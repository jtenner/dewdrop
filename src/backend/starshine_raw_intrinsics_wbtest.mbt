///|
test "raw bit casts preserve packed scalar and vector carriers" {
  let stages = backend_test_single_module_stages(
    28201UL, b"builtin cast<a, b>(value: a) -> b = \"unsafe.bitcast\"\npub fn pack(value: U32) -> I16x2 {\n  cast(value)\n}\npub fn unpack(value: I16x2) -> U32 {\n  cast(value)\n}\npub fn wide(value: U64) -> I16x4 {\n  cast(value)\n}\npub fn vector(value: V128) -> F32x4 {\n  cast(value)\n}\n",
  )
  @test.assert_eq(
    @semantic.collect_compiler_source_diagnostics(
      stages.program,
      stages.analyzed,
      stages.lowering,
      stages.link,
    ),
    [],
  )
  assert_eq(stages.link.imported_function_count, 0)
  let module_ = emit_starshine_program_module(stages.lowering, stages.link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "raw bit casts reject different carriers before Wasm validation" {
  let stages = backend_test_single_module_stages(
    28202UL, b"builtin cast<a, b>(value: a) -> b = \"unsafe.bitcast\"\npub fn invalid(value: U32) -> U64 {\n  cast(value)\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Err(InvalidBuiltinSignature(name, _, _)) =>
      assert_eq(name, b"unsafe.bitcast")
    _ => fail("expected InvalidBuiltinSignature before Wasm validation")
  }
}

///|
test "raw bit casts reject references and erased signatures" {
  for
    source in [
      b"builtin cast<a, b>(value: a) -> b = \"unsafe.bitcast\"\npub fn invalid(value: String) -> String {\n  cast(value)\n}\n",
      b"builtin cast<a, b>(value: a) -> b = \"unsafe.bitcast\"\npub fn invalid(value: F32) -> U32 {\n  cast(value)\n}\n",
      b"builtin cast(value: Unit) -> Unit = \"unsafe.bitcast\"\npub fn invalid() -> Unit {\n  cast(())\n}\n",
    ] {
    let stages = backend_test_single_module_stages(28203UL, source)
    assert_eq(stages.diagnostic_count(), 0)
    match emit_starshine_program_module(stages.lowering, stages.link) {
      Err(InvalidBuiltinSignature(name, _, _)) =>
        assert_eq(name, b"unsafe.bitcast")
      _ => fail("expected InvalidBuiltinSignature for non-carrier cast")
    }
  }
}
