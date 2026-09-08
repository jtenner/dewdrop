///|
fn fragment_payload_test_layouts() -> PlannedModuleTypeLayouts raise {
  let lowering = syntax_cycle_test_lowering(
    b"pub enum Choice {\n  One(I64)\n  Two(I32)\n}\npub fn run(value: Choice) -> I32 {\n  1\n}\n",
  )
  assert_eq(lowering.type_layouts.payload_types.length(), 2)
  assert_eq(lowering.type_layouts.payload_shapes.length(), 2)
  lowering.type_layouts
}

///|
test "fragment payload indices preserve ownership and machine bounds" {
  let layouts = fragment_payload_test_layouts()
  let owner = layouts.variants[0].variant
  assert_eq(
    check_fragment_payload_index(layouts, owner, { start: 0, length: 1, }, 0),
    Ok(0),
  )
  assert_eq(
    check_fragment_payload_index(
      layouts,
      layouts.variants[1].variant,
      { start: 1, length: 1, },
      0,
    ),
    Ok(1),
  )
  let cases = [
    (403, { start: 0, length: 1, }, 1, 1UL, 1UL, 0UL),
    (403, { start: 0, length: 1, }, -1, 1UL, 4294967295UL, 0UL),
    (403, { start: 1, length: 0, }, 0, 0UL, 0UL, 1UL),
    (
      101,
      { start: 2147483647, length: 2, },
      1,
      2UL,
      2UL,
      (1UL << 32) | 2147483647UL,
    ),
    (101, { start: -1, length: 1, }, 0, 2UL, 1UL, (1UL << 32) | 4294967295UL),
    (101, { start: 0, length: -1, }, 0, 2UL, 4294967295UL, 1UL << 32),
  ]
  for entry in cases {
    let (code, payload, index, expected, actual, detail) = entry
    assert_eq(
      check_fragment_payload_index(layouts, owner, payload, index),
      Err({
        code,
        phase: 4,
        module_id: layouts.module_id,
        declaration: owner,
        body: 0UL,
        expression: 0xffffffffU,
        expected,
        actual,
        detail,
      }),
    )
  }
}

///|
test "fragment payload type and shape arrays are parallel before reads" {
  let layouts = fragment_payload_test_layouts()
  let owner = layouts.variants[0].variant
  ignore(layouts.payload_shapes.pop())
  assert_eq(
    check_fragment_payload_index(layouts, owner, { start: 0, length: 1, }, 0),
    Err({
      code: 103,
      phase: 4,
      module_id: layouts.module_id,
      declaration: owner,
      body: 0UL,
      expression: 0xffffffffU,
      expected: 2UL,
      actual: 1UL,
      detail: 1UL,
    }),
  )
}
