import assert from "node:assert/strict";

export function checkRawGcStorage(main) {
  for (let test = 0; test < 11; test++) {
    assert.equal(main(test), 1, `raw Wasm GC storage case ${test}`);
  }
  return 11;
}
