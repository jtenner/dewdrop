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
  for (const test of [12, 13, 14, 15]) {
    assert.equal(main(test), 1, `checked array operation ${test}`);
  }
  assert.throws(() => main(4294967295), WebAssembly.RuntimeError, "unknown array case is not a passing case");
  return 17;
}
