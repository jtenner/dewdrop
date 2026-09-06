///|
// This records dependence, not a proof of truth or of a particular type.
fn BasicBodyInferencer::guard_condition_dependent(
  self : BasicBodyInferencer,
  root : ExprId,
  targets : Map[DeclId, Bytes],
) -> Bool {
  let work = [root]
  let seen = {}
  while work.length() > 0 {
    let expression = work.pop().unwrap()
    if expression < 0 || seen.contains(expression) {
      continue
    }
    guard expression < self.collected.expressions.length() else {
      abort("ARN-104 query guard dependency expression")
    }
    seen[expression] = true
    match self.collected.expressions[expression] {
      HirPrefixExpr(_, value, _)
      | HirFieldExpr(value, _, _)
      | HirQualifiedExpr(value, _, _)
      | HirProductFieldExpr(value, _, _, _) => work.push(value)
      HirBinaryExpr(_, left, right, _) | HirIndexExpr(left, right, _) => {
        work.push(left)
        work.push(right)
      }
      HirCallExpr(target, arguments, _) => {
        guard target >= 0 && target < self.names.expression_references.length() else {
          abort("ARN-104 query guard dependency target")
        }
        let declaration = match self.names.expression_references[target] {
          ModuleValueNameReference(name) => {
            let binding = self.collected.value_bindings[name]
            let candidate = self.collected.value_binding_candidates[binding.head]
            if candidate.next >= 0 {
              0UL
            } else {
              candidate.declaration
            }
          }
          ImportedValueNameReference(index) => {
            let imports = self.imports.unwrap()
            if imports.scope.callable_references[index].next >= 0 {
              0UL
            } else {
              imports.callables[index].declaration
            }
          }
          _ => 0UL
        }
        if targets.contains(declaration) {
          let span = self.explicit_call_type_arguments(expression)
          guard program_specialization_span_is_valid(
            span,
            self.resolved.explicit_call_type_arguments.length(),
          ) else {
            abort("ARN-101 query guard dependency arguments")
          }
          for offset in 0..<span.length {
            if impl_type_contains_generic(
                self.resolved,
                self.resolved.explicit_call_type_arguments[span.start + offset],
              ) {
              return true
            }
          }
        }
        work.push(target)
        guard program_specialization_span_is_valid(
          arguments,
          self.collected.expression_children.length(),
        ) else {
          abort("ARN-101 query guard dependency operands")
        }
        for offset in 0..<arguments.length {
          work.push(
            self.collected.expression_children[arguments.start + offset],
          )
        }
      }
      _ => ()
    }
  }
  false
}
