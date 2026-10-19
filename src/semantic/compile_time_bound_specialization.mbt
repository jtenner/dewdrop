///|
// The physical evidence already selected this implementation. Recover its
// logical substitutions without searching for another implementation.
fn compile_time_bound_method_arguments(
  lowering : PlannedProgramLowering,
  module_ : PlannedModuleLowering,
  caller_key : String,
  implementation : DeclId,
  requirement : DeclId,
  receiver : ExprId,
  call_arguments : HirSpan,
) -> Array[CompileTimeType] {
  let context = match lowering.compile_time {
    Some(value) => value
    None => return []
  }
  guard receiver >= 0 && receiver < module_.expressions.length() else {
    abort("ARN-104 checked bound call receiver")
  }
  let caller_bindings : Map[CompileTimeBindingKey, CompileTimeType] = match
    context.instances.get(caller_key) {
    Some(instance) => instance.bindings
    None => {}
  }
  let receiver_type = match
    compile_time_read_type(
      module_,
      module_.expressions[receiver].type_,
      caller_bindings,
    ) {
    Ok(value) =>
      match reduce_compile_time_projections(context, module_, value, 0) {
        Ok(value) => value
        Err(_) => return []
      }
    Err(_) => return []
  }
  if compile_time_types_are_concrete([receiver_type]) != Ok(true) {
    return []
  }
  let arguments = compile_time_call_arguments(
    lowering, module_, caller_key, call_arguments, false,
  )
  let required_module = lowering.modules[context.declaration_module(requirement)]
  let callable = required_module.functions.callable_of(requirement).unwrap()
  let trait_declaration = match callable.kind {
    PlannedTraitMethodCallable(value) => value
    _ => abort("SPC-303 bound call lost its trait requirement")
  }
  let trait_count = callable.owner_generic_parameters.length
  guard arguments.length() == trait_count + callable.generic_parameters.length else {
    abort("SPC-303 bound call logical argument count")
  }
  if compile_time_types_are_concrete(arguments) != Ok(true) {
    return []
  }
  let trait_arguments = []
  for index in 0..<trait_count {
    trait_arguments.push(arguments[index])
  }
  let trait_type = if trait_count == 0 {
    CtTrait(trait_declaration)
  } else {
    CtApplied(CtTrait(trait_declaration), trait_arguments)
  }
  let implementation_owner = context.declaration_module(implementation)
  let collected = context.program.modules[implementation_owner]
  let implementation_module = lowering.modules[implementation_owner]
  let mut implementation_index = -1
  for index, candidate in collected.impls {
    if candidate.declaration == implementation {
      implementation_index = index
      break
    }
  }
  guard implementation_index >= 0 else {
    abort("LNK-504 checked implementation has no declaration")
  }
  let resolved = context.analyzed.frozen.interfaces[implementation_owner].resolved_types
  let pattern_target = match
    compile_time_read_type(
      implementation_module,
      -resolved.impl_target_types[implementation_index] - 2,
      {},
    ) {
    Ok(value) => value
    Err(_) => abort("SPC-303 checked implementation target type")
  }
  let trait_pattern_id = resolved.impl_trait_types[implementation_index]
  guard trait_pattern_id >= 0 else {
    abort("SPC-303 checked trait evidence selected an inherent implementation")
  }
  let pattern_trait = match
    compile_time_read_type(
      implementation_module,
      -trait_pattern_id - 2,
      {},
      self_binding=Some((implementation, receiver_type)),
    ) {
    Ok(value) => value
    Err(_) => abort("SPC-303 checked implementation trait type")
  }
  let substitutions : Map[CompileTimeBindingKey, CompileTimeType] = {}
  guard compile_time_match_type(pattern_target, receiver_type, substitutions) &&
    compile_time_match_type(pattern_trait, trait_type, substitutions) else {
    abort(
      "SPC-303 checked implementation disagrees with logical receiver or trait",
    )
  }
  let parameters = collected.generic_parameters_of(implementation)
  let result = []
  for index in 0..<parameters.length {
    let parameter = collected.generic_parameters[parameters.start + index].id
    match substitutions.get(CtGenericBinding(parameter)) {
      Some(value) => result.push(value)
      None =>
        abort(
          "SPC-303 checked implementation parameter has no logical substitution",
        )
    }
  }
  for index in trait_count..<arguments.length() {
    result.push(arguments[index])
  }
  result
}

///|
// A bound receiver's prerequisites cover implementation parameters. Method
// parameters have separate checked roots in the expression evidence arena.
fn append_program_bound_method_evidence(
  module_ : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  caller : PlannedWasmFunctionFragment,
  expression : ExprId,
  request : ProgramTraitEvidenceRequest,
) -> Bool {
  if expression < 0 || expression >= module_.expression_evidence.length() {
    return true
  }
  let roots = module_.expression_evidence[expression]
  guard program_specialization_span_is_valid(
    roots,
    module_.trait_evidence_roots.length(),
  ) else {
    abort("ARN-101 checked bound method evidence roots")
  }
  for index in 0..<roots.length {
    let root = resolve_program_lowering_evidence_node(
      module_,
      fragments,
      Some(caller),
      module_.trait_evidence_roots[roots.start + index],
      request,
    )
    if root < 0 {
      return false
    }
    request.roots.push(root)
  }
  true
}
