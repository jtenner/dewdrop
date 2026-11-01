import fs from 'node:fs';
import { decodeDewTestMetadata } from '../tools/dew-test/metadata.mjs';
const module = await WebAssembly.compile(fs.readFileSync('.tmp/focused.wasm'));
const tests = decodeDewTestMetadata(WebAssembly.Module.customSections(module, 'dew.tests')[0]);
const instance = await WebAssembly.instantiate(module, {
  'dewdrop.transform.workers': {capacity: () => 0},
  wasi_snapshot_preview1: {fd_write: () => {throw Error('unexpected test failure write');}},
});
instance.exports.__dew_init?.();
for (const test of tests.filter(t => t.name.includes('scaling'))) {
  const run = instance.exports[test.export];
  for (let n = 0; n < 10; n++) run();
  global.gc();
  const before = process.memoryUsage();
  const start = performance.now();
  for (let n = 0; n < 200; n++) run();
  const elapsed = performance.now() - start;
  global.gc();
  console.log(JSON.stringify({test: test.name, runs: 200, elapsed_ms: elapsed,
    per_call_ms: elapsed / 200, before, after: process.memoryUsage()}));
}
const production = await WebAssembly.compile(fs.readFileSync('.tmp/consumer.wasm'));
if (WebAssembly.Module.customSections(production, 'dew.tests').length) throw Error('production test metadata');
const consumer = await WebAssembly.instantiate(production, {});
consumer.exports.__dew_init?.();
if (consumer.exports.main() !== 0) throw Error('production consumer result');
console.log('production consumer: no test metadata; main returned 0');
