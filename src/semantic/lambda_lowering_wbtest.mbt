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
  assert_true(planned.lambdas[0].elided)
  assert_eq(
    planned.expressions[outer_expression].kind,
    PlannedConsumedExpression,
  )
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
  assert_true(planned.lambdas[1].directized)
  assert_eq(
    planned.expressions[inner_expression].kind,
    PlannedConsumedExpression,
  )
  let mut direct_inner_calls = 0
  for
    expression in outer.body.expressions.start..<(outer.body.expressions.start +
    outer.body.expressions.length) {
    match planned.expressions[expression].kind {
      PlannedDirectLambdaCall(1, captures, arguments) => {
        assert_eq(captures.length, 2)
        assert_eq(arguments.length, 1)
        direct_inner_calls += 1
      }
      _ => ()
    }
  }
  assert_eq(direct_inner_calls, 1)
  let inner = collected.lambdas[1]
  let offset_expression = lambda_name_expression(collected, inner, "offset")
  let seed_expression = lambda_name_expression(collected, inner, "seed")
  assert_eq(planned.expressions[offset_expression].kind, PlannedCaptureGet(0))
  assert_eq(planned.expressions[seed_expression].kind, PlannedCaptureGet(1))
}

///|
test "lowering directizes immediate and call-only local lambdas" {
  let (collected, _, _, _, _, planned) = lowering_test_module(
    941UL, b"fn main(seed: I32) -> I32 {\n  let callback = fn(value: I32) -> I32 {\n    value + seed\n  }\n  let first = callback(20)\n  let second = callback(21)\n  first + second + fn(value: I32) -> I32 {\n    value + 1\n  }(0)\n}\n",
  )
  assert_eq(planned.diagnostics.length(), 0)
  assert_eq(planned.lambdas.length(), 2)
  assert_true(planned.lambdas[0].directized)
  assert_true(planned.lambdas[1].directized)
  let mut direct_calls = 0
  let mut closure_constructions = 0
  for
    expression in collected.bodies[0].expressions.start..<(collected.bodies[0].expressions.start +
    collected.bodies[0].expressions.length) {
    match planned.expressions[expression].kind {
      PlannedDirectLambdaCall(_, _, _) => direct_calls += 1
      PlannedLambdaClosure(_, _) => closure_constructions += 1
      _ => ()
    }
  }
  assert_eq(direct_calls, 3)
  assert_eq(closure_constructions, 0)
  let mut elided_lets = 0
  for item in planned.block_items {
    match item.kind {
      PlannedElidedLetItem(_) => elided_lets += 1
      _ => ()
    }
  }
  assert_eq(elided_lets, 1)
}

///|
test "lowering keeps returned and captured function values escaping" {
  let (collected, _, _, _, _, planned) = lowering_test_module(
    942UL, b"fn make(seed: I32) -> fn(I32) -> I32 {\n  let callback = fn(value: I32) -> I32 {\n    value + seed\n  }\n  let wrapper = fn(value: I32) -> I32 {\n    callback(value)\n  }\n  wrapper\n}\n",
  )
  assert_eq(planned.diagnostics.length(), 0)
  assert_false(planned.lambdas[0].directized)
  assert_false(planned.lambdas[1].directized)
  let mut closure_constructions = 0
  for
    expression in collected.bodies[0].expressions.start..<(collected.bodies[0].expressions.start +
    collected.bodies[0].expressions.length) {
    match planned.expressions[expression].kind {
      PlannedLambdaClosure(_, _) => closure_constructions += 1
      _ => ()
    }
  }
  assert_eq(closure_constructions, 2)
}

///|
test "lowering removes call-only named function values" {
  let (collected, _, _, _, _, planned) = lowering_test_module(
    943UL, b"fn increment(value: I32) -> I32 {\n  value + 1\n}\nfn main() -> I32 {\n  let callback = increment\n  callback(41)\n}\n",
  )
  assert_eq(planned.diagnostics.length(), 0)
  let body = collected.bodies[1]
  let mut direct_increment_calls = 0
  let mut function_references = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match planned.expressions[expression].kind {
      PlannedDirectCall(declaration, _, _, _) if declaration ==
        collected.declarations[0].id => direct_increment_calls += 1
      PlannedFunctionReference(_) => function_references += 1
      _ => ()
    }
  }
  assert_eq(direct_increment_calls, 1)
  assert_eq(function_references, 0)
}
