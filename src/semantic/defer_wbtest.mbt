///|
test "defer lowers through directized lexical cleanup closures" {
  let program = collect_program_manifest(
    2641UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn cleanup(value: I32) -> Unit {\n  assert(value > 0, \"cleanup\")\n}\nfn run(value: I32) -> I32 {\n  defer cleanup(value)\n  if value > 1 {\n    return value + 1\n  }\n  value\n}\npub fn main() -> Unit {\n  assert(run(1) == 1, \"fallthrough\")\n  assert(run(2) == 3, \"return\")\n}\n",
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
