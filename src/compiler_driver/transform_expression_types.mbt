///|
fn compiler_transform_reflected_type(
  type_ : @semantic.CompileTimeReflectedType,
  cache : Map[UInt64, @transforms.ReflectedType],
) -> @transforms.ReflectedType {
  if cache.get(type_.identity) is Some(value) {
    return value
  }
  let value : @transforms.ReflectedType = {
    kind: type_.kind,
    name: type_.name,
    arguments: type_.arguments.map(fn(value) {
      compiler_transform_reflected_type(value, cache)
    }),
  }
  cache[type_.identity] = value
  value
}

///|
fn compiler_collect_transform_expression_types(
  plan : @transforms.Plan,
  sources : @semantic.StandardLibrarySources,
  options : CompilerPipelineOptions,
) -> Unit {
  let targets = plan.reflection_targets()
  if targets.is_empty() {
    return
  }
  // Keep original target bodies for reflection. The execution check uses stubs
  // separately so a transform can repair an invalid original body.
  let program = @semantic.collect_program_manifest_with_standard_sources(
    options.module_id_base,
    transform_manifest(plan.reflection_sources()),
    sources,
    options.default_preamble,
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_unoptimized_program_lowering(program, analyzed)
  if compiler_frontend_error(program, analyzed, lowering) is Some(error) {
    plan.set_reflection_error(error.message())
    return
  }
  let cache : Map[UInt64, @transforms.ReflectedType] = {}
  for
    value in @semantic.compile_time_expression_types(
      program, analyzed, lowering, targets,
    ) {
    let file = program.source_file(value.file).unwrap()
    plan.add_expression_type(
      value.module_index,
      file.path,
      value.offset,
      value.kind,
      compiler_transform_reflected_type(value.type_, cache),
    )
  }
}
