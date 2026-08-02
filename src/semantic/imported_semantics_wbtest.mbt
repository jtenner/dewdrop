///|
fn imported_semantic_program(
  consumer : Bytes,
  library : Bytes,
) -> (
  CollectedProgram,
  FrozenProgramInterfaces,
  ResolvedModuleImports,
  ResolvedModuleNames,
  InferredModuleBodies,
) {
  let program = collect_program_manifest(
    1800UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new("consumer.dew", consumer),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new("library.dew", library),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  let collected = program.modules[0]
  let resolved = frozen.interfaces[0].resolved_types
  let scope = frozen.import_scopes[0]
  let imports = resolve_module_imports(resolved, scope)
  let names = resolve_module_names_with_imports(collected, scope)
  let inferred = infer_module_bodies_with_imports(
    collected, resolved, imports, names,
  )
  (program, frozen, imports, names, inferred)
}

///|
test "imported generic function calls select external declaration evidence" {
  let (program, frozen, imports, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn run() -> I32 {\n  identity(7)\n}\n", b"pub fn identity<t>(value: t) -> t {\n  value\n}\n",
  )
  assert_eq(frozen.import_diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let collected = program.modules[0]
  let body = collected.body_of(collected.lookup_value("run").unwrap()).unwrap()
  let calls = body_calls(collected, body)
  assert_eq(calls.length(), 1)
  let external = frozen.interfaces[1].callables_named("identity")[0].declaration
  assert_true(imports.callable(external) is Some(_))
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, external)
      assert_eq(arguments.length, 1)
      assert_call_primitive(
        inferred,
        frozen.interfaces[0].resolved_types,
        inferred.call_type_arguments[arguments.start],
        I32Type,
      )
    }
    _ => fail("expected selected imported generic call")
  }
  assert_call_primitive(
    inferred,
    frozen.interfaces[0].resolved_types,
    inferred.expression_types[calls[0]],
    I32Type,
  )
}

///|
test "imported enum patterns retain external variant IDs" {
  let (_, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn read(value: OptionI32) -> I32 {\n  match value {\n    OptionI32::None => 0\n    OptionI32::Some(item) => item\n  }\n}\n",
    b"pub enum OptionI32 {\n  None\n  Some(I32)\n}\n",
  )
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let variants = frozen.interfaces[1].variants
  let mut saw_none = false
  let mut saw_some = false
  for selected in inferred.pattern_constructors {
    match selected {
      VariantInferredPatternConstructor(variant, _) =>
        if variant == variants[0].variant {
          saw_none = true
        } else if variant == variants[1].variant {
          saw_some = true
        }
      _ => ()
    }
  }
  assert_true(saw_none)
  assert_true(saw_some)
}

///|
test "imported enum construction retains external variant IDs" {
  let (_, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn idle() -> Message {\n  Message::Idle\n}\npub fn number(value: I32) -> Message {\n  Message::Number(value)\n}\npub fn move(x: I32, y: I32) -> Message {\n  Message::Move {\n    y: y\n    x: x\n  }\n}\n",
    b"pub enum Message {\n  Idle\n  Number(I32)\n  Move {\n    x: I32\n    y: I32\n  }\n}\n",
  )
  assert_eq(frozen.interfaces[0].resolved_types.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let variants = frozen.interfaces[1].variants
  let mut saw_idle = false
  let mut saw_number = false
  let mut saw_move = false
  for selection in inferred.expression_selections {
    match selection {
      UnitVariantValueSelection(variant, _) if variant == variants[0].variant =>
        saw_idle = true
      VariantConstructionSelection(variant, _) if variant == variants[1].variant =>
        saw_number = true
      VariantConstructionSelection(variant, _) if variant == variants[2].variant =>
        saw_move = true
      _ => ()
    }
  }
  assert_true(saw_idle)
  assert_true(saw_number)
  assert_true(saw_move)
}

///|
test "imported struct construction and field access retain external IDs" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn make(value: I32) -> Item {\n  Item {\n    value: value\n  }\n}\npub fn read(value: Item) -> I32 {\n  value.value\n}\n",
    b"pub struct Item {\n  value: I32\n}\n",
  )
  assert_eq(frozen.interfaces[0].resolved_types.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let item = frozen.interfaces[1]
    .declaration_named("Item", FrozenTypeDeclaration)
    .unwrap()
  let field = frozen.interfaces[1].fields[0].field
  let mut saw_construction = false
  let mut saw_field = false
  for selection in inferred.expression_selections {
    match selection {
      StructConstructionSelection(declaration, _) if declaration == item =>
        saw_construction = true
      FieldAccessSelection(selected) if selected == field => saw_field = true
      _ => ()
    }
  }
  assert_true(saw_construction)
  assert_true(saw_field)
  assert_eq(program.modules[0].diagnostics.length(), 0)
}

