import { readFileSync } from 'node:fs';
import { performance } from 'node:perf_hooks';
import assert from 'node:assert/strict';
const { instance } = await WebAssembly.instantiate(readFileSync('.tmp/trim-consumer.wasm'), {});
const e = instance.exports;
e.__dew_init?.();
assert.equal(e.convenience(), 5);
assert.equal(e.empty(), 0);
for (const n of [16, 256, 4096]) {
  const f = e[`scan_${n}`];
  for (let i = 0; i < 10000; i++) assert.equal(f(), 6);
  global.gc();
  const before = process.memoryUsage();
  const samples = [];
  for (let s = 0; s < 7; s++) {
    const start = performance.now();
    let total = 0;
    for (let i = 0; i < 10000; i++) total += f();
    samples.push((performance.now() - start) * 1e6 / 10000);
    assert.equal(total, 60000);
  }
  global.gc();
  const after = process.memoryUsage();
  samples.sort((a,b) => a-b);
  console.log(JSON.stringify({whitespaceBytes: 2*n, calls: 70000, medianNs: samples[3], heapUsedDelta: after.heapUsed-before.heapUsed, rssDelta:after.rss-before.rss}));
}
console.log('production consumer: 5 exports passed; no host imports');
