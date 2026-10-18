#!/usr/bin/env node
// Compare the old scan and the production checked lookup in one test binary.
import { readFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { performance } from "node:perf_hooks";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { getHeapStatistics } from "node:v8";
import { arch, cpus, platform, release } from "node:os";
import { decodeDewTestMetadata } from "./dew-test/metadata.mjs";
import { readSelfHostInvariantFailure, formatSelfHostInvariantFailure } from "./self-host-invariant-record.mjs";

const args = process.argv.slice(2);
const worker = args[0] === "--worker";
if (worker) args.shift();
const [path, count = "7", mode, size, family = "function"] = args;
const runs = Number(count);
if (!path || !Number.isInteger(runs) || runs < 1 || runs > 30) {
  throw new Error("usage: node tools/benchmark-self-host-index-lookups.mjs TESTS.wasm [RUNS=7] [function|metadata|field_layout]");
}
const bytes = readFileSync(path);
if (worker) {
  const module = await WebAssembly.compile(bytes);
  const sections = WebAssembly.Module.customSections(module, "dew.tests");
  if (sections.length !== 1) throw new Error("missing test metadata");
  const name = family === "function" ? `index lookup benchmark ${mode} ${size}` :
    `index lookup metadata benchmark ${family} ${mode} ${size}`;
  const test = decodeDewTestMetadata(Buffer.from(sections[0])).find(test => test.name === name);
  if (!test || test.expectedTrap !== null) throw new Error(`missing ordinary test: ${name}`);
  let instance;
  const imports = { wasi_snapshot_preview1: {
    fd_write(fd, iovs, count, written) {
      const memory = instance.exports.memory;
      const view = new DataView(memory.buffer);
      let total = 0;
      for (let i = 0; i < count; i++) {
        const start = view.getUint32(iovs + i * 8, true);
        const length = view.getUint32(iovs + i * 8 + 4, true);
        process.stderr.write(Buffer.from(memory.buffer, start, length));
        total += length;
      }
      view.setUint32(written, total, true);
      return 0;
    },
  } };
  for (const entry of WebAssembly.Module.imports(module)) {
    if (entry.kind !== "function") throw new Error(`unsupported host import: ${entry.module}.${entry.name}`);
    imports[entry.module] ??= Object.create(null);
    imports[entry.module][entry.name] ??= () => {
      throw new Error(`unexpected host call: ${entry.module}.${entry.name}`);
    };
  }
  instance = await WebAssembly.instantiate(module, imports);
  instance.exports.__dew_init?.();
  const run = instance.exports[test.export];
  for (let i = 0; i < 3; i++) run();
  const samples = [];
  for (let i = 0; i < runs; i++) {
    global.gc();
    const before = getHeapStatistics().used_heap_size;
    const start = performance.now();
    try { run(); } catch (error) {
      const failure = readSelfHostInvariantFailure(instance.exports.memory);
      if (failure) throw new Error(formatSelfHostInvariantFailure(failure), { cause: error });
      throw error;
    }
    const milliseconds = performance.now() - start;
    const after = getHeapStatistics().used_heap_size;
    global.gc();
    samples.push({ milliseconds, heap_before_bytes: before, heap_after_bytes: after,
      heap_after_gc_bytes: getHeapStatistics().used_heap_size, rss_bytes: process.memoryUsage().rss });
  }
  const sorted = samples.map(sample => sample.milliseconds).sort((a, b) => a - b);
  console.log(JSON.stringify({ family, mode, size: Number(size), samples,
    median_milliseconds: sorted[Math.floor(sorted.length / 2)],
    peak_rss_kib: process.resourceUsage().maxRSS }));
} else {
  const cases = [];
  const suite = mode ?? "function";
  if (!["function", "metadata", "field_layout"].includes(suite)) throw new Error(`unknown suite: ${suite}`);
  const families = suite === "metadata" ? ["field", "callable"] : [suite];
  for (const family of families) {
    for (const size of family === "function" ? [128, 512, 2048] : [64, 256]) {
      for (const mode of ["scan", "direct"]) {
        const result = spawnSync(process.execPath, ["--expose-gc", "--no-liftoff", fileURLToPath(import.meta.url),
          "--worker", path, String(runs), mode, String(size), family], { encoding: "utf8", timeout: 30_000 });
        if (result.status !== 0) throw new Error(`${family} ${mode} ${size} failed: ${result.stderr}`, { cause: result.error });
        cases.push(JSON.parse(result.stdout));
      }
    }
  }
  console.log(JSON.stringify({ wasm_sha256: createHash("sha256").update(bytes).digest("hex"),
    harness_sha256: createHash("sha256").update(readFileSync(fileURLToPath(import.meta.url))).digest("hex"),
    wasm_bytes: bytes.length, node: process.version, v8: process.versions.v8,
    worker_node_flags: ["--expose-gc", "--no-liftoff"],
    environment: { platform: platform(), release: release(), arch: arch(), cpu: cpus()[0].model },
    runs, suite, warmup_runs_per_case: 3, queries_per_sample: 8192,
    field_queries_per_iteration: suite === "function" ? 0 : 2,
    fixture_construction_included: suite === "function",
    memory_limits: "V8 heap sizes and process RSS include runtime overhead. Heap deltas are not allocation totals; collection can occur during a sample.",
    cases }, null, 2));
}
