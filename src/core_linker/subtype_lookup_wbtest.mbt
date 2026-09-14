///|
test "subtype presence matches the old scan for absolute relative and invalid supers" {
  let empty = @lib.CompType::struct_([])
  let types = [
    @lib.SubType::new(false, [], empty),
    @lib.SubType::new(false, [@lib.TypeIdx::new(0U)], empty),
    @lib.SubType::new(true, [@lib.TypeIdx::new(1U)], empty),
    @lib.SubType::comp_type(empty),
    @lib.SubType::comp_type(@lib.CompType::func([], [])),
    @lib.SubType::new(true, [@lib.TypeIdx::rec(3U)], empty),
    @lib.SubType::new(true, [@lib.TypeIdx::new(99U)], empty),
  ]
  let arena = core_type_arena(
    @lib.Module::new().with_type_sec(
      @lib.TypeSec::new([@lib.RecType::group(types)]),
    ),
  )
  for index in 0..<types.length() {
    let mut old = false
    for subtype in types {
      for super_ in subtype.super_types() {
        if core_type_index(super_) == Some(index) {
          old = true
        }
      }
    }
    assert_eq(core_type_has_declared_subtype(arena, index), old)
  }
  assert_false(core_empty_struct_marker(arena, 0))
  assert_false(core_empty_struct_marker(arena, 1))
  assert_true(core_empty_struct_marker(arena, 2))
  assert_true(core_empty_struct_marker(arena, 3))
  assert_false(core_empty_struct_marker(arena, 4))
  assert_false(core_empty_struct_marker(arena, -1))
  assert_false(core_empty_struct_marker(arena, 99))
}
