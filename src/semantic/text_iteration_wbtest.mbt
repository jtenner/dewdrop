///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "code point iterators retain stable text module identities" {
  let program = collect_program_manifest(
    2641UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.string\nopen dew.std.text\npub fn run() -> U32 {\n  let points = \"A\".code_points()\n  if points.has_next() { points.next() } else { 0u32 }\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let text_index = program.module_index("dew.std.text").unwrap()
  let text = program.modules[text_index]
  assert_eq(text.diagnostics, [])
  let iterator_type = text.lookup_type("StringCodePoints").unwrap()
  assert_eq(semantic_id_module(iterator_type), standard_library_module_id(46))
  assert_true(text.lookup_type("StringViewCodePoints") is Some(_))
  assert_true(text.lookup_value("string_code_points") is Some(_))
  assert_true(text.lookup_value("string_view_code_points") is Some(_))
  assert_true(program.module_index("dew.std.fixed_array") is Some(_))
  assert_eq(program.module_index("dew.std.array"), None)
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics, [])
  for module_ in analyzed.modules {
    assert_eq(module_.names.diagnostics, [])
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics, [])
}
