import assert from "node:assert/strict";

export function checkUnitBranches(exports) {
  let checks = 0;
  for (const [index, name] of ["bool_branch", "i64_branch", "ref_branch", "product_branch", "unit_branch", "nested_branch"].entries()) {
    assert.equal(exports.main(index, 0), 0, `${name}: skipped branch has no effect`);
    assert.equal(exports.main(index, 1), 1, `${name}: branch runs exactly once`);
    checks += 2;
  }
  assert.equal(exports.main(6, 0), 5);
  assert.equal(exports.main(6, 1), 7);
  assert.equal(exports.main(7, 0), 9);
  assert.equal(exports.main(7, 1), 9);
  checks += 4;
  for (const [index, [name, expected]] of [["folded_true", 1], ["folded_false", 0], ["query_true", 1], ["query_false", 0]].entries()) {
    assert.equal(exports.main(index + 8, 0), expected, `${name}: selected branch preserves effects`);
    checks++;
  }
  assert.equal(exports.main(12, 0), 42, "Unit match subject runs once without a stack value");
  assert.equal(exports.main(13, 0), 42, "Unit loop initial and continue values run once without stores");
  checks += 2;
  assert.equal(exports.main(14, 0), 42, "Unit globals run their initializers and keep scalar global slots aligned");
  assert.equal(exports.main(14, 1), 42, "reading Unit globals does not run their initializers again");
  checks += 2;
  for (const [index, name] of ["if condition", "match subject", "loop initial"].entries()) {
    assert.throws(() => exports.main(index + 15, 0),
      error => error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message),
      `Never ${name} traps before its branches run`);
    checks++;
  }
  return checks;
}
