///|
priv enum CompileTimeGuardWalk {
  GuardExpression(ExprId)
  GuardBlock(BlockId)
  GuardPattern(PatternId)
}

///|
priv enum CompileTimeGuardFact {
  TraitGuardFact(ResolvedTypeId, ResolvedTypeId)
  EqualGuardFact(ResolvedTypeId, ResolvedTypeId)
  ConditionalGuardFact(ExprId, Bool)
} derive(Eq)

///|
fn BasicBodyInferencer::guarded_trait_obligation(
  self : BasicBodyInferencer,
  target : BodyTypeId,
  bound : BodyTypeId,
  trait_declaration : DeclId,
  origin : TypeConstraintOrigin,
) -> (ResolvedTypeId, ResolvedTypeId)? {
  match origin.kind {
    CallTypeConstraint | OperatorTypeConstraint | ExpressionTypeConstraint => ()
    _ => return None
  }
  let expression = origin.source
  self.prepare_guard_scopes()
  let facts = match self.guarded_trait_scopes.get(expression) {
    Some(facts) => facts
    None => return None
  }
  for fact in facts {
    let (source_target, source_bound) = match fact {
      TraitGuardFact(target, bound) => (target, bound)
      _ => continue
    }
    if self.resolved_bound_trait(source_bound) != Some(trait_declaration) {
      continue
    }
    let refined_target = self.guard_refined_type(
      self.solver.resolved_type(source_target),
      expression,
    )
    let refined_bound = self.guard_refined_type(
      self.solver.resolved_type(source_bound),
      expression,
    )
    let snapshot = self.solver.snapshot()
    let viable = self.solver.unify(target, refined_target, origin) &&
      self.solver.unify(bound, refined_bound, origin)
    self.solver.rollback(snapshot)
    if viable {
      return Some((source_target, source_bound))
    }
  }
  None
}

///|
fn compile_time_guard_builtin(name : Bytes) -> Bool {
  compile_time_type_query_arity(name) is Some(_)
}

///|
fn BasicBodyInferencer::guard_builtin_targets(
  self : BasicBodyInferencer,
) -> Map[DeclId, Bytes] {
  if self.guard_builtin_cache is Some(targets) {
    return targets
  }
  let targets = {}
  for builtin in self.collected.builtins {
    if compile_time_guard_builtin(builtin.builtin_name) {
      targets[builtin.declaration] = builtin.builtin_name
    }
  }
  if self.imports is Some(imports) {
    for index in imports.scope.imported_interfaces {
      for callable in imports.scope.interfaces[index].unwrap().callables {
        if callable.kind is FrozenBuiltinCallable(name) &&
          compile_time_guard_builtin(name) {
          targets[callable.declaration] = name
        }
      }
    }
  }
  self.guard_builtin_cache = Some(targets)
  targets
}

///|
fn BasicBodyInferencer::guard_condition_facts(
  self : BasicBodyInferencer,
  expression : ExprId,
  truth : Bool,
  targets : Map[DeclId, Bytes],
) -> Array[CompileTimeGuardFact] {
  let facts = []
  if self.guard_condition_dependent(expression, targets) {
    facts.push(ConditionalGuardFact(expression, truth))
  }
  let work = [(expression, truth)]
  while work.length() > 0 {
    let (expression, truth) = work.pop().unwrap()
    if expression < 0 {
      continue
    }
    match self.collected.expressions[expression] {
      HirPrefixExpr(HirLogicalNot, value, _) => work.push((value, !truth))
      HirBinaryExpr(HirLogicalAnd, left, right, _) if truth => {
        work.push((left, true))
        work.push((right, true))
      }
      HirBinaryExpr(HirLogicalOr, left, right, _) if !truth => {
        work.push((left, false))
        work.push((right, false))
      }
      HirCallExpr(target, arguments, _) if arguments.length == 0 => {
        let declaration = match self.names.expression_references[target] {
          ModuleValueNameReference(name) => {
            let binding = self.collected.value_bindings[name]
            let candidate = self.collected.value_binding_candidates[binding.head]
            if candidate.next >= 0 {
              continue
            }
            candidate.declaration
          }
          ImportedValueNameReference(index) => {
            let imports = self.imports.unwrap()
            if imports.scope.callable_references[index].next >= 0 {
              continue
            }
            imports.callables[index].declaration
          }
          _ => continue
        }
        let name = match targets.get(declaration) {
          Some(value) => value
          None => continue
        }
        if name != b"types.implements" &&
          name != b"types.type_equal" &&
          name != b"types.is_unit" &&
          name != b"types.is_never" {
          continue
        }
        let arguments = self.explicit_call_type_arguments(expression)
        let count = if name == b"types.implements" ||
          name == b"types.type_equal" {
          2
        } else {
          1
        }
        if arguments.length != count {
          continue
        }
        guard program_specialization_span_is_valid(
          arguments,
          self.resolved.explicit_call_type_arguments.length(),
        ) else {
          abort("ARN-101 guarded trait query type arguments")
        }
        let left = self.resolved.explicit_call_type_arguments[arguments.start]
        let dependent = impl_type_contains_generic(self.resolved, left) ||
          (
            count == 2 &&
            impl_type_contains_generic(
              self.resolved,
              self.resolved.explicit_call_type_arguments[arguments.start + 1],
            )
          )
        if dependent {
          facts.push(ConditionalGuardFact(expression, truth))
        }
        if !truth ||
          name == b"types.is_integer" ||
          name == b"types.is_signed_integer" ||
          name == b"types.is_float" {
          continue
        }
        let right = if count == 2 {
          self.resolved.explicit_call_type_arguments[arguments.start + 1]
        } else if name == b"types.is_unit" {
          self.resolved.primitive(UnitType)
        } else {
          self.resolved.primitive(NeverType)
        }
        facts.push(
          if name == b"types.implements" {
            TraitGuardFact(left, right)
          } else {
            EqualGuardFact(left, right)
          },
        )
      }
      _ => ()
    }
  }
  facts
}

