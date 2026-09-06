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
test "lowering freezes mutable field writes" {
  let (collected, _, _, _, _, planned) = lowering_test_module(
    913UL, b"struct Box<t> {\n  mut value: t\n}\nfn write(box: Box<I32>, value: I32) -> Unit {\n  box.value = value\n}\n",
  )
  assert_eq(planned.diagnostics.length(), 0)
  let mut field_set = 0
  for expression in planned.expressions {
    match expression.kind {
      PlannedFieldSet(field, base, value) => {
        field_set += 1
        assert_eq(field, collected.fields[0].id)
        assert_true(base >= 0)
        assert_true(value >= 0)
      }
      _ => ()
    }
  }
  assert_eq(field_set, 1)
}

///|
test "lowering freezes runtime trait coercions and dynamic slots" {
  let (collected, _, _, _, _, planned) = lowering_test_module(
    907UL, b"trait Read {\n  fn read(self) -> I32\n}\nstruct Item {}\nimpl Read for Item {\n  fn read(self) -> I32 {\n    42\n  }\n}\nfn invoke(value: Read) -> I32 {\n  value.read()\n}\nfn use() -> I32 {\n  invoke(Item::{})\n}\n",
  )
  assert_eq(planned.diagnostics.length(), 0)
  let invoke_calls = body_calls(collected, collected.bodies[1])
  match planned.expressions[invoke_calls[0]].kind {
    PlannedDynamicTraitCall(trait_, requirement, slot, receiver, _, arguments) => {
      assert_eq(trait_, collected.declarations[0].id)
      assert_eq(requirement, collected.methods[0].id)
      assert_eq(slot, 0)
      assert_true(receiver >= 0)
      assert_eq(arguments.length, 0)
    }
    _ => fail("expected planned dynamic trait call")
  }
  let use_calls = body_calls(collected, collected.bodies[2])
  let call = use_calls[0]
  let source_arguments = match collected.expressions[call] {
    HirCallExpr(_, values, _) => values
    _ => fail("expected call")
  }
  let item = collected.expression_children[source_arguments.start]
  match planned.expressions[item].trait_object_coercion {
    SelectedInferredTraitObjectCoercion(trait_, evidence) => {
      assert_eq(trait_, collected.declarations[0].id)
      assert_true(evidence >= 0)
    }
    _ => fail("expected planned trait coercion")
  }
}

///|
test "lowering preserves instantiated generic aggregate callback signatures" {
  let (collected, resolved, _, _, _, planned) = lowering_test_module(
    906UL, b"struct CallbackBox<t> {\n  callback: fn(t) -> t\n}\nfn increment(value: I32) -> I32 {\n  value + 1\n}\nfn identity<t>(value: CallbackBox<t>) -> CallbackBox<t> {\n  value\n}\nfn use() -> I32 {\n  let box = identity(CallbackBox::{\n    callback: increment\n  })\n  let callback = box.callback\n  callback(41)\n}\n",
  )
  assert_eq(planned.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[2])
  let mut function_type = -1
  for call in calls {
    match planned.expressions[call].kind {
      PlannedFunctionValueCall(_, _, type_) => function_type = type_
      _ => ()
    }
  }
  assert_true(function_type >= 0)
  match resolved.types[function_type] {
    FunctionType(parameters, result) => {
      assert_eq(parameters.length, 1)
      assert_eq(
        resolved.types[resolved.type_arguments[parameters.start]],
        PrimitiveType(I32Type),
      )
      assert_eq(resolved.types[result], PrimitiveType(I32Type))
    }
    _ => fail("expected concrete function type")
  }
}

///|
test "lowering plans freeze constructors fields locals and block items" {
  let (collected, _, names, _, _, planned) = lowering_test_module(
    902UL, b"struct Item {\n  value: I32\n}\nfn make(value: I32) -> I32 {\n  let item = Item::{\n    value: value\n  }\n  item.value\n}\n",
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
      PlannedFieldGet(_, _, _) => field = expression
      _ => ()
    }
  }
  assert_true(construction >= 0)
  assert_true(field >= 0)
  match planned.expressions[field].kind {
    PlannedFieldGet(field_id, _, _) =>
      assert_eq(field_id, collected.fields[0].id)
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
    PlannedModuleValueGet(declaration, _) =>
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
      CompileTimeQueryDiagnostic(_, _, _) => abort("unexpected compile-time query diagnostic")
    }
  }
  assert_eq(unsupported, 1)
}
