///|
test "fragment capture metadata accepts valid owned tables" {
  let lowering = planned_capture_test_lowering()
  assert_eq(check_planned_capture_metadata(lowering, 4), Ok(()))
}

///|
test "fragment metadata accepts unresolved generic template carriers" {
  let program = compiler_test_single_module_program(
    6046UL, b"pub fn maker<t>(value: t) -> fn() -> t {\n  fn() -> t {\n    value\n  }\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed).modules[0]
  assert_eq(lowering.captures.length(), 1)
  assert_true(lowering.captures[0].shape is GenericPlannedValueShape)
  assert_eq(check_planned_capture_metadata(lowering, 4), Ok(()))
}

///|
test "fragment metadata rejects a root body from another module" {
  let lowering = planned_capture_test_lowering()
  let owner = 6047UL << 32
  lowering.lambdas[0] = { ..lowering.lambdas[0], root_body: owner, }
  assert_eq(
    check_planned_capture_metadata(lowering, 4),
    Err({
      code: 106,
      phase: 4,
      module_id: 6046UL,
      declaration: 0UL,
      body: owner,
      expression: 0xffffffffU,
      expected: 6046UL,
      actual: 6047UL,
      detail: 21UL << 32,
    }),
  )
}

///|
test "fragment metadata rejects a missing root body before lookup" {
  let lowering = planned_capture_test_lowering()
  let owner = (6046UL << 32) | 2UL
  lowering.lambdas[0] = { ..lowering.lambdas[0], root_body: owner, }
  assert_eq(
    check_planned_capture_metadata(lowering, 4),
    Err({
      code: 104,
      phase: 4,
      module_id: 6046UL,
      declaration: 0UL,
      body: owner,
      expression: 0xffffffffU,
      expected: 2UL,
      actual: 2UL,
      detail: 21UL << 32,
    }),
  )
}

///|
test "fragment metadata rejects a root record with another stored identity" {
  let lowering = planned_capture_test_lowering()
  let owner = lowering.bodies[0].body
  lowering.bodies[0] = { ..lowering.bodies[0], body: owner + 1UL, }
  assert_eq(
    check_planned_capture_metadata(lowering, 4),
    Err({
      code: 106,
      phase: 4,
      module_id: 6046UL,
      declaration: 0UL,
      body: owner,
      expression: 0xffffffffU,
      expected: owner,
      actual: owner + 1UL,
      detail: 21UL << 32,
    }),
  )
}

///|
test "emission metadata reports its actual phase for an orphan capture" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.bodies[0]
  lowering.captures.push(lowering.captures[0])
  assert_eq(
    check_planned_capture_metadata(lowering, 7),
    Err(
      planned_body_arena_failure(
        lowering,
        body,
        7,
        104,
        -1,
        0UL,
        1UL,
        (17UL << 32) | 1UL,
      ),
    ),
  )
}

///|
test "fragment capture metadata rejects an orphan outside an empty span" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.bodies[0]
  lowering.lambdas[0] = {
    ..lowering.lambdas[0],
    captures: { start: 0, length: 0, },
  }
  assert_eq(
    check_planned_capture_metadata(lowering, 4),
    Err(
      planned_body_arena_failure(
        lowering,
        body,
        4,
        104,
        -1,
        0UL,
        0UL,
        17UL << 32,
      ),
    ),
  )
}

///|
test "fragment capture metadata rejects a missing capture owner before lookup" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.bodies[0]
  lowering.captures[0] = { ..lowering.captures[0], lambda: 1, }
  assert_eq(
    check_planned_capture_metadata(lowering, 4),
    Err(
      planned_body_arena_failure(
        lowering,
        body,
        4,
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
test "fragment capture metadata rejects a wrong stored lambda identity" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.bodies[0]
  lowering.lambdas[0] = { ..lowering.lambdas[0], lambda: 1, }
  assert_eq(
    check_planned_capture_metadata(lowering, 4),
    Err(
      planned_body_arena_failure(
        lowering,
        body,
        4,
        106,
        -1,
        0UL,
        1UL,
        16UL << 32,
      ),
    ),
  )
}

///|
test "fragment capture metadata rejects a wrapping capture span" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.bodies[0]
  lowering.lambdas[0] = {
    ..lowering.lambdas[0],
    captures: { start: 2147483647, length: 1, },
  }
  assert_eq(
    check_planned_capture_metadata(lowering, 4),
    Err(
      planned_body_arena_failure(
        lowering,
        body,
        4,
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
test "fragment capture metadata checks source ownership before carriers" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.bodies[0]
  let other = lowering.bodies[1].body
  lowering.captures[0] = {
    ..lowering.captures[0],
    source: BodyLocalCapture(other, 0),
  }
  assert_eq(
    check_planned_capture_metadata(lowering, 4),
    Err(
      planned_body_arena_failure(
        lowering,
        body,
        4,
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
test "fragment capture metadata checks orphan global locals" {
  let lowering = planned_capture_test_lowering()
  let body = lowering.bodies[0]
  let index = lowering.locals.length()
  lowering.locals.push(lowering.locals[0])
  assert_eq(
    check_planned_capture_metadata(lowering, 4),
    Err(
      planned_body_arena_failure(
        lowering,
        body,
        4,
        104,
        -1,
        body.locals.start.to_uint64(),
        index.to_uint64(),
        (2UL << 32) | body.locals.length.to_uint64(),
      ),
    ),
  )
}