///|
fn BasicBodyInferencer::mark_guard_scope(
  self : BasicBodyInferencer,
  root : CompileTimeGuardWalk,
  facts : Array[CompileTimeGuardFact],
) -> Unit {
  if facts.is_empty() {
    return
  }
  let work = [root]
  let seen : Map[ExprId, Bool] = {}
  fn children(span : HirSpan) -> Unit {
    guard program_specialization_span_is_valid(
      span,
      self.collected.expression_children.length(),
    ) else {
      abort("ARN-101 guarded expression children")
    }
    for offset in 0..<span.length {
      work.push(
        GuardExpression(self.collected.expression_children[span.start + offset]),
      )
    }
  }
  fn fields(span : HirSpan) -> Unit {
    guard program_specialization_span_is_valid(
      span,
      self.collected.object_fields.length(),
    ) else {
      abort("ARN-101 guarded object fields")
    }
    for offset in 0..<span.length {
      work.push(
        GuardExpression(self.collected.object_fields[span.start + offset].value),
      )
    }
  }
  while work.length() > 0 {
    match work.pop().unwrap() {
      GuardBlock(block) => {
        let span = self.collected.blocks[block].items
        for offset in 0..<span.length {
          match self.collected.block_items[span.start + offset] {
            HirLetItem(_, _, _, value, _) | HirExpressionItem(value, _) =>
              work.push(GuardExpression(value))
          }
        }
      }
      GuardPattern(pattern) => {
        if pattern < 0 {
          continue
        }
        match self.collected.patterns[pattern] {
          HirLiteralPattern(value, _) => work.push(GuardExpression(value))
          HirQualifiedPattern(root, _, _) => work.push(GuardPattern(root))
          HirTuplePattern(root, span, _)
          | HirAlternativePattern(root, span, _) => {
            work.push(GuardPattern(root))
            for offset in 0..<span.length {
              work.push(
                GuardPattern(
                  self.collected.pattern_children[span.start + offset],
                ),
              )
            }
          }
          HirProductPattern(span, _) =>
            for offset in 0..<span.length {
              work.push(
                GuardPattern(
                  self.collected.pattern_children[span.start + offset],
                ),
              )
            }
          HirStructPattern(root, span, _, _, _) => {
            work.push(GuardPattern(root))
            for offset in 0..<span.length {
              work.push(
                GuardPattern(
                  self.collected.pattern_fields[span.start + offset].pattern,
                ),
              )
            }
          }
          _ => ()
        }
      }
      GuardExpression(expression) => {
        if expression < 0 || seen.contains(expression) {
          continue
        }
        seen[expression] = true
        let existing = self.guarded_trait_scopes.get_or_init(expression, () => {
          []
        })
        for fact in facts {
          if !existing.contains(fact) {
            existing.push(fact)
          }
        }
        match self.collected.expressions[expression] {
          HirProductExpr(span, _) | HirArrayExpr(span, _) => children(span)
          HirObjectExpr(span, _) => fields(span)
          HirConstructExpr(target, span, _) => {
            fields(span)
            work.push(GuardExpression(target))
          }
          HirBlockExpr(block, _) => work.push(GuardBlock(block))
          HirIfExpr(condition, block, alternative, _) => {
            work.push(GuardExpression(condition))
            work.push(GuardBlock(block))
            work.push(GuardExpression(alternative))
          }
          HirMatchExpr(value, arms, _) | HirWhileExpr(value, arms, _) => {
            work.push(GuardExpression(value))
            for offset in 0..<arms.length {
              let arm = self.collected.pattern_arms[self.collected.arm_children[arms.start +
                offset]]
              work.push(GuardPattern(arm.pattern))
              work.push(GuardExpression(arm.guard_condition))
              work.push(GuardExpression(arm.body))
            }
          }
          HirLambdaExpr(lambda, _) =>
            work.push(GuardBlock(self.collected.lambdas[lambda].body.root))
          HirReturnExpr(value, _)
          | HirBreakExpr(value, _)
          | HirContinueExpr(value, _)
          | HirPrefixExpr(_, value, _)
          | HirFieldExpr(value, _, _)
          | HirQualifiedExpr(value, _, _)
          | HirProductFieldExpr(value, _, _, _) =>
            work.push(GuardExpression(value))
          HirBinaryExpr(_, left, right, _)
          | HirIndexExpr(left, right, _)
          | HirAssignmentExpr(left, right, _) => {
            work.push(GuardExpression(left))
            work.push(GuardExpression(right))
          }
          HirCallExpr(target, args, _) => {
            work.push(GuardExpression(target))
            children(args)
          }
          HirIndexSetExpr(target, index, value, _) => {
            work.push(GuardExpression(target))
            work.push(GuardExpression(index))
            work.push(GuardExpression(value))
          }
          _ => ()
        }
      }
    }
  }
}

