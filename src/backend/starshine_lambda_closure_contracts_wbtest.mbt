///|
test "lambda closure emission rejects a wrong in-range type in both lanes" {
  let (lowering, link, diagnostics) = backend_packed_primitive_pipeline(
    b"pub fn make(value: I64) -> fn() -> I64 {\n  fn() -> I64 {\n    value\n  }\n}\n",
  )
  assert_eq(diagnostics, 0)
  let module_ = link.modules[0]
  module_.lambda_closure_type_indices[0] = module_.closure_type_index
  let expected = Err(
    CompilerInvariantFailure({
      code: 504U,
      phase: 7U,
      module_id: 2520UL,
      declaration: 0UL,
      body: 0UL,
      expression: 0xffffffffU,
      expected: 0UL,
      actual: 0xffffffffUL,
      detail: 101UL << 32,
    }),
  )
  assert_eq(emit_starshine_program_module(lowering, link), expected)
  assert_eq(emit_starshine_module(lowering.modules[0], module_), expected)
}

///|
test "lambda closure emission rejects a changed in-range capture field" {
  let (lowering, link, diagnostics) = backend_packed_primitive_pipeline(
    b"pub fn make(left: I64, right: I64) -> fn() -> I64 {\n  fn() -> I64 {\n    left - right\n  }\n}\n",
  )
  assert_eq(diagnostics, 0)
  let module_ = link.modules[0]
  module_.lambda_capture_field_indices[0] = 2
  let expected = Err(
    CompilerInvariantFailure({
      code: 504U,
      phase: 7U,
      module_id: 2520UL,
      declaration: 0UL,
      body: 0UL,
      expression: 0xffffffffU,
      expected: 1UL,
      actual: 2UL,
      detail: 114UL << 32,
    }),
  )
  assert_eq(emit_starshine_program_module(lowering, link), expected)
  assert_eq(emit_starshine_module(lowering.modules[0], module_), expected)
}

///|
test "lambda closure emission retains public generic erased and selected layouts" {
  for
    source in [
      b"pub fn choose<t>(value: t) -> t {\n  let mut held = value\n  let read = fn() -> t {\n    held = value\n    held\n  }\n  read()\n}\npub fn right(value: I64) -> I64 {\n  choose(value)\n}\npub fn erased() -> Unit {\n  choose(())\n}\n",
      b"pub fn make<t>(value: t) -> fn() -> t {\n  fn() -> t {\n    value\n  }\n}\npub fn right(value: I64) -> fn() -> I64 {\n  make(value)\n}\npub fn erased() -> fn() -> Unit {\n  make(())\n}\n",
    ] {
    let stages = backend_test_single_module_stages(28161UL, source)
    assert_eq(stages.diagnostic_count(), 0)
    assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
  }
}
