///|
fn program_runtime_trait_callable_supports_external_evidence_for_classes(
  lowering : PlannedProgramLowering,
  module_lookup : Map[ModuleId, Int],
  declaration : DeclId,
  parameter_classes : Array[ProgramExternalRuntimeEvidenceClass],
  states : Map[String, Int],
) -> Bool {
  let key = program_external_runtime_evidence_state_key(
    declaration, parameter_classes,
  )
  match states.get(key) {
    Some(2) => return true
    Some(3) => return false
    _ => ()
  }
  // Discover the entire reachable support graph before publishing any result.
  // A recursive back edge is not a completed proof: a later failed member
  // invalidates every caller in that cycle.
  let work = [(key, declaration, parameter_classes.copy())]
  let seen : Map[String, Bool] = Map([(key, true)])
  let callers : Map[String, Array[String]] = {}
  let failed : Map[String, Bool] = {}
  let failures : Array[String] = []
  let mut head = 0
  while head < work.length() {
    let (current, target, classes) = work[head]
    head += 1
    let supported = match states.get(current) {
      Some(2) => true
      Some(3) => false
      _ =>
        program_collect_runtime_trait_support_dependencies(
          lowering,
          module_lookup,
          target,
          classes,
          fn(child, child_classes) {
            let child_key = program_external_runtime_evidence_state_key(
              child, child_classes,
            )
            match callers.get(child_key) {
              Some(values) => values.push(current)
              None => callers[child_key] = [current]
            }
            if !seen.contains(child_key) {
              seen[child_key] = true
              work.push((child_key, child, child_classes.copy()))
            }
          },
        )
    }
    if !supported {
      failed[current] = true
      failures.push(current)
    }
  }
  head = 0
  while head < failures.length() {
    let current = failures[head]
    head += 1
    match callers.get(current) {
      Some(values) =>
        for caller in values {
          if !failed.contains(caller) {
            failed[caller] = true
            failures.push(caller)
          }
        }
      None => ()
    }
  }
  for request in work {
    let (current, _, _) = request
    states[current] = if failed.contains(current) { 3 } else { 2 }
  }
  !failed.contains(key)
}

///|
fn program_collect_runtime_trait_support_dependencies(
  lowering : PlannedProgramLowering,
  module_lookup : Map[ModuleId, Int],
  declaration : DeclId,
  parameter_classes : Array[ProgramExternalRuntimeEvidenceClass],
  dependency : (DeclId, Array[ProgramExternalRuntimeEvidenceClass]) -> Unit,
) -> Bool {
  let module_index = match module_lookup.get(semantic_id_module(declaration)) {
    Some(value) => value
    None => return false
  }
  if module_index < 0 || module_index >= lowering.modules.length() {
    return false
  }
  let module_ = lowering.modules[module_index]
  let callable = match module_.functions.callable_of(declaration) {
    Some(value) => value
    None => return false
  }
  let body_id = match callable.kind {
    PlannedFunctionCallable(body) | PlannedImplMethodCallable(_, Some(body)) =>
      body
    _ => return false
  }
  let body_index = semantic_id_local(body_id)
  if body_index < 0 || body_index >= module_.bodies.length() {
    return false
  }
  let body = module_.bodies[body_index]
  for expression in compile_time_owned_expressions(module_, body) {
    let in_lambda = expression < body.expressions.start ||
      expression - body.expressions.start >= body.expressions.length
    match module_.expressions[expression].kind {
      PlannedBoundDirectCall(_, slot, receiver, _, _) =>
        if receiver < 0 || slot < 0 || slot >= parameter_classes.length() {
          return false
        } else if in_lambda &&
          parameter_classes[slot] != ProgramExternalConcreteEvidence {
          return false
        }
      PlannedBoundOperatorCall(_, slot, _, _, _, _) =>
        if slot < 0 || slot >= parameter_classes.length() {
          return false
        } else if in_lambda &&
          parameter_classes[slot] != ProgramExternalConcreteEvidence {
          return false
        }
      _ => ()
    }
    if !module_.expression_evidence.is_empty() &&
      (expression < 0 || expression >= module_.expression_evidence.length()) {
      return false
    }
    let call = program_evidence_target_and_arguments(
      module_.expressions[expression],
    )
    // The lowering omits this optional table when there are no expression
    // obligations. A present but truncated table is not an empty proof.
    let roots = if module_.expression_evidence.is_empty() {
      { start: 0, length: 0, }
    } else {
      module_.expression_evidence[expression]
    }
    if roots.start < 0 ||
      roots.length < 0 ||
      roots.start > module_.trait_evidence_roots.length() ||
      roots.length > module_.trait_evidence_roots.length() - roots.start {
      return false
    }
    let target_classes : Array[ProgramExternalRuntimeEvidenceClass] = []
    for index in 0..<roots.length {
      let root = module_.trait_evidence_roots[roots.start + index]
      let class_ = match
        program_external_runtime_evidence_class(
          module_, root, parameter_classes,
        ) {
        Some(value) => value
        None => return false
      }
      target_classes.push(class_)
    }
    let has_runtime = target_classes.any(class_ => {
      class_ != ProgramExternalConcreteEvidence
    })
    if has_runtime {
      // Source lambdas have no dictionary capture recipe yet. A concrete
      // instance remains valid, but this optional runtime export is unproved.
      if in_lambda {
        return false
      }
      match call {
        Some((target, arguments)) if arguments.length > 0 =>
          dependency(target, target_classes)
        None =>
          match module_.expressions[expression].kind {
            PlannedParameterSelect(_, _) => ()
            _ => return false
          }
        _ => return false
      }
    }
    match module_.expressions[expression].trait_object_coercion {
      SelectedInferredTraitObjectCoercion(_, evidence) =>
        match
          program_external_runtime_evidence_class(
            module_, evidence, parameter_classes,
          ) {
          Some(ProgramExternalConcreteEvidence) => ()
          Some(ProgramExternalDirectRuntimeEvidence)
          | Some(ProgramExternalCapturedRuntimeEvidence) =>
            if in_lambda {
              return false
            }
          None => return false
        }
      ErrorInferredTraitObjectCoercion => return false
      NoInferredTraitObjectCoercion => ()
    }
  }
  true
}
