///|
fn infer_test_module(
  module_id : UInt64,
  source : Bytes,
) -> (
  CollectedModule,
  ResolvedModuleTypes,
  ResolvedModuleNames,
  InferredModuleBodies,
) {
  let collected = collect_bytes(module_id, source)
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  (collected, resolved, names, inferred)
}

///|
fn assert_inferred_primitive(
  inferred : InferredModuleBodies,
  resolved : ResolvedModuleTypes,
  type_ : BodyTypeId,
  primitive : PrimitiveType,
) -> Unit {
  match inferred.type_term(type_) {
    BodyResolvedType(resolved_type) =>
      if resolved_type != resolved.primitive(primitive) {
        abort("unexpected inferred primitive type")
      }
    _ => abort("expected inferred primitive type")
  }
}

///|
test "basic inference types parameters lets binary expressions and tails" {
  let (collected, resolved, names, inferred) = infer_test_module(
    90UL, b"fn add(value: I32) -> I32 {\n  let doubled = value + value\n  doubled\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let body = collected.bodies[0]
  let info = inferred.body(body.id).unwrap()
  assert_inferred_primitive(inferred, resolved, info.root_type, I32Type)
  let name_info = names.body(body.id).unwrap()
  assert_eq(name_info.locals.length, 2)
  assert_inferred_primitive(
    inferred,
    resolved,
    inferred.local_types[name_info.locals.start],
    I32Type,
  )
  assert_inferred_primitive(
    inferred,
    resolved,
    inferred.local_types[name_info.locals.start + 1],
    I32Type,
  )
  let root = match body.root {
    BlockBodyRoot(block) => block
    _ => fail("expected function block")
  }
  let items = collected.blocks[root].items
  let addition = match collected.block_items[items.start] {
    HirLetItem(_, _, _, expression, _) => expression
    _ => fail("expected inferred let")
  }
  assert_inferred_primitive(
    inferred,
    resolved,
    inferred.expression_types[addition],
    I32Type,
  )
  assert_eq(info.types.length, 0)
}

///|
test "basic inference selects unambiguous named function references" {
  let (collected, resolved, _, inferred) = infer_test_module(
    96UL, b"fn increment(value: I32) -> I32 {\n  value + 1\n}\nfn select() -> fn(I32) -> I32 {\n  increment\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let mut selected = -1
  for expression, selection in inferred.expression_selections {
    match selection {
      FunctionReferenceSelection(declaration, _) => {
        assert_eq(declaration, collected.callables[0].declaration)
        selected = expression
      }
      _ => ()
    }
  }
  assert_true(selected >= 0)
  match inferred.type_term(inferred.expression_types[selected]) {
    BodyResolvedType(type_) =>
      assert_eq(type_, resolved.callable_function_types[0])
    _ => fail("expected resolved function-reference type")
  }
}

///|
test "basic inference specializes generic function references from expected types" {
  let (collected, _, _, inferred) = infer_test_module(
    97UL, b"fn identity<t>(value: t) -> t {\n  value\n}\nfn use_i32(callback: fn(I32) -> I32) -> I32 {\n  callback(42)\n}\nfn main() -> I32 {\n  use_i32(identity)\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let mut selected = false
  for selection in inferred.expression_selections {
    match selection {
      FunctionReferenceSelection(declaration, arguments) if declaration ==
        collected.callables[0].declaration => {
        assert_eq(arguments.length, 1)
        assert_true(inferred.expression_type_arguments[arguments.start] >= 0)
        selected = true
      }
      _ => ()
    }
  }
  assert_true(selected)
}

///|
test "basic inference selects overloaded function references from expected types" {
  let (collected, _, _, inferred) = infer_test_module(
    98UL, b"builtin choose(value: I32) -> I32 = \"choose_i32\"\nbuiltin choose(value: I64) -> I64 = \"choose_i64\"\nfn apply(callback: fn(I32) -> I32, value: I32) -> I32 {\n  callback(value)\n}\nfn use_argument() -> I32 {\n  apply(choose, 41)\n}\nfn use_return() -> fn(I64) -> I64 {\n  choose\n}\nfn use_assignment() -> I32 {\n  let mut callback = fn(value: I32) -> I32 {\n    value\n  }\n  callback = choose\n  callback(42)\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let mut i32_selections = 0
  let mut i64_selections = 0
  for selection in inferred.expression_selections {
    match selection {
      FunctionReferenceSelection(declaration, _) if declaration ==
        collected.callables[0].declaration => i32_selections += 1
      FunctionReferenceSelection(declaration, _) if declaration ==
        collected.callables[1].declaration => i64_selections += 1
      _ => ()
    }
  }
  assert_eq(i32_selections, 2)
  assert_eq(i64_selections, 1)
}

///|
test "basic inference diagnoses overloaded references without a usable expected type" {
  let (_, _, _, inferred) = infer_test_module(
    99UL, b"builtin choose(value: I32) -> I32 = \"choose_i32\"\nbuiltin choose(value: I64) -> I64 = \"choose_i64\"\nfn missing() -> Unit {\n  let callback = choose\n}\nfn mismatch() -> fn(Bool) -> Bool {\n  choose\n}\n",
  )
  let mut expected_required = 0
  let mut no_match = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      FunctionReferenceExpectedTypeRequired(_, _, _) => expected_required += 1
      NoMatchingFunctionReference(_, _, _) => no_match += 1
      _ => ()
    }
  }
  assert_eq(expected_required, 1)
  assert_eq(no_match, 1)
}

///|
test "basic inference type-checks calls through function-valued locals" {
  let (collected, resolved, _, inferred) = infer_test_module(
    97UL, b"fn apply(callback: fn(I32) -> I64, value: I32) -> I64 {\n  callback(value)\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let body = collected.bodies[0]
  let call = match body.root {
    BlockBodyRoot(block) => {
      let items = collected.blocks[block].items
      match collected.block_items[items.start] {
        HirExpressionItem(expression, _) => expression
        _ => fail("expected call tail")
      }
    }
    _ => fail("expected function block")
  }
  match inferred.call_targets[call] {
    SelectedFunctionValueCallTarget(target) =>
      match inferred.type_term(inferred.expression_types[target]) {
        BodyResolvedType(type_) =>
          match resolved.types[type_] {
            FunctionType(parameters, result) => {
              assert_eq(parameters.length, 1)
              assert_eq(result, resolved.primitive(I64Type))
            }
            _ => fail("expected function-valued call target")
          }
        _ => fail("expected resolved call-target type")
      }
    _ => fail("expected selected function-valued call")
  }
}

///|
test "basic inference preserves initializer-before-shadow local types" {
  let (collected, resolved, names, inferred) = infer_test_module(
    91UL, b"fn choose(value: I32) -> I32 {\n  let first = value\n  let mut value = first\n  value\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let info = names.body(collected.bodies[0].id).unwrap()
  assert_eq(info.locals.length, 3)
  for index in 0..<info.locals.length {
    assert_inferred_primitive(
      inferred,
      resolved,
      inferred.local_types[info.locals.start + index],
      I32Type,
    )
  }
}

///|
test "basic inference uses bidirectional if and no-else Unit rules" {
  let (collected, resolved, _, inferred) = infer_test_module(
    92UL, b"fn choose(condition: Bool) -> I32 {\n  if condition {\n    1\n  } else {\n    2\n  }\n}\nfn work(condition: Bool) -> Unit {\n  if condition {\n    1\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  assert_inferred_primitive(
    inferred,
    resolved,
    inferred.body(collected.bodies[0].id).unwrap().root_type,
    I32Type,
  )
  assert_inferred_primitive(
    inferred,
    resolved,
    inferred.body(collected.bodies[1].id).unwrap().root_type,
    UnitType,
  )
}

///|
test "basic inference checks explicit bare and tail returns" {
  let (_, _, _, inferred) = infer_test_module(
    93UL, b"fn explicit() -> I32 {\n  return 1\n}\nfn stop() -> Unit {\n  return\n}\nfn bad_return() -> I32 {\n  return true\n}\nfn bad_tail() -> I32 {\n  false\n}\n",
  )
  let mut mismatch_count = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      BodyConstraintDiagnostic(LocalTypeMismatch(_, _, _)) =>
        mismatch_count += 1
      _ => ()
    }
  }
  assert_eq(mismatch_count, 2)
}

///|
test "basic inference treats empty function blocks as Unit" {
  let (collected, resolved, _, inferred) = infer_test_module(
    94UL, b"fn empty() -> Unit {}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  assert_inferred_primitive(
    inferred,
    resolved,
    inferred.body(collected.bodies[0].id).unwrap().root_type,
    UnitType,
  )
}

///|
test "basic inference infers module-let literal body results" {
  let (collected, resolved, _, inferred) = infer_test_module(
    95UL, b"let signed = 1\nlet unsigned = 1U\nlet text = \"value\"\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  assert_inferred_primitive(
    inferred,
    resolved,
    inferred.body(collected.bodies[0].id).unwrap().root_type,
    I32Type,
  )
  assert_inferred_primitive(
    inferred,
    resolved,
    inferred.body(collected.bodies[1].id).unwrap().root_type,
    U32Type,
  )
  assert_inferred_primitive(
    inferred,
    resolved,
    inferred.body(collected.bodies[2].id).unwrap().root_type,
    StringType,
  )
}

///|
test "basic inference poisons one if mismatch without cascades" {
  let (collected, _, names, inferred) = infer_test_module(
    96UL, b"fn invalid(value: I32) -> I32 {\n  let selected = if true {\n    value\n  } else {\n    false\n  }\n  selected\n}\n",
  )
  let mut mismatch_count = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      BodyConstraintDiagnostic(LocalTypeMismatch(_, _, _)) =>
        mismatch_count += 1
      _ => ()
    }
  }
  assert_eq(mismatch_count, 1)
  let body = collected.bodies[0]
  let locals = names.body(body.id).unwrap().locals
  assert_eq(inferred.local_types[locals.start + 1], 0)
  assert_eq(inferred.body(body.id).unwrap().root_type, 0)
}

