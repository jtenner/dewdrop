///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "queue functions use ordinary library bodies and lowering" {
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
  for callable in queue.callables {
    assert_true(queue.body_of(callable.declaration) is Some(_))
  }
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics, [])
  for interface_ in analyzed.frozen.interfaces {
    assert_eq(interface_.resolved_types.diagnostics, [])
  }
  for module_ in analyzed.modules {
    assert_eq(module_.names.diagnostics, [])
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowered = plan_program_lowering(program, analyzed)
  assert_eq(lowered.modules[0].diagnostics.length(), 0)
}
