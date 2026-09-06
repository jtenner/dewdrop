///|
test "canonical standard module identities match the native package registry" {
  let program = collect_program_manifest(
    24901UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.*\npub fn main() -> Unit {}\n",
        ),
      ]),
    ]),
  )
  for index, module_ in program.modules {
    let path = program.module_paths[index]
    if path.has_prefix("dew.std.") {
      assert_eq(
        canonical_standard_module_id(path),
        Some(module_.module_id),
        msg=path,
      )
    }
  }
  assert_eq(canonical_standard_module_id("app.main"), None)
}
