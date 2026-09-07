import assert from "node:assert/strict";

export function checkProductPatterns(exports) {
  const expected = [42, 42, 42, 42, 42, 42, 99, 43, 42, 42, 0, 42, 0, 42, 42, 41, 42];
  for (const [index, value] of expected.entries()) {
    assert.equal(exports.main(index), value, `product pattern case ${index}`);
  }
  return expected.length;
}
