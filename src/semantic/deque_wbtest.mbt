///|
test "deque functions use ordinary library bodies and lowering" {
  let program = collect_program_manifest(
    2633UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.collections.deque\nfn make() -> Deque<I32> {\n  deque_new()\n}\npub fn run() -> Unit {\n  let value = make()\n  deque_push_front(value, 1)\n  deque_push_back(value, 2)\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let deque = program.modules[program
    .module_index("dew.std.collections.deque")
    .unwrap()]
  assert_eq(deque.diagnostics, [])
  for callable in deque.callables {
    assert_true(deque.body_of(callable.declaration) is Some(_))
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
