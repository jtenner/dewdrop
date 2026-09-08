import assert from "node:assert/strict";

export function checkGenericQueryOrder(exports) {
  assert.equal(exports.main(0), 42n, "query caller retains its logical types");
  assert.equal(exports.main(1), 42n, "bound caller retains its selected implementation");
  assert.equal(exports.main(2), 7n, "plain request is not reclassified after creation");
  assert.equal(exports.main(3), 9n, "plain trait implementation is not reclassified");
  assert.equal(exports.main(4), 42n, "signed receiver keeps its exact logical specialization");
  assert.equal(exports.main(5), 7n, "unsigned receiver with the same carrier keeps its different target");
  return 6;
}
