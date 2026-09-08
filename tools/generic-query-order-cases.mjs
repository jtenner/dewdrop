import assert from "node:assert/strict";

export function checkGenericQueryOrder(exports) {
  assert.equal(exports.main(0), 42n, "query caller retains its logical types");
  assert.equal(exports.main(1), 42n, "bound caller retains its selected implementation");
  assert.equal(exports.main(2), 7n, "plain request is not reclassified after creation");
  assert.equal(exports.main(3), 9n, "plain trait implementation is not reclassified");
  return 4;
}
