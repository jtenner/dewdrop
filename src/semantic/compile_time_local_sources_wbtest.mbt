///|
test "query local sources stay inside one body and its lambdas" {
  let collected = collect_bytes(
    60UL, b"fn first() -> fn() -> I32 {\n  let value = 41\n  fn() -> I32 {\n    value + 1\n  }\n}\nfn second() -> I32 {\n  let value = 99\n  value\n}\n",
  )
  let names = resolve_module_names(collected)
  assert_eq(collected.diagnostics, [])
  assert_eq(names.diagnostics, [])
  let first = compile_time_source_local_initializers(
    collected,
    names,
    collected.bodies[0],
  )
  let second = compile_time_source_local_initializers(
    collected,
    names,
    collected.bodies[1],
  )
  assert_eq(first.length(), 1)
  assert_eq(second.length(), 1)
  for expression, initializer in first {
    assert_true(
      names.expression_references[expression] is LambdaCaptureNameReference(_),
    )
    assert_true(collected.expressions[initializer] is HirI32Expr(41UL, _))
    assert_false(second.contains(expression))
  }
  for expression, initializer in second {
    assert_true(
      names.expression_references[expression] is LocalNameReference(_),
    )
    assert_true(collected.expressions[initializer] is HirI32Expr(99UL, _))
    assert_false(first.contains(expression))
  }
}

///|
test "query local sources exclude mutable captures" {
  let collected = collect_bytes(
    61UL, b"fn make() -> fn() -> I32 {\n  let mut value = 41\n  fn() -> I32 {\n    value = value + 1\n    value\n  }\n}\n",
  )
  let names = resolve_module_names(collected)
  assert_eq(collected.diagnostics, [])
  assert_eq(names.diagnostics, [])
  assert_eq(
    compile_time_source_local_initializers(
      collected,
      names,
      collected.bodies[0],
    ).length(),
    0,
  )
}
