import assert from "node:assert/strict";

export function checkMemberCalls(main) {
  let checks = 0;
  for (const value of [-2147483648, -7, 0, 42, 2147483647]) {
    assert.equal(main(value, value), value, "index/field assignment, Unit receivers, Never argument prefixes, exact named method results and effects, and indexed float arithmetic");
    assert.equal(main(value, value === 0 ? 1 : 0), -1, "index/field comparison must use its operand");
    checks += 2;
  }
  return checks;
}
