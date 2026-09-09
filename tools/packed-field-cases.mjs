import assert from "node:assert/strict";

export function checkPackedFields(main) {
  const expected = [-1, 255, -1, 65535];
  for (let index = 0; index < 32; index++) {
    // Mutable capture cells replace locals and must preserve their full value.
    const result = index >= 24 ? (index % 2 === 0 ? 42 : 0)
      : index < 16 || index >= 20 ? expected[index % 4]
      : index < 18 ? 511 : 131071;
    assert.equal(main(index), result, `packed field case ${index}`);
  }
  return 32;
}
