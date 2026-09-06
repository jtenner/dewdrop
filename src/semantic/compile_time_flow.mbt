///|
fn refresh_compile_time_block_flow(
  module_ : PlannedModuleLowering,
  block : BlockId,
) -> Unit {
  let source = module_.blocks[block]
  let mut summary = flow(flow_falls_through)
  let mut length = 0
  for offset in 0..<source.items.length {
    if !summary.may_fall_through() {
      break
    }
    length += 1
    match module_.block_items[source.items.start + offset].kind {
      PlannedLetItem(_, _, value) | PlannedExpressionItem(value) =>
        summary = flow_sequence(summary, module_.expressions[value].flow)
      PlannedElidedLetItem(_) => ()
    }
  }
  module_.blocks[block] = {
    ..source,
    items: { ..source.items, length, },
    flow: summary,
  }
}

///|
// Use the evaluation order from the exhaustive IR edge table. Control edges
// are handled separately; a lambda body is not evaluated at closure creation.
fn refresh_compile_time_expression_flow(
  module_ : PlannedModuleLowering,
  expression : ExprId,
) -> Unit {
  let source = module_.expressions[expression]
  let control_input = match source.kind {
    PlannedIfExpression(input, _, _)
    | PlannedMatchExpression(input, _)
    | PlannedWhileExpression(_, input, _)
    | PlannedBinaryExpression(HirLogicalAnd, input, _)
    | PlannedBinaryExpression(HirLogicalOr, input, _) => input
    _ => -1
  }
  if control_input >= 0 &&
    !module_.expressions[control_input].flow.may_fall_through() {
    let start = module_.expression_children.length()
    module_.expression_children.push(control_input)
    module_.expressions[expression] = {
      ..source,
      kind: PlannedParameterSelect({ start, length: 1, }, 0),
      flow: module_.expressions[control_input].flow,
    }
    return
  }
  let summary = match source.kind {
    PlannedPoisonExpression | PlannedConsumedExpression => return
    PlannedLambdaClosure(_, _) => flow(flow_falls_through)
    PlannedBlockExpression(block) => module_.blocks[block].flow
    PlannedIfExpression(condition, block, alternative) =>
      flow_sequence(
        module_.expressions[condition].flow,
        flow_union(
          module_.blocks[block].flow,
          if alternative >= 0 {
            module_.expressions[alternative].flow
          } else {
            flow(flow_falls_through)
          },
        ),
      )
    PlannedMatchExpression(initial, arms)
    | PlannedWhileExpression(_, initial, arms) => {
      let mut branches = flow(0)
      for offset in 0..<arms.length {
        let id = module_.arm_children[arms.start + offset]
        let arm = module_.pattern_arms[id]
        let summary = flow_sequence(
          if arm.guard_condition >= 0 {
            module_.expressions[arm.guard_condition].flow
          } else {
            flow(flow_falls_through)
          },
          module_.expressions[arm.body].flow,
        )
        module_.pattern_arms[id] = { ..arm, flow: summary, }
        branches = flow_union(branches, summary)
      }
      if source.kind is PlannedWhileExpression(_, _, _) {
        let mut exits = branches.outcomes & flow_returns
        if branches.may_break() {
          exits = exits | flow_falls_through
        }
        if branches.may_diverge() ||
          branches.may_continue() ||
          branches.may_fall_through() ||
          (!branches.may_break() && !branches.may_return()) {
          exits = exits | flow_diverges
        }
        branches = flow(exits)
      }
      flow_sequence(module_.expressions[initial].flow, branches)
    }
    PlannedBinaryExpression(HirLogicalAnd, left, right)
    | PlannedBinaryExpression(HirLogicalOr, left, right) =>
      flow_sequence(
        module_.expressions[left].flow,
        flow_union(flow(flow_falls_through), module_.expressions[right].flow),
      )
    _ => {
      let edges : Array[CompileTimeReachTask] = []
      if source.kind is PlannedDirectLambdaCall(_, _, arguments) {
        // The lambda body is a separate flow scope, not a call operand.
        compile_time_push_children(module_, arguments, edges)
      } else {
        compile_time_push_expression(module_, source.kind, edges)
      }
      let evaluations : Array[ExprId] = []
      let mut summary = flow(flow_falls_through)
      for edge in edges {
        let child = match edge {
          CtReachExpression(child) if child >= 0 => child
          _ => continue
        }
        // A resolved static callee is identity metadata, not a runtime operand.
        match module_.expressions[child].kind {
          PlannedConsumedExpression | PlannedFunctionReference(_, _) => continue
          _ => ()
        }
        evaluations.push(child)
        summary = flow_sequence(summary, module_.expressions[child].flow)
        if !summary.may_fall_through() {
          if source.kind is PlannedParameterSelect(arguments, selected) &&
            arguments.length == evaluations.length() &&
            selected == arguments.length - 1 {
            module_.expressions[expression] = { ..source, flow: summary, }
            return
          }
          let start = module_.expression_children.length()
          for value in evaluations {
            module_.expression_children.push(value)
          }
          module_.expressions[expression] = {
            ..source,
            kind: PlannedParameterSelect(
              { start, length: evaluations.length(), },
              evaluations.length() - 1,
            ),
            flow: summary,
          }
          return
        }
      }
      let terminal = match source.kind {
        PlannedReturnExpression(_) => flow(flow_returns)
        PlannedBreakExpression(_, _) => flow(flow_breaks)
        PlannedContinueExpression(_, _) => flow(flow_continues)
        _ =>
          if source.shape is NeverPlannedValueShape {
            flow(flow_diverges)
          } else {
            flow(flow_falls_through)
          }
      }
      flow_sequence(summary, terminal)
    }
  }
  module_.expressions[expression] = { ..source, flow: summary, }
}
