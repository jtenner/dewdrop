import assert from "node:assert/strict";

export function checkStringOperations(main) {
  const labels = ["empty values and bounds", "short searches",
    "long searches and hash", "mixed affixes", "UTF-16 at each alignment",
    "Unicode vectors and stable hash", "concatenation preserves inputs",
    "literal match uses text content", "computed values and fields use content equality"];
  for (const [index, label] of labels.entries()) {
    assert.equal(main(index), 1, `String ${label}`);
  }
  return labels.length;
}
