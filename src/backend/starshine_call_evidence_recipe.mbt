///|
fn starshine_call_runtime_evidence(
  planned : @semantic.PlannedProgramWasmGCLink,
  body : @semantic.BodyId,
  caller_key : String,
  expression : @semantic.ExprId,
  caller_parameters : StarshineCallFrameParameters,
) -> Result[@semantic.HirSpan?, StarshineCodeEmissionError] {
  let selected = match
    @semantic.check_program_specialized_call_runtime_evidence(
      planned, body, caller_key, expression,
    ) {
    Ok(value) => value
    Err(failure) =>
      return Err(
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
  let key = @semantic.program_specialized_call_key(body, caller_key, expression)
  let declaration = match planned.specialized_call_targets.get(key) {
    Some(value) => value.declaration
    None => 0UL
  }
  let failure = fn(code, expected, actual, detail) {
    CompilerInvariantFailure({
      code,
      phase: 7U,
      module_id: @semantic.semantic_id_module(body),
      declaration,
      body,
      expression: expression.reinterpret_as_uint(),
      expected,
      actual,
      detail,
    })
  }
  let start = caller_parameters.start
  let length = caller_parameters.length
  let values = caller_parameters.values
  guard start >= 0 &&
    length >= 0 &&
    start <= values.length() &&
    length <= values.length() - start else {
    return Err(
      failure(
        101U,
        values.length().to_uint64(),
        (start.reinterpret_as_uint().to_uint64() << 32) |
        length.reinterpret_as_uint().to_uint64(),
        1UL << 32,
      ),
    )
  }
  match selected {
    Some(span) =>
      // The recipe's owned span and unchanged contents were checked above.
      // These indices name this emitted frame's parameters, not root-body
      // locals or the parameters of an enclosing lambda factory.
      for index in 0..<span.length {
        let parameter = planned.specialized_call_runtime_evidence_parameters[span.start +
          index]
        guard parameter >= 0 && parameter < length else {
          return Err(
            failure(
              704U,
              length.to_uint64(),
              parameter.reinterpret_as_uint().to_uint64(),
              index.to_uint64(),
            ),
          )
        }
      }
    None => ()
  }
  Ok(selected)
}
