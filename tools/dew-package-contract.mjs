// Dew package contract v1. No CLI, compiler, or network work belongs here.
import { createHash } from "node:crypto";
import { constants } from "node:fs";
import { lstat, open, readdir, realpath } from "node:fs/promises";
import { join, relative, resolve, sep } from "node:path";
import { TextDecoder } from "node:util";

export const MAX_MANIFEST_BYTES = 1_048_576;
export const MAX_NAME_BYTES = 255;
export const MAX_VERSION_BYTES = 255;
export const MAX_REQUIREMENT_BYTES = 2048;
export const MAX_DEPENDENCIES = 256;
export const MAX_PATH_BYTES = 4096;
export const MAX_SOURCE_BYTES = 16 * 1_048_576;
export const MAX_FILES = 65_536;
export const MAX_CAPSULE_BYTES = 64 * 1_048_576;
// Local compiler cache codecs retain this separate bound. encodeCapsule uses
// the smaller publish policy above, including the checksum and metadata.
export const MAX_LOCAL_ARTIFACT_BYTES = 256 * 1_048_576;

const hasLoneSurrogate = /[\uD800-\uDFFF]/u;
const manifestFields = new Set(["name", "version", "dependencies"]);

function boundedString(value, max, field) {
  if (typeof value !== "string" || value.length === 0 || value.length > max ||
      hasLoneSurrogate.test(value) || Buffer.byteLength(value) > max) {
    throw new Error(`${field} must be a nonempty UTF-8 string of at most ${max} bytes`);
  }
  return value;
}

function validateName(value, field = "package name") {
  boundedString(value, MAX_NAME_BYTES, field);
  if (/[^a-z0-9@/._-]/.test(value) || !/^@[a-z0-9._-]+\/[a-z0-9._-]+$/.test(value)) {
    throw new Error(`${field} must use @scope/name with lowercase ASCII letters, digits, '.', '_', or '-'`);
  }
}

function validU32(text) {
  return (text.length === 1 || text[0] !== "0") && Number(text) <= 0xffff_ffff;
}

function validateVersion(value, field = "package version") {
  boundedString(value, MAX_VERSION_BYTES, field);
  const match = /^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$/.exec(value);
  if (!match || match[0] !== value || !match.slice(1, 4).every(validU32) ||
      (match[4] && match[4].split(".").some((part) => /^[0-9]+$/.test(part) && !validU32(part)))) {
    throw new Error(`${field} must be strict SemVer with U32 core and numeric prerelease identifiers`);
  }
}

function validateRequirement(value) {
  boundedString(value, MAX_REQUIREMENT_BYTES, "dependency requirement");
  if (value === "*") return;
  if (value.startsWith("git+")) {
    // Match dew.std.package. This is deliberately not an npm or URL parser.
    const hash = value.indexOf("#");
    if (hash <= 4 || hash === value.length - 1 || value.includes("\0")) {
      throw new Error("Git dependency requirement must use git+source#ref");
    }
    return;
  }
  validateVersion(value[0] === "^" || value[0] === "~" ? value.slice(1) : value, "dependency requirement version");
}

function objectFields(value, field) {
  if (!value || typeof value !== "object" ||
      (Object.getPrototypeOf(value) !== Object.prototype && Object.getPrototypeOf(value) !== null)) {
    throw new Error(`${field} must be a plain object`);
  }
  const fields = Object.getOwnPropertyDescriptors(value);
  for (const key of Reflect.ownKeys(fields)) {
    if (typeof key !== "string" || !Object.hasOwn(fields[key], "value")) {
      throw new Error(`${field} must contain string data fields`);
    }
  }
  return fields;
}

