///|
test "generic mutable capture reads reserve selected product scratch" {
  let stages = backend_test_single_module_stages(
    28135UL, b"pub fn mutable_select<t>(first: t, second: t) -> t {\n  let mut item = first\n  let update = fn() -> t {\n    item = second\n    item\n  }\n  item = first\n  let _ = update()\n  item\n}\npub fn scalar(value: I64) -> I64 {\n  mutable_select(0i64, value)\n}\npub fn unit(value: I64) -> I64 {\n  mutable_select((), ())\n  value\n}\npub fn product(value: I64) -> I64 {\n  let (selected, (effect, tag)) = mutable_select((0i64, ((), 0i32)), (value, ((), 7i32)))\n  let _ = effect\n  if tag == 7i32 {\n    selected\n  } else {\n    0i64\n  }\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let module_ = match
    emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => module_
    Err(error) => fail(@debug.to_string(error))
  }
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "escaping generic capture reads reserve selected product scratch" {
  let stages = backend_test_single_module_stages(
    28136UL, b"fn reader<t>(value: t) -> fn() -> t {\n  fn() -> t {\n    value\n  }\n}\npub fn run(value: I64) -> (I64, (Unit, I32)) {\n  let read = reader((value, ((), 7i32)))\n  read()\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let module_ = match
    emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => module_
    Err(error) => fail(@debug.to_string(error))
  }
  assert_eq(@validate.validate_module(module_), Ok(()))
}
