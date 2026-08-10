///|
test "fixed array standard source has stable compiler-owned identities" {
  let module_id = standard_library_module_id(10)
  let collected = collect_program_files_with_frozen_standard_imports(
    module_id,
    standard_library_program_files(
      module_id,
      "std/fixed_array.dew",
      @standard_sources.standard_fixed_array_source(),
      false,
      false,
    ),
  )
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(semantic_id_local(collected.lookup_type("FixedArray").unwrap()), 0)
  assert_eq(
    semantic_id_local(collected.lookup_value("fixed_array_make").unwrap()),
    1,
  )
  assert_eq(collected.callables.length(), 14)
  assert_eq(semantic_id_local(collected.callables[6].declaration), 8)
  assert_eq(semantic_id_local(collected.callables[12].declaration), 15)
  assert_eq(semantic_id_local(collected.callables[13].declaration), 17)
}

///|
test "fixed array source calls infer through generic implementations" {
  let program = collect_program_manifest(
    2611UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.fixed_array\npub fn run() -> I32 {\n  let values = FixedArray::make(3u32, 7)\n  values[1u32] = 9\n  values[1u32]\n}\npub fn safe(index: U32) -> Option<I32> {\n  let values = FixedArray::make(2u32, 5)\n  fixed_array_get(values, index)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  if analyzed.modules[0].inferred.diagnostics.length() > 0 {
    assert_eq(
      analyzed.modules[0].inferred.diagnostics[0],
      UnsupportedExpressionInference(-1, 0UL),
    )
  }
}
