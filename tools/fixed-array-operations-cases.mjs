import assert from "node:assert/strict";

export function checkFixedArrayOperations(main) {
  for (const [index, label] of [
    "I64 indexed read and write",
    "checked read out of range",
    "checked I64 payload",
    "Unit effects in source order",
    "reference read and write",
    "tuple storage",
  ].entries()) {
    let result;
    assert.doesNotThrow(() => { result = main(index); }, `FixedArray ${label}`);
    assert.equal(result, 1, `FixedArray ${label}`);
  }
  const arrayBounds = (error) => error instanceof WebAssembly.RuntimeError &&
    /array element access out of bounds/.test(error.message);
  assert.throws(() => main(6), arrayBounds, "FixedArray Unit read bounds");
  assert.throws(() => main(7), arrayBounds, "FixedArray Unit write bounds");
  assert.equal(main(8), 1, "FixedArray tuple indexed write");
  assert.equal(main(9), 1, "FixedArray checked Unit payload");
  assert.equal(main(10), 1, "FixedArray packed U8 storage");
  assert.equal(main(11), 1, "FixedArray packed U16 storage");
  assert.equal(main(12), 1, "FixedArray packed storage across a typed return");
  return 13;
}
