///|
fn BasicBodyInferencer::collect_method_candidates(
  self : BasicBodyInferencer,
  receiver_type : BodyTypeId,
  name : NameId,
) -> Bool {
  self.call_scratch.method_candidates.clear()
  self.call_scratch.method_candidate_impls.clear()
  let head = match self.body_impl_target_head(receiver_type) {
    Some(head) => head
    None => return false
  }
  if head == ErrorImplTargetHead {
    return true
  }
  let inherent = self.impl_index.method_dispatch_span(head, name, true, true)
  let candidates = if inherent.length > 0 {
    inherent
  } else {
    self.impl_index.method_dispatch_span(head, name, false, true)
  }
  for offset in candidates.start..<(candidates.start + candidates.length) {
    let candidate = self.impl_index.method_dispatch[offset]
    if !self.implementation_visible(candidate.implementation) {
      continue
    }
    self.call_scratch.method_candidates.push(
      self.impl_index.methods[candidate.method_index].declaration,
    )
    self.call_scratch.method_candidate_impls.push(candidate.implementation)
  }
  true
}

///|
fn BasicBodyInferencer::implementation_generic_parameters(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> HirSpan {
  if semantic_id_module(declaration) == self.collected.module_id {
    return self.collected.generic_parameters_of(declaration)
  }
  match self.imports {
    Some(imports) =>
      match imports.implementation(declaration) {
        Some(implementation) => implementation.generic_parameters
        None => { start: 0, length: 0, }
      }
    None => { start: 0, length: 0, }
  }
}

///|
fn BasicBodyInferencer::begin_method_candidate(
  self : BasicBodyInferencer,
  implementation_index : Int,
  declaration : DeclId,
) -> BodyTypeId {
  let implementation = self.impl_index.implementations[implementation_index]
  self.call_scratch.instantiation_generics = self.implementation_generic_parameters(
    implementation.declaration,
  )
  self.call_scratch.instantiation_method_generics = if semantic_id_module(
      declaration,
    ) ==
    self.collected.module_id {
    self.collected.generic_parameters_of(declaration)
  } else {
    match self.imported_callable_of(declaration) {
      Some(callable) => callable.generic_parameters
      None => { start: 0, length: 0, }
    }
  }
  self.call_scratch.candidate_type_arguments.clear()
  for
    _ in 0..<(self.call_scratch.instantiation_generics.length +
    self.call_scratch.instantiation_method_generics.length) {
    self.call_scratch.candidate_type_arguments.push(
      self.solver.fresh_variable(),
    )
  }
  self.call_scratch.instantiation_self_owner = implementation.declaration
  self.call_scratch.instantiation_self_type = -1
  self.next_instantiation_generation()
  let target = self.instantiate_signature_type(implementation.target_type)
  self.call_scratch.instantiation_self_type = target
  target
}

///|
fn BasicBodyInferencer::apply_explicit_method_type_arguments(
  self : BasicBodyInferencer,
  expression : ExprId,
  implementation_index : Int,
  declaration : DeclId,
) -> Bool {
  let owner_count = self.implementation_generic_parameters(
      self.impl_index.implementations[implementation_index].declaration,
    ).length
  let method_count = if semantic_id_module(declaration) ==
    self.collected.module_id {
    self.collected.generic_parameters_of(declaration).length
  } else {
    self.call_generic_count(declaration)
  }
  self.apply_explicit_call_type_arguments(expression, owner_count, method_count)
}

///|
fn BasicBodyInferencer::try_method_candidate(
  self : BasicBodyInferencer,
  expression : ExprId,
  receiver : ExprId,
  arguments : HirSpan,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Bool {
  if !self.callable_exists(declaration) {
    return false
  }
  let parameter_count = self.call_parameter_count(declaration)
  if parameter_count == 0 ||
    !self.call_parameter_is_receiver(declaration, 0) ||
    parameter_count - 1 != arguments.length {
    return false
  }
  let snapshot = self.solver.snapshot()
  let target = self.begin_method_candidate(implementation_index, declaration)
  if !self.apply_explicit_method_type_arguments(
      expression, implementation_index, declaration,
    ) {
    self.solver.rollback(snapshot)
    return false
  }
  let origin = call_type_origin(expression, offset)
  let mut viable = self.solver.unify(
    self.expression_type(receiver),
    target,
    origin,
  )
  if viable {
    viable = self.solver.unify(
      self.expression_type(receiver),
      self.instantiate_signature_type(self.call_parameter_type(declaration, 0)),
      origin,
    )
  }
  let mut index = 0
  while viable && index < arguments.length {
    viable = self.solver.unify(
      self.expression_type(
        self.collected.expression_children[arguments.start + index],
      ),
      self.instantiate_signature_type(
        self.call_parameter_type(declaration, index + 1),
      ),
      origin,
    )
    index += 1
  }
  if viable {
    viable = self.solver.unify(
      self.expression_type(expression),
      self.instantiate_signature_type(self.call_result_type(declaration)),
      origin,
    )
  }
  if viable {
    viable = self.impl_candidate_bounds_satisfied(
      implementation_index, origin, 0,
    )
  }
  if viable {
    viable = self.method_candidate_bounds_satisfied(declaration, origin, 0)
  }
  self.solver.rollback(snapshot)
  viable
}

///|
fn BasicBodyInferencer::select_method_candidate(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  receiver : ExprId,
  arguments : HirSpan,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Unit {
  let target = self.begin_method_candidate(implementation_index, declaration)
  guard self.apply_explicit_method_type_arguments(
    expression, implementation_index, declaration,
  ) else {
    abort("selected method has mismatched explicit type argument count")
  }
  let origin = call_type_origin(expression, offset)
  self.constrain(self.expression_type(receiver), target, origin)
  self.constrain(
    self.expression_type(receiver),
    self.instantiate_signature_type(self.call_parameter_type(declaration, 0)),
    origin,
  )
  for index in 0..<arguments.length {
    self.constrain_assignable(
      self.expression_type(
        self.collected.expression_children[arguments.start + index],
      ),
      self.instantiate_signature_type(
        self.call_parameter_type(declaration, index + 1),
      ),
      origin,
    )
  }
  self.constrain_assignable(
    self.instantiate_signature_type(self.call_result_type(declaration)),
    self.expression_type(expression),
    origin,
  )
  let start = self.call_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.call_type_arguments.push(type_)
  }
  let type_arguments = {
    start,
    length: self.call_scratch.candidate_type_arguments.length(),
  }
  self.call_targets[call_slot] = SelectedInferredCallTarget(
    declaration, type_arguments,
  )
  self.record_selected_impl_prerequisite_evidence(
    expression, implementation_index, origin,
  )
  self.validate_method_call_obligations(
    expression,
    declaration,
    type_arguments,
    self.implementation_generic_parameters(
      self.impl_index.implementations[implementation_index].declaration,
    ).length,
    offset,
  )
}

///|
fn BasicBodyInferencer::collect_operator_candidates(
  self : BasicBodyInferencer,
  trait_declaration : DeclId,
  method_name : NameId,
) -> Unit {
  self.call_scratch.method_candidates.clear()
  self.call_scratch.method_candidate_impls.clear()
  let candidates = self.impl_index.trait_method_dispatch_span(
    trait_declaration, method_name, true,
  )
  for offset in candidates.start..<(candidates.start + candidates.length) {
    let candidate = self.impl_index.trait_method_dispatch[offset]
    if !self.implementation_visible(candidate.implementation) {
      continue
    }
    self.call_scratch.method_candidates.push(
      self.impl_index.methods[candidate.method_index].declaration,
    )
    self.call_scratch.method_candidate_impls.push(candidate.implementation)
  }
}

///|
fn BasicBodyInferencer::prepare_string_pattern_operators(
  self : BasicBodyInferencer,
) -> Unit {
  // Keep implicit comparisons in the same arena-ordered work queue as explicit
  // operators. The pattern literal remains a String-valued expression.
  if self.trait_declaration_named("Eq") is None ||
    self.collected.find_name("eq") is None {
    return
  }
  for
    pattern in self.body.patterns.start..<(self.body.patterns.start +
    self.body.patterns.length) {
    if !self.live_pattern(pattern) {
      continue
    }
    match self.collected.patterns[pattern] {
      HirLiteralPattern(expression, _) =>
        match self.collected.expressions[expression] {
          HirStringExpr(_, _) =>
            self.call_scratch.string_pattern_expressions[expression] = true
          _ => ()
        }
      _ => ()
    }
  }
}

///|
fn BasicBodyInferencer::operator_result_type(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> BodyTypeId {
  match self.collected.expressions[expression] {
    HirStringExpr(_, _) => self.primitive(BoolType)
    _ => self.expression_type(expression)
  }
}

///|
fn BasicBodyInferencer::try_operator_candidate(
  self : BasicBodyInferencer,
  expression : ExprId,
  left : ExprId,
  right : ExprId,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Bool {
  if !self.callable_exists(declaration) ||
    self.call_parameter_count(declaration) != 2 ||
    !self.call_parameter_is_receiver(declaration, 0) {
    return false
  }
  let snapshot = self.solver.snapshot()
  let target = self.begin_method_candidate(implementation_index, declaration)
  let origin = operator_type_origin(expression, offset)
  let mut viable = self.solver.unify(self.expression_type(left), target, origin)
  if viable {
    viable = self.solver.unify(
      self.expression_type(left),
      self.expression_type(right),
      origin,
    )
  }
  if viable {
    viable = self.solver.unify(
      self.expression_type(left),
      self.instantiate_signature_type(self.call_parameter_type(declaration, 0)),
      origin,
    )
  }
  if viable {
    viable = self.solver.unify(
      self.expression_type(right),
      self.instantiate_signature_type(self.call_parameter_type(declaration, 1)),
      origin,
    )
  }
  if viable {
    viable = self.solver.unify(
      self.operator_result_type(expression),
      self.instantiate_signature_type(self.call_result_type(declaration)),
      origin,
    )
  }
  if viable {
    viable = self.impl_candidate_bounds_satisfied(
      implementation_index, origin, 0,
    )
  }
  self.solver.rollback(snapshot)
  viable
}

///|
fn BasicBodyInferencer::select_operator_candidate(
  self : BasicBodyInferencer,
  expression : ExprId,
  left : ExprId,
  right : ExprId,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Unit {
  let target = self.begin_method_candidate(implementation_index, declaration)
  let origin = operator_type_origin(expression, offset)
  self.constrain(self.expression_type(left), target, origin)
  self.constrain(
    self.expression_type(left),
    self.expression_type(right),
    origin,
  )
  self.constrain(
    self.expression_type(left),
    self.instantiate_signature_type(self.call_parameter_type(declaration, 0)),
    origin,
  )
  self.constrain_assignable(
    self.expression_type(right),
    self.instantiate_signature_type(self.call_parameter_type(declaration, 1)),
    origin,
  )
  self.constrain_assignable(
    self.instantiate_signature_type(self.call_result_type(declaration)),
    self.operator_result_type(expression),
    origin,
  )
  let start = self.call_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.call_type_arguments.push(type_)
  }
  self.operator_targets[self.expression_index(expression)] = SelectedInferredCallTarget(
    declaration,
    { start, length: self.call_scratch.candidate_type_arguments.length(), },
  )
  self.record_selected_impl_prerequisite_evidence(
    expression, implementation_index, origin,
  )
}

///|
fn BasicBodyInferencer::try_index_candidate(
  self : BasicBodyInferencer,
  expression : ExprId,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Bool {
  let (base, index, value) = match self.collected.expressions[expression] {
    HirIndexExpr(base, index, _) => (base, index, -1)
    HirIndexSetExpr(base, index, value, _) => (base, index, value)
    _ => abort("index work item is not an index expression")
  }
  let expected_parameters = if value >= 0 { 3 } else { 2 }
  if !self.callable_exists(declaration) ||
    self.call_parameter_count(declaration) != expected_parameters ||
    !self.call_parameter_is_receiver(declaration, 0) {
    return false
  }
  let snapshot = self.solver.snapshot()
  let target = self.begin_method_candidate(implementation_index, declaration)
  let origin = operator_type_origin(expression, offset)
  let mut viable = self.solver.unify(self.expression_type(base), target, origin)
  if viable {
    viable = self.solver.unify(
      self.expression_type(base),
      self.instantiate_signature_type(self.call_parameter_type(declaration, 0)),
      origin,
    )
  }
  if viable {
    viable = self.assignable_viable(
      self.expression_type(index),
      self.instantiate_signature_type(self.call_parameter_type(declaration, 1)),
      origin,
    )
  }
  if viable && value >= 0 {
    viable = self.assignable_viable(
      self.expression_type(value),
      self.instantiate_signature_type(self.call_parameter_type(declaration, 2)),
      origin,
    )
  }
  if viable {
    viable = self.solver.unify(
      self.expression_type(expression),
      self.instantiate_signature_type(self.call_result_type(declaration)),
      origin,
    )
  }
  if viable {
    viable = self.impl_candidate_bounds_satisfied(
      implementation_index, origin, 0,
    )
  }
  self.solver.rollback(snapshot)
  viable
}

///|
fn BasicBodyInferencer::select_index_candidate(
  self : BasicBodyInferencer,
  expression : ExprId,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Unit {
  let (base, index, value) = match self.collected.expressions[expression] {
    HirIndexExpr(base, index, _) => (base, index, -1)
    HirIndexSetExpr(base, index, value, _) => (base, index, value)
    _ => abort("index work item is not an index expression")
  }
  let target = self.begin_method_candidate(implementation_index, declaration)
  let origin = operator_type_origin(expression, offset)
  self.constrain(self.expression_type(base), target, origin)
  self.constrain(
    self.expression_type(base),
    self.instantiate_signature_type(self.call_parameter_type(declaration, 0)),
    origin,
  )
  self.constrain_assignable(
    self.expression_type(index),
    self.instantiate_signature_type(self.call_parameter_type(declaration, 1)),
    origin,
  )
  if value >= 0 {
    self.constrain_assignable(
      self.expression_type(value),
      self.instantiate_signature_type(self.call_parameter_type(declaration, 2)),
      origin,
    )
  }
  self.constrain_assignable(
    self.instantiate_signature_type(self.call_result_type(declaration)),
    self.expression_type(expression),
    origin,
  )
  let start = self.call_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.call_type_arguments.push(type_)
  }
  self.operator_targets[self.expression_index(expression)] = SelectedInferredCallTarget(
    declaration,
    { start, length: self.call_scratch.candidate_type_arguments.length(), },
  )
  self.record_selected_impl_prerequisite_evidence(
    expression, implementation_index, origin,
  )
}

///|

///|

///|

///|
fn index_trait(expression : HirExpr) -> (String, String)? {
  match expression {
    HirIndexExpr(_, _, _) => Some(("IndexedGet", "indexed_get"))
    HirIndexSetExpr(_, _, _, _) => Some(("IndexedSet", "indexed_set"))
    _ => None
  }
}

///|
fn BasicBodyInferencer::select_declared_bound_operator(
  self : BasicBodyInferencer,
  expression : ExprId,
  trait_declaration : DeclId,
  method_name : NameId,
  left : ExprId,
  right : ExprId,
  offset : UInt64,
) -> Bool {
  let evidence = self.declared_body_trait_evidence(
    self.expression_type(left),
    Some(trait_declaration),
    method_name,
    expression~,
  )
  if evidence.length() == 0 {
    return false
  }
  if evidence.length() > 1 {
    self.operator_targets[self.expression_index(expression)] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(
      AmbiguousMethod(
        method_name,
        expression,
        evidence[0].requirement,
        evidence[1].requirement,
        evidence.length(),
        offset,
      ),
    )
    return true
  }
  let selected = evidence[0]
  let declaration = selected.requirement
  if !self.callable_exists(declaration) ||
    self.call_parameter_count(declaration) != 2 ||
    !self.call_parameter_is_receiver(declaration, 0) {
    self.operator_targets[self.expression_index(expression)] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(NoMatchingMethod(method_name, expression, offset))
    return true
  }
  let receiver_type = self.expression_type(left)
  self.begin_declared_body_trait_evidence(selected, receiver_type)
  let origin = operator_type_origin(expression, offset)
  self.constrain(receiver_type, self.expression_type(right), origin)
  self.constrain(
    receiver_type,
    self.instantiate_signature_type(self.call_parameter_type(declaration, 0)),
    origin,
  )
  self.constrain_assignable(
    self.expression_type(right),
    self.instantiate_signature_type(self.call_parameter_type(declaration, 1)),
    origin,
  )
  self.constrain_assignable(
    self.instantiate_signature_type(self.call_result_type(declaration)),
    self.expression_type(expression),
    origin,
  )
  let start = self.call_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.call_type_arguments.push(type_)
  }
  self.operator_targets[self.expression_index(expression)] = if selected.evidence_index <
    0 {
    SelectedInferredCallTarget(declaration, {
      start,
      length: self.call_scratch.candidate_type_arguments.length(),
    })
  } else {
    SelectedBoundInferredCallTarget(declaration, selected.evidence_index, {
      start,
      length: self.call_scratch.candidate_type_arguments.length(),
    })
  }
  true
}

///|
fn BasicBodyInferencer::trait_requirement_slot(
  self : BasicBodyInferencer,
  trait_declaration : DeclId,
  requirement : DeclId,
) -> Int {
  let mut slot = 0
  if semantic_id_module(trait_declaration) == self.collected.module_id {
    for method_info in self.collected.methods {
      if method_info.kind == TraitMethodDecl &&
        method_info.parent == trait_declaration {
        if method_info.id == requirement {
          return slot
        }
        if self.call_parameter_count(method_info.id) > 0 &&
          self.call_parameter_is_receiver(method_info.id, 0) {
          slot += 1
        }
      }
    }
    return -1
  }
  match self.imports {
    Some(imports) =>
      for interface_index in imports.scope.imported_interfaces {
        let interface_ = imports.scope.interfaces[interface_index].unwrap()
        for callable in interface_.callables {
          match callable.kind {
            FrozenTraitCallable(owner) if owner == trait_declaration => {
              if callable.declaration == requirement {
                return slot
              }
              if self.call_parameter_count(callable.declaration) > 0 &&
                self.call_parameter_is_receiver(callable.declaration, 0) {
                slot += 1
              }
            }
            _ => ()
          }
        }
      }
    None => ()
  }
  -1
}

///|
fn BasicBodyInferencer::begin_trait_object_requirement(
  self : BasicBodyInferencer,
  trait_declaration : DeclId,
  requirement : DeclId,
  receiver_type : BodyTypeId,
) -> Unit {
  self.call_scratch.instantiation_generics = if semantic_id_module(
      trait_declaration,
    ) ==
    self.collected.module_id {
    self.collected.generic_parameters_of(trait_declaration)
  } else {
    match self.imports {
      Some(imports) => imports.generic_parameters_of(trait_declaration)
      None => { start: 0, length: 0, }
    }
  }
  self.call_scratch.instantiation_method_generics = if semantic_id_module(
      requirement,
    ) ==
    self.collected.module_id {
    self.collected.generic_parameters_of(requirement)
  } else {
    { start: 0, length: self.call_generic_count(requirement), }
  }
  self.call_scratch.candidate_type_arguments.clear()
  for
    _ in 0..<(self.call_scratch.instantiation_generics.length +
    self.call_scratch.instantiation_method_generics.length) {
    self.call_scratch.candidate_type_arguments.push(
      self.solver.fresh_variable(),
    )
  }
  self.call_scratch.instantiation_self_owner = trait_declaration
  self.call_scratch.instantiation_self_type = receiver_type
  self.next_instantiation_generation()
}

///|
fn BasicBodyInferencer::trait_object_type_mentions_self(
  self : BasicBodyInferencer,
  type_ : ResolvedTypeId,
  trait_declaration : DeclId,
) -> Bool {
  if type_ < 0 || type_ >= self.resolved.types.length() {
    return false
  }
  match self.resolved.types[type_] {
    SelfType(owner) => owner == trait_declaration
    AppliedType(base, arguments) => {
      if self.trait_object_type_mentions_self(base, trait_declaration) {
        return true
      }
      for index in 0..<arguments.length {
        if self.trait_object_type_mentions_self(
            self.resolved.type_arguments[arguments.start + index],
            trait_declaration,
          ) {
          return true
        }
      }
      false
    }
    FunctionType(parameters, result) => {
      for index in 0..<parameters.length {
        if self.trait_object_type_mentions_self(
            self.resolved.type_arguments[parameters.start + index],
            trait_declaration,
          ) {
          return true
        }
      }
      self.trait_object_type_mentions_self(result, trait_declaration)
    }
    _ => false
  }
}

///|
fn BasicBodyInferencer::trait_requirement_is_object_safe(
  self : BasicBodyInferencer,
  trait_declaration : DeclId,
  requirement : DeclId,
) -> Bool {
  let method_generics = if semantic_id_module(requirement) ==
    self.collected.module_id {
    self.collected.generic_parameters_of(requirement).length
  } else {
    self.call_generic_count(requirement)
  }
  if method_generics > 0 {
    return false
  }
  for index in 1..<self.call_parameter_count(requirement) {
    if self.trait_object_type_mentions_self(
        self.call_parameter_type(requirement, index),
        trait_declaration,
      ) {
      return false
    }
  }
  !self.trait_object_type_mentions_self(
    self.call_result_type(requirement),
    trait_declaration,
  )
}

///|
fn BasicBodyInferencer::select_trait_object_method(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  receiver : ExprId,
  name : NameId,
  arguments : HirSpan,
  offset : UInt64,
) -> Bool {
  let trait_declaration = match
    self.body_trait_declaration(self.expression_type(receiver)) {
    Some(value) => value
    None => return false
  }
  let requirement = match
    self.trait_requirement_named(trait_declaration, name) {
    Some(value) => value
    None => return false
  }
  let slot = self.trait_requirement_slot(trait_declaration, requirement)
  if slot < 0 ||
    !self.callable_exists(requirement) ||
    !self.trait_requirement_is_object_safe(trait_declaration, requirement) ||
    self.call_parameter_count(requirement) == 0 ||
    !self.call_parameter_is_receiver(requirement, 0) ||
    self.call_parameter_count(requirement) - 1 != arguments.length {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(NoMatchingMethod(name, expression, offset))
    return true
  }
  let receiver_type = self.expression_type(receiver)
  self.begin_trait_object_requirement(
    trait_declaration, requirement, receiver_type,
  )
  let origin = call_type_origin(expression, offset)
  let parameter_types : Array[BodyTypeId] = []
  for index in 0..<arguments.length {
    parameter_types.push(
      self.instantiate_signature_type(
        self.call_parameter_type(requirement, index + 1),
      ),
    )
  }
  let result_type = self.instantiate_signature_type(
    self.call_result_type(requirement),
  )
  let start = self.call_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.call_type_arguments.push(type_)
  }
  self.constrain(
    receiver_type,
    self.instantiate_signature_type(self.call_parameter_type(requirement, 0)),
    origin,
  )
  for index in 0..<arguments.length {
    self.constrain_expression_assignable(
      self.collected.expression_children[arguments.start + index],
      parameter_types[index],
      origin,
    )
  }
  self.constrain(result_type, self.expression_type(expression), origin)
  self.call_targets[call_slot] = SelectedDynamicTraitCallTarget(
    trait_declaration,
    requirement,
    slot,
    { start, length: self.call_type_arguments.length() - start, },
  )
  true
}

///|
fn BasicBodyInferencer::select_declared_bound_method(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  receiver : ExprId,
  name : NameId,
  arguments : HirSpan,
  offset : UInt64,
) -> Bool {
  let evidence = self.declared_body_trait_evidence(
    self.expression_type(receiver),
    None,
    name,
    expression~,
  )
  if evidence.length() == 0 {
    return false
  }
  if evidence.length() > 1 {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(
      AmbiguousMethod(
        name,
        expression,
        evidence[0].requirement,
        evidence[1].requirement,
        evidence.length(),
        offset,
      ),
    )
    return true
  }
  let selected = evidence[0]
  let declaration = selected.requirement
  if !self.callable_exists(declaration) ||
    self.call_parameter_count(declaration) == 0 ||
    !self.call_parameter_is_receiver(declaration, 0) ||
    self.call_parameter_count(declaration) - 1 != arguments.length {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(NoMatchingMethod(name, expression, offset))
    return true
  }
  let receiver_type = self.expression_type(receiver)
  self.begin_declared_body_trait_evidence(selected, receiver_type)
  let method_count = self.call_generic_count(declaration)
  if !self.apply_explicit_call_type_arguments(
      expression,
      self.call_scratch.candidate_type_arguments.length() - method_count,
      method_count,
    ) {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(NoMatchingMethod(name, expression, offset))
    return true
  }
  let origin = call_type_origin(expression, offset)
  self.constrain(
    receiver_type,
    self.instantiate_signature_type(self.call_parameter_type(declaration, 0)),
    origin,
  )
  for index in 0..<arguments.length {
    self.constrain_assignable(
      self.expression_type(
        self.collected.expression_children[arguments.start + index],
      ),
      self.instantiate_signature_type(
        self.call_parameter_type(declaration, index + 1),
      ),
      origin,
    )
  }
  self.constrain_assignable(
    self.instantiate_signature_type(self.call_result_type(declaration)),
    self.expression_type(expression),
    origin,
  )
  let start = self.call_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.call_type_arguments.push(type_)
  }
  self.call_targets[call_slot] = if selected.evidence_index < 0 {
    SelectedInferredCallTarget(declaration, {
      start,
      length: self.call_scratch.candidate_type_arguments.length(),
    })
  } else {
    SelectedBoundInferredCallTarget(declaration, selected.evidence_index, {
      start,
      length: self.call_scratch.candidate_type_arguments.length(),
    })
  }
  self.validate_method_call_obligations(
    expression,
    declaration,
    { start, length: self.call_scratch.candidate_type_arguments.length(), },
    self.call_scratch.candidate_type_arguments.length() - method_count,
    offset,
  )
  true
}

///|
fn BasicBodyInferencer::try_resolve_operator(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> Bool {
  let source = self.collected.expressions[expression]
  let (trait_name, method_name_string, target_expression, offset) = match
    source {
    HirStringExpr(_, offset) => ("Eq", "eq", expression, offset)
    HirBinaryExpr(operator, left, _, offset) => {
      let (trait_name, method_name) = binary_operator_trait(operator).unwrap()
      (trait_name, method_name, left, offset)
    }
    HirIndexExpr(base, _, offset) | HirIndexSetExpr(base, _, _, offset) => {
      let (trait_name, method_name) = index_trait(source).unwrap()
      (trait_name, method_name, base, offset)
    }
    _ => abort("operator work item is not operator-backed syntax")
  }
  let (left, right) = match source {
    HirBinaryExpr(_, left, right, _) => (left, right)
    HirStringExpr(_, _) => (expression, expression)
    _ => (-1, -1)
  }
  let trait_declaration = self.trait_declaration_named(trait_name).unwrap()
  let method_name = self.collected.find_name(method_name_string).unwrap()
  if left >= 0 &&
    self.select_declared_bound_operator(
      expression, trait_declaration, method_name, left, right, offset,
    ) {
    return true
  }
  if self.body_impl_target_head(self.expression_type(target_expression)) is None {
    if self.defer_expression_check(expression, [
        self.expression_type(target_expression),
      ]) {
      return true
    }
    return false
  }
  if self.type_is_error(self.expression_type(target_expression)) ||
    (right >= 0 && self.type_is_error(self.expression_type(right))) {
    self.operator_targets[self.expression_index(expression)] = ErrorInferredCallTarget
    self.poison_expression(expression)
    return true
  }
  let deferred_inputs = match source {
    HirBinaryExpr(_, left, right, _) | HirIndexExpr(left, right, _) =>
      [self.expression_type(left), self.expression_type(right)]
    HirIndexSetExpr(target, index, value, _) =>
      [
        self.expression_type(target),
        self.expression_type(index),
        self.expression_type(value),
      ]
    _ => []
  }
  if self.defer_expression_check(expression, deferred_inputs) {
    return true
  }
  self.collect_operator_candidates(trait_declaration, method_name)
  self.call_scratch.trial_viable_count = 0
  self.call_scratch.trial_first_declaration = 0UL
  self.call_scratch.trial_second_declaration = 0UL
  let mut first_impl = -1
  let mut best_specificity = -1
  for candidate_index in 0..<self.call_scratch.method_candidates.length() {
    let declaration = self.call_scratch.method_candidates[candidate_index]
    let implementation_index = self.call_scratch.method_candidate_impls[candidate_index]
    let viable = match source {
      HirBinaryExpr(_, _, _, _) | HirStringExpr(_, _) =>
        self.try_operator_candidate(
          expression, left, right, declaration, implementation_index, offset,
        )
      HirIndexExpr(_, _, _) | HirIndexSetExpr(_, _, _, _) =>
        self.try_index_candidate(
          expression, declaration, implementation_index, offset,
        )
      _ => false
    }
    if viable {
      let specificity = self.impl_index.implementations[implementation_index].specificity
      if specificity > best_specificity {
        best_specificity = specificity
        self.call_scratch.trial_viable_count = 1
        self.call_scratch.trial_first_declaration = declaration
        self.call_scratch.trial_second_declaration = 0UL
        first_impl = implementation_index
      } else if specificity == best_specificity {
        self.call_scratch.trial_viable_count += 1
        if self.call_scratch.trial_viable_count == 2 {
          self.call_scratch.trial_second_declaration = declaration
        }
      }
    }
  }
  if self.call_scratch.trial_viable_count == 1 {
    match source {
      HirBinaryExpr(_, _, _, _) | HirStringExpr(_, _) =>
        self.select_operator_candidate(
          expression,
          left,
          right,
          self.call_scratch.trial_first_declaration,
          first_impl,
          offset,
        )
      HirIndexExpr(_, _, _) | HirIndexSetExpr(_, _, _, _) =>
        self.select_index_candidate(
          expression,
          self.call_scratch.trial_first_declaration,
          first_impl,
          offset,
        )
      _ => ()
    }
  } else if self.call_scratch.trial_viable_count > 1 {
    self.operator_targets[self.expression_index(expression)] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(
      AmbiguousMethod(
        method_name,
        expression,
        self.call_scratch.trial_first_declaration,
        self.call_scratch.trial_second_declaration,
        self.call_scratch.trial_viable_count,
        offset,
      ),
    )
  } else {
    self.operator_targets[self.expression_index(expression)] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(NoMatchingMethod(method_name, expression, offset))
  }
  true
}

///|
fn BasicBodyInferencer::constrain_operator_calls(
  self : BasicBodyInferencer,
  final_ : Bool,
) -> Unit {
  while self.call_scratch.pending_operators.length() > 0 {
    self.call_scratch.deferred_operators.clear()
    let mut progress = false
    for expression in self.call_scratch.pending_operators {
      if self.try_resolve_operator(expression) {
        progress = true
      } else {
        self.call_scratch.deferred_operators.push(expression)
      }
    }
    self.call_scratch.pending_operators.clear()
    for expression in self.call_scratch.deferred_operators {
      self.call_scratch.pending_operators.push(expression)
    }
    if !progress {
      break
    }
  }
  if !final_ {
    return
  }
  for expression in self.call_scratch.pending_operators {
    let inputs = match self.collected.expressions[expression] {
      HirBinaryExpr(_, left, right, _) | HirIndexExpr(left, right, _) =>
        [self.expression_type(left), self.expression_type(right)]
      HirIndexSetExpr(target, index, value, _) =>
        [
          self.expression_type(target),
          self.expression_type(index),
          self.expression_type(value),
        ]
      _ => []
    }
    if self.defer_expression_check(expression, inputs) {
      continue
    }
    let method_name_string = match self.collected.expressions[expression] {
      HirBinaryExpr(operator, _, _, _) =>
        binary_operator_trait(operator).unwrap().1
      source => index_trait(source).unwrap().1
    }
    let method_name = self.collected.find_name(method_name_string).unwrap()
    self.operator_targets[self.expression_index(expression)] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(
      NoMatchingMethod(
        method_name,
        expression,
        self.collected.expressions[expression].offset(),
      ),
    )
  }
  self.call_scratch.pending_operators.clear()
}

///|
fn BasicBodyInferencer::collect_type_qualified_candidates(
  self : BasicBodyInferencer,
  head : ImplTargetHead,
  name : NameId,
) -> Unit {
  self.call_scratch.method_candidates.clear()
  self.call_scratch.method_candidate_impls.clear()
  let static_methods = self.impl_index.method_dispatch_span(
    head, name, true, false,
  )
  for
    offset in static_methods.start..<(static_methods.start +
    static_methods.length) {
    let candidate = self.impl_index.method_dispatch[offset]
    if !self.implementation_visible(candidate.implementation) {
      continue
    }
    self.call_scratch.method_candidates.push(
      self.impl_index.methods[candidate.method_index].declaration,
    )
    self.call_scratch.method_candidate_impls.push(candidate.implementation)
  }
  let instance_methods = self.impl_index.method_dispatch_span(
    head, name, true, true,
  )
  for
    offset in instance_methods.start..<(instance_methods.start +
    instance_methods.length) {
    let candidate = self.impl_index.method_dispatch[offset]
    if !self.implementation_visible(candidate.implementation) {
      continue
    }
    self.call_scratch.method_candidates.push(
      self.impl_index.methods[candidate.method_index].declaration,
    )
    self.call_scratch.method_candidate_impls.push(candidate.implementation)
  }
}

///|
fn BasicBodyInferencer::try_qualified_method_candidate(
  self : BasicBodyInferencer,
  expression : ExprId,
  arguments : HirSpan,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Bool {
  if !self.callable_exists(declaration) ||
    self.call_parameter_count(declaration) != arguments.length {
    return false
  }
  let snapshot = self.solver.snapshot()
  self.begin_method_candidate(implementation_index, declaration) |> ignore
  if !self.apply_explicit_method_type_arguments(
      expression, implementation_index, declaration,
    ) {
    self.solver.rollback(snapshot)
    return false
  }
  let origin = call_type_origin(expression, offset)
  let mut viable = true
  let mut index = 0
  while viable && index < arguments.length {
    viable = self.solver.unify(
      self.expression_type(
        self.collected.expression_children[arguments.start + index],
      ),
      self.instantiate_signature_type(
        self.call_parameter_type(declaration, index),
      ),
      origin,
    )
    index += 1
  }
  if viable {
    viable = self.solver.unify(
      self.expression_type(expression),
      self.instantiate_signature_type(self.call_result_type(declaration)),
      origin,
    )
  }
  if viable {
    viable = self.impl_candidate_bounds_satisfied(
      implementation_index, origin, 0,
    )
  }
  self.solver.rollback(snapshot)
  viable
}

///|
fn BasicBodyInferencer::select_qualified_method_candidate(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  arguments : HirSpan,
  declaration : DeclId,
  implementation_index : Int,
  offset : UInt64,
) -> Unit {
  self.begin_method_candidate(implementation_index, declaration) |> ignore
  guard self.apply_explicit_method_type_arguments(
    expression, implementation_index, declaration,
  ) else {
    abort(
      "selected qualified method has mismatched explicit type argument count",
    )
  }
  let origin = call_type_origin(expression, offset)
  for index in 0..<arguments.length {
    self.constrain_assignable(
      self.expression_type(
        self.collected.expression_children[arguments.start + index],
      ),
      self.instantiate_signature_type(
        self.call_parameter_type(declaration, index),
      ),
      origin,
    )
  }
  self.constrain_assignable(
    self.instantiate_signature_type(self.call_result_type(declaration)),
    self.expression_type(expression),
    origin,
  )
  let start = self.call_type_arguments.length()
  for type_ in self.call_scratch.candidate_type_arguments {
    self.call_type_arguments.push(type_)
  }
  self.call_targets[call_slot] = SelectedInferredCallTarget(declaration, {
    start,
    length: self.call_scratch.candidate_type_arguments.length(),
  })
}

///|
fn BasicBodyInferencer::collect_trait_qualified_candidates(
  self : BasicBodyInferencer,
  trait_declaration : DeclId,
  name : NameId,
) -> Unit {
  self.call_scratch.method_candidates.clear()
  self.call_scratch.method_candidate_impls.clear()
  let static_methods = self.impl_index.trait_method_dispatch_span(
    trait_declaration, name, false,
  )
  for
    offset in static_methods.start..<(static_methods.start +
    static_methods.length) {
    let candidate = self.impl_index.trait_method_dispatch[offset]
    if !self.implementation_visible(candidate.implementation) {
      continue
    }
    self.call_scratch.method_candidates.push(
      self.impl_index.methods[candidate.method_index].declaration,
    )
    self.call_scratch.method_candidate_impls.push(candidate.implementation)
  }
  let instance_methods = self.impl_index.trait_method_dispatch_span(
    trait_declaration, name, true,
  )
  for
    offset in instance_methods.start..<(instance_methods.start +
    instance_methods.length) {
    let candidate = self.impl_index.trait_method_dispatch[offset]
    if !self.implementation_visible(candidate.implementation) {
      continue
    }
    self.call_scratch.method_candidates.push(
      self.impl_index.methods[candidate.method_index].declaration,
    )
    self.call_scratch.method_candidate_impls.push(candidate.implementation)
  }
}

///|
fn BasicBodyInferencer::resolve_type_qualified_method_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  arguments : HirSpan,
  target_head : ImplTargetHead,
  name : NameId,
  offset : UInt64,
) -> Bool {
  self.collect_type_qualified_candidates(target_head, name)
  self.resolve_qualified_method_candidates(
    call_slot, expression, arguments, name, offset,
  )
}

///|
fn BasicBodyInferencer::resolve_trait_qualified_method_call(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  arguments : HirSpan,
  trait_declaration : DeclId,
  name : NameId,
  offset : UInt64,
) -> Bool {
  self.collect_trait_qualified_candidates(trait_declaration, name)
  self.resolve_qualified_method_candidates(
    call_slot, expression, arguments, name, offset,
  )
}

///|
fn BasicBodyInferencer::resolve_qualified_method_candidates(
  self : BasicBodyInferencer,
  call_slot : Int,
  expression : ExprId,
  arguments : HirSpan,
  name : NameId,
  offset : UInt64,
) -> Bool {
  if self.call_scratch.method_candidates.length() == 0 {
    return false
  }
  self.call_scratch.trial_viable_count = 0
  self.call_scratch.trial_first_declaration = 0UL
  self.call_scratch.trial_second_declaration = 0UL
  let mut first_impl = -1
  let mut best_specificity = -1
  for candidate_index in 0..<self.call_scratch.method_candidates.length() {
    let declaration = self.call_scratch.method_candidates[candidate_index]
    let implementation_index = self.call_scratch.method_candidate_impls[candidate_index]
    if self.try_qualified_method_candidate(
        expression, arguments, declaration, implementation_index, offset,
      ) {
      let candidate_specificity = self.impl_index.implementations[implementation_index].specificity
      if candidate_specificity > best_specificity {
        best_specificity = candidate_specificity
        self.call_scratch.trial_viable_count = 1
        self.call_scratch.trial_first_declaration = declaration
        self.call_scratch.trial_second_declaration = 0UL
        first_impl = implementation_index
      } else if candidate_specificity == best_specificity {
        self.call_scratch.trial_viable_count += 1
        if self.call_scratch.trial_viable_count == 2 {
          self.call_scratch.trial_second_declaration = declaration
        }
      }
    }
  }
  if self.call_scratch.trial_viable_count == 1 {
    self.select_qualified_method_candidate(
      call_slot,
      expression,
      arguments,
      self.call_scratch.trial_first_declaration,
      first_impl,
      offset,
    )
  } else if self.call_scratch.trial_viable_count > 1 {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(
      AmbiguousMethod(
        name,
        expression,
        self.call_scratch.trial_first_declaration,
        self.call_scratch.trial_second_declaration,
        self.call_scratch.trial_viable_count,
        offset,
      ),
    )
  } else {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.poison_expression(expression)
    self.diagnose(NoMatchingMethod(name, expression, offset))
  }
  true
}

///|
fn BasicBodyInferencer::body_nominal_type(
  self : BasicBodyInferencer,
  declaration : DeclId,
) -> BodyTypeId? {
  for index, type_ in self.resolved.types {
    match type_ {
      NominalType(candidate) if candidate == declaration =>
        return Some(self.solver.resolved_type(index))
      _ => ()
    }
  }
  None
}

///|

///|
fn BasicBodyInferencer::try_resolve_method_call(
  self : BasicBodyInferencer,
  call_slot : Int,
) -> Bool {
  let expression = self.call_expressions[call_slot]
  let (target, arguments, offset) = match
    self.collected.expressions[expression] {
    HirCallExpr(target, arguments, offset) => (target, arguments, offset)
    _ => abort("method call slot is not a call")
  }
  let (receiver, name) = match self.collected.expressions[target] {
    HirFieldExpr(receiver, name, _) => (receiver, name)
    _ => abort("method call target is not a field expression")
  }
  if self.select_trait_object_method(
      call_slot, expression, receiver, name, arguments, offset,
    ) {
    return true
  }
  if self.select_declared_bound_method(
      call_slot, expression, receiver, name, arguments, offset,
    ) {
    return true
  }
  if self.defer_expression_check(expression, [self.expression_type(receiver)]) {
    return true
  }
  if !self.collect_method_candidates(self.expression_type(receiver), name) {
    return false
  }
  if self.type_is_error(self.expression_type(receiver)) {
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.poison_expression(expression)
    return true
  }
  let mut tier = 0
  while tier < 2 {
    self.call_scratch.trial_viable_count = 0
    self.call_scratch.trial_first_declaration = 0UL
    self.call_scratch.trial_second_declaration = 0UL
    let mut first_impl = -1
    let mut best_specificity = -1
    for candidate_index in 0..<self.call_scratch.method_candidates.length() {
      let implementation_index = self.call_scratch.method_candidate_impls[candidate_index]
      let implementation = self.impl_index.implementations[implementation_index]
      let candidate_tier = match implementation.kind {
        InherentIndexedImpl => 0
        TraitIndexedImpl(_) => 1
      }
      if candidate_tier != tier {
        continue
      }
      let declaration = self.call_scratch.method_candidates[candidate_index]
      if self.try_method_candidate(
          expression, receiver, arguments, declaration, implementation_index, offset,
        ) {
        if implementation.specificity > best_specificity {
          best_specificity = implementation.specificity
          self.call_scratch.trial_viable_count = 1
          self.call_scratch.trial_first_declaration = declaration
          self.call_scratch.trial_second_declaration = 0UL
          first_impl = implementation_index
        } else if implementation.specificity == best_specificity {
          self.call_scratch.trial_viable_count += 1
          if self.call_scratch.trial_viable_count == 2 {
            self.call_scratch.trial_second_declaration = declaration
          }
        }
      }
    }
    if self.call_scratch.trial_viable_count == 1 {
      self.select_method_candidate(
        call_slot,
        expression,
        receiver,
        arguments,
        self.call_scratch.trial_first_declaration,
        first_impl,
        offset,
      )
      return true
    }
    if self.call_scratch.trial_viable_count > 1 {
      self.call_targets[call_slot] = ErrorInferredCallTarget
      self.poison_expression(expression)
      self.diagnose(
        AmbiguousMethod(
          name,
          expression,
          self.call_scratch.trial_first_declaration,
          self.call_scratch.trial_second_declaration,
          self.call_scratch.trial_viable_count,
          offset,
        ),
      )
      return true
    }
    tier += 1
  }
  self.call_targets[call_slot] = ErrorInferredCallTarget
  self.poison_expression(expression)
  self.diagnose(NoMatchingMethod(name, expression, offset))
  true
}

///|
fn BasicBodyInferencer::constrain_method_calls(
  self : BasicBodyInferencer,
  final_ : Bool,
) -> Unit {
  while self.call_scratch.pending_methods.length() > 0 {
    self.call_scratch.deferred_methods.clear()
    let mut progress = false
    for call_slot in self.call_scratch.pending_methods {
      if self.try_resolve_method_call(call_slot) {
        progress = true
      } else {
        self.call_scratch.deferred_methods.push(call_slot)
      }
    }
    self.call_scratch.pending_methods.clear()
    for call_slot in self.call_scratch.deferred_methods {
      self.call_scratch.pending_methods.push(call_slot)
    }
    if !progress {
      break
    }
  }
  if !final_ {
    return
  }
  for call_slot in self.call_scratch.pending_methods {
    let expression = self.call_expressions[call_slot]
    let target = match self.collected.expressions[expression] {
      HirCallExpr(target, _, _) => target
      _ => abort("pending method is not a call")
    }
    let receiver = match self.collected.expressions[target] {
      HirFieldExpr(receiver, _, _) => receiver
      _ => abort("pending method target is not a field")
    }
    self.call_targets[call_slot] = ErrorInferredCallTarget
    self.poison_expression(expression)
    match self.collected.expressions[receiver] {
      HirObjectExpr(_, _) => ()
      _ =>
        if !self.type_is_error(self.expression_type(receiver)) {
          let name = match self.collected.expressions[target] {
            HirFieldExpr(_, name, _) => name
            _ => abort("pending method target is not a field")
          }
          self.diagnose(
            NoMatchingMethod(
              name,
              expression,
              self.collected.expressions[expression].offset(),
            ),
          )
        }
    }
  }
  self.call_scratch.pending_methods.clear()
}

///|
fn BasicBodyInferencer::try_call_candidate(
  self : BasicBodyInferencer,
  expression : ExprId,
  arguments : HirSpan,
  declaration : DeclId,
  offset : UInt64,
) -> Bool {
  if !self.callable_exists(declaration) ||
    !self.call_arity_matches(declaration, arguments) {
    return false
  }
  let snapshot = self.solver.snapshot()
  self.begin_call_candidate(declaration)
  if !self.apply_explicit_call_type_arguments(
      expression,
      0,
      self.call_scratch.candidate_type_arguments.length(),
    ) {
    self.solver.rollback(snapshot)
    return false
  }
  let origin = call_type_origin(expression, offset)
  let parameter_types : Array[BodyTypeId] = []
  for index in 0..<arguments.length {
    parameter_types.push(
      self.instantiate_signature_type(
        self.call_parameter_type(declaration, index),
      ),
    )
  }
  let result_type = self.instantiate_signature_type(
    self.call_result_type(declaration),
  )
  let mut viable = true
  let parameter_order = self.solver.projection_parameter_order(parameter_types)
  for slot in 0..<arguments.length {
    let index = match parameter_order {
      Some(order) => order[slot]
      None => slot
    }
    let parameter_type = parameter_types[index]
    let argument = self.collected.expression_children[arguments.start + index]
    if !self.object_argument_matches_nominal_shape(argument, parameter_type) ||
      !self.assignable_viable(
        self.expression_type(argument),
        parameter_type,
        origin,
      ) {
      viable = false
      break
    }
  }
  if viable {
    viable = self.solver.unify(
      self.expression_type(expression),
      result_type,
      origin,
    )
  }
  self.solver.rollback(snapshot)
  viable
}
