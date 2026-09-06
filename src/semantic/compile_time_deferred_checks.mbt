///|
fn BasicBodyInferencer::has_deferred_type(
  self : BasicBodyInferencer,
  root : BodyTypeId,
) -> Bool {
  let representative = self.solver.representative_type(root)
  if self.type_is_variable(representative) {
    for deferred in self.deferred_types {
      if self.solver.representative_type(deferred) == representative {
        return true
      }
    }
  }
  false
}

///|
fn BasicBodyInferencer::type_depends_on_parameter(
  self : BasicBodyInferencer,
  root : BodyTypeId,
) -> Bool {
  let work = [root]
  let seen = {}
  while work.length() > 0 {
    let type_ = self.solver.representative_type(work.pop().unwrap())
    if seen.contains(type_) {
      continue
    }
    seen[type_] = true
    match self.solver.type_term(type_) {
      BodyResolvedType(id) =>
        if impl_type_contains_generic(self.resolved, id) {
          return true
        }
      BodyProductType(arguments)
      | BodyAppliedType(_, arguments)
      | BodyFunctionType(arguments, _) as node => {
        for offset in 0..<arguments.length {
          work.push(self.solver.type_arguments[arguments.start + offset])
        }
        match node {
          BodyAppliedType(base, _) => work.push(base)
          BodyFunctionType(_, result) => work.push(result)
          _ => ()
        }
      }
      BodyMemberTypeProjection(owner, _, _) => work.push(owner)
      _ => ()
    }
  }
  false
}

///|
fn BasicBodyInferencer::defer_expression_check(
  self : BasicBodyInferencer,
  expression : ExprId,
  inputs : Array[BodyTypeId],
) -> Bool {
  if !self.can_defer_expression_check(expression, inputs) {
    return false
  }
  self.ensure_member_storage()
  self.expression_selections[self.expression_index(expression)] = DeferredExpressionSelection
  self.deferred_types.push(self.expression_type(expression))
  true
}

///|
fn BasicBodyInferencer::can_defer_expression_check(
  self : BasicBodyInferencer,
  expression : ExprId,
  inputs : Array[BodyTypeId],
) -> Bool {
  if expression < self.body.expressions.start ||
    expression - self.body.expressions.start >= self.body.expressions.length {
    return false
  }
  // Concrete rechecks can never create another deferred check.
  if self.reachability is Some(live) &&
    live.declaration == self.body.declaration {
    return false
  }
  let mut dependent = false
  for type_ in inputs {
    if self.has_deferred_type(type_) {
      dependent = true
    }
  }
  if !dependent {
    self.prepare_guard_scopes()
    let mut guarded = self.guarded_trait_scopes
      .get(expression)
      .unwrap_or([])
      .any(fact => fact is ConditionalGuardFact(_, _))
    if self.collected.expressions[expression] is HirIfExpr(condition, _, _, _) {
      guarded = guarded ||
        self.guard_condition_dependent(condition, self.guard_builtin_targets())
    }
    if !guarded || !inputs.any(type_ => self.type_depends_on_parameter(type_)) {
      return false
    }
  }
  true
}
