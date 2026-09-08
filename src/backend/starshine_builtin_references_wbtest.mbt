///|
test "raw builtin function references have concrete wrappers without imports" {
  let (lowering, link, diagnostics) = backend_packed_primitive_pipeline(
    b"builtin add(a: I32, b: I32) -> I32 = \"i32.add\"\nfn factory() -> fn(I32, I32) -> I32 {\n  add\n}\npub fn run() -> I32 {\n  let operation = factory()\n  operation(40i32, 2i32)\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_eq(link.imported_function_count, 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}
