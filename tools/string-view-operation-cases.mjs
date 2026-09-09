import assert from "node:assert/strict";

export function checkStringViewOperations(main) {
  const labels = ["empty values and bounds", "unaligned equality and hash",
    "short search candidates", "long search and final candidate",
    "mixed String/view affixes", "UTF-16 count at each vector alignment",
    "full Unicode vectors", "nested Unicode views", "byte access and conversion preserve the nested range"];
  for (const [index, label] of labels.entries()) {
    assert.equal(main(index), 1, `StringView ${label}`);
  }
  for (const index of [9, 10, 11]) {
    assert.throws(() => main(index), error =>
      error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message),
    `StringView byte access rejects an out-of-range index: ${index}`);
  }
  assert.equal(main(12), 1, "StringView raw cast function preserves nested UTF-8 and empty ranges");
  assert.equal(main(13), 1, "StringView Into Bytes preserves the selected range");
  return labels.length + 5;
}
