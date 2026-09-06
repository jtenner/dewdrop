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
test "structural overload specificity selects strict nested containment" {
  let (collected, resolved, _, inferred) = call_test_module(
    117UL, b"struct Box<t> {\n  value: t\n}\nbuiltin pick<t>(value: Box<t>) -> I32 = \"broad\"\nbuiltin pick<t>(value: Box<Box<t>>) -> I32 = \"nested\"\nfn use(value: Box<Box<I32>>) -> I32 {\n  pick(value)\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[0])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, collected.declarations[2].id)
      assert_eq(arguments.length, 1)
      assert_call_primitive(
        inferred,
        resolved,
        inferred.call_type_arguments[arguments.start],
        I32Type,
      )
    }
    _ => fail("expected structurally narrower nested overload")
  }
}

///|
test "structural overload specificity is independent of declaration order" {
  let (collected, _, _, inferred) = call_test_module(
    118UL, b"struct Box<t> {\n  value: t\n}\nbuiltin pick<t>(value: Box<Box<t>>) -> I32 = \"nested\"\nbuiltin pick<t>(value: Box<t>) -> I32 = \"broad\"\nfn use(value: Box<Box<I32>>) -> I32 {\n  pick(value)\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[0])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.declarations[1].id)
    _ => fail("expected source-order-independent structural winner")
  }
}

///|
test "structural overload specificity includes expected result types" {
  let (collected, _, _, inferred) = call_test_module(
    121UL, b"struct Box<t> {\n  value: t\n}\nbuiltin make<t>() -> Box<t> = \"broad\"\nbuiltin make<t>() -> Box<Box<t>> = \"nested\"\nfn use() -> Box<Box<I32>> {\n  make()\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[0])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.declarations[2].id)
    _ => fail("expected result-structurally narrower overload")
  }
}

///|
test "equivalent and overlapping-incomparable generic overloads stay ambiguous" {
  let (equivalent, _, _, equivalent_inferred) = call_test_module(
    122UL, b"struct Box<t> {}\nbuiltin pick<a>(value: Box<a>) -> I32 = \"first\"\nbuiltin pick<b>(value: Box<b>) -> I32 = \"second\"\nfn use(value: Box<I32>) -> I32 {\n  pick(value)\n}\n",
  )
  let equivalent_calls = body_calls(equivalent, equivalent.bodies[0])
  let mut equivalent_ambiguity = 0
  for diagnostic in equivalent_inferred.diagnostics {
    match diagnostic {
      AmbiguousCallOverload(_, expression, _, _, 2, _) if expression ==
        equivalent_calls[0] => equivalent_ambiguity += 1
      _ => ()
    }
  }
  assert_eq(equivalent_ambiguity, 1)

  let (incomparable, _, _, incomparable_inferred) = call_test_module(
    123UL, b"struct Pair<a, b> {}\nbuiltin pick<a>(value: Pair<a, I32>) -> I32 = \"left\"\nbuiltin pick<b>(value: Pair<Bool, b>) -> I32 = \"right\"\nfn use(value: Pair<Bool, I32>) -> I32 {\n  pick(value)\n}\n",
  )
  let incomparable_calls = body_calls(incomparable, incomparable.bodies[0])
  let mut incomparable_ambiguity = 0
  for diagnostic in incomparable_inferred.diagnostics {
    match diagnostic {
      AmbiguousCallOverload(_, expression, _, _, 2, _) if expression ==
        incomparable_calls[0] => incomparable_ambiguity += 1
      _ => ()
    }
  }
  assert_eq(incomparable_ambiguity, 1)
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
test "explicit call-site type arguments resolve otherwise uninferred generics" {
  let (collected, resolved, _, inferred) = call_test_module(
    112UL, b"fn phantom<t>() -> I32 {\n  1\n}\nfn use() -> I32 {\n  phantom::<I32>()\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[1])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, collected.declarations[0].id)
      assert_eq(arguments.length, 1)
      assert_call_primitive(
        inferred,
        resolved,
        inferred.call_type_arguments[arguments.start],
        I32Type,
      )
    }
    _ => fail("expected explicitly specialized phantom call")
  }
}

///|
test "explicit call-site type arguments constrain ordinary inference" {
  let (_, _, _, inferred) = call_test_module(
    113UL, b"fn identity<t>(value: t) -> t {\n  value\n}\nfn use() -> Bool {\n  identity::<Bool>(1)\n}\n",
  )
  let mut mismatches = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      BodyConstraintDiagnostic(LocalTypeMismatch(_, _, _)) => mismatches += 1
      _ => ()
    }
  }
  assert_eq(mismatches, 1)
}

