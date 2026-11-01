import { readFileSync } from 'node:fs';
import { performance } from 'node:perf_hooks';
import { decodeDewTestMetadata } from './dew-test/metadata.mjs';
const module = new WebAssembly.Module(readFileSync(process.argv[2]));
const tests = decodeDewTestMetadata(Buffer.from(WebAssembly.Module.customSections(module, 'dew.tests')[0]));
const test = tests.find(x => x.name === 'Node hex reference 63');
if (!test) throw new Error('missing 4096-byte reference case');
const instance = new WebAssembly.Instance(module, {
  'dewdrop.transform.workers': { capacity: () => 0 },
  wasi_snapshot_preview1: { fd_write: () => { throw new Error('benchmark assertion failed'); } },
});
instance.exports.__dew_init?.();
const run = instance.exports[test.export];
for (let i = 0; i < 100; i++) run();
global.gc();
const before = process.memoryUsage();
const start = performance.now();
for (let i = 0; i < 1000; i++) run();
const elapsed = performance.now() - start;
global.gc();
const after = process.memoryUsage();
console.log(JSON.stringify({ iterations: 1000, inputBytes: 4096, elapsedMs: elapsed,
  mibInputPerSecond: 4096 * 1000 / 1048576 / (elapsed / 1000), before, after,
  note: 'Encode + decode + two equality checks per iteration; Node process memory includes VM and GC. No exact Wasm GC heap size is exposed.' }, null, 2));
