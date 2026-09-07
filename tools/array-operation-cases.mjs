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
  for (const test of [16, 17, 23, 25, 26]) {
    assert.equal(main(test), 1, `Dew array storage and iterator case ${test}`);
  }
  assert.throws(() => main(24), error =>
    error instanceof WebAssembly.RuntimeError && /illegal cast|null/.test(error.message),
  "removed reference storage is cleared");
  for (const test of [18, 19, 20, 21, 22]) {
    assert.throws(() => main(test), error =>
      error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message),
    `Dew array checked bound or overflow case ${test}`);
  }
  assert.throws(() => main(4294967295), WebAssembly.RuntimeError, "unknown array case is not a passing case");
  assert.equal(main(27), 1, "packed Array literals keep signedness and work after growth");
  return 29;
}
