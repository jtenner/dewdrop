///|
test "inherent instance methods select exact implementation declarations" {
  let (collected, resolved, _, inferred) = call_test_module(
    701UL, b"struct Item {\n  value: I32\n}\nimpl Item {\n  fn get(self) -> I32 {\n    self.value\n  }\n}\nfn use(item: Item) -> I32 {\n  item.get()\n}\n",
  )
  assert_eq(inferred.impl_index.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[1])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, collected.methods[0].id)
      assert_eq(arguments.length, 0)
    }
    _ => fail("expected inherent method target")
  }
  assert_call_primitive(
    inferred,
    resolved,
    inferred.expression_types[calls[0]],
    I32Type,
  )
}

///|
test "transparent aliases support qualified and instance inherent methods" {
  let (collected, resolved, _, inferred) = call_test_module(
    718UL, b"type Counter = U64\nimpl Counter {\n  fn empty() -> Counter {\n    0u64\n  }\n  fn add(self, value: U64) -> Counter {\n    self + value\n  }\n}\nfn use() -> Counter {\n  Counter::empty().add(2u64)\n}\n",
  )
  assert_eq(inferred.impl_index.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[2])
  assert_eq(calls.length(), 2)
  for call in calls {
    assert_call_primitive(
      inferred,
      resolved,
      inferred.expression_types[call],
      U64Type,
    )
  }
}

///|
test "method-local bounds are available inside inherent method bodies" {
  let (collected, resolved, _, inferred) = call_test_module(
    719UL, b"trait Mark {\n  fn mark(self) -> U64\n}\nimpl Mark for U64 {\n  fn mark(self) -> U64 {\n    self\n  }\n}\nstruct Hasher {}\nimpl Hasher {\n  fn mark_value<t: Mark>(value: t) -> U64 {\n    value.mark()\n  }\n}\nfn use() -> U64 {\n  Hasher::mark_value(7u64)\n}\n",
  )
  assert_eq(inferred.impl_index.diagnostics.length(), 0)
  let owner_generics = collected.generic_parameters_of(
    collected.impls[1].declaration,
  )
  let method_generics = collected.generic_parameters_of(collected.methods[2].id)
  assert_eq(owner_generics.length, 0)
  assert_eq(method_generics.length, 1)
  let generic = collected.generic_parameters[method_generics.start]
  assert_eq(generic.bounds.length, 1)
  let parameters = collected.parameters_of(collected.methods[2].id)
  assert_eq(parameters.length, 1)
  match resolved.types[resolved.parameter_types[parameters.start]] {
    GenericParameterType(parameter) => assert_eq(parameter, generic.id)
    _ => fail("expected method parameter to retain its generic identity")
  }
  let bound_type = resolved.generic_bound_types[generic.bounds.start]
  match resolved.types[bound_type] {
    TraitType(declaration) =>
      assert_eq(
        collected.name(
          collected.declarations[semantic_id_local(declaration)].name,
        ),
        "Mark",
      )
    AppliedType(base, _) =>
      match resolved.types[base] {
        TraitType(declaration) =>
          assert_eq(
            collected.name(
              collected.declarations[semantic_id_local(declaration)].name,
            ),
            "Mark",
          )
        _ => fail("expected applied method-local Mark bound")
      }
    _ => fail("expected method-local Mark bound")
  }
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      NoMatchingMethod(name, _, _) =>
        fail("unexpected missing method: " + collected.name(name))
      UnsatisfiedTraitObligation(_, _, _, _, _) =>
        fail("unexpected unsatisfied method-local trait bound")
      _ => fail("unexpected method-local generic diagnostic")
    }
  }
  assert_eq(inferred.diagnostics.length(), 0)
}

///|
test "method-local bounds remain available after earlier generic methods" {
  let (_, _, _, inferred) = call_test_module(
    720UL, b"trait Mark {\n  fn mark(self) -> U64\n}\nimpl Mark for U64 {\n  fn mark(self) -> U64 {\n    self\n  }\n}\nstruct Hasher<a> {}\nimpl<a> Hasher<a> {\n  fn first<x>(self, value: x) -> x {\n    value\n  }\n  fn mark_value<t: Mark>(self, value: t) -> U64 {\n    value.mark()\n  }\n}\nfn use(hasher: Hasher<Bool>) -> U64 {\n  hasher.mark_value(7u64)\n}\n",
  )
  assert_eq(inferred.impl_index.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
}

///|
test "generic inherent methods substitute impl arguments and Self" {
  let (collected, resolved, _, inferred) = call_test_module(
    702UL, b"struct Box<t> {\n  item: t\n}\nimpl<t> Box<t> {\n  fn get(self) -> t {\n    self.item\n  }\n}\nfn use(boxed: Box<I32>) -> I32 {\n  boxed.get()\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[1])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, collected.methods[0].id)
      assert_eq(arguments.length, 1)
      assert_call_primitive(
        inferred,
        resolved,
        inferred.call_type_arguments[arguments.start],
        I32Type,
      )
    }
    _ => fail("expected generic method target")
  }
}

