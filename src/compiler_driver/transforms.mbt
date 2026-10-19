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
  trusted_library_indices~ : Array[Int32] = [],
  retain_transform_declarations~ : Bool = false,
  source_pool~ : @semantic.ProgramManifest = @semantic.ProgramManifest::new([]),
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
  let plan = match @transforms.prepare(modules, trusted_library_indices~) {
    Ok(value) => value
    Err(message) => return Err(CompilerSourceError(message, []))
  }
  if !plan.active {
    return Ok(manifest)
  }
  // Compiler API imports use the same pool resolver as source imports. This
  // happens before checking, so fallback library bytes cannot replace a caller
  // module whose logical file paths differ from the standard registry.
  let selected = compiler_manifest_import_closure(
    transform_manifest(plan.modules),
    source_pool,
  )
  let plan = if selected.modules.length() == plan.modules.length() {
    plan
  } else {
    let trusted = trusted_library_indices.copy()
    if trusted.is_empty() {
      for
        index in manifest.modules.length()..<(manifest.modules.length() +
        @transforms.transform_library_sources().length()) {
        trusted.push(index)
      }
    }
    let selected_sources : Array[@transforms.SourceModule] = selected.modules.map(fn(
        module_,
      ) {
        {
          path: module_.path,
          files: module_.files.map(fn(file) {
            { path: file.path, source: file.source, }
          }),
        }
      },
    )
    match
      @transforms.prepare(selected_sources, trusted_library_indices=trusted) {
      Ok(value) => value
      Err(message) => return Err(CompilerSourceError(message, []))
    }
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
  if @semantic.compile_time_intrinsic_contract_error(lowering) is Some(error) {
    return Err(CompilerSourceError(error, []))
  }
  compiler_register_transform_intrinsic_contracts(plan, lowering)
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
  for layout in @semantic.compile_time_raw_layouts(program, lowering) {
    plan.add_raw_layout(
      layout.key,
      layout.identity,
      layout.fields,
      layout.storage,
    )
  }
  let frame_calls = match
    @semantic.compile_time_frame_calls(program, analyzed, lowering) {
    Ok(value) => value
    Err(message) => return Err(CompilerSourceError(message, []))
  }
  let calls = @semantic.compile_time_calls(program, analyzed, lowering).map(call => {
    ("", "", call)
  })
  for framed in frame_calls {
    calls.push((framed.frame, framed.target_frame, framed.call))
  }
  for (frame, target_frame, call) in calls {
    if program.source_file(call.file) is Some(source) {
      let target_path = match program.source_file(call.target_file) {
        Some(file) => file.path
        None => ""
      }
      if call.target_module == -7 {
        plan.add_scalar_proof(
          call.module_index,
          source.path,
          call.offset,
          @utf8.encode(call.result_kind),
          frame~,
        )
        continue
      }
      if call.constant is Some(value) {
        let constant = match value {
          @semantic.TransformBoolConstant(value) =>
            @transforms.CheckedBool(value)
          @semantic.TransformU32Constant(value) => @transforms.CheckedU32(value)
          @semantic.TransformStringsConstant(values) =>
            @transforms.CheckedStrings(values)
          @semantic.TransformUnitConstant => @transforms.CheckedUnit
        }
        plan.add_constant(
          call.module_index,
          source.path,
          call.offset,
          constant,
          frame~,
        )
        continue
      }
      plan.add_call_proof(
        call.module_index,
        source.path,
        call.offset,
        call.target_module,
        target_path,
        call.target_offset,
        frame~,
        target_frame~,
        reference=call.reference,
        result_kind=call.result_kind,
        constructor_key=call.constructor_key,
        function_declaration=call.function_identity.map(identity => {
          identity.declaration
        }),
        generic_function=call.function_identity
          .map(identity => identity.generic_function)
          .unwrap_or(false),
      )
    }
  }
  compiler_collect_transform_expression_types(plan, sources, options)
  match plan.expand(output_module_count~, retain_transform_declarations~) {
    Ok(modules) => {
      for report in plan.reports() {
        options.transform_reports.push(report)
      }
      Ok(transform_manifest(modules))
    }
    Err(message) => Err(CompilerSourceError(message, []))
  }
}
