import assert from "node:assert/strict";

export function checkBytesOperations(main) {
  const cases = [
    "empty inputs and affix bounds",
    "unaligned multi-vector equality and affixes",
    "short search candidates and all byte values",
    "long rolling search and the final candidate",
    "stable FNV-1a hashes and logical views",
    "valid UTF-8 boundary encodings",
    "invalid, overlong, surrogate, and truncated UTF-8",
    "UTF-8 across vector and view boundaries",
    "every view alignment and multi-vector search",
    "checked conversion shares the exact logical view",
  ];
  for (const [index, label] of cases.entries()) {
    assert.equal(main(index), 1, `Bytes ${label}`);
  }
  for (const index of [10, 11]) {
    assert.throws(() => main(index), error =>
      error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message),
    `Bytes checked conversion rejects invalid UTF-8: ${index}`);
  }
  for (const [index, label] of [[12, "concatenation preserves raw bytes and inputs"],
    [13, "concatenation preserves each source alignment"]]) {
    assert.equal(main(index), 1, `Bytes ${label}`);
  }
  for (const [index, label] of [[14, "SIMD loads preserve every lane and alignment"],
    [15, "SIMD arguments run once in source order"],
    [16, "SIMD library access works through a returned function"]]) {
    assert.equal(main(index), 1, `Bytes ${label}`);
  }
  for (const index of [17, 18, 19, 20]) {
    assert.throws(() => main(index), error =>
      error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message),
    `Bytes SIMD access rejects an out-of-range index: ${index}`);
  }
  assert.equal(main(21), 1, "Bytes length uses the logical range, not capacity or offset");
  return cases.length + 12;
}