///|
test "method-local generics instantiate freshly after impl generics" {
  let (collected, resolved, _, inferred) = call_test_module(
    708UL, b"struct Box<a> {}\nimpl<a> Box<a> {\n  fn choose<t>(self, value: t) -> t {\n    value\n  }\n}\nfn use(boxed: Box<Bool>) -> I32 {\n  boxed.choose(1)\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[1])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, collected.methods[0].id)
      assert_eq(arguments.length, 2)
      assert_call_primitive(
        inferred,
        resolved,
        inferred.call_type_arguments[arguments.start],
        BoolType,
      )
      assert_call_primitive(
        inferred,
        resolved,
        inferred.call_type_arguments[arguments.start + 1],
        I32Type,
      )
    }
    _ => fail("expected generic method target")
  }
}

///|
test "trait method generics dispatch through matching implementation methods" {
  let (collected, resolved, _, inferred) = call_test_module(
    721UL, b"trait Convert {\n  fn keep<t>(self, value: t) -> t\n}\nstruct Item {}\nimpl Convert for Item {\n  fn keep<t>(self, value: t) -> t {\n    value\n  }\n}\nfn use(item: Item) -> I32 {\n  item.keep(42)\n}\n",
  )
  assert_eq(inferred.impl_index.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let requirement_generics = collected.generic_parameters_of(
    collected.methods[0].id,
  )
  let implementation_generics = collected.generic_parameters_of(
    collected.methods[1].id,
  )
  assert_eq(requirement_generics.length, 1)
  assert_eq(implementation_generics.length, 1)
  let calls = body_calls(collected, collected.bodies[1])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, collected.methods[1].id)
      assert_eq(arguments.length, 1)
      assert_call_primitive(
        inferred,
        resolved,
        inferred.call_type_arguments[arguments.start],
        I32Type,
      )
    }
    _ => fail("expected generic trait implementation method")
  }
}

///|
test "trait method generic bounds constrain static calls" {
  let (_, _, _, accepted) = call_test_module(
    722UL, b"trait Mark {}\nimpl Mark for I32 {}\ntrait Convert {\n  fn keep<t: Mark>(self, value: t) -> t\n}\nstruct Item {}\nimpl Convert for Item {\n  fn keep<t: Mark>(self, value: t) -> t {\n    value\n  }\n}\nfn use(item: Item) -> I32 {\n  item.keep(42)\n}\n",
  )
  assert_eq(accepted.impl_index.diagnostics.length(), 0)
  assert_eq(accepted.diagnostics.length(), 0)
  let (_, _, _, rejected) = call_test_module(
    723UL, b"trait Mark {}\ntrait Convert {\n  fn keep<t: Mark>(self, value: t) -> t\n}\nstruct Item {}\nimpl Convert for Item {\n  fn keep<t: Mark>(self, value: t) -> t {\n    value\n  }\n}\nfn use(item: Item) -> Bool {\n  item.keep(true)\n}\n",
  )
  let mut unsatisfied = 0
  for diagnostic in rejected.diagnostics {
    match diagnostic {
      NoMatchingMethod(_, _, _) | UnsatisfiedTraitObligation(_, _, _, _, _) =>
        unsatisfied += 1
      _ => ()
    }
  }
  assert_eq(unsatisfied, 1)
}

///|
test "explicit type arguments specialize inherent and trait methods" {
  let (collected, resolved, _, inferred) = call_test_module(
    724UL, b"trait Factory {\n  fn make<t>(self) -> I32\n}\nstruct Item {}\nimpl Factory for Item {\n  fn make<t>(self) -> I32 {\n    1\n  }\n}\nimpl Item {\n  fn inherent<t>(self) -> I32 {\n    2\n  }\n}\nfn use(item: Item) -> I32 {\n  item.make::<Bool>() + item.inherent::<I64>()\n}\n",
  )
  assert_eq(inferred.impl_index.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[2])
  assert_eq(calls.length(), 2)
  let expected = [BoolType, I64Type]
  for index in 0..<calls.length() {
    match inferred.call_targets[calls[index]] {
      SelectedInferredCallTarget(_, arguments) => {
        assert_eq(arguments.length, 1)
        assert_call_primitive(
          inferred,
          resolved,
          inferred.call_type_arguments[arguments.start],
          expected[index],
        )
      }
      _ => fail("expected explicitly specialized method")
    }
  }
}

