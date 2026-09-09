///|
fn check_program_initializer_candidate_lookup(
  candidates : Array[PlannedProgramModuleInitializer],
) -> Result[Map[DeclId, Int], ProgramFunctionLookupFailure] {
  let lookup : Map[DeclId, Int] = {}
  for index, initializer in candidates {
    guard !lookup.contains(initializer.declaration) else {
      return Err(program_initializer_dependency_failure(initializer.declaration,
        initializer.body, 0xffffffffU, 504, 1UL, 2UL, (16UL << 32) | index.to_uint64()))
    }
    lookup[initializer.declaration] = index
  }
  Ok(lookup)
}

///|
fn check_program_initializer_dependencies(
  lowering : PlannedProgramLowering,
  initializer : PlannedProgramModuleInitializer,
  initializer_lookup : Map[DeclId, Int],
  candidates : Array[PlannedProgramModuleInitializer],
) -> Result[Array[Int], ProgramFunctionLookupFailure] {
  let dependencies : Array[Int] = []
  let seen_dependencies : Map[Int, Bool] = {}
  let seen_bodies : Map[BodyId, Bool] = {}
  let work : Array[ProgramInitializerDependencyBody] = [{
    module_index: initializer.module_index,
    declaration: initializer.declaration,
    body: initializer.body,
    kind: ModuleLetBody,
  }]
  while work.length() > 0 {
    let task = match work.pop() {
      Some(value) => value
      None => return Err(program_initializer_dependency_failure(
        initializer.declaration, initializer.body, 0xffffffffU, 103, 1UL, 0UL, 21UL))
    }
    let failure = fn(code, expected, actual, detail) {
      program_initializer_dependency_failure(task.declaration, task.body,
        0xffffffffU, code, expected, actual, detail)
    }
    guard task.module_index >= 0 && task.module_index < lowering.modules.length() else {
      return Err(failure(101, lowering.modules.length().to_uint64(), task.module_index.reinterpret_as_uint().to_uint64(), 20UL))
    }
    let module_ = lowering.modules[task.module_index]
    let body = match check_program_link_body_identity(module_, task.declaration, task.body) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    guard body.kind == task.kind else {
      return Err(failure(106, program_initializer_body_kind_code(task.kind), program_initializer_body_kind_code(body.kind), 22UL))
    }
    if seen_bodies.contains(body.body) { continue }
    match check_program_link_body_arenas(module_, body) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
    seen_bodies[body.body] = true
    for expression in body.expressions.start..<(body.expressions.start + body.expressions.length) {
      match module_.expressions[expression].kind {
        PlannedModuleValueGet(declaration, _) => {
          let value_failure = fn(code, expected, actual) {
            program_initializer_dependency_failure(body.declaration, body.body,
              expression.reinterpret_as_uint(), code, expected, actual, declaration)
          }
          let dependency = match initializer_lookup.get(declaration) {
            Some(value) => value
            None => return Err(value_failure(504, 1UL, 0UL))
          }
          guard dependency >= 0 && dependency < candidates.length() else {
            return Err(value_failure(101, candidates.length().to_uint64(), dependency.reinterpret_as_uint().to_uint64()))
          }
          guard candidates[dependency].declaration == declaration else {
            return Err(value_failure(106, declaration, candidates[dependency].declaration))
          }
          if !seen_dependencies.contains(dependency) {
            seen_dependencies[dependency] = true
            dependencies.push(dependency)
          }
        }
        PlannedDirectCall(target, _, _, _)
        | PlannedTailCall(target, _, _, _)
        | PlannedOperatorCall(target, _, _, _, _)
        | PlannedIndexCall(target, _, _, _)
        | PlannedIndexSetCall(target, _, _, _, _) => {
          match check_program_initializer_call_target(lowering, body, expression, target) {
            Err(error) => return Err(error)
            Ok(None) => ()
            Ok(Some(next)) => if !seen_bodies.contains(next.body) { work.push(next) }
          }
        }
        _ => ()
      }
    }
  }
  Ok(dependencies)
}