function validateManifest(value) {
  const fields = objectFields(value, "package manifest");
  for (const key of Object.keys(fields)) {
    if (!manifestFields.has(key)) throw new Error(`unknown package manifest field: ${key}`);
  }
  const name = Object.hasOwn(fields, "name") ? fields.name.value : undefined;
  const version = Object.hasOwn(fields, "version") ? fields.version.value : undefined;
  validateName(name);
  validateVersion(version);
  const dependencies = {};
  if (Object.hasOwn(fields, "dependencies")) {
    const values = objectFields(fields.dependencies.value, "package dependencies");
    const names = Object.keys(values);
    if (names.length > MAX_DEPENDENCIES) throw new Error(`package dependencies exceed the ${MAX_DEPENDENCIES} limit`);
    for (const key of names) {
      validateName(key, "dependency name");
      validateRequirement(values[key].value);
      dependencies[key] = values[key].value;
    }
  }
  return { name, version, dependencies };
}

/** Parse the two-level manifest schema without losing duplicate JSON keys. */
export function parsePackageManifest(text) {
  if (typeof text !== "string" || text.length > MAX_MANIFEST_BYTES || Buffer.byteLength(text) > MAX_MANIFEST_BYTES) {
    throw new Error(`package manifest exceeds the ${MAX_MANIFEST_BYTES} byte limit or is not text`);
  }
  let offset = 0;
  function whitespace() { while (offset < text.length && " \t\r\n".includes(text[offset])) offset++; }
  function token(expected) {
    whitespace();
    if (text[offset] !== expected) throw new Error(`invalid manifest JSON: expected '${expected}' at ${offset}`);
    offset++;
  }
  function string(field) {
    whitespace();
    if (text[offset] !== '"') throw new Error(`invalid manifest JSON: ${field} must be a string at ${offset}`);
    const start = offset++;
    while (offset < text.length) {
      const byte = text[offset++];
      if (byte === "\\") offset++;
      else if (byte === '"') {
        let value;
        try { value = JSON.parse(text.slice(start, offset)); }
        catch (error) { throw new Error(`invalid manifest JSON string for ${field}: ${error.message}`); }
        if (hasLoneSurrogate.test(value)) throw new Error(`invalid manifest JSON Unicode in ${field}`);
        return value;
      }
    }
    throw new Error(`invalid manifest JSON: unterminated ${field}`);
  }
  function object(dependencies) {
    token("{");
    const result = {};
    const seen = new Set();
    whitespace();
    if (text[offset] === "}") { offset++; return result; }
    for (;;) {
      const key = string("key");
      if (seen.has(key)) throw new Error(`duplicate ${dependencies ? "dependency" : "manifest"} key: ${key}`);
      seen.add(key);
      if (dependencies) {
        if (seen.size > MAX_DEPENDENCIES) throw new Error(`package dependencies exceed the ${MAX_DEPENDENCIES} limit`);
        validateName(key, "dependency name");
      } else if (!manifestFields.has(key)) throw new Error(`unknown package manifest field: ${key}`);
      token(":");
      result[key] = !dependencies && key === "dependencies" ? object(true) : string(dependencies ? "dependency requirement" : key);
      whitespace();
      if (text[offset] === "}") { offset++; return result; }
      token(",");
    }
  }
  const value = object(false);
  whitespace();
  if (offset !== text.length) throw new Error(`invalid manifest JSON: trailing data at ${offset}`);
  return validateManifest(value);
}

function noSymlink(info, path) {
  if (info.isSymbolicLink()) throw new Error(`package path is a symlink: ${path}`);
}

function sameFile(left, right) {
  return left.dev === right.dev && left.ino === right.ino;
}