///|
test "imported nominal signatures unify with consumer signature types" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn run(value: Item) -> Item {\n  keep(value)\n}\n", b"pub struct Item {}\npub fn keep(value: Item) -> Item {\n  value\n}\n",
  )
  assert_eq(frozen.interfaces[0].resolved_types.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let collected = program.modules[0]
  let body = collected.body_of(collected.lookup_value("run").unwrap()).unwrap()
  let call = body_calls(collected, body)[0]
  let external = frozen.interfaces[1].callables_named("keep")[0].declaration
  match inferred.call_targets[call] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, external)
      assert_eq(arguments.length, 0)
    }
    _ => fail("expected selected imported nominal call")
  }
}

///|
test "imported transparent aliases normalize in consumer signatures" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn run(value: Count) -> Count {\n  keep(value)\n}\n",
    b"pub type Count = I32\npub fn keep(value: Count) -> Count {\n  value\n}\n",
  )
  assert_eq(frozen.interfaces[0].resolved_types.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let collected = program.modules[0]
  let run = collected.lookup_value("run").unwrap()
  let parameters = collected.parameters_of(run)
  assert_eq(
    frozen.interfaces[0].resolved_types.parameter_types[parameters.start],
    frozen.interfaces[0].resolved_types.primitive(I32Type),
  )
}

///|
test "imported generic aliases substitute consumer type arguments" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn run(value: Wrapped<I32>) -> Wrapped<I32> {\n  keep(value)\n}\n",
    b"pub struct Box<t> {}\npub type Wrapped<t> = Box<t>\npub fn keep<t>(value: Wrapped<t>) -> Wrapped<t> {\n  value\n}\n",
  )
  assert_eq(frozen.interfaces[0].resolved_types.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let collected = program.modules[0]
  let run = collected.lookup_value("run").unwrap()
  let parameters = collected.parameters_of(run)
  let parameter_type = frozen.interfaces[0].resolved_types.parameter_types[parameters.start]
  match frozen.interfaces[0].resolved_types.types[parameter_type] {
    AppliedType(base, arguments) => {
      let box_declaration = frozen.interfaces[1]
        .declaration_named("Box", FrozenTypeDeclaration)
        .unwrap()
      assert_eq(
        frozen.interfaces[0].resolved_types.types[base],
        NominalType(box_declaration),
      )
      assert_eq(arguments.length, 1)
      assert_eq(
        frozen.interfaces[0].resolved_types.type_arguments[arguments.start],
        frozen.interfaces[0].resolved_types.primitive(I32Type),
      )
    }
    _ => fail("expected substituted imported generic alias")
  }
}

///|
test "local value declarations shadow imported public values" {
  let (program, _, _, names, inferred) = imported_semantic_program(
    b"open app.library\nfn identity(value: I32) -> I32 {\n  value\n}\npub fn run() -> I32 {\n  identity(7)\n}\n",
    b"pub fn identity(value: Bool) -> Bool {\n  value\n}\n",
  )
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let collected = program.modules[0]
  let body = collected.body_of(collected.lookup_value("run").unwrap()).unwrap()
  let call = body_calls(collected, body)[0]
  match inferred.call_targets[call] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.lookup_value("identity").unwrap())
    _ => fail("expected selected local shadowing call")
  }
}

