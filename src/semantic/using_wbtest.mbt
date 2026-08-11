///|
test "using lowers through Disposable evidence and defer cleanup" {
  let program = collect_program_manifest(
    2642UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.disposable\nstruct Resource {\n  value: I32\n}\nimpl Disposable for Resource {\n  fn dispose(self) -> Unit {\n    assert(self.value == 7, \"dispose\")\n  }\n}\nfn acquire() -> Resource {\n  Resource {\n    value: 7\n  }\n}\npub fn main() -> Unit {\n  using resource = acquire()\n  assert(resource.value == 7, \"using\")\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics, [])
  assert_eq(analyzed.modules[0].names.diagnostics, [])
  assert_eq(analyzed.modules[0].inferred.diagnostics, [])
  let lowered = plan_program_lowering(program, analyzed)
  assert_true(lowered.modules[0].lambdas.length() >= 1)
  let link = plan_program_wasmgc_link(analyzed, lowered, 0)
  assert_eq(link.diagnostics, [])
}
