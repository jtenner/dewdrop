///|
test "bench core type map groups=512" (it : @bench.T) {
  let groups = Array::make(
    512,
    @lib.RecType::new(@lib.SubType::comp_type(@lib.CompType::struct_([]))),
  )
  let arena = core_type_arena(
    @lib.Module::new().with_type_sec(@lib.TypeSec::new(groups)),
  )
  let guest = core_type_arena(@lib.Module::new())
  let bindings = Array::make(512, -1)
  it.bench(fn() {
    it.keep(core_build_type_maps(arena, guest, bindings, bindings).unwrap())
  })
}

///|
test "bench core type map groups=8192" (it : @bench.T) {
  let groups = Array::make(
    8192,
    @lib.RecType::new(@lib.SubType::comp_type(@lib.CompType::struct_([]))),
  )
  let arena = core_type_arena(
    @lib.Module::new().with_type_sec(@lib.TypeSec::new(groups)),
  )
  let guest = core_type_arena(@lib.Module::new())
  let bindings = Array::make(8192, -1)
  it.bench(fn() {
    it.keep(core_build_type_maps(arena, guest, bindings, bindings).unwrap())
  })
}
