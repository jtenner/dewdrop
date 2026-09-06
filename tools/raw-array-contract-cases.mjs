import assert from "node:assert/strict";

export function checkRawArrayContracts(main) {
  for (const [index, label] of [
    "I32 storage with a second generic parameter",
    "I64 storage through a generic field",
    "default scalar allocation",
    "overlapping copy",
  ].entries()) {
    assert.equal(main(index), 1, `raw array ${label}`);
  }
  assert.throws(() => main(4), (error) => error instanceof WebAssembly.RuntimeError &&
    /array element access out of bounds/.test(error.message), "raw array copy bounds");
  for (const [index, label] of [
    [5, "generic scalar default and copy"],
    [6, "reference copy"],
    [7, "tuple copy"],
    [8, "Unit branch and copy"],
    [9, "packed generic copy"],
    [11, "zero-length boundary copy"],
    [12, "standard Wasm opcode spelling"],
    [13, "Unit copy evaluates every operand once in source order"],
    [14, "reference field write restores the declared heap type"],
  ]) {
    assert.equal(main(index), 1, `raw array ${label}`);
  }
  assert.throws(() => main(10), (error) => error instanceof WebAssembly.RuntimeError &&
    /array element access out of bounds/.test(error.message), "raw Unit array copy bounds");
  return 15;
}
