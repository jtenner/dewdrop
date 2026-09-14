///|
test "bench marker subtype checks types=512" (it : @bench.T) {
  let groups = Array::make(
    512,
    @lib.RecType::new(@lib.SubType::comp_type(@lib.CompType::struct_([]))),
  )
  let arena = core_type_arena(
    @lib.Module::new().with_type_sec(@lib.TypeSec::new(groups)),
  )
  it.bench(fn() {
    for index in 0..<512 {
      it.keep(core_empty_struct_marker(arena, index))
    }
  })
}

///|
test "bench marker subtype checks types=4096" (it : @bench.T) {
  let groups = Array::make(
    4096,
    @lib.RecType::new(@lib.SubType::comp_type(@lib.CompType::struct_([]))),
  )
  let arena = core_type_arena(
    @lib.Module::new().with_type_sec(@lib.TypeSec::new(groups)),
  )
  it.bench(fn() {
    for index in 0..<4096 {
      it.keep(core_empty_struct_marker(arena, index))
    }
  })
}