/** Bounded regular-file read. Keep filesystem errors visible to the caller. */
export async function readPackageManifest(manifestPath) {
  const before = await lstat(manifestPath);
  noSymlink(before, manifestPath);
  if (!before.isFile()) throw new Error(`package manifest is not a regular file: ${manifestPath}`);
  if (before.size > MAX_MANIFEST_BYTES) throw new Error("package manifest exceeds the 1 MiB limit");
  const handle = await open(manifestPath, constants.O_RDONLY | (constants.O_NOFOLLOW ?? 0) | (constants.O_NONBLOCK ?? 0));
  try {
    const opened = await handle.stat();
    if (!opened.isFile() || !sameFile(before, opened) || opened.size !== before.size) {
      throw new Error(`package manifest changed before read: ${manifestPath}`);
    }
    // One extra byte detects growth without reading an unbounded stream.
    const bytes = Buffer.alloc(opened.size + 1);
    let length = 0;
    while (length < bytes.length) {
      const { bytesRead } = await handle.read(bytes, length, bytes.length - length, length);
      if (bytesRead === 0) break;
      length += bytesRead;
    }
    const after = await handle.stat();
    const current = await lstat(manifestPath);
    noSymlink(current, manifestPath);
    if (length !== opened.size || after.size !== opened.size || after.mtimeMs !== opened.mtimeMs ||
        after.ctimeMs !== opened.ctimeMs || !sameFile(opened, current)) {
      throw new Error(`package manifest changed during read: ${manifestPath}`);
    }
    let text;
    try { text = new TextDecoder("utf-8", { fatal: true, ignoreBOM: true }).decode(bytes.subarray(0, length)); }
    catch { throw new Error(`package manifest is not valid UTF-8: ${manifestPath}`); }
    return parsePackageManifest(text);
  } finally { await handle.close(); }
}

function validatePath(path) {
  boundedString(path, MAX_PATH_BYTES, "source path");
  if (path.startsWith("/") || /^[A-Za-z]:\//.test(path) || path.includes("\\") || path.includes("\0") ||
      !path.endsWith(".dew") || path.startsWith("dew.json/") ||
      path.split("/").some((part) => part === "" || part === "." || part === "..")) {
    throw new Error(`invalid source path: ${JSON.stringify(path)}`);
  }
}

function checkPathConflicts(paths) {
  for (const path of paths) {
    for (let end = path.indexOf("/"); end >= 0; end = path.indexOf("/", end + 1)) {
      if (paths.has(path.slice(0, end))) throw new Error(`source path prefix conflict: ${path}`);
    }
  }
}

/** Select sources, including tests. This inventory does not freeze file bytes.
 * The snapshot consumer must use no-follow open, fstat, bounded reads, and
 * identity/size checks. It must also recheck source directory components.
 */
export async function collectSourceFiles(packageRoot) {
  const requestedRoot = resolve(packageRoot);
  const rootInfo = await lstat(requestedRoot);
  noSymlink(rootInfo, requestedRoot);
  if (!rootInfo.isDirectory()) throw new Error(`package root is not a directory: ${requestedRoot}`);
  const root = await realpath(requestedRoot);
  const output = [];
  async function checked(path, previous) {
    const info = await lstat(path);
    noSymlink(info, path);
    if (await realpath(path) !== path || (previous && !sameFile(info, previous))) {
      throw new Error(`package source path changed or escapes its root: ${path}`);
    }
    return info;
  }
  async function source(path, info) {
    if (!info.isFile()) throw new Error(`source is not a regular file: ${path}`);
    const logical = relative(root, path).split(sep).join("/");
    validatePath(logical);
    if (info.size > MAX_SOURCE_BYTES) throw new Error(`source exceeds the 16 MiB limit: ${logical}`);
    if (output.length === MAX_FILES) throw new Error(`source file count exceeds the ${MAX_FILES} limit`);
    output.push({ path: logical, absolutePath: path, size: info.size });
  }
  async function collect(directory, recursive) {
    const before = await checked(directory);
    if (!before.isDirectory()) throw new Error(`source directory changed: ${directory}`);
    if (Buffer.byteLength(relative(root, directory)) > MAX_PATH_BYTES) throw new Error("source directory path exceeds the 4096 byte limit");
    const entries = await readdir(directory, { withFileTypes: true });
    for (const entry of entries) {
      const path = join(directory, entry.name);
      if (recursive || entry.name.endsWith(".dew")) {
        const info = await checked(path);
        if (info.isDirectory()) {
          if (recursive) await collect(path, true);
        } else if (entry.name.endsWith(".dew")) await source(path, info);
      }
    }
    await checked(directory, before);
  }
  const sourceRoot = join(root, "src");
  let src;
  try { src = await lstat(sourceRoot); }
  catch (error) { if (error.code !== "ENOENT") throw error; }
  if (src) noSymlink(src, sourceRoot);
  await collect(src?.isDirectory() ? sourceRoot : root, Boolean(src?.isDirectory()));
  if (!output.length) throw new Error("package has no conventional .dew sources");
  const paths = new Set(output.map((file) => file.path));
  checkPathConflicts(paths);
  // Cache UTF-8 keys so the comparator does not allocate on each comparison.
  return output.map((file) => ({ file, key: Buffer.from(file.path) }))
    .sort((left, right) => Buffer.compare(left.key, right.key)).map(({ file }) => file);
}

