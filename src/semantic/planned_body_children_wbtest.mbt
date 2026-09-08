///|
fn planned_child_test_failure(
  body : PlannedBodyLowering,
  expression : Int,
  span : HirSpan,
  child : Int,
  tag : Int,
) -> BodyArenaFailure {
  {
    code: 104,
    phase: 7,
    module_id: 6046UL,
    declaration: body.declaration,
    body: body.body,
    expression: expression.reinterpret_as_uint(),
    expected: span.start.to_uint64(),
    actual: child.reinterpret_as_uint().to_uint64(),
    detail: (tag.to_uint64() << 32) | span.length.to_uint64(),
  }
}

///|
test "lowered unary operands must belong to their physical body" {
  for child in [0, -1, 2147483647] {
    let lowering = planned_body_arena_test_lowering()
    let body = lowering.bodies[1]
    let expression = body.expressions.start
    assert_eq(check_planned_body_arenas(lowering, body, 7), Ok(()))
    lowering.expressions[expression] = {
      ..lowering.expressions[expression],
      kind: PlannedPrefixExpression(HirNegative, child),
    }
    assert_eq(
      check_planned_body_arenas(lowering, body, 7),
      Err(
        planned_child_test_failure(body, expression, body.expressions, child, 1),
      ),
    )
  }
}

///|
test "only the exact missing sentinel can erase an optional return operand" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[1]
  let expression = body.expressions.start
  lowering.expressions[expression] = {
    ..lowering.expressions[expression],
    kind: PlannedReturnExpression(-2),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err(planned_child_test_failure(body, expression, body.expressions, -2, 1)),
  )
}

///|
test "lowered local reads cannot use a missing logical local" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[1]
  let expression = body.expressions.start
  lowering.expressions[expression] = {
    ..lowering.expressions[expression],
    kind: PlannedLocalGet(body.locals.length),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err(
      planned_child_test_failure(
        body,
        expression,
        { start: 0, length: body.locals.length, },
        body.locals.length,
        2,
      ),
    ),
  )
}

///|
test "lowered block expressions cannot select another body block" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[1]
  let expression = body.expressions.start
  let other = lowering.bodies[0].blocks.start
  lowering.expressions[expression] = {
    ..lowering.expressions[expression],
    kind: PlannedBlockExpression(other),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err(planned_child_test_failure(body, expression, body.blocks, other, 3)),
  )
}

///|
test "lowered argument spans are checked before list access" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[1]
  let expression = body.expressions.start
  lowering.expressions[expression] = {
    ..lowering.expressions[expression],
    kind: PlannedProductNew({ start: 2147483647, length: 1, }),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err({
      code: 101,
      phase: 7,
      module_id: 6046UL,
      declaration: body.declaration,
      body: body.body,
      expression: expression.reinterpret_as_uint(),
      expected: lowering.expression_children.length().to_uint64(),
      actual: 1UL,
      detail: (10UL << 32) | 2147483647UL,
    }),
  )
}

///|
test "an in-range argument list cannot name another body expression" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[1]
  let expression = body.expressions.start
  let other = lowering.bodies[0].expressions.start
  let start = lowering.expression_children.length()
  lowering.expression_children.push(other)
  lowering.expressions[expression] = {
    ..lowering.expressions[expression],
    kind: PlannedProductNew({ start, length: 1, }),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err(
      planned_child_test_failure(body, expression, body.expressions, other, 1),
    ),
  )
}

///|
test "lowered block item spans are checked before list access" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[1]
  let block = body.blocks.start
  lowering.blocks[block] = {
    ..lowering.blocks[block],
    items: { start: 2147483647, length: 1, },
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err({
      code: 101,
      phase: 7,
      module_id: 6046UL,
      declaration: body.declaration,
      body: body.body,
      expression: 0xffffffffU,
      expected: lowering.block_items.length().to_uint64(),
      actual: 1UL,
      detail: (11UL << 32) | 2147483647UL,
    }),
  )
}
