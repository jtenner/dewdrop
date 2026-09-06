///|
// A read is refined at its source expression, not by rebinding the generic
// parameter or its local slot. Sibling branches keep their original types.
fn BasicBodyInferencer::guard_refined_type(
  self : BasicBodyInferencer,
  root : BodyTypeId,
  expression : ExprId,
) -> BodyTypeId {
  if expression < 0 {
    return root
  }
  self.prepare_guard_scopes()
  let facts = match self.guarded_trait_scopes.get(expression) {
    Some(value) => value
    None => return root
  }
  self.guard_refine_with_facts(root, expression, facts)
}

///|
fn BasicBodyInferencer::guard_refine_with_facts(
  self : BasicBodyInferencer,
  root : BodyTypeId,
  expression : ExprId,
  facts : Array[CompileTimeGuardFact],
) -> BodyTypeId {
  let bindings : Map[GenericParameterId, BodyTypeId] = {}
  fn representative(id : ResolvedTypeId) -> ResolvedTypeId {
    let mut current = id
    let mut hops = 0
    while self.resolved.types[current] is GenericParameterType(parameter) {
      match bindings.get(parameter) {
        Some(value) => current = -(value + 2)
        None => break
      }
      hops += 1
      guard hops <= bindings.length() else {
        abort("SOL-202 guarded equality parent cycle")
      }
    }
    current
  }
  for fact in facts {
    let (left, right) = match fact {
      EqualGuardFact(left, right) =>
        (representative(left), representative(right))
      _ => continue
    }
    if left == right {
      continue
    }
    match (self.resolved.types[left], self.resolved.types[right]) {
      (
        GenericParameterType(left_parameter),
        GenericParameterType(right_parameter),
      ) =>
        if left_parameter > right_parameter {
          bindings[left_parameter] = self.solver.resolved_type(right)
        } else if right_parameter > left_parameter {
          bindings[right_parameter] = self.solver.resolved_type(left)
        }
      (GenericParameterType(parameter), _) =>
        bindings[parameter] = self.solver.resolved_type(right)
      (_, GenericParameterType(parameter)) =>
        bindings[parameter] = self.solver.resolved_type(left)
      // Keep contradictory source facts intact. They do not certify a read.
      // The selected-body query pass determines whether this branch can run.
      _ => return root
    }
  }
  if bindings.is_empty() {
    return root
  }
  fn refine(root : BodyTypeId, depth : Int) -> BodyTypeId {
    if depth >= 256 {
      self.diagnose(
        BodyConstraintDiagnostic(
          InvalidLocalMemberProjection(
            root,
            "CT-034 guarded type refinement limit exceeded",
            expression_type_origin(
              expression,
              self.collected.expressions[expression].offset(),
            ),
          ),
        ),
      )
      return self.solver.error_type()
    }
    let root = self.solver.representative_type(root)
    match self.solver.type_term(root) {
      BodyResolvedType(id) =>
        match self.resolved.types[id] {
          GenericParameterType(parameter) =>
            match bindings.get(parameter) {
              Some(value) if value != root => refine(value, depth + 1)
              _ => root
            }
          ProductType(_)
          | AppliedType(_, _)
          | FunctionType(_, _)
          | MemberTypeProjection(_, _, _) =>
            match self.solver.substitute_member_type(id, bindings, depth + 1) {
              Ok(value) => value
              Err(message) => {
                self.diagnose(
                  BodyConstraintDiagnostic(
                    InvalidLocalMemberProjection(
                      root,
                      message,
                      expression_type_origin(
                        expression,
                        self.collected.expressions[expression].offset(),
                      ),
                    ),
                  ),
                )
                self.solver.error_type()
              }
            }
          _ => root
        }
      BodyProductType(span)
      | BodyAppliedType(_, span)
      | BodyFunctionType(span, _) as type_ => {
        let values = []
        let mut changed = false
        for index in 0..<span.length {
          let original = self.solver.type_arguments[span.start + index]
          let value = refine(original, depth + 1)
          changed = changed || original != value
          values.push(value)
        }
        match type_ {
          BodyAppliedType(base, _) => {
            let value = refine(base, depth + 1)
            if changed || value != base {
              self.solver.applied_type(value, values)
            } else {
              root
            }
          }
          BodyFunctionType(_, result) => {
            let value = refine(result, depth + 1)
            if changed || value != result {
              self.solver.function_type(values, value)
            } else {
              root
            }
          }
          _ => if changed { self.solver.product_type(values) } else { root }
        }
      }
      BodyMemberTypeProjection(owner, operation, selector) => {
        let value = refine(owner, depth + 1)
        if value != owner {
          self.solver.member_projection_type(value, operation, selector)
        } else {
          root
        }
      }
      _ => root
    }
  }
  refine(root, 0)
}

///|
fn BasicBodyInferencer::guard_has_condition_facts(
  self : BasicBodyInferencer,
  condition : ExprId,
) -> Bool {
  let targets = self.guard_builtin_targets()
  !self.guard_condition_facts(condition, true, targets).is_empty() ||
  !self.guard_condition_facts(condition, false, targets).is_empty()
}

///|
fn BasicBodyInferencer::guard_branch_type(
  self : BasicBodyInferencer,
  root : BodyTypeId,
  condition : ExprId,
  truth : Bool,
) -> BodyTypeId {
  self.prepare_guard_scopes()
  let facts = self.guard_condition_facts(
    condition,
    truth,
    self.guard_builtin_targets(),
  )
  if self.guarded_trait_scopes.get(condition) is Some(outer) {
    for fact in outer {
      facts.push(fact)
    }
  }
  self.guard_refine_with_facts(root, condition, facts)
}

///|
// The surrounding return, local and call contracts seed the shared result
// before either branch checks it under that branch's own assumptions.
fn BasicBodyInferencer::constrain_guarded_joins(
  self : BasicBodyInferencer,
) -> Unit {
  for expression in self.pending_guarded_joins {
    let (condition, block, alternative, offset) = match
      self.collected.expressions[expression] {
      HirIfExpr(condition, block, alternative, offset) =>
        (condition, block, alternative, offset)
      _ => abort("BOD-609 guarded join is not an if expression")
    }
    let result = self.expression_type(expression)
    let then_type = self.block_type(block)
    let else_type = self.expression_type(alternative)
    let origin = expression_type_origin(expression, offset)
    if self.is_never_type(then_type) && self.is_never_type(else_type) {
      self.constrain(result, self.primitive(NeverType), origin)
      // A generic sibling can supply the logical result before a concrete
      // branch narrows it. Never must not constrain a completing sibling.
    } else if self.solver.type_term(self.solver.representative_type(else_type))
      is BodyResolvedType(id) &&
      self.resolved.types[id] is GenericParameterType(_) {
      self.constrain_assignable(
        else_type,
        self.guard_branch_type(result, condition, false),
        origin,
      )
      self.constrain_assignable(
        then_type,
        self.guard_branch_type(result, condition, true),
        origin,
      )
    } else {
      self.constrain_assignable(
        then_type,
        self.guard_branch_type(result, condition, true),
        origin,
      )
      self.constrain_assignable(
        else_type,
        self.guard_branch_type(result, condition, false),
        origin,
      )
    }
  }
  self.pending_guarded_joins.clear()
}
