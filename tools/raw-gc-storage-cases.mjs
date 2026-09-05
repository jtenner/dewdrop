import assert from "node:assert/strict";

export function checkRawGcStorage(main) {
  for (let test = 0; test < 7; test++) {
    assert.equal(main(test), 1, `raw Wasm array storage case ${test}`);
  }
  return 7;
}
