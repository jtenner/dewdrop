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
test "generic calls require local coherent trait evidence" {
  let accepted = collect_bytes(
    2721UL, b"trait Marker {}\nstruct Yes {}\nimpl Marker for Yes {}\nfn keep<t: Marker>(value: t) -> t {\n  value\n}\nfn accepted() -> Yes {\n  keep(Yes {})\n}\n",
  )
  let accepted_types = resolve_module_types(accepted)
  let accepted_names = resolve_module_names(accepted)
  let accepted_inferred = infer_module_bodies(
    accepted, accepted_types, accepted_names,
  )
  assert_eq(accepted_inferred.diagnostics.length(), 0)

  let rejected = collect_bytes(
    2722UL, b"trait Marker {}\nstruct No {}\nfn keep<t: Marker>(value: t) -> t {\n  value\n}\nfn rejected() -> No {\n  keep(No {})\n}\n",
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
    2723UL, b"trait Convert<t> {}\nstruct Item {}\nimpl Convert<I32> for Item {}\nfn accepts<t: Convert<I32>>(value: t) -> t {\n  value\n}\nfn rejects<t: Convert<I64>>(value: t) -> t {\n  value\n}\nfn run_ok() -> Item {\n  accepts(Item {})\n}\nfn run_bad() -> Item {\n  rejects(Item {})\n}\n",
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
test "imported generic calls retain and enforce bound evidence" {
  let program = collect_program_manifest(
    2724UL,
    ProgramManifest::new([
      ManifestModule::new("bounds.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open bounds.library\nstruct Yes {}\nstruct No {}\nimpl Marker for Yes {}\nfn accepted() -> Yes {\n  keep(Yes {})\n}\nfn rejected() -> No {\n  keep(No {})\n}\n",
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
