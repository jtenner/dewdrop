///|
test "generic calls specialize tuple-valued type arguments recursively" {
  let stages = backend_test_single_module_stages(
    28113UL,
    b"open dew.std.array\nfn repeat<t>(value: t) -> Array<(t, t)> {\n  let values = Array::with_capacity(1u32)\n  values.push((value, value))\n  values\n}\npub fn run() -> (I32, I32) {\n  repeat(21i32)[0u32]\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => fail(@debug.to_string(error))
  }
}
