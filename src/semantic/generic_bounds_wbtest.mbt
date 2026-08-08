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
