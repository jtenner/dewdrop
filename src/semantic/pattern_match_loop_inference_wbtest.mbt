///|
fn body_expression_of_kind(
  collected : CollectedModule,
  body : HirBody,
  match_ : Bool,
) -> ExprId {
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match collected.expressions[expression] {
      HirMatchExpr(_, _, _) if match_ => return expression
      HirWhileExpr(_, _, _) if !match_ => return expression
      _ => ()
    }
  }
  -1
}

///|
test "match inference selects generic tuple and unit variants" {
  let (collected, resolved, names, inferred) = call_test_module(
    140UL, b"enum Maybe<t> {\n  None\n  Some(t)\n}\nfn unwrap(value: Maybe<I32>) -> I32 {\n  match value {\n    Some(item) if item > 0 => item\n    None => 0\n    _ => -1\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let body = collected.bodies[0]
  let match_expression = body_expression_of_kind(collected, body, true)
  assert_true(match_expression >= 0)
  assert_call_primitive(
    inferred,
    resolved,
    inferred.expression_types[match_expression],
    I32Type,
  )
  let local_info = names.body(body.id).unwrap().locals
  assert_eq(local_info.length, 2)
  assert_call_primitive(
    inferred,
    resolved,
    inferred.local_types[local_info.start + 1],
    I32Type,
  )
  let arms = match collected.expressions[match_expression] {
    HirMatchExpr(_, arms, _) => arms
    _ => fail("expected match")
  }
  let first_arm = collected.pattern_arms[collected.arm_children[arms.start]]
  let second_arm = collected.pattern_arms[collected.arm_children[arms.start + 1]]
  match inferred.pattern_constructors[first_arm.pattern] {
    VariantInferredPatternConstructor(variant, arguments) => {
      assert_eq(variant, collected.variants[1].id)
      assert_eq(arguments.length, 1)
      assert_call_primitive(
        inferred,
        resolved,
        inferred.pattern_type_arguments[arguments.start],
        I32Type,
      )
    }
    _ => fail("expected selected Some constructor")
  }
  match inferred.pattern_constructors[second_arm.pattern] {
    VariantInferredPatternConstructor(variant, arguments) => {
      assert_eq(variant, collected.variants[0].id)
      assert_eq(arguments.length, 1)
    }
    _ => fail("expected selected None constructor")
  }
}

///|
test "pattern inference substitutes struct variants and nominal structs" {
  let (collected, resolved, names, inferred) = call_test_module(
    141UL, b"enum Message<t> {\n  Named {\n    value: t\n    code: I32\n  }\n}\nstruct Pair<t> {\n  first: t\n  second: I32\n}\nfn from_message(message: Message<String>) -> String {\n  match message {\n    Named {\n      value\n      code\n    } => value\n  }\n}\nfn from_pair(pair: Pair<Bool>) -> Bool {\n  match pair {\n    Pair {\n      first\n      second\n    } => first\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let first_names = names.body(collected.bodies[0].id).unwrap().locals
  assert_call_primitive(
    inferred,
    resolved,
    inferred.local_types[first_names.start + 1],
    StringType,
  )
  assert_call_primitive(
    inferred,
    resolved,
    inferred.local_types[first_names.start + 2],
    I32Type,
  )
  let second_names = names.body(collected.bodies[1].id).unwrap().locals
  assert_call_primitive(
    inferred,
    resolved,
    inferred.local_types[second_names.start + 1],
    BoolType,
  )
  assert_call_primitive(
    inferred,
    resolved,
    inferred.local_types[second_names.start + 2],
    I32Type,
  )
  let first_match = body_expression_of_kind(
    collected,
    collected.bodies[0],
    true,
  )
  let first_arms = match collected.expressions[first_match] {
    HirMatchExpr(_, arms, _) => arms
    _ => fail("expected first match")
  }
  let first_pattern = collected.pattern_arms[collected.arm_children[first_arms.start]].pattern
  match inferred.pattern_constructors[first_pattern] {
    VariantInferredPatternConstructor(variant, _) =>
      assert_eq(variant, collected.variants[0].id)
    _ => fail("expected struct variant selection")
  }
  let second_match = body_expression_of_kind(
    collected,
    collected.bodies[1],
    true,
  )
  let second_arms = match collected.expressions[second_match] {
    HirMatchExpr(_, arms, _) => arms
    _ => fail("expected second match")
  }
  let second_pattern = collected.pattern_arms[collected.arm_children[second_arms.start]].pattern
  match inferred.pattern_constructors[second_pattern] {
    StructInferredPatternConstructor(declaration, _) =>
      assert_eq(declaration, collected.declarations[1].id)
    _ => fail("expected nominal struct selection")
  }
}

///|
test "alternative patterns unify corresponding binding types" {
  let (collected, resolved, names, inferred) = call_test_module(
    142UL, b"enum State {\n  A(I32)\n  B(I32)\n}\nfn read(state: State) -> I32 {\n  match state {\n    A(value), B(value) => value\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let locals = names.body(collected.bodies[0].id).unwrap().locals
  assert_eq(locals.length, 2)
  assert_call_primitive(
    inferred,
    resolved,
    inferred.local_types[locals.start + 1],
    I32Type,
  )
}

///|
test "match inference checks guards literals and arm result compatibility" {
  let (_, _, _, inferred) = call_test_module(
    143UL, b"fn invalid(value: Bool) -> I32 {\n  match value {\n    true if 1 => 1\n    _ => false\n  }\n}\n",
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
test "pattern inference diagnoses ambiguity payloads and fields" {
  let (_, _, _, inferred) = call_test_module(
    144UL, b"enum First {\n  Same(I32)\n}\nenum Second {\n  Same(I32)\n}\nenum Record {\n  Named {\n    value: I32\n    code: Bool\n  }\n  Unit\n}\nfn ambiguous<t>(value: t) -> I32 {\n  match value {\n    Same(item) => item\n  }\n}\nfn invalid(record: Record) -> I32 {\n  match record {\n    Unit(value) => value\n    Named {\n      missing\n    } => 0\n  }\n}\n",
  )
  let mut ambiguous = 0
  let mut kind = 0
  let mut unknown_field = 0
  let mut missing_field = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      AmbiguousPatternVariant(_, _, _, _, count, _) => {
        ambiguous += 1
        assert_eq(count, 2)
      }
      PatternPayloadKindMismatch(_, _, _) => kind += 1
      UnknownPatternField(_, _, _) => unknown_field += 1
      MissingPatternField(_, _, _) => missing_field += 1
      _ => ()
    }
  }
  assert_eq(ambiguous, 1)
  assert_eq(kind, 1)
  assert_eq(unknown_field, 1)
  assert_eq(missing_field, 2)
}

///|
test "qualified variants and payload arity use the expected enum" {
  let (collected, _, _, inferred) = call_test_module(
    151UL, b"enum Maybe {\n  None\n  Some(I32, Bool)\n}\nfn read(value: Maybe) -> I32 {\n  match value {\n    Maybe::Some(item) => item\n    Maybe::None => 0\n  }\n}\n",
  )
  let mut arity = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      PatternPayloadArityMismatch(_, expected, actual, _) => {
        arity += 1
        assert_eq(expected, 2)
        assert_eq(actual, 1)
      }
      _ => ()
    }
  }
  assert_eq(arity, 1)
  let match_expression = body_expression_of_kind(
    collected,
    collected.bodies[0],
    true,
  )
  let arms = match collected.expressions[match_expression] {
    HirMatchExpr(_, arms, _) => arms
    _ => fail("expected qualified match")
  }
  let first = collected.pattern_arms[collected.arm_children[arms.start]].pattern
  let second = collected.pattern_arms[collected.arm_children[arms.start + 1]].pattern
  match inferred.pattern_constructors[first] {
    VariantInferredPatternConstructor(variant, _) =>
      assert_eq(variant, collected.variants[1].id)
    _ => fail("expected qualified Some")
  }
  match inferred.pattern_constructors[second] {
    VariantInferredPatternConstructor(variant, _) =>
      assert_eq(variant, collected.variants[0].id)
    _ => fail("expected qualified None")
  }
}

///|
test "alternative pattern payloads must give shared bindings compatible types" {
  let (_, _, _, inferred) = call_test_module(
    152UL, b"enum State {\n  Number(I32)\n  Flag(Bool)\n}\nfn invalid(state: State) -> I32 {\n  match state {\n    Number(value), Flag(value) => 0\n  }\n}\n",
  )
  let mut mismatch = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      BodyConstraintDiagnostic(LocalTypeMismatch(_, _, origin)) =>
        if origin.kind == PatternTypeConstraint {
          mismatch += 1
        }
      _ => ()
    }
  }
  assert_eq(mismatch, 1)
}

