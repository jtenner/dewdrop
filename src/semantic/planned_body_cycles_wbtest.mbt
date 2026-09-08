///|
fn syntax_cycle_test_lowering(source : Bytes) -> PlannedModuleLowering raise {
  let program = compiler_test_single_module_program(6046UL, source)
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  assert_eq(lowering.modules[0].diagnostics.length(), 0)
  lowering.modules[0]
}

///|
test "physical syntax accepts shared children and loop control" {
  let lowering = syntax_cycle_test_lowering(
    b"pub fn run(value: I64) -> I64 {\n  value + value\n}\n",
  )
  let body = lowering.bodies[0]
  assert_eq(body.expressions.length, 3)
  lowering.expressions[2] = {
    ..lowering.expressions[2],
    kind: PlannedBinaryExpression(HirAdd, 0, 0),
  }
  assert_eq(check_planned_body_arenas(lowering, body, 7), Ok(()))
  // Both edges are pending when node zero enters. Node one also reaches node
  // two, so the duplicate pending event must become a harmless done-node visit.
  let leaf = lowering.expressions[0]
  lowering.expressions[0] = {
    ..leaf,
    kind: PlannedBinaryExpression(HirAdd, 2, 1),
  }
  lowering.expressions[1] = {
    ..lowering.expressions[1],
    kind: PlannedPrefixExpression(HirNegative, 2),
  }
  lowering.expressions[2] = leaf
  assert_eq(check_planned_body_arenas(lowering, body, 7), Ok(()))
  let loops = syntax_cycle_test_lowering(
    b"pub fn run() -> I64 {\n  while 0i64 {\n    value if value < 3i64 => continue value + 1i64\n    value => break value\n  }\n}\n",
  )
  assert_eq(check_planned_body_arenas(loops, loops.bodies[0], 7), Ok(()))
}

///|
test "physical syntax rejects a two-expression cycle" {
  let lowering = syntax_cycle_test_lowering(
    b"pub fn run(value: I64) -> I64 {\n  value + value\n}\n",
  )
  let body = lowering.bodies[0]
  lowering.expressions[0] = {
    ..lowering.expressions[0],
    kind: PlannedPrefixExpression(HirNegative, 1),
  }
  lowering.expressions[1] = {
    ..lowering.expressions[1],
    kind: PlannedPrefixExpression(HirNegative, 0),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err({
      code: 108,
      phase: 7,
      module_id: lowering.module_id,
      declaration: body.declaration,
      body: body.body,
      expression: 1U,
      expected: 0UL,
      actual: 1UL,
      detail: 1UL << 32,
    }),
  )
}

///|
test "physical syntax rejects a pattern cycle" {
  let lowering = syntax_cycle_test_lowering(
    b"pub fn run(value: I64) -> I64 {\n  match value {\n    _ => value\n  }\n}\n",
  )
  let body = lowering.bodies[0]
  let pattern = body.patterns.start
  lowering.patterns[pattern] = {
    ..lowering.patterns[pattern],
    source: HirQualifiedPattern(pattern, 0, 0UL),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err({
      code: 108,
      phase: 7,
      module_id: lowering.module_id,
      declaration: body.declaration,
      body: body.body,
      expression: 0xffffffffU,
      expected: 0UL,
      actual: 1UL,
      detail: (4UL << 32) | pattern.to_uint64(),
    }),
  )
}

///|
test "physical syntax walks a long chain without a depth limit" {
  let lowering = syntax_cycle_test_lowering(
    b"pub fn run(value: I64) -> I64 {\n  value\n}\n",
  )
  let body = lowering.bodies[0]
  assert_eq(lowering.expressions.length(), 1)
  let leaf = lowering.expressions[0]
  for index in 0..<5000 {
    lowering.expressions[index] = {
      ..leaf,
      kind: PlannedPrefixExpression(HirNegative, index + 1),
    }
    lowering.expressions.push(leaf)
  }
  assert_eq(
    check_planned_body_arenas(
      lowering,
      { ..body, expressions: { start: 0, length: 5001, }, },
      7,
    ),
    Ok(()),
  )
}

///|
test "physical body rejects a self-referential expression before emission" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[1]
  let expression = body.expressions.start
  assert_eq(check_planned_body_arenas(lowering, body, 7), Ok(()))
  lowering.expressions[expression] = {
    ..lowering.expressions[expression],
    kind: PlannedPrefixExpression(HirNegative, expression),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err({
      code: 108,
      phase: 7,
      module_id: lowering.module_id,
      declaration: body.declaration,
      body: body.body,
      expression: expression.reinterpret_as_uint(),
      expected: 0UL,
      actual: 1UL,
      detail: (1UL << 32) | expression.to_uint64(),
    }),
  )
}

///|
test "physical body rejects a block-expression cycle before emission" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[1]
  let expression = body.expressions.start
  lowering.expressions[expression] = {
    ..lowering.expressions[expression],
    kind: PlannedBlockExpression(body.blocks.start),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err({
      code: 108,
      phase: 7,
      module_id: lowering.module_id,
      declaration: body.declaration,
      body: body.body,
      expression: expression.reinterpret_as_uint(),
      expected: 0UL,
      actual: 1UL,
      detail: (1UL << 32) | expression.to_uint64(),
    }),
  )
}
