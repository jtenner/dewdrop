///|
fn lowering_test_module(
  module_id : UInt64,
  source : Bytes,
) -> (
  CollectedModule,
  ResolvedModuleTypes,
  ResolvedModuleNames,
  InferredModuleBodies,
  AnalyzedModuleFlows,
  PlannedModuleLowering,
) {
  let collected = collect_bytes(module_id, source)
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
  (collected, resolved, names, inferred, flows, planned)
}

///|
test "lowering plans freeze exact direct and method call targets" {
  let (collected, _, _, inferred, _, planned) = lowering_test_module(
    901UL, b"struct Item {\n  value: I32\n}\nimpl Item {\n  fn read(self) -> I32 {\n    self.value\n  }\n}\nfn add(value: I32) -> I32 {\n  value + 1\n}\nfn use(item: Item) -> I32 {\n  add(item.read())\n}\n",
  )
  assert_eq(planned.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[2])
  assert_eq(calls.length(), 2)
  match planned.expressions[calls[0]].kind {
    PlannedDirectCall(declaration, receiver, _, _) => {
      assert_eq(declaration, collected.methods[0].id)
      assert_true(receiver >= 0)
    }
    _ => fail("expected planned receiver call")
  }
  match planned.expressions[calls[1]].kind {
    PlannedDirectCall(declaration, receiver, _, _) => {
      assert_eq(declaration, collected.declarations[2].id)
      assert_eq(receiver, -1)
    }
    _ => fail("expected planned direct call")
  }
  for call in calls {
    match collected.expressions[call] {
      HirCallExpr(target, _, _) =>
        assert_eq(planned.expressions[target].kind, PlannedConsumedExpression)
      _ => abort("expected call expression")
    }
  }
  assert_eq(
    planned.expressions[calls[1]].type_,
    inferred.expression_types[calls[1]],
  )
  assert_eq(planned.expressions[calls[1]].shape, I32PlannedValueShape)
}

///|
test "lowering plans freeze constructors fields locals and block items" {
  let (collected, _, names, _, _, planned) = lowering_test_module(
    902UL, b"struct Item {\n  value: I32\n}\nfn make(value: I32) -> I32 {\n  let item = Item {\n    value: value\n  }\n  item.value\n}\n",
  )
  assert_eq(planned.diagnostics.length(), 0)
  let body = collected.bodies[0]
  let mut construction = -1
  let mut field = -1
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match planned.expressions[expression].kind {
      PlannedStructNew(_, _, _) => construction = expression
      PlannedFieldGet(_, _) => field = expression
      _ => ()
    }
  }
  assert_true(construction >= 0)
  assert_true(field >= 0)
  match planned.expressions[field].kind {
    PlannedFieldGet(field_id, _) => assert_eq(field_id, collected.fields[0].id)
    _ => fail("expected planned field")
  }
  let block = match body.root {
    BlockBodyRoot(value) => value
    _ => abort("expected block body")
  }
  let items = collected.blocks[block].items
  match planned.block_items[items.start].kind {
    PlannedLetItem(local_id, _, _) =>
      assert_eq(local_id, names.block_item_locals[items.start])
    _ => fail("expected planned let")
  }
}

///|
test "lowering plans distinguish module lets from callable names" {
  let (collected, _, _, _, _, planned) = lowering_test_module(
    905UL, b"let answer = 1\nfn use() -> I32 {\n  answer\n}\n",
  )
  assert_eq(planned.diagnostics.length(), 0)
  let body = collected.bodies[1]
  let root = match body.root {
    BlockBodyRoot(block) =>
      match collected.block_items[collected.blocks[block].items.start] {
        HirExpressionItem(expression, _) => expression
        _ => abort("expected expression item")
      }
    _ => abort("expected block body")
  }
  match planned.expressions[root].kind {
    PlannedModuleValueGet(declaration) =>
      assert_eq(declaration, collected.declarations[0].id)
    _ => fail("expected planned module value read")
  }
}

///|
test "lowering plan body jobs merge deterministically" {
  let collected = collect_bytes(
    903UL, b"fn first(value: I32) -> I32 {\n  value + 1\n}\nfn second(value: I32) -> I32 {\n  value + 2\n}\nfn third(value: I32) -> I32 {\n  value + 3\n}\n",
  )
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
  let forward = plan_module_lowering_in_order(
    collected,
    resolved,
    type_layouts,
    initialization,
    functions,
    names,
    inferred,
    flows,
    [0, 1, 2],
  )
  let reverse = plan_module_lowering_in_order(
    collected,
    resolved,
    type_layouts,
    initialization,
    functions,
    names,
    inferred,
    flows,
    [2, 1, 0],
  )
  assert_eq(forward, reverse)
}

///|
test "unsupported indexes remain explicit poison lowering operations" {
  let (_, _, _, _, _, planned) = lowering_test_module(
    904UL, b"fn read(value: I32, index: I32) -> I32 {\n  value[index]\n}\n",
  )
  let mut unsupported = 0
  for diagnostic in planned.diagnostics {
    match diagnostic {
      UnsupportedIndexLowering(_, _) => unsupported += 1
    }
  }
  assert_eq(unsupported, 1)
}
