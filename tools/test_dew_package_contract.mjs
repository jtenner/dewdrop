#!/usr/bin/env node
// Narrow functional checks only. No compiler, network, or timing harness.
import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import * as fs from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { runInNewContext } from "node:vm";
import { execFileSync } from "node:child_process";

const BASE = "20f902acb6caa56a49712df832aeb0c46ec520b8";
const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const baseline = process.argv.includes("--baseline");
const temporary = await fs.mkdtemp(join(tmpdir(), "dew-contract-check-"));
const fingerprint = "a".repeat(64);
const integrity = `sha256-${"b".repeat(64)}`;
const manifest = { name: "@test/example", version: "1.2.3", dependencies: {} };
const input = (changes = {}) => ({ manifest, files: [{ path: "src/main.dew", contents: Buffer.from("fn main {}\n") }], source: "registry:https://example.test", interfaceFingerprint: fingerprint, integrity, ...changes });
let serial = 0;
async function fixture(files = { "main.dew": "source" }) {
  const directory = join(temporary, String(serial++));
  await fs.mkdir(directory);
  for (const [path, contents] of Object.entries(files)) {
    await fs.mkdir(dirname(join(directory, path)), { recursive: true });
    await fs.writeFile(join(directory, path), contents);
  }
  return directory;
}

// Load the real, pinned publisher functions. Replace only CLI exit and I/O for
// the in-memory encoder adapter. No validation is copied into this adapter.
function legacyFunctions(overrides = {}) {
  const source = execFileSync("git", ["show", `${BASE}:tools/dew-registry.mjs`], { cwd: root, encoding: "utf8" });
  const section = source.slice(source.indexOf("async function sourceFiles("), source.indexOf("async function publish("));
  const select = overrides.selectedPaths ? "sourceFiles = async () => selectedPaths;" : "";
  return runInNewContext(`${section}\n${select}\n({ sourceFiles, capsule })`, {
    Buffer, createHash, join, relative, dirname,
    ...fs, fail(message) { throw new Error(message); }, ...overrides,
  });
}

let contract;
if (baseline) {
  const legacy = legacyFunctions();
  // The virtual manifest path must stay inside a real source fixture.
  contract = {
    async parsePackageManifest(text) {
      const directory = await fixture();
      const { capsule } = legacyFunctions({ readFile: async (path) => path === join(directory, "dew.json") ? text : Buffer.from("source") });
      return (await capsule(join(directory, "dew.json"), input().source, fingerprint, integrity)).manifest;
    },
    async readPackageManifest(path) { return (await legacy.capsule(path, input().source, fingerprint, integrity)).manifest; },
    async collectSourceFiles(directory) {
      return Promise.all((await legacy.sourceFiles(directory)).map(async (absolutePath) => ({ path: relative(directory, absolutePath).replaceAll("\\", "/"), absolutePath, size: (await fs.stat(absolutePath)).size })));
    },
    async encodeCapsule(value) {
      const directory = "/virtual-package";
      const paths = value.files.map((file) => file.path.startsWith("/") ? file.path : `${directory}/${file.path}`);
      const files = new Map(value.files.map((file, index) => [paths[index], file.contents]));
      // Override sourceFiles after evaluation, while retaining the real encoder.
      const { capsule } = legacyFunctions({
        selectedPaths: paths,
        readFile: async (path) => path === join(directory, "dew.json") ? JSON.stringify(value.manifest) : files.get(path),
      });
      return (await capsule(join(directory, "dew.json"), value.source, value.interfaceFingerprint, value.integrity)).encoded;
    },
  };
} else {
  contract = await import("./dew-package-contract.mjs");
}

const checks = [];
function check(name, run) { checks.push({ name, run }); }
const parse = (value) => contract.parsePackageManifest(typeof value === "string" ? value : JSON.stringify(value));
async function rejected(operation, reason) {
  await assert.rejects(async () => { await operation(); }, reason);
}

