///|
pub struct StarshineCompilerInvariantFailure {
  code : UInt
  phase : UInt
  module_id : @semantic.ModuleId
  declaration : @semantic.DeclId
  body : @semantic.BodyId
  expression : UInt
  expected : UInt64
  actual : UInt64
  detail : UInt64
} derive(Eq, Debug)

///|
fn starshine_planned_call_target(
  planned : @semantic.PlannedProgramWasmGCLink,
  caller_module : @semantic.ModuleId,
  body : @semantic.BodyId,
  expression : @semantic.ExprId,
  declaration : @semantic.DeclId,
  caller_key : String,
  has_type_arguments : Bool,
) -> Result[@semantic.PlannedProgramWasmFunction?, StarshineCodeEmissionError] {
  let failure = fn(code, expected, actual, detail) {
    CompilerInvariantFailure({
      code,
      phase: 7U,
      module_id: caller_module,
      declaration,
      body,
      expression: expression.reinterpret_as_uint(),
      expected,
      actual,
      detail,
    })
  }
  let key = @semantic.program_specialized_call_key(body, caller_key, expression)
  match planned.specialized_call_lookup.get(key) {
    Some(index) => {
      guard index >= 0 && index < planned.functions.length() else {
        return Err(
          failure(
            101U,
            planned.functions.length().to_uint64(),
            index.reinterpret_as_uint().to_uint64(),
            0UL,
          ),
        )
      }
      let witness = match planned.specialized_call_targets.get(key) {
        Some(value) => value
        None => return Err(failure(304U, 1UL, 0UL, 1UL))
      }
      let target = planned.functions[index]
      guard target.declaration == witness.declaration else {
        return Err(
          failure(
            701U,
            witness.declaration,
            target.declaration,
            index.to_uint64(),
          ),
        )
      }
      guard target.specialization_abi_key == witness.specialization_abi_key else {
        return Err(failure(701U, 1UL, 0UL, (1UL << 32) | index.to_uint64()))
      }
      guard target.function_index == witness.function_index else {
        return Err(
          failure(
            701U,
            witness.function_index.reinterpret_as_uint().to_uint64(),
            target.function_index.reinterpret_as_uint().to_uint64(),
            (2UL << 32) | index.to_uint64(),
          ),
        )
      }
      guard index == witness.function_table_index else {
        return Err(
          failure(
            701U,
            witness.function_table_index.reinterpret_as_uint().to_uint64(),
            index.to_uint64(),
            3UL << 32,
          ),
        )
      }
      Ok(Some(target))
    }
    None if has_type_arguments =>
      // Physical shape equality cannot prove a logical query or trait target,
      // even when there is only one linked shape-compatible candidate.
      Err(failure(304U, 1UL, 0UL, 0UL))
    None => Ok(planned.function_of(declaration))
  }
}
