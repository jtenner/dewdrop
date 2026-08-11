///|
test "circular buffer standard module has stable identities and lowering" {
  let program = collect_program_manifest(
    2632UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.collections.circular_buffer\nfn make() -> CircularBuffer<I32> {\n  circular_buffer_growable(2u32)\n}\npub fn run() -> Bool {\n  circular_buffer_push_back(make(), 1)\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let buffer = program.modules[program
    .module_index("dew.std.collections.circular_buffer")
    .unwrap()]
  assert_eq(buffer.diagnostics, [])
  assert_eq(semantic_id_local(buffer.lookup_type("CircularBuffer").unwrap()), 0)
  assert_eq(
    semantic_id_local(buffer.lookup_value("circular_buffer_bounded").unwrap()),
    2,
  )
  assert_eq(
    standard_circular_buffer_operation(
      buffer.lookup_value("circular_buffer_push_back").unwrap(),
    ),
    CircularBufferPushBack,
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
