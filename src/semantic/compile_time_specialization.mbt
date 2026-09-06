///|
struct CompileTimeSpecializedBody {
  module_ : PlannedModuleLowering
  types : Array[CompileTimeType]
  bindings : Map[GenericParameterId, CompileTimeType]
}

///|
struct CompileTimeProgramContext {
  program : CollectedProgram
  analyzed : AnalyzedProgramSemantics
  targets : Map[DeclId, Bytes]
  sensitive : Map[DeclId, Bool]
  instances : Map[String, CompileTimeSpecializedBody]
}

///|
fn compile_time_owned_expressions(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
) -> Array[ExprId] {
  let result = []
  let spans = [body.expressions]
  for lambda in module_.lambdas {
    if lambda.root_body == body.body {
      spans.push(lambda.expressions)
    }
  }
  for span in spans {
    guard program_specialization_span_is_valid(
      span,
      module_.expressions.length(),
    ) else {
      abort("ARN-101 compile-time expression owner span is outside its arena")
    }
    for index in 0..<span.length {
      result.push(span.start + index)
    }
  }
  result
}

///|
fn compile_time_expression_owner(
  module_ : PlannedModuleLowering,
  expression : ExprId,
) -> DeclId? {
  for body in module_.bodies {
    if expression >= body.expressions.start &&
      expression - body.expressions.start < body.expressions.length {
      return Some(body.declaration)
    }
  }
  for lambda in module_.lambdas {
    if expression >= lambda.expressions.start &&
      expression - lambda.expressions.start < lambda.expressions.length {
      for body in module_.bodies {
        if body.body == lambda.root_body {
          return Some(body.declaration)
        }
      }
      abort("ARN-106 compile-time lambda has no owning body")
    }
  }
  None
}

///|
fn compile_time_generic_expression(
  module_ : PlannedModuleLowering,
  expression : ExprId,
) -> Bool {
  match compile_time_expression_owner(module_, expression) {
    Some(declaration) =>
      match module_.functions.callable_of(declaration) {
        Some(callable) =>
          program_callable_generic_parameters(callable).length > 0
        None => false
      }
    None => false
  }
}

///|
fn compile_time_program_context(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  targets : Map[DeclId, Bytes],
) -> CompileTimeProgramContext {
  let sensitive : Map[DeclId, Bool] = Map([])
  let callers : Map[DeclId, Array[DeclId]] = Map([])
  let work : Array[DeclId] = []
  for module_ in lowering.modules {
    let has_projections = module_.resolved_types.any(type_ => {
        type_ is MemberTypeProjection(_, _, _)
      }) ||
      module_.types.any(type_ => type_ is BodyMemberTypeProjection(_, _, _))
    for callable in module_.functions.callables {
      if compile_time_projected_signature(module_, callable) {
        sensitive[callable.declaration] = true
        work.push(callable.declaration)
      }
    }
    for index, expression in module_.expressions {
      if has_projections &&
        compile_time_has_projection(module_, expression.type_) {
        if compile_time_expression_owner(module_, index) is Some(caller) &&
          !sensitive.contains(caller) {
          sensitive[caller] = true
          work.push(caller)
        }
      }
      let (target, _) = match
        program_evidence_target_and_arguments(expression) {
        Some(value) => value
        None => continue
      }
      let caller = match compile_time_expression_owner(module_, index) {
        Some(value) => value
        None => continue
      }
      if targets.contains(target) && !sensitive.contains(caller) {
        sensitive[caller] = true
        work.push(caller)
      }
      match callers.get(target) {
        Some(entries) => entries.push(caller)
        None => callers[target] = [caller]
      }
    }
  }
  while work.length() > 0 {
    let target = work.pop().unwrap()
    match callers.get(target) {
      Some(entries) =>
        for caller in entries {
          if !sensitive.contains(caller) {
            sensitive[caller] = true
            work.push(caller)
          }
        }
      None => ()
    }
  }
  { program, analyzed, targets, sensitive, instances: {}, }
}

///|
// A structural, delimited encoding, not a hash or a physical carrier key.
// Concrete-type validation bounds the depth before this function is called.
fn compile_time_type_key(type_ : CompileTimeType) -> String {
  match type_ {
    CtPrimitive(value) => "p" + value.rank().to_string() + ";"
    CtNominal(id) => "n" + id.to_string() + ";"
    CtTrait(id) => "t" + id.to_string() + ";"
    CtProduct(values) => "(" + compile_time_types_key(values) + ")"
    CtApplied(base, values) =>
      "a[" + compile_time_type_key(base) + compile_time_types_key(values) + "]"
    CtFunction(parameters, result) =>
      "f[" +
      compile_time_types_key(parameters) +
      "]" +
      compile_time_type_key(result)
    CtUnknown | CtParameter(_) | CtError | CtMemberProjection(_, _, _) =>
      abort("SPC-301 unresolved logical specialization key")
  }
}

///|
fn compile_time_types_key(types : Array[CompileTimeType]) -> String {
  let output = StringBuilder::new()
  for type_ in types {
    output.write_string(compile_time_type_key(type_))
  }
  output.to_string()
}

