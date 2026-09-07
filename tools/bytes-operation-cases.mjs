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
  return cases.length + 2;
}