///|
test "trait methods dispatch statically through coherent impl evidence" {
  let (collected, _, _, inferred) = call_test_module(
    703UL, b"trait Show {\n  fn show(self) -> String\n}\nstruct Item {}\nimpl Show for Item {\n  fn show(self) -> String {\n    \"item\"\n  }\n}\nfn use(item: Item) -> String {\n  item.show()\n}\n",
  )
  assert_eq(inferred.impl_index.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[1])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.methods[1].id)
    _ => fail("expected trait implementation method")
  }
}

///|
test "inherent methods outrank trait methods with the same name" {
  let (collected, _, _, inferred) = call_test_module(
    704UL, b"trait Value {\n  fn value(self) -> I32\n}\nstruct Item {}\nimpl Value for Item {\n  fn value(self) -> I32 {\n    1\n  }\n}\nimpl Item {\n  fn value(self) -> I32 {\n    2\n  }\n}\nfn use(item: Item) -> I32 {\n  item.value()\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[2])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.methods[2].id)
    _ => fail("expected inherent method precedence")
  }
}

///|
test "strictly specialized trait impl methods outrank generic fallbacks" {
  let (collected, _, _, inferred) = call_test_module(
    710UL, b"trait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {}\nimpl<t> Read for Box<t> {\n  fn read(self) -> I32 {\n    1\n  }\n}\nimpl Read for Box<I32> {\n  fn read(self) -> I32 {\n    2\n  }\n}\nfn use(value: Box<I32>) -> I32 {\n  value.read()\n}\n",
  )
  assert_eq(inferred.impl_index.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[2])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.methods[2].id)
    _ => fail("expected specialized trait method")
  }
}

///|
test "same-name methods from separate traits are ambiguous" {
  let (_, _, _, inferred) = call_test_module(
    705UL, b"trait First {\n  fn read(self) -> I32\n}\ntrait Second {\n  fn read(self) -> I32\n}\nstruct Item {}\nimpl First for Item {\n  fn read(self) -> I32 {\n    1\n  }\n}\nimpl Second for Item {\n  fn read(self) -> I32 {\n    2\n  }\n}\nfn use(item: Item) -> I32 {\n  item.read()\n}\n",
  )
  let mut ambiguous = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      AmbiguousMethod(_, _, _, _, count, _) => {
        ambiguous += 1
        assert_eq(count, 2)
      }
      _ => ()
    }
  }
  assert_eq(ambiguous, 1)
}

///|
test "method parameters constrain nested object arguments" {
  let (collected, _, _, inferred) = call_test_module(
    706UL, b"struct Item {\n  value: I32\n}\nimpl Item {\n  fn combine(self, other: Item) -> I32 {\n    other.value\n  }\n}\nfn use(item: Item) -> I32 {\n  item.combine({\n    value: 2\n  })\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[1])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.methods[0].id)
    _ => fail("expected object-argument method")
  }
  let (_, selection) = selected_expression_of_kind(collected, inferred, false)
  match selection {
    StructConstructionSelection(declaration, _) =>
      assert_eq(declaration, collected.declarations[0].id)
    _ => fail("expected method object argument selection")
  }
}

///|
test "type-qualified static and instance methods select impl declarations" {
  let (collected, _, _, inferred) = call_test_module(
    711UL, b"struct Item {\n  value: I32\n}\nimpl Item {\n  fn make(value: I32) -> Item {\n    Item::{\n      value: value\n    }\n  }\n  fn read(self) -> I32 {\n    self.value\n  }\n}\nfn use(item: Item) -> I32 {\n  let made = Item::make(1)\n  Item::read(made)\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[2])
  assert_eq(calls.length(), 2)
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.methods[0].id)
    _ => fail("expected qualified static method")
  }
  match inferred.call_targets[calls[1]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.methods[1].id)
    _ => fail("expected qualified instance method")
  }
}

