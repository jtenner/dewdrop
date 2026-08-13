///|
test "collection retains ordered generic trait-bound syntax" {
  let collected = collect_bytes(
    2720UL, b"trait Eq {\n  fn eq(self, right: Self) -> Bool\n}\ntrait Debug {\n  fn debug(self) -> String\n}\nfn inspect<t: Eq + Debug, u>(value: t) -> t {\n  value\n}\n",
  )
  let declaration = collected.lookup_value("inspect").unwrap()
  let parameters = collected.generic_parameters_of(declaration)
  assert_eq(parameters.length, 2)
  let first = collected.generic_parameters[parameters.start]
  assert_eq(first.bounds.length, 2)
  match collected.type_syntax[collected.generic_bounds[first.bounds.start]] {
    NamedTypeSyntax(name, _) => assert_eq(collected.names[name], "Eq")
    _ => fail("expected first named generic bound")
  }
  match
    collected.type_syntax[collected.generic_bounds[first.bounds.start + 1]] {
    NamedTypeSyntax(name, _) => assert_eq(collected.names[name], "Debug")
    _ => fail("expected second named generic bound")
  }
  assert_eq(collected.generic_parameters[parameters.start + 1].bounds.length, 0)
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 0)
  match resolved.types[resolved.generic_bound_types[first.bounds.start]] {
    TraitType(declaration) =>
      assert_eq(declaration, collected.lookup_trait("Eq").unwrap())
    _ => fail("expected resolved Eq trait bound")
  }
  match resolved.types[resolved.generic_bound_types[first.bounds.start + 1]] {
    TraitType(declaration) =>
      assert_eq(declaration, collected.lookup_trait("Debug").unwrap())
    _ => fail("expected resolved Debug trait bound")
  }
}

///|
test "generic bodies select declared operator evidence symbolically" {
  let collected = collect_bytes(
    2728UL, b"trait Eq {\n  fn eq(self, right: Self) -> Bool\n}\nfn equal<t: Eq>(left: t, right: t) -> Bool {\n  left == right\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)
  let body = collected
    .body_of(collected.lookup_value("equal").unwrap())
    .unwrap()
  let mut selected = false
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match collected.expressions[expression] {
      HirBinaryExpr(_, _, _, _) =>
        match inferred.operator_targets[expression] {
          SelectedBoundInferredCallTarget(requirement, evidence, arguments) => {
            assert_eq(requirement, collected.methods[0].id)
            assert_eq(evidence, 0)
            assert_eq(arguments.length, 0)
            selected = true
          }
          _ => fail("expected symbolic generic operator evidence")
        }
      _ => ()
    }
  }
  assert_true(selected)
}

