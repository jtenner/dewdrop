///|
fn assert_expression_nominal(
  inferred : InferredModuleBodies,
  resolved : ResolvedModuleTypes,
  type_ : BodyTypeId,
  declaration : DeclId,
) -> Unit {
  let mut current = type_
  while true {
    match inferred.type_term(current) {
      BodyAppliedType(base, _) => current = base
      BodyResolvedType(resolved_type) =>
        match resolved.types[resolved_type] {
          NominalType(actual) => {
            if actual != declaration {
              abort("unexpected nominal declaration")
            }
            return
          }
          AppliedType(base, _) =>
            match resolved.types[base] {
              NominalType(actual) => {
                if actual != declaration {
                  abort("unexpected applied nominal declaration")
                }
                return
              }
              _ => abort("expected nominal base")
            }
          _ => abort("expected nominal type")
        }
      _ => abort("expected frozen nominal type")
    }
  }
}

///|
fn selected_expression_of_kind(
  collected : CollectedModule,
  inferred : InferredModuleBodies,
  construct : Bool,
) -> (ExprId, InferredExpressionSelection) {
  for index, expression in collected.expressions {
    match expression {
      HirConstructExpr(_, _, _) if construct =>
        return (index, inferred.expression_selections[index])
      HirObjectExpr(_, _) if !construct =>
        return (index, inferred.expression_selections[index])
      _ => ()
    }
  }
  abort("expected selected expression")
}

