import assert from "node:assert/strict";

export function checkStringPatterns(main) {
  const cases = [
    [10207, "selected Eq target and one subject evaluation"],
    [107, "nested literal uses selected Eq"],
    [2, "discarded result retains Eq side effects"],
    [101, "is-pattern uses selected Eq"],
    [0, "failed parent skips nested equality"],
  ];
  for (const [index, [expected, label]] of cases.entries()) {
    assert.equal(main(index), expected, `String pattern ${label}`);
  }
  return cases.length;
}
