///|
fn planned_capture_test_lowering() -> PlannedModuleLowering raise {
  let program = compiler_test_single_module_program(
    6046UL, b"pub fn maker(value: I64) -> fn() -> I64 {\n  fn() -> I64 {\n    value\n  }\n}\npub fn other(value: I64) -> I64 {\n  value\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  assert_eq(lowering.modules[0].diagnostics.length(), 0)
  let module_ = lowering.modules[0]
  assert_eq(module_.lambdas.length(), 1)
  assert_eq(module_.captures.length(), 1)
  module_
}

///|
test "physical capture reads require an owning lambda" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.bodies[1]
  assert_eq(check_planned_body_arenas(lowering, body, 7), Ok(()))
  let expression = body.expressions.start
  lowering.expressions[expression] = {
    ..lowering.expressions[expression],
    kind: PlannedCaptureGet(0),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err(
      planned_child_test_failure(
        body,
        expression,
        { start: 0, length: 0, },
        0,
        17,
      ),
    ),
  )
}

///|
test "physical capture reads stay in the lambda capture span" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.lambda_body(0).unwrap()
  assert_eq(check_planned_body_arenas(lowering, body, 7, lambda=0), Ok(()))
  let expression = body.expressions.start
  lowering.expressions[expression] = {
    ..lowering.expressions[expression],
    kind: PlannedCaptureGet(1),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7, lambda=0),
    Err(
      planned_child_test_failure(
        body,
        expression,
        { start: 0, length: 1, },
        1,
        17,
      ),
    ),
  )
}

///|
test "physical capture entries preserve their relative identity" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.lambda_body(0).unwrap()
  lowering.captures[0] = { ..lowering.captures[0], capture: 1, }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7, lambda=0),
    Err(
      planned_body_arena_failure(
        lowering,
        body,
        7,
        106,
        -1,
        0UL,
        1UL,
        17UL << 32,
      ),
    ),
  )
}

///|
test "physical capture entries preserve their lambda owner" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.lambda_body(0).unwrap()
  lowering.captures[0] = { ..lowering.captures[0], lambda: 1, }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7, lambda=0),
    Err(
      planned_body_arena_failure(
        lowering,
        body,
        7,
        106,
        -1,
        0UL,
        1UL,
        18UL << 32,
      ),
    ),
  )
}

///|
test "physical lambda capture spans are checked before access" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.lambda_body(0).unwrap()
  lowering.lambdas[0] = {
    ..lowering.lambdas[0],
    captures: { start: 2147483647, length: 1, },
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7, lambda=0),
    Err(
      planned_body_arena_failure(
        lowering,
        body,
        7,
        101,
        -1,
        1UL,
        1UL,
        (17UL << 32) | 2147483647UL,
      ),
    ),
  )
}

///|
test "physical closure recipes retain the selected capture span" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.bodies[0]
  let expression = body.expressions.start
  guard lowering.expressions[expression].kind
    is PlannedLambdaClosure(lambda, captures) else {
    fail("fixture must return a capturing closure")
  }
  lowering.expressions[expression] = {
    ..lowering.expressions[expression],
    kind: PlannedLambdaClosure(lambda, { ..captures, length: 0, }),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err(
      planned_body_arena_failure(
        lowering,
        body,
        7,
        106,
        expression,
        1UL,
        0UL,
        20UL << 32,
      ),
    ),
  )
}

///|
test "physical lambda identity is checked even without locals" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.lambda_body(0).unwrap()
  assert_eq(body.locals.length, 0)
  lowering.lambdas[0] = { ..lowering.lambdas[0], lambda: 1, }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7, lambda=0),
    Err(
      planned_body_arena_failure(
        lowering,
        body,
        7,
        106,
        -1,
        0UL,
        1UL,
        16UL << 32,
      ),
    ),
  )
}
