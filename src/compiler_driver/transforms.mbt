///|
fn transform_manifest(
  modules : Array[@transforms.SourceModule],
) -> @semantic.ProgramManifest {
  @semantic.ProgramManifest::new(
    modules.map(fn(module_) {
      @semantic.ManifestModule::new(
        module_.path,
        module_.files.map(fn(file) {
          @semantic.ManifestFile::new(file.path, file.source)
        }),
      )
    }),
  )
}

///|
/// Select external standard dependencies before expansion adds compiler library
/// modules. This does not parse transform bodies or change ordinary manifests.
pub fn transform_loading_manifest(
  manifest : @semantic.ProgramManifest,
) -> @semantic.ProgramManifest {
  if !manifest.modules.any(fn(module_) {
      module_.files.any(fn(file) {
        @transforms.contains_transform_syntax(file.source)
      })
    }) {
    return manifest
  }
  let modules = manifest.modules.copy()
  for
    library in transform_manifest(@transforms.transform_library_sources()).modules {
    modules.push(library)
  }
  @semantic.ProgramManifest::new(modules)
}

///|
fn compiler_expand_transforms(
  manifest : @semantic.ProgramManifest,
  sources : @semantic.StandardLibrarySources,
  options : CompilerPipelineOptions,
) -> Result[@semantic.ProgramManifest, CompilerCompilationError] {
  let modules : Array[@transforms.SourceModule] = manifest.modules.map(fn(
    module_,
  ) {
    {
      path: module_.path,
      files: module_.files.map(fn(file) {
        { path: file.path, source: file.source, }
      }),
    }
  })
  let plan = match @transforms.prepare(modules) {
    Ok(value) => value
    Err(message) => return Err(CompilerSourceError(message, []))
  }
  if !plan.active {
    return Ok(manifest)
  }
  // Check ordinary Dew code before running it. Target bodies are checked after expansion.
  let program = @semantic.collect_program_manifest_with_standard_sources(
    options.module_id_base,
    transform_manifest(plan.validation_sources()),
    sources,
    options.default_preamble,
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_unoptimized_program_lowering(program, analyzed)
  if compiler_frontend_error(program, analyzed, lowering) is Some(error) {
    return Err(error)
  }
  let output_module_count = plan.modules.length()
  for mi in output_module_count..<program.modules.length() {
    let module_ = program.modules[mi]
    let files : Array[@transforms.SourceFile] = []
    for fi, path in module_.file_paths {
      files.push({ path, source: module_.file_sources[fi], })
    }
    match plan.add_checked_module({ path: program.module_paths[mi], files, }) {
      Ok(_) => ()
      Err(message) => return Err(CompilerSourceError(message, []))
    }
  }
  for
    (mi, name, key) in @semantic.compile_time_imported_type_names(
      program, analyzed,
    ) {
    plan.add_type_name(mi, name, key)
  }
  match
    plan.check_signatures(fn(mi, name) {
      @semantic.compile_time_transform_signature_is_valid(
        program, lowering, mi, name,
      )
    }) {
    Ok(_) => ()
    Err(message) => return Err(CompilerSourceError(message, []))
  }
  for
    (mi, file, offset, opcode) in @semantic.compile_time_scalar_operator_proofs(
      program, analyzed, lowering,
    ) {
    if program.source_file(file) is Some(source_file) {
      plan.add_scalar_proof(mi, source_file.path, offset, opcode)
    }
  }
  for
    (mi, file, offset, constructor) in @semantic.compile_time_pattern_proofs(
      program, analyzed,
    ) {
    if program.source_file(file) is Some(source_file) {
      plan.add_pattern_proof(mi, source_file.path, offset, constructor)
    }
  }
  for literal in @semantic.compile_time_arrays(program, lowering) {
    if program.source_file(literal.file) is Some(file) {
      plan.add_array_layout(
        literal.module_index,
        file.path,
        literal.offset,
        literal.key,
        literal.fields,
      )
    }
  }
  for call in @semantic.compile_time_calls(program, analyzed, lowering) {
    if program.source_file(call.file) is Some(source) {
      let target_path = match program.source_file(call.target_file) {
        Some(file) => file.path
        None => ""
      }
      plan.add_call_proof(
        call.module_index,
        source.path,
        call.offset,
        call.target_module,
        target_path,
        call.target_offset,
        reference=call.reference,
        result_kind=call.result_kind,
        constructor_key=call.constructor_key,
      )
    }
  }
  match plan.expand(output_module_count~) {
    Ok(modules) => Ok(transform_manifest(modules))
    Err(message) => Err(CompilerSourceError(message, []))
  }
}
