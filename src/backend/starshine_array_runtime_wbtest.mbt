///|
fn array_runtime_test_marker_count(
  instructions : Array[@lib.Instruction],
  marker : @lib.Instruction,
) -> Int {
  let mut count = 0
  for instruction in instructions {
    if instruction == marker {
      count += 1
    }
  }
  count
}

///|
test "raw bulk array operations emit every operand once" {
  let stages = backend_test_single_module_stages(
    28113UL,
    b"open dew.std.array\npub fn run() -> I32 {\n  let values = [1, 2]\n  values[0u32]\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let planned = stages.link.modules[stages.link.root_module_index]
  let marker = @lib.Instruction::i32_const(@lib.I32::new(5151515))
  let scalar = Some(@semantic.planned_i32_shape())
  let nop = [@lib.Instruction::nop()]
  let zero = [@lib.Instruction::i32_const(@lib.I32::new(0))]

  let copy_within = starshine_finish_array(
    planned,
    Some(stages.link),
    0UL,
    44,
    scalar,
    [nop, zero, [marker], zero],
    0,
    1,
    2,
    3,
  ).unwrap()
  assert_eq(array_runtime_test_marker_count(copy_within, marker), 1)

  let fill = starshine_finish_array(
    planned,
    Some(stages.link),
    0UL,
    45,
    scalar,
    [nop, zero, [marker], zero],
    0,
    1,
    2,
    3,
  ).unwrap()
  assert_eq(array_runtime_test_marker_count(fill, marker), 1)

  let slice = starshine_finish_array(
    planned,
    Some(stages.link),
    0UL,
    46,
    scalar,
    [nop, [marker], zero],
    0,
    1,
    2,
    3,
  ).unwrap()
  assert_eq(array_runtime_test_marker_count(slice, marker), 1)

  let extended = starshine_finish_array(
    planned,
    Some(stages.link),
    0UL,
    47,
    scalar,
    [nop, [marker]],
    0,
    1,
    2,
    3,
  ).unwrap()
  assert_eq(array_runtime_test_marker_count(extended, marker), 1)
}

///|
test "product array elements use reference storage" {
  let stages = backend_test_single_module_stages(
    28115UL,
    b"pub fn run() -> (I32, I64) {\n  (1, 2L)\n}\n",
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
