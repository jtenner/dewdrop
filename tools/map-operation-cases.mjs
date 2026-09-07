import assert from "node:assert/strict";

export function checkMapOperations(main) {
  for (const [index, label] of [
    "scalar insert, replacement, indexing, and missing keys",
    "collision chains, growth, and head/middle/tail removal",
    "Unit values and value iteration",
    "tuple values and generic payload binding",
    "clear preserves aliases and allows reuse",
    "entry aliases observe value replacement",
  ].entries()) {
    assert.equal(main(index), 1, `Map ${label}`);
  }
  assert.equal(main(7), 1, "Map iterator remains exhausted");
  assert.equal(main(8), 1, "Map String and Bytes keys use content equality");
  assert.equal(main(9), 1, "Map hashes each insertion once and reuses hashes during growth");
  assert.equal(main(10), 1, "Map preserves reference, f32, and f64 values");
  assert.equal(main(11), 1, "Map iteration visits each entry once after growth");
  for (const [index, label] of [[6, "unchecked missing key"]]) {
    assert.throws(() => main(index), error => error instanceof WebAssembly.RuntimeError &&
      /unreachable/.test(error.message), `Map ${label}`);
  }
  return 12;
}
