///|
test "fixed arrays emit carrier-specialized WasmGC indexing" {
  let program = @semantic.collect_program_manifest(
    2610UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.fixed_array\npub fn run() -> I32 {\n  let values = FixedArray::make(3u32, 7)\n  values[1u32] = 9\n  values[1u32]\n}\npub fn safe(index: U32) -> Option<I32> {\n  let values = FixedArray::make(2u32, 5)\n  fixed_array_get(values, index)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics.length(), 0)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_true(
    link.type_lookup.get(@semantic.standard_fixed_array_type_declaration())
    is Some(_),
  )
  match emit_starshine_program_module(lowering, link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => assert_eq(error, UnsupportedBuiltin(b"expected-debug"))
  }
}
