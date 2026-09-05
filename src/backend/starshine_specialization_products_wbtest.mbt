///|
test "generic function references retain concrete product signatures" {
  let stages = backend_test_single_module_stages(
    28125UL, b"fn identity<t>(value: t) -> t {\n  value\n}\nfn reader<t>() -> fn(t) -> t {\n  identity\n}\npub fn run(left: I32, right: I64) -> I64 {\n  let callback = reader::<(I32, I64)>()\n  let (_, selected) = callback((left, right))\n  selected\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let module_ = match
    emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(value) => value
    Err(error) => {
      debug_inspect(error)
      fail("callback emission failed")
    }
  }
  assert_eq(@validate.validate_module(module_), Ok(()))
}
