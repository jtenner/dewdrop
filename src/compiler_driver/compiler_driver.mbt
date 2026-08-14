///|
pub enum CompilerPlanningMode {
  CompilerProductionPlanning
  CompilerTestPlanning
} derive(Eq, Debug)

///|
pub struct CompilerPipelineOptions {
  module_id_base : @semantic.ModuleId
  root_module_index : Int
  default_preamble : Bool
  planning_mode : CompilerPlanningMode
} derive(Eq, Debug)

///|
pub fn CompilerPipelineOptions::production(
  module_id_base : @semantic.ModuleId,
  root_module_index : Int,
  default_preamble : Bool,
) -> CompilerPipelineOptions {
  {
    module_id_base,
    root_module_index,
    default_preamble,
    planning_mode: CompilerProductionPlanning,
  }
}

///|
pub fn CompilerPipelineOptions::test_mode(
  module_id_base : @semantic.ModuleId,
  root_module_index : Int,
  default_preamble : Bool,
) -> CompilerPipelineOptions {
  {
    module_id_base,
    root_module_index,
    default_preamble,
    planning_mode: CompilerTestPlanning,
  }
}

///|
pub struct CompilerCompilation {
  program : @semantic.CollectedProgram
  analyzed : @semantic.AnalyzedProgramSemantics
  lowering : @semantic.PlannedProgramLowering
  link : @semantic.PlannedProgramWasmGCLink
  cache_status : @standard_loader.InterfaceBundleCacheStatus
  body_cache_status : @standard_loader.BodyInferenceCacheStatus
  planning_cache_status : @standard_loader.PlanningCacheStatus
  parse_event_cache_status : @standard_loader.ParseEventCacheStatus
}

///|
pub fn compile_manifest(
  manifest : @semantic.ProgramManifest,
  loaded : @standard_loader.StandardLibraryLoad,
  options : CompilerPipelineOptions,
  prior_parse_event_cache_status? : @standard_loader.ParseEventCacheStatus = @standard_loader.ParseEventCacheWasUsed(
    0, 0,
  ),
) -> Result[CompilerCompilation, String] {
  let prepared = match
    @standard_loader.prepare_program_parse_event_cache(
      manifest,
      loaded,
      options.default_preamble,
      prior_status=prior_parse_event_cache_status,
    ) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let manifest = prepared.manifest
  let program = @semantic.collect_program_manifest_with_standard_sources(
    options.module_id_base,
    manifest,
    prepared.standard_sources,
    options.default_preamble,
  )
  let cached = match
    @standard_loader.analyze_program_with_interface_bundle_cache(
      program,
      loaded,
      root_module_index=options.root_module_index,
    ) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let analyzed = cached.analyzed
  let planned = match
    @standard_loader.plan_program_lowering_with_cache(program, analyzed) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let lowering = planned.lowering
  let planning_options = match options.planning_mode {
    CompilerProductionPlanning =>
      @semantic.WasmGCPlanningOptions::optimized_subtype_families()
    CompilerTestPlanning => @semantic.WasmGCPlanningOptions::test_mode()
  }
  let linked = match
    @standard_loader.plan_program_wasmgc_link_with_cache(
      program,
      analyzed,
      lowering,
      options.root_module_index,
      planning_options,
    ) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let link = linked.link
  Ok({
    program,
    analyzed,
    lowering,
    link,
    cache_status: cached.status,
    body_cache_status: cached.body_cache_status,
    planning_cache_status: @standard_loader.combine_planning_cache_status(
      planned.status,
      linked.status,
    ),
    parse_event_cache_status: prepared.status,
  })
}

///|
pub fn CompilerCompilation::source_diagnostics(
  self : CompilerCompilation,
) -> Array[@semantic.CompilerSourceDiagnostic] {
  @semantic.collect_compiler_source_diagnostics(
    self.program,
    self.analyzed,
    self.lowering,
    self.link,
  )
}

///|
pub fn CompilerCompilation::has_errors(self : CompilerCompilation) -> Bool {
  for diagnostic in self.source_diagnostics() {
    match diagnostic.severity {
      @semantic.CompilerError => return true
      @semantic.CompilerWarning => ()
    }
  }
  false
}

///|
pub fn CompilerCompilation::emit_binary(
  self : CompilerCompilation,
) -> Result[Bytes, @backend.StarshineProgramBinaryEmissionError] {
  @backend.emit_starshine_program_binary(self.lowering, self.link)
}
