///|
test "relative expression IDs must belong to the selected body" {
  let collected = collect_bytes(
    6042UL, b"fn first() -> I32 {\n  1\n}\nfn second() -> I32 {\n  2\n}\n",
  )
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(collected.bodies.length(), 2)
  let first = collected.bodies[0]
  let second = collected.bodies[1]
  assert_eq(check_body_owned_spans(collected, second, 2), Ok(()))
  assert_eq(
    check_body_relative_index(
      collected,
      second,
      BodyExpressions,
      second.expressions.start,
      2,
    ),
    Ok(0),
  )
  let other = first.expressions.start
  assert_eq(
    check_body_relative_index(collected, second, BodyExpressions, other, 2),
    Err({
      code: 102,
      phase: 2,
      module_id: 6042UL,
      declaration: second.declaration,
      body: second.id,
      expression: other.reinterpret_as_uint(),
      expected: second.expressions.length.to_uint64(),
      actual: other.to_uint64(),
      detail: second.expressions.start.to_uint64(),
    }),
  )
}

///|
test "owned body spans reject machine-boundary mutations before allocation" {
  let collected = collect_bytes(6043UL, b"fn run() -> I32 {\n  1\n}\n")
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(collected.bodies.length(), 1)
  let body = collected.bodies[0]
  let invalid = { ..body, expressions: { start: 2147483647, length: 1, }, }
  assert_eq(
    check_body_owned_spans(collected, invalid, 1),
    Err({
      code: 101,
      phase: 1,
      module_id: 6043UL,
      declaration: body.declaration,
      body: body.id,
      expression: 0xffffffffU,
      expected: collected.expressions.length().to_uint64(),
      actual: 2147483647UL,
      detail: 1UL,
    }),
  )
  let invalid = { ..body, pattern_fields: { start: 0, length: 1, }, }
  assert_eq(
    check_body_owned_spans(collected, invalid, 3),
    Err({
      code: 101,
      phase: 3,
      module_id: 6043UL,
      declaration: body.declaration,
      body: body.id,
      expression: 0xffffffffU,
      expected: 0UL,
      actual: 0UL,
      detail: (9UL << 32) | 1UL,
    }),
  )
  assert_eq(check_body_owned_spans(collected, body, 3), Ok(()))
}
