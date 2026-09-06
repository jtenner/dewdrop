///|
test "removed array emitter operations report an exact diagnostic" {
  let stages = backend_test_single_module_stages(
    28113UL, b"open dew.std.array\npub fn run() -> I32 {\n  let values = [1, 2]\n  values[0u32]\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let planned = stages.link.modules[stages.link.root_module_index]
  for
    operation in [
      1, 2, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 20, 21, 39, 40, 41, 42, 43, 44, 45,
      46, 47, 49,
    ] {
    assert_eq(
      starshine_finish_array(
        planned,
        Some(stages.link),
        0UL,
        operation,
        None,
        [],
        -1,
        -1,
        -1,
        -1,
      ),
      Err(UnsupportedExpression(0UL, -409)),
    )
  }
}

///|
test "product array elements use reference storage" {
  let stages = backend_test_single_module_stages(
    28115UL, b"pub fn run() -> (I32, I64) {\n  (1, 2L)\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let mut found = false
  for module_ in stages.lowering.modules {
    for expression in module_.expressions {
      if expression.shape is @semantic.ProductPlannedValueShape(_) {
        found = true
        assert_true(
          starshine_array_shape_uses_reference_storage(expression.shape),
        )
      }
    }
  }
  assert_true(found)
}
