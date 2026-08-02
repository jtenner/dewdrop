///|
fn call_test_module(
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
fn assert_call_primitive(
  inferred : InferredModuleBodies,
  resolved : ResolvedModuleTypes,
  type_ : BodyTypeId,
  primitive : PrimitiveType,
) -> Unit {
  match inferred.type_term(type_) {
    BodyResolvedType(resolved_type) =>
      if resolved_type != resolved.primitive(primitive) {
        abort("unexpected inferred primitive call type")
      }
    _ => abort("expected inferred primitive call type")
  }
}

///|
fn body_calls(collected : CollectedModule, body : HirBody) -> Array[ExprId] {
  let calls : Array[ExprId] = []
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match collected.expressions[expression] {
      HirCallExpr(_, _, _) => calls.push(expression)
      _ => ()
    }
  }
  calls
}

///|
test "generic direct calls instantiate fresh type variables per call" {
  let (collected, resolved, names, inferred) = call_test_module(
    100UL, b"fn identity<t>(value: t) -> t {\n  value\n}\nfn use() -> Bool {\n  let number = identity(1)\n  let flag = identity(true)\n  flag\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let body = collected.bodies[1]
  let calls = body_calls(collected, body)
  assert_eq(calls.length(), 2)
  let expected = [I32Type, BoolType]
  for index in 0..<calls.length() {
    let call = calls[index]
    assert_call_primitive(
      inferred,
      resolved,
      inferred.expression_types[call],
      expected[index],
    )
    match inferred.call_targets[call] {
      SelectedInferredCallTarget(declaration, arguments) => {
        assert_eq(declaration, collected.declarations[0].id)
        assert_eq(arguments.length, 1)
        assert_call_primitive(
          inferred,
          resolved,
          inferred.call_type_arguments[arguments.start],
          expected[index],
        )
      }
      _ => fail("expected selected generic direct call")
    }
  }
  let locals = names.body(body.id).unwrap().locals
  assert_call_primitive(
    inferred,
    resolved,
    inferred.local_types[locals.start],
    I32Type,
  )
  assert_call_primitive(
    inferred,
    resolved,
    inferred.local_types[locals.start + 1],
    BoolType,
  )
}

///|
test "generic call instantiation substitutes through applied signatures" {
  let (collected, resolved, _, inferred) = call_test_module(
    101UL, b"struct Box<t> {\n  value: t\n}\nbuiltin unwrap<t>(value: Box<t>) -> t = \"unwrap\"\nfn use(value: Box<I32>) -> I32 {\n  unwrap(value)\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let body = collected.bodies[0]
  let calls = body_calls(collected, body)
  assert_eq(calls.length(), 1)
  assert_call_primitive(
    inferred,
    resolved,
    inferred.expression_types[calls[0]],
    I32Type,
  )
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, collected.declarations[1].id)
      assert_eq(arguments.length, 1)
      assert_call_primitive(
        inferred,
        resolved,
        inferred.call_type_arguments[arguments.start],
        I32Type,
      )
    }
    _ => fail("expected selected applied generic call")
  }
}

///|
test "builtin overload selection uses argument and expected result types" {
  let (collected, resolved, _, inferred) = call_test_module(
    102UL, b"builtin convert(value: I32) -> I64 = \"i32_to_i64\"\nbuiltin convert(value: F32) -> F64 = \"f32_to_f64\"\nbuiltin make() -> I32 = \"make_i32\"\nbuiltin make() -> F32 = \"make_f32\"\nfn use_convert() -> I64 {\n  convert(1)\n}\nfn use_make() -> F32 {\n  make()\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let convert_calls = body_calls(collected, collected.bodies[0])
  let make_calls = body_calls(collected, collected.bodies[1])
  assert_eq(convert_calls.length(), 1)
  assert_eq(make_calls.length(), 1)
  match inferred.call_targets[convert_calls[0]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.declarations[0].id)
    _ => fail("expected I32 builtin overload")
  }
  match inferred.call_targets[make_calls[0]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.declarations[3].id)
    _ => fail("expected expected-type-selected builtin overload")
  }
  assert_call_primitive(
    inferred,
    resolved,
    inferred.expression_types[convert_calls[0]],
    I64Type,
  )
  assert_call_primitive(
    inferred,
    resolved,
    inferred.expression_types[make_calls[0]],
    F32Type,
  )
}

///|
test "concrete builtin overload outranks a viable generic overload" {
  let (collected, _, _, inferred) = call_test_module(
    103UL, b"builtin choose<t>(value: t) -> t = \"generic_choose\"\nbuiltin choose(value: I32) -> I32 = \"i32_choose\"\nfn use() -> I32 {\n  choose(1)\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[0])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, collected.declarations[1].id)
      assert_eq(arguments.length, 0)
    }
    _ => fail("expected concrete overload to outrank generic overload")
  }
}

///|
test "overload selection falls back to a less specific generic candidate" {
  let (collected, resolved, _, inferred) = call_test_module(
    110UL, b"builtin choose(value: I32) -> I32 = \"choose_i32\"\nbuiltin choose<t>(value: t) -> t = \"choose_generic\"\nfn use() -> Bool {\n  choose(true)\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[0])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, collected.declarations[1].id)
      assert_eq(arguments.length, 1)
      assert_call_primitive(
        inferred,
        resolved,
        inferred.call_type_arguments[arguments.start],
        BoolType,
      )
    }
    _ => fail("expected generic overload fallback")
  }
}

