import assert from "node:assert/strict";

export function checkStringOperations(main) {
  const labels = ["empty values and bounds", "short searches",
    "long searches and hash", "mixed affixes", "UTF-16 at each alignment",
    "Unicode vectors and stable hash", "concatenation preserves inputs",
    "literal match uses text content", "computed values and fields use content equality",
    "byte access preserves the logical Unicode range"];
  for (const [index, label] of labels.entries()) {
    assert.equal(main(index), 1, `String ${label}`);
  }
  for (const index of [10, 11, 12]) {
    assert.throws(() => main(index), error =>
      error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message),
    `String byte access rejects an out-of-range index: ${index}`);
  }
  for (const [index, label] of [[13, "SIMD loads preserve logical view bounds"],
    [14, "SIMD arguments run once in source order"],
    [15, "SIMD library access works through a returned function"]]) {
    assert.equal(main(index), 1, `String ${label}`);
  }
  for (const index of [16, 17, 18]) {
    assert.throws(() => main(index), error =>
      error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message),
    `String SIMD access rejects an out-of-range index: ${index}`);
  }
  return labels.length + 9;
}
