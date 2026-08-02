///|
fn lambda_name_expression(
  collected : CollectedModule,
  lambda : HirLambda,
  spelling : String,
) -> ExprId {
  for
    expression in lambda.body.expressions.start..<(lambda.body.expressions.start +
    lambda.body.expressions.length) {
    match collected.expressions[expression] {
      HirNameExpr(name, _) if collected.name(name) == spelling =>
        return expression
      _ => ()
    }
  }
  abort("lambda name expression was not found")
}

///|
test "lambda names resolve parameters and deterministic mutable captures" {
  let collected = collect_bytes(
    610UL, b"fn make(seed: I32) -> I32 {\n  let mut amount = seed\n  let callback = fn(value: I32) -> I32 {\n    value + amount\n  }\n  0\n}\n",
  )
  let names = resolve_module_names(collected)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(names.lambdas.length(), 1)
  let body = collected.bodies[0]
  let lambda = collected.lambdas[0]
  let info = names.lambda(0).unwrap()
  assert_eq(info.locals.length, 1)
  assert_eq(info.captures.length, 1)
  assert_eq(names.lambda_parameter_locals[lambda.parameters.start], 0)
  let capture = names.lambda_capture(0, 0).unwrap()
  assert_eq(collected.name(capture.name), "amount")
  assert_eq(capture.source, BodyLocalCapture(body.id, 1))
  assert_true(capture.mutable_)
  let parameter_expression = lambda_name_expression(collected, lambda, "value")
  let capture_expression = lambda_name_expression(collected, lambda, "amount")
  assert_eq(
    names.expression_references[parameter_expression],
    LocalNameReference(0),
  )
  assert_eq(
    names.expression_references[capture_expression],
    LambdaCaptureNameReference(0),
  )
}

///|
test "nested lambdas retain exact parent-local and root-local capture sources" {
  let collected = collect_bytes(
    611UL, b"fn make(seed: I32) -> I32 {\n  let outer = fn(offset: I32) -> I32 {\n    let inner = fn(value: I32) -> I32 {\n      value + offset + seed\n    }\n    0\n  }\n  0\n}\n",
  )
  let names = resolve_module_names(collected)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(names.lambdas.length(), 2)
  assert_eq(names.lambda(0).unwrap().captures.length, 1)
  let routed_seed = names.lambda_capture(0, 0).unwrap()
  assert_eq(collected.name(routed_seed.name), "seed")
  assert_eq(routed_seed.source, BodyLocalCapture(collected.bodies[0].id, 0))
  assert_eq(names.lambda(1).unwrap().captures.length, 2)
  let offset_capture = names.lambda_capture(1, 0).unwrap()
  assert_eq(collected.name(offset_capture.name), "offset")
  assert_eq(offset_capture.source, LambdaLocalCapture(0, 0))
  let seed_capture = names.lambda_capture(1, 1).unwrap()
  assert_eq(collected.name(seed_capture.name), "seed")
  assert_eq(seed_capture.source, BodyLocalCapture(collected.bodies[0].id, 0))
}

///|
test "lambda lexical snapshots exclude bindings declared after the expression" {
  let collected = collect_bytes(
    612UL, b"fn make() -> I32 {\n  let callback = fn() -> I32 {\n    later\n  }\n  let later = 1\n  0\n}\n",
  )
  let names = resolve_module_names(collected)
  assert_eq(names.lambdas.length(), 1)
  assert_eq(names.lambda(0).unwrap().captures.length, 0)
  assert_eq(names.diagnostics.length(), 1)
  match names.diagnostics[0] {
    UnknownValueName(name, _, _) => assert_eq(collected.name(name), "later")
    _ => fail("expected unknown lambda value diagnostic")
  }
}
