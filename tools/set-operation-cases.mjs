import assert from "node:assert/strict";

export function checkSetOperations(main) {
  const cases = [
    "empty, insert, duplicate, and membership",
    "collision chains, growth, and removal",
    "clear preserves aliases and allows reuse",
    "iterator lookahead and repeated exhaustion",
    "iteration visits each key once after growth",
    "String and Bytes content equality",
    "full-width I64 keys and iteration",
    "each insert hashes once and growth reuses hashes",
  ];
  for (const [index, label] of cases.entries()) {
    assert.equal(main(index), 1, `Set ${label}`);
  }
  return cases.length;
}