///|
test "call inference selects direct functions and records call targets" {
  let (collected, resolved, names, inferred) = infer_test_module(
    97UL, b"fn identity(value: I32) -> I32 {\n  value\n}\nfn use(value: I32) -> I32 {\n  let result = identity(value)\n  result\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let body = collected.bodies[1]
  let mut call = -1
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match collected.expressions[expression] {
      HirCallExpr(_, _, _) => call = expression
      _ => ()
    }
  }
  assert_true(call >= 0)
  match inferred.call_targets[call] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, collected.declarations[0].id)
      assert_eq(arguments.length, 0)
    }
    _ => fail("expected selected direct call")
  }
  assert_inferred_primitive(
    inferred,
    resolved,
    inferred.expression_types[call],
    I32Type,
  )
  let locals = names.body(body.id).unwrap().locals
  assert_inferred_primitive(
    inferred,
    resolved,
    inferred.local_types[locals.start + 1],
    I32Type,
  )
}

///|
test "basic inference result is independent of body job order" {
  let collected = collect_bytes(
    98UL, b"let first = 1\nfn second(value: I32) -> I32 {\n  let next = value + 1\n  next\n}\nfn third(flag: Bool) -> Unit {\n  if flag {\n    1\n  }\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let forward = infer_module_bodies_in_order(collected, resolved, names, [
    0, 1, 2,
  ])
  let reverse = infer_module_bodies_in_order(collected, resolved, names, [
    2, 1, 0,
  ])
  assert_eq(forward, reverse)
}

///|
fn deeply_negated_function(depth : Int) -> Bytes {
  let output = Buffer(size_hint=depth + 64)
  output.write_string_utf8("fn deep() -> Bool {\n  ")
  for _ in 0..<depth {
    output.write_byte(b'!')
  }
  output.write_string_utf8("true\n}\n")
  output.to_bytes()
}

///|
test "basic inference remains iterative through 1024 prefix expressions" {
  let (collected, resolved, _, inferred) = infer_test_module(
    99UL,
    deeply_negated_function(1024),
  )
  assert_eq(inferred.diagnostics.length(), 0)
  assert_inferred_primitive(
    inferred,
    resolved,
    inferred.body(collected.bodies[0].id).unwrap().root_type,
    BoolType,
  )
  for
    expression in collected.bodies[0].expressions.start..<(collected.bodies[0].expressions.start +
    collected.bodies[0].expressions.length) {
    assert_inferred_primitive(
      inferred,
      resolved,
      inferred.expression_types[expression],
      BoolType,
    )
  }
}
