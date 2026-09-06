///|
// Select logical query bodies before nominal layout planning. This pass creates
// no signatures, function indices, or physical carrier requests.
fn compile_time_demand_instances(
  lowering : PlannedProgramLowering,
) -> Map[DeclId, Array[PlannedModuleLowering]] {
  let selected : Map[DeclId, Array[PlannedModuleLowering]] = {}
  let context = match lowering.compile_time {
    Some(value) => value
    None => return selected
  }
  if context.sensitive.is_empty() {
    return selected
  }
  let work : Array[(PlannedModuleLowering, PlannedBodyLowering, String)] = []
  let seen : Map[String, Bool] = {}
  let temporary : Array[String] = []
  for module_ in lowering.modules {
    for body in module_.bodies {
      if module_.functions.callable_of(body.declaration) is Some(callable) &&
        program_callable_generic_parameters(callable).length > 0 {
        continue
      }
      work.push((module_, body, ""))
    }
  }
  while work.length() > 0 {
    let (module_, body, caller_key) = work.pop().unwrap()
    for id in compile_time_owned_expressions(module_, body) {
      let expression = module_.expressions[id]
      let (declaration, arguments) = match
        program_evidence_target_and_arguments(expression) {
        Some(value) => value
        None => continue
      }
      if !context.sensitive.contains(declaration) ||
        context.targets.contains(declaration) {
        continue
      }
      let owner = lowering.index.declaration_owner(declaration).unwrap()
      let callable = lowering.modules[owner].functions
        .callable_of(declaration)
        .unwrap()
      if program_callable_generic_parameters(callable).length == 0 {
        continue
      }
      let types = compile_time_call_arguments(
        lowering,
        module_,
        caller_key,
        arguments,
        expression.kind is PlannedFunctionReference(_, _),
      )
      if compile_time_types_are_concrete(types) != Ok(true) {
        continue
      }
      let key = match
        compile_time_specialization_key(
          lowering,
          declaration,
          "demand:" + declaration.to_string(),
          types,
          false,
        ) {
        Some(value) => value
        None => continue
      }
      if seen.contains(key) {
        continue
      }
      seen[key] = true
      temporary.push(key)
      let instance = context.instances[key].module_
      match selected.get(declaration) {
        Some(values) => values.push(instance)
        None => selected[declaration] = [instance]
      }
      for body in instance.bodies {
        if body.declaration == declaration {
          work.push((instance, body, key))
        }
      }
    }
  }
  for key in temporary {
    context.instances.remove(key)
  }
  selected
}

///|
fn compile_time_demand_modules(
  lowering : PlannedProgramLowering,
  module_ : PlannedModuleLowering,
  declaration : DeclId,
  selected : Map[DeclId, Array[PlannedModuleLowering]],
) -> Array[PlannedModuleLowering] {
  if compile_time_deferred_callable(lowering, module_, declaration) {
    selected.get(declaration).unwrap_or([])
  } else {
    [module_]
  }
}

///|
fn compile_time_deferred_callable(
  lowering : PlannedProgramLowering,
  module_ : PlannedModuleLowering,
  declaration : DeclId,
) -> Bool {
  match lowering.compile_time {
    Some(context) if context.sensitive.contains(declaration) =>
      match module_.functions.callable_of(declaration) {
        Some(callable) =>
          program_callable_generic_parameters(callable).length > 0
        None => false
      }
    _ => false
  }
}

///|
fn compile_time_deferred_declarations(
  lowering : PlannedProgramLowering,
  module_ : PlannedModuleLowering,
) -> Map[DeclId, Bool] {
  let result = {}
  for callable in module_.functions.callables {
    if compile_time_deferred_callable(lowering, module_, callable.declaration) {
      result[callable.declaration] = true
    }
  }
  result
}

///|
fn compile_time_shape_has_reference(shape : PlannedValueShape) -> Bool {
  match shape {
    RefPlannedValueShape => true
    ProductPlannedValueShape(fields) =>
      fields.any(compile_time_shape_has_reference)
    _ => false
  }
}

///|
fn compile_time_demand_expressions(
  lowering : PlannedProgramLowering,
  module_ : PlannedModuleLowering,
  selected : Map[DeclId, Array[PlannedModuleLowering]],
) -> Array[PlannedExpression] {
  let result = []
  for body in module_.bodies {
    for
      instance in compile_time_demand_modules(
        lowering,
        module_,
        body.declaration,
        selected,
      ) {
      for id in compile_time_owned_expressions(instance, body) {
        result.push(instance.expressions[id])
      }
    }
  }
  result
}
