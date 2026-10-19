///|
test "no preamble transforms load external AST dependencies" {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new(
        "main.dew", b"import dewdrop.ast as @ast\ntransform fn answer() -> I32 {\n 0i32\n}\n",
      ),
    ]),
  ])
  let loading = transform_loading_manifest(manifest)
  let selected = @semantic.direct_standard_library_source_paths(loading, false)
  assert_true(selected.contains("std/array.dew"))
  assert_eq(loading.modules.length(), 3)
}

///|
test "ordinary transform names do not add loading dependencies" {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new(
        "main.dew", b"fn transform() -> I32 {\n let transform = 1i32\n transform\n}\n",
      ),
    ]),
  ])
  let loading = transform_loading_manifest(manifest)
  assert_eq(loading.modules.length(), 1)
  assert_eq(@semantic.direct_standard_library_source_paths(loading, false), [])
}
