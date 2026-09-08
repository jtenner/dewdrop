///|
fn lambda_shape_test_module() -> PlannedModuleLowering raise {
  let (_, _, _, inferred, _, module_) = lowering_test_module(
    24911UL, b"pub fn make(seed: I64) -> fn(I64) -> I64 {\n  fn(next: I64) -> I64 {\n    seed + next\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(module_.diagnostics, [])
  assert_eq(module_.lambdas.length(), 1)
  assert_eq(module_.functions.callables[0].declaration, 24911UL << 32)
  assert_eq(module_.lambdas[0].root_body, 24911UL << 32)
  assert_eq(module_.lambdas[0].expressions.start, 1)
  module_
}

///|
test "lambda parameters and captures retain complete shape failure context" {
  let module_ = lambda_shape_test_module()
  let lambda = module_.lambdas[0]
  for detail in [(1UL << 32) | 2UL, (2UL << 32) | 3UL] {
    for
      item in [
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
      let (shape, actual) = item
      assert_eq(
        check_lambda_physical_shape(
          module_.module_id,
          module_.functions.callables[0].declaration,
          lambda,
          shape,
          detail,
        ),
        Err({
          code: 301,
          phase: 4,
          module_id: 24911UL,
          declaration: 24911UL << 32,
          body: 24911UL << 32,
          expression: 1U,
          expected: 0UL,
          actual,
          detail,
        }),
      )
    }
  }
}

///|
test "lambda physical evidence keeps concrete and erased shapes" {
  let module_ = lambda_shape_test_module()
  for
    shape in [
      UnitPlannedValueShape,
      NeverPlannedValueShape,
      I8PlannedValueShape,
      U16PlannedValueShape,
      I32PlannedValueShape,
      I64PlannedValueShape,
      F32PlannedValueShape,
      F64PlannedValueShape,
      V128PlannedValueShape,
      RefPlannedValueShape,
      ProductPlannedValueShape([UnitPlannedValueShape, I64PlannedValueShape]),
    ] {
    assert_eq(
      check_lambda_physical_shape(
        module_.module_id,
        module_.functions.callables[0].declaration,
        module_.lambdas[0],
        shape,
        0xffffffffUL,
      ),
      Ok(()),
    )
  }
}

///|
test "lambda physical results reject poison including product leaves" {
  let module_ = lambda_shape_test_module()
  let source = module_.lambdas[0]
  assert_eq(source.result_shape, I64PlannedValueShape)
  let declaration = module_.functions.callables[0].declaration
  for
    shape in [
      ErrorPlannedValueShape,
      ProductPlannedValueShape([I64PlannedValueShape, ErrorPlannedValueShape]),
    ] {
    let mutated = { ..source, result_shape: shape, }
    let expected : LambdaPhysicalShapeFailure = {
      code: 301,
      phase: 4,
      module_id: 24911UL,
      declaration,
      body: source.root_body,
      expression: source.expressions.start.reinterpret_as_uint(),
      expected: 0UL,
      actual: 2UL,
      detail: 0xffffffffUL,
    }
    assert_eq(
      check_lambda_physical_shape(
        module_.module_id,
        declaration,
        mutated,
        mutated.result_shape,
        0xffffffffUL,
      ),
      Err(expected),
    )
  }
}

///|
test "lambda physical results reject hidden generic product leaves" {
  let module_ = lambda_shape_test_module()
  let source = module_.lambdas[0]
  let declaration = module_.functions.callables[0].declaration
  let shape = ProductPlannedValueShape([
    I64PlannedValueShape,
    GenericPlannedValueShape,
  ])
  let expected : LambdaPhysicalShapeFailure = {
    code: 301,
    phase: 4,
    module_id: 24911UL,
    declaration,
    body: source.root_body,
    expression: source.expressions.start.reinterpret_as_uint(),
    expected: 0UL,
    actual: 1UL,
    detail: 0xffffffffUL,
  }
  assert_eq(
    check_lambda_physical_shape(
      module_.module_id,
      declaration,
      source,
      shape,
      0xffffffffUL,
    ),
    Err(expected),
  )
}
