///|
test "cross file functions emit one valid module" {
  let module_id = 999UL
  let program = @semantic.collect_program_manifest(
    module_id,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "double.dew", b"fn double(value: I32) -> I32 {\n  value + value\n}\n",
        ),
        @semantic.ManifestFile::new(
          "run.dew", b"pub fn run(value: I32) -> I32 {\n  double(value)\n}\n",
        ),
      ]),
    ]),
  )
  let collected = program.modules[0]
  let analyzed = @semantic.analyze_program_semantics(program)
  let resolved = analyzed.frozen.interfaces[0].resolved_types
  let names = analyzed.modules[0].names
  let inferred = analyzed.modules[0].inferred
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_unoptimized_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics, [])
  assert_true(
    link.function_of(collected.lookup_value("double").unwrap()) is Some(_),
  )
  assert_true(
    link.function_of(collected.lookup_value("run").unwrap()) is Some(_),
  )
  match emit_starshine_program_binary(lowering, link) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to emit cross-file module")
  }
}
