///|
fn planned_child_list_fixture() -> PlannedModuleLowering raise {
  let program = compiler_test_single_module_program(
    6046UL, b"struct Wrap {\n  value: I64\n}\nenum Choice {\n  Value(I64)\n}\npub fn first(value: I64) -> I64 {\n  value\n}\npub fn make(value: I64) -> Wrap {\n  Wrap::{\n    value: value\n  }\n}\npub fn read(value: Wrap) -> I64 {\n  match value {\n    Wrap {\n      value: found\n    } => found\n  }\n}\npub fn unpack(value: Choice) -> I64 {\n  match value {\n    Choice::Value(found) => found\n  }\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  let program_lowering = plan_program_lowering(program, analyzed)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = program_lowering.modules[0]
  assert_eq(lowering.diagnostics.length(), 0)
  assert_eq(lowering.bodies.length(), 4)
  for body in lowering.bodies {
    assert_eq(check_planned_body_arenas(lowering, body, 7), Ok(()))
  }
  lowering
}

///|
fn planned_child_constructor(
  lowering : PlannedModuleLowering,
  body : PlannedBodyLowering,
) -> (Int, HirSpan) raise {
  for
    index in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    if lowering.expressions[index].kind is PlannedStructNew(_, _, fields) {
      return (index, fields)
    }
  }
  fail("fixture must contain a struct construction")
}

///|
test "lowered constructor fields cannot borrow another body value" {
  let lowering = planned_child_list_fixture()
  let body = lowering.bodies[1]
  let (expression, fields) = planned_child_constructor(lowering, body)
  assert_eq(fields.length, 1)
  let child = lowering.bodies[0].expressions.start
  lowering.object_fields[fields.start] = {
    ..lowering.object_fields[fields.start],
    value: child,
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err(
      planned_child_test_failure(body, expression, body.expressions, child, 1),
    ),
  )
}

///|
test "lowered constructor field spans are checked before access" {
  let lowering = planned_child_list_fixture()
  let body = lowering.bodies[1]
  let (expression, _) = planned_child_constructor(lowering, body)
  let source = lowering.expressions[expression]
  guard source.kind is PlannedStructNew(declaration, types, _) else {
    fail("struct constructor")
  }
  lowering.expressions[expression] = {
    ..source,
    kind: PlannedStructNew(declaration, types, { start: 2147483647, length: 1, }),
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
      expected: lowering.object_fields.length().to_uint64(),
      actual: 1UL,
      detail: (12UL << 32) | 2147483647UL,
    }),
  )
}

///|
test "lowered match arm lists cannot select another body arm" {
  let lowering = planned_child_list_fixture()
  let body = lowering.bodies[3]
  let mut selected = None
  for
    index in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    if lowering.expressions[index].kind is PlannedMatchExpression(_, arms) {
      selected = Some((index, arms))
    }
  }
  let (expression, arms) = selected.unwrap()
  assert_eq(arms.length, 1)
  let other = lowering.bodies[2].pattern_arms.start
  lowering.arm_children[arms.start] = other
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err(
      planned_child_test_failure(body, expression, body.pattern_arms, other, 5),
    ),
  )
}

///|
test "lowered arm guards must belong to their body" {
  let lowering = planned_child_list_fixture()
  let body = lowering.bodies[3]
  let arm = body.pattern_arms.start
  let other = lowering.bodies[0].expressions.start
  lowering.pattern_arms[arm] = {
    ..lowering.pattern_arms[arm],
    guard_condition: other,
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err(planned_child_test_failure(body, -1, body.expressions, other, 1)),
  )
}

///|
test "lowered tuple pattern children retain body ownership" {
  let lowering = planned_child_list_fixture()
  let body = lowering.bodies[3]
  let mut selected = None
  for
    index in body.patterns.start..<(body.patterns.start + body.patterns.length) {
    if lowering.patterns[index].source is HirTuplePattern(_, children, _) {
      selected = Some(children)
    }
  }
  let children = selected.unwrap()
  assert_eq(children.length, 1)
  let other = lowering.bodies[2].patterns.start
  lowering.pattern_children[children.start] = other
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err(planned_child_test_failure(body, -1, body.patterns, other, 4)),
  )
}

///|
test "lowered struct pattern field spans are checked before access" {
  let lowering = planned_child_list_fixture()
  let body = lowering.bodies[2]
  let mut changed = false
  for
    index in body.patterns.start..<(body.patterns.start + body.patterns.length) {
    let pattern = lowering.patterns[index]
    if pattern.source is HirStructPattern(base, _, rest, rest_offset, offset) {
      lowering.patterns[index] = {
        ..pattern,
        source: HirStructPattern(
          base,
          { start: 2147483647, length: 1, },
          rest,
          rest_offset,
          offset,
        ),
      }
      changed = true
    }
  }
  assert_true(changed)
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err({
      code: 101,
      phase: 7,
      module_id: 6046UL,
      declaration: body.declaration,
      body: body.body,
      expression: 0xffffffffU,
      expected: lowering.pattern_fields.length().to_uint64(),
      actual: 1UL,
      detail: (15UL << 32) | 2147483647UL,
    }),
  )
}

///|
test "lowered closure capture spans cannot exceed the arena" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[2]
  let expression = body.expressions.start
  let source = lowering.expressions[expression]
  guard source.kind is PlannedLambdaClosure(lambda, _) else {
    fail("closure fixture")
  }
  lowering.expressions[expression] = {
    ..source,
    kind: PlannedLambdaClosure(lambda, { start: 2147483647, length: 1, }),
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
      expected: lowering.captures.length().to_uint64(),
      actual: 1UL,
      detail: (17UL << 32) | 2147483647UL,
    }),
  )
}

///|
test "lowered closures require a present lambda" {
  let lowering = planned_body_arena_test_lowering()
  let body = lowering.bodies[2]
  let expression = body.expressions.start
  let source = lowering.expressions[expression]
  guard source.kind is PlannedLambdaClosure(_, captures) else {
    fail("closure fixture")
  }
  lowering.expressions[expression] = {
    ..source,
    kind: PlannedLambdaClosure(-1, captures),
  }
  assert_eq(
    check_planned_body_arenas(lowering, body, 7),
    Err(
      planned_child_test_failure(
        body,
        expression,
        { start: 0, length: lowering.lambdas.length(), },
        -1,
        16,
      ),
    ),
  )
}
