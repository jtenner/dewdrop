///|
test "lowering freezes lambda construction bodies locals and captures" {
  let (collected, _, names, inferred, _, planned) = lowering_test_module(
    940UL, b"fn main(seed: I32) -> Unit {\n  let outer = fn(offset: I32) -> I32 {\n    let inner = fn(value: I32) -> I32 {\n      value + offset + seed\n    }\n    inner(1)\n  }\n}\n",
  )
  assert_eq(planned.diagnostics.length(), 0)
  assert_eq(planned.lambdas.length(), 2)
  assert_eq(planned.captures.length(), 3)
  for lambda_index in 0..<2 {
    let lambda = collected.lambdas[lambda_index]
    let planned_lambda = planned.lambdas[lambda_index]
    assert_eq(planned_lambda.lambda, lambda_index)
    assert_eq(planned_lambda.expressions, lambda.body.expressions)
    assert_eq(planned_lambda.blocks, lambda.body.blocks)
    assert_eq(
      planned_lambda.root_type,
      inferred.lambda(lambda_index).unwrap().root_type,
    )
    assert_eq(planned_lambda.root_shape, I32PlannedValueShape)
    let name_info = names.lambda(lambda_index).unwrap()
    assert_eq(planned_lambda.locals, name_info.locals)
    assert_eq(planned_lambda.captures, name_info.captures)
    for local_id in 0..<name_info.locals.length {
      let local_info = planned.locals[name_info.locals.start + local_id]
      assert_eq(local_info.lambda, lambda_index)
      assert_eq(local_info.local_id, local_id)
    }
    for capture_id in 0..<name_info.captures.length {
      let capture = planned.captures[name_info.captures.start + capture_id]
      assert_eq(capture.lambda, lambda_index)
      assert_eq(capture.capture, capture_id)
      assert_eq(capture.shape, I32PlannedValueShape)
    }
  }
  let root_body = collected.bodies[0]
  let mut outer_expression = -1
  for
    expression in root_body.expressions.start..<(root_body.expressions.start +
    root_body.expressions.length) {
    match collected.expressions[expression] {
      HirLambdaExpr(0, _) => outer_expression = expression
      _ => ()
    }
  }
  assert_true(outer_expression >= 0)
  match planned.expressions[outer_expression].kind {
    PlannedLambdaClosure(0, captures) => assert_eq(captures.length, 1)
    _ => fail("expected outer closure construction")
  }
  let outer = collected.lambdas[0]
  let mut inner_expression = -1
  for
    expression in outer.body.expressions.start..<(outer.body.expressions.start +
    outer.body.expressions.length) {
    match collected.expressions[expression] {
      HirLambdaExpr(1, _) => inner_expression = expression
      _ => ()
    }
  }
  assert_true(inner_expression >= 0)
  match planned.expressions[inner_expression].kind {
    PlannedLambdaClosure(1, captures) => assert_eq(captures.length, 2)
    _ => fail("expected nested closure construction")
  }
  let inner = collected.lambdas[1]
  let offset_expression = lambda_name_expression(collected, inner, "offset")
  let seed_expression = lambda_name_expression(collected, inner, "seed")
  assert_eq(planned.expressions[offset_expression].kind, PlannedCaptureGet(0))
  assert_eq(planned.expressions[seed_expression].kind, PlannedCaptureGet(1))
}
