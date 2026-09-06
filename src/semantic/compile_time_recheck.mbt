///|
fn compile_time_body_needs_recheck(
  context : CompileTimeProgramContext,
  owner_index : Int,
  declaration : DeclId,
) -> Bool {
  let owner = context.modules[owner_index]
  let inferred = context.analyzed.modules[owner_index].inferred
  for body in owner.bodies {
    if body.declaration == declaration {
      for expression in compile_time_owned_expressions(owner, body) {
        if inferred.expression_selections[expression]
          is DeferredExpressionSelection {
          return true
        }
      }
    }
  }
  false
}

///|
fn recheck_compile_time_body(
  context : CompileTimeProgramContext,
  owner_index : Int,
  declaration : DeclId,
  bindings : Map[GenericParameterId, CompileTimeType],
  conditions : Map[ExprId, Bool],
  previous : PlannedModuleLowering,
) -> PlannedModuleLowering {
  let owner = context.modules[owner_index]
  let analyzed = context.analyzed.modules[owner_index]
  let (collected, mask) = selected_inference_source(
    context.program.modules[owner_index],
    analyzed.names,
    declaration,
    conditions,
  )
  let (resolved, substitutions) = compile_time_inference_types(
    owner,
    context.analyzed.frozen.interfaces[owner_index].resolved_types,
    bindings,
  )
  let live = { ..mask, type_substitutions: substitutions, }
  let order = []
  for index in 0..<collected.bodies.length() {
    order.push(index)
  }
  let inferred = infer_module_bodies_with_imports_in_order_and_family_cache(
      collected,
      resolved,
      Some(analyzed.imports),
      analyzed.names,
      order,
      Array::make(collected.bodies.length(), None),
      reachability=Some(live),
    ).unwrap().inferred
  if !inferred.diagnostics.is_empty() {
    for diagnostic in inferred.diagnostics {
      let offset = diagnostic.offset()
      let mut expression = -1
      for id, source in collected.expressions {
        if live.expressions[id] && source.offset() == offset {
          expression = id
          break
        }
      }
      previous.diagnostics.push(
        CompileTimeQueryDiagnostic(
          expression,
          "CT-041 selected body check failed: " + @debug.to_string(diagnostic),
          offset,
        ),
      )
    }
    return previous
  }
  let flows = analyze_module_flows_with_imports(
    collected,
    resolved,
    inferred,
    analyzed.imports,
  )
  let selected = plan_module_lowering_in_order(
    collected,
    resolved,
    owner.type_layouts,
    owner.initialization,
    {
      ..owner.functions,
      callables: owner.functions.callables.copy(),
      parameters: owner.functions.parameters.copy(),
    },
    analyzed.names,
    inferred,
    flows,
    order,
    reachability=Some(live),
  )
  fold_module_compile_time_queries(
    context,
    owner_index,
    selected,
    bindings,
    Some(declaration),
  )
  selected
}
