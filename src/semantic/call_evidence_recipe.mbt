///|
pub fn check_program_specialized_call_runtime_evidence(
  link : PlannedProgramWasmGCLink,
  body : BodyId,
  caller_key : String,
  expression : ExprId,
) -> Result[HirSpan?, ProgramFunctionLookupFailure] {
  match
    check_program_specialized_call_lookup(link, body, caller_key, expression) {
    Err(failure) => return Err(failure)
    Ok(_) => ()
  }
  let key = program_specialized_call_key(body, caller_key, expression)
  let selected = link.specialized_call_runtime_evidence_lookup.get(key)
  let witness = link.specialized_call_targets.get(key)
  if selected is None && witness is None {
    return Ok(None)
  }
  let declaration = match witness {
    Some(value) => value.declaration
    None => 0UL
  }
  let failure = fn(code, expected, actual, detail) {
    ProgramFunctionLookupFailure::{
      code,
      phase: 5,
      module_id: semantic_id_module(body),
      declaration,
      body,
      expression: expression.reinterpret_as_uint(),
      expected,
      actual,
      detail,
    }
  }
  let witness = match witness {
    Some(value) => value
    None => return Err(failure(304, 1UL, 0UL, 2UL))
  }
  let expected = witness.runtime_evidence_operands
  let span = match selected {
    Some(span) => span
    None => {
      guard expected.is_empty() else {
        return Err(failure(703, expected.length().to_uint64(), 0UL, 0UL))
      }
      return Ok(None)
    }
  }
  let actual = link.specialized_call_runtime_evidence_parameters
  guard program_specialization_span_is_valid(span, actual.length()) else {
    return Err(
      failure(
        101,
        actual.length().to_uint64(),
        (span.start.reinterpret_as_uint().to_uint64() << 32) |
        span.length.reinterpret_as_uint().to_uint64(),
        0UL,
      ),
    )
  }
  guard expected.length() == span.length else {
    return Err(
      failure(703, expected.length().to_uint64(), span.length.to_uint64(), 0UL),
    )
  }
  for index in 0..<span.length {
    let parameter = actual[span.start + index]
    guard parameter == expected[index] else {
      return Err(
        failure(
          704,
          expected[index].reinterpret_as_uint().to_uint64(),
          parameter.reinterpret_as_uint().to_uint64(),
          index.to_uint64(),
        ),
      )
    }
  }
  Ok(selected)
}

///|
fn verify_program_call_evidence_recipes(
  link : PlannedProgramWasmGCLink,
) -> Result[Unit, ProgramFunctionLookupFailure] {
  for key, _ in link.specialized_call_targets {
    match
      check_program_specialized_call_runtime_evidence(
        link,
        key.body,
        key.specialization_abi_key,
        key.expression,
      ) {
      Ok(_) => ()
      Err(failure) => return Err(failure)
    }
  }
  for key, _ in link.specialized_call_runtime_evidence_lookup {
    if !link.specialized_call_targets.contains(key) {
      match
        check_program_specialized_call_runtime_evidence(
          link,
          key.body,
          key.specialization_abi_key,
          key.expression,
        ) {
        Ok(_) => ()
        Err(failure) => return Err(failure)
      }
    }
  }
  Ok(())
}

///|
fn assert_program_call_evidence_recipes(
  link : PlannedProgramWasmGCLink,
) -> Unit {
  match verify_program_call_evidence_recipes(link) {
    Ok(_) => ()
    Err(failure) => abort(@debug.to_string(failure))
  }
}
