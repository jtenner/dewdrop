import assert from "node:assert/strict";
import { checkSpecializationProducts, specializationI64Values } from "./specialization-product-cases.mjs";

export const specializationCallbackNames = [
  "mixed_scalars", "nominal_callback", "generic_nominal_callback",
  "captured_nominal_callback", "captured_generic_nominal_callback",
  "callback_evaluation_order", "trait_identity_callback",
  "bound_function_callback", "bound_lambda_callback",
  "direct_bound_callback", "closed_bound_callback",
];

export function checkSpecializationCallbacks(exports) {
  let checks = checkSpecializationProducts(exports);
  for (const name of specializationCallbackNames) {
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
