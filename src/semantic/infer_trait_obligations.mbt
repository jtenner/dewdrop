///|
priv struct DeclaredBodyTraitEvidence {
  bound_type : ResolvedTypeId
  trait_declaration : DeclId
  requirement : DeclId
  evidence_index : Int
}

///|
fn BasicBodyInferencer::body_generic_parameter_spans(
  self : BasicBodyInferencer,
) -> (HirSpan, HirSpan) {
  match self.collected.declaration(self.body.declaration) {
    Some(MethodReference(method_info)) if method_info.kind == ImplMethodDecl =>
      (
        self.collected.generic_parameters_of(method_info.parent),
        self.collected.generic_parameters_of(self.body.declaration),
      )
    _ =>
      (
        self.collected.generic_parameters_of(self.body.declaration),
        { start: 0, length: 0, },
      )
  }
}

///|
fn BasicBodyInferencer::body_generic_parameter_ordinal(
  self : BasicBodyInferencer,
  parameter : GenericParameterId,
) -> Int? {
  let (owner, method_parameters) = self.body_generic_parameter_spans()
  let parameter_index = semantic_id_local(parameter)
  if parameter_index >= owner.start &&
    parameter_index < owner.start + owner.length {
    return Some(parameter_index - owner.start)
  }
  if parameter_index >= method_parameters.start &&
    parameter_index < method_parameters.start + method_parameters.length {
    return Some(owner.length + parameter_index - method_parameters.start)
  }
  None
}

