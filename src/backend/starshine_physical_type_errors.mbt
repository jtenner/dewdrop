///|
fn starshine_physical_type_invariant_error(
  failure : @semantic.ProgramPhysicalTypeFailure,
) -> StarshineCodeEmissionError {
  CompilerInvariantFailure({
    code: failure.code.reinterpret_as_uint(),
    phase: 7U,
    module_id: failure.module_id,
    declaration: failure.declaration,
    body: failure.body,
    expression: failure.expression,
    expected: failure.expected,
    actual: failure.actual,
    detail: failure.detail,
  })
}
