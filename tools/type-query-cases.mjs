import assert from "node:assert/strict";

export function checkTypeQueries(main) {
  for (let index = 0; index < 29; index++) {
    assert.equal(main(index), 1, `compile-time type query case ${index}`);
  }
  assert.equal(main(29), 0, "unknown case must not report a pass");
  return 30;
}
