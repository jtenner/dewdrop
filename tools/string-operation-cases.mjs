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
  assert.equal(main(19), 1, "StringBuilder length counts UTF-8 bytes across live aliases");
  for (const index of [20, 21]) {
    assert.throws(() => main(index), error =>
      error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message),
    `StringBuilder length rejects consumed state: ${index}`);
  }
  assert.equal(main(22), 1, "StringBuilder length works through a returned function");
  assert.equal(main(23), 1, "StringBuilder default function retains aliases and grows with UTF-8 text");
  assert.equal(main(24), 1, "StringBuilder default function can finish empty");
  assert.equal(main(25), 1, "String-to-Bytes raw function retains Unicode slices and empty values");
  assert.equal(main(26), 1, "String Into Bytes preserves UTF-8 bytes");
  return labels.length + 17;
}