///|
test "primitive-qualified static methods select impl declarations" {
  let (collected, _, names, inferred) = call_test_module(
    714UL, b"impl I32 {\n  fn answer() -> I32 {\n    42\n  }\n}\nfn use() -> I32 {\n  I32::answer()\n}\n",
  )
  assert_eq(names.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[1])
  assert_eq(calls.length(), 1)
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.methods[0].id)
    _ => fail("expected primitive-qualified static method")
  }
  assert_eq(inferred.diagnostics.length(), 0)
}

///|
test "trait-qualified instance and static methods select coherent evidence" {
  let (collected, _, _, inferred) = call_test_module(
    713UL, b"trait Build {\n  fn make(value: I32) -> Self\n  fn read(self) -> I32\n}\nstruct Item {\n  value: I32\n}\nimpl Build for Item {\n  fn make(value: I32) -> Self {\n    Item::{\n      value: value\n    }\n  }\n  fn read(self) -> I32 {\n    self.value\n  }\n}\nfn use(item: Item) -> I32 {\n  let made = Build::make(1)\n  Build::read(made)\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[2])
  assert_eq(calls.length(), 2)
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.methods[2].id)
    _ => fail("expected trait-qualified static method")
  }
  match inferred.call_targets[calls[1]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.methods[3].id)
    _ => fail("expected trait-qualified instance method")
  }
}

///|
test "generic static methods infer impl arguments through Self" {
  let (collected, resolved, _, inferred) = call_test_module(
    712UL, b"struct Box<a> {\n  value: a\n}\nimpl<a> Box<a> {\n  fn make(value: a) -> Self {\n    Box::{\n      value: value\n    }\n  }\n}\nfn use() -> Box<I32> {\n  Box::make(1)\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[1])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, collected.methods[0].id)
      assert_eq(arguments.length, 1)
      assert_call_primitive(
        inferred,
        resolved,
        inferred.call_type_arguments[arguments.start],
        I32Type,
      )
    }
    _ => fail("expected generic static method")
  }
}

///|
test "runtime trait values retain coercion evidence and dynamic method slots" {
  let (collected, _, _, inferred) = call_test_module(
    715UL, b"trait Read {\n  fn read(self) -> I32\n}\nstruct Item {}\nimpl Read for Item {\n  fn read(self) -> I32 {\n    42\n  }\n}\nfn invoke(value: Read) -> I32 {\n  value.read()\n}\nfn use() -> I32 {\n  invoke(Item::{})\n}\n",
  )
  assert_eq(inferred.impl_index.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let invoke_calls = body_calls(collected, collected.bodies[1])
  assert_eq(invoke_calls.length(), 1)
  match inferred.call_targets[invoke_calls[0]] {
    SelectedDynamicTraitCallTarget(trait_, requirement, slot, arguments) => {
      assert_eq(trait_, collected.declarations[0].id)
      assert_eq(requirement, collected.methods[0].id)
      assert_eq(slot, 0)
      assert_eq(arguments.length, 0)
    }
    _ => fail("expected dynamic trait call target")
  }
  let use_calls = body_calls(collected, collected.bodies[2])
  assert_eq(use_calls.length(), 1)
  let call = use_calls[0]
  let arguments = match collected.expressions[call] {
    HirCallExpr(_, values, _) => values
    _ => fail("expected function call")
  }
  let item = collected.expression_children[arguments.start]
  match inferred.trait_object_coercions[item] {
    SelectedInferredTraitObjectCoercion(trait_, evidence) => {
      assert_eq(trait_, collected.declarations[0].id)
      match inferred.trait_evidence[evidence].kind {
        ConcreteInferredTraitEvidence(implementation, arguments) => {
          assert_eq(implementation, collected.impls[0].declaration)
          assert_eq(arguments.length, 0)
        }
        _ => fail("expected concrete runtime trait evidence")
      }
    }
    _ => fail("expected runtime trait object coercion")
  }
}

///|
test "generic trait values coerce at explicit and tail return boundaries" {
  let (_, _, _, inferred) = call_test_module(
    718UL, b"trait Read {\n  fn read(self) -> I32\n}\nfn explicit<t: Read>(value: t) -> Read {\n  return value\n}\nfn tail<t: Read>(value: t) -> Read {\n  value\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let mut bound_coercions = 0
  for coercion in inferred.trait_object_coercions {
    match coercion {
      SelectedInferredTraitObjectCoercion(_, evidence) =>
        match inferred.trait_evidence[evidence].kind {
          BoundInferredTraitEvidence(_) => bound_coercions += 1
          _ => fail("expected generic-bound runtime trait evidence")
        }
      _ => ()
    }
  }
  assert_eq(bound_coercions, 2)
}

///|
test "generic trait coercion evidence is deterministic across body schedules" {
  let collected = collect_bytes(
    719UL, b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\nfn choose<t: Value>(flag: Bool, value: t) -> Value {\n  if flag {\n    value\n  } else {\n    value\n  }\n}\nfn invoke(value: Value) -> I32 {\n  value.value()\n}\npub fn main() -> I32 {\n  invoke(choose(true, 42))\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let forward_order : Array[Int] = []
  let reverse_order : Array[Int] = []
  for index in 0..<collected.bodies.length() {
    forward_order.push(index)
    reverse_order.push(collected.bodies.length() - index - 1)
  }
  let forward = infer_module_bodies_in_order(
    collected, resolved, names, forward_order,
  )
  let reverse = infer_module_bodies_in_order(
    collected, resolved, names, reverse_order,
  )
  assert_eq(forward, reverse)
}

///|
test "runtime trait calls reject method-generic requirements while static calls work" {
  let (collected, _, _, inferred) = call_test_module(
    725UL, b"trait Factory {\n  fn make<t>(self, value: t) -> I32\n}\nstruct Item {}\nimpl Factory for Item {\n  fn make<t>(self, value: t) -> I32 {\n    42\n  }\n}\nfn dynamic(value: Factory) -> I32 {\n  value.make(1)\n}\nfn static(value: Item) -> I32 {\n  value.make(1)\n}\n",
  )
  let dynamic_calls = body_calls(collected, collected.bodies[1])
  assert_eq(inferred.call_targets[dynamic_calls[0]], ErrorInferredCallTarget)
  let static_calls = body_calls(collected, collected.bodies[2])
  match inferred.call_targets[static_calls[0]] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, collected.methods[1].id)
      assert_eq(arguments.length, 1)
    }
    _ => fail("expected static method-generic dispatch")
  }
  let mut missing = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      NoMatchingMethod(_, expression, _) if expression == dynamic_calls[0] =>
        missing += 1
      _ => ()
    }
  }
  assert_eq(missing, 1)
}

