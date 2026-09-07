///|
// Resolve the selected semantic call once. Do not search by a runtime name or
// use another specialization when the exact pattern call map is missing.
fn starshine_match_string_call(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  body : @semantic.BodyId,
  expression : @semantic.ExprId,
  declaration : @semantic.DeclId,
  arguments : @semantic.HirSpan,
  specialization : StarshineGenericSpecialization?,
  subject : Array[@lib.Instruction],
  literal : Array[@lib.Instruction],
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  let key = match specialization {
    Some(value) => value.specialization_abi_key
    None => ""
  }
  let (function_index, parameter_span, result_span, value_types, kind) = match
    program {
    Some(link) => {
      let function_ = match
        link.specialized_call_function(body, key, expression) {
        Some(value) => value
        None => {
          if arguments.length != 0 {
            return Err(MissingFunction(declaration))
          }
          match link.function_of(declaration) {
            Some(value) if value.specialization_abi_key == "" => value
            _ => return Err(MissingFunction(declaration))
          }
        }
      }
      if function_.declaration != declaration {
        return Err(MissingFunction(declaration))
      }
      (
        function_.function_index,
        function_.parameters,
        function_.results,
        link.modules[function_.module_index].function_value_types,
        function_.kind,
      )
    }
    None => {
      if arguments.length != 0 {
        return Err(MissingFunction(declaration))
      }
      let function_ = match planned.function_of(declaration) {
        Some(value) if value.specialization_abi_key == "" => value
        _ => return Err(MissingFunction(declaration))
      }
      (
        function_.function_index,
        function_.parameters,
        function_.results,
        planned.function_value_types,
        function_.kind,
      )
    }
  }
  if kind is @semantic.PlannedWasmSignatureOnlyFunction {
    return Err(SignatureOnlyCall(declaration))
  }
  if function_index < 0 {
    return Err(MissingFunction(declaration))
  }
  let parameters : Array[@semantic.PlannedWasmValueType] = []
  let results : Array[@semantic.PlannedWasmValueType] = []
  for pair in [(parameter_span, parameters), (result_span, results)] {
    let (span, values) = pair
    guard span.start >= 0 &&
      span.length >= 0 &&
      span.start <= value_types.length() &&
      span.length <= value_types.length() - span.start else {
      abort("ARN-101 String pattern function signature is outside its arena")
    }
    for index in 0..<span.length {
      values.push(value_types[span.start + index])
    }
  }
  let mut valid = parameters.length() == 2 &&
    results.length() == 1 &&
    results[0] is @semantic.WasmI32Value
  for parameter in parameters {
    match parameter {
      @semantic.WasmStringRefValue | @semantic.WasmNullableEqRefValue => ()
      _ => valid = false
    }
  }
  if !valid {
    return Err(
      InvalidPatternEqualitySignature(
        body, expression, declaration, parameters, results,
      ),
    )
  }
  let output = subject.copy()
  append_starshine_instructions(output, literal)
  output.push(
    @lib.Instruction::call(
      @lib.FuncIdx::new(function_index.reinterpret_as_uint()),
    ),
  )
  Ok(output)
}
