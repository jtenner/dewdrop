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
test "derived and handwritten implementations conflict through ordinary coherence" {
  let source = b"struct Item {} derive(Eq, Debug, Hash)\nimpl Eq for Item {\n  fn eq(self, right: Item) -> Bool {\n    true\n  }\n}\nimpl Ne for Item {\n  fn ne(self, right: Item) -> Bool {\n    false\n  }\n}\nimpl Debug for Item {\n  fn debug(self) -> Unit {}\n}\nimpl Hash for Item {\n  fn hash(self) -> U64 {\n    0u64\n  }\n  fn hash_eq(self, right: Item) -> Bool {\n    true\n  }\n}\n"
  let collected = collect_program_bytes(2707UL, source)
  let resolved = resolve_module_types(collected)
  let index = build_module_impl_index(collected, resolved)
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(resolved.diagnostics.length(), 0)
  let mut user_implementations = 0
  for implementation in index.implementations {
    if semantic_id_local(implementation.declaration) >=
      collected.preamble_declaration_count {
      user_implementations += 1
      assert_false(implementation.coherent)
    }
  }
  assert_eq(user_implementations, 8)
  assert_eq(index.diagnostics.length(), 4)
  for diagnostic in index.diagnostics {
    match diagnostic {
      OverlappingTraitImpl(_, first, second, _, offset) => {
        let derived_offset = collected.declaration_location(first).unwrap().offset
        assert_true(
          derived_offset == 22UL ||
          derived_offset == 26UL ||
          derived_offset == 33UL,
        )
        assert_eq(
          collected.declaration_location(second).unwrap().offset,
          offset,
        )
      }
      _ => fail("expected derived and handwritten overlap")
    }
  }
}

///|
test "derive requests remain primary when declared after handwritten evidence" {
  let collected = collect_program_bytes(
    2708UL, b"impl Debug for Item {\n  fn debug(self) -> Unit {}\n}\nstruct Item {} derive(Debug)\n",
  )
  let resolved = resolve_module_types(collected)
  let index = build_module_impl_index(collected, resolved)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(index.diagnostics.length(), 1)
  match index.diagnostics[0] {
    OverlappingTraitImpl(_, first, second, _, offset) => {
      assert_eq(collected.declaration_location(first).unwrap().offset, 0UL)
      assert_eq(collected.declaration_location(second).unwrap().offset, 74UL)
      assert_eq(offset, 74UL)
    }
    _ => fail("expected derive request overlap")
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
test "derive diagnostics reject unknown and duplicate requests while accepting generics" {
  let collected = collect_bytes(
    2701UL, b"struct Unknown {} derive(Display)\nstruct Duplicate {} derive(Eq, Eq)\nstruct Generic<t> {\n  value: t\n} derive(Eq)\n",
  )
  assert_eq(collected.diagnostics.length(), 2)
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
  assert_eq(collected.impls.length(), 4)
  let generic_eq = collected.impls[2]
  let parameters = collected.generic_parameters_of(generic_eq.declaration)
  assert_eq(parameters.length, 1)
  assert_eq(collected.generic_parameters[parameters.start].bounds.length, 1)
}

///|
test "derive Show freezes field prerequisites and conflicts ordinarily" {
  let program = collect_program_manifest(
    2709UL,
    ProgramManifest::new([
      ManifestModule::new("derive.show", [
        ManifestFile::new(
          "show.dew", b"open dew.std.show\nstruct Box<t> {\n  value: t\n} derive(Show)\nstruct Conflict {\n  value: I32\n} derive(Show)\nimpl Show for Conflict {\n  fn append_show(self, builder: StringBuilder) -> Unit {\n    show_append(builder, self.value)\n  }\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let module_ = program.modules[0]
  assert_eq(module_.diagnostics, [])
  assert_eq(module_.impls.length(), 3)
  let generic_parameters = module_.generic_parameters_of(
    module_.impls[0].declaration,
  )
  assert_eq(generic_parameters.length, 1)
  assert_eq(
    module_.generic_parameters[generic_parameters.start].bounds.length,
    1,
  )
  let analyzed = analyze_program_semantics(program)
  let diagnostics = analyzed.modules[0].inferred.impl_index.diagnostics
  assert_eq(diagnostics.length(), 1)
  match diagnostics[0] {
    OverlappingTraitImpl(_, _, _, _, _) => ()
    _ => fail("expected derived Show overlap")
  }
}

///|
test "derived field bounds support unconstrained owner parameters" {
  let program = collect_program_manifest(
    2706UL,
    ProgramManifest::new([
      ManifestModule::new("derive.selective", [
        ManifestFile::new(
          "selective.dew", b"struct Selected<a, b> {\n  value: a\n} derive(Eq)\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
}

///|
test "derive prerequisites follow fields and payloads" {
  let collected = collect_bytes(
    2705UL, b"struct Selected<a, b> {\n  value: a\n} derive(Eq, Debug, Hash)\nstruct Phantom<t> {} derive(Eq, Debug, Hash)\nenum Choice<a, b> {\n  Some(a)\n} derive(Eq, Debug, Hash)\nstruct Already<t: Eq + Debug + Hash> {\n  value: t\n} derive(Eq, Debug, Hash)\n",
  )
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(collected.impls.length(), 16)
  for implementation_index in 0..<4 {
    let parameters = collected.generic_parameters_of(
      collected.impls[implementation_index].declaration,
    )
    assert_eq(parameters.length, 2)
    assert_eq(collected.generic_parameters[parameters.start].bounds.length, 1)
    assert_eq(
      collected.generic_parameters[parameters.start + 1].bounds.length,
      0,
    )
  }
  for implementation_index in 4..<8 {
    let parameters = collected.generic_parameters_of(
      collected.impls[implementation_index].declaration,
    )
    assert_eq(parameters.length, 1)
    assert_eq(collected.generic_parameters[parameters.start].bounds.length, 0)
  }
  for implementation_index in 8..<12 {
    let parameters = collected.generic_parameters_of(
      collected.impls[implementation_index].declaration,
    )
    assert_eq(parameters.length, 2)
    assert_eq(collected.generic_parameters[parameters.start].bounds.length, 1)
    assert_eq(
      collected.generic_parameters[parameters.start + 1].bounds.length,
      0,
    )
  }
  for implementation_index in 12..<16 {
    let parameters = collected.generic_parameters_of(
      collected.impls[implementation_index].declaration,
    )
    assert_eq(parameters.length, 1)
    assert_eq(collected.generic_parameters[parameters.start].bounds.length, 3)
  }
}
