///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "queue standard module has stable identities and lowering" {
  let program = collect_program_manifest(
    2631UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.queue\nfn make_queue() -> Queue<I32> {\n  queue_new()\n}\npub fn run() -> Unit {\n  let queue = make_queue()\n  queue_enqueue(queue, 1)\n  match queue_dequeue(queue) {\n    Option::Some(_) => {}\n    Option::None => {}\n  }\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let queue = program.modules[program.module_index("dew.std.queue").unwrap()]
  assert_eq(queue.diagnostics, [])
  assert_eq(semantic_id_local(queue.lookup_type("Queue").unwrap()), 0)
  assert_eq(semantic_id_local(queue.lookup_value("queue_new").unwrap()), 2)
  assert_eq(
    standard_queue_operation(queue.lookup_value("queue_dequeue").unwrap()),
    QueueDequeue,
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics, [])
  for module_ in analyzed.modules {
    assert_eq(module_.names.diagnostics, [])
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowered = plan_program_lowering(program, analyzed)
  assert_eq(lowered.modules[0].diagnostics.length(), 0)
}
