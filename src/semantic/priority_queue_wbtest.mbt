///|
test "priority queue standard module has stable identities and transitive generic lowering" {
  let program = collect_program_manifest(
    2635UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.ordering\nopen dew.std.collections.binary_heap\nopen dew.std.collections.priority_queue\nfn make() -> PriorityQueue<I32, I32, NaturalComparator> {\n  priority_queue_new(natural_comparator(), HeapOrder::Minimum)\n}\npub fn run() -> Unit {\n  let queue = make()\n  priority_queue_enqueue(queue, 20, 2)\n  priority_queue_enqueue(queue, 10, 1)\n  priority_queue_dequeue(queue)\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let module_index = program
    .module_index("dew.std.collections.priority_queue")
    .unwrap()
  let queue = program.modules[module_index]
  assert_eq(queue.diagnostics, [])
  let queue_type = queue.lookup_type("PriorityQueue").unwrap()
  assert_eq(semantic_id_module(queue_type), standard_library_module_id(40))
  assert_true(queue.lookup_type("PriorityItem") is Some(_))
  assert_true(queue.lookup_value("priority_queue_enqueue") is Some(_))
  assert_true(queue.lookup_value("priority_queue_dequeue") is Some(_))
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
