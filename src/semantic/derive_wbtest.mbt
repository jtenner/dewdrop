///|
test "derive Eq synthesizes coherent Eq and Ne implementations" {
  let (collected, _, index) = impl_test_module(
    2700UL, b"trait Eq {\n  fn eq(self, right: Self) -> Bool\n}\ntrait Ne {\n  fn ne(self, right: Self) -> Bool\n}\nstruct Pair {\n  left: I32\n  right: I32\n} derive(Eq)\n",
  )
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(index.diagnostics.length(), 0)
  assert_eq(index.implementations.length(), 2)
  assert_eq(index.methods.length(), 2)
  for implementation in index.implementations {
    assert_true(implementation.valid)
    assert_true(implementation.coherent)
    assert_eq(
      implementation.target_head,
      NominalImplTargetHead(collected.lookup_type("Pair").unwrap()),
    )
  }
}

///|
test "derive diagnostics reject unknown duplicate and unbounded generic requests" {
  let collected = collect_bytes(
    2701UL, b"struct Unknown {} derive(Display)\nstruct Duplicate {} derive(Eq, Eq)\nstruct Generic<t> {\n  value: t\n} derive(Eq)\n",
  )
  assert_eq(collected.diagnostics.length(), 3)
  match collected.diagnostics[0] {
    UnknownDerivedTrait("Display", _, _) => ()
    _ => fail("expected unknown derived trait")
  }
  match collected.diagnostics[1] {
    UnknownDerivedTrait("duplicate Eq", _, _) => ()
    _ => fail("expected duplicate derived trait")
  }
  match collected.diagnostics[2] {
    GenericDeriveRequiresBounds("Eq", _, _) => ()
    _ => fail("expected generic derive bound diagnostic")
  }
}
