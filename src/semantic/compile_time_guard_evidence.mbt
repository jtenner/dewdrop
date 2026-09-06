///|
fn resolve_compile_time_guarded_evidence(
  context : CompileTimeProgramContext,
  module_ : PlannedModuleLowering,
  bindings : Map[GenericParameterId, CompileTimeType],
  active : DeclId?,
  search : CompileTimeEvidenceSearch,
) -> Unit {
  if module_.expression_evidence.is_empty() {
    return
  }
  let seen : Map[Int, Bool] = {}
  for expression, source in module_.expressions {
    if !compile_time_in_body(module_, expression, active) ||
      (active is None && compile_time_generic_expression(module_, expression)) ||
      source.kind is PlannedPoisonExpression {
      continue
    }
    guard expression < module_.expression_evidence.length() else {
      abort("ARN-103 guarded expression evidence")
    }
    let span = module_.expression_evidence[expression]
    guard program_specialization_span_is_valid(
      span,
      module_.trait_evidence_roots.length(),
    ) else {
      abort("ARN-101 guarded evidence roots")
    }
    let work = []
    for offset in 0..<span.length {
      work.push(module_.trait_evidence_roots[span.start + offset])
    }
    search.include_test_impls = match
      compile_time_expression_owner(module_, expression) {
      Some(declaration) =>
        search.collected.declaration_is_test_only(declaration)
      None => false
    }
    while work.pop() is Some(index) {
      if seen.contains(index) {
        continue
      }
      seen[index] = true
      guard index >= 0 && index < module_.trait_evidence.length() else {
        abort("ARN-104 guarded evidence node")
      }
      let node = module_.trait_evidence[index]
      match node.kind {
        GuardedInferredTraitEvidence(target_id, bound_id) => {
          fn resolve() -> Result[CompileTimeTraitWitness, String] {
            if target_id < 0 ||
              target_id >= module_.resolved_types.length() ||
              bound_id < 0 ||
              bound_id >= module_.resolved_types.length() {
              return Err(
                "CT-040 guarded obligation source type is outside its arena",
              )
            }
            let target = match
              compile_time_read_type(module_, -target_id - 2, bindings) {
              Ok(value) => value
              Err(_) => return Err("CT-040 invalid guarded obligation target")
            }
            let bound = match
              compile_time_read_type(module_, -bound_id - 2, bindings) {
              Ok(value) => value
              Err(_) => return Err("CT-040 invalid guarded obligation bound")
            }
            search.steps = 0
            match search.witness(target, bound) {
              Ok(Some(witness)) => Ok(witness)
              Ok(None) =>
                Err("CT-040 selected branch has no trait implementation")
              Err(error) => Err(error)
            }
          }
          match resolve() {
            Ok(witness) => {
              let resolved = compile_time_witness_node(
                context, module_, witness,
              )
              guard resolved == module_.trait_evidence.length() - 1 else {
                abort("EVD-212 guarded witness root ordering")
              }
              module_.trait_evidence[index] = module_.trait_evidence[resolved]
              ignore(module_.trait_evidence.pop())
            }
            Err(message) =>
              module_.diagnostics.push(
                CompileTimeQueryDiagnostic(expression, message, source.offset),
              )
          }
        }
        _ => {
          guard program_specialization_span_is_valid(
            node.prerequisites,
            module_.trait_evidence_children.length(),
          ) else {
            abort("ARN-101 guarded prerequisite span")
          }
          for offset in 0..<node.prerequisites.length {
            work.push(
              module_.trait_evidence_children[node.prerequisites.start + offset],
            )
          }
        }
      }
    }
  }
}
