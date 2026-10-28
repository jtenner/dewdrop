#!/usr/bin/env node
// Narrow CLI checks. All compiler children and HTTP calls are mocks.
import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { existsSync } from "node:fs";
import { mkdir, mkdtemp, readFile, readdir, rm, symlink, truncate, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const registry = process.env.DEW_TEST_REGISTRY_MODULE ?? join(here, "dew-registry.mjs");
const hex = "a".repeat(64);
const digest = bytes => createHash("sha256").update(bytes).digest("hex");
const moduleName = name => name.slice(1).replaceAll("/", ".").replaceAll("-", "_");

async function sources(root) {
  const out = [];
  async function walk(dir) {
    for (const entry of await readdir(dir, { withFileTypes: true })) {
      if (entry.isDirectory()) await walk(join(dir, entry.name));
      else if (entry.isFile() && entry.name.endsWith(".dew")) out.push(join(dir, entry.name));
    }
  }
  const { stat } = await import("node:fs/promises");
  if (await stat(join(root, "src")).then(s => s.isDirectory(), () => false)) await walk(join(root, "src"));
  else for (const entry of await readdir(root, { withFileTypes: true })) {
    if (entry.isFile() && entry.name.endsWith(".dew")) out.push(join(root, entry.name));
  }
  out.sort((a, b) => Buffer.compare(Buffer.from(a), Buffer.from(b)));
  return Promise.all(out.map(async path => ({ path: path.slice(root.length + 1), contents: await readFile(path) })));
}

function integrity(manifest, files) {
  const hash = createHash("sha256").update("DEW_PACKAGE_INTEGRITY_V1\0");
  function field(bytes) {
    bytes = Buffer.from(bytes);
    const size = Buffer.alloc(4); size.writeUInt32LE(bytes.length);
    hash.update(size).update(bytes);
  }
  for (const text of [manifest.name, manifest.version, moduleName(manifest.name)]) field(text);
  for (const file of files) { field(file.path); field(file.contents); }
  for (const [name, request] of Object.entries(manifest.dependencies ?? {}).sort()) { field(name); field(request); }
  return `sha256-${hash.digest("hex")}`;
}

function decode(bytes) {
  assert.equal(bytes.subarray(0, 8).toString(), "DEWPKG1\0");
  assert.equal(digest(bytes.subarray(0, -32)), bytes.subarray(-32).toString("hex"));
  let at = 8;
  function u32() { const n = bytes.readUInt32LE(at); at += 4; return n; }
  function field() { const n = u32(); const value = bytes.subarray(at, at + n); at += n; return value; }
  const [name, version, source, sourceIntegrity, interfaceFingerprint] = Array.from({ length: 5 }, () => field().toString());
  const dependencies = {};
  for (let n = u32(); n > 0; n--) dependencies[field().toString()] = field().toString();
  const files = [];
  for (let n = u32(); n > 0; n--) files.push({ path: field().toString(), contents: field() });
  assert.equal(at, bytes.length - 32);
  return { name, version, source, integrity: sourceIntegrity, interfaceFingerprint, dependencies, files };
}

async function driver(specPath) {
  const spec = JSON.parse(await readFile(specPath, "utf8"));
  // Optional external fixture while the separate contract branch is pending.
  // Never silently replace or skip the real contract.
  if (process.env.DEW_TEST_CONTRACT_MODULE) {
    Bun.plugin({ name: "explicit-test-contract", setup(builder) {
      builder.onResolve({ filter: /dew-package-contract\.mjs$/ }, () => ({ path: resolve(process.env.DEW_TEST_CONTRACT_MODULE) }));
    } });
  }
  let built;
  let builtGraph;
  let builtManifest;
  const mutations = async stage => {
    if (spec.mutate === stage) {
      if (spec.mutateRoot !== false) await writeFile(spec.liveSource, `// changed at ${stage}\n`);
      if (spec.dependencySource) await writeFile(spec.dependencySource, "// changed dependency\n");
      if (spec.lock) await writeFile(spec.lock, '{"lockfileVersion":1,"packages":[]}');
      if (spec.mutateManifest) await writeFile(spec.manifest, JSON.stringify({ name: "@test/pack", version: "2.0.0" }));
    }
  };
  Bun.spawn = (argv, options) => {
    const work = (async () => {
      if (argv[1] === "build") {
        builtManifest = argv[argv.indexOf("--manifest") + 1];
        const root = dirname(builtManifest);
        const manifest = JSON.parse(await readFile(builtManifest, "utf8"));
        built = await sources(root);
        builtGraph = [];
        if (Object.keys(manifest.dependencies ?? {}).length) {
          const lock = JSON.parse(await readFile(join(root, "dew.lock"), "utf8"));
          for (const entry of lock.packages) {
            const dep = resolve(root, entry.path);
            if (root !== dirname(spec.manifest)) assert.ok(dep.startsWith(root + "/"), "lock path escapes snapshot");
            const depManifest = dep.endsWith("dew.json") ? dep : join(dep, "dew.json");
            builtGraph.push({ name: entry.name, files: await sources(dirname(depManifest)) });
          }
        }
        await writeFile(spec.trace, JSON.stringify({ manifest: builtManifest, graph: builtGraph, env: { cache: options.env.DEW_CACHE_DIR }, argv }));
        await mutations("build");
        if (spec.buildFailure) return { status: 7, output: "", stderr: "mock compiler failed: fixture build error\n" };
        if (spec.removeOutputParent) await rm(spec.removeOutputParent, { recursive: true });
        await writeFile(argv[argv.indexOf("-o") + 1], "mock wasm");
        return { status: 0, output: "" };
      }
      if (argv[1] === "package-integrity") {
        const manifest = JSON.parse(await readFile(argv[2], "utf8"));
        const files = await sources(dirname(argv[2]));
        assert.deepEqual(files, built, "integrity sources differ from build inputs");
        if (builtGraph.length) {
          const lock = JSON.parse(await readFile(join(dirname(argv[2]), "dew.lock"), "utf8"));
          const current = [];
          for (const entry of lock.packages) {
            const path = resolve(dirname(argv[2]), entry.path);
            current.push({ name: entry.name, files: await sources(path.endsWith("dew.json") ? dirname(path) : path) });
          }
          assert.deepEqual(current, builtGraph, "dependency graph differs from build inputs");
        }
        const text = integrity(manifest, files);
        await mutations("integrity");
        return { status: 0, output: text };
      }
      if (argv[1]?.endsWith("dew-abi.mjs")) return { status: 0, output: JSON.stringify({ schema: 1, versions: { core: 1 }, path: moduleName(JSON.parse(await readFile(builtManifest, "utf8")).name), interfaceFingerprint: hex, dependencies: [] }) };
      throw new Error(`unexpected child: ${JSON.stringify(argv)}`);
    })();
    return {
      stdout: new ReadableStream({ async start(controller) { try { const value = await work; controller.enqueue(Buffer.from(value.output)); controller.close(); } catch (error) { controller.error(error); } } }),
      exited: work.then(value => { if (value.stderr) process.stderr.write(value.stderr); return value.status; }),
    };
  };
  globalThis.fetch = async (url, options) => {
    assert.ok(spec.command === "publish" && !spec.args.includes("--dry-run"), "local preparation must not use network");
    assert.equal(url, "http://127.0.0.1:1/api/cli/packages");
    const capsule = decode(Buffer.from(options.body));
    assert.deepEqual(capsule.files, built, "capsule sources differ from build inputs");
    assert.equal(capsule.integrity, integrity(capsule, built));
    if (spec.dependencySource) {
      assert.equal(builtGraph.length, 1);
      assert.equal(builtGraph[0].files[0].contents.toString(), "// dependency before\n");
    }
    await writeFile(spec.upload, Buffer.from(options.body));
    return new Response(JSON.stringify({ name: capsule.name, version: capsule.version, url: "/fixture" }));
  };
  if (spec.cleanupFailure) {
    const { preparePackage } = await import(join(here, "dew-package-snapshot.mjs"));
    try {
      await preparePackage({ manifestPath: spec.manifest, repositoryRoot: resolve(here, ".."), source: "registry:http://127.0.0.1:1", run: async (argv, options) => {
        const child = Bun.spawn(argv, options);
        const output = await new Response(child.stdout).text();
        const status = await child.exited;
        if (status) throw new Error(`mock child failed (exit ${status})`);
        return output;
      } }, { remove: async (path, options) => { await rm(path, options); throw new Error("mock cleanup failure"); } });
    } catch (error) { console.error(error.message); process.exitCode = 1; }
    return;
  }
  process.argv = [process.execPath, registry, spec.command, ...spec.args];
  await import(registry);
}

if (process.argv[2] === "--driver") {
  await driver(process.argv[3]);
} else {
  const { test } = await import("node:test");
  async function fixture(t, options = {}) {
    const root = await mkdtemp(join(tmpdir(), "dew-pack-check-"));
    t.after(() => rm(root, { recursive: true, force: true }));
    const pkg = join(root, "package");
    await mkdir(pkg);
    const manifest = join(pkg, options.alternate ? "alternate.json" : "dew.json");
    const manifestValue = { name: "@test/pack", version: "1.0.0", dependencies: {} };
    const liveSource = join(pkg, options.src ? "src/main.dew" : "main.dew");
    if (options.src) await mkdir(dirname(liveSource));
    await writeFile(liveSource, "// root before\n");
    const spec = { root, manifest, liveSource, trace: join(root, "trace.json"), upload: join(root, "upload.dpa"), command: "publish", args: [], ...options };
    if (options.dependency) {
      const dep = join(pkg, ".dew/packages/dep");
      await mkdir(dep, { recursive: true });
      await writeFile(join(dep, "dew.json"), JSON.stringify({ name: "@test/dep", version: "1.0.0" }));
      spec.dependencySource = join(dep, "dep.dew");
      await writeFile(spec.dependencySource, "// dependency before\n");
      manifestValue.dependencies["@test/dep"] = "1.0.0";
      spec.lock = join(pkg, "dew.lock");
      await writeFile(spec.lock, JSON.stringify({ lockfileVersion: 1, packages: [{ name: "@test/dep", version: "1.0.0", source: "registry:http://127.0.0.1:1", path: ".dew/packages/dep", integrity: integrity({ name: "@test/dep", version: "1.0.0" }, await sources(dep)), interface: hex }] }));
    }
    await writeFile(manifest, JSON.stringify(manifestValue));
    const config = join(root, "config");
    await mkdir(config);
    await writeFile(join(config, "credentials.json"), JSON.stringify({ version: 1, registries: { "http://127.0.0.1:1": { token: "fixture-token" } } }));
    const scratch = join(root, "tmp"); await mkdir(scratch);
    async function run(command = spec.command, args = []) {
      spec.command = command;
      spec.args = [...(spec.defaultManifest ? [] : ["--manifest", manifest]), "--registry", "http://127.0.0.1:1", ...args];
      const path = join(root, "spec.json"); await writeFile(path, JSON.stringify(spec));
      return spawnSync("bun", [fileURLToPath(import.meta.url), "--driver", path], { cwd: pkg, env: { ...process.env, TMPDIR: scratch, DEW_CONFIG_HOME: config, DEW_PACKAGE_ROOTS: "" }, encoding: "utf8", timeout: 15_000 });
    }
    return { ...spec, pkg, config, scratch, spec, run };
  }
  function success(result) { assert.ifError(result.error); assert.equal(result.status, 0, `stdout:\n${result.stdout}\nstderr:\n${result.stderr}`); }
  function rejected(result, pattern) { assert.ifError(result.error); assert.notEqual(result.status, 0, result.stdout); assert.match(result.stderr, pattern); }

  test("publish keeps capsule sources fixed after build", async t => {
    const f = await fixture(t, { mutate: "build" }); success(await f.run());
  });
  test("publish keeps capsule sources fixed after integrity", async t => {
    const f = await fixture(t, { mutate: "integrity" }); success(await f.run());
  });
  test("snapshot fixes dependency graph and rewrites lock paths", async t => {
    const f = await fixture(t, { dependency: true, mutate: "build", mutateRoot: false, alternate: true });
    success(await f.run());
    const trace = JSON.parse(await readFile(f.trace, "utf8"));
    assert.notEqual(trace.manifest, f.manifest);
    assert.ok(trace.env.cache.startsWith(f.scratch + "/"));
    assert.equal(await readdir(f.scratch).then(x => x.length), 0, "snapshot is removed");
  });
  test("compiler failure keeps stderr and removes private files", async t => {
    const f = await fixture(t, { buildFailure: true });
    rejected(await f.run(), /mock compiler failed: fixture build error/);
    assert.deepEqual(await readdir(f.scratch), [], "build failure leaked a temporary directory");
  });
  test("src regular file uses root sources", async t => {
    const f = await fixture(t); await writeFile(join(f.pkg, "src"), "regular file"); success(await f.run());
  });
  test("manifest changes after build cannot change capsule identity", async t => {
    const f = await fixture(t, { mutate: "build", mutateRoot: false, mutateManifest: true });
    success(await f.run()); assert.equal(decode(await readFile(f.upload)).version, "1.0.0");
  });
  test("default manifest with absent dependencies is accepted", async t => {
    const f = await fixture(t, { defaultManifest: true });
    await writeFile(f.manifest, JSON.stringify({ name: "@test/pack", version: "1.0.0" }));
    success(await f.run()); assert.deepEqual(decode(await readFile(f.upload)).dependencies, {});
  });
  test("snapshot rejects invalid UTF-8 manifest bytes before build", async t => {
    const f = await fixture(t);
    await writeFile(f.manifest, Buffer.concat([Buffer.from('{"name":"@test/pack","version":"1.0.0","dependencies":{"@test/dep":"git+https://example.invalid/repo#'), Buffer.from([255]), Buffer.from('"}}')]));
    rejected(await f.run(), /UTF-8/); assert.ok(!existsSync(f.trace));
  });
  test("pack retains capsule and local INPUTS without credentials or network", async t => {
    const f = await fixture(t, { command: "pack", alternate: true, src: true, mutate: "build", dependency: true });
    await writeFile(join(f.pkg, "ignored.dew"), "// ignored root\n");
    await writeFile(join(f.pkg, "src/main_test.dew"), "// include tests in integrity\n");
    await writeFile(join(f.config, "credentials.json"), "invalid credential file: must not be read");
    const output = join(f.root, "packed"); success(await f.run("pack", ["--output", output]));
    const capsule = decode(await readFile(join(output, "package.dpa")));
    assert.deepEqual(capsule.files.map(f => f.path), ["src/main.dew", "src/main_test.dew"]);
    assert.equal(capsule.files[0].contents.toString(), "// root before\n");
    const inputs = JSON.parse(await readFile(join(output, "INPUTS.json"), "utf8"));
    assert.equal(inputs.kind, "dew-local-package-inputs"); assert.equal(inputs.schemaVersion, 1);
    assert.equal(inputs.sourceIntegrity, capsule.integrity);
    assert.equal(inputs.interfaceFingerprint, hex);
    assert.equal(inputs.capsule.sha256, digest(await readFile(join(output, "package.dpa"))));
    assert.equal(inputs.dependencies.length, 1);
    assert.equal(inputs.release, null, "Phase 4 release fields must remain absent");
    assert.match(f.spec.command, /pack/);
    assert.ok(!existsSync(f.upload)); assert.deepEqual(await readdir(f.scratch), []);
  });
  test("pack output collision preserves all existing inputs", async t => {
    const f = await fixture(t); const output = join(f.root, "packed"); await mkdir(output);
    await writeFile(join(output, "INPUTS.json"), "keep me");
    rejected(await f.run("pack", ["--output", output]), /exist|collision/i);
    assert.equal(await readFile(join(output, "INPUTS.json"), "utf8"), "keep me");
    assert.equal(await readFile(f.liveSource, "utf8"), "// root before\n");
  });
  test("pack failure does not create an output set", async t => {
    const f = await fixture(t, { buildFailure: true }); const output = join(f.root, "packed");
    rejected(await f.run("pack", ["--output", output]), /mock compiler failed/);
    assert.ok(!existsSync(output)); assert.deepEqual(await readdir(f.scratch), []);
  });
  test("output parent loss reports a write failure without changing input", async t => {
    const f = await fixture(t); const parent = join(f.root, "output-parent"); await mkdir(parent);
    f.spec.removeOutputParent = parent;
    rejected(await f.run("pack", ["--output", join(parent, "packed")]), /ENOENT/);
    assert.equal(await readFile(f.liveSource, "utf8"), "// root before\n");
    assert.deepEqual(await readdir(f.scratch), []);
  });
  for (const buildFailure of [false, true]) test(`cleanup failure remains visible (build failure: ${buildFailure})`, async t => {
    const f = await fixture(t, { cleanupFailure: true, buildFailure });
    const result = await f.run(); rejected(result, /could not remove private package snapshot.*mock cleanup failure/);
    if (buildFailure) assert.match(result.stderr, /mock child failed \(exit 7\)/);
    assert.deepEqual(await readdir(f.scratch), []); assert.ok(!existsSync(f.upload));
  });
  test("publish dry-run uses local preparation with no auth or upload", async t => {
    const f = await fixture(t); await writeFile(join(f.config, "credentials.json"), "must not be read");
    const output = join(f.root, "dry"); success(await f.run("publish", ["--dry-run", "--output", output]));
    assert.ok(existsSync(join(output, "INPUTS.json"))); assert.ok(!existsSync(f.upload));
  });
  for (const [label, args] of [
    ["unknown", ["--typo"]], ["duplicate", ["--registry", "http://127.0.0.1:1"]],
    ["missing", ["--output"]], ["positional", ["extra"]], ["output without dry-run", ["--output", "unused"]],
  ]) test(`publish rejects ${label} options`, async t => {
    const f = await fixture(t);
    const result = await f.run("publish", args); rejected(result, /unknown|duplicate|requires|unexpected|dry-run/i); assert.equal(result.status, 2);
  });
  test("pack help is local and strict", async t => {
    const f = await fixture(t); const result = await f.run("pack", ["--help"]); success(result);
    assert.match(result.stdout, /--manifest/); assert.match(result.stdout, /--output/);
    rejected(await f.run("pack", ["--help", "--typo"]), /unknown/i);
  });
  test("reject source files above 16 MiB before build", async t => {
    const f = await fixture(t); await truncate(f.liveSource, 16 * 1024 * 1024 + 1);
    rejected(await f.run(), /16 MiB|source.*(?:limit|bound|large)/i); assert.ok(!existsSync(f.trace));
  });
  test("64 MiB publish cap is checked before build", async t => {
    const f = await fixture(t);
    for (let index = 0; index < 4; index++) {
      const path = index ? join(f.pkg, `file${index}.dew`) : f.liveSource;
      await writeFile(path, ""); await truncate(path, 16 * 1024 * 1024);
    }
    rejected(await f.run(), /64 MiB.*(?:publish|upload)|64 MiB.*limit/);
    assert.ok(!existsSync(f.trace), "over-limit package reached the build");
  });
  for (const kind of ["escape", "identity", "integrity", "cycle", "missing"]) test(`snapshot rejects ${kind} graph inputs`, async t => {
    const f = await fixture(t, { dependency: true });
    const lock = JSON.parse(await readFile(f.lock, "utf8"));
    if (kind === "escape") lock.packages[0].path = "../outside";
    if (kind === "identity") lock.packages[0].version = "2.0.0";
    if (kind === "integrity") lock.packages[0].integrity = `sha256-${"0".repeat(64)}`;
    if (kind === "missing") lock.packages = [];
    if (kind === "cycle") {
      const manifest = { name: "@test/dep", version: "1.0.0", dependencies: { "@test/pack": "1.0.0" } };
      await writeFile(join(dirname(f.dependencySource), "dew.json"), JSON.stringify(manifest));
      lock.packages[0].integrity = integrity(manifest, await sources(dirname(f.dependencySource)));
    }
    await writeFile(f.lock, JSON.stringify(lock));
    const reasons = {
      escape: /unsafe locked package path: \.\.\/outside/,
      identity: /identity mismatch/,
      integrity: /integrity mismatch/,
      cycle: /dependency cycle/,
      missing: /missing from dew.lock/,
    };
    rejected(await f.run(), reasons[kind]);
    assert.ok(!existsSync(f.trace)); assert.deepEqual(await readdir(f.scratch), []);
  });
  test("snapshot captures a shared diamond once", async t => {
    const f = await fixture(t); const entries = [];
    await writeFile(f.manifest, JSON.stringify({ name: "@test/pack", version: "1.0.0", dependencies: { "@test/a": "*", "@test/b": "*" } }));
    for (const name of ["a", "b", "c"]) {
      const root = join(f.pkg, ".deps", name); await mkdir(root, { recursive: true });
      const manifest = { name: `@test/${name}`, version: "1.0.0", dependencies: name === "c" ? {} : { "@test/c": "*" } };
      await writeFile(join(root, "dew.json"), JSON.stringify(manifest)); await writeFile(join(root, "main.dew"), `// ${name}\n`);
      entries.push({ name: manifest.name, version: manifest.version, source: "registry:http://127.0.0.1:1", path: `.deps/${name}`, integrity: integrity(manifest, await sources(root)), interface: hex });
    }
    await writeFile(join(f.pkg, "dew.lock"), JSON.stringify({ lockfileVersion: 1, packages: entries }));
    const output = join(f.root, "diamond"); success(await f.run("pack", ["--output", output]));
    const inputs = JSON.parse(await readFile(join(output, "INPUTS.json"), "utf8"));
    assert.deepEqual(inputs.dependencies.map(p => p.name), ["@test/a", "@test/b", "@test/c"]);
    assert.equal(new Set(inputs.lock.packages.map(p => p.path)).size, 3);
    assert.ok(inputs.lock.packages.every(p => !p.path.includes("..") && !p.path.startsWith("/")));
  });
  for (const kind of ["source", "directory", "manifest", "dependency"]) test(`reject ${kind} symlinks`, async t => {
      const f = await fixture(t, { src: true, dependency: kind === "dependency" });
      if (kind === "source") await symlink(f.liveSource, join(f.pkg, "src/alias.dew"));
      if (kind === "directory") await symlink(join(f.pkg, "src"), join(f.pkg, "src/alias"));
      if (kind === "manifest") { await writeFile(join(f.root, "real.json"), await readFile(f.manifest)); await rm(f.manifest); await symlink(join(f.root, "real.json"), f.manifest); }
      if (kind === "dependency") { const dep = dirname(f.dependencySource); await rm(f.dependencySource); await symlink(f.liveSource, f.dependencySource); assert.ok(existsSync(dep)); }
      rejected(await f.run(), /symlink|symbolic|unsafe/i); assert.ok(!existsSync(f.trace));
  });
  test("shell routes pack to the script without a native build", async t => {
    const f = await fixture(t); const bin = join(f.root, "bin"); await mkdir(bin);
    await writeFile(join(bin, "bun"), '#!/bin/sh\nprintf "bun:%s\\n" "$*"\n', { mode: 0o755 });
    await writeFile(join(bin, "moon"), '#!/bin/sh\necho "unexpected native pack route" >&2\nexit 91\n', { mode: 0o755 });
    const result = spawnSync("bash", [join(here, "dew"), "pack", "--help"], { encoding: "utf8", env: { ...process.env, PATH: `${bin}:${process.env.PATH}` } });
    success(result); assert.match(result.stdout, /bun:.*dew-registry.mjs pack --help/);
  });
}
