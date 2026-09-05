import assert from "node:assert/strict";

export function checkArrayOperations(main) {
  for (let test = 0; test < 5; test++) {
    assert.equal(main(test), 1, `array operation case ${test}`);
  }
  for (let test = 5; test < 9; test++) {
    assert.throws(() => main(test), WebAssembly.RuntimeError, `array bounds case ${test}`);
  }
  assert.equal(main(9), 1, "Unit literal, iteration, pop, clear, and option checks");
  for (const test of [10, 11]) {
    assert.throws(() => main(test), WebAssembly.RuntimeError, `non-returning index ${test}`);
  }
  return 12;
}
