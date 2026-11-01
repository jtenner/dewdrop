import assert from 'node:assert/strict';
import fs from 'node:fs';
import { performance } from 'node:perf_hooks';
const bytes = fs.readFileSync('.tmp/iter-consumer.wasm');
const module = await WebAssembly.compile(bytes);
assert.deepEqual(WebAssembly.Module.imports(module), [], 'production has no hidden host imports');
const facts = WebAssembly.Module.customSections(module, 'compiler.facts');
assert.equal(facts.length, 1, 'normal compiler facts');
const wat = fs.readFileSync('.tmp/iter-consumer.wat', 'utf8');
for (const [param, result, body] of [
  ['i32', 'i32', 'local.get 0'],
  ['eqref', 'eqref', 'local.get 0'],
  ['i32', 'i32', 'i32.const 1'],
  ['eqref', 'i32', 'i32.const 1'],
]) {
  const signature = `(param ${param}) (result ${result})\n    ${body}\n  )`;
  assert.ok(wat.includes(signature), `specialized callback ${param} -> ${result}: ${body}`);
}
console.log('concrete callback specializations: scalar/reference identity and predicate');
const instance = await WebAssembly.instantiate(module, {});
const e = instance.exports;
e.__dew_init?.();
assert.equal(e.scalar_callback(), 42);
assert.equal(e.reference_callback(), 1);
for (const n of [0, 1, 2, 3, 17, 1024, 65536]) {
  const k = Math.ceil(n / 2);
  assert.equal(e.pipeline(n) >>> 0, (2 * k * (k - 1)) >>> 0, `sum oracle n=${n}`);
}
console.log('production integration: 15 checks passed; imports=0');
for (const n of [1024, 65536, 262144]) {
  for (let i = 0; i < 5; ++i) e.pipeline(n);
  global.gc?.();
  const before = process.memoryUsage();
  const start = performance.now();
  for (let i = 0; i < 20; ++i) e.pipeline(n);
  const ms = performance.now() - start;
  const peak = process.memoryUsage();
  global.gc?.();
  const after = process.memoryUsage();
  console.log(JSON.stringify({n, runs:20, ms, heap_delta:peak.heapUsed-before.heapUsed, retained_heap_delta:after.heapUsed-before.heapUsed, rss:peak.rss}));
}
console.log(JSON.stringify({wasm_bytes:bytes.length, loops:[...wat.matchAll(/^\s*(?:\(loop\b|loop\b)/gm)].length, struct_new_sites:[...wat.matchAll(/\bstruct\.new\b/g)].length, array_new_sites:[...wat.matchAll(/\barray\.new(?:_default|_fixed)?\b/g)].length}));