check("manifest: absent dependencies means own empty object", async () => {
  const result = await parse({ name: manifest.name, version: manifest.version });
  assert.equal(Object.hasOwn(result, "dependencies"), true);
  assert.deepEqual(Object.entries(result.dependencies), []);
});
check("manifest: valid plain result", async () => {
  const result = await parse(manifest);
  assert.equal(result.name, manifest.name);
  assert.equal(result.version, manifest.version);
  assert.equal(Array.isArray(result), false);
  assert.deepEqual(Object.keys(result).sort(), ["dependencies", "name", "version"]);
});
for (const [name, text, reason] of [
  ["unknown field", '{"name":"@t/p","version":"1.0.0","dependencies":{},"script":"x"}', /unknown.*field/i],
  ["duplicate field", '{"name":"@t/p","name":"@t/q","version":"1.0.0","dependencies":{}}', /duplicate/i],
  ["escaped duplicate field", '{"name":"@t/p","na\\u006de":"@t/q","version":"1.0.0","dependencies":{}}', /duplicate/i],
  ["duplicate dependency", '{"name":"@t/p","version":"1.0.0","dependencies":{"@a/b":"*","@a/b":"^1.0.0"}}', /duplicate/i],
  ["escaped duplicate dependency", '{"name":"@t/p","version":"1.0.0","dependencies":{"@a/b":"*","@a\\u002fb":"^1.0.0"}}', /duplicate/i],
  ["proto field", '{"name":"@t/p","version":"1.0.0","dependencies":{},"__proto__":{}}', /unknown.*field/i],
  ["proto dependency", '{"name":"@t/p","version":"1.0.0","dependencies":{"__proto__":"*"}}', /dependency.*name/i],
  ["null dependencies", '{"name":"@t/p","version":"1.0.0","dependencies":null}', /dependencies|manifest/i],
  ["array dependencies", '{"name":"@t/p","version":"1.0.0","dependencies":[]}', /dependencies|manifest/i],
  ["malformed JSON", '{"name":', /JSON/i],
  ["trailing JSON", '{"name":"@t/p","version":"1.0.0","dependencies":{}} true', /JSON/i],
  ["nested dependency", '{"name":"@t/p","version":"1.0.0","dependencies":{"@a/b":{}}}', /requirement|string/i],
]) check(`manifest: reject ${name}`, () => rejected(() => parse(text), reason));

