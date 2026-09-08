import assert from "node:assert/strict";
import { checkSpecializationProducts, specializationI64Values } from "./specialization-product-cases.mjs";

export function checkSpecializationCallbacks(exports) {
  let checks = checkSpecializationProducts(exports);
  for (const name of [
    "mixed_scalars", "nominal_callback", "generic_nominal_callback",
    "captured_nominal_callback", "captured_generic_nominal_callback",
    "callback_evaluation_order", "trait_identity_callback",
  ]) {
    assert.equal(typeof exports[name], "function", `missing export ${name}`);
    for (const value of specializationI64Values) {
      let actual;
      assert.doesNotThrow(() => { actual = exports[name](value); }, `${name}(${value})`);
      assert.equal(actual, value, `${name}(${value})`);
      checks++;
    }
  }
  return checks;
}
