///|
test "WasmGC planning flattens lambda captures into closure subtypes" {
  let (resolved, lowering) = wasmgc_test_inputs(
    980UL, b"fn make(seed: I32) -> fn(I32) -> I32 {\n  fn(value: I32) -> I32 {\n    value + seed\n  }\n}\n",
  )
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  assert_true(planned.closure_type_index >= 0)
  assert_eq(planned.lambda_closure_type_indices.length(), 1)
  assert_eq(planned.lambda_capture_field_indices.length(), 1)
  assert_eq(planned.lambda_capture_field_indices[0], 1)
  let closure = planned.physical_types[planned.closure_type_index]
  assert_eq(closure.kind, PlannedWasmClosureType)
  assert_eq(closure.fields.length, 1)
  let entry = planned.fields[closure.fields.start]
  assert_eq(entry.role, WasmClosureEntryField)
  assert_eq(entry.storage, WasmNullableFunctionRefStorage)
  let lambda_closure_index = planned.lambda_closure_type_indices[0]
  let lambda_closure = planned.physical_types[lambda_closure_index]
  assert_eq(lambda_closure.kind, PlannedWasmLambdaClosureType(0))
  assert_eq(lambda_closure.fields.length, 2)
  let inherited_entry = planned.fields[lambda_closure.fields.start]
  assert_eq(inherited_entry.role, WasmClosureEntryField)
  assert_eq(inherited_entry.storage, WasmNullableFunctionRefStorage)
  let capture = planned.fields[lambda_closure.fields.start + 1]
  assert_eq(capture.role, WasmLambdaCaptureField(0, 0))
  assert_eq(capture.storage, WasmI32Storage)
}

///|
test "WasmGC planning gives directized lambdas lifted capture parameters" {
  let (resolved, lowering) = wasmgc_test_inputs(
    982UL, b"fn main(seed: I32) -> I32 {\n  let callback = fn(value: I32) -> I32 {\n    value + seed\n  }\n  callback(41)\n}\n",
  )
  assert_true(lowering.lambdas[0].directized)
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  assert_eq(planned.lambda_capture_parameter_indices.length(), 1)
  assert_eq(planned.lambda_capture_parameter_indices[0], 0)
  assert_eq(planned.lambda_closure_type_indices[0], -1)
  let lambda_function = planned.functions[planned.lambda_function_indices[0]]
  assert_eq(lambda_function.parameters.length, 2)
}

///|
test "WasmGC planning keeps escaping lambda environment parameters" {
  let (resolved, lowering) = wasmgc_test_inputs(
    983UL, b"fn make(seed: I32) -> fn(I32) -> I32 {\n  fn(value: I32) -> I32 {\n    value + seed\n  }\n}\n",
  )
  assert_false(lowering.lambdas[0].directized)
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  assert_eq(planned.lambda_capture_parameter_indices[0], -1)
  let lambda_function = planned.functions[planned.lambda_function_indices[0]]
  assert_eq(lambda_function.parameters.length, 2)
}

///|
test "WasmGC planning omits closure physical types when no lambdas exist" {
  let (resolved, lowering) = wasmgc_test_inputs(
    981UL, b"fn main() -> I32 {\n  1\n}\n",
  )
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  assert_eq(planned.closure_type_index, -1)
  assert_eq(planned.lambda_closure_type_indices.length(), 0)
  assert_eq(planned.lambda_capture_field_indices.length(), 0)
}
