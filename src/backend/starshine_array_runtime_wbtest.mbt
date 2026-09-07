///|
test "removed Array backing builtins report their exact target" {
  for name in [b"dew_array_backing_length_i32", b"dew_array_backing_length_ref"] {
    assert_eq(
      starshine_inline_builtin_instructions(name, -1),
      Err(UnsupportedBuiltin(name)),
    )
  }
}

///|
test "Array literal storage rejects unresolved physical evidence" {
  let stages = backend_test_single_module_stages(
    28113UL, b"open dew.std.array\npub fn run() -> I32 {\n  let values = [1, 2]\n  values[0u32]\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let planned = stages.link.modules[stages.link.root_module_index]
  let shapes : Array[@semantic.PlannedValueShape] = []
  for module_ in stages.lowering.modules {
    for index, type_ in module_.resolved_types {
      match type_ {
        @semantic.ErrorType
        | @semantic.GenericParameterType(_)
        | @semantic.PrimitiveType(@semantic.NeverType) =>
          shapes.push(
            @semantic.planned_value_shape_from_resolved_types(
              module_.resolved_types,
              module_.resolved_type_arguments,
              index,
            ),
          )
        _ => ()
      }
    }
  }
  assert_true(shapes.any(shape => shape is @semantic.GenericPlannedValueShape))
  assert_true(shapes.any(shape => shape is @semantic.ErrorPlannedValueShape))
  assert_true(shapes.any(shape => shape is @semantic.NeverPlannedValueShape))
  for shape in shapes {
    assert_eq(
      starshine_finish_scalar_array_literal(
        planned,
        Some(stages.link),
        0UL,
        shape,
        [],
        -1,
        -1,
      ),
      Err(UnsupportedExpression(0UL, -417)),
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
        assert_eq(
          starshine_array_storage_value_type(expression.shape),
          Some(@lib.ValType::eqref_null()),
        )
      }
    }
  }
  assert_true(found)
}