///|
test "imported implementation evidence is translated into consumer types" {
  let (_, frozen, imports, _, _) = imported_semantic_program(
    b"open app.library\npub fn run() -> I32 {\n  1\n}\n", b"pub struct Item {}\npub trait Mark {\n  fn mark(self) -> I32\n}\nimpl Mark for Item {\n  fn mark(self) -> I32 {\n    1\n  }\n}\n",
  )
  let mut selected : ResolvedImportedImplementation? = None
  for evidence in imports.implementations {
    if semantic_id_module(evidence.declaration) == 1801UL {
      selected = Some(evidence)
      break
    }
  }
  let evidence = selected.unwrap()
  let item = frozen.interfaces[1]
    .declaration_named("Item", FrozenTypeDeclaration)
    .unwrap()
  let mark = frozen.interfaces[1]
    .declaration_named("Mark", FrozenTraitDeclaration)
    .unwrap()
  assert_eq(
    frozen.interfaces[0].resolved_types.types[evidence.target_type],
    NominalType(item),
  )
  assert_eq(
    frozen.interfaces[0].resolved_types.types[evidence.trait_type],
    TraitType(mark),
  )
  let mut method_found = false
  for callable in frozen.interfaces[1].callables {
    match callable.kind {
      FrozenImplCallable(implementation) if implementation ==
        evidence.declaration => method_found = true
      _ => ()
    }
  }
  assert_true(method_found)
}

