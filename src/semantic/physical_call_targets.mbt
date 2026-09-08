///|
pub struct PlannedProgramPhysicalCallTarget {
  declaration : DeclId
  specialization_abi_key : String
  function_index : Int
  function_table_index : Int
  runtime_evidence_operands : Array[Int]
} derive(Eq, Debug)

///|
fn record_program_physical_call_target(
  targets : Map[ProgramSpecializedCallKey, PlannedProgramPhysicalCallTarget],
  call : PlannedProgramSpecializedCall,
  index : Int,
  function_ : PlannedProgramWasmFunction,
  evidence_parameters : Array[Int],
) -> Result[Unit, ProgramFunctionLookupFailure] {
  guard call.target == function_.declaration else {
    return Err(
      program_physical_call_target_failure(
        call,
        504,
        call.target,
        function_.declaration,
        6UL,
      ),
    )
  }
  guard call.target_specialization_abi_key == function_.specialization_abi_key else {
    return Err(program_physical_call_target_failure(call, 504, 1UL, 0UL, 7UL))
  }
  let span = call.runtime_evidence_parameters
  guard program_specialization_span_is_valid(span, evidence_parameters.length()) else {
    return Err(
      program_physical_call_target_failure(
        call,
        101,
        evidence_parameters.length().to_uint64(),
        (span.start.reinterpret_as_uint().to_uint64() << 32) |
        span.length.reinterpret_as_uint().to_uint64(),
        4UL,
      ),
    )
  }
  let operands : Array[Int] = []
  for index in 0..<span.length {
    let parameter = evidence_parameters[span.start + index]
    guard parameter >= 0 else {
      return Err(
        program_physical_call_target_failure(
          call,
          704,
          0UL,
          parameter.reinterpret_as_uint().to_uint64(),
          index.to_uint64(),
        ),
      )
    }
    operands.push(parameter)
  }
  let key = program_specialized_call_key(
    call.caller_body,
    call.caller_specialization_abi_key,
    call.expression,
  )
  let target = {
    declaration: call.target,
    specialization_abi_key: call.target_specialization_abi_key,
    function_index: function_.function_index,
    function_table_index: index,
    runtime_evidence_operands: operands,
  }
  match targets.get(key) {
    Some(previous) if previous != target => {
      let (expected, actual, detail) = if previous.declaration !=
        target.declaration {
        (previous.declaration, target.declaration, 0UL)
      } else if previous.specialization_abi_key != target.specialization_abi_key {
        (1UL, 0UL, 1UL)
      } else if previous.function_index != target.function_index {
        (
          previous.function_index.reinterpret_as_uint().to_uint64(),
          target.function_index.reinterpret_as_uint().to_uint64(),
          2UL,
        )
      } else if previous.function_table_index != target.function_table_index {
        (
          previous.function_table_index.reinterpret_as_uint().to_uint64(),
          target.function_table_index.reinterpret_as_uint().to_uint64(),
          3UL,
        )
      } else if previous.runtime_evidence_operands.length() != operands.length() {
        (
          previous.runtime_evidence_operands.length().to_uint64(),
          operands.length().to_uint64(),
          4UL,
        )
      } else {
        let mut different = -1
        for index in 0..<operands.length() {
          if previous.runtime_evidence_operands[index] != operands[index] {
            different = index
            break
          }
        }
        guard different >= 0 else {
          return Err(
            program_physical_call_target_failure(call, 303, 1UL, 0UL, 6UL << 32),
          )
        }
        (
          previous.runtime_evidence_operands[different].to_uint64(),
          operands[different].to_uint64(),
          (5UL << 32) | different.to_uint64(),
        )
      }
      Err(
        program_physical_call_target_failure(
          call, 303, expected, actual, detail,
        ),
      )
    }
    Some(_) => Ok(())
    None => {
      targets[key] = target
      Ok(())
    }
  }
}

///|
fn program_physical_call_target_failure(
  call : PlannedProgramSpecializedCall,
  code : Int,
  expected : UInt64,
  actual : UInt64,
  detail : UInt64,
) -> ProgramFunctionLookupFailure {
  {
    code,
    phase: 5,
    module_id: semantic_id_module(call.caller_body),
    declaration: call.target,
    body: call.caller_body,
    expression: call.expression.reinterpret_as_uint(),
    expected,
    actual,
    detail,
  }
}