///|
fn BasicBodyInferencer::direct_body_generic_parameter(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> GenericParameterId? {
  let representative = self.solver.representative_type(type_)
  match self.solver.type_term(representative) {
    BodyResolvedType(resolved_type) =>
      match self.resolved.types[resolved_type] {
        GenericParameterType(parameter) => Some(parameter)
        _ => None
      }
    _ => None
  }
}

///|
fn BasicBodyInferencer::resolved_bound_trait(
  self : BasicBodyInferencer,
  bound_type : ResolvedTypeId,
) -> DeclId? {
  match self.resolved.types[bound_type] {
    TraitType(declaration) => Some(declaration)
    AppliedType(base, _) =>
      match self.resolved.types[base] {
        TraitType(declaration) => Some(declaration)
        _ => None
      }
    _ => None
  }
}

///|
fn BasicBodyInferencer::trait_requirement_named(
  self : BasicBodyInferencer,
  trait_declaration : DeclId,
  name : NameId,
) -> DeclId? {
  let name_string = self.collected.name(name)
  if semantic_id_module(trait_declaration) == self.collected.module_id {
    for method_info in self.collected.methods {
      if method_info.kind == TraitMethodDecl &&
        method_info.parent == trait_declaration &&
        self.collected.name(method_info.name) == name_string {
        return Some(method_info.id)
      }
    }
    return None
  }
  match self.imports {
    Some(imports) =>
      for interface_index in imports.scope.imported_interfaces {
        let interface_ = imports.scope.interfaces[interface_index].unwrap()
        for callable in interface_.callables {
          match callable.kind {
            FrozenTraitCallable(owner) if owner == trait_declaration &&
              callable.name == name_string => return Some(callable.declaration)
            _ => ()
          }
        }
      }
    None => ()
  }
  None
}

///|
fn BasicBodyInferencer::declared_body_trait_evidence(
  self : BasicBodyInferencer,
  target_type : BodyTypeId,
  trait_filter : DeclId?,
  method_name : NameId,
  expression? : ExprId = -1,
) -> Array[DeclaredBodyTraitEvidence] {
  let parameter = match self.direct_body_generic_parameter(target_type) {
    Some(value) => value
    None => return []
  }
  let (owner, method_parameters) = self.body_generic_parameter_spans()
  let mut evidence_index = 0
  let evidence : Array[DeclaredBodyTraitEvidence] = []
  let mut span = owner
  let mut phase = 0
  while phase < 2 {
    for generic_offset in 0..<span.length {
      let generic = self.collected.generic_parameters[span.start +
        generic_offset]
      for bound_offset in 0..<generic.bounds.length {
        let bound_index = generic.bounds.start + bound_offset
        if generic.id == parameter {
          let bound_type = self.resolved.generic_bound_types[bound_index]
          match self.resolved_bound_trait(bound_type) {
            Some(trait_declaration) =>
              if trait_filter is None ||
                trait_filter.unwrap() == trait_declaration {
                match
                  self.trait_requirement_named(trait_declaration, method_name) {
                  Some(requirement) =>
                    evidence.push({
                      bound_type,
                      trait_declaration,
                      requirement,
                      evidence_index,
                    })
                  None => ()
                }
              }
            None => ()
          }
        }
        evidence_index += 1
      }
    }
    span = method_parameters
    phase += 1
  }
  for
    guarded in self.guarded_trait_evidence(
      expression, parameter, trait_filter, method_name,
    ) {
    if !evidence.any(value => {
        value.bound_type == guarded.bound_type &&
        value.requirement == guarded.requirement
      }) {
      evidence.push(guarded)
    }
  }
  evidence
}

///|
fn BasicBodyInferencer::begin_declared_body_trait_evidence(
  self : BasicBodyInferencer,
  evidence : DeclaredBodyTraitEvidence,
  receiver_type : BodyTypeId,
) -> Unit {
  self.call_scratch.instantiation_generics = if semantic_id_module(
      evidence.trait_declaration,
    ) ==
    self.collected.module_id {
    self.collected.generic_parameters_of(evidence.trait_declaration)
  } else {
    match self.imports {
      Some(imports) => imports.generic_parameters_of(evidence.trait_declaration)
      None => { start: 0, length: 0, }
    }
  }
  self.call_scratch.instantiation_method_generics = if semantic_id_module(
      evidence.requirement,
    ) ==
    self.collected.module_id {
    self.collected.generic_parameters_of(evidence.requirement)
  } else {
    { start: 0, length: self.call_generic_count(evidence.requirement), }
  }
  self.call_scratch.candidate_type_arguments.clear()
  match self.resolved.types[evidence.bound_type] {
    AppliedType(_, arguments) =>
      for index in 0..<arguments.length {
        self.call_scratch.candidate_type_arguments.push(
          self.solver.resolved_type(
            self.resolved.type_arguments[arguments.start + index],
          ),
        )
      }
    _ => ()
  }
  for _ in 0..<self.call_scratch.instantiation_method_generics.length {
    self.call_scratch.candidate_type_arguments.push(
      self.solver.fresh_variable(),
    )
  }
  self.call_scratch.instantiation_self_owner = evidence.trait_declaration
  self.call_scratch.instantiation_self_type = receiver_type
  self.next_instantiation_generation()
}

///|
fn BasicBodyInferencer::body_declared_trait_obligation_evidence(
  self : BasicBodyInferencer,
  target : BodyTypeId,
  bound : BodyTypeId,
  trait_declaration : DeclId,
  origin : TypeConstraintOrigin,
) -> Int? {
  let parameter = match self.direct_body_generic_parameter(target) {
    Some(value) => value
    None => return None
  }
  let (owner, method_parameters) = self.body_generic_parameter_spans()
  let mut evidence_index = 0
  let mut span = owner
  let mut phase = 0
  while phase < 2 {
    for generic_offset in 0..<span.length {
      let generic = self.collected.generic_parameters[span.start +
        generic_offset]
      for bound_offset in 0..<generic.bounds.length {
        let bound_type = self.resolved.generic_bound_types[generic.bounds.start +
          bound_offset]
        if generic.id == parameter &&
          self.resolved_bound_trait(bound_type) == Some(trait_declaration) {
          let snapshot = self.solver.snapshot()
          let viable = self.solver.unify(
            bound,
            self.solver.resolved_type(bound_type),
            origin,
          )
          self.solver.rollback(snapshot)
          if viable {
            return Some(evidence_index)
          }
        }
        evidence_index += 1
      }
    }
    span = method_parameters
    phase += 1
  }
  None
}

///|
fn BasicBodyInferencer::body_declared_trait_obligation_satisfied(
  self : BasicBodyInferencer,
  target : BodyTypeId,
  bound : BodyTypeId,
  trait_declaration : DeclId,
  origin : TypeConstraintOrigin,
) -> Bool {
  self.body_declared_trait_obligation_evidence(
    target, bound, trait_declaration, origin,
  )
  is Some(_)
}

///|
fn BasicBodyInferencer::body_impl_target_head(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> ImplTargetHead? {
  let representative = self.solver.representative_type(type_)
  match self.solver.type_term(representative) {
    BodyErrorType => Some(ErrorImplTargetHead)
    BodyVariableType(_)
    | BodyProductType(_)
    | BodyFunctionType(_, _)
    | BodyMemberTypeProjection(_, _, _) => None
    BodyResolvedType(resolved_type) => {
      let (head, _) = resolved_impl_target_head(self.resolved, resolved_type)
      Some(head)
    }
    BodyAppliedType(base, _) =>
      match self.solver.type_term(self.solver.representative_type(base)) {
        BodyResolvedType(resolved_base) => {
          let (head, _) = resolved_impl_target_head(
            self.resolved,
            resolved_base,
          )
          Some(head)
        }
        BodyErrorType => Some(ErrorImplTargetHead)
        _ => None
      }
  }
}

///|
fn BasicBodyInferencer::begin_obligation_impl_candidate(
  self : BasicBodyInferencer,
  implementation_index : Int,
) -> (BodyTypeId, BodyTypeId) {
  let implementation = self.impl_index.implementations[implementation_index]
  self.call_scratch.instantiation_generics = self.implementation_generic_parameters(
    implementation.declaration,
  )
  self.call_scratch.instantiation_method_generics = { start: 0, length: 0, }
  self.call_scratch.candidate_type_arguments.clear()
  for _ in 0..<self.call_scratch.instantiation_generics.length {
    self.call_scratch.candidate_type_arguments.push(
      self.solver.fresh_variable(),
    )
  }
  self.call_scratch.instantiation_self_owner = implementation.declaration
  self.call_scratch.instantiation_self_type = -1
  self.next_instantiation_generation()
  let target = self.instantiate_signature_type(implementation.target_type)
  self.call_scratch.instantiation_self_type = target
  let trait_type = self.instantiate_signature_type(implementation.trait_type)
  (target, trait_type)
}

///|
priv struct PendingImplTraitObligation {
  target : BodyTypeId
  bound : BodyTypeId
  trait_declaration : DeclId
}

///|
fn BasicBodyInferencer::impl_candidate_bounds_satisfied(
  self : BasicBodyInferencer,
  implementation_index : Int,
  origin : TypeConstraintOrigin,
  depth : Int,
) -> Bool {
  if depth >= 64 {
    return false
  }
  let implementation = self.impl_index.implementations[implementation_index]
  let local_impl = semantic_id_module(implementation.declaration) ==
    self.collected.module_id
  let imported = if local_impl {
    None
  } else {
    match self.imports {
      Some(imports) => imports.implementation(implementation.declaration)
      None => None
    }
  }
  let generics = self.implementation_generic_parameters(
    implementation.declaration,
  )
  if generics.length == 0 {
    return true
  }
  let mut requirement_count = 0
  for generic_offset in 0..<generics.length {
    if local_impl {
      requirement_count += self.collected.generic_parameters[generics.start +
        generic_offset].bounds.length
    } else {
      let imported_impl = imported.unwrap()
      let imports = self.imports.unwrap()
      requirement_count += imports.generic_parameter_bounds[imported_impl.generic_bounds.start +
        generic_offset].length
    }
  }
  if requirement_count == 0 {
    return true
  }
  let obligations : Array[PendingImplTraitObligation] = []
  for generic_offset in 0..<generics.length {
    let (parameter_bounds, bound_types) = if local_impl {
      (
        self.collected.generic_parameters[generics.start + generic_offset].bounds,
        self.resolved.generic_bound_types,
      )
    } else {
      let imported_impl = imported.unwrap()
      let imports = self.imports.unwrap()
      (
        imports.generic_parameter_bounds[imported_impl.generic_bounds.start +
        generic_offset],
        imports.generic_bound_types,
      )
    }
    for
      bound_offset in parameter_bounds.start..<(parameter_bounds.start +
      parameter_bounds.length) {
      let resolved_bound = bound_types[bound_offset]
      let trait_declaration = match self.resolved.types[resolved_bound] {
        TraitType(value) => value
        AppliedType(base, _) =>
          match self.resolved.types[base] {
            TraitType(value) => value
            _ => continue
          }
        _ => continue
      }
      obligations.push({
        target: self.call_scratch.candidate_type_arguments[generic_offset],
        bound: self.instantiate_signature_type(resolved_bound),
        trait_declaration,
      })
    }
  }
  for obligation in obligations {
    if !self.trait_obligation_satisfied_at_depth(
        obligation.target,
        obligation.bound,
        obligation.trait_declaration,
        origin,
        depth + 1,
      ) {
      return false
    }
  }
  true
}

///|
fn BasicBodyInferencer::method_candidate_bounds_satisfied(
  self : BasicBodyInferencer,
  declaration : DeclId,
  origin : TypeConstraintOrigin,
  depth : Int,
) -> Bool {
  if depth >= 64 {
    return false
  }
  let local_method = semantic_id_module(declaration) == self.collected.module_id
  let generics = if local_method {
    self.collected.generic_parameters_of(declaration)
  } else {
    match self.imports {
      Some(imports) =>
        match imports.callable(declaration) {
          Some(callable) => callable.generic_parameters
          None => return false
        }
      None => return false
    }
  }
  if generics.length == 0 {
    return true
  }
  let argument_start = self.call_scratch.instantiation_generics.length
  for generic_offset in 0..<generics.length {
    let (parameter_bounds, bound_types) = if local_method {
      (
        self.collected.generic_parameters[generics.start + generic_offset].bounds,
        self.resolved.generic_bound_types,
      )
    } else {
      let imports = self.imports.unwrap()
      let callable = imports.callable(declaration).unwrap()
      (
        imports.generic_parameter_bounds[callable.generic_bounds.start +
        generic_offset],
        imports.generic_bound_types,
      )
    }
    for
      bound_offset in parameter_bounds.start..<(parameter_bounds.start +
      parameter_bounds.length) {
      let resolved_bound = bound_types[bound_offset]
      let trait_declaration = match self.resolved.types[resolved_bound] {
        TraitType(value) => value
        AppliedType(base, _) =>
          match self.resolved.types[base] {
            TraitType(value) => value
            _ => continue
          }
        _ => continue
      }
      if !self.trait_obligation_satisfied_at_depth(
          self.call_scratch.candidate_type_arguments[argument_start +
          generic_offset],
          self.instantiate_signature_type(resolved_bound),
          trait_declaration,
          origin,
          depth + 1,
        ) {
        return false
      }
    }
  }
  true
}

///|
fn BasicBodyInferencer::validate_method_call_obligations(
  self : BasicBodyInferencer,
  expression : ExprId,
  declaration : DeclId,
  type_arguments : HirSpan,
  implementation_generic_count : Int,
  offset : UInt64,
) -> Unit {
  let method_generic_count = self.call_generic_count(declaration)
  if method_generic_count <= 0 {
    return
  }
  self.validate_call_obligations(
    expression,
    declaration,
    {
      start: type_arguments.start + implementation_generic_count,
      length: method_generic_count,
    },
    offset,
  )
}

///|
fn BasicBodyInferencer::trait_obligation_satisfied_at_depth(
  self : BasicBodyInferencer,
  target : BodyTypeId,
  bound : BodyTypeId,
  trait_declaration : DeclId,
  origin : TypeConstraintOrigin,
  depth : Int,
) -> Bool {
  if depth >= 64 {
    return false
  }
  if self.body_declared_trait_obligation_satisfied(
      target, bound, trait_declaration, origin,
    ) {
    return true
  }
  if self.guarded_trait_obligation(target, bound, trait_declaration, origin)
    is Some(_) {
    return true
  }
  let head = match self.body_impl_target_head(target) {
    Some(value) => value
    None => return false
  }
  for bucket in self.impl_index.buckets {
    guard bucket.kind == TraitImplBucket(trait_declaration) &&
      bucket.target_head == head else {
      continue
    }
    for
      offset in bucket.implementations.start..<(bucket.implementations.start +
      bucket.implementations.length) {
      let implementation_index = self.impl_index.bucket_implementations[offset]
      let implementation = self.impl_index.implementations[implementation_index]
      if !implementation.valid ||
        !implementation.coherent ||
        !self.implementation_visible(implementation_index) {
        continue
      }
      let snapshot = self.solver.snapshot()
      let (candidate_target, candidate_trait) = self.begin_obligation_impl_candidate(
        implementation_index,
      )
      let mut viable = self.solver.unify(target, candidate_target, origin) &&
        self.solver.unify(bound, candidate_trait, origin)
      if viable {
        viable = self.impl_candidate_bounds_satisfied(
          implementation_index, origin, depth,
        )
      }
      self.solver.rollback(snapshot)
      if viable {
        return true
      }
    }
  }
  false
}

///|
fn BasicBodyInferencer::select_impl_candidate_prerequisite_evidence_nodes(
  self : BasicBodyInferencer,
  implementation_index : Int,
  origin : TypeConstraintOrigin,
  depth : Int,
) -> Array[Int]? {
  if depth >= 64 {
    return None
  }
  let implementation = self.impl_index.implementations[implementation_index]
  let local_impl = semantic_id_module(implementation.declaration) ==
    self.collected.module_id
  let imported = if local_impl {
    None
  } else {
    match self.imports {
      Some(imports) => imports.implementation(implementation.declaration)
      None => None
    }
  }
  let generics = self.implementation_generic_parameters(
    implementation.declaration,
  )
  if generics.length == 0 {
    return Some([])
  }
  let mut requirement_count = 0
  for generic_offset in 0..<generics.length {
    if local_impl {
      requirement_count += self.collected.generic_parameters[generics.start +
        generic_offset].bounds.length
    } else {
      let imported_impl = imported.unwrap()
      let imports = self.imports.unwrap()
      requirement_count += imports.generic_parameter_bounds[imported_impl.generic_bounds.start +
        generic_offset].length
    }
  }
  if requirement_count == 0 {
    return Some([])
  }
  let obligations : Array[PendingImplTraitObligation] = []
  for generic_offset in 0..<generics.length {
    let (parameter_bounds, bound_types) = if local_impl {
      (
        self.collected.generic_parameters[generics.start + generic_offset].bounds,
        self.resolved.generic_bound_types,
      )
    } else {
      let imported_impl = imported.unwrap()
      let imports = self.imports.unwrap()
      (
        imports.generic_parameter_bounds[imported_impl.generic_bounds.start +
        generic_offset],
        imports.generic_bound_types,
      )
    }
    for
      bound_offset in parameter_bounds.start..<(parameter_bounds.start +
      parameter_bounds.length) {
      let resolved_bound = bound_types[bound_offset]
      let trait_declaration = match self.resolved.types[resolved_bound] {
        TraitType(value) => value
        AppliedType(base, _) =>
          match self.resolved.types[base] {
            TraitType(value) => value
            _ => continue
          }
        _ => continue
      }
      obligations.push({
        target: self.call_scratch.candidate_type_arguments[generic_offset],
        bound: self.instantiate_signature_type(resolved_bound),
        trait_declaration,
      })
    }
  }
  let nodes : Array[Int] = []
  for obligation in obligations {
    match
      self.select_trait_obligation_evidence_at_depth(
        obligation.target,
        obligation.bound,
        obligation.trait_declaration,
        origin,
        depth + 1,
      ) {
      Some(node) => nodes.push(node)
      None => return None
    }
  }
  Some(nodes)
}

///|
fn BasicBodyInferencer::trait_evidence_argument(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> InferredTraitEvidenceArgument? {
  let representative = self.solver.representative_type(type_)
  match self.solver.type_term(representative) {
    BodyErrorType =>
      Some(ShapeInferredTraitEvidenceArgument(ErrorPlannedValueShape))
    BodyVariableType(_) | BodyMemberTypeProjection(_, _, _) => None
    BodyProductType(_) | BodyFunctionType(_, _) =>
      Some(ShapeInferredTraitEvidenceArgument(RefPlannedValueShape))
    BodyAppliedType(_, _) =>
      Some(ShapeInferredTraitEvidenceArgument(RefPlannedValueShape))
    BodyResolvedType(resolved_type) =>
      match self.resolved.types[resolved_type] {
        GenericParameterType(parameter) =>
          match self.body_generic_parameter_ordinal(parameter) {
            Some(ordinal) => Some(GenericInferredTraitEvidenceArgument(ordinal))
            None =>
              Some(ShapeInferredTraitEvidenceArgument(GenericPlannedValueShape))
          }
        _ =>
          Some(
            ShapeInferredTraitEvidenceArgument(
              planned_resolved_value_shape(self.resolved, resolved_type),
            ),
          )
      }
  }
}

///|
fn BasicBodyInferencer::select_trait_obligation_evidence_at_depth(
  self : BasicBodyInferencer,
  target : BodyTypeId,
  bound : BodyTypeId,
  trait_declaration : DeclId,
  origin : TypeConstraintOrigin,
  depth : Int,
) -> Int? {
  if depth >= 64 {
    return None
  }
  match
    self.body_declared_trait_obligation_evidence(
      target, bound, trait_declaration, origin,
    ) {
    Some(slot) => {
      let node = self.trait_evidence.length()
      self.trait_evidence.push({
        kind: BoundInferredTraitEvidence(slot),
        prerequisites: { start: 0, length: 0, },
      })
      return Some(node)
    }
    None => ()
  }
  if self.guarded_trait_obligation(target, bound, trait_declaration, origin)
    is Some((source_target, source_bound)) {
    let node = self.trait_evidence.length()
    self.trait_evidence.push({
      kind: GuardedInferredTraitEvidence(source_target, source_bound),
      prerequisites: { start: 0, length: 0, },
    })
    return Some(node)
  }
  let head = match self.body_impl_target_head(target) {
    Some(value) => value
    None => return None
  }
  for bucket in self.impl_index.buckets {
    guard bucket.kind == TraitImplBucket(trait_declaration) &&
      bucket.target_head == head else {
      continue
    }
    for
      offset in bucket.implementations.start..<(bucket.implementations.start +
      bucket.implementations.length) {
      let implementation_index = self.impl_index.bucket_implementations[offset]
      let implementation = self.impl_index.implementations[implementation_index]
      if !implementation.valid ||
        !implementation.coherent ||
        !self.implementation_visible(implementation_index) {
        continue
      }
      let evidence_start = self.trait_evidence.length()
      let child_start = self.trait_evidence_children.length()
      let rollback_argument_start = self.trait_evidence_arguments.length()
      let snapshot = self.solver.snapshot()
      let (candidate_target, candidate_trait) = self.begin_obligation_impl_candidate(
        implementation_index,
      )
      let viable = self.solver.unify(target, candidate_target, origin) &&
        self.solver.unify(bound, candidate_trait, origin)
      let candidate_arguments : Array[InferredTraitEvidenceArgument] = []
      let mut arguments_complete = viable
      if viable {
        for type_ in self.call_scratch.candidate_type_arguments {
          match self.trait_evidence_argument(type_) {
            Some(argument) => candidate_arguments.push(argument)
            None => arguments_complete = false
          }
        }
      }
      let prerequisites = if arguments_complete {
        self.select_impl_candidate_prerequisite_evidence_nodes(
          implementation_index, origin, depth,
        )
      } else {
        None
      }
      self.solver.rollback(snapshot)
      match prerequisites {
        Some(nodes) => {
          let prerequisite_start = self.trait_evidence_children.length()
          for node in nodes {
            self.trait_evidence_children.push(node)
          }
          let argument_start = self.trait_evidence_arguments.length()
          for argument in candidate_arguments {
            self.trait_evidence_arguments.push(argument)
          }
          let evidence = self.trait_evidence.length()
          self.trait_evidence.push({
            kind: ConcreteInferredTraitEvidence(implementation.declaration, {
              start: argument_start,
              length: candidate_arguments.length(),
            }),
            prerequisites: {
              start: prerequisite_start,
              length: self.trait_evidence_children.length() - prerequisite_start,
            },
          })
          return Some(evidence)
        }
        None => {
          self.trait_evidence.truncate(evidence_start)
          self.trait_evidence_children.truncate(child_start)
          self.trait_evidence_arguments.truncate(rollback_argument_start)
        }
      }
    }
  }
  None
}

///|
fn BasicBodyInferencer::select_trait_obligation_evidence(
  self : BasicBodyInferencer,
  target : BodyTypeId,
  bound : BodyTypeId,
  trait_declaration : DeclId,
  origin : TypeConstraintOrigin,
) -> Int? {
  self.select_trait_obligation_evidence_at_depth(
    target, bound, trait_declaration, origin, 0,
  )
}

///|
fn BasicBodyInferencer::ensure_expression_evidence(
  self : BasicBodyInferencer,
) -> Unit {
  if self.expression_evidence.length() == 0 && self.body.expressions.length > 0 {
    self.expression_evidence = Array::make(self.body.expressions.length, {
      start: 0,
      length: 0,
    })
  }
}

///|
fn BasicBodyInferencer::append_expression_evidence_nodes(
  self : BasicBodyInferencer,
  expression : ExprId,
  nodes : Array[Int],
) -> Unit {
  if nodes.length() == 0 {
    return
  }
  self.ensure_expression_evidence()
  let expression_index = self.expression_index(expression)
  let existing = self.expression_evidence[expression_index]
  if existing.length > 0 &&
    existing.start + existing.length != self.trait_evidence_roots.length() {
    abort("expression evidence roots are not contiguous")
  }
  let start = if existing.length > 0 {
    existing.start
  } else {
    self.trait_evidence_roots.length()
  }
  for node in nodes {
    self.trait_evidence_roots.push(node)
  }
  self.expression_evidence[expression_index] = {
    start,
    length: existing.length + nodes.length(),
  }
}

///|
fn BasicBodyInferencer::record_selected_impl_prerequisite_evidence(
  self : BasicBodyInferencer,
  expression : ExprId,
  implementation_index : Int,
  origin : TypeConstraintOrigin,
) -> Unit {
  match
    self.select_impl_candidate_prerequisite_evidence_nodes(
      implementation_index, origin, 0,
    ) {
    Some(nodes) => self.append_expression_evidence_nodes(expression, nodes)
    None =>
      abort("selected implementation prerequisites lost coherent evidence")
  }
}

///|
fn BasicBodyInferencer::validate_generic_parameter_obligations(
  self : BasicBodyInferencer,
  expression : ExprId,
  declaration : DeclId,
  type_arguments : HirSpan,
  generic_offset : Int,
  parameter : GenericParameterId,
  bounds : HirSpan,
  bound_types : Array[ResolvedTypeId],
  offset : UInt64,
) -> Unit {
  let origin = call_type_origin(expression, offset)
  for bound_offset in bounds.start..<(bounds.start + bounds.length) {
    self.begin_call_candidate(declaration)
    for index in 0..<type_arguments.length {
      self.call_scratch.candidate_type_arguments[index] = self.call_type_arguments[type_arguments.start +
        index]
    }
    let resolved_bound = bound_types[bound_offset]
    let bound = self.instantiate_signature_type(resolved_bound)
    let trait_declaration = match self.resolved.types[resolved_bound] {
      TraitType(value) => value
      AppliedType(base, _) =>
        match self.resolved.types[base] {
          TraitType(value) => value
          _ => continue
        }
      _ => continue
    }
    match
      self.select_trait_obligation_evidence(
        self.call_type_arguments[type_arguments.start + generic_offset],
        bound,
        trait_declaration,
        origin,
      ) {
      Some(evidence) => self.trait_evidence_roots.push(evidence)
      None =>
        self.diagnose(
          UnsatisfiedTraitObligation(
            declaration, parameter, trait_declaration, expression, offset,
          ),
        )
    }
  }
}

///|
fn BasicBodyInferencer::validate_call_obligations_now(
  self : BasicBodyInferencer,
  expression : ExprId,
  declaration : DeclId,
  type_arguments : HirSpan,
  offset : UInt64,
) -> Unit {
  let evidence_start = self.trait_evidence_roots.length()
  if semantic_id_module(declaration) == self.collected.module_id {
    let generics = self.collected.generic_parameters_of(declaration)
    for generic_offset in 0..<generics.length {
      let parameter = self.collected.generic_parameters[generics.start +
        generic_offset]
      self.validate_generic_parameter_obligations(
        expression,
        declaration,
        type_arguments,
        generic_offset,
        parameter.id,
        parameter.bounds,
        self.resolved.generic_bound_types,
        offset,
      )
    }
    if self.trait_evidence_roots.length() > evidence_start {
      self.ensure_expression_evidence()
      self.expression_evidence[self.expression_index(expression)] = {
        start: evidence_start,
        length: self.trait_evidence_roots.length() - evidence_start,
      }
    }
    return
  }
  match self.imports {
    Some(imports) =>
      match imports.callable(declaration) {
        Some(callable) =>
          for generic_offset in 0..<callable.generic_bounds.length {
            let parameter_index = callable.generic_bounds.start + generic_offset
            self.validate_generic_parameter_obligations(
              expression,
              declaration,
              type_arguments,
              generic_offset,
              imports.generic_parameter_ids[parameter_index],
              imports.generic_parameter_bounds[parameter_index],
              imports.generic_bound_types,
              offset,
            )
          }
        None => ()
      }
    None => ()
  }
  if self.trait_evidence_roots.length() > evidence_start {
    self.ensure_expression_evidence()
    self.expression_evidence[self.expression_index(expression)] = {
      start: evidence_start,
      length: self.trait_evidence_roots.length() - evidence_start,
    }
  }
}

///|
fn BasicBodyInferencer::validate_call_obligations(
  self : BasicBodyInferencer,
  expression : ExprId,
  declaration : DeclId,
  type_arguments : HirSpan,
  offset : UInt64,
) -> Unit {
  for index in 0..<type_arguments.length {
    if self.body_type_is_unresolved(
        self.call_type_arguments[type_arguments.start + index],
      ) {
      self.pending_call_obligation_expressions.push(expression)
      self.pending_call_obligation_declarations.push(declaration)
      self.pending_call_obligation_type_arguments.push(type_arguments)
      self.pending_call_obligation_offsets.push(offset)
      return
    }
  }
  self.validate_call_obligations_now(
    expression, declaration, type_arguments, offset,
  )
}