///|
test "implementation evidence over private local heads is not exported" {
  let program = collect_program_manifest(
    1842UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open app.library\npub fn run() -> I32 {\n  1\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"struct Hidden {}\npub trait Mark {\n  fn mark(self) -> I32\n}\nimpl Mark for Hidden {\n  fn mark(self) -> I32 {\n    7\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  assert_eq(frozen.interfaces[1].implementations.length(), 0)
  for callable in frozen.interfaces[1].callables {
    match callable.kind {
      FrozenImplCallable(_) => fail("private-head impl method leaked")
      _ => ()
    }
  }
}

///|
test "test-only implementation evidence is absent from imported scopes" {
  let program = collect_program_manifest(
    1840UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open app.library\npub fn run() -> I32 {\n  Item {}.mark()\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"pub struct Item {}\npub trait Mark {\n  fn mark(self) -> I32\n}\n",
        ),
        ManifestFile::new(
          "evidence_test.dew", b"impl Mark for Item {\n  fn mark(self) -> I32 {\n    7\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  assert_eq(frozen.interfaces[1].implementations.length(), 0)
  let imports = resolve_module_imports(
    frozen.interfaces[0].resolved_types,
    frozen.import_scopes[0],
  )
  for evidence in imports.implementations {
    assert_true(semantic_id_module(evidence.declaration) != 1841UL)
  }
}

///|
test "ambiguous imported values are diagnosed before inference" {
  let program = collect_program_manifest(
    1850UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open app.first\nopen app.second\npub fn run() -> I32 {\n  same()\n}\n",
        ),
      ]),
      ManifestModule::new("app.first", [
        ManifestFile::new("first.dew", b"pub fn same() -> I32 {\n  1\n}\n"),
      ]),
      ManifestModule::new("app.second", [
        ManifestFile::new("second.dew", b"pub fn same() -> I32 {\n  2\n}\n"),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  assert_eq(frozen.import_diagnostics.length(), 1)
  match frozen.import_diagnostics[0] {
    AmbiguousImportedValue(1850UL, "same", _, _) => ()
    _ => fail("expected ambiguous imported value diagnostic")
  }
  let names = resolve_module_names_with_imports(
    program.modules[0],
    frozen.import_scopes[0],
  )
  assert_eq(names.diagnostics.length(), 1)
  match names.diagnostics[0] {
    AmbiguousImportedValueName(_, _, _) => ()
    _ => fail("expected ambiguous imported body name")
  }
}

///|
test "qualified imports do not add unqualified values" {
  let program = collect_program_manifest(
    1880UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"import app.library\npub fn run() -> I32 {\n  answer()\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new("library.dew", b"pub fn answer() -> I32 {\n  42\n}\n"),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].names.diagnostics.length(), 1)
  match analyzed.modules[0].names.diagnostics[0] {
    UnknownValueName(name, _, _) =>
      assert_eq(program.modules[0].name(name), "answer")
    _ => fail("expected qualified import to hide unqualified values")
  }
}

///|
test "opens do not create module aliases" {
  let program = collect_program_manifest(
    1882UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open app.library\npub fn run() -> I32 {\n  @library.answer()\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new("library.dew", b"pub fn answer() -> I32 {\n  42\n}\n"),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].names.diagnostics.length(), 1)
  match analyzed.modules[0].names.diagnostics[0] {
    UnknownImportAlias(name, _, _) =>
      assert_eq(program.modules[0].name(name), "library")
    _ => fail("expected open import to omit an alias")
  }
}

///|
test "duplicate import aliases are diagnosed deterministically" {
  let program = collect_program_manifest(
    1885UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"import app.first as @same\nimport app.second as @same\npub fn run() -> I32 {\n  0\n}\n",
        ),
      ]),
      ManifestModule::new("app.first", [
        ManifestFile::new("first.dew", b"pub fn first() -> I32 {\n  1\n}\n"),
      ]),
      ManifestModule::new("app.second", [
        ManifestFile::new("second.dew", b"pub fn second() -> I32 {\n  2\n}\n"),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  assert_eq(frozen.import_diagnostics.length(), 1)
  match frozen.import_diagnostics[0] {
    DuplicateImportedAlias(1885UL, "same", _, _) => ()
    _ => fail("expected duplicate imported alias diagnostic")
  }
}

///|
test "explicit import aliases select external calls" {
  let program = collect_program_manifest(
    1890UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"import app.library as @lib\npub fn run() -> I32 {\n  @lib.answer()\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new("library.dew", b"pub fn answer() -> I32 {\n  42\n}\n"),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].names.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let collected = program.modules[0]
  let body = collected.body_of(collected.lookup_value("run").unwrap()).unwrap()
  let call = body_calls(collected, body)[0]
  let external = analyzed.frozen.interfaces[1].callables_named("answer")[0].declaration
  match analyzed.modules[0].inferred.call_targets[call] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, external)
    _ => fail("expected aliased imported call selection")
  }
}

///|
test "default import aliases use the final module segment" {
  let program = collect_program_manifest(
    1895UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"import app.library\npub fn run() -> I32 {\n  @library.answer()\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new("library.dew", b"pub fn answer() -> I32 {\n  42\n}\n"),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].names.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
}

///|
test "program semantic analysis retains manifest order and external calls" {
  let program = collect_program_manifest(
    1900UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open app.library\npub fn run() -> I32 {\n  answer()\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new("library.dew", b"pub fn answer() -> I32 {\n  42\n}\n"),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules.length(), program.modules.length())
  assert_eq(analyzed.modules[0].module_id, 1900UL)
  assert_eq(analyzed.modules[1].module_id, 1901UL)
  assert_eq(analyzed.modules[0].names.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let collected = program.modules[0]
  let body = collected.body_of(collected.lookup_value("run").unwrap()).unwrap()
  let call = body_calls(collected, body)[0]
  let external = analyzed.frozen.interfaces[1].callables_named("answer")[0].declaration
  match analyzed.modules[0].inferred.call_targets[call] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, external)
    _ => fail("expected program-level imported call selection")
  }
}

///|
test "independently imported implementation overlaps are incoherent" {
  let program = collect_program_manifest(
    1850UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open app.types\nopen app.left\nopen app.right\npub fn run() -> I32 {\n  1\n}\n",
        ),
      ]),
      ManifestModule::new("app.types", [
        ManifestFile::new(
          "types.dew", b"pub struct Pair<a, b> {}\npub trait Read {\n  fn read(self) -> I32\n}\n",
        ),
      ]),
      ManifestModule::new("app.left", [
        ManifestFile::new(
          "left.dew", b"open app.types\nimpl<a> Read for Pair<a, I32> {\n  fn read(self) -> I32 {\n    1\n  }\n}\n",
        ),
      ]),
      ManifestModule::new("app.right", [
        ManifestFile::new(
          "right.dew", b"open app.types\nimpl<b> Read for Pair<Bool, b> {\n  fn read(self) -> I32 {\n    2\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let index = analyzed.modules[0].inferred.impl_index
  let mut overlaps = 0
  for diagnostic in index.diagnostics {
    match diagnostic {
      OverlappingTraitImpl(_, _, _, _, _) => overlaps += 1
      _ => ()
    }
  }
  assert_eq(overlaps, 1)
  let mut coherent_imports = 0
  for implementation in index.implementations {
    let owner = semantic_id_module(implementation.declaration)
    if (owner == 1852UL || owner == 1853UL) && implementation.coherent {
      coherent_imports += 1
    }
  }
  assert_eq(coherent_imports, 0)
}
