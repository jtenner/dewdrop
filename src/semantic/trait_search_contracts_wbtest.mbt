///|
test "trait search diagnostics survive binary encoding and family rebasing" {
  let diagnostic = TraitObligationFailure(
    make_semantic_id(6021UL, 2),
    17,
    "CT-013 cyclic trait prerequisite",
    92UL,
  )
  let writer = @cache_binary.Writer::new(size_hint=128)
  ib_write_inference_diagnostic(writer, diagnostic)
  let reader = @cache_binary.Reader::new(
    writer.to_bytes(),
    context="trait search diagnostic",
  )
  assert_eq(ib_read_inference_diagnostic(reader, "diagnostic"), diagnostic)
  assert_eq(
    rebase_family_diagnostic(diagnostic, 5, 0, 10),
    TraitObligationFailure(
      make_semantic_id(6021UL, 2),
      22,
      "CT-013 cyclic trait prerequisite",
      102UL,
    ),
  )
}

///|
test "trait search limits and cycles have distinct exact errors" {
  let search = BodyTraitSearch::new()
  assert_eq(search.admit(0, 1, 2UL), Ok(()))
  search.steps = 65536
  assert_eq(search.admit(0, 1, 2UL), Err("CT-013 cyclic trait prerequisite"))
  assert_eq(
    search.admit(1, 0, 2UL),
    Err("CT-012 trait evidence search limit exceeded"),
  )
  assert_eq(search.active, [(0, 1, 2UL)])
  search.steps = 0
  for index in 1..<256 {
    assert_eq(search.admit(index, 1, 2UL), Ok(()))
  }
  assert_eq(
    search.admit(256, 1, 2UL),
    Err("CT-012 trait evidence search limit exceeded"),
  )
  assert_eq(search.active.length(), 256)
}

///|
test "trait type keys survive rollback and preserve logical identities" {
  let solver = root_contract_fixture()
  let search = BodyTraitSearch::new()
  let variable = solver.variable_types[0]
  let original = search.type_key(solver, variable)
  let i32 = solver.resolved_type(solver.resolved.primitive(I32Type))
  let concrete = search.type_key(solver, i32)
  let snapshot = solver.snapshot()
  assert_true(solver.unify(variable, i32, synthetic_type_origin(0, 0UL)))
  assert_eq(search.type_key(solver, variable), concrete)
  let local = solver.product_type([variable, i32])
  let local_key = search.type_key(solver, local)
  solver.rollback(snapshot)
  assert_eq(search.type_key(solver, variable), original)
  assert_eq(search.type_key(solver, i32), concrete)
  let replacement = solver.product_type([i32, i32])
  assert_eq(search.type_key(solver, replacement), local_key)
  let symbolic = solver.resolved.types.length()
  solver.resolved.types.push(GenericParameterType(make_semantic_id(80UL, 0)))
  let key = search.type_key(solver, solver.resolved_type(symbolic))
  solver.resolved.types[symbolic] = GenericParameterType(
    make_semantic_id(81UL, 0),
  )
  assert_true(search.type_key(solver, solver.resolved_type(symbolic)) != key)
}

///|
test "trait type keys check owned spans and structural cycles" {
  let solver = root_contract_fixture()
  let search = BodyTraitSearch::new()
  let root = solver.product_type([solver.error_type(), solver.variable_types[0]])
  assert_true(search.type_key(solver, root) is Ok(_))
  let span = match solver.types[root] {
    BodyProductType(span) => span
    _ => fail("expected product type")
  }
  solver.type_arguments[span.start + 1] = root
  assert_eq(
    search.type_key(solver, root),
    Err({ code: 211, module_id: 80UL, expected: 0, actual: root, detail: root, }),
  )
  solver.types[root] = BodyProductType({
    start: solver.type_arguments.length(),
    length: 1,
  })
  assert_eq(
    search.type_key(solver, root),
    Err({
      code: 101,
      module_id: 80UL,
      expected: solver.type_arguments.length(),
      actual: solver.type_arguments.length(),
      detail: 1,
    }),
  )
}

///|
test "method bounds keep sibling obligations across nested searches" {
  let collected = collect_bytes(
    6022UL, b"trait Mark {}\nstruct Box<t> {}\nimpl Mark for I32 {}\nimpl<t: Mark> Mark for Box<t> {}\nstruct Runner {}\nimpl Runner {\n  fn check<a: Mark, b: Mark>(self, left: a, right: b) -> Unit {}\n}\nfn run(runner: Runner, left: Box<I32>, right: Box<I32>) -> Unit {\n  runner.check(left, right)\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics, [])
}

///|
test "owner bounds preserve the method generic environment" {
  let collected = collect_bytes(
    6023UL, b"trait Mark {}\nstruct Box<t> {}\nimpl Mark for I32 {}\nimpl<t: Mark> Mark for Box<t> {}\nstruct Runner<t> {}\nimpl<t: Mark> Runner<t> {\n  fn check<a: Mark, b: Mark>(self, left: a, right: b) -> Unit {}\n}\nfn run(runner: Runner<Box<I32>>, left: Box<I32>, right: Box<I32>) -> Unit {\n  runner.check(left, right)\n}\nfn rejected(runner: Runner<Box<I32>>, left: Box<I32>, right: Box<Bool>) -> Unit {\n  runner.check(left, right)\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 1)
  match inferred.diagnostics[0] {
    NoMatchingMethod(name, expression, offset) => {
      assert_eq(collected.name(name), "check")
      assert_eq(collected.expressions[expression].offset(), offset)
      let body = collected.bodies[collected.bodies.length() - 1]
      assert_true(
        expression >= body.expressions.start &&
        expression - body.expressions.start < body.expressions.length,
      )
    }
    _ => fail("the missing Bool bound must remain an ordinary mismatch")
  }
}

///|
test "native trait inference accepts a prerequisite chain deeper than 64" {
  let mut nested = "I32"
  for _ in 0..<65 {
    nested = "Box<" + nested + ">"
  }
  let source = "trait Mark {}\nstruct Box<t> {}\nimpl Mark for I32 {}\nimpl<t: Mark> Mark for Box<t> {}\nfn need<t: Mark>(value: t) -> Unit {}\nfn run(value: " +
    nested +
    ") -> Unit {\n  need(value)\n}\n"
  let collected = collect_bytes(6020UL, source.to_bytes())
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 0)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics, [])
}

///|
test "native trait inference diagnoses cyclic prerequisites" {
  let collected = collect_bytes(
    6021UL, b"struct Node {}\ntrait Loop<t> {}\nimpl<t: Loop<Node>> Loop<t> for Node {}\nfn need<t: Loop<Node>>(value: t) -> Unit {}\nfn run(value: Node) -> Unit {\n  need(value)\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let mut cycles = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      TraitObligationFailure(_, expression, message, offset) => {
        assert_eq(message, "CT-013 cyclic trait prerequisite")
        assert_true(
          expression >= 0 && expression < collected.expressions.length(),
        )
        assert_eq(collected.expressions[expression].offset(), offset)
        cycles += 1
      }
      _ =>
        fail(
          "cycle was returned as ordinary missing evidence: " +
          @debug.to_string(diagnostic),
        )
    }
  }
  assert_eq(cycles, 1)
}
