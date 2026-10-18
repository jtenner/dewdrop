///|
test "product match subjects demand their scalar boxes" {
  let stages = backend_test_single_module_stages(
    28120UL, b"pub fn pair(a: Bool, b: Bool) -> I32 {\n  match (a, b) {\n    (true, _) => 10\n    (_, true) => 20\n    _ => 30\n  }\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_true(stages.link.erased_box_type_indices[0] >= 0)
  for slot in 1..<5 {
    assert_eq(stages.link.erased_box_type_indices[slot], -1)
  }
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "wildcard product matches demand only their actual leaf carriers" {
  let stages = backend_test_single_module_stages(
    28121UL, b"pub fn discard(a: F32, b: F64, c: V128) -> I32 {\n  match (a, b, c) {\n    _ => 7\n  }\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  for slot in 0..<5 {
    if slot >= 2 {
      assert_true(stages.link.erased_box_type_indices[slot] >= 0)
    } else {
      assert_eq(stages.link.erased_box_type_indices[slot], -1)
    }
  }
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "functional product loops demand their scalar boxes" {
  let stages = backend_test_single_module_stages(
    28122UL, b"pub fn loop_pair(a: I32, b: I64) -> I64 {\n  while (a, b) {\n    (0, _) => break b\n    _ => break b\n  }\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  for slot in 0..<5 {
    if slot < 2 {
      assert_true(stages.link.erased_box_type_indices[slot] >= 0)
    } else {
      assert_eq(stages.link.erased_box_type_indices[slot], -1)
    }
  }
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}
