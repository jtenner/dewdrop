///|
/// Test-only ordered source input used by semantic compiler tests.
struct CompilerTestSource {
  path : String
  bytes : Bytes
}

///|
fn CompilerTestSource::new(path : String, bytes : Bytes) -> CompilerTestSource {
  { path, bytes, }
}

///|
/// Test-only ordered module input. Array order is preserved exactly.
struct CompilerTestModule {
  name : String
  sources : Array[CompilerTestSource]
}

///|
fn CompilerTestModule::new(
  name : String,
  sources : Array[CompilerTestSource],
) -> CompilerTestModule {
  { name, sources, }
}

///|
fn compiler_test_manifest(
  modules : Array[CompilerTestModule],
) -> ProgramManifest {
  let manifest_modules : Array[ManifestModule] = []
  for module_ in modules {
    let files : Array[ManifestFile] = []
    for source in module_.sources {
      files.push(ManifestFile::new(source.path, source.bytes))
    }
    manifest_modules.push(ManifestModule::new(module_.name, files))
  }
  ProgramManifest::new(manifest_modules)
}

///|
fn compiler_test_single_module_program(
  module_id_base : ModuleId,
  source : Bytes,
) -> CollectedProgram {
  collect_program_manifest(
    module_id_base,
    compiler_test_manifest([
      CompilerTestModule::new("app.main", [
        CompilerTestSource::new("main.dew", source),
      ]),
    ]),
  )
}

///|
struct SemanticCompilerTestStages {
  program : CollectedProgram
  analyzed : AnalyzedProgramSemantics
  lowering : PlannedProgramLowering
  link : PlannedProgramWasmGCLink
}

///|
fn compiler_test_analyze(
  program : CollectedProgram,
) -> AnalyzedProgramSemantics {
  analyze_program_semantics(program)
}

///|
fn compiler_test_lower(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
) -> PlannedProgramLowering {
  plan_program_lowering(program, analyzed)
}

///|
fn compiler_test_link(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  root_module_index? : Int = 0,
  emit_tests? : Bool = false,
) -> PlannedProgramWasmGCLink {
  if emit_tests {
    plan_program_wasmgc_link_with_options(
      analyzed,
      lowering,
      root_module_index,
      WasmGCPlanningOptions::test_mode(),
    )
  } else {
    plan_program_wasmgc_link(analyzed, lowering, root_module_index)
  }
}

///|
fn compiler_test_stages(
  module_id_base : ModuleId,
  modules : Array[CompilerTestModule],
  root_module_index? : Int = 0,
  emit_tests? : Bool = false,
) -> SemanticCompilerTestStages {
  let program = collect_program_manifest(
    module_id_base,
    compiler_test_manifest(modules),
  )
  let analyzed = compiler_test_analyze(program)
  let lowering = compiler_test_lower(program, analyzed)
  let link = compiler_test_link(
    analyzed,
    lowering,
    root_module_index~,
    emit_tests~,
  )
  { program, analyzed, lowering, link, }
}

///|
fn SemanticCompilerTestStages::diagnostics(
  self : SemanticCompilerTestStages,
) -> Array[CompilerSourceDiagnostic] {
  collect_compiler_source_diagnostics(
    self.program,
    self.analyzed,
    self.lowering,
    self.link,
  )
}

///|
test "compiler test builders preserve ordered modules and expose stages" {
  let stages = compiler_test_stages(
    22900UL,
    [
      CompilerTestModule::new("dep.value", [
        CompilerTestSource::new(
          "dep.dew", b"pub fn answer() -> I32 {\n  42\n}\n",
        ),
      ]),
      CompilerTestModule::new("app.main", [
        CompilerTestSource::new(
          "main.dew", b"open dep.value\npub fn run() -> I32 {\n  answer()\n}\n",
        ),
      ]),
    ],
    root_module_index=1,
  )
  assert_eq(stages.program.module_paths[0], "dep.value")
  assert_eq(stages.program.module_paths[1], "app.main")
  assert_eq(stages.diagnostics().length(), 0)
  assert_true(stages.link.functions.length() > 0)
  let single = compiler_test_single_module_program(
    22902UL, b"pub fn value() -> I32 {\n  1\n}\n",
  )
  assert_eq(single.module_paths[0], "app.main")
}
