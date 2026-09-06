///|
test "Unit field reads preserve receivers without a physical field" {
  let stages = backend_test_single_module_stages(
    28117UL, b"struct Slot<t> {\n  value: t\n}\nfn read<t>(slot: Slot<t>) -> t {\n  slot.value\n}\npub fn run() -> Unit {\n  read(Slot::{\n    value: ()\n  })\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(_) => ()
    Err(error) => fail(@debug.to_string(error))
  }
}
