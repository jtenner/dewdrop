///|
test "String pattern effects prevent removal of flat and nested comparisons" {
  let program = collect_program_manifest(
    99500UL,
    ProgramManifest::new([
      ManifestModule::new("app.patterns", [
        ManifestFile::new(
          "patterns.dew", b"builtin stop() -> Never = \"unreachable\"\ntrait Eq {\n  fn eq(self, right: Self) -> Bool\n}\nimpl Eq for String {\n  fn eq(self, right: String) -> Bool {\n    stop()\n  }\n}\nenum Text {\n  Item(String)\n}\nfn flat(value: String) -> U32 {\n  match value {\n    \"same\" => 1u32\n    _ => 0u32\n  }\n}\nfn nested(value: Text) -> U32 {\n  match value {\n    Text::Item(\"same\") => 1u32\n    _ => 0u32\n  }\n}\nfn pure() -> U32 {\n  1u32\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_program_lowering(program, analyzed)
  let summaries = program_callable_effect_summaries(lowering.modules)
  let collected = program.modules[0]
  assert_true(summaries.contains(collected.lookup_value("pure").unwrap()))
  assert_false(summaries.contains(collected.lookup_value("flat").unwrap()))
  assert_false(summaries.contains(collected.lookup_value("nested").unwrap()))
}
