import assert from "node:assert/strict";

export function checkRawGcUnit(main) {
  assert.equal(main(0), 1, "Unit raw array effects and length");
  assert.throws(() => main(1), WebAssembly.RuntimeError, "Unit raw array read bounds");
  assert.throws(() => main(2), WebAssembly.RuntimeError, "Unit raw array write bounds");
  return 3;
}
