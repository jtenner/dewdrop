///|
/// Test-only result for backend tests that need the complete linked pipeline.
struct BackendCompilerTestStages {
  program : @semantic.CollectedProgram
  analyzed : @semantic.AnalyzedProgramSemantics
  lowering : @semantic.PlannedProgramLowering
  link : @semantic.PlannedProgramWasmGCLink
}

///|
fn backend_test_single_module_stages(
  module_id_base : @semantic.ModuleId,
  source : Bytes,
  emit_tests? : Bool = false,
) -> BackendCompilerTestStages {
  let program = @semantic.collect_program_manifest(
    module_id_base,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new("main.dew", source),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = if emit_tests {
    @semantic.plan_program_wasmgc_link_with_options(
      analyzed,
      lowering,
      0,
      @semantic.WasmGCPlanningOptions::test_mode(),
    )
  } else {
    @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  }
  { program, analyzed, lowering, link, }
}

///|
fn BackendCompilerTestStages::diagnostic_count(
  self : BackendCompilerTestStages,
) -> Int {
  @semantic.collect_compiler_source_diagnostics(
    self.program,
    self.analyzed,
    self.lowering,
    self.link,
  ).length()
}

///|
fn BackendCompilerTestStages::emit_module(
  self : BackendCompilerTestStages,
) -> @lib.Module {
  emit_starshine_program_module(self.lowering, self.link).unwrap()
}

///|
fn BackendCompilerTestStages::emit_binary(
  self : BackendCompilerTestStages,
) -> Bytes {
  emit_starshine_program_binary(self.lowering, self.link).unwrap()
}

///|
test "backend compiler test builder exposes emission without manual pipeline" {
  let stages = backend_test_single_module_stages(
    22901UL, b"pub fn run() -> I32 {\n  42\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  ignore(stages.emit_module())
  assert_true(stages.emit_binary().length() > 8)
}
