import assert from "node:assert/strict";

export function checkRawGcStorage(main) {
  for (const test of [...Array(14).keys(), 15, 17, 18, 20, 21, 22, 23, 24, 25]) {
    assert.equal(main(test), 1, `raw Wasm GC storage case ${test}`);
  }
  assert.throws(() => main(14), error =>
    error instanceof WebAssembly.RuntimeError && /cast/i.test(error.message),
  "raw ref.cast rejects an incompatible runtime heap");
  assert.throws(() => main(16), error =>
    error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message),
  "raw ref.cast preserves a nonreturning operand");
  assert.throws(() => main(19), error =>
    error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message),
  "builder casts retain the shared consumed state");
  return 26;
}
