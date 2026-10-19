///|
// Count copied arena entries, not heap bytes. Include both the optimization
// copy and the arrays replaced by the selected instance. Rechecks debit this
// conservative copy bundle again before constructing fresh selected arenas.
fn charge_transform_instance_copy(
  context : CompileTimeProgramContext,
  owner : PlannedModuleLowering,
) -> Bool {
  if context.transform_instance_budget < 0 {
    return true
  }
  let counts = [
    owner.functions.callables.length(),
    owner.functions.parameters.length(),
    owner.bodies.length(),
    owner.lambdas.length(),
    owner.locals.length(),
    owner.blocks.length(),
    owner.expressions.length(),
    owner.block_items.length(),
    owner.patterns.length(),
    owner.pattern_arms.length(),
    owner.expression_children.length(),
    owner.arm_children.length(),
    owner.call_type_arguments.length(),
    owner.call_type_argument_shapes.length(),
    owner.expressions.length(),
    owner.trait_evidence_roots.length(),
    owner.lambdas.length(),
    owner.captures.length(),
    owner.resolved_types.length(),
    owner.resolved_type_arguments.length(),
    owner.types.length(),
    owner.trait_evidence.length(),
    owner.trait_evidence_children.length(),
    owner.trait_evidence_arguments.length(),
    owner.functions.callables.length(),
    owner.functions.parameters.length(),
  ]
  for count in counts {
    if count > context.transform_instance_budget {
      context.transform_instance_exhausted = true
      return false
    }
    context.transform_instance_budget -= count
  }
  true
}
