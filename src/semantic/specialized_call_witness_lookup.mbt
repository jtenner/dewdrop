///|
fn check_program_specialized_call_lookup(
  link : PlannedProgramWasmGCLink,
  body : BodyId,
  caller_key : String,
  expression : ExprId,
) -> Result[PlannedProgramWasmFunction?, ProgramFunctionLookupFailure] {
  let key = program_specialized_call_key(body, caller_key, expression)
  let index = link.specialized_call_lookup.get(key)
  let witness = link.specialized_call_targets.get(key)
  if index is None && witness is None {
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
  let index = match index {
    Some(value) => value
    None => return Err(failure(304, 1UL, 0UL, 0UL))
  }
  guard index >= 0 && index < link.functions.length() else {
    return Err(
      failure(
        101,
        link.functions.length().to_uint64(),
        index.reinterpret_as_uint().to_uint64(),
        0UL,
      ),
    )
  }
  let witness = match witness {
    Some(value) => value
    None => return Err(failure(304, 1UL, 0UL, 1UL))
  }
  let target = link.functions[index]
  guard target.declaration == witness.declaration else {
    return Err(
      failure(701, witness.declaration, target.declaration, index.to_uint64()),
    )
  }
  guard target.specialization_abi_key == witness.specialization_abi_key else {
    return Err(failure(701, 1UL, 0UL, (1UL << 32) | index.to_uint64()))
  }
  guard target.function_index == witness.function_index else {
    return Err(
      failure(
        701,
        witness.function_index.reinterpret_as_uint().to_uint64(),
        target.function_index.reinterpret_as_uint().to_uint64(),
        (2UL << 32) | index.to_uint64(),
      ),
    )
  }
  guard index == witness.function_table_index else {
    return Err(
      failure(
        701,
        witness.function_table_index.reinterpret_as_uint().to_uint64(),
        index.to_uint64(),
        3UL << 32,
      ),
    )
  }
  Ok(Some(target))
}

///|
fn verify_program_specialized_call_lookups(
  link : PlannedProgramWasmGCLink,
) -> Result[Unit, ProgramFunctionLookupFailure] {
  for key, _ in link.specialized_call_lookup {
    match
      check_program_specialized_call_lookup(
        link,
        key.body,
        key.specialization_abi_key,
        key.expression,
      ) {
      Ok(_) => ()
      Err(failure) => return Err(failure)
    }
  }
  for key, witness in link.specialized_call_targets {
    if !link.specialized_call_lookup.contains(key) {
      return Err({
        code: 304,
        phase: 5,
        module_id: semantic_id_module(key.body),
        declaration: witness.declaration,
        body: key.body,
        expression: key.expression.reinterpret_as_uint(),
        expected: 1UL,
        actual: 0UL,
        detail: 0UL,
      })
    }
  }
  Ok(())
}

///|
fn assert_program_specialized_call_lookups(
  link : PlannedProgramWasmGCLink,
) -> Unit {
  match verify_program_specialized_call_lookups(link) {
    Ok(_) => ()
    Err(failure) => abort(@debug.to_string(failure))
  }
}
