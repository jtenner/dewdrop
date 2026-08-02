///|
test "WasmGC planning assigns deterministic closure and environment structs" {
  let (resolved, lowering) = wasmgc_test_inputs(
    980UL, b"fn main(seed: I32) -> Unit {\n  let callback = fn(value: I32) -> I32 {\n    value + seed\n  }\n}\n",
  )
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  assert_true(planned.closure_type_index >= 0)
  assert_eq(planned.lambda_environment_type_indices.length(), 1)
  assert_eq(planned.lambda_capture_field_indices.length(), 1)
  assert_eq(planned.lambda_capture_field_indices[0], 0)
  let closure = planned.physical_types[planned.closure_type_index]
  assert_eq(closure.kind, PlannedWasmClosureType)
  assert_eq(closure.fields.length, 2)
  let entry = planned.fields[closure.fields.start]
  let environment = planned.fields[closure.fields.start + 1]
  assert_eq(entry.role, WasmClosureEntryField)
  assert_eq(entry.storage, WasmNullableFunctionRefStorage)
  assert_eq(environment.role, WasmClosureEnvironmentField)
  assert_eq(environment.storage, WasmNullableEqRefStorage)
  let environment_index = planned.lambda_environment_type_indices[0]
  let lambda_environment = planned.physical_types[environment_index]
  assert_eq(lambda_environment.kind, PlannedWasmLambdaEnvironmentType(0))
  assert_eq(lambda_environment.fields.length, 1)
  let capture = planned.fields[lambda_environment.fields.start]
  assert_eq(capture.role, WasmLambdaCaptureField(0, 0))
  assert_eq(capture.storage, WasmI32Storage)
}

///|
test "WasmGC planning omits closure physical types when no lambdas exist" {
  let (resolved, lowering) = wasmgc_test_inputs(
    981UL, b"fn main() -> I32 {\n  1\n}\n",
  )
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  assert_eq(planned.closure_type_index, -1)
  assert_eq(planned.lambda_environment_type_indices.length(), 0)
  assert_eq(planned.lambda_capture_field_indices.length(), 0)
}
