///|
#skip("large compiler stress case; run tools/test-stress-native.sh")
test "lowering plans remain iterative through 1024 prefixes" {
  let collected = collect_bytes(905UL, deeply_prefixed_let(1024))
  let resolved = resolve_module_types(collected)
  let type_layouts = plan_module_type_layouts(collected, resolved)
  let functions = plan_module_functions(collected, resolved)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let initialization = plan_module_initialization(
    collected,
    inferred.module_values,
  )
  let flows = analyze_module_flows(collected, resolved, inferred)
  let planned = plan_module_lowering(
    collected, resolved, type_layouts, initialization, functions, names, inferred,
    flows,
  )
  assert_eq(planned.diagnostics.length(), 0)
  assert_eq(planned.expressions.length(), 1025)
  let mut prefixes = 0
  for expression in planned.expressions {
    match expression.kind {
      PlannedPrefixExpression(_, _) => prefixes += 1
      _ => ()
    }
  }
  assert_eq(prefixes, 1024)
}

///|
#skip("large compiler stress case; run tools/test-stress-native.sh")
test "lowering plans retain 512 exact method targets" {
  let collected = collect_bytes(906UL, many_inherent_methods_source(512))
  let resolved = resolve_module_types(collected)
  let type_layouts = plan_module_type_layouts(collected, resolved)
  let functions = plan_module_functions(collected, resolved)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let initialization = plan_module_initialization(
    collected,
    inferred.module_values,
  )
  let flows = analyze_module_flows(collected, resolved, inferred)
  let planned = plan_module_lowering(
    collected, resolved, type_layouts, initialization, functions, names, inferred,
    flows,
  )
  assert_eq(planned.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[512])
  assert_eq(calls.length(), 512)
  for index, call in calls {
    match planned.expressions[call].kind {
      PlannedDirectCall(declaration, receiver, _, _) => {
        assert_eq(declaration, collected.methods[index].id)
        assert_true(receiver >= 0)
      }
      _ => fail("expected planned stress method")
    }
  }
}
