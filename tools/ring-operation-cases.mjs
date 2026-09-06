import assert from "node:assert/strict";

export function checkRingOperations(main) {
  for (const test of [0, 1, 2, 3, 4, 5, 8, 9, 10, 13, 14, 15, 16, 17, 18]) {
    assert.equal(main(test), 1, `Dew circular buffer, Queue, or Deque case ${test}`);
  }
  for (const test of [6, 7]) {
    assert.throws(() => main(test), error =>
      error instanceof WebAssembly.RuntimeError && /illegal cast|null/.test(error.message),
    `removed ring references are cleared: ${test}`);
  }
  for (const test of [11, 12, 4294967295]) {
    assert.throws(() => main(test), error =>
      error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message),
    `ring bound or unknown case: ${test}`);
  }
  return 20;
}
