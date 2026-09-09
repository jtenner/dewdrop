import assert from "node:assert/strict";

export function checkRawGcStorage(main) {
  for (const test of [...Array(14).keys(), 15, 17]) {
    assert.equal(main(test), 1, `raw Wasm GC storage case ${test}`);
  }
  assert.throws(() => main(14), error =>
    error instanceof WebAssembly.RuntimeError && /cast/i.test(error.message),
  "raw ref.cast rejects an incompatible runtime heap");
  assert.throws(() => main(16), error =>
    error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message),
  "raw ref.cast preserves a nonreturning operand");
  return 18;
}
