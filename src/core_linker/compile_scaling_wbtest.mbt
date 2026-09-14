///|
test "type map cursor covers empty recursive and bound groups" {
  let subtype = @lib.SubType::comp_type(@lib.CompType::struct_([]))
  let arena = core_type_arena(
    @lib.Module::new().with_type_sec(
      @lib.TypeSec::new([
        @lib.RecType::group([]),
        @lib.RecType::new(subtype),
        @lib.RecType::group([subtype, subtype]),
        @lib.RecType::group([]),
        @lib.RecType::new(subtype),
      ]),
    ),
  )
  let guest = core_type_arena(
    @lib.Module::new().with_type_sec(
      @lib.TypeSec::new([@lib.RecType::new(subtype)]),
    ),
  )
  let none = [-1, -1, -1, -1]
  assert_eq(
    core_build_type_maps(arena, guest, none, none).unwrap(),
    ([1, 2, 3, 4], [0], [false, false, false, false, false], 5),
  )
  assert_eq(
    core_build_type_maps(arena, guest, [0, -1, -1, -1], [-1, -1, -1, 0]).unwrap(),
    ([0, 1, 2, 0], [0], [false, true, false, false, true], 3),
  )
  assert_eq(
    core_build_type_maps(arena, guest, [-1, 0, -1, -1], none),
    Err(CoreWasmInvalidMarkerGroup(2)),
  )
}
