///|
test "diverging let initializers need no physical local" {
  let stages = backend_test_single_module_stages(
    22902UL, b"pub fn run() -> I32 {\n  let _ = while 0u32 {\n    _ => {\n      return 7i32\n    }\n  }\n  0i32\n}\n",
  )
  assert_eq(stages.program.diagnostics.length(), 0)
  assert_eq(stages.analyzed.modules[0].inferred.diagnostics.length(), 0)
  assert_eq(stages.link.diagnostics.length(), 0)
  let mut never_locals = 0
  for local_ in stages.lowering.modules[0].locals {
    if local_.shape is @semantic.NeverPlannedValueShape {
      never_locals += 1
    }
  }
  assert_eq(never_locals, 1)
  let module_ = match
    emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => module_
    Err(error) => fail(@debug.to_string(error))
  }
  assert_eq(@validate.validate_module(module_), Ok(()))
}
