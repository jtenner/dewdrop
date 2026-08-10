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
}

///|
pub fn compile_manifest(
  manifest : @semantic.ProgramManifest,
  loaded : @standard_loader.StandardLibraryLoad,
  options : CompilerPipelineOptions,
) -> Result[CompilerCompilation, String] {
  let program = @semantic.collect_program_manifest_with_standard_sources(
    options.module_id_base,
    manifest,
    loaded.sources,
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
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = match options.planning_mode {
    CompilerProductionPlanning =>
      @semantic.plan_program_wasmgc_link(
        analyzed,
        lowering,
        options.root_module_index,
      )
    CompilerTestPlanning =>
      @semantic.plan_program_wasmgc_link_with_options(
        analyzed,
        lowering,
        options.root_module_index,
        @semantic.WasmGCPlanningOptions::test_mode(),
      )
  }
  Ok({ program, analyzed, lowering, link, cache_status: cached.status })
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
