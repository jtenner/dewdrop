///|
// A relaxed probe only decides whether source checking can wait. It never
// supplies a target or commits a relaxed type to the caller.
fn BasicBodyInferencer::deferred_overload_equation(
  self : BasicBodyInferencer,
  actual : BodyTypeId,
  expected : BodyTypeId,
  origin : TypeConstraintOrigin,
) -> Bool {
  let snapshot = self.solver.snapshot()
  if self.assignable_viable(actual, expected, origin) {
    self.solver.commit(snapshot)
    true
  } else {
    self.solver.rollback(snapshot)
    self.deferred_constraint_has_no_independent_mismatch(actual, expected)
  }
}

///|
fn BasicBodyInferencer::try_deferred_overload_candidate(
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
  let parameters = []
  for index in 0..<arguments.length {
    parameters.push(
      self.instantiate_signature_type(
        self.call_parameter_type(declaration, index),
      ),
    )
  }
  let result = self.instantiate_signature_type(
    self.call_result_type(declaration),
  )
  let origin = call_type_origin(expression, offset)
  let mut viable = true
  for index in 0..<arguments.length {
    let argument = self.collected.expression_children[arguments.start + index]
    if !self.object_argument_matches_nominal_shape(argument, parameters[index]) ||
      !self.deferred_overload_equation(
        self.expression_type(argument),
        parameters[index],
        origin,
      ) {
      viable = false
      break
    }
  }
  if viable {
    viable = self.deferred_overload_equation(
      result,
      self.expression_type(expression),
      origin,
    )
  }
  self.solver.rollback(snapshot)
  viable
}

///|
fn BasicBodyInferencer::defer_overload_selection(
  self : BasicBodyInferencer,
  expression : ExprId,
  arguments : HirSpan,
  offset : UInt64,
) -> Bool {
  if self.call_scratch.overload_candidates.length() < 2 {
    return false
  }
  guard program_specialization_span_is_valid(
    arguments,
    self.collected.expression_children.length(),
  ) else {
    abort("ARN-101 deferred overload arguments")
  }
  let inputs = [self.expression_type(expression)]
  for index in 0..<arguments.length {
    inputs.push(
      self.expression_type(
        self.collected.expression_children[arguments.start + index],
      ),
    )
  }
  if !self.can_defer_expression_check(expression, inputs) {
    return false
  }
  for declaration in self.call_scratch.overload_candidates {
    if self.try_deferred_overload_candidate(
        expression, arguments, declaration, offset,
      ) {
      return self.defer_expression_check(expression, inputs)
    }
  }
  false
}