///|
test "runtime trait calls reject methods exposing Self outside the receiver" {
  let (collected, _, _, inferred) = call_test_module(
    717UL, b"trait Clone {\n  fn clone(self) -> Self\n}\nstruct Item {}\nimpl Clone for Item {\n  fn clone(self) -> Self {\n    self\n  }\n}\nfn invoke(value: Clone) -> Clone {\n  value.clone()\n}\n",
  )
  let calls = body_calls(collected, collected.bodies[1])
  assert_eq(calls.length(), 1)
  assert_eq(inferred.call_targets[calls[0]], ErrorInferredCallTarget)
  let mut missing = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      NoMatchingMethod(_, expression, _) if expression == calls[0] =>
        missing += 1
      _ => ()
    }
  }
  assert_eq(missing, 1)
}

///|
test "concrete trait calls remain statically selected without trait objects" {
  let (collected, _, _, inferred) = call_test_module(
    716UL, b"trait Read {\n  fn read(self) -> I32\n}\nstruct Item {}\nimpl Read for Item {\n  fn read(self) -> I32 {\n    42\n  }\n}\nfn invoke(value: Item) -> I32 {\n  value.read()\n}\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[1])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.methods[1].id)
    _ => fail("expected static implementation method")
  }
  for coercion in inferred.trait_object_coercions {
    assert_eq(coercion, NoInferredTraitObjectCoercion)
  }
}

///|
test "method inference is deterministic across body schedules" {
  let collected = collect_bytes(
    709UL, b"struct Item {\n  value: I32\n}\nimpl Item {\n  fn read(self) -> I32 {\n    self.value\n  }\n}\nfn first(item: Item) -> I32 {\n  item.read()\n}\nfn second(item: Item) -> I32 {\n  item.read()\n}\n",
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
test "unknown methods produce one method diagnostic without field cascades" {
  let (_, _, _, inferred) = call_test_module(
    707UL, b"struct Item {}\nfn use(item: Item) -> I32 {\n  item.missing()\n}\n",
  )
  let mut method_errors = 0
  let mut field_errors = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      NoMatchingMethod(_, _, _) => method_errors += 1
      UnknownFieldForType(_, _, _, _) | FieldAccessRequiresNominal(_, _) =>
        field_errors += 1
      _ => ()
    }
  }
  assert_eq(method_errors, 1)
  assert_eq(field_errors, 0)
}