///|
test "generic struct construction selects fields and type arguments" {
  let (collected, resolved, _, inferred) = call_test_module(
    401UL, b"struct Pair<t> {\n  first: t\n  second: Bool\n}\nfn make(value: I32) -> Pair<I32> {\n  Pair::{\n    first: value\n    second: true\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let (_, selection) = selected_expression_of_kind(collected, inferred, true)
  match selection {
    StructConstructionSelection(declaration, arguments) => {
      assert_eq(declaration, collected.declarations[0].id)
      assert_eq(arguments.length, 1)
      assert_call_primitive(
        inferred,
        resolved,
        inferred.expression_type_arguments[arguments.start],
        I32Type,
      )
    }
    _ => fail("expected generic struct construction")
  }
  assert_eq(
    inferred.object_field_targets[0],
    SelectedObjectFieldTarget(collected.fields[0].id),
  )
  assert_eq(
    inferred.object_field_targets[1],
    SelectedObjectFieldTarget(collected.fields[1].id),
  )
}

///|
test "untyped object expressions select from their expected struct" {
  let (collected, resolved, _, inferred) = call_test_module(
    402UL, b"struct Pair<t> {\n  first: t\n  second: Bool\n}\nfn make(value: I32) -> Pair<I32> {\n  {\n    first: value\n    second: true\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let (expression, selection) = selected_expression_of_kind(
    collected, inferred, false,
  )
  match selection {
    StructConstructionSelection(declaration, arguments) => {
      assert_eq(declaration, collected.declarations[0].id)
      assert_eq(arguments.length, 1)
    }
    _ => fail("expected object struct selection")
  }
  assert_expression_nominal(
    inferred,
    resolved,
    inferred.expression_types[expression],
    collected.declarations[0].id,
  )
}

///|
test "generic field access substitutes the base type arguments" {
  let (collected, resolved, _, inferred) = call_test_module(
    403UL, b"struct Pair<t> {\n  first: t\n}\nfn read(pair: Pair<I32>) -> I32 {\n  pair.first\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let mut field_expression = -1
  for index, expression in collected.expressions {
    match expression {
      HirFieldExpr(_, _, _) => field_expression = index
      _ => ()
    }
  }
  match inferred.expression_selections[field_expression] {
    FieldAccessSelection(field) => assert_eq(field, collected.fields[0].id)
    _ => fail("expected selected field")
  }
  assert_call_primitive(
    inferred,
    resolved,
    inferred.expression_types[field_expression],
    I32Type,
  )
}

///|
test "generic aggregate function fields remain callable after instantiation" {
  let (collected, resolved, names, inferred) = call_test_module(
    414UL, b"struct CallbackBox<t> {\n  callback: fn(t) -> t\n}\nfn increment(value: I32) -> I32 {\n  value + 1\n}\nfn identity<t>(value: CallbackBox<t>, first: Bool) -> CallbackBox<t> {\n  if first {\n    value\n  } else {\n    value\n  }\n}\nfn use() -> I32 {\n  let box = identity(CallbackBox::{\n    callback: increment\n  }, true)\n  let callback = box.callback\n  callback(41)\n}\n",
  )
  let mut field_expression = -1
  for index, expression in collected.expressions {
    match expression {
      HirFieldExpr(_, _, _) => field_expression = index
      _ => ()
    }
  }
  match inferred.type_term(inferred.expression_types[field_expression]) {
    BodyFunctionType(_, _) => ()
    BodyResolvedType(type_) =>
      match resolved.types[type_] {
        FunctionType(_, _) => ()
        _ => fail("expected resolved function field type")
      }
    _ => fail("expected function field type")
  }
  let mut callback_target = -1
  for expression in collected.expressions {
    match expression {
      HirCallExpr(target, _, _) =>
        match names.expression_references[target] {
          LocalNameReference(_) => callback_target = target
          _ => ()
        }
      _ => ()
    }
  }
  assert_true(callback_target >= 0)
  match inferred.type_term(inferred.expression_types[callback_target]) {
    BodyFunctionType(_, _) => ()
    BodyResolvedType(type_) =>
      match resolved.types[type_] {
        FunctionType(_, _) => ()
        _ => fail("expected resolved callback local type")
      }
    _ => fail("expected callback local function type")
  }
  assert_eq(inferred.diagnostics.length(), 0)
  let mut function_call = -1
  for index, selection in inferred.call_targets {
    match selection {
      SelectedFunctionValueCallTarget(_) => function_call = index
      _ => ()
    }
  }
  assert_true(function_call >= 0)
  assert_call_primitive(
    inferred,
    resolved,
    inferred.expression_types[function_call],
    I32Type,
  )
}

///|
test "generic struct enum variant construction retains its variant" {
  let (collected, resolved, _, inferred) = call_test_module(
    404UL, b"enum Message<t> {\n  Empty\n  Data {\n    value: t\n    code: I32\n  }\n}\nfn make(value: String) -> Message<String> {\n  Message::Data::{\n    value: value\n    code: 1\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let (_, selection) = selected_expression_of_kind(collected, inferred, true)
  match selection {
    VariantConstructionSelection(variant, arguments) => {
      assert_eq(variant, collected.variants[1].id)
      assert_eq(arguments.length, 1)
      assert_call_primitive(
        inferred,
        resolved,
        inferred.expression_type_arguments[arguments.start],
        StringType,
      )
    }
    _ => fail("expected struct variant construction")
  }
}

///|
test "qualified unit variants are inferred as enum values" {
  let (collected, resolved, _, inferred) = call_test_module(
    405UL, b"enum Maybe<t> {\n  None\n  Some(t)\n}\nfn none() -> Maybe<I32> {\n  Maybe::None\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let mut qualified = -1
  for index, expression in collected.expressions {
    match expression {
      HirQualifiedExpr(_, _, _) => qualified = index
      _ => ()
    }
  }
  match inferred.expression_selections[qualified] {
    UnitVariantValueSelection(variant, arguments) => {
      assert_eq(variant, collected.variants[0].id)
      assert_eq(arguments.length, 1)
    }
    _ => fail("expected unit variant value")
  }
  assert_expression_nominal(
    inferred,
    resolved,
    inferred.expression_types[qualified],
    collected.declarations[0].id,
  )
}

///|
test "tuple and bare enum constructors infer generic variant values" {
  let (collected, resolved, _, inferred) = call_test_module(
    408UL, b"enum Maybe<t> {\n  None\n  Some(t)\n}\nfn some(value: I32) -> Maybe<I32> {\n  Maybe::Some(value)\n}\nfn bare(value: I32) -> Maybe<I32> {\n  Some(value)\n}\nfn none() -> Maybe<I32> {\n  None\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let mut selected_some = 0
  let mut selected_none = 0
  for index, selection in inferred.expression_selections {
    match selection {
      VariantConstructionSelection(variant, arguments) => {
        selected_some += 1
        assert_eq(variant, collected.variants[1].id)
        assert_eq(arguments.length, 1)
        assert_call_primitive(
          inferred,
          resolved,
          inferred.expression_type_arguments[arguments.start],
          I32Type,
        )
        assert_eq(inferred.call_targets[index], NoInferredCallTarget)
      }
      UnitVariantValueSelection(variant, arguments) => {
        selected_none += 1
        assert_eq(variant, collected.variants[0].id)
        assert_eq(arguments.length, 1)
      }
      _ => ()
    }
  }
  assert_eq(selected_some, 2)
  assert_eq(selected_none, 1)
}

///|
test "object arguments participate in overload nominal-shape selection" {
  let (collected, _, _, inferred) = call_test_module(
    409UL, b"struct Point {\n  x: I32\n}\nbuiltin choose(value: I32) -> Bool = \"number\"\nbuiltin choose(value: Point) -> Bool = \"point\"\nfn use() -> Bool {\n  choose({\n    x: 1\n  })\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[0])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.declarations[2].id)
    _ => fail("expected Point overload")
  }
  let (_, selection) = selected_expression_of_kind(collected, inferred, false)
  match selection {
    StructConstructionSelection(declaration, _) =>
      assert_eq(declaration, collected.declarations[0].id)
    _ => fail("expected object argument struct selection")
  }
}

///|
test "nested objects and chained fields resolve through the member worklist" {
  let (_, resolved, _, inferred) = call_test_module(
    410UL, b"struct Inner {\n  x: I32\n}\nstruct Outer {\n  inner: Inner\n}\nfn make() -> Outer {\n  {\n    inner: {\n      x: 1\n    }\n  }\n}\nfn read(value: Outer) -> I32 {\n  value.inner.x\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let mut object_count = 0
  let mut field_count = 0
  for index, selection in inferred.expression_selections {
    match selection {
      StructConstructionSelection(_, _) => object_count += 1
      FieldAccessSelection(_) => {
        field_count += 1
        if field_count == 2 {
          assert_call_primitive(
            inferred,
            resolved,
            inferred.expression_types[index],
            I32Type,
          )
        }
      }
      _ => ()
    }
  }
  assert_eq(object_count, 2)
  assert_eq(field_count, 2)
}

///|
test "construction validates unknown missing duplicate fields and payload kind" {
  let (_, _, _, inferred) = call_test_module(
    406UL, b"struct Pair {\n  first: I32\n  second: Bool\n}\nenum Flag {\n  On\n}\nfn bad() -> Pair {\n  Pair::{\n    first: 1\n    first: 2\n    extra: 3\n  }\n}\nfn bad_variant() -> Flag {\n  Flag::On::{}\n}\n",
  )
  let mut duplicate = 0
  let mut unknown = 0
  let mut missing = 0
  let mut kind = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      DuplicateConstructionField(_, _, _) => duplicate += 1
      UnknownConstructionField(_, _, _) => unknown += 1
      MissingConstructionField(_, _, _) => missing += 1
      ConstructionPayloadKindMismatch(_, _, _) => kind += 1
      _ => ()
    }
  }
  assert_eq(duplicate, 1)
  assert_eq(unknown, 1)
  assert_eq(missing, 1)
  assert_eq(kind, 1)
}

///|
test "tuple construction arity and unconstrained generic arguments diagnose" {
  let (_, _, _, inferred) = call_test_module(
    411UL, b"enum Maybe<t> {\n  Some(t)\n}\nstruct Empty<t> {}\nfn bad() -> Maybe<I32> {\n  Maybe::Some()\n}\nlet empty = Empty::{}\n",
  )
  let mut arity = 0
  let mut unresolved = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      ConstructionPayloadArityMismatch(_, _, expected, actual, _) => {
        arity += 1
        assert_eq(expected, 1)
        assert_eq(actual, 0)
      }
      UnresolvedExpressionTypeArgument(_, _, _) => unresolved += 1
      _ => ()
    }
  }
  assert_eq(arity, 1)
  assert_eq(unresolved, 1)
}

///|
test "unknown method calls do not cascade into field diagnostics" {
  let (_, _, _, inferred) = call_test_module(
    412UL, b"struct Value {\n  item: I32\n}\nfn use(value: Value) -> I32 {\n  value.method()\n}\n",
  )
  let mut method_error = 0
  let mut field_error = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      NoMatchingMethod(_, _, _) => method_error += 1
      UnknownFieldForType(_, _, _, _) | FieldAccessRequiresNominal(_, _) =>
        field_error += 1
      _ => ()
    }
  }
  assert_eq(method_error, 1)
  assert_eq(field_error, 0)
}

///|
test "object and field inference merges deterministically by body order" {
  let collected = collect_bytes(
    413UL, b"struct Pair {\n  first: I32\n}\nfn make() -> Pair {\n  Pair::{\n    first: 1\n  }\n}\nfn read(value: Pair) -> I32 {\n  value.first\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let forward = infer_module_bodies_in_order(collected, resolved, names, [0, 1])
  let reverse = infer_module_bodies_in_order(collected, resolved, names, [1, 0])
  assert_eq(forward, reverse)
}

///|
test "field access and object inference diagnose missing nominal context" {
  let (_, _, _, inferred) = call_test_module(
    407UL, b"fn object() -> I32 {\n  {\n    value: 1\n  }\n}\nfn field(value: I32) -> I32 {\n  value.missing\n}\n",
  )
  let mut object_error = 0
  let mut field_error = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      ObjectTypeRequired(_, _) => object_error += 1
      FieldAccessRequiresNominal(_, _) => field_error += 1
      _ => ()
    }
  }
  assert_eq(object_error, 1)
  assert_eq(field_error, 1)
}
