///|
priv struct ProgramInitializerDependencyBody {
  module_index : Int
  declaration : DeclId
  body : BodyId
  kind : HirBodyKind
}

///|
fn program_initializer_dependency_failure(
  declaration : DeclId,
  body : BodyId,
  expression : UInt,
  code : Int,
  expected : UInt64,
  actual : UInt64,
  detail : UInt64,
) -> ProgramFunctionLookupFailure {
  {
    ..program_function_lookup_failure(
      declaration, code, expected, actual, detail,
    ),
    body,
    expression,
  }
}

///|
fn program_initializer_body_kind_code(kind : HirBodyKind) -> UInt64 {
  match kind {
    ModuleLetBody => 0UL
    FunctionBody => 1UL
    ImplMethodBody => 2UL
  }
}

///|
fn check_program_initializer_call_target(
  lowering : PlannedProgramLowering,
  caller : PlannedBodyLowering,
  expression : ExprId,
  target : DeclId,
) -> Result[ProgramInitializerDependencyBody?, ProgramFunctionLookupFailure] {
  let failure = fn(code, expected, actual) {
    program_initializer_dependency_failure(
      caller.declaration,
      caller.body,
      expression.reinterpret_as_uint(),
      code,
      expected,
      actual,
      target,
    )
  }
  let owner = match
    lowering.index.module_lookup.get(semantic_id_module(target)) {
    Some(value) => value
    None => return Err(failure(607, 1UL, 0UL))
  }
  guard owner >= 0 && owner < lowering.modules.length() else {
    return Err(
      failure(
        101,
        lowering.modules.length().to_uint64(),
        owner.reinterpret_as_uint().to_uint64(),
      ),
    )
  }
  let module_ = lowering.modules[owner]
  guard module_.module_id == semantic_id_module(target) else {
    return Err(failure(107, semantic_id_module(target), module_.module_id))
  }
  let functions = module_.functions
  guard functions.module_id == module_.module_id else {
    return Err(failure(106, module_.module_id, functions.module_id))
  }
  let local = semantic_id_local(target)
  guard local >= 0 && local < functions.callable_by_declaration.length() else {
    return Err(
      failure(
        101,
        functions.callable_by_declaration.length().to_uint64(),
        local.reinterpret_as_uint().to_uint64(),
      ),
    )
  }
  let index = functions.callable_by_declaration[local]
  guard index != -1 else { return Err(failure(607, 1UL, 0UL)) }
  guard index >= 0 && index < functions.callables.length() else {
    return Err(
      failure(
        101,
        functions.callables.length().to_uint64(),
        index.reinterpret_as_uint().to_uint64(),
      ),
    )
  }
  let callable = functions.callables[index]
  guard callable.declaration == target else {
    return Err(failure(106, target, callable.declaration))
  }
  let (body, kind) = match callable.kind {
    PlannedFunctionCallable(body) => (body, FunctionBody)
    PlannedImplMethodCallable(_, Some(body)) => (body, ImplMethodBody)
    PlannedBuiltinCallable(_)
    | PlannedForeignCallable(_, _, _)
    | PlannedTraitMethodCallable(_)
    | PlannedImplMethodCallable(_, None) => return Ok(None)
  }
  // Check identity even when another call edge already visited this body.
  match check_program_link_body_identity(module_, target, body) {
    Err(error) => return Err(error)
    Ok(_) => Ok(Some({ module_index: owner, declaration: target, body, kind, }))
  }
}
