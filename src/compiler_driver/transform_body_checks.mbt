///|
fn compiler_transform_body_check(
  plan : @transforms.Plan,
  program : @semantic.CollectedProgram,
  analyzed : @semantic.AnalyzedProgramSemantics,
  lowering : @semantic.PlannedProgramLowering,
) -> Result[Array[@semantic.CompilerSourceDiagnostic], CompilerCompilationError] {
  let diagnostics = @semantic.collect_compiler_frontend_diagnostics(
    program, analyzed, lowering,
  )
  let deferred : Map[Int32, Bool] = {}
  for
    (index, mi, file, offset) in @semantic.compile_time_body_diagnostics(
      program, analyzed, lowering, diagnostics,
    ) {
    if program.source_file(file) is Some(source) &&
      plan.add_body_error(
        mi,
        source.path,
        offset,
        @semantic.render_compiler_source_diagnostic(program, diagnostics[index]),
      ) {
      deferred[index] = true
    }
  }
  for index, diagnostic in diagnostics {
    if diagnostic.severity is @semantic.CompilerError &&
      !deferred.contains(index) {
      return Err(compiler_frontend_error(program, analyzed, lowering).unwrap())
    }
  }
  Ok(diagnostics)
}
