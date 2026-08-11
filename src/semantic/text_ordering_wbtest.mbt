///|
test "text comparators remain explicit and lower through ordering evidence" {
  let program = collect_program_manifest(
    2640UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.ordering\nopen dew.std.string\nopen dew.std.bytes\npub fn run() -> Bool {\n  ordering_is_less(string_comparator().compare(\"a\", \"b\")) && ordering_is_equal(string_view_comparator().compare(\"a\".view(0u32, 1u32), \"a\".view(0u32, 1u32))) && ordering_is_greater(bytes_comparator().compare(\"b\".as_bytes(), \"a\".as_bytes()))\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let ordering_index = program.module_index("dew.std.ordering").unwrap()
  let ordering = program.modules[ordering_index]
  assert_eq(ordering.diagnostics, [])
  let comparator = ordering.lookup_trait("Comparator").unwrap()
  assert_eq(semantic_id_module(comparator), standard_library_module_id(38))
  assert_true(ordering.lookup_type("StringComparator") is Some(_))
  assert_true(ordering.lookup_type("StringViewComparator") is Some(_))
  assert_true(ordering.lookup_type("BytesComparator") is Some(_))
  assert_true(ordering.lookup_value("string_comparator") is Some(_))
  assert_true(ordering.lookup_value("string_view_comparator") is Some(_))
  assert_true(ordering.lookup_value("bytes_comparator") is Some(_))
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
