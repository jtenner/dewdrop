///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "stack standard module has stable identities and lowering" {
  let program = collect_program_manifest(
    2630UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.collections.stack\nfn make_stack() -> Stack<I32> {\n  stack_new()\n}\npub fn run() -> Unit {\n  let stack = make_stack()\n  stack_push(stack, 1)\n  match stack_pop(stack) {\n    Option::Some(_) => {}\n    Option::None => {}\n  }\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let stack = program.modules[program
    .module_index("dew.std.collections.stack")
    .unwrap()]
  assert_eq(stack.diagnostics, [])
  assert_eq(semantic_id_local(stack.lookup_type("Stack").unwrap()), 0)
  assert_eq(semantic_id_local(stack.lookup_value("stack_new").unwrap()), 2)
  assert_eq(
    standard_stack_operation(stack.lookup_value("stack_push").unwrap()),
    StackPush,
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
