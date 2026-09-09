import assert from "node:assert/strict";
import { checkSpecializationProducts, specializationI64Values } from "./specialization-product-cases.mjs";

export const specializationCallbackNames = [
  "named_map_payload_callback", "named_array_payload_callback",
  "mixed_scalars", "nominal_callback", "generic_nominal_callback",
  "captured_nominal_callback", "captured_generic_nominal_callback",
  "callback_evaluation_order", "trait_identity_callback",
  "bound_function_callback", "bound_lambda_callback",
  "direct_bound_callback", "closed_bound_callback",
  "nested_capture_callback", "nested_mutable_capture_callback",
  "erased_capture_callback", "packed_capture_callback",
  "generic_enum_callback",
  "generic_enum_reader_callback", "generic_enum_nested_callback",
  "generic_enum_mixed_callback", "generic_enum_reference_callback",
  "generic_enum_unit_callback",
  "generic_enum_float_callback", "generic_enum_vector_callback",
  "generic_enum_function_callback", "generic_enum_literal_callback",
  "generic_enum_empty_callback", "generic_enum_unit_reader_callback",
  "generic_enum_order_callback",
  "result_ok_callback", "result_err_callback", "result_nested_callback",
  "result_unit_callback", "result_reference_callback",
  "result_function_callback", "result_vector_callback",
  "result_float_callback", "result_name_collision_callback",
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
