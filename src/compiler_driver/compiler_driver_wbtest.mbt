///|
test "compiler driver runs the production pipeline" {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("driver.main", [
      @semantic.ManifestFile::new(
        "main.dew", b"pub fn main() -> I32 {\n  42\n}\n",
      ),
    ]),
  ])
  let compiled = compile_manifest(
    manifest,
    @standard_loader.StandardLibraryLoad::bootstrap(),
    CompilerPipelineOptions::production(5000UL, 0, true),
  ).unwrap()
  assert_eq(compiled.source_diagnostics().length(), 0)
  assert_false(compiled.has_errors())
  let binary = compiled.emit_binary().unwrap()
  assert_true(binary.length() > 8)
}

///|
test "compiler driver selects test planning" {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("driver.tests", [
      @semantic.ManifestFile::new("main_test.dew", b"test \"answer\" {\n}\n"),
    ]),
  ])
  let compiled = compile_manifest(
    manifest,
    @standard_loader.StandardLibraryLoad::bootstrap(),
    CompilerPipelineOptions::test_mode(5001UL, 0, true),
  ).unwrap()
  assert_eq(compiled.source_diagnostics().length(), 0)
  assert_true(compiled.link.modules[0].emit_tests)
}
