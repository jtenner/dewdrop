///|
test "binary heap standard module has stable identities and generic lowering" {
  let program = collect_program_manifest(
    2634UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.ordering\nopen dew.std.collections.binary_heap\nfn make() -> BinaryHeap<I32, NaturalComparator> {\n  binary_heap_new(natural_comparator(), HeapOrder::Minimum)\n}\npub fn run() -> Unit {\n  let heap = make()\n  binary_heap_push(heap, 2)\n  binary_heap_push(heap, 1)\n  binary_heap_pop(heap)\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let module_index = program
    .module_index("dew.std.collections.binary_heap")
    .unwrap()
  let heap = program.modules[module_index]
  assert_eq(heap.diagnostics, [])
  let heap_type = heap.lookup_type("BinaryHeap").unwrap()
  assert_eq(semantic_id_module(heap_type), standard_library_module_id(39))
  assert_true(heap.lookup_type("HeapOrder") is Some(_))
  assert_true(heap.lookup_value("binary_heap_push") is Some(_))
  assert_true(heap.lookup_value("binary_heap_pop") is Some(_))
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics, [])
  for module_ in analyzed.modules {
    assert_eq(module_.names.diagnostics, [])
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowered = plan_program_lowering(program, analyzed)
  assert_eq(lowered.modules[0].diagnostics.length(), 0)
}
