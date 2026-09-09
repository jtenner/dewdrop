import assert from "node:assert/strict";
import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { specializationI64Values } from "./specialization-product-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
for (const value of specializationI64Values) {
  assert.equal(exports.main(value), value, `operator source order and result at ${value}`);
}
console.log(`native operator call recipe checks passed: ${specializationI64Values.length}`);
