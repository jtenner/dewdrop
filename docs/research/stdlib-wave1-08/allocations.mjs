import assert from 'node:assert/strict';
import fs from 'node:fs';
const { instance } = await WebAssembly.instantiate(fs.readFileSync('.tmp/iter-instrumented.wasm'), {});
const e = instance.exports;
e.__dew_init?.();
for (const n of [0, 1, 2, 17, 1024, 65536]) {
  e.probe_reset();
  const result = e.pipeline(n) >>> 0;
  const k = Math.ceil(n / 2);
  assert.equal(result, (2 * k * (k - 1)) >>> 0);
  assert.equal(Number(e.probe_array()), 1, `only the input backing array n=${n}`);
  console.log(JSON.stringify({n, result, struct_allocations:Number(e.probe_struct()), array_allocations:Number(e.probe_array())}));
}
