///|
test "live capture planning rejects invalid shapes with full source context" {
  for
    source in [
      b"pub fn make(seed: I64) -> fn(I64) -> I64 {\n  fn(value: I64) -> I64 {\n    value + seed\n  }\n}\n",
      b"pub fn run(seed: I64) -> I64 {\n  let callback = fn(value: I64) -> I64 {\n    value + seed\n  }\n  callback(41i64)\n}\n",
      b"pub fn run() -> I64 {\n  let mut seed = 1i64\n  let callback = fn(value: I64) -> I64 {\n    seed = seed + value\n    seed\n  }\n  callback(41i64)\n}\n",
    ] {
    let (_, lowering) = wasmgc_test_inputs(24912UL, source)
    assert_eq(lowering.diagnostics, [])
    assert_eq(lowering.lambdas.length(), 1)
    assert_eq(lowering.captures.length(), 1)
    let lambda = lowering.lambdas[0]
    let capture = lowering.captures[0]
    assert_false(lambda.elided)
    assert_eq(capture.shape, I64PlannedValueShape)
    assert_eq(check_module_lambda_capture_shapes(lowering), Ok(()))
    for
      (shape, reason) in [
        (GenericPlannedValueShape, 1UL),
        (ErrorPlannedValueShape, 2UL),
        (
          ProductPlannedValueShape([
            I64PlannedValueShape,
            GenericPlannedValueShape,
          ]),
          1UL,
        ),
        (
          ProductPlannedValueShape([
            I64PlannedValueShape,
            ErrorPlannedValueShape,
          ]),
          2UL,
        ),
      ] {
      lowering.captures[0] = { ..capture, shape, }
      assert_eq(
        check_module_lambda_capture_shapes(lowering),
        Err({
          code: 301,
          phase: 4,
          module_id: 24912UL,
          declaration: 24912UL << 32,
          body: 24912UL << 32,
          expression: lambda.expressions.start.reinterpret_as_uint(),
          expected: 0UL,
          actual: reason,
          detail: 2UL << 32,
        }),
      )
    }
  }
}

///|
test "capture failures retain the declaration and relative capture index" {
  let (_, lowering) = wasmgc_test_inputs(
    24915UL, b"struct Marker {\n  value: I32\n}\npub fn make(left: I64, right: I64) -> fn() -> I64 {\n  fn() -> I64 {\n    left + right\n  }\n}\n",
  )
  assert_eq(lowering.diagnostics, [])
  assert_eq(lowering.captures.length(), 2)
  let lambda = lowering.lambdas[0]
  let second = lowering.captures[lambda.captures.start + 1]
  assert_eq(second.capture, 1)
  lowering.captures[lambda.captures.start + 1] = {
    ..second,
    shape: ErrorPlannedValueShape,
  }
  assert_eq(
    check_module_lambda_capture_shapes(lowering),
    Err({
      code: 301,
      phase: 4,
      module_id: 24915UL,
      declaration: (24915UL << 32) | 1UL,
      body: 24915UL << 32,
      expression: lambda.expressions.start.reinterpret_as_uint(),
      expected: 0UL,
      actual: 2UL,
      detail: (2UL << 32) | 1UL,
    }),
  )
}

///|
test "capture checks preserve concrete shapes and logical templates" {
  let (resolved, lowering) = wasmgc_test_inputs(
    24912UL, b"pub fn make(seed: I64) -> fn(I64) -> I64 {\n  fn(value: I64) -> I64 {\n    value + seed\n  }\n}\n",
  )
  let capture = lowering.captures[0]
  for
    shape in [
      UnitPlannedValueShape,
      NeverPlannedValueShape,
      I64PlannedValueShape,
      RefPlannedValueShape,
      ProductPlannedValueShape([UnitPlannedValueShape, I64PlannedValueShape]),
    ] {
    lowering.captures[0] = { ..capture, shape, }
    assert_eq(check_module_lambda_capture_shapes(lowering), Ok(()))
  }
  lowering.captures[0] = capture
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  let closure = planned.physical_types[planned.lambda_closure_type_indices[0]]
  assert_eq(planned.fields[closure.fields.start + 1].storage, WasmI64Storage)
  let (_, template) = wasmgc_test_inputs(
    24913UL, b"pub fn make<t>(seed: t) -> fn() -> t {\n  fn() -> t {\n    seed\n  }\n}\n",
  )
  assert_eq(template.diagnostics, [])
  assert_eq(template.captures[0].shape, GenericPlannedValueShape)
  assert_eq(check_module_lambda_capture_shapes(template), Ok(()))
  let (elided_resolved, elided) = wasmgc_test_inputs(
    24914UL, b"pub fn run() -> I32 {\n  let mut seed = 1\n  let unused = fn() -> I32 {\n    seed\n  }\n  seed = 42\n  seed\n}\n",
  )
  assert_true(elided.lambdas[0].elided)
  elided.captures[0] = { ..elided.captures[0], shape: ErrorPlannedValueShape, }
  assert_eq(check_module_lambda_capture_shapes(elided), Ok(()))
  let planned_elided = plan_module_wasmgc_fragments(elided_resolved, elided)
  assert_eq(planned_elided.capture_cell_type_indices[0], -1)
  assert_eq(planned_elided.lambda_closure_type_indices[0], -1)
}

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
test "WasmGC planning boxes mutable captures in shared carrier cells" {
  let (resolved, lowering) = wasmgc_test_inputs(
    984UL, b"fn main() -> I32 {\n  let mut seed = 1\n  let callback = fn(value: I32) -> I32 {\n    seed = seed + value\n    seed\n  }\n  callback(41)\n}\n",
  )
  assert_true(lowering.lambdas[0].directized)
  assert_true(lowering.captures[0].mutable_)
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  let cell_index = planned.capture_cell_type_indices[0]
  assert_true(cell_index >= 0)
  let cell = planned.physical_types[cell_index]
  assert_eq(cell.kind, PlannedWasmCaptureCellType(0))
  assert_eq(cell.fields.length, 1)
  let value = planned.fields[cell.fields.start]
  assert_eq(value.role, WasmCaptureCellValueField(0))
  assert_eq(value.storage, WasmI32Storage)
  assert_true(value.mutable_)
  assert_eq(planned.lambda_capture_parameter_indices[0], 0)
  let lambda_function = planned.functions[planned.lambda_function_indices[0]]
  assert_eq(
    planned.function_value_types[lambda_function.parameters.start],
    WasmNullableEqRefValue,
  )
  assert_eq(planned.lambda_closure_type_indices[0], -1)
}

///|
test "WasmGC planning does not box captures used only by elided lambdas" {
  let (resolved, lowering) = wasmgc_test_inputs(
    985UL, b"fn main() -> I32 {\n  let mut seed = 1\n  let unused = fn() -> I32 {\n    seed\n  }\n  seed = 42\n  seed\n}\n",
  )
  assert_true(lowering.lambdas[0].elided)
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  assert_eq(planned.capture_cell_type_indices[0], -1)
  assert_eq(planned.lambda_closure_type_indices[0], -1)
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
