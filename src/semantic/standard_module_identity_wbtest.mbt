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

///|
test "explicit standard module files preserve all canonical identities without reinjection" {
  let original = collect_program_manifest(
    24901UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.*\npub fn main() -> Unit {}\n",
        ),
      ]),
    ]),
  )
  let modules : Array[ManifestModule] = []
  for index, module_ in original.modules {
    let files : Array[ManifestFile] = []
    for file_index, path in module_.file_paths {
      files.push(ManifestFile::new(path, module_.file_sources[file_index]))
    }
    modules.push(ManifestModule::new(original.module_paths[index], files))
  }
  let explicit = collect_program_manifest(
    24901UL,
    ProgramManifest::new(modules),
  )
  assert_eq(explicit.module_paths, original.module_paths)
  assert_eq(explicit.diagnostics.length(), 0)
  for index, module_ in original.modules {
    assert_eq(explicit.modules[index].module_id, module_.module_id)
    assert_eq(explicit.modules[index].file_paths, module_.file_paths)
    assert_eq(explicit.modules[index].file_sources, module_.file_sources)
  }
}

///|
test "every registered source path belongs to a canonical standard module" {
  for path in @standard_sources.standard_source_paths() {
    let module_path = @standard_sources.standard_source_module_name(path)
    assert_true(canonical_standard_module_id(module_path) is Some(_), msg=path)
  }
}
