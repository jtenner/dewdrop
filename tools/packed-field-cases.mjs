import assert from "node:assert/strict";

export function checkPackedFields(main) {
  const expected = [-1, 255, -1, 65535];
  for (let index = 0; index < 20; index++) {
    // Mutable capture cells replace locals and must preserve their full value.
    const result = index < 16 ? expected[index % 4] : (index < 18 ? 511 : 131071);
    assert.equal(main(index), result, `packed field case ${index}`);
  }
  return 20;
}
