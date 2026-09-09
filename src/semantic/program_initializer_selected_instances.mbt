///|
// Dependency analysis consumes the exact logical instance already selected for
// emission. Physical-only specializations can share an unchanged source body;
// query-sensitive generic bodies cannot fall back to their logical template.
fn check_program_initializer_instance(
  lowering : PlannedProgramLowering,
  task : ProgramInitializerDependencyBody,
) -> Result[PlannedModuleLowering, ProgramFunctionLookupFailure] {
  let source = lowering.modules[task.module_index]
  let failure = fn(code, expected, actual) {
    program_initializer_dependency_failure(task.declaration, task.body,
      0xffffffffU, code, expected, actual, 23UL)
  }
  match lowering.compile_time {
    Some(context) => match context.instances.get(task.specialization_key) {
      Some(instance) => {
        guard instance.declaration == task.declaration else {
          return Err(failure(106, task.declaration, instance.declaration))
        }
        guard instance.module_.module_id == source.module_id else {
          return Err(failure(107, source.module_id, instance.module_.module_id))
        }
        Ok(instance.module_)
      }
      None => {
        guard !compile_time_deferred_callable(lowering, source, task.declaration) else {
          return Err(failure(304, 1UL, 0UL))
        }
        Ok(source)
      }
    }
    None => Ok(source)
  }
}

///|
fn check_program_initializer_call_lookup(
  calls : Array[PlannedProgramSpecializedCall],
) -> Result[Map[ProgramSpecializedCallKey, PlannedProgramSpecializedCall], ProgramFunctionLookupFailure] {
  let lookup : Map[ProgramSpecializedCallKey, PlannedProgramSpecializedCall] = {}
  for call in calls {
    let key : ProgramSpecializedCallKey = {
      body: call.caller_body,
      specialization_abi_key: call.caller_specialization_abi_key,
      expression: call.expression,
    }
    match lookup.get(key) {
      Some(previous) => {
        guard previous.target == call.target &&
          previous.target_specialization_abi_key == call.target_specialization_abi_key else {
          return Err(program_initializer_dependency_failure(call.target,
            call.caller_body, call.expression.reinterpret_as_uint(),
            303, 1UL, 2UL, 24UL))
        }
      }
      None => lookup[key] = call
    }
  }
  Ok(lookup)
}

///|
fn check_program_initializer_selected_call(
  caller : PlannedBodyLowering,
  caller_key : String,
  expression : ExprId,
  target : ProgramInitializerDependencyBody,
  calls : Map[ProgramSpecializedCallKey, PlannedProgramSpecializedCall],
) -> Result[ProgramInitializerDependencyBody, ProgramFunctionLookupFailure] {
  let key : ProgramSpecializedCallKey = {
    body: caller.body,
    specialization_abi_key: caller_key,
    expression,
  }
  match calls.get(key) {
    None => Ok(target)
    Some(call) => {
      let failure = fn(code, expected, actual) {
        program_initializer_dependency_failure(caller.declaration, caller.body,
          expression.reinterpret_as_uint(), code, expected, actual, 25UL)
      }
      guard call.caller_body == caller.body else {
        return Err(failure(106, caller.body, call.caller_body))
      }
      guard call.expression == expression else {
        return Err(failure(106, expression.reinterpret_as_uint().to_uint64(),
          call.expression.reinterpret_as_uint().to_uint64()))
      }
      guard call.caller_specialization_abi_key == caller_key else {
        return Err(failure(303, 1UL, 0UL))
      }
      guard call.target == target.declaration else {
        return Err(failure(106, target.declaration, call.target))
      }
      Ok({ ..target, specialization_key: call.target_specialization_abi_key, })
    }
  }
}
