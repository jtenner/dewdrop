///|
test "ordered map standard module has stable identities and range lowering" {
  let program = collect_program_manifest(
    2637UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.ordering\nopen dew.std.collections.ordered_map\nfn make() -> OrderedMap<I32, I32, NaturalComparator> {\n  ordered_map_new(natural_comparator())\n}\npub fn run() -> Unit {\n  let map = make()\n  ordered_map_insert(map, 2, 20)\n  ordered_map_insert(map, 1, 10)\n  ordered_map_range(map, Option::Some(1), true, Option::Some(2), true)\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let module_index = program
    .module_index("dew.std.collections.ordered_map")
    .unwrap()
  let map = program.modules[module_index]
  assert_eq(map.diagnostics, [])
  let map_type = map.lookup_type("OrderedMap").unwrap()
  assert_eq(semantic_id_module(map_type), standard_library_module_id(42))
  assert_true(map.lookup_type("OrderedMapIter") is Some(_))
  assert_true(map.lookup_value("ordered_map_insert") is Some(_))
  assert_true(map.lookup_value("ordered_map_range") is Some(_))
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics, [])
  for module_ in analyzed.modules {
    assert_eq(module_.names.diagnostics, [])
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowered = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowered, 0)
  assert_eq(link.diagnostics, [])
}
