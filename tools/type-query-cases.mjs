import assert from "node:assert/strict";

export function checkTypeQueries(main) {
  for (let index = 0; index < 38; index++) {
    assert.equal(main(index), 1, `compile-time type query case ${index}`);
  }
  assert.equal(main(38), 0, "unknown case must not report a pass");
  return 39;
}