for (const name of ["scope/name", "@/name", "@scope/", "@a/b/c", "@A/b", "@a/b!", "@a/é", "@a/b\n", `@a/${"b".repeat(253)}`]) {
  check(`name: reject ${JSON.stringify(name)}`, () => rejected(() => parse({ ...manifest, name }), /package name/i));
}
check("name: punctuation and 255 byte boundary", async () => {
  for (const name of ["@._-/._-", `@a/${"b".repeat(252)}`]) assert.equal((await parse({ ...manifest, name })).name, name);
});
const goodVersions = ["0.0.0", "4294967295.4294967295.4294967295", "1.2.3-4294967295", "1.2.3-alpha.1-x+00.99999999999999999999", `1.2.3+${"b".repeat(249)}`];
for (const version of goodVersions) check(`version: accept ${version}`, async () => assert.equal((await parse({ ...manifest, version })).version, version));
for (const version of ["1.2", "v1.2.3", "1.02.3", "1.2.3.4", "4294967296.0.0", "1.2.3-4294967296", "1.2.3-01", "1.2.3-", "1.2.3+", "1.2.3-a..b", "1.2.3+a+b", "1.2.3_foo", "1.2.3\n", `1.2.3+${"b".repeat(250)}`]) {
  check(`version: reject ${JSON.stringify(version)}`, () => rejected(() => parse({ ...manifest, version }), /version/i));
}
for (const requirement of ["*", "1.2.3", "^0.2.3", "~1.2.3-alpha+build", "git+x#r", "git+https://example.test/repo#tag", `git+${"x".repeat(2042)}#r`]) {
  check(`requirement: accept ${requirement.length > 70 ? `${requirement.slice(0, 30)} (${requirement.length} bytes)` : requirement}`, async () => assert.equal((await parse({ ...manifest, dependencies: { "@a/b": requirement } })).dependencies["@a/b"], requirement));
}
for (const requirement of ["", "latest", "1.x", ">=1.2.3", "^1.2", "~1.02.3", "1.2.3-4294967296", "git+#r", "git+x#", "git+x", "git+x#r\0", `git+${"x".repeat(2043)}#r`]) {
  check(`requirement: reject ${JSON.stringify(requirement.length > 70 ? `${requirement.slice(0, 30)} (${requirement.length} bytes)` : requirement)}`, () => rejected(() => parse({ ...manifest, dependencies: { "@a/b": requirement } }), /requirement/i));
}
check("dependencies: reject invalid name", () => rejected(() => parse({ ...manifest, dependencies: { bad: "*" } }), /dependency.*name/i));
check("dependencies: 256 accepted, 257 rejected", async () => {
  const dependencies = Object.fromEntries(Array.from({ length: 256 }, (_, i) => [`@a/p${i}`, "*"]));
  assert.equal(Object.keys((await parse({ ...manifest, dependencies })).dependencies).length, 256);
  await rejected(() => parse({ ...manifest, dependencies: { ...dependencies, "@a/extra": "*" } }), /256|dependencies.*limit/i);
});
check("manifest: 1 MiB text boundary", async () => {
  const text = JSON.stringify(manifest);
  assert.equal((await parse(text.padEnd(1_048_576))).name, manifest.name);
  await rejected(() => parse(text.padEnd(1_048_577)), /manifest.*(limit|MiB|large|bytes)/i);
});
check("manifest: disk reader uses the same strict parser", async () => {
  const directory = await fixture({ "main.dew": "x", "dew.json": JSON.stringify({ ...manifest, extra: true }) });
  await rejected(() => contract.readPackageManifest(join(directory, "dew.json")), /unknown.*field/i);
});
check("manifest: disk reader rejects oversized file", async () => {
  const directory = await fixture({ "main.dew": "x", "dew.json": JSON.stringify(manifest).padEnd(1_048_577) });
  await rejected(() => contract.readPackageManifest(join(directory, "dew.json")), /manifest.*(limit|MiB|large|bytes)/i);
});
check("manifest: disk reader rejects symlink", async () => {
  const directory = await fixture({ "main.dew": "x", "real.json": JSON.stringify(manifest) });
  await fs.symlink("real.json", join(directory, "dew.json"));
  await rejected(() => contract.readPackageManifest(join(directory, "dew.json")), /symlink|symbolic/i);
});
check("manifest: missing file keeps read error", async () => {
  await rejected(() => contract.readPackageManifest(join(temporary, "missing.json")), /ENOENT|no such file/i);
});

