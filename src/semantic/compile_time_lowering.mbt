///|
fn compile_time_builtin_targets(
  lowering : PlannedProgramLowering,
) -> Map[DeclId, Bytes] {
  let result : Map[DeclId, Bytes] = Map([])
  for module_ in lowering.modules {
    for callable in module_.functions.callables {
      match callable.kind {
        PlannedBuiltinCallable(name) if compile_time_type_query_arity(name)
          is Some(_) ||
          name == b"types.static_assert" ||
          computed_type_builtin(name) => result[callable.declaration] = name
        _ => ()
      }
    }
  }
  result
}

///|
fn compile_time_fold_call(
  context : CompileTimeProgramContext,
  module_ : PlannedModuleLowering,
  source : PlannedExpression,
  name : Bytes,
  receiver : ExprId,
  arguments : HirSpan,
  type_arguments : HirSpan,
  bindings : Map[GenericParameterId, CompileTimeType],
  evidence : CompileTimeEvidenceSearch?,
) -> Result[PlannedExpression?, String] {
  if computed_type_builtin(name) {
    return Err("CT-036 a type-producing query must be used in a type position")
  }
  if receiver >= 0 || arguments.length != 0 {
    return Err("CT-001 type query requires zero runtime operands")
  }
  let types = match
    compile_time_read_arguments(module_, type_arguments, bindings) {
    Ok(types) => types
    Err(error) => return Err("CT-002 " + @debug.to_string(error))
  }
  let evaluated = if name == b"types.field_names" ||
    name == b"types.variant_names" {
    evaluate_compile_time_names(context, name, types)
  } else if name == b"types.implements" {
    match evidence {
      Some(search) => evaluate_compile_time_implements(search, types)
      None => Err("CT-010 missing trait evidence context")
    }
  } else {
    match evaluate_compile_time_type_query(name, types) {
      Ok(value) => Ok(value)
      Err(error) => Err("CT-002 " + @debug.to_string(error))
    }
  }
  let result = match evaluated {
    Ok(Some(value)) => value
    Ok(None) => return Ok(None)
    Err(error) => return Err(error)
  }
  let declared_result = match
    compile_time_read_type(module_, source.type_, bindings) {
    Ok(value) => value
    Err(error) => return Err("CT-003 " + @debug.to_string(error))
  }
  let expected = match result {
    CtBool(_) => CtPrimitive(BoolType)
    CtU32(_) => CtPrimitive(U32Type)
    CtStringArray(_) =>
      CtApplied(CtNominal(standard_array_type_declaration()), [
        CtPrimitive(StringType),
      ])
  }
  if declared_result != expected {
    return Err("CT-003 query declaration has the wrong result type")
  }
  let kind = match result {
    CtBool(value) => PlannedBoolConst(value)
    CtU32(value) => PlannedU32Const(value.reinterpret_as_uint().to_uint64())
    CtStringArray(values) => PlannedStringArrayConst(values)
  }
  Ok(Some({ ..source, kind, }))
}

///|
// Required even in debug builds. Generic templates keep their queries until
// exact logical arguments are available for a specific instance.
fn fold_program_compile_time_queries(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
) -> PlannedProgramLowering {
  let targets = compile_time_builtin_targets(lowering)
  if targets.length() == 0 {
    return lowering
  }
  let context = compile_time_program_context(
    program, analyzed, lowering, targets,
  )
  for index, module_ in lowering.modules {
    fold_module_compile_time_queries(context, index, module_, {}, None)
  }
  { ..lowering, compile_time: Some(context), }
}

