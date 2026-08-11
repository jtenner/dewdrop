///|
test "ordered set standard module has stable identities and range lowering" {
  let program = collect_program_manifest(
    2638UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.ordering\nopen dew.std.collections.ordered_set\nfn make() -> OrderedSet<I32, NaturalComparator> {\n  ordered_set_new(natural_comparator())\n}\npub fn run() -> Unit {\n  let set = make()\n  ordered_set_insert(set, 2)\n  ordered_set_insert(set, 1)\n  ordered_set_range(set, Option::Some(1), true, Option::Some(2), true)\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let module_index = program
    .module_index("dew.std.collections.ordered_set")
    .unwrap()
  let set = program.modules[module_index]
  assert_eq(set.diagnostics, [])
  let set_type = set.lookup_type("OrderedSet").unwrap()
  assert_eq(semantic_id_module(set_type), standard_library_module_id(43))
  assert_true(set.lookup_type("OrderedSetIter") is Some(_))
  assert_true(set.lookup_value("ordered_set_insert") is Some(_))
  assert_true(set.lookup_value("ordered_set_range") is Some(_))
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
