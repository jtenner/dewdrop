///|
test "Unit if branches discard call results" {
  let stages = backend_test_single_module_stages(
    28119UL, b"fn yes() -> Bool {\n  true\n}\npub fn run(flag: Bool) -> I32 {\n  if flag {\n    yes()\n  }\n  1\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => fail(@debug.to_string(error))
  }
}

///|
test "folded Unit branches discard selected block results" {
  let stages = backend_test_single_module_stages(
    28120UL, b"open dew.std.types\nfn yes() -> Bool {\n  true\n}\npub fn run() -> I32 {\n  if is_unit::<Unit>() {\n    yes()\n  }\n  1\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => fail(@debug.to_string(error))
  }
}