check("sources: recursive src, tests included, global byte order", async () => {
  const directory = await fixture({ "src/a/z.dew": "z", "src/a.dew": "aa", "src/é.dew": "e", "src/😀.dew": "u", "src/\uE000.dew": "p", "src/unit_test.dew": "t", "root.dew": "ignored", "src/note.txt": "ignored" });
  const files = await contract.collectSourceFiles(directory);
  const expected = ["src/a.dew", "src/a/z.dew", "src/unit_test.dew", "src/é.dew", "src/\uE000.dew", "src/😀.dew"];
  assert.deepEqual(files.map((file) => file.path), expected);
  for (const file of files) {
    assert.equal(file.absolutePath, join(directory, file.path));
    assert.equal(file.size, (await fs.stat(file.absolutePath)).size);
  }
});
check("sources: root fallback is regular files only", async () => {
  const directory = await fixture({ "z.dew": "z", "a_test.dew": "a", "other/nested.dew": "ignored", "folder.dew/nested.dew": "ignored" });
  assert.deepEqual((await contract.collectSourceFiles(directory)).map((file) => file.path), ["a_test.dew", "z.dew"]);
});
check("sources: regular src file uses root fallback", async () => {
  const directory = await fixture({ src: "not a directory", "main.dew": "x" });
  assert.deepEqual((await contract.collectSourceFiles(directory)).map((file) => file.path), ["main.dew"]);
});
check("sources: empty src does not fall back", async () => {
  const directory = await fixture({ "main.dew": "x", "src/note.txt": "x" });
  await rejected(() => contract.collectSourceFiles(directory), /no conventional.*sources/i);
});
for (const kind of ["src", "nested directory", "nested source", "root source", "package root"]) {
  check(`sources: reject symlink ${kind}`, async () => {
    const directory = await fixture({ "main.dew": "x" });
    const outside = await fixture({ "outside.dew": "x" });
    let selected = directory;
    if (kind === "src") await fs.symlink(outside, join(directory, "src"));
    if (kind.startsWith("nested")) {
      await fs.mkdir(join(directory, "src"));
      await fs.writeFile(join(directory, "src/main.dew"), "x");
      await fs.symlink(kind === "nested source" ? join(outside, "outside.dew") : outside, join(directory, "src", kind === "nested source" ? "link.dew" : "link"));
    }
    if (kind === "root source") await fs.symlink(join(outside, "outside.dew"), join(directory, "link.dew"));
    if (kind === "package root") { selected = join(directory, "alias"); await fs.symlink(outside, selected); }
    await rejected(() => contract.collectSourceFiles(selected), /symlink|symbolic/i);
  });
}
check("sources: unreadable src error stays visible", async () => {
  const directory = await fixture({ "main.dew": "fallback", "src/main.dew": "x" });
  await fs.chmod(join(directory, "src"), 0);
  try { await rejected(() => contract.collectSourceFiles(directory), /EACCES|permission denied/i); }
  finally { await fs.chmod(join(directory, "src"), 0o700); }
});
check("sources: 16 MiB bound before content read", async () => {
  const directory = await fixture();
  await fs.truncate(join(directory, "main.dew"), 16 * 1_048_576);
  assert.equal((await contract.collectSourceFiles(directory))[0].size, 16 * 1_048_576);
  await fs.truncate(join(directory, "main.dew"), 16 * 1_048_576 + 1);
  await rejected(() => contract.collectSourceFiles(directory), /source.*(16|limit|large)/i);
});

