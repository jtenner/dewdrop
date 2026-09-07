///|
fn CompileTimeProgramContext::declaration_module(
  self : CompileTimeProgramContext,
  declaration : DeclId,
) -> Int {
  for index, module_ in self.modules {
    if module_.module_id == semantic_id_module(declaration) {
      return index
    }
  }
  abort("LNK-504 compile-time trait declaration has no owning module")
}

///|
fn compile_time_append_argument(
  module_ : PlannedModuleLowering,
  type_ : CompileTimeType,
) -> Unit {
  let id = compile_time_append_resolved(module_, type_)
  module_.call_type_arguments.push(-id - 2)
  module_.call_type_argument_shapes.push(
    planned_value_shape_from_resolved_types(
      module_.resolved_types,
      module_.resolved_type_arguments,
      id,
    ),
  )
}

///|
fn compile_time_witness_node(
  context : CompileTimeProgramContext,
  module_ : PlannedModuleLowering,
  witness : CompileTimeTraitWitness,
) -> Int {
  let declaration = witness.implementation.declaration
  let collected = context.program.modules[context.declaration_module(
      declaration,
    )]
  let generics = collected.generic_parameters_of(declaration)
  let arguments = module_.trait_evidence_arguments.length()
  for offset in 0..<generics.length {
    let parameter = collected.generic_parameters[generics.start + offset].id
    let type_ = witness.bindings.get(parameter).unwrap()
    let id = compile_time_append_resolved(module_, type_)
    module_.trait_evidence_arguments.push(
      ShapeInferredTraitEvidenceArgument(
        planned_value_shape_from_resolved_types(
          module_.resolved_types,
          module_.resolved_type_arguments,
          id,
        ),
      ),
    )
  }
  let children = witness.prerequisites.map(child => {
    compile_time_witness_node(context, module_, child)
  })
  let start = module_.trait_evidence_children.length()
  for child in children {
    module_.trait_evidence_children.push(child)
  }
  let id = module_.trait_evidence.length()
  module_.trait_evidence.push({
    kind: ConcreteInferredTraitEvidence(declaration, {
      start: arguments,
      length: generics.length,
    }),
    prerequisites: { start, length: children.length(), },
  })
  id
}

///|
// A branch proof authorizes checking the trait requirement, not a runtime
// dictionary slot. Only the retained exact instance resolves its implementation.
fn resolve_compile_time_guarded_calls(
  context : CompileTimeProgramContext,
  module_ : PlannedModuleLowering,
  bindings : Map[GenericParameterId, CompileTimeType],
  active : DeclId?,
  search : CompileTimeEvidenceSearch,
) -> Unit {
  for expression, source in module_.expressions {
    if !compile_time_in_body(module_, expression, active) ||
      (active is None && compile_time_generic_expression(module_, expression)) {
      continue
    }
    let (requirement, receiver, type_arguments) = match source.kind {
      PlannedDirectCall(target, receiver, _, arguments) =>
        (target, receiver, arguments)
      PlannedOperatorCall(target, _, receiver, _, arguments) =>
        (target, receiver, arguments)
      _ => continue
    }
    let requirement_module = context.modules[context.declaration_module(
        requirement,
      )]
    let callable = match requirement_module.functions.callable_of(requirement) {
      Some(value) if value.kind is PlannedTraitMethodCallable(_) => value
      _ => continue
    }
    let trait_declaration = match callable.kind {
      PlannedTraitMethodCallable(id) => id
      _ => abort("INV-001 guarded trait requirement")
    }
    fn resolve() -> Result[PlannedExpressionKind, String] {
      if receiver < 0 || receiver >= module_.expressions.length() {
        return Err("CT-040 guarded trait call has no receiver")
      }
      let target = match
        compile_time_read_type(
          module_,
          module_.expressions[receiver].type_,
          bindings,
        ) {
        Ok(value) => value
        Err(_) => return Err("CT-040 invalid guarded receiver type")
      }
      let arguments = match
        compile_time_read_arguments(module_, type_arguments, bindings) {
        Ok(value) => value
        Err(_) => return Err("CT-040 invalid guarded trait arguments")
      }
      let trait_count = callable.owner_generic_parameters.length
      if arguments.length() != trait_count + callable.generic_parameters.length {
        return Err("CT-040 guarded trait argument count mismatch")
      }
      let trait_arguments = []
      for index in 0..<trait_count {
        trait_arguments.push(arguments[index])
      }
      let trait_ = if trait_count == 0 {
        CtTrait(trait_declaration)
      } else {
        CtApplied(CtTrait(trait_declaration), trait_arguments)
      }
      search.budget.steps = 0
      let witness = match search.witness(target, trait_) {
        Ok(Some(value)) => value
        Ok(None) =>
          return Err("CT-040 selected branch has no trait implementation")
        Err(error) => return Err(error)
      }
      let methods = witness.implementation.methods
      guard program_specialization_span_is_valid(
        methods,
        witness.index.methods.length(),
      ) else {
        abort("ARN-101 guarded implementation methods")
      }
      let mut selected : DeclId? = None
      for index in 0..<methods.length {
        let method = witness.index.methods[methods.start + index]
        if method.requirement == Some(requirement) {
          if selected is Some(_) {
            return Err("CT-015 ambiguous guarded implementation method")
          }
          selected = Some(method.declaration)
        }
      }
      let method = match selected {
        Some(value) => value
        None => return Err("CT-040 trait implementation has no required method")
      }
      let collected = context.program.modules[context.declaration_module(method)]
      let owner_generics = collected.generic_parameters_of(
        witness.implementation.declaration,
      )
      let start = module_.call_type_arguments.length()
      for offset in 0..<owner_generics.length {
        let parameter = collected.generic_parameters[owner_generics.start +
          offset].id
        let type_ = match witness.bindings.get(parameter) {
          Some(value) => value
          None =>
            return Err("CT-011 unresolved guarded implementation parameter")
        }
        compile_time_append_argument(module_, type_)
      }
      for offset in trait_count..<arguments.length() {
        compile_time_append_argument(module_, arguments[offset])
      }
      let span = {
        start,
        length: module_.call_type_arguments.length() - start,
      }
      let roots = witness.prerequisites.map(child => {
        compile_time_witness_node(context, module_, child)
      })
      let evidence_start = module_.trait_evidence_roots.length()
      for root in roots {
        module_.trait_evidence_roots.push(root)
      }
      module_.expression_evidence[expression] = {
        start: evidence_start,
        length: roots.length(),
      }
      Ok(
        match source.kind {
          PlannedDirectCall(_, receiver, args, _) =>
            PlannedDirectCall(method, receiver, args, span)
          PlannedOperatorCall(_, operator, left, right, _) =>
            PlannedOperatorCall(method, operator, left, right, span)
          _ => abort("INV-001 guarded call changed while resolving")
        },
      )
    }
    match resolve() {
      Ok(kind) => module_.expressions[expression] = { ..source, kind, }
      Err(message) =>
        module_.diagnostics.push(
          CompileTimeQueryDiagnostic(expression, message, source.offset),
        )
    }
  }
}