///|
fn compile_time_specialization_key(
  lowering : PlannedProgramLowering,
  declaration : DeclId,
  abi_key : String,
  logical_types : Array[CompileTimeType],
  erased_fallback : Bool,
) -> String? {
  let context = match lowering.compile_time {
    Some(value) if value.sensitive.contains(declaration) => value
    _ => return Some(abi_key)
  }
  // A public generic export has no concrete logical arguments. It must not
  // invent a Ref instantiation; only actual call sites create query instances.
  if erased_fallback {
    return None
  }
  if logical_types.length() == 0 ||
    compile_time_types_are_concrete(logical_types) != Ok(true) {
    return None
  }
  let key = abi_key + ":logical[" + compile_time_types_key(logical_types) + "]"
  match context.instances.get(key) {
    Some(instance) => {
      guard instance.types == logical_types else {
        abort("SPC-302 logical specialization key collision")
      }
      return Some(key)
    }
    None => ()
  }
  let owner_index = lowering.index.declaration_owner(declaration).unwrap()
  let owner = lowering.modules[owner_index]
  let callable = owner.functions.callable_of(declaration).unwrap()
  let parameters = program_callable_generic_parameters(callable)
  guard parameters.length == logical_types.length() else {
    abort("SPC-301 logical specialization arity mismatch")
  }
  let collected = context.program.modules[owner_index]
  guard program_specialization_span_is_valid(
    parameters,
    collected.generic_parameters.length(),
  ) else {
    abort("ARN-101 logical specialization parameters are outside their arena")
  }
  let bindings : Map[GenericParameterId, CompileTimeType] = Map([])
  for index in 0..<parameters.length {
    bindings[collected.generic_parameters[parameters.start + index].id] = logical_types[index]
  }
  let instances = [owner]
  prepare_program_optimization_mutation(instances)
  let instance = {
    ..instances[0],
    diagnostics: [],
    lambdas: owner.lambdas.copy(),
    captures: owner.captures.copy(),
    resolved_types: owner.resolved_types.copy(),
    resolved_type_arguments: owner.resolved_type_arguments.copy(),
    types: owner.types.copy(),
    functions: {
      ..owner.functions,
      callables: owner.functions.callables.copy(),
      parameters: owner.functions.parameters.copy(),
    },
  }
  fold_module_compile_time_queries(
    context,
    owner_index,
    instance,
    bindings,
    Some(declaration),
  )
  materialize_compile_time_instance_types(
    context, owner, instance, bindings, declaration,
  )
  context.instances[key] = {
    module_: instance,
    types: logical_types.copy(),
    bindings,
  }
  Some(key)
}

///|
// The emitter and call scanner consume the same instance. Neither re-evaluates
// type queries or chooses a different specialized branch.
pub fn program_function_lowering(
  lowering : PlannedProgramLowering,
  module_index : Int,
  specialization_key : String,
) -> PlannedModuleLowering {
  match lowering.compile_time {
    Some(context) =>
      match context.instances.get(specialization_key) {
        Some(instance) => {
          guard instance.module_.module_id ==
            lowering.modules[module_index].module_id else {
            abort("SPC-302 compile-time body belongs to another module")
          }
          instance.module_
        }
        None => lowering.modules[module_index]
      }
    None => lowering.modules[module_index]
  }
}

///|
fn compile_time_call_arguments(
  lowering : PlannedProgramLowering,
  owner : PlannedModuleLowering,
  caller_key : String,
  arguments : HirSpan,
  reference : Bool,
) -> Array[CompileTimeType] {
  let bindings : Map[GenericParameterId, CompileTimeType] = match
    lowering.compile_time {
    Some(context) =>
      match context.instances.get(caller_key) {
        Some(instance) => instance.bindings
        None => Map([])
      }
    None => Map([])
  }
  let arena = if reference {
    owner.expression_type_arguments
  } else {
    owner.call_type_arguments
  }
  guard program_specialization_span_is_valid(arguments, arena.length()) else {
    abort("SPC-302 compile-time call arguments are outside their arena")
  }
  let types : Array[CompileTimeType] = []
  for index in 0..<arguments.length {
    match
      compile_time_read_type(owner, arena[arguments.start + index], bindings) {
      Ok(type_) =>
        match lowering.compile_time {
          Some(context) =>
            match reduce_compile_time_projections(context, owner, type_, 0) {
              Ok(value) => types.push(value)
              Err(_) => types.push(CtError)
            }
          None => types.push(type_)
        }
      Err(_) => types.push(CtError)
    }
  }
  types
}

///|
// The physical boundary must not turn a pending query into a callable import.
// Inspect only live functions and their selected instances, not templates.
fn verify_program_compile_time_closure(
  lowering : PlannedProgramLowering,
  functions : Array[PlannedProgramWasmFunction],
  diagnostics : Array[ProgramWasmGCLinkDiagnostic],
) -> Unit {
  let context = match lowering.compile_time {
    Some(value) => value
    None => return
  }
  for function_ in functions {
    if function_.elided {
      continue
    }
    let module_ = program_function_lowering(
      lowering,
      function_.module_index,
      function_.specialization_abi_key,
    )
    let body = match function_.kind {
      PlannedWasmDefinedFunction(body) =>
        module_.bodies[semantic_id_local(body)]
      PlannedWasmDefinedLambdaFunction(lambda) =>
        match module_.lambda_body(lambda) {
          Some(body) => body
          None => abort("BOD-610 missing compile-time lambda body")
        }
      _ => continue
    }
    guard program_specialization_span_is_valid(
      body.expressions,
      module_.expressions.length(),
    ) else {
      abort("ARN-101 compile-time verification body span is outside its arena")
    }
    for index in 0..<body.expressions.length {
      let expression = body.expressions.start + index
      let source = module_.expressions[expression]
      match program_evidence_target_and_arguments(source) {
        Some((target, _)) if context.targets.contains(target) =>
          diagnostics.push(
            ProgramCompileTimeFailure(
              module_.module_id,
              function_.declaration,
              function_.specialization_abi_key,
              expression,
              "CT-005 compile-time builtin remains at the physical boundary",
              source.offset,
            ),
          )
        _ => ()
      }
    }
  }
}