///|
test "poisoned overload arguments suppress dependent ambiguity" {
  let (collected, _, _, inferred) = call_test_module(
    111UL, b"builtin choose(value: I32) -> I32 = \"choose_i32\"\nbuiltin choose(value: Bool) -> I32 = \"choose_bool\"\nfn use() -> I32 {\n  choose({})\n}\n",
  )
  let mut object_error_count = 0
  let mut call_diagnostic_count = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      ObjectTypeRequired(_, _) => object_error_count += 1
      NoMatchingCallOverload(_, _, _)
      | AmbiguousCallOverload(_, _, _, _, _, _) => call_diagnostic_count += 1
      _ => ()
    }
  }
  assert_eq(object_error_count, 1)
  assert_eq(call_diagnostic_count, 0)
  let calls = body_calls(collected, collected.bodies[0])
  assert_eq(inferred.call_targets[calls[0]], ErrorInferredCallTarget)
}

///|
test "overload worklist retries parents after nested calls resolve" {
  let (collected, resolved, _, inferred) = call_test_module(
    104UL, b"builtin convert(value: I32) -> I64 = \"i32_to_i64\"\nbuiltin convert(value: F32) -> F64 = \"f32_to_f64\"\nbuiltin wrap(value: I64) -> Bool = \"wrap_i64\"\nbuiltin wrap(value: F64) -> Bool = \"wrap_f64\"\nfn use() -> Bool {\n  wrap(convert(1))\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[0])
  assert_eq(calls.length(), 2)
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.declarations[0].id)
    _ => fail("expected inner I32 conversion")
  }
  match inferred.call_targets[calls[1]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.declarations[2].id)
    _ => fail("expected retried outer I64 wrapper")
  }
  assert_call_primitive(
    inferred,
    resolved,
    inferred.expression_types[calls[1]],
    BoolType,
  )
}

///|
test "overload failures and ambiguities rollback speculative diagnostics" {
  let (collected, _, _, inferred) = call_test_module(
    105UL, b"builtin convert(value: I32) -> I64 = \"i32_to_i64\"\nbuiltin convert(value: F32) -> F64 = \"f32_to_f64\"\nbuiltin pick(value: I32) -> I32 = \"pick_first\"\nbuiltin pick(value: I32) -> I32 = \"pick_second\"\nfn no_match() -> I64 {\n  convert(true)\n}\nfn ambiguous() -> I32 {\n  pick(1)\n}\n",
  )
  let mut no_match_count = 0
  let mut ambiguous_count = 0
  let mut mismatch_count = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      NoMatchingCallOverload(_, _, _) => no_match_count += 1
      AmbiguousCallOverload(_, _, first, second, count, _) => {
        ambiguous_count += 1
        assert_eq(first, collected.declarations[2].id)
        assert_eq(second, collected.declarations[3].id)
        assert_eq(count, 2)
      }
      BodyConstraintDiagnostic(LocalTypeMismatch(_, _, _)) =>
        mismatch_count += 1
      _ => ()
    }
  }
  assert_eq(no_match_count, 1)
  assert_eq(ambiguous_count, 1)
  assert_eq(mismatch_count, 0)
  for body in collected.bodies {
    let calls = body_calls(collected, body)
    assert_eq(calls.length(), 1)
    assert_eq(inferred.call_targets[calls[0]], ErrorInferredCallTarget)
    assert_eq(inferred.expression_types[calls[0]], 0)
    assert_eq(inferred.body(body.id).unwrap().root_type, 0)
  }
}

///|
test "direct calls diagnose argument count and invalid local targets" {
  let (collected, _, _, inferred) = call_test_module(
    106UL, b"fn one(value: I32) -> I32 {\n  value\n}\nfn wrong_count() -> I32 {\n  one()\n}\nfn invalid(value: I32) -> I32 {\n  value()\n}\n",
  )
  let mut arity_count = 0
  let mut invalid_count = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      CallArgumentCountMismatch(_, declaration, expected, actual, _) => {
        arity_count += 1
        assert_eq(declaration, collected.declarations[0].id)
        assert_eq(expected, 1)
        assert_eq(actual, 0)
      }
      InvalidCallTarget(_, _) => invalid_count += 1
      _ => ()
    }
  }
  assert_eq(arity_count, 1)
  assert_eq(invalid_count, 1)
}

///|
test "uninferred generic call arguments remain visible diagnostics" {
  let (collected, resolved, _, inferred) = call_test_module(
    107UL, b"fn phantom<t>() -> I32 {\n  1\n}\nfn use() -> I32 {\n  phantom()\n}\n",
  )
  let mut unresolved_count = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      UnresolvedCallTypeArgument(_, index, _) => {
        unresolved_count += 1
        assert_eq(index, 0)
      }
      _ => ()
    }
  }
  assert_eq(unresolved_count, 1)
  let calls = body_calls(collected, collected.bodies[1])
  assert_call_primitive(
    inferred,
    resolved,
    inferred.expression_types[calls[0]],
    I32Type,
  )
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(_, arguments) => {
      assert_eq(arguments.length, 1)
      match inferred.type_term(inferred.call_type_arguments[arguments.start]) {
        BodyVariableType(_) => ()
        _ => fail("expected unresolved retained generic argument")
      }
    }
    _ => fail("expected selected phantom call")
  }
}
