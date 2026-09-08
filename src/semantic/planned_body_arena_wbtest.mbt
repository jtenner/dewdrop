///|
fn planned_body_arena_test_lowering() -> PlannedModuleLowering raise {
  let program = compiler_test_single_module_program(
    6046UL, b"pub fn first(value: I64) -> I64 {\n  value\n}\npub fn second(value: I64) -> I64 {\n  value\n}\npub fn maker() -> fn(I64) -> I64 {\n  fn(value: I64) -> I64 {\n    value\n  }\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  assert_eq(lowering.modules[0].diagnostics.length(), 0)
  lowering.modules[0]
}

///|
test "native physical body arenas accept named and lambda bodies" {
  let lowering = planned_body_arena_test_lowering()
  for body in lowering.bodies {
    assert_eq(check_planned_body_arenas(lowering, body, 7), Ok(()))
  }
  assert_eq(lowering.lambdas.length(), 1)
  assert_eq(
    check_planned_body_arenas(lowering, lowering.lambda_body(0).unwrap(), 7),
    Ok(()),
  )
}

///|
test "native physical body spans reject overflow before allocation" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[0]
  let invalid : HirSpan = { start: 2147483647, length: 1, }
  let cases = [
    (1, { ..body, expressions: invalid, }, lowering.expressions.length()),
    (2, { ..body, locals: invalid, }, lowering.locals.length()),
    (3, { ..body, blocks: invalid, }, lowering.blocks.length()),
    (4, { ..body, patterns: invalid, }, lowering.patterns.length()),
    (5, { ..body, pattern_arms: invalid, }, lowering.pattern_arms.length()),
  ]
  for entry in cases {
    let (tag, invalid_body, arena_length) = entry
    assert_eq(
      check_planned_body_arenas(lowering, invalid_body, 7),
      Err({
        code: 101,
        phase: 7,
        module_id: 6046UL,
        declaration: body.declaration,
        body: body.body,
        expression: 0xffffffffU,
        expected: arena_length.to_uint64(),
        actual: 1UL,
        detail: (tag.to_uint64() << 32) | 2147483647UL,
      }),
    )
  }
}

///|
test "native physical body spans reject negative starts and lengths" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[0]
  let cases : Array[HirSpan] = [
    { start: -1, length: 1, },
    { start: 0, length: -1, },
  ]
  for span in cases {
    assert_eq(
      check_planned_body_arenas(lowering, { ..body, expressions: span, }, 7),
      Err({
        code: 101,
        phase: 7,
        module_id: 6046UL,
        declaration: body.declaration,
        body: body.body,
        expression: 0xffffffffU,
        expected: lowering.expressions.length().to_uint64(),
        actual: span.length.reinterpret_as_uint().to_uint64(),
        detail: (1UL << 32) | span.start.reinterpret_as_uint().to_uint64(),
      }),
    )
  }
}

///|
test "native physical expression roots cannot cross body boundaries" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[1]
  let expression = lowering.bodies[0].expressions.start
  assert_eq(
    check_planned_body_arenas(
      lowering,
      { ..body, root: ExpressionBodyRoot(expression), },
      7,
    ),
    Err({
      code: 102,
      phase: 7,
      module_id: 6046UL,
      declaration: body.declaration,
      body: body.body,
      expression: expression.reinterpret_as_uint(),
      expected: body.expressions.start.to_uint64(),
      actual: expression.to_uint64(),
      detail: (1UL << 32) | body.expressions.length.to_uint64(),
    }),
  )
}

///|
test "native physical block roots cannot cross body boundaries" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[1]
  let block = lowering.bodies[0].blocks.start
  assert_eq(
    check_planned_body_arenas(
      lowering,
      { ..body, root: BlockBodyRoot(block), },
      7,
    ),
    Err({
      code: 102,
      phase: 7,
      module_id: 6046UL,
      declaration: body.declaration,
      body: body.body,
      expression: block.reinterpret_as_uint(),
      expected: body.blocks.start.to_uint64(),
      actual: block.to_uint64(),
      detail: (3UL << 32) | body.blocks.length.to_uint64(),
    }),
  )
}

///|
test "native physical locals retain their stored relative identity" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[1]
  let index = body.locals.start
  lowering.locals[index] = { ..lowering.locals[index], local_id: 1, }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err({
      code: 106,
      phase: 7,
      module_id: 6046UL,
      declaration: body.declaration,
      body: body.body,
      expression: 0xffffffffU,
      expected: 0UL,
      actual: 1UL,
      detail: (2UL << 32) | index.to_uint64(),
    }),
  )
}

///|
test "native physical locals cannot belong to a different body" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[1]
  let other = lowering.bodies[0].body
  let index = body.locals.start
  lowering.locals[index] = { ..lowering.locals[index], body: other, }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err({
      code: 106,
      phase: 7,
      module_id: 6046UL,
      declaration: body.declaration,
      body: body.body,
      expression: 0xffffffffU,
      expected: body.body,
      actual: other,
      detail: (6UL << 32) | index.to_uint64(),
    }),
  )
}
