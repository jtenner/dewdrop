///|
// Transform execution needs logical method instances per source conversion.
// Physical dictionaries can merge equal carriers; pure type queries cannot.
fn materialize_compile_time_trait_methods(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  modules : Array[PlannedModuleWasmGCFragments],
  module_lookup : Map[ModuleId, Int32],
  mi : Int32,
  caller : PlannedWasmFunctionFragment?,
  expression : ExprId,
) -> Unit {
  let context = match lowering.compile_time {
    Some(value) if value.transform_instance_budget >= 0 => value
    _ => return
  }
  let caller_key = caller
    .map(value => value.specialization_abi_key)
    .unwrap_or("")
  let owner = program_function_lowering(lowering, mi, caller_key)
  let (trait_, source_evidence, expected) = match
    owner.expressions[expression].trait_object_coercion {
    SelectedInferredTraitObjectCoercion(trait_, evidence, expected) =>
      (trait_, evidence, expected)
    _ => return
  }
  // A nongeneric implementation has no logical owner arguments to preserve.
  // Keep its ordinary checked dictionary and avoid per-site type reconstruction.
  if owner.trait_evidence[source_evidence].kind
    is ConcreteInferredTraitEvidence(implementation, _) {
    let implementation_owner = context.declaration_module(implementation)
    if context.program.modules[implementation_owner].generic_parameters_of(
        implementation,
      ).length ==
      0 {
      return
    }
  }
  let bindings : Map[CompileTimeBindingKey, CompileTimeType] = match
    context.instances.get(caller_key) {
    Some(instance) => instance.bindings
    None => {}
  }
  let read = fn(type_) {
    match compile_time_read_type(owner, type_, bindings) {
      Ok(value) => reduce_compile_time_projections(context, owner, value, 0)
      Err(_) => Err("checked trait source type is unavailable")
    }
  }
  let receiver_type = match read(owner.expressions[expression].type_) {
    Ok(value) => value
    Err(_) => return
  }
  let trait_type = match read(expected) {
    Ok(value) => value
    Err(_) => return
  }
  guard compile_time_types_are_concrete([receiver_type, trait_type]) == Ok(true) else {
    return
  }
  let evidence = empty_program_trait_evidence_request()
  let root = resolve_program_lowering_evidence_node(
    owner,
    modules[mi],
    caller,
    source_evidence,
    evidence,
  )
  let implementation = match
    program_trait_evidence_request_identity(evidence, root) {
    Some((value, _)) => value
    None => return
  }
  let arguments = match evidence.evidence[root].kind {
    PlannedConcreteTraitEvidence(_, arguments) => arguments
    PlannedRuntimeTraitEvidence(_, _) => return
  }
  let method_evidence = match
    program_trait_evidence_prerequisite_request(evidence, root) {
    Some(value) => value
    None => return
  }
  let logical_types = compile_time_implementation_arguments(
    lowering,
    implementation,
    receiver_type,
    trait_type,
    [],
  )
  let shapes = []
  for index in 0..<arguments.length {
    shapes.push(evidence.arguments[arguments.start + index])
  }
  let requirements = wasmgc_trait_requirements(
    owner.functions,
    Some(analyzed.modules[mi].imports),
    trait_,
  )
  for requirement in requirements {
    let site = (owner.module_id, expression, caller_key, requirement)
    if context.trait_method_frames.contains(site) {
      continue
    }
    let method_ = match
      program_impl_method_for_requirement(
        lowering, module_lookup, implementation, requirement,
      ) {
      Some(value) => value
      None => continue
    }
    let method_owner = lowering.index.declaration_owner(method_).unwrap()
    let callable = lowering.modules[method_owner].functions
      .callable_of(method_)
      .unwrap()
    // Generic requirements are not object safe. Their declaration is retained
    // by inference for diagnostics but must never gain an executable frame.
    if callable.generic_parameters.length != 0 {
      continue
    }
    let key = if callable.owner_generic_parameters.length == 0 {
      ""
    } else {
      match
        materialize_program_generic_specialization(
          analyzed,
          lowering,
          modules,
          module_lookup,
          method_,
          shapes,
          { start: 0, length: shapes.length(), },
          method_evidence,
          false,
          logical_types~,
        ) {
        Some(value) => value
        None => continue
      }
    }
    context.trait_method_frames[site] = (method_, key)
  }
}
