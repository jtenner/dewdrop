///|
test "nested closure sources retain direct and forwarded locals" {
  let program = compiler_test_single_module_program(
    6046UL, b"pub fn maker(seed: I64) -> fn(I64) -> fn() -> I64 {\n  fn(offset: I64) -> fn() -> I64 {\n    fn() -> I64 {\n      seed + offset\n    }\n  }\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  let planned = plan_program_lowering(program, analyzed)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = planned.modules[0]
  assert_eq(lowering.diagnostics.length(), 0)
  assert_eq(lowering.lambdas.length(), 2)
  assert_eq(lowering.captures.length(), 3)
  for body in lowering.bodies {
    assert_eq(check_planned_body_arenas(lowering, body, 7), Ok(()))
  }
  for lambda in 0..<lowering.lambdas.length() {
    assert_eq(
      check_planned_body_arenas(
        lowering,
        lowering.lambda_body(lambda).unwrap(),
        7,
        lambda~,
      ),
      Ok(()),
    )
  }
}

///|
test "capture sources retain their root body before physical planning" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.lambda_body(0).unwrap()
  let other = lowering.bodies[1].body
  lowering.captures[0] = {
    ..lowering.captures[0],
    source: BodyLocalCapture(other, 0),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7, lambda=0),
    Err(
      planned_body_arena_failure(
        lowering,
        body,
        7,
        106,
        -1,
        body.body,
        other,
        22UL << 32,
      ),
    ),
  )
}

///|
test "capture source locals stay in their owning span" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.lambda_body(0).unwrap()
  lowering.captures[0] = {
    ..lowering.captures[0],
    source: BodyLocalCapture(body.body, 1),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7, lambda=0),
    Err(planned_child_test_failure(body, -1, { start: 0, length: 1, }, 1, 2)),
  )
}

///|
test "capture source lambdas must be present" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.lambda_body(0).unwrap()
  lowering.captures[0] = {
    ..lowering.captures[0],
    source: LambdaLocalCapture(1, 0),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7, lambda=0),
    Err(planned_child_test_failure(body, -1, { start: 0, length: 1, }, 1, 16)),
  )
}

///|
test "erased captures still require their source owner" {
  let program = compiler_test_single_module_program(
    6046UL, b"pub fn maker(value: Unit) -> fn() -> Unit {\n  fn() -> Unit {\n    value\n  }\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  let planned = plan_program_lowering(program, analyzed)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = planned.modules[0]
  assert_eq(lowering.diagnostics.length(), 0)
  assert_eq(lowering.captures.length(), 1)
  assert_eq(lowering.captures[0].shape, UnitPlannedValueShape)
  let body = lowering.lambda_body(0).unwrap()
  assert_eq(check_planned_body_arenas(lowering, body, 7, lambda=0), Ok(()))
  let other = body.body + 1UL
  lowering.captures[0] = {
    ..lowering.captures[0],
    source: BodyLocalCapture(other, 0),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7, lambda=0),
    Err(
      planned_body_arena_failure(
        lowering,
        body,
        7,
        106,
        -1,
        body.body,
        other,
        22UL << 32,
      ),
    ),
  )
}

///|
test "closure captures must be available in their enclosing environment" {
  let program = compiler_test_single_module_program(
    6046UL, b"pub fn maker(seed: I64) -> fn(I64) -> fn(I64) -> I64 {\n  fn(offset: I64) -> fn(I64) -> I64 {\n    fn(extra: I64) -> I64 {\n      seed + offset + extra\n    }\n  }\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  let planned = plan_program_lowering(program, analyzed)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = planned.modules[0]
  assert_eq(lowering.diagnostics.length(), 0)
  assert_eq(lowering.lambdas.length(), 2)
  assert_eq(lowering.captures.length(), 3)
  let body = lowering.lambda_body(0).unwrap()
  assert_eq(check_planned_body_arenas(lowering, body, 7, lambda=0), Ok(()))
  let index = lowering.lambdas[1].captures.start
  assert_eq(index, 1)
  assert_eq(lowering.captures[index].source, BodyLocalCapture(body.body, 0))
  lowering.captures[index] = {
    ..lowering.captures[index],
    source: LambdaLocalCapture(1, 0),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7, lambda=0),
    Err(
      planned_body_arena_failure(
        lowering,
        body,
        7,
        104,
        body.expressions.start,
        1UL,
        0UL,
        (23UL << 32) | index.to_uint64(),
      ),
    ),
  )
}