///|
fn BasicBodyInferencer::prepare_guard_scopes(
  self : BasicBodyInferencer,
) -> Unit {
  if !self.guarded_trait_scopes_ready {
    self.guarded_trait_scopes_ready = true
    let targets = self.guard_builtin_targets()
    if targets.is_empty() {
      return
    }
    // Include enclosing lambda scopes. Facts are indexed by semantic source
    // expression ID, so a sibling body cannot borrow another body's evidence.
    for
      scope in compile_time_source_local_scopes(
        self.collected,
        self.names,
        self.body,
      ) {
      for offset in 0..<scope.expressions.length {
        let id = scope.expressions.start + offset
        let source = self.collected.expressions[id]
        match source {
          HirIfExpr(condition, block, alternative, _) => {
            self.mark_guard_scope(
              GuardBlock(block),
              self.guard_condition_facts(condition, true, targets),
            )
            self.mark_guard_scope(
              GuardExpression(alternative),
              self.guard_condition_facts(condition, false, targets),
            )
          }
          HirBinaryExpr(HirLogicalAnd, left, right, _) =>
            self.mark_guard_scope(
              GuardExpression(right),
              self.guard_condition_facts(left, true, targets),
            )
          HirBinaryExpr(HirLogicalOr, left, right, _) =>
            self.mark_guard_scope(
              GuardExpression(right),
              self.guard_condition_facts(left, false, targets),
            )
          _ => ()
        }
      }
    }
  }
}

///|
fn BasicBodyInferencer::guarded_trait_evidence(
  self : BasicBodyInferencer,
  expression : ExprId,
  target_type : BodyTypeId,
  trait_filter : DeclId?,
  method_name : NameId,
) -> Array[DeclaredBodyTraitEvidence] {
  if expression < 0 {
    return []
  }
  self.prepare_guard_scopes()
  let result = []
  for fact in self.guarded_trait_scopes.get(expression).unwrap_or([]) {
    let (target, bound_type) = match fact {
      TraitGuardFact(target, bound_type) => (target, bound_type)
      _ => continue
    }
    if !impl_type_contains_generic(self.resolved, target) {
      continue
    }
    let snapshot = self.solver.snapshot()
    let matches = self.solver.unify(
      target_type,
      self.solver.resolved_type(target),
      expression_type_origin(
        expression,
        self.collected.expressions[expression].offset(),
      ),
    )
    self.solver.rollback(snapshot)
    if !matches {
      continue
    }
    let trait_declaration = match self.resolved_bound_trait(bound_type) {
      Some(value) => value
      None => continue
    }
    if trait_filter is Some(expected) && expected != trait_declaration {
      continue
    }
    if self.trait_requirement_named(trait_declaration, method_name)
      is Some(requirement) {
      result.push({
        bound_type,
        trait_declaration,
        requirement,
        evidence_index: -1,
      })
    }
  }
  result
}
