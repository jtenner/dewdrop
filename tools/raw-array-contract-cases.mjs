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
    [15, "Option constructor uses the unboxed generic field value"],
    [16, "signed 8-bit raw storage truncates and sign-extends"],
    [17, "unsigned 8-bit raw storage truncates and zero-extends"],
    [18, "signed 16-bit raw storage truncates and sign-extends"],
    [19, "unsigned 16-bit raw storage truncates and zero-extends"],
    [20, "generic signed 8-bit storage"],
    [21, "generic unsigned 8-bit storage"],
    [22, "generic signed 16-bit storage"],
    [23, "generic unsigned 16-bit storage"],
    [24, "signed 8-bit Array literal and growth"],
    [25, "unsigned 8-bit Array literal and growth"],
    [26, "signed 16-bit Array literal and growth"],
    [27, "unsigned 16-bit Array literal and growth"],
    [28, "signed 8-bit default, write, and copy"],
    [29, "unsigned 8-bit default, write, and copy"],
    [30, "signed 16-bit default, write, and copy"],
    [31, "unsigned 16-bit default, write, and copy"],
  ]) {
    assert.equal(main(index), 1, `raw array ${label}`);
  }
  assert.throws(() => main(10), (error) => error instanceof WebAssembly.RuntimeError &&
    /array element access out of bounds/.test(error.message), "raw Unit array copy bounds");
  for (const index of [32, 33]) {
    assert.throws(() => main(index), (error) => error instanceof WebAssembly.RuntimeError &&
      /array element access out of bounds/.test(error.message), "packed raw array bounds");
  }
  return 34;
}
