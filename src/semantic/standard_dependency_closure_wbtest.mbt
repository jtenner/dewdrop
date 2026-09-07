///|
test "standard dependency selection follows source imports through cycles" {
  let manifest = ProgramManifest::new([
    ManifestModule::new("app.main", [
      ManifestFile::new("main.dew", b"open dew.std.ordering\n"),
    ]),
  ])
  let sources = StandardLibrarySources::new([
    ManifestFile::new("std/ordering.dew", b"open dew.std.string\n"),
    ManifestFile::new("std/string.dew", b"open dew.std.ordering\n"),
  ])
  let program = collect_program_manifest_with_standard_sources(
    99502UL, manifest, sources, false,
  )
  assert_true(program.module_index("dew.std.string") is Some(_))
  let paths = required_standard_library_source_paths(
    manifest,
    false,
    sources=Some(sources),
  )
  assert_true(paths.contains("std/string.dew"))
  assert_eq(
    paths,
    required_standard_library_source_paths(
      manifest,
      false,
      sources=Some(sources),
    ),
  )
  let seen : Map[String, Bool] = Map([])
  for path in program.module_paths {
    assert_false(seen.contains(path))
    seen[path] = true
  }
}

///|
test "standard dependency selection uses the supplied sources" {
  let manifest = ProgramManifest::new([
    ManifestModule::new("app.main", [
      ManifestFile::new("main.dew", b"open dew.std.ordering\n"),
    ]),
  ])
  let sources = StandardLibrarySources::new([
    ManifestFile::new("std/ordering.dew", b"open dew.std.string_builder\n"),
  ])
  let paths = required_standard_library_source_paths(
    manifest,
    false,
    sources=Some(sources),
  )
  assert_true(paths.contains("std/string_builder.dew"))
  let seen : Map[String, Bool] = Map([])
  for path in paths {
    assert_false(seen.contains(path))
    seen[path] = true
  }
}
