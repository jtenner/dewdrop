import { createHash } from "node:crypto";
import { constants, createReadStream } from "node:fs";
import { chmod, lstat, mkdir, mkdtemp, open, readdir, realpath, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { delimiter, dirname, isAbsolute, join, relative, resolve, sep } from "node:path";
import { collectSourceFiles, encodeCapsule, parsePackageManifest } from "./dew-package-contract.mjs";
import { MAX_LOCK_BYTES, parsePackageLock } from "./dew-package-lock.mjs";

const SOURCE_MAX = 16 * 1_048_576;
const MANIFEST_MAX = 1_048_576;
const PUBLISH_MAX = 64 * 1_048_576;
const LOCAL_MAX = 256 * 1_048_576;
const GRAPH_MAX = 4096;
const sha256 = bytes => createHash("sha256").update(bytes).digest("hex");
const compare = (a, b) => Buffer.compare(Buffer.from(a), Buffer.from(b));
const moduleName = name => name.slice(1).replaceAll("/", ".").replaceAll("-", "_");

function inside(root, path) {
  const local = relative(root, path);
  return local === "" || (!isAbsolute(local) && local !== ".." && !local.startsWith(`..${sep}`));
}

// Check every parent, not only the final directory entry. O_NOFOLLOW protects
// the opened file too. Recheck after the read to detect parent replacement.
async function noSymlinks(path) {
  path = resolve(path);
  let at = path;
  while (true) {
    if ((await lstat(at)).isSymbolicLink()) throw new Error(`symlink input is not allowed: ${at}`);
    const parent = dirname(at);
    if (parent === at) break;
    at = parent;
  }
  if (await realpath(path) !== path) throw new Error(`unsafe input path: ${path}`);
}

async function readBounded(path, limit, label) {
  await noSymlinks(path);
  const initial = await lstat(path);
  if (!initial.isFile()) throw new Error(`${label} must be a regular file: ${path}`);
  const file = await open(path, constants.O_RDONLY | (constants.O_NOFOLLOW ?? 0) | (constants.O_NONBLOCK ?? 0));
  try {
    const before = await file.stat();
    if (!before.isFile() || initial.dev !== before.dev || initial.ino !== before.ino) throw new Error(`${label} changed before capture: ${path}`);
    if (before.size > limit) throw new Error(`${label} exceeds its ${limit === SOURCE_MAX ? "16 MiB" : `${limit} byte`} limit: ${path}`);
    // One spare byte detects growth without an unbounded readFile allocation.
    const buffer = Buffer.allocUnsafe(before.size + 1);
    let length = 0;
    while (length < buffer.length) {
      const { bytesRead } = await file.read(buffer, length, buffer.length - length, null);
      if (bytesRead === 0) break;
      length += bytesRead;
    }
    const after = await file.stat();
    await noSymlinks(path);
    const entry = await lstat(path);
    if (length !== before.size || before.size !== after.size || before.mtimeMs !== after.mtimeMs || before.ctimeMs !== after.ctimeMs || entry.dev !== after.dev || entry.ino !== after.ino) {
      throw new Error(`input changed during capture: ${path}`);
    }
    return buffer.subarray(0, length);
  } finally {
    await file.close();
  }
}

async function optionalBytes(path, limit, label) {
  try { return await readBounded(path, limit, label); }
  catch (error) { if (error.code === "ENOENT") return null; throw error; }
}

function hashField(hash, value) {
  const bytes = Buffer.isBuffer(value) ? value : Buffer.from(value);
  const length = Buffer.allocUnsafe(4); length.writeUInt32LE(bytes.length);
  hash.update(length).update(bytes);
}

// This is the existing compiler source-integrity domain and field order.
// Source tests are included. Dependencies follow source records.
function integrityHash(manifest) {
  const hash = createHash("sha256").update("DEW_PACKAGE_INTEGRITY_V1\0");
  for (const value of [manifest.name, manifest.version, moduleName(manifest.name)]) hashField(hash, value);
  return hash;
}

function finishIntegrity(hash, manifest) {
  for (const [name, requirement] of Object.entries(manifest.dependencies).sort(([a], [b]) => compare(a, b))) {
    hashField(hash, name); hashField(hash, requirement);
  }
  return `sha256-${hash.digest("hex")}`;
}

async function put(path, bytes) {
  await mkdir(dirname(path), { recursive: true, mode: 0o700 });
  await writeFile(path, bytes, { flag: "wx", mode: 0o400 });
}

function encodedHeaderSize(manifest, source) {
  const field = value => 4 + Buffer.byteLength(value);
  return 8 + field(manifest.name) + field(manifest.version) + field(source) + field(`sha256-${"0".repeat(64)}`) + field("0".repeat(64)) + 4 +
    Object.entries(manifest.dependencies).reduce((n, [name, request]) => n + field(name) + field(request), 0) + 4 + 32;
}

async function capturePackage(manifestPath, target, source, maximum) {
  const original = await readBounded(manifestPath, MANIFEST_MAX, "manifest");
  let text;
  try { text = new TextDecoder("utf-8", { fatal: true, ignoreBOM: true }).decode(original); }
  catch { throw new Error(`package manifest is not valid UTF-8: ${manifestPath}`); }
  const manifest = parsePackageManifest(text);
  const root = dirname(manifestPath);
  await noSymlinks(root);
  const selected = await collectSourceFiles(root);
  if (!selected.length || selected.length > 65536) throw new Error("package source file count is outside its bound");
  let encodedSize = encodedHeaderSize(manifest, source);
  // Preflight sizes before copying or allocating source buffers.
  for (const file of selected) {
    if (file.size > SOURCE_MAX) throw new Error(`source exceeds the 16 MiB limit: ${file.path}`);
    encodedSize += 8 + Buffer.byteLength(file.path) + file.size;
    if (encodedSize > maximum) throw new Error(`package capsule exceeds the ${maximum === PUBLISH_MAX ? "64 MiB publish" : "256 MiB local artifact"} limit`);
  }
  const hash = integrityHash(manifest);
  const files = [];
  for (const file of selected) {
    if (!inside(root, resolve(file.absolutePath)) || relative(root, file.absolutePath).split(sep).join("/") !== file.path) throw new Error(`unsafe selected source: ${file.path}`);
    const bytes = await readBounded(file.absolutePath, SOURCE_MAX, "source");
    if (bytes.length !== file.size) throw new Error(`source changed during capture: ${file.path}`);
    hashField(hash, file.path); hashField(hash, bytes);
    await put(join(target, file.path), bytes);
    files.push({ path: file.path, size: bytes.length, sha256: sha256(bytes) });
  }
  const canonical = Buffer.from(`${JSON.stringify(manifest)}\n`);
  const capturedManifest = join(target, "dew.json");
  await put(capturedManifest, canonical);
  return { manifest, manifestPath: capturedManifest, files, integrity: finishIntegrity(hash, manifest), manifestSha256: sha256(original), capturedManifestSha256: sha256(canonical) };
}

async function captureGraph(manifestPath, target, source) {
  const root = await capturePackage(manifestPath, target, source, PUBLISH_MAX);
  const originalRoot = dirname(manifestPath);
  const lockBytes = await optionalBytes(join(originalRoot, "dew.lock"), MAX_LOCK_BYTES, "lockfile");
  let lock = { lockfileVersion: 1, packages: [] };
  if (lockBytes) {
    let lockText;
    try { lockText = new TextDecoder("utf-8", { fatal: true, ignoreBOM: true }).decode(lockBytes); }
    catch { throw new Error("lockfile is not valid UTF-8"); }
    lock = parsePackageLock(lockText);
  }
  const locked = new Map();
  for (const entry of lock.packages) {
    if (!entry || typeof entry.name !== "string" || locked.has(entry.name)) throw new Error("invalid or duplicate locked package name");
    for (const key of ["version", "source", "path", "integrity", "interface"]) if (typeof entry[key] !== "string") throw new Error(`locked package ${key} must be a string`);
    if (!/^sha256-[0-9a-f]{64}$/.test(entry.integrity) || !/^[0-9a-f]{64}$/.test(entry.interface)) throw new Error(`invalid locked provenance for ${entry.name}`);
    locked.set(entry.name, entry);
  }
  const packages = new Map([[root.manifest.name, root]]);
  const visiting = new Set();
  const rewritten = [];
  const graph = [];
  const modules = new Map();
  async function visit(package_) {
    const name = package_.manifest.name;
    if (visiting.has(name)) throw new Error(`dependency cycle at ${name}`);
    const module = moduleName(name);
    if (modules.has(module) && modules.get(module) !== name) throw new Error(`package module name collision: ${module}`);
    modules.set(module, name);
    visiting.add(name);
    for (const dep of Object.keys(package_.manifest.dependencies).sort(compare)) {
      if (visiting.has(dep)) throw new Error(`dependency cycle at ${dep}`);
      if (packages.has(dep)) continue;
      const entry = locked.get(dep);
      if (!entry) throw new Error(`dependency ${dep} is missing from dew.lock`);
      if (!entry.path || entry.path.includes("\\") || entry.path.includes("\0") || isAbsolute(entry.path)) throw new Error(`unsafe dependency lock path: ${entry.path}`);
      const inputPath = resolve(originalRoot, entry.path);
      if (!inside(originalRoot, inputPath)) throw new Error(`dependency lock path escapes package workspace: ${entry.path}`);
      await noSymlinks(inputPath);
      const definition = (await lstat(inputPath)).isDirectory() ? join(inputPath, "dew.json") : inputPath;
      const logical = `.dew-snapshot/${graph.length}/dew.json`;
      const captured = await capturePackage(definition, dirname(join(target, logical)), entry.source, LOCAL_MAX);
      if (captured.manifest.name !== dep || captured.manifest.version !== entry.version) throw new Error(`locked package identity mismatch for ${dep}`);
      if (captured.integrity !== entry.integrity) throw new Error(`dependency integrity mismatch for ${dep}`);
      packages.set(dep, captured);
      rewritten.push({ ...entry, path: logical });
      graph.push({ name: dep, version: entry.version, source: entry.source, integrity: captured.integrity, interfaceFingerprint: entry.interface, dependencies: captured.manifest.dependencies, manifestSha256: captured.manifestSha256, capturedManifestSha256: captured.capturedManifestSha256, files: captured.files });
      await visit(captured);
    }
    visiting.delete(name);
  }
  await visit(root);
  rewritten.sort((a, b) => compare(a.name, b.name));
  graph.sort((a, b) => compare(a.name, b.name));
  const capturedLock = Buffer.from(`${JSON.stringify({ lockfileVersion: 1, packages: rewritten })}\n`);
  await put(join(target, "dew.lock"), capturedLock);
  return { root, graph, lock: { originalSha256: lockBytes ? sha256(lockBytes) : null, capturedSha256: sha256(capturedLock), packages: rewritten } };
}

async function captureStandard(repositoryRoot, target, environment) {
  // Same ordered root search as bootstrap_standard_root. No config or network.
  const candidates = environment.DEW_PACKAGE_ROOTS ? environment.DEW_PACKAGE_ROOTS.split(delimiter) : [repositoryRoot];
  let selected;
  for (const candidate of candidates) {
    for (const root of [resolve(candidate, "dew.std"), resolve(candidate)]) {
      try { await lstat(join(root, "std/preamble/00-builtins.dew")); selected = root; break; }
      catch (error) { if (error.code !== "ENOENT" && error.code !== "ENOTDIR") throw error; }
    }
    if (selected) break;
  }
  if (!selected) throw new Error("cannot locate dew.std package in ordered roots");
  await noSymlinks(join(selected, "std"));
  const hash = createHash("sha256").update("DEW_LOCAL_STANDARD_INPUTS_V1\0");
  let count = 0;
  async function walk(directory) {
    const entries = await readdir(directory, { withFileTypes: true });
    entries.sort((a, b) => compare(a.name, b.name));
    for (const entry of entries) {
      const path = join(directory, entry.name);
      if (entry.isSymbolicLink()) throw new Error(`symlink standard input is not allowed: ${path}`);
      if (entry.isDirectory()) await walk(path);
      else if (entry.isFile() && entry.name.endsWith(".dew")) {
        if (++count > 65536) throw new Error("standard source file count is outside its bound");
        const logical = relative(selected, path).split(sep).join("/");
        const bytes = await readBounded(path, SOURCE_MAX, "standard source");
        hashField(hash, logical); hashField(hash, bytes);
        await put(join(target, logical), bytes);
      }
    }
  }
  await walk(join(selected, "std"));
  return { sha256: hash.digest("hex"), files: count, identityKind: "captured-standard-sources-v1" };
}

async function freezeDirectories(root) {
  for (const entry of await readdir(root, { withFileTypes: true })) if (entry.isDirectory()) await freezeDirectories(join(root, entry.name));
  await chmod(root, 0o500);
}

async function thawDirectories(root) {
  await chmod(root, 0o700);
  for (const entry of await readdir(root, { withFileTypes: true })) if (entry.isDirectory()) await thawDirectories(join(root, entry.name));
}

/** All package reads after capture use private files. Compiler and ABI tools
 * are trusted installed tools, not copied package inputs. `run` is injectable
 * so functional checks do not build the compiler or access the network. */
export async function preparePackage({ manifestPath, source, repositoryRoot, run, environment = process.env }, services = {}) {
  const temporary = await mkdtemp(join(await realpath(tmpdir()), "dew-package-"));
  let primary;
  try {
    const packageRoot = join(temporary, "package");
    const standardRoot = join(temporary, "standard");
    const { root, graph, lock } = await captureGraph(resolve(manifestPath), packageRoot, source);
    const standard = await captureStandard(repositoryRoot, standardRoot, environment);
    await freezeDirectories(packageRoot); await freezeDirectories(standardRoot);
    const env = { ...environment, DEW_CACHE_DIR: join(temporary, "cache"), DEW_PACKAGE_ROOTS: standardRoot, DEW_PACKAGE_OFFLINE: "1" };
    const wasm = join(temporary, "package.wasm");
    await run([join(repositoryRoot, "tools/dew"), "build", "--manifest", root.manifestPath, "--package-root", standardRoot, "-o", wasm], { cwd: packageRoot, env });
    const abiText = await run(["node", join(repositoryRoot, "tools/dew-abi.mjs"), wasm, "interface"], { cwd: packageRoot, env, capture: true, message: "could not read the compiled package interface" });
    let abi;
    try { abi = JSON.parse(abiText); } catch { throw new Error("compiler emitted invalid interface metadata"); }
    if (!/^[0-9a-f]{64}$/.test(abi?.interfaceFingerprint) || abi.path !== moduleName(root.manifest.name)) throw new Error("compiler returned invalid package interface provenance");
    const integrity = await run([join(repositoryRoot, "tools/dew"), "package-integrity", root.manifestPath], { cwd: packageRoot, env, capture: true, message: "could not calculate package integrity" });
    if (integrity !== root.integrity) throw new Error("compiler package integrity differs from captured source integrity");
    const files = [];
    for (const entry of root.files) {
      const contents = await readBounded(join(packageRoot, entry.path), SOURCE_MAX, "captured source");
      if (sha256(contents) !== entry.sha256) throw new Error(`captured source changed: ${entry.path}`);
      files.push({ path: entry.path, contents });
    }
    const encoded = encodeCapsule({ manifest: root.manifest, files, source, interfaceFingerprint: abi.interfaceFingerprint, integrity });
    if (encoded.length > PUBLISH_MAX) throw new Error("package capsule exceeds the 64 MiB publish limit");
    const buildHash = createHash("sha256");
    let buildBytes = 0;
    for await (const chunk of createReadStream(wasm)) { buildHash.update(chunk); buildBytes += chunk.length; }
    const inputs = {
      schemaVersion: 1,
      kind: "dew-local-package-inputs",
      manifest: root.manifest,
      inputManifest: resolve(manifestPath),
      manifestSha256: root.manifestSha256,
      capturedManifestSha256: root.capturedManifestSha256,
      module: moduleName(root.manifest.name),
      source, sourceIntegrity: integrity, interfaceFingerprint: abi.interfaceFingerprint,
      files: root.files, dependencies: graph, lock, standard,
      build: { wasmSha256: buildHash.digest("hex"), wasmBytes: buildBytes, abi, compilerBuildIdentity: null, compilerBuildIdentityNote: "The current ABI does not expose the compiler build identity." },
      capsule: { sha256: sha256(encoded), bytes: encoded.length, mediaType: "application/vnd.dewdrop.package-v1" },
      release: null,
      releaseNote: "Local captured inputs only. GitHub tag, commit, ownership, public metadata and release validation are not prepared.",
    };
    return { encoded, manifest: root.manifest, inputs };
  } catch (error) {
    primary = error;
    throw error;
  } finally {
    try {
      // Also thaw after a partial freeze. Capture errors can leave only one tree.
      for (const root of ["package", "standard"]) {
        try { await thawDirectories(join(temporary, root)); }
        catch (error) { if (error.code !== "ENOENT") throw error; }
      }
      await (services.remove ?? rm)(temporary, { recursive: true, force: true });
    } catch (error) {
      throw new Error(`${primary ? `${primary.message}; ` : ""}could not remove private package snapshot ${temporary}: ${error.message}`, { cause: error });
    }
  }
}

/** Reserve a whole new output directory. No existing file can be overwritten. */
export async function retainPackage(artifact, output) {
  output = resolve(output);
  await noSymlinks(dirname(output));
  await mkdir(output, { mode: 0o700 });
  try {
    const capsulePath = join(output, "package.dpa");
    const inputsPath = join(output, "INPUTS.json");
    const inputs = { ...artifact.inputs, output: { capsule: capsulePath, inputs: inputsPath } };
    await writeFile(capsulePath, artifact.encoded, { flag: "wx", mode: 0o600 });
    await writeFile(inputsPath, `${JSON.stringify(inputs, null, 2)}\n`, { flag: "wx", mode: 0o600 });
    return inputs;
  } catch (error) {
    try { await rm(output, { recursive: true, force: true }); }
    catch (cleanup) { throw new Error(`${error.message}; could not remove incomplete output ${output}: ${cleanup.message}`); }
    throw error;
  }
}