// An independent v1 decoder checks field order, lengths, paths, and checksum.
function decode(bytes) {
  assert.equal(bytes.subarray(0, 8).toString("binary"), "DEWPKG1\0");
  const end = bytes.length - 32;
  assert.deepEqual(bytes.subarray(end), createHash("sha256").update(bytes.subarray(0, end)).digest());
  let offset = 8;
  const u32 = () => { const value = bytes.readUInt32LE(offset); offset += 4; return value; };
  const field = () => { const length = u32(); const value = bytes.subarray(offset, offset + length); offset += length; return value; };
  const text = () => field().toString("utf8");
  const result = { name: text(), version: text(), source: text(), integrity: text(), interfaceFingerprint: text(), dependencies: [], files: [] };
  const dependencies = u32();
  for (let index = 0; index < dependencies; index++) result.dependencies.push([text(), text()]);
  const files = u32();
  for (let index = 0; index < files; index++) result.files.push({ path: text(), contents: field() });
  assert.equal(offset, end);
  return result;
}
check("capsule: v1 bytes and canonical order from supplied buffers", async () => {
  const value = input({ manifest: { ...manifest, dependencies: { "@z/p": "^1.2.3", "@a/p": "*" } }, files: [{ path: "z_test.dew", contents: Buffer.from([0, 255]) }, { path: "a.dew", contents: Buffer.from("a") }] });
  const encoded = await contract.encodeCapsule(value);
  const decoded = decode(encoded);
  assert.equal(decoded.name, manifest.name);
  assert.equal(decoded.version, manifest.version);
  assert.equal(decoded.source, value.source);
  assert.equal(decoded.integrity, integrity);
  assert.equal(decoded.interfaceFingerprint, fingerprint);
  assert.deepEqual(decoded.dependencies, [["@a/p", "*"], ["@z/p", "^1.2.3"]]);
  assert.deepEqual(decoded.files, value.files.toSorted((a, b) => Buffer.compare(Buffer.from(a.path), Buffer.from(b.path))));
  assert.deepEqual(encoded, await contract.encodeCapsule({ ...value, files: value.files.toReversed() }));
});
check("capsule: omitted dependencies", async () => {
  assert.deepEqual(decode(await contract.encodeCapsule(input({ manifest: { name: manifest.name, version: manifest.version } }))).dependencies, []);
});
for (const path of ["/x.dew", "C:/x.dew", "a\\b.dew", "a\0.dew", "a//b.dew", "./x.dew", "a/../b.dew", "a/./b.dew", "x.dew/", "README", "dew.json/x.dew", `${"x".repeat(4093)}.dew`]) {
  check(`capsule path: reject ${JSON.stringify(path.length > 80 ? `${path.slice(0, 30)} (${path.length} bytes)` : path)}`, () => rejected(() => contract.encodeCapsule(input({ files: [{ path, contents: Buffer.alloc(0) }] })), /path/i));
}
check("capsule path: 4096 byte boundary", async () => {
  const path = `${"x".repeat(4092)}.dew`;
  assert.equal(decode(await contract.encodeCapsule(input({ files: [{ path, contents: Buffer.alloc(0) }] }))).files[0].path, path);
});
for (const paths of [["a.dew", "a.dew"], ["a.dew", "a.dew-other.dew", "a.dew/b.dew"]]) {
  check(`capsule path: reject ${paths.length === 2 ? "duplicate" : "prefix conflict"}`, () => rejected(() => contract.encodeCapsule(input({ files: paths.map((path) => ({ path, contents: Buffer.alloc(0) })) })), /duplicate|conflict/i));
}
check("capsule: reject empty files", () => rejected(() => contract.encodeCapsule(input({ files: [] })), /files|sources/i));
check("capsule: reject 65537 files before encoding", () => rejected(() => contract.encodeCapsule(input({ files: Array.from({ length: 65537 }, (_, i) => ({ path: `p${i}.dew`, contents: Buffer.alloc(0) })) })), /65536|file.*limit/i));
check("capsule: 16 MiB per source limit", async () => {
  await rejected(() => contract.encodeCapsule(input({ files: [{ path: "main.dew", contents: Buffer.alloc(16 * 1_048_576 + 1) }] })), /source.*(16|limit|large)/i);
});
check("capsule: preflight 64 MiB before output allocation", async () => {
  const contents = Buffer.alloc(16 * 1_048_576);
  const value = input({ files: [0, 1, 2, 3].map((i) => ({ path: `p${i}.dew`, contents })) });
  const concat = Buffer.concat;
  const alloc = Buffer.alloc;
  const allocUnsafe = Buffer.allocUnsafe;
  const guard = (size) => { if (size > 64 * 1_048_576) throw new Error("TEST: oversized allocation before capsule limit check"); };
  Buffer.concat = (list, size) => { guard(size ?? list.reduce((sum, part) => sum + part.length, 0)); return concat(list, size); };
  Buffer.alloc = (size, ...args) => { guard(size); return alloc(size, ...args); };
  Buffer.allocUnsafe = (size) => { guard(size); return allocUnsafe(size); };
  try { await rejected(() => contract.encodeCapsule(value), /capsule.*64 MiB/i); }
  finally { Buffer.concat = concat; Buffer.alloc = alloc; Buffer.allocUnsafe = allocUnsafe; }
});
for (const source of ["", "x".repeat(2049)]) check(`capsule: reject source length ${source.length}`, () => rejected(() => contract.encodeCapsule(input({ source })), /source/i));
check("capsule: invalid provenance", () => rejected(() => contract.encodeCapsule(input({ interfaceFingerprint: "invalid" })), /provenance|fingerprint/i));
check("capsule: inherited manifest fields cannot supply values", () => rejected(() => contract.encodeCapsule(input({ manifest: Object.create(manifest) })), /manifest|package name|plain object/i));
check("capsule: unknown object key", () => rejected(() => contract.encodeCapsule(input({ manifest: { ...manifest, extra: "x" } })), /unknown.*field/i));

let failed = 0;
try {
  for (const { name, run } of checks) {
    try { await run(); console.log(`ok ${name}`); }
    catch (error) { failed++; console.error(`not ok ${name}: ${error.message}`); }
  }
  console.log(`checks=${checks.length} passed=${checks.length - failed} failed=${failed} mode=${baseline ? "baseline" : "module"}`);
} finally { await fs.rm(temporary, { recursive: true, force: true }); }
process.exitCode = failed ? 1 : 0;
