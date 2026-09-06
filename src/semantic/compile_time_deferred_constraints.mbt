///|
// A deferred equation may hide only a generic-dependent mismatch. Concrete
// siblings in a tuple, function, or application are still checked here.
priv enum DeferredConstraintShape {
  DeferredUnknownShape
  DeferredAtomShape(ResolvedTypeId)
  DeferredProductShape(Array[BodyTypeId])
  DeferredAppliedShape(BodyTypeId, Array[BodyTypeId])
  DeferredFunctionShape(Array[BodyTypeId], BodyTypeId)
  DeferredInvalidShape
}

///|
fn BasicBodyInferencer::deferred_constraint_shape(
  self : BasicBodyInferencer,
  root : BodyTypeId,
) -> DeferredConstraintShape {
  fn arguments(span : HirSpan, resolved : Bool) -> Array[BodyTypeId] {
    let arena = if resolved {
      self.resolved.type_arguments
    } else {
      self.solver.type_arguments
    }
    guard program_specialization_span_is_valid(span, arena.length()) else {
      abort("ARN-101 deferred constraint arguments")
    }
    let values = []
    for offset in 0..<span.length {
      let child = arena[span.start + offset]
      values.push(
        if resolved {
          self.solver.resolved_type(child)
        } else {
          child
        },
      )
    }
    values
  }
  match self.solver.type_term(self.solver.representative_type(root)) {
    BodyVariableType(_) => DeferredUnknownShape
    BodyResolvedType(id) =>
      match self.resolved.types[id] {
        GenericParameterType(_) | SelfType(_) => DeferredUnknownShape
        ProductType(span) => DeferredProductShape(arguments(span, true))
        AppliedType(base, span) =>
          DeferredAppliedShape(
            self.solver.resolved_type(base),
            arguments(span, true),
          )
        FunctionType(span, result) =>
          DeferredFunctionShape(
            arguments(span, true),
            self.solver.resolved_type(result),
          )
        MemberTypeProjection(_, _, _) if impl_type_contains_generic(
            self.resolved,
            id,
          ) => DeferredUnknownShape
        _ => DeferredAtomShape(id)
      }
    BodyProductType(span) => DeferredProductShape(arguments(span, false))
    BodyAppliedType(base, span) =>
      DeferredAppliedShape(base, arguments(span, false))
    BodyFunctionType(span, result) =>
      DeferredFunctionShape(arguments(span, false), result)
    BodyMemberTypeProjection(owner, _, _) if self.type_depends_on_parameter(
        owner,
      ) => DeferredUnknownShape
    _ => DeferredInvalidShape
  }
}

///|
fn BasicBodyInferencer::deferred_constraint_has_no_independent_mismatch(
  self : BasicBodyInferencer,
  left : BodyTypeId,
  right : BodyTypeId,
) -> Bool {
  let work = [(left, right)]
  let seen = {}
  while work.length() > 0 {
    let pair = work.pop().unwrap()
    if seen.contains(pair) {
      continue
    }
    seen[pair] = true
    let (left, right) = pair
    if self.solver.representative_type(left) ==
      self.solver.representative_type(right) {
      continue
    }
    let a = self.deferred_constraint_shape(left)
    let b = self.deferred_constraint_shape(right)
    let (xs, ys) = match (a, b) {
      (DeferredUnknownShape, _) | (_, DeferredUnknownShape) => continue
      (DeferredAtomShape(a), DeferredAtomShape(b)) => {
        if self.resolved.types[a] != self.resolved.types[b] {
          return false
        }
        continue
      }
      (DeferredProductShape(xs), DeferredProductShape(ys)) => (xs, ys)
      (DeferredAppliedShape(a, xs), DeferredAppliedShape(b, ys)) => {
        work.push((a, b))
        (xs, ys)
      }
      (DeferredFunctionShape(xs, a), DeferredFunctionShape(ys, b)) => {
        work.push((a, b))
        (xs, ys)
      }
      _ => return false
    }
    if xs.length() != ys.length() {
      return false
    }
    for index in 0..<xs.length() {
      work.push((xs[index], ys[index]))
    }
  }
  true
}

///|
fn BasicBodyInferencer::defer_type_constraint(
  self : BasicBodyInferencer,
  left : BodyTypeId,
  right : BodyTypeId,
  origin : TypeConstraintOrigin,
) -> Bool {
  match origin.kind {
    ExpressionTypeConstraint
    | CallTypeConstraint
    | OperatorTypeConstraint
    | ReturnTypeConstraint => ()
    _ => return false
  }
  if !self.solver.snapshots.is_empty() ||
    !self.can_defer_expression_check(origin.source, [left, right]) {
    return false
  }
  let snapshot = self.solver.snapshot()
  let viable = self.solver.unify(left, right, origin)
  self.solver.rollback(snapshot)
  if viable ||
    !self.deferred_constraint_has_no_independent_mismatch(left, right) {
    return false
  }
  self.defer_expression_check(origin.source, [left, right])
}
