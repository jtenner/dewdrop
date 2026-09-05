import assert from "node:assert/strict";
import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkSpecializationProducts, specializationI64Values } from "./specialization-product-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
let checks = checkSpecializationProducts(exports);
for (const name of ["mixed_scalars"]) {
  assert.equal(typeof exports[name], "function", `missing export ${name}`);
  for (const value of specializationI64Values) {
    let actual;
    assert.doesNotThrow(() => { actual = exports[name](value); }, `${name}(${value})`);
    assert.equal(actual, value, `${name}(${value})`);
    checks++;
  }
}
console.log(`native specialization callback checks passed: ${checks}`);