///|
fn fold_module_compile_time_queries(
  context : CompileTimeProgramContext,
  module_index : Int,
  module_ : PlannedModuleLowering,
  bindings : Map[GenericParameterId, CompileTimeType],
  active : DeclId?,
) -> Unit {
  let mut has_queries = false
  for source in module_.expressions {
    if source.kind is PlannedDirectCall(target, _, _, _) &&
      context.targets.contains(target) {
      has_queries = true
      break
    }
  }
  if !has_queries {
    return
  }
  let errors : Map[Int, String] = Map([])
  let mut evidence : CompileTimeEvidenceSearch? = None
  for index, source in module_.expressions {
    if !compile_time_in_body(module_, index, active) ||
      (active is None && compile_time_generic_expression(module_, index)) {
      continue
    }
    match source.kind {
      PlannedDirectCall(target, receiver, arguments, type_arguments) => {
        let name = match context.targets.get(target) {
          Some(value) => value
          None => continue
        }
        if name == b"types.static_assert" {
          continue
        }
        if name == b"types.implements" {
          if evidence is None {
            let collected = context.program.modules[module_index]
            let resolved = context.analyzed.frozen.interfaces[module_index].resolved_types
            let imports = context.analyzed.modules[module_index].imports
            evidence = Some({
              collected,
              resolved,
              module_,
              imports,
              index: build_module_impl_index_with_imports(
                collected, resolved, imports,
              ),
              active: [],
              steps: 0,
              include_test_impls: false,
            })
          }
          let search = evidence.unwrap()
          search.include_test_impls = match
            compile_time_expression_owner(module_, index) {
            Some(declaration) =>
              search.collected.declaration_is_test_only(declaration)
            None => false
          }
        }
        match
          compile_time_fold_call(
            context, module_, source, name, receiver, arguments, type_arguments,
            bindings, evidence,
          ) {
          Ok(Some(replacement)) => module_.expressions[index] = replacement
          Ok(None) =>
            if active is Some(_) {
              errors[index] = "CT-004 type query remains unresolved in a concrete instance"
            }
          Err(message) => errors[index] = message
        }
      }
      _ => ()
    }
  }
  fold_program_constants([module_])
  prune_compile_time_branches(module_, active)
  for expression, source in module_.expressions {
    if !compile_time_in_body(module_, expression, active) ||
      (active is None && compile_time_generic_expression(module_, expression)) {
      continue
    }
    // A failed query in a discarded arm is not evaluated.
    if source.kind is PlannedPoisonExpression {
      continue
    }
    let error = match errors.get(expression) {
      Some(message) => Some(message)
      None =>
        match source.kind {
          PlannedDirectCall(target, receiver, arguments, type_arguments) if context.targets.get(
              target,
            ) ==
            Some(b"types.static_assert") =>
            match
              fold_compile_time_assertion(
                module_, source, receiver, arguments, type_arguments,
              ) {
              Ok(replacement) => {
                module_.expressions[expression] = replacement
                None
              }
              Err(message) => Some(message)
            }
          _ => None
        }
    }
    match error {
      Some(message) => {
        module_.diagnostics.push(
          CompileTimeQueryDiagnostic(expression, message, source.offset),
        )
        module_.expressions[expression] = {
          ..source,
          kind: PlannedPoisonExpression,
        }
      }
      None => ()
    }
  }
}

///|
fn fold_compile_time_assertion(
  module_ : PlannedModuleLowering,
  source : PlannedExpression,
  receiver : ExprId,
  arguments : HirSpan,
  type_arguments : HirSpan,
) -> Result[PlannedExpression, String] {
  if receiver >= 0 ||
    arguments.length != 2 ||
    type_arguments.length != 0 ||
    !program_specialization_span_is_valid(
      arguments,
      module_.expression_children.length(),
    ) {
    return Err(
      "CT-001 static_assert requires a condition and message, with no type arguments",
    )
  }
  let result_type = compile_time_read_type(module_, source.type_, {})
  if result_type != Ok(CtPrimitive(UnitType)) {
    return Err("CT-003 static_assert must return Unit")
  }
  let condition = module_.expression_children[arguments.start]
  let message = module_.expression_children[arguments.start + 1]
  let text = match module_.expressions[message].kind {
    PlannedStringConst(text) => @utf8.decode_lossy(text)
    _ =>
      return Err("CT-020 static_assert message must be a compile-time string")
  }
  match module_.expressions[condition].kind {
    PlannedBoolConst(false) => Err("CT-021 static assertion failed: " + text)
    PlannedBoolConst(true) =>
      // An empty evaluation sequence, with the original logical Unit type.
      // It supplies no value and does not create a runtime intrinsic call.
      Ok({
        ..source,
        kind: PlannedProductNew({
          start: module_.expression_children.length(),
          length: 0,
        }),
      })
    _ => Err("CT-022 static_assert condition is not a compile-time Boolean")
  }
}
