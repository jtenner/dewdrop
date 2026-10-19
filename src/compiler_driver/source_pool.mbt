///|
/// Add only imported source-pool modules. Missing imports remain visible to the
/// ordinary source checker, including compiler-provided transform libraries.
fn compiler_manifest_import_closure(
  manifest : @semantic.ProgramManifest,
  source_pool : @semantic.ProgramManifest,
) -> @semantic.ProgramManifest {
  if source_pool.modules.is_empty() {
    return manifest
  }
  let modules = manifest.modules.copy()
  let selected : Map[String, Bool] = Map::default()
  for module_ in modules {
    selected[module_.path] = true
  }
  // These are the ambient modules that ordinary native collection always
  // supplies. Select their exact pooled records before using a fallback.
  for path in ["dew.std.preamble", "dew.std.option", "dew.std.result"] {
    for candidate in source_pool.modules {
      if candidate.path == path && !selected.contains(path) {
        selected[path] = true
        modules.push(candidate)
      }
    }
  }
  let mut index = 0
  while index < modules.length() {
    for file in modules[index].files {
      let events = @parser.parse_bytes(file.source)
      let mut scanning = true
      while scanning {
        match events.next() {
          Some(@parser.Declaration(@parser.Import(import_))) => {
            let path = import_.path.join(".")
            for candidate in source_pool.modules {
              let matches = if import_.wildcard {
                candidate.path.has_prefix(path + ".")
              } else {
                candidate.path == path
              }
              if matches && !selected.contains(candidate.path) {
                selected[candidate.path] = true
                modules.push(candidate)
              }
            }
          }
          _ => scanning = false
        }
      }
    }
    index += 1
  }
  @semantic.ProgramManifest::new(modules)
}

///|
fn compiler_expand_transform_import_closure(
  manifest : @semantic.ProgramManifest,
  source_pool : @semantic.ProgramManifest,
  standard_sources : @semantic.StandardLibrarySources,
  options : CompilerPipelineOptions,
) -> Result[@semantic.ProgramManifest, CompilerCompilationError] {
  if source_pool.modules.is_empty() {
    return compiler_expand_transforms(manifest, standard_sources, options)
  }
  let libraries = @transforms.transform_library_sources()
  for module_ in source_pool.modules {
    if libraries.any(library => library.path == module_.path) {
      return Err(
        CompilerSourceError(
          "dewdrop.ast and dewdrop.transform are supplied by the compiler",
          [],
        ),
      )
    }
  }
  let mut current = compiler_manifest_import_closure(manifest, source_pool)
  let trusted_library_indices : Array[Int32] = []
  for _ in 0..<(source_pool.modules.length() + 1) {
    let previous_count = current.modules.length()
    let expanded = match
      compiler_expand_transforms(
        current,
        standard_sources,
        options,
        trusted_library_indices~,
        retain_transform_declarations=true,
        source_pool~,
      ) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    // Only prepare can add modules during expansion. Track its exact output
    // positions rather than trusting a module name in a later source pool.
    if trusted_library_indices.is_empty() &&
      expanded.modules.length() > previous_count {
      guard expanded.modules.length() >= previous_count + libraries.length() else {
        return Err(
          CompilerInfrastructureError("transform API module count mismatch"),
        )
      }
      for index in previous_count..<(previous_count + libraries.length()) {
        trusted_library_indices.push(index)
      }
    }
    let selected = compiler_manifest_import_closure(expanded, source_pool)
    if selected.modules.length() == expanded.modules.length() {
      if trusted_library_indices.is_empty() {
        return Ok(selected)
      }
      // No annotations remain in this output. This pass only removes retained
      // transform declarations; it performs no interpretation or semantic pass.
      let modules : Array[@transforms.SourceModule] = selected.modules.map(fn(
        module_,
      ) {
        {
          path: module_.path,
          files: module_.files.map(fn(file) {
            { path: file.path, source: file.source, }
          }),
        }
      })
      let plan = match @transforms.prepare(modules, trusted_library_indices~) {
        Ok(value) => value
        Err(message) => return Err(CompilerSourceError(message, []))
      }
      return match plan.expand() {
        Ok(value) => Ok(transform_manifest(value))
        Err(message) => Err(CompilerSourceError(message, []))
      }
    }
    current = selected
  }
  Err(
    CompilerSourceError(
      "transform import expansion exceeded its source pool bound",
      [],
    ),
  )
}
