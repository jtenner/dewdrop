///|
fn check_program_initializer_source(
  module_ : PlannedModuleLowering,
  declaration : DeclId,
  body : BodyId,
) -> Result[PlannedBodyLowering, ProgramFunctionLookupFailure] {
  let failure = fn(code, expected, actual, detail) {
    {
      ..program_function_lookup_failure(declaration, code, expected, actual, detail),
      module_id: module_.module_id,
      body,
    }
  }
  guard semantic_id_module(declaration) == module_.module_id else {
    return Err(failure(107, module_.module_id, semantic_id_module(declaration), 0UL))
  }
  guard semantic_id_module(body) == module_.module_id else {
    return Err(failure(107, module_.module_id, semantic_id_module(body), 1UL))
  }
  let index = semantic_id_local(body)
  guard index >= 0 && index < module_.bodies.length() else {
    return Err(failure(101, module_.bodies.length().to_uint64(), index.reinterpret_as_uint().to_uint64(), 2UL))
  }
  let source = module_.bodies[index]
  guard source.body == body else {
    return Err(failure(106, body, source.body, 3UL))
  }
  guard source.declaration == declaration else {
    return Err(failure(106, declaration, source.declaration, 4UL))
  }
  match program_specialization_shape_error(source.root_shape) {
    None => ()
    Some("generic") => return Err(failure(301, 0UL, 1UL, 5UL))
    Some("error") => return Err(failure(301, 0UL, 2UL, 5UL))
    Some(_) => return Err(failure(301, 0UL, 3UL, 5UL))
  }
  match source.kind {
    ModuleLetBody => ()
    FunctionBody => return Err(failure(106, 0UL, 1UL, 6UL))
    ImplMethodBody => return Err(failure(106, 0UL, 2UL, 6UL))
  }
  match check_planned_body_arenas(module_, source, 5) {
    Ok(_) => Ok(source)
    Err(error) => Err({
      code: error.code,
      phase: error.phase,
      module_id: error.module_id,
      declaration: error.declaration,
      body: error.body,
      expression: error.expression,
      expected: error.expected,
      actual: error.actual,
      detail: error.detail,
    })
  }
}

///|
fn assert_program_initializer_source(
  module_ : PlannedModuleLowering,
  declaration : DeclId,
  body : BodyId,
) -> PlannedBodyLowering {
  match check_program_initializer_source(module_, declaration, body) {
    Ok(source) => source
    Err(failure) => abort(@debug.to_string(failure))
  }
}