///|
test "explicit call-site type arguments diagnose exact arity" {
  let (collected, _, _, inferred) = call_test_module(
    114UL, b"fn pair<a, b>(left: a, right: b) -> a {\n  left\n}\nfn use() -> I32 {\n  pair::<I32>(1, true)\n}\n",
  )
  let mut arity = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      CallTypeArgumentCountMismatch(_, declaration, expected, actual, _) => {
        arity += 1
        assert_eq(declaration, collected.declarations[0].id)
        assert_eq(expected, 2)
        assert_eq(actual, 1)
      }
      _ => ()
    }
  }
  assert_eq(arity, 1)
}

///|
test "explicit type arguments select matching overload arity" {
  let (collected, resolved, _, inferred) = call_test_module(
    115UL, b"builtin choose<t>(value: t) -> t = \"one\"\nbuiltin choose<a, b>(value: b) -> b = \"two\"\nfn use() -> Bool {\n  choose::<I32, Bool>(true)\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[0])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, collected.declarations[1].id)
      assert_eq(arguments.length, 2)
      assert_call_primitive(
        inferred,
        resolved,
        inferred.call_type_arguments[arguments.start],
        I32Type,
      )
      assert_call_primitive(
        inferred,
        resolved,
        inferred.call_type_arguments[arguments.start + 1],
        BoolType,
      )
    }
    _ => fail("expected explicit-arity-selected overload")
  }
}

///|
test "explicit type arguments may name enclosing rigid generics" {
  let (collected, resolved, _, inferred) = call_test_module(
    116UL, b"fn phantom<t>() -> I32 {\n  1\n}\nfn forward<u>() -> I32 {\n  phantom::<u>()\n}\nfn use() -> I32 {\n  forward::<Bool>()\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[1])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(_, arguments) => {
      assert_eq(arguments.length, 1)
      match inferred.type_term(inferred.call_type_arguments[arguments.start]) {
        BodyResolvedType(type_) =>
          match resolved.types[type_] {
            GenericParameterType(parameter) =>
              assert_eq(
                parameter,
                collected.generic_parameters[collected.generic_parameters_of(
                  collected.declarations[1].id,
                ).start].id,
              )
            _ => fail("expected enclosing generic type argument")
          }
        _ => fail("expected rigid explicit generic argument")
      }
    }
    _ => fail("expected explicit forwarding call")
  }
}

///|
test "Never-returning direct calls remain Never inside generic match joins" {
  let (collected, resolved, _, inferred) = call_test_module(
    119UL, b"enum Option<t> {\n  Some(t)\n  None\n}\nfn fail() -> Never {\n  fail()\n}\nfn unwrap<t>(value: Option<t>) -> t {\n  match value {\n    Option::Some(item) => item\n    Option::None => fail()\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let fail_declaration = collected.lookup_value("fail").unwrap()
  let mut callable_index = -1
  for index, callable in collected.callables {
    if callable.declaration == fail_declaration {
      callable_index = index
    }
  }
  assert_true(callable_index >= 0)
  assert_eq(
    resolved.types[resolved.callable_return_types[callable_index]],
    PrimitiveType(NeverType),
  )
  let calls = body_calls(collected, collected.bodies[1])
  assert_eq(calls.length(), 1)
  assert_call_primitive(
    inferred,
    resolved,
    inferred.expression_types[calls[0]],
    NeverType,
  )
  let root = match collected.bodies[1].root {
    BlockBodyRoot(block) =>
      match collected.block_items[collected.blocks[block].items.start] {
        HirExpressionItem(expression, _) => expression
        _ => fail("expected match body root")
      }
    _ => fail("expected block body")
  }
  match inferred.type_term(inferred.expression_types[root]) {
    BodyResolvedType(type_) =>
      match resolved.types[type_] {
        GenericParameterType(_) => ()
        _ => fail("expected generic match result")
      }
    _ => fail("expected rigid generic match result")
  }
}

///|
test "body inference never mutates the frozen resolved type interner" {
  let collected = collect_bytes(
    120UL, b"struct Box<t> {\n  value: t\n}\nfn identity<t>(value: Box<t>) -> Box<t> {\n  value\n}\nfn phantom<t>() -> I32 {\n  1\n}\nfn use(value: Box<I32>) -> Box<I32> {\n  phantom::<Bool>()\n  identity(value)\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let frozen_types = resolved.types.copy()
  let frozen_arguments = resolved.type_arguments.copy()
  let frozen_syntax = resolved.syntax_types.copy()
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)
  assert_eq(resolved.types, frozen_types)
  assert_eq(resolved.type_arguments, frozen_arguments)
  assert_eq(resolved.syntax_types, frozen_syntax)
  for term in inferred.types {
    match term {
      BodyVariableType(_)
      | BodyProductType(_)
      | BodyAppliedType(_, _)
      | BodyFunctionType(_, _)
      | BodyMemberTypeProjection(_, _, _) => ()
      BodyErrorType | BodyResolvedType(_) => ()
    }
  }
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
