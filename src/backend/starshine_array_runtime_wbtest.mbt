///|
test "removed array emitter operations report an exact diagnostic" {
  let stages = backend_test_single_module_stages(
    28113UL, b"open dew.std.array\npub fn run() -> I32 {\n  let values = [1, 2]\n  values[0u32]\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let planned = stages.link.modules[stages.link.root_module_index]
  for operation in 0..<50 {
    if operation == 48 {
      continue
    }
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
test "circular buffers emit without an Array literal or legacy wrapper" {
  let stages = backend_test_single_module_stages(
    28116UL, b"open dew.std.collections.circular_buffer\npub fn run() -> I64 {\n  let fixed = circular_buffer_bounded(2u32)\n  let grown = circular_buffer_growable(2u32)\n  circular_buffer_push_back(fixed, 7i64)\n  circular_buffer_push_back(grown, 9i64)\n  match circular_buffer_pop_front(grown) {\n    Option::Some(value) => value\n    Option::None => 0i64\n  }\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(_) => ()
    Err(error) => fail(@debug.to_string(error))
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
