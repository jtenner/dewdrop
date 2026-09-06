///|
test "reference field writes restore the declared heap type from raw storage" {
  let stages = backend_test_single_module_stages(
    28119UL, b"struct Storage<t> {}\nbuiltin make<t>(length: U32, item: t) -> Storage<t> = \"array.new\"\nbuiltin get<t>(storage: Storage<t>, index: U32) -> t = \"array.get\"\nstruct Item {\n  value: I32\n}\nstruct Owner {\n  mut item: Item\n}\npub fn run() -> I32 {\n  let first = Item::{\n    value: 1i32\n  }\n  let owner = Owner::{\n    item: first\n  }\n  let values = make(1u32, Item::{\n    value: 2i32\n  })\n  owner.item = get(values, 0u32)\n  owner.item.value\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_binary(stages.lowering, stages.link) {
    Ok(_) => ()
    Err(error) => fail(@debug.to_string(error))
  }
}
