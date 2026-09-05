///|
test "inferred Unit enum arguments create an erased payload layout" {
  let stages = backend_test_single_module_stages(
    29311UL, b"enum Choice<t> {\n  Empty\n  Present(t)\n}\npub fn run() -> I32 {\n  let value = Choice::Present(())\n  match value {\n    Choice::Present(_) => 1i32\n    Choice::Empty => 0i32\n  }\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}
