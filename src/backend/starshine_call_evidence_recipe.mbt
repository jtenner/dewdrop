///|
fn starshine_call_runtime_evidence(
  planned : @semantic.PlannedProgramWasmGCLink,
  body : @semantic.BodyId,
  caller_key : String,
  expression : @semantic.ExprId,
) -> Result[@semantic.HirSpan?, StarshineCodeEmissionError] {
  match
    @semantic.check_program_specialized_call_runtime_evidence(
      planned, body, caller_key, expression,
    ) {
    Ok(value) => Ok(value)
    Err(failure) =>
      Err(
        CompilerInvariantFailure({
          code: failure.code.to_uint(),
          phase: 7U,
          module_id: failure.module_id,
          declaration: failure.declaration,
          body: failure.body,
          expression: failure.expression,
          expected: failure.expected,
          actual: failure.actual,
          detail: failure.detail,
        }),
      )
  }
}
