///|
fn backend_lambda_function_lookup_stages() -> (
  @semantic.PlannedProgramLowering,
  @semantic.PlannedProgramWasmGCLink,
) raise {
  let (lowering, link, diagnostics) = backend_packed_primitive_pipeline(
    b"pub fn make(flag: Bool) -> fn() -> I32 {\n  if flag {\n    fn() -> I32 {\n      1\n    }\n  } else {\n    fn() -> I32 {\n      2\n    }\n  }\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_eq(
    @validate.validate_module(
      emit_starshine_program_module(lowering, link).unwrap(),
    ),
    Ok(()),
  )
  (lowering, link)
}

///|
fn backend_lambda_function_lookup_failure(
  code : UInt32,
  expected : UInt64,
  actual : UInt64,
  role : UInt64,
  slot : Int32,
) -> StarshineCodeEmissionError {
  CompilerInvariantFailure({
    code,
    phase: 7U,
    module_id: 2520UL,
    declaration: 0UL,
    body: 0UL,
    expression: 0xffffffffU,
    expected,
    actual,
    detail: (role << 32) | slot.reinterpret_as_uint().to_uint64(),
  })
}

///|
test "emission rejects another valid same-signature lambda function lookup" {
  let (lowering, link) = backend_lambda_function_lookup_stages()
  let module_ = link.modules[0]
  assert_eq(module_.lambda_function_indices.length(), 2)
  let first = module_.lambda_function_indices[0]
  let second = module_.lambda_function_indices[1]
  assert_true(first != second)
  assert_eq(
    module_.functions[first].signature_type_index,
    module_.functions[second].signature_type_index,
  )
  module_.lambda_function_indices[0] = second
  match emit_starshine_program_module(lowering, link) {
    Err(error) =>
      assert_eq(
        error,
        backend_lambda_function_lookup_failure(504U, 0UL, 1UL, 122UL, 0),
      )
    Ok(_) => fail("a changed lambda function lookup reached emission")
  }
}

///|
test "module emission checks lambda function lookups before reading targets" {
  let (lowering, link) = backend_lambda_function_lookup_stages()
  let module_ = link.modules[0]
  assert_eq(
    @validate.validate_module(
      emit_starshine_module(lowering.modules[0], module_).unwrap(),
    ),
    Ok(()),
  )
  module_.lambda_function_indices[0] = module_.lambda_function_indices[1]
  match emit_starshine_module(lowering.modules[0], module_) {
    Err(error) =>
      assert_eq(
        error,
        backend_lambda_function_lookup_failure(504U, 0UL, 1UL, 122UL, 0),
      )
    Ok(_) => fail("a changed lambda function lookup reached module emission")
  }
}

///|
test "emission checks exact lambda entry signatures before section writes" {
  let (lowering, link) = backend_lambda_function_lookup_stages()
  let module_ = link.modules[0]
  let source = module_.functions[module_.lambda_function_indices[0]]
  let other = module_.functions[0].signature_type_index
  assert_true(other != source.signature_type_index)
  module_.lambda_entry_signature_indices[0] = other
  match emit_starshine_program_module(lowering, link) {
    Err(error) =>
      assert_eq(
        error,
        backend_lambda_function_lookup_failure(
          504U,
          source.signature_type_index.to_uint64(),
          other.to_uint64(),
          124UL,
          0,
        ),
      )
    Ok(_) => fail("a changed lambda entry signature reached emission")
  }
}
