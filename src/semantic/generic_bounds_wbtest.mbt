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
