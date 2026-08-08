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
    match collected.declaration(implementation.declaration) {
      Some(TopLevelReference(declaration)) =>
        assert_eq(declaration.offset, 144UL)
      _ => fail("expected derived implementation declaration")
    }
    let derived_method = index.methods[implementation.methods.start]
    match collected.declaration(derived_method.declaration) {
      Some(MethodReference(declaration)) => assert_eq(declaration.offset, 144UL)
      _ => fail("expected derived method declaration")
    }
  }
}

///|
test "ordinary nominal collection creates no synthetic derive work" {
  let collected = collect_bytes(
    2702UL, b"struct Plain {\n  value: I32\n}\nenum Choice {\n  None\n  Some(I32)\n}\n",
  )
  assert_eq(collected.impls.length(), 0)
  assert_eq(collected.methods.length(), 0)
  assert_eq(collected.bodies.length(), 0)
}

///|
test "empty enums may derive equality without spurious flow diagnostics" {
  let program = collect_program_manifest(
    2703UL,
    ProgramManifest::new([
      ManifestModule::new("derive.empty", [
        ManifestFile::new(
          "empty.dew", b"enum Abyss {} derive(Eq)\npub fn main() -> I32 {\n  0\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(program.modules[0].diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
}

///|
test "derive Debug supplies ambient debug call evidence" {
  let program = collect_program_manifest(
    2704UL,
    ProgramManifest::new([
      ManifestModule::new("derive.debug", [
        ManifestFile::new(
          "debug.dew", b"struct Point {\n  value: I32\n} derive(Debug)\nfn run() -> Unit {\n  debug(Point {\n    value: 1\n  })\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
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
    DuplicateDerivedTrait("Eq", _, first_offset, duplicate_offset) => {
      assert_eq(first_offset, 61UL)
      assert_eq(duplicate_offset, 65UL)
    }
    _ => fail("expected duplicate derived trait")
  }
  match collected.diagnostics[2] {
    GenericDeriveRequiresBounds("Eq", _, _) => ()
    _ => fail("expected generic derive bound diagnostic")
  }
}