///|
test "tuple rest and struct rest patterns accept partial payloads" {
  let (_, _, _, inferred) = call_test_module(
    145UL, b"enum Data {\n  Tuple(I32, Bool, String)\n  Named {\n    first: I32\n    second: Bool\n  }\n}\nfn tuple(data: Data) -> I32 {\n  match data {\n    Tuple(first, ..., last) => first\n    _ => 0\n  }\n}\nfn named(data: Data) -> I32 {\n  match data {\n    Named {\n      first\n      ...\n    } => first\n    _ => 0\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
}

///|
test "functional loop inference constrains state result guards and patterns" {
  let (collected, resolved, names, inferred) = call_test_module(
    146UL, b"enum Step<t> {\n  Next(t)\n  Done(t)\n}\nfn run(initial: Step<I32>) -> I32 {\n  while initial {\n    Next(value) if value > 0 => continue initial\n    Done(value) => break value\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let body = collected.bodies[0]
  let while_expression = body_expression_of_kind(collected, body, false)
  let control = names.expression_controls[while_expression]
  assert_true(control >= 0)
  let control_info = names.body(body.id).unwrap().controls
  let state_type = inferred.control_state_types[control_info.start + control]
  let result_type = inferred.control_result_types[control_info.start + control]
  match inferred.type_term(state_type) {
    BodyResolvedType(type_) =>
      match resolved.types[type_] {
        AppliedType(_, arguments) => assert_eq(arguments.length, 1)
        _ => fail("expected Step application state")
      }
    _ => fail("expected resolved loop state")
  }
  assert_call_primitive(inferred, resolved, result_type, I32Type)
  assert_call_primitive(
    inferred,
    resolved,
    inferred.expression_types[while_expression],
    I32Type,
  )
}

///|
test "functional loops diagnose transfer mismatches and fallthrough" {
  let (collected, resolved, _, inferred) = call_test_module(
    147UL, b"enum Step {\n  Next(I32)\n  Done(I32)\n}\nfn invalid(initial: Step) -> I32 {\n  while initial {\n    Next(value) => continue value\n    Done(value) => true\n  }\n}\n",
  )
  let mut mismatch = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      BodyConstraintDiagnostic(LocalTypeMismatch(_, _, _)) => mismatch += 1
      _ => ()
    }
  }
  let flows = analyze_module_flows(collected, resolved, inferred)
  let mut fallthrough = 0
  for diagnostic in flows.diagnostics {
    match diagnostic {
      FunctionalLoopArmFallsThrough(_, _) => fallthrough += 1
      _ => ()
    }
  }
  assert_true(mismatch >= 1)
  assert_eq(fallthrough, 1)
}

///|
test "continue-only functional loops infer Never results" {
  let (collected, resolved, _, inferred) = call_test_module(
    148UL, b"fn spin(initial: I32) -> I32 {\n  while initial {\n    _ => continue initial\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let while_expression = body_expression_of_kind(
    collected,
    collected.bodies[0],
    false,
  )
  assert_call_primitive(
    inferred,
    resolved,
    inferred.expression_types[while_expression],
    NeverType,
  )
}