/** Encode exactly the supplied snapshot. Never read files or recompute hashes. */
export function encodeCapsule({ manifest, files, source, interfaceFingerprint, integrity }) {
  const checked = validateManifest(manifest);
  boundedString(source, MAX_REQUIREMENT_BYTES, "package source");
  if (typeof interfaceFingerprint !== "string" || interfaceFingerprint.length !== 64 || !/^[0-9a-f]+$/.test(interfaceFingerprint) ||
      typeof integrity !== "string" || integrity.length !== 71 || !/^sha256-[0-9a-f]+$/.test(integrity)) {
    throw new Error("invalid package provenance: expected a SHA-256 integrity and interface fingerprint");
  }
  if (!Array.isArray(files) || files.length === 0 || files.length > MAX_FILES) {
    throw new Error(`capsule files must contain 1 to ${MAX_FILES} sources`);
  }
  const metadata = [checked.name, checked.version, source, integrity, interfaceFingerprint];
  const dependencies = Object.entries(checked.dependencies).sort(([left], [right]) => left < right ? -1 : left > right ? 1 : 0);
  let size = 68 + metadata.reduce((sum, value) => sum + Buffer.byteLength(value), 0);
  for (const [name, requirement] of dependencies) size += 8 + Buffer.byteLength(name) + Buffer.byteLength(requirement);
  const paths = new Set();
  const records = [];
  for (const file of files) {
    const path = file?.path;
    const contents = file?.contents;
    validatePath(path);
    if (paths.has(path)) throw new Error(`duplicate source path: ${path}`);
    paths.add(path);
    if (!Buffer.isBuffer(contents)) throw new Error(`source contents must be a Buffer: ${path}`);
    if (contents.length > MAX_SOURCE_BYTES) throw new Error(`source exceeds the 16 MiB limit: ${path}`);
    size += 8 + Buffer.byteLength(path) + contents.length;
    if (size > MAX_CAPSULE_BYTES) throw new Error("package capsule exceeds the 64 MiB publish limit");
    records.push({ path: Buffer.from(path), contents });
  }
  checkPathConflicts(paths);
  records.sort((left, right) => Buffer.compare(left.path, right.path));
  const output = Buffer.allocUnsafe(size);
  let offset = 0;
  function u32(value) { output.writeUInt32LE(value, offset); offset += 4; }
  function field(value) {
    if (Buffer.isBuffer(value)) {
      u32(value.length);
      offset += value.copy(output, offset);
    } else {
      u32(Buffer.byteLength(value));
      offset += output.write(value, offset, "utf8");
    }
  }
  offset += output.write("DEWPKG1\0", offset, "binary");
  for (const value of metadata) field(value);
  u32(dependencies.length);
  for (const [name, requirement] of dependencies) { field(name); field(requirement); }
  u32(records.length);
  for (const file of records) { field(file.path); field(file.contents); }
  if (offset !== size - 32) throw new Error(`capsule v1 size mismatch: wrote ${offset}, expected ${size - 32}`);
  createHash("sha256").update(output.subarray(0, offset)).digest().copy(output, offset);
  return output;
}
