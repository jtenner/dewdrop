///|
/// Follow actual source imports once per path. Keep the seed order and append
/// newly discovered paths in source order. Cycles do not revisit a file.
pub fn required_standard_library_source_paths(
  manifest : ProgramManifest,
  default_preamble : Bool,
  sources? : StandardLibrarySources? = None,
) -> Array[String] {
  let required = direct_standard_library_source_paths(
    manifest, default_preamble,
  )
  let seen : Map[String, Bool] = Map([])
  for path in required {
    seen[path] = true
  }
  let mut cursor = 0
  while cursor < required.length() {
    let path = required[cursor]
    cursor += 1
    let file = match sources {
      Some(provider) => provider.file(path)
      None =>
        match @standard_sources.bootstrap_standard_source(path) {
          Some(source) => ManifestFile::new(path, source)
          None => abort("standard source registry has no entry for \{path}")
        }
    }
    let dependency = ProgramManifest::new([
      ManifestModule::new("dependency", [file]),
    ])
    for child in direct_standard_library_source_paths(dependency, false) {
      if !seen.contains(child) {
        seen[child] = true
        required.push(child)
      }
    }
  }
  required
}

///|
fn standard_dependency_selection_files(
  manifest : ProgramManifest,
  sources : StandardLibrarySources,
  default_preamble : Bool,
) -> Array[ProgramFile] {
  let files : Array[ProgramFile] = []
  for module_ in manifest.modules {
    for file in module_.files {
      files.push(ProgramFile::from_manifest(0UL, file))
    }
  }
  for
    path in required_standard_library_source_paths(
      manifest,
      default_preamble,
      sources=Some(sources),
    ) {
    files.push(ProgramFile::from_manifest(0UL, sources.file(path)))
  }
  files
}