///|
test "generic bodies select declared method evidence symbolically" {
  let collected = collect_bytes(
    2729UL, b"trait Value {\n  fn value(self) -> I32\n}\nfn read<t: Value>(value: t) -> I32 {\n  value.value()\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)
  let body = collected.body_of(collected.lookup_value("read").unwrap()).unwrap()
  let calls = body_calls(collected, body)
  assert_eq(calls.length(), 1)
  match inferred.call_targets[calls[0]] {
    SelectedBoundInferredCallTarget(requirement, evidence, arguments) => {
      assert_eq(requirement, collected.methods[0].id)
      assert_eq(evidence, 0)
      assert_eq(arguments.length, 0)
    }
    _ => fail("expected symbolic generic method evidence")
  }
}

///|
test "generic bodies instantiate applied bound method arguments" {
  let collected = collect_bytes(
    2732UL, b"trait Convert<u> {\n  fn convert(self, value: u) -> u\n}\nfn convert_i32<t: Convert<I32>>(target: t, value: I32) -> I32 {\n  target.convert(value)\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)
  let body = collected
    .body_of(collected.lookup_value("convert_i32").unwrap())
    .unwrap()
  let calls = body_calls(collected, body)
  assert_eq(calls.length(), 1)
  match inferred.call_targets[calls[0]] {
    SelectedBoundInferredCallTarget(requirement, evidence, arguments) => {
      assert_eq(requirement, collected.methods[0].id)
      assert_eq(evidence, 0)
      assert_eq(arguments.length, 1)
      assert_call_primitive(
        inferred,
        resolved,
        inferred.call_type_arguments[arguments.start],
        I32Type,
      )
    }
    _ => fail("expected applied symbolic method evidence")
  }
}

///|
test "generic implementation bodies consume owner bound evidence" {
  let collected = collect_bytes(
    2733UL, b"trait Value {\n  fn value(self) -> I32\n}\ntrait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {\n  item: t\n}\nimpl<t: Value> Read for Box<t> {\n  fn read(self) -> I32 {\n    self.item.value()\n  }\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)
  let body = collected.bodies[0]
  let calls = body_calls(collected, body)
  assert_eq(calls.length(), 1)
  match inferred.call_targets[calls[0]] {
    SelectedBoundInferredCallTarget(requirement, evidence, _) => {
      assert_eq(requirement, collected.methods[0].id)
      assert_eq(evidence, 0)
    }
    _ => fail("expected implementation-owner symbolic method evidence")
  }
}

///|
test "generic bodies use declared bounds for nested obligations" {
  let collected = collect_bytes(
    2730UL, b"trait Marker {}\nfn require<t: Marker>(value: t) -> t {\n  value\n}\nfn forward<t: Marker>(value: t) -> t {\n  require(value)\n}\nfn rejected<t>(value: t) -> t {\n  require(value)\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 1)
  match inferred.diagnostics[0] {
    UnsatisfiedTraitObligation(callable, _, trait_, _, _) => {
      assert_eq(callable, collected.lookup_value("require").unwrap())
      assert_eq(trait_, collected.lookup_trait("Marker").unwrap())
    }
    _ => fail("expected only the unbounded nested obligation to fail")
  }
}

///|
test "generic bodies use declared bounds for implementation prerequisites" {
  let collected = collect_bytes(
    2731UL, b"trait Eq {\n  fn eq(self, right: Self) -> Bool\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t: Eq> Eq for Box<t> {\n  fn eq(self, right: Box<t>) -> Bool {\n    true\n  }\n}\nfn equal_boxes<t: Eq>(left: Box<t>, right: Box<t>) -> Bool {\n  left == right\n}\nfn rejected<t>(left: Box<t>, right: Box<t>) -> Bool {\n  left == right\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 1)
  match inferred.diagnostics[0] {
    NoMatchingMethod(name, _, _) => assert_eq(collected.names[name], "eq")
    _ => fail("expected only the unbounded implementation prerequisite to fail")
  }
}

///|
test "generic calls freeze recursive concrete and symbolic evidence" {
  let collected = collect_bytes(
    2734UL, b"trait Marker {}\ntrait Value {}\nstruct Yes {}\nstruct Box<t> {\n  value: t\n}\nimpl Marker for Yes {}\nimpl Marker for I32 {}\nimpl<t: Marker> Value for Box<t> {}\nfn require<t: Value>(value: t) -> t {\n  value\n}\nfn concrete(value: Box<Yes>) -> Box<Yes> {\n  require(value)\n}\nfn scalar(value: Box<I32>) -> Box<I32> {\n  require(value)\n}\nfn symbolic<t: Value>(value: t) -> t {\n  require(value)\n}\nfn generic_box<t: Marker>(value: Box<t>) -> Box<t> {\n  require(value)\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)

  let concrete_body = collected
    .body_of(collected.lookup_value("concrete").unwrap())
    .unwrap()
  let concrete_call = body_calls(collected, concrete_body)[0]
  let concrete_span = inferred.expression_evidence[concrete_call]
  assert_eq(concrete_span.length, 1)
  let concrete_root = inferred.trait_evidence_roots[concrete_span.start]
  let value_impl = collected.impls[2].declaration
  match inferred.trait_evidence[concrete_root].kind {
    ConcreteInferredTraitEvidence(implementation, arguments) => {
      assert_eq(implementation, value_impl)
      assert_eq(arguments.length, 1)
      match inferred.trait_evidence_arguments[arguments.start] {
        ShapeInferredTraitEvidenceArgument(shape) =>
          assert_eq(shape, RefPlannedValueShape)
        _ => fail("expected retained concrete evidence carrier")
      }
    }
    _ => fail("expected concrete outer evidence")
  }
  let prerequisites = inferred.trait_evidence[concrete_root].prerequisites
  assert_eq(prerequisites.length, 1)
  let marker_node = inferred.trait_evidence_children[prerequisites.start]
  match inferred.trait_evidence[marker_node].kind {
    ConcreteInferredTraitEvidence(implementation, arguments) => {
      assert_eq(implementation, collected.impls[0].declaration)
      assert_eq(arguments.length, 0)
    }
    _ => fail("expected concrete prerequisite evidence")
  }
  assert_eq(inferred.trait_evidence[marker_node].prerequisites.length, 0)

  let scalar_body = collected
    .body_of(collected.lookup_value("scalar").unwrap())
    .unwrap()
  let scalar_call = body_calls(collected, scalar_body)[0]
  let scalar_span = inferred.expression_evidence[scalar_call]
  assert_eq(scalar_span.length, 1)
  let scalar_root = inferred.trait_evidence_roots[scalar_span.start]
  match inferred.trait_evidence[scalar_root].kind {
    ConcreteInferredTraitEvidence(implementation, arguments) => {
      assert_eq(implementation, value_impl)
      assert_eq(arguments.length, 1)
      match inferred.trait_evidence_arguments[arguments.start] {
        ShapeInferredTraitEvidenceArgument(shape) =>
          assert_eq(shape, I32PlannedValueShape)
        _ => fail("expected retained scalar evidence carrier")
      }
    }
    _ => fail("expected scalar concrete evidence")
  }

  let symbolic_body = collected
    .body_of(collected.lookup_value("symbolic").unwrap())
    .unwrap()
  let symbolic_call = body_calls(collected, symbolic_body)[0]
  let symbolic_span = inferred.expression_evidence[symbolic_call]
  assert_eq(symbolic_span.length, 1)
  let symbolic_root = inferred.trait_evidence_roots[symbolic_span.start]
  match inferred.trait_evidence[symbolic_root].kind {
    BoundInferredTraitEvidence(slot) => assert_eq(slot, 0)
    _ => fail("expected caller-bound symbolic evidence")
  }

  let generic_box_body = collected
    .body_of(collected.lookup_value("generic_box").unwrap())
    .unwrap()
  let generic_box_call = body_calls(collected, generic_box_body)[0]
  let generic_box_span = inferred.expression_evidence[generic_box_call]
  assert_eq(generic_box_span.length, 1)
  let generic_box_root = inferred.trait_evidence_roots[generic_box_span.start]
  let generic_box_evidence = inferred.trait_evidence[generic_box_root]
  match generic_box_evidence.kind {
    ConcreteInferredTraitEvidence(implementation, arguments) => {
      assert_eq(implementation, value_impl)
      assert_eq(arguments.length, 1)
      match inferred.trait_evidence_arguments[arguments.start] {
        GenericInferredTraitEvidenceArgument(index) => assert_eq(index, 0)
        _ => fail("expected caller generic evidence argument")
      }
    }
    _ => fail("expected generic implementation evidence")
  }
  assert_eq(generic_box_evidence.prerequisites.length, 1)
  let generic_box_child = inferred.trait_evidence_children[generic_box_evidence.prerequisites.start]
  match inferred.trait_evidence[generic_box_child].kind {
    BoundInferredTraitEvidence(slot) => assert_eq(slot, 0)
    _ => fail("expected generic implementation bound prerequisite")
  }

  let reverse = infer_module_bodies_in_order(collected, resolved, names, [
    4, 3, 2, 1, 0,
  ])
  assert_eq(inferred, reverse)
}

///|
test "recursive implementation evidence retains node-local arguments" {
  let collected = collect_bytes(
    2736UL, b"trait Value {}\ntrait Read {}\nstruct Box<t> {\n  value: t\n}\nimpl<t: Value> Read for Box<t> {}\ntrait Inspect {}\nstruct Wrap<t> {\n  value: t\n}\nimpl<t: Read> Inspect for Wrap<t> {}\nfn require<t: Inspect>(value: t) -> t {\n  value\n}\nfn nested<t: Value>(value: t) -> Wrap<Box<t>> {\n  require(Wrap::{\n    value: Box::{\n      value: value\n    }\n  })\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)
  let body = collected
    .body_of(collected.lookup_value("nested").unwrap())
    .unwrap()
  let call = body_calls(collected, body)[0]
  let span = inferred.expression_evidence[call]
  assert_eq(span.length, 1)
  let inspect_node = inferred.trait_evidence_roots[span.start]
  let inspect_evidence = inferred.trait_evidence[inspect_node]
  match inspect_evidence.kind {
    ConcreteInferredTraitEvidence(implementation, arguments) => {
      assert_eq(implementation, collected.impls[1].declaration)
      assert_eq(arguments.length, 1)
      match inferred.trait_evidence_arguments[arguments.start] {
        ShapeInferredTraitEvidenceArgument(shape) =>
          assert_eq(shape, RefPlannedValueShape)
        _ => fail("expected applied Inspect owner argument")
      }
    }
    _ => fail("expected concrete Inspect evidence")
  }
  assert_eq(inspect_evidence.prerequisites.length, 1)
  let read_node = inferred.trait_evidence_children[inspect_evidence.prerequisites.start]
  let read_evidence = inferred.trait_evidence[read_node]
  match read_evidence.kind {
    ConcreteInferredTraitEvidence(implementation, arguments) => {
      assert_eq(implementation, collected.impls[0].declaration)
      assert_eq(arguments.length, 1)
      match inferred.trait_evidence_arguments[arguments.start] {
        GenericInferredTraitEvidenceArgument(index) => assert_eq(index, 0)
        _ => fail("expected caller generic Read owner argument")
      }
    }
    _ => fail("expected concrete Read prerequisite evidence")
  }
  assert_eq(read_evidence.prerequisites.length, 1)
  let value_node = inferred.trait_evidence_children[read_evidence.prerequisites.start]
  match inferred.trait_evidence[value_node].kind {
    BoundInferredTraitEvidence(slot) => assert_eq(slot, 0)
    _ => fail("expected leaf caller Value evidence")
  }
}

///|
test "generic method calls freeze implementation prerequisite evidence" {
  let collected = collect_bytes(
    2735UL, b"trait Marker {}\ntrait Value {\n  fn value(self) -> I32\n}\nstruct Yes {}\nstruct Box<t> {\n  value: t\n}\nimpl Marker for Yes {}\nimpl<t: Marker> Value for Box<t> {\n  fn value(self) -> I32 {\n    1\n  }\n}\nfn concrete(value: Box<Yes>) -> I32 {\n  value.value()\n}\nfn symbolic<t: Marker>(value: Box<t>) -> I32 {\n  value.value()\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)

  let concrete_body = collected
    .body_of(collected.lookup_value("concrete").unwrap())
    .unwrap()
  let concrete_call = body_calls(collected, concrete_body)[0]
  let concrete_span = inferred.expression_evidence[concrete_call]
  assert_eq(concrete_span.length, 1)
  let concrete_node = inferred.trait_evidence_roots[concrete_span.start]
  match inferred.trait_evidence[concrete_node].kind {
    ConcreteInferredTraitEvidence(implementation, arguments) => {
      assert_eq(implementation, collected.impls[0].declaration)
      assert_eq(arguments.length, 0)
    }
    _ => fail("expected concrete method prerequisite")
  }

  let symbolic_body = collected
    .body_of(collected.lookup_value("symbolic").unwrap())
    .unwrap()
  let symbolic_call = body_calls(collected, symbolic_body)[0]
  let symbolic_span = inferred.expression_evidence[symbolic_call]
  assert_eq(symbolic_span.length, 1)
  let symbolic_node = inferred.trait_evidence_roots[symbolic_span.start]
  match inferred.trait_evidence[symbolic_node].kind {
    BoundInferredTraitEvidence(slot) => assert_eq(slot, 0)
    _ => fail("expected symbolic method prerequisite")
  }
}

///|
test "generic calls require local coherent trait evidence" {
  let accepted = collect_bytes(
    2721UL, b"trait Marker {}\nstruct Yes {}\nimpl Marker for Yes {}\nfn keep<t: Marker>(value: t) -> t {\n  value\n}\nfn accepted() -> Yes {\n  keep(Yes::{})\n}\n",
  )
  let accepted_types = resolve_module_types(accepted)
  let accepted_names = resolve_module_names(accepted)
  let accepted_inferred = infer_module_bodies(
    accepted, accepted_types, accepted_names,
  )
  assert_eq(accepted_inferred.diagnostics.length(), 0)

  let rejected = collect_bytes(
    2722UL, b"trait Marker {}\nstruct No {}\nfn keep<t: Marker>(value: t) -> t {\n  value\n}\nfn rejected() -> No {\n  keep(No::{})\n}\n",
  )
  let rejected_types = resolve_module_types(rejected)
  let rejected_names = resolve_module_names(rejected)
  let rejected_inferred = infer_module_bodies(
    rejected, rejected_types, rejected_names,
  )
  assert_eq(rejected_inferred.diagnostics.length(), 1)
  match rejected_inferred.diagnostics[0] {
    UnsatisfiedTraitObligation(callable, parameter, trait_, _, _) => {
      assert_eq(callable, rejected.lookup_value("keep").unwrap())
      assert_eq(parameter, rejected.generic_parameters[0].id)
      assert_eq(trait_, rejected.lookup_trait("Marker").unwrap())
    }
    _ => fail("expected unsatisfied generic trait obligation")
  }
}

///|
test "generic implementation bounds constrain method and obligation evidence" {
  let collected = collect_bytes(
    2725UL, b"trait Marker {}\ntrait Value {\n  fn value(self) -> I32\n}\nstruct Yes {}\nstruct No {}\nstruct Box<t> {\n  value: t\n}\nimpl Marker for Yes {}\nimpl<t: Marker> Value for Box<t> {\n  fn value(self) -> I32 {\n    1\n  }\n}\nfn require<t: Value>(value: t) -> t {\n  value\n}\nfn accepted_method(value: Box<Yes>) -> I32 {\n  value.value()\n}\nfn rejected_method(value: Box<No>) -> I32 {\n  value.value()\n}\nfn accepted_obligation(value: Box<Yes>) -> Box<Yes> {\n  require(value)\n}\nfn rejected_obligation(value: Box<No>) -> Box<No> {\n  require(value)\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 2)
  let mut method_failure = false
  let mut obligation_failure = false
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      NoMatchingMethod(_, expression, _) =>
        match collected.expressions[expression] {
          HirCallExpr(target, _, _) =>
            match collected.expressions[target] {
              HirFieldExpr(_, name, _) => {
                assert_eq(collected.names[name], "value")
                method_failure = true
              }
              _ =>
                fail("expected rejected generic implementation method target")
            }
          _ => fail("expected rejected generic implementation method call")
        }
      UnsatisfiedTraitObligation(callable, _, trait_, _, _) => {
        assert_eq(callable, collected.lookup_value("require").unwrap())
        assert_eq(trait_, collected.lookup_trait("Value").unwrap())
        obligation_failure = true
      }
      _ => fail("unexpected generic implementation bound diagnostic")
    }
  }
  assert_true(method_failure)
  assert_true(obligation_failure)
}

///|
test "generic implementation bounds constrain operator evidence transitively" {
  let collected = collect_bytes(
    2726UL, b"trait Marker {}\ntrait Eq {\n  fn eq(self, right: Self) -> Bool\n}\nstruct Yes {}\nstruct No {}\nstruct Box<t> {\n  value: t\n}\nstruct Outer<t> {\n  value: t\n}\nimpl Marker for Yes {}\nimpl<t: Marker> Eq for Box<t> {\n  fn eq(self, right: Box<t>) -> Bool {\n    true\n  }\n}\nimpl<t: Eq> Eq for Outer<t> {\n  fn eq(self, right: Outer<t>) -> Bool {\n    true\n  }\n}\nfn accepted(left: Outer<Box<Yes>>, right: Outer<Box<Yes>>) -> Bool {\n  left == right\n}\nfn rejected(left: Outer<Box<No>>, right: Outer<Box<No>>) -> Bool {\n  left == right\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let outer_impl = collected.impls[collected.impls.length() - 1].declaration
  let outer_generics = collected.generic_parameters_of(outer_impl)
  assert_eq(outer_generics.length, 1)
  assert_eq(collected.generic_parameters[outer_generics.start].bounds.length, 1)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.impl_index.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 1)
  match inferred.diagnostics[0] {
    NoMatchingMethod(name, _, _) => assert_eq(collected.names[name], "eq")
    _ => fail("expected transitively unsatisfied operator evidence")
  }
}

///|
test "generic call obligations match applied trait arguments" {
  let collected = collect_bytes(
    2723UL, b"trait Convert<t> {}\nstruct Item {}\nimpl Convert<I32> for Item {}\nfn accepts<t: Convert<I32>>(value: t) -> t {\n  value\n}\nfn rejects<t: Convert<I64>>(value: t) -> t {\n  value\n}\nfn run_ok() -> Item {\n  accepts(Item::{})\n}\nfn run_bad() -> Item {\n  rejects(Item::{})\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 1)
  match inferred.diagnostics[0] {
    UnsatisfiedTraitObligation(callable, _, trait_, _, _) => {
      assert_eq(callable, collected.lookup_value("rejects").unwrap())
      assert_eq(trait_, collected.lookup_trait("Convert").unwrap())
    }
    _ => fail("expected applied trait obligation mismatch")
  }
}

///|
test "imported generic implementation bounds constrain visible evidence" {
  let program = collect_program_manifest(
    2727UL,
    ProgramManifest::new([
      ManifestModule::new("evidence.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open evidence.library\nfn accepted(value: Box<Yes>) -> I32 {\n  value.value()\n}\nfn rejected(value: Box<No>) -> I32 {\n  value.value()\n}\n",
        ),
      ]),
      ManifestModule::new("evidence.library", [
        ManifestFile::new(
          "library.dew", b"pub trait Marker {}\npub trait Value {\n  fn value(self) -> I32\n}\npub struct Yes {}\npub struct No {}\npub struct Box<t> {\n  value: t\n}\nimpl Marker for Yes {}\nimpl<t: Marker> Value for Box<t> {\n  fn value(self) -> I32 {\n    1\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let consumer = analyzed.modules[0]
  let mut frozen_bounded_impls = 0
  for implementation in analyzed.frozen.interfaces[1].implementations {
    if implementation.generic_parameters.length > 0 {
      frozen_bounded_impls += 1
    }
  }
  assert_eq(frozen_bounded_impls, 1)
  let mut library_impls = 0
  let mut bounded_impls = 0
  let mut marker_trait = 0UL
  let mut bound_trait = 0UL
  let consumer_types = analyzed.frozen.interfaces[0].resolved_types
  for implementation in consumer.imports.implementations {
    if semantic_id_module(implementation.declaration) ==
      program.modules[1].module_id {
      library_impls += 1
      if implementation.generic_parameters.length == 0 {
        match consumer_types.types[implementation.trait_type] {
          TraitType(declaration) => marker_trait = declaration
          _ => fail("expected imported marker implementation trait")
        }
      }
    }
    if implementation.generic_parameters.length > 0 {
      bounded_impls += 1
      assert_eq(implementation.generic_parameters.length, 1)
      assert_eq(implementation.generic_bounds.length, 1)
      let parameter_bounds = consumer.imports.generic_parameter_bounds[implementation.generic_bounds.start]
      assert_eq(parameter_bounds.length, 1)
      match
        consumer_types.types[consumer.imports.generic_bound_types[parameter_bounds.start]] {
        TraitType(declaration) => bound_trait = declaration
        _ => fail("expected imported implementation marker bound")
      }
    }
  }
  assert_eq(library_impls, 2)
  assert_eq(bounded_impls, 1)
  assert_eq(bound_trait, marker_trait)
  let mut indexed_library_impls = 0
  for implementation in consumer.inferred.impl_index.implementations {
    if semantic_id_module(implementation.declaration) ==
      program.modules[1].module_id {
      indexed_library_impls += 1
      assert_true(implementation.valid)
      assert_true(implementation.coherent)
    }
  }
  assert_eq(indexed_library_impls, 2)
  assert_eq(consumer.inferred.impl_index.diagnostics.length(), 0)
  assert_eq(consumer.inferred.diagnostics.length(), 1)
  match consumer.inferred.diagnostics[0] {
    NoMatchingMethod(name, _, _) =>
      assert_eq(program.modules[0].names[name], "value")
    _ => fail("expected imported generic implementation bound failure")
  }
}

///|
test "imported generic calls freeze recursive implementation evidence" {
  let program = collect_program_manifest(
    2736UL,
    ProgramManifest::new([
      ManifestModule::new("evidence.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open evidence.library\nfn run(value: Box<Yes>) -> Box<Yes> {\n  require(value)\n}\n",
        ),
      ]),
      ManifestModule::new("evidence.library", [
        ManifestFile::new(
          "library.dew", b"pub trait Marker {}\npub trait Value {}\npub struct Yes {}\npub struct Box<t> {\n  value: t\n}\nimpl Marker for Yes {}\nimpl<t: Marker> Value for Box<t> {}\npub fn require<t: Value>(value: t) -> t {\n  value\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let consumer = analyzed.modules[0]
  assert_eq(consumer.inferred.diagnostics.length(), 0)
  let body = program.modules[0]
    .body_of(program.modules[0].lookup_value("run").unwrap())
    .unwrap()
  let call = body_calls(program.modules[0], body)[0]
  let span = consumer.inferred.expression_evidence[call]
  assert_eq(span.length, 1)
  let root = consumer.inferred.trait_evidence_roots[span.start]
  let root_evidence = consumer.inferred.trait_evidence[root]
  match root_evidence.kind {
    ConcreteInferredTraitEvidence(implementation, arguments) => {
      assert_eq(arguments.length, 1)
      assert_eq(
        semantic_id_module(implementation),
        program.modules[1].module_id,
      )
      let imported_impl = consumer.imports
        .implementation(implementation)
        .unwrap()
      assert_eq(imported_impl.generic_parameters.length, 1)
    }
    _ => fail("expected imported concrete root evidence")
  }
  assert_eq(root_evidence.prerequisites.length, 1)
  let child = consumer.inferred.trait_evidence_children[root_evidence.prerequisites.start]
  match consumer.inferred.trait_evidence[child].kind {
    ConcreteInferredTraitEvidence(implementation, arguments) => {
      assert_eq(arguments.length, 0)
      assert_eq(
        semantic_id_module(implementation),
        program.modules[1].module_id,
      )
      let imported_impl = consumer.imports
        .implementation(implementation)
        .unwrap()
      assert_eq(imported_impl.generic_parameters.length, 0)
    }
    _ => fail("expected imported concrete prerequisite evidence")
  }

  let lowering = plan_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].expression_evidence[call], span)
  assert_eq(lowering.modules[0].trait_evidence_roots[span.start], root)
  assert_eq(lowering.modules[0].trait_evidence[root], root_evidence)
}

///|
test "imported generic calls retain and enforce bound evidence" {
  let program = collect_program_manifest(
    2724UL,
    ProgramManifest::new([
      ManifestModule::new("bounds.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open bounds.library\nstruct Yes {}\nstruct No {}\nimpl Marker for Yes {}\nfn accepted() -> Yes {\n  keep(Yes::{})\n}\nfn rejected() -> No {\n  keep(No::{})\n}\n",
        ),
      ]),
      ManifestModule::new("bounds.library", [
        ManifestFile::new(
          "library.dew", b"pub trait Marker {}\npub fn keep<t: Marker>(value: t) -> t {\n  value\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let consumer = analyzed.modules[0]
  assert_eq(consumer.inferred.diagnostics.length(), 1)
  match consumer.inferred.diagnostics[0] {
    UnsatisfiedTraitObligation(callable, _, trait_, _, _) => {
      let library = analyzed.frozen.interfaces[1]
      assert_eq(callable, library.callables_named("keep")[0].declaration)
      assert_eq(
        trait_,
        library.declaration_named("Marker", FrozenTraitDeclaration).unwrap(),
      )
    }
    _ => fail("expected imported generic bound diagnostic")
  }
}
