///|
test "imported function values retain signatures after private callables" {
  for consumer in [
    b"open app.library\npub fn factory() -> fn(I64) -> I64 {\n  read\n}\n",
    b"import app.library as @lib\npub fn run() -> I64 {\n  @lib.read(42i64)\n}\n",
  ] {
    let (program, frozen, imports, names, inferred) = imported_semantic_program(
      consumer,
      b"fn hidden(value: I32) -> I32 {\n  value\n}\npub fn read(value: I64) -> I64 {\n  value\n}\n",
    )
    assert_eq(frozen.import_diagnostics.length(), 0)
    assert_eq(names.diagnostics.length(), 0)
    assert_eq(inferred.diagnostics, [])
    let source = frozen.interfaces[1].callables_named("read")[0]
    let imported = imports.callable(source.declaration).unwrap()
    assert_eq(
      imported.declaration,
      program.modules[1].lookup_value("read").unwrap(),
    )
    let resolved = frozen.interfaces[0].resolved_types
    match resolved.types[imported.function_type] {
      FunctionType(parameters, result) => {
        assert_eq(parameters.length, 1)
        assert_eq(
          resolved.types[resolved.type_arguments[parameters.start]],
          PrimitiveType(I64Type),
        )
        assert_eq(resolved.types[result], PrimitiveType(I64Type))
      }
      _ => fail("expected the exported function's own signature")
    }
  }
}

///|
test "imported generic function values retain binders after private callables" {
  let (_, frozen, imports, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn factory() -> fn(I64) -> I64 {\n  read\n}\n",
    b"fn hidden(value: I32) -> I32 {\n  value\n}\npub fn read<t>(value: t) -> t {\n  value\n}\n",
  )
  assert_eq(frozen.import_diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics, [])
  let source = frozen.interfaces[1].callables_named("read")[0]
  let imported = imports.callable(source.declaration).unwrap()
  let resolved = frozen.interfaces[0].resolved_types
  match resolved.types[imported.function_type] {
    FunctionType(parameters, result) => {
      assert_eq(parameters.length, 1)
      assert_eq(resolved.type_arguments[parameters.start], result)
      match resolved.types[result] {
        GenericParameterType(parameter) => assert_eq(
          semantic_id_module(parameter),
          frozen.interfaces[1].module_id,
        )
        _ => fail("the imported function retains its own generic binder")
      }
    }
    _ => fail("expected an imported generic function signature")
  }
}

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
#skip("compiler integration case; run tools/test-integration-native.sh")
test "imported transparent aliases support qualified and instance methods" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn run() -> Counter {\n  Counter::empty().add(2u64)\n}\n",
    b"pub type Counter = U64\nimpl Counter {\n  fn empty() -> Counter {\n    0u64\n  }\n  fn add(self, value: U64) -> Counter {\n    self + value\n  }\n}\n",
  )
  assert_eq(frozen.import_diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let collected = program.modules[0]
  let body = collected.body_of(collected.lookup_value("run").unwrap()).unwrap()
  let calls = body_calls(collected, body)
  assert_eq(calls.length(), 2)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "imported method-local bounds select generic method evidence" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn run() -> Bool {\n  Filter::empty().add(7u64).contains(7u64)\n}\n",
    b"pub type Filter = U64\nimpl Filter {\n  fn empty() -> Filter {\n    0u64\n  }\n  fn add<t: Hash>(self, value: t) -> Filter {\n    self | value.hash()\n  }\n  fn contains<t: Hash>(self, value: t) -> Bool {\n    (self & value.hash()) == value.hash()\n  }\n}\n",
  )
  assert_eq(frozen.import_diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let collected = program.modules[0]
  let body = collected.body_of(collected.lookup_value("run").unwrap()).unwrap()
  assert_eq(body_calls(collected, body).length(), 3)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
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
#skip("compiler integration case; run tools/test-integration-native.sh")
test "imported explicit calls and trait method generics retain exact arguments" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn run(item: Item) -> I32 {\n  phantom::<Bool>() + item.keep::<I32>(41)\n}\n",
    b"pub fn phantom<t>() -> I32 {\n  1\n}\npub trait Keep {\n  fn keep<t>(self, value: t) -> t\n}\npub struct Item {}\nimpl Keep for Item {\n  fn keep<t>(self, value: t) -> t {\n    value\n  }\n}\n",
  )
  assert_eq(frozen.import_diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.impl_index.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let collected = program.modules[0]
  let body = collected.body_of(collected.lookup_value("run").unwrap()).unwrap()
  let calls = body_calls(collected, body)
  assert_eq(calls.length(), 2)
  let expected = [BoolType, I32Type]
  for index in 0..<calls.length() {
    match inferred.call_targets[calls[index]] {
      SelectedInferredCallTarget(_, arguments) => {
        assert_eq(arguments.length, 1)
        assert_call_primitive(
          inferred,
          frozen.interfaces[0].resolved_types,
          inferred.call_type_arguments[arguments.start],
          expected[index],
        )
      }
      _ => fail("expected imported explicit generic selection")
    }
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "bare imported enum patterns infer from the expected type" {
  let (_, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn read(value: OptionI32) -> I32 {\n  match value {\n    None => 0\n    Some(item) => item\n    Named {\n      value\n    } => value\n  }\n}\n",
    b"pub enum OptionI32 {\n  None\n  Some(I32)\n  Named {\n    value: I32\n  }\n}\n",
  )
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let variants = frozen.interfaces[1].variants
  let mut saw_none = false
  let mut saw_some = false
  let mut saw_named = false
  for selected in inferred.pattern_constructors {
    match selected {
      VariantInferredPatternConstructor(variant, _) =>
        if variant == variants[0].variant {
          saw_none = true
        } else if variant == variants[1].variant {
          saw_some = true
        } else if variant == variants[2].variant {
          saw_named = true
        }
      _ => ()
    }
  }
  assert_true(saw_none)
  assert_true(saw_some)
  assert_true(saw_named)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "imported enum construction retains external variant IDs" {
  let (_, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn idle() -> Message {\n  Message::Idle\n}\npub fn number(value: I32) -> Message {\n  Message::Number(value)\n}\npub fn move(x: I32, y: I32) -> Message {\n  Message::Move::{\n    y: y\n    x: x\n  }\n}\n",
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
#skip("compiler integration case; run tools/test-integration-native.sh")
test "imported struct construction and field access retain external IDs" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn make(value: I32) -> Item {\n  Item::{\n    value: value\n  }\n}\npub fn read(value: Item) -> I32 {\n  value.value\n}\n",
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
      FieldAccessSelection(selected, _) if selected == field => saw_field = true
      _ => ()
    }
  }
  assert_true(saw_construction)
  assert_true(saw_field)
  assert_eq(program.modules[0].diagnostics.length(), 0)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "imported mutable struct fields retain mutability" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn write(box: Box<I32>, value: I32) -> Unit {\n  box.value = value\n}\npub fn read(box: Box<I32>) -> I32 {\n  box.value\n}\n",
    b"pub struct Box<t> {\n  mut value: t\n}\n",
  )
  assert_eq(frozen.interfaces[0].resolved_types.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let field = frozen.interfaces[1].fields[0].field
  let mut selected = 0
  for selection in inferred.expression_selections {
    match selection {
      FieldAccessSelection(candidate, true) if candidate == field =>
        selected += 1
      _ => ()
    }
  }
  assert_eq(selected, 2)
  assert_eq(program.modules[0].diagnostics.length(), 0)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
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
#skip("compiler integration case; run tools/test-integration-native.sh")
test "imported named functions resolve as first-class references" {
  let (_, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn select() -> fn(I32) -> I32 {\n  increment\n}\n", b"pub fn increment(value: I32) -> I32 {\n  value + 1\n}\n",
  )
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let expected = frozen.interfaces[1].callables_named("increment")[0].declaration
  let mut saw_reference = false
  for selection in inferred.expression_selections {
    match selection {
      FunctionReferenceSelection(declaration, _) if declaration == expected =>
        saw_reference = true
      _ => ()
    }
  }
  assert_true(saw_reference)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "imported function signatures retain canonical structural types" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn run(value: fn(I32) -> I64) -> fn(I32) -> I64 {\n  keep(value)\n}\n",
    b"pub fn keep(value: fn(I32) -> I64) -> fn(I32) -> I64 {\n  value\n}\n",
  )
  assert_eq(frozen.interfaces[0].resolved_types.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let collected = program.modules[0]
  let run = collected.lookup_value("run").unwrap()
  let parameters = collected.parameters_of(run)
  let resolved = frozen.interfaces[0].resolved_types
  assert_eq(
    resolved.parameter_types[parameters.start],
    resolved.callable_return_types[0],
  )
  match resolved.types[resolved.callable_return_types[0]] {
    FunctionType(function_parameters, result) => {
      assert_eq(function_parameters.length, 1)
      assert_eq(
        resolved.type_arguments[function_parameters.start],
        resolved.primitive(I32Type),
      )
      assert_eq(result, resolved.primitive(I64Type))
    }
    _ => fail("expected imported function type")
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
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
#skip("compiler integration case; run tools/test-integration-native.sh")
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
#skip("compiler integration case; run tools/test-integration-native.sh")
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
#skip("compiler integration case; run tools/test-integration-native.sh")
test "imported aggregate field cursor preserves declaration grouping" {
  let (_, frozen, imports, _, _) = imported_semantic_program(
    b"open app.library\npub fn run() -> I32 {\n  1\n}\n", b"pub struct First {\n  first: I32\n}\nstruct Hidden {\n  hidden: I32\n}\npub fn divider() -> I32 {\n  0\n}\npub struct Second {\n  second: I64\n}\n",
  )
  let first = frozen.interfaces[1]
    .declaration_named("First", FrozenTypeDeclaration)
    .unwrap()
  let second = frozen.interfaces[1]
    .declaration_named("Second", FrozenTypeDeclaration)
    .unwrap()
  let first_fields = imports.fields_of(first)
  let second_fields = imports.fields_of(second)
  assert_eq(first_fields.length(), 1)
  assert_eq(first_fields[0].name, "first")
  assert_eq(second_fields.length(), 1)
  assert_eq(second_fields[0].name, "second")
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
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
#skip("compiler integration case; run tools/test-integration-native.sh")
test "imported generic derived evidence retains prerequisites and dispatch" {
  let (_, frozen, imports, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn same(left: Box<I32>, right: Box<I32>) -> Bool {\n  left == right && left.hash_eq(right)\n}\npub fn write(value: Box<I32>) -> Unit {\n  debug(value)\n}\n",
    b"pub struct Box<t> {\n  value: t\n} derive(Eq, Debug, Hash)\n",
  )
  assert_eq(frozen.import_diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let mut derived_implementations = 0
  for implementation in imports.implementations {
    if semantic_id_module(implementation.declaration) != 1801UL {
      continue
    }
    derived_implementations += 1
    assert_eq(implementation.generic_parameters.length, 1)
    let bounds = imports.generic_parameter_bounds[implementation.generic_bounds.start]
    assert_eq(bounds.length, 1)
  }
  assert_eq(derived_implementations, 4)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "private derived evidence is not exported" {
  let program = collect_program_manifest(
    1843UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open app.library\npub fn run() -> I32 {\n  1\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"struct Hidden<t> {\n  value: t\n} derive(Eq, Debug, Hash)\n",
        ),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  assert_eq(frozen.interfaces[1].implementations.length(), 0)
  for callable in frozen.interfaces[1].callables {
    match callable.kind {
      FrozenImplCallable(_) => fail("private derived method leaked")
      _ => ()
    }
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
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
#skip("compiler integration case; run tools/test-integration-native.sh")
test "test-only implementation evidence is absent from imported scopes" {
  let program = collect_program_manifest(
    1840UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open app.library\npub fn run() -> I32 {\n  Item::{}.mark()\n}\n",
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
#skip("compiler integration case; run tools/test-integration-native.sh")
test "imported callable collisions form expected-type overload sets" {
  let program = collect_program_manifest(
    1850UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open app.first\nopen app.second\npub fn select() -> fn(I32) -> I32 {\n  same\n}\n",
        ),
      ]),
      ManifestModule::new("app.first", [
        ManifestFile::new(
          "first.dew", b"pub fn same(value: I32) -> I32 {\n  value + 1\n}\n",
        ),
      ]),
      ManifestModule::new("app.second", [
        ManifestFile::new(
          "second.dew", b"pub fn same(value: I64) -> I64 {\n  value + 2i64\n}\n",
        ),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  assert_eq(frozen.import_diagnostics.length(), 0)
  let collected = program.modules[0]
  let resolved = frozen.interfaces[0].resolved_types
  let scope = frozen.import_scopes[0]
  let imports = resolve_module_imports(resolved, scope)
  let names = resolve_module_names_with_imports(collected, scope)
  assert_eq(names.diagnostics.length(), 0)
  let inferred = infer_module_bodies_with_imports(
    collected, resolved, imports, names,
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let expected = frozen.interfaces[1].callables_named("same")[0].declaration
  let mut selected = false
  for selection in inferred.expression_selections {
    match selection {
      FunctionReferenceSelection(declaration, _) if declaration == expected =>
        selected = true
      _ => ()
    }
  }
  assert_true(selected)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
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
#skip("compiler integration case; run tools/test-integration-native.sh")
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
#skip("compiler integration case; run tools/test-integration-native.sh")
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
#skip("compiler integration case; run tools/test-integration-native.sh")
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
#skip("compiler integration case; run tools/test-integration-native.sh")
test "public foreign library members are callable through import aliases" {
  let program = collect_program_manifest(
    1892UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"import app.imports as @raw\npub fn run() -> U32 {\n  @raw.answer()\n}\n",
        ),
      ]),
      ManifestModule::new("app.imports", [
        ManifestFile::new(
          "imports.dew", b"foreign impl \"provider\" as Provider {\n  pub fn answer() -> U32 = \"answer\"\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics.length(), 0)
  assert_eq(analyzed.frozen.interfaces[1].callables_named("answer").length(), 1)
  assert_eq(analyzed.modules[0].names.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
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
#skip("compiler integration case; run tools/test-integration-native.sh")
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
#skip("compiler integration case; run tools/test-integration-native.sh")
test "ordinary orphan implementations are rejected before export" {
  let program = collect_program_manifest(
    1850UL,
    ProgramManifest::new([
      ManifestModule::new("app.orphan", [
        ManifestFile::new(
          "orphan.dew", b"open app.traits\nopen app.types\nimpl<a> Read for Pair<a, I32> {\n  fn read(self) -> I32 {\n    1\n  }\n}\n",
        ),
      ]),
      ManifestModule::new("app.traits", [
        ManifestFile::new(
          "traits.dew", b"pub trait Read {\n  fn read(self) -> I32\n}\n",
        ),
      ]),
      ManifestModule::new("app.types", [
        ManifestFile::new("types.dew", b"pub struct Pair<a, b> {}\n"),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let index = analyzed.modules[0].inferred.impl_index
  assert_eq(index.diagnostics.length(), 1)
  match index.diagnostics[0] {
    OrphanTraitImpl(implementation, trait_, target, offset) => {
      assert_eq(implementation, program.modules[0].impls[0].declaration)
      assert_eq(semantic_id_module(trait_), 1851UL)
      match target {
        NominalImplTargetHead(declaration) =>
          assert_eq(semantic_id_module(declaration), 1852UL)
        _ => fail("expected imported nominal orphan target")
      }
      assert_eq(offset, 31UL)
    }
    _ => fail("expected ordinary orphan implementation diagnostic")
  }
  let orphan = index
    .implementation(program.modules[0].impls[0].declaration)
    .unwrap()
  assert_false(orphan.valid)
  assert_false(orphan.coherent)
  assert_eq(analyzed.frozen.interfaces[0].implementations.length(), 0)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "orphan ownership is independent of manifest module order" {
  let check = fn(reverse : Bool) raise {
    let orphan = ManifestModule::new("app.orphan", [
      ManifestFile::new(
        "orphan.dew", b"open app.traits\nopen app.types\nimpl Read for Item {\n  fn read(self) -> I32 {\n    1\n  }\n}\n",
      ),
    ])
    let traits = ManifestModule::new("app.traits", [
      ManifestFile::new(
        "traits.dew", b"pub trait Read {\n  fn read(self) -> I32\n}\n",
      ),
    ])
    let types = ManifestModule::new("app.types", [
      ManifestFile::new("types.dew", b"pub struct Item {}\n"),
    ])
    let program = collect_program_manifest(
      1855UL,
      ProgramManifest::new(
        if reverse {
          [types, traits, orphan]
        } else {
          [orphan, traits, types]
        },
      ),
    )
    let analyzed = analyze_program_semantics(program)
    let orphan_index = program.module_index("app.orphan").unwrap()
    let trait_index = program.module_index("app.traits").unwrap()
    let type_index = program.module_index("app.types").unwrap()
    let diagnostics = analyzed.modules[orphan_index].inferred.impl_index.diagnostics
    assert_eq(diagnostics.length(), 1)
    match diagnostics[0] {
      OrphanTraitImpl(_, trait_declaration, target, _) => {
        assert_eq(
          semantic_id_module(trait_declaration),
          program.modules[trait_index].module_id,
        )
        match target {
          NominalImplTargetHead(target_declaration) =>
            assert_eq(
              semantic_id_module(target_declaration),
              program.modules[type_index].module_id,
            )
          _ => fail("expected manifest-order nominal target")
        }
      }
      _ => fail("expected manifest-order orphan diagnostic")
    }
  }
  check(false)
  check(true)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "foreign orphan implementations remain module-local evidence" {
  let program = collect_program_manifest(
    1860UL,
    ProgramManifest::new([
      ManifestModule::new("app.foreign", [
        ManifestFile::new(
          "foreign.dew", b"open app.traits\nopen app.types\nforeign impl Read for Item {\n  fn read(self) -> I32 {\n    42\n  }\n}\npub fn run(value: Item) -> I32 {\n  value.read()\n}\n",
        ),
      ]),
      ManifestModule::new("app.traits", [
        ManifestFile::new(
          "traits.dew", b"pub trait Read {\n  fn read(self) -> I32\n}\n",
        ),
      ]),
      ManifestModule::new("app.types", [
        ManifestFile::new("types.dew", b"pub struct Item {}\n"),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.impl_index.diagnostics.length(), 0)
  assert_true(
    analyzed.modules[0].inferred.impl_index
    .implementation(program.modules[0].impls[0].declaration)
    .unwrap().coherent,
  )
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  assert_eq(analyzed.frozen.interfaces[0].implementations.length(), 0)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "trait or nominal package ownership permits ordinary implementations" {
  let program = collect_program_manifest(
    1870UL,
    ProgramManifest::new([
      ManifestModule::new("app.owner", [
        ManifestFile::new(
          "owner.dew", b"open app.library\npub trait LocalRead {\n  fn local_read(self) -> I32\n}\npub struct Local {}\nimpl LocalRead for Foreign {\n  fn local_read(self) -> I32 {\n    1\n  }\n}\nimpl ForeignRead for Local {\n  fn foreign_read(self) -> I32 {\n    2\n  }\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"pub trait ForeignRead {\n  fn foreign_read(self) -> I32\n}\npub struct Foreign {}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let index = analyzed.modules[0].inferred.impl_index
  assert_eq(index.diagnostics.length(), 0)
  let local_impl_start = program.modules[0].impls.length() - 2
  assert_true(
    index
    .implementation(program.modules[0].impls[local_impl_start].declaration)
    .unwrap().coherent,
  )
  assert_true(
    index
    .implementation(program.modules[0].impls[local_impl_start + 1].declaration)
    .unwrap().coherent,
  )
  assert_eq(analyzed.frozen.interfaces[0].implementations.length(), 2)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "compiler preamble traits remain standard-owned in ordinary modules" {
  let program = collect_program_manifest(
    1859UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open app.types\nimpl Eq for Item {\n  fn eq(self, right: Self) -> Bool {\n    true\n  }\n}\n",
        ),
      ]),
      ManifestModule::new("app.types", [
        ManifestFile::new("types.dew", b"pub struct Item {}\n"),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let diagnostics = analyzed.modules[0].inferred.impl_index.diagnostics
  assert_eq(diagnostics.length(), 1)
  match diagnostics[0] {
    OrphanTraitImpl(_, trait_declaration, target, _) => {
      assert_true(
        semantic_module_is_standard_package(
          semantic_id_module(trait_declaration),
        ),
      )
      match target {
        NominalImplTargetHead(target_declaration) =>
          assert_eq(
            semantic_id_module(target_declaration),
            program.modules[1].module_id,
          )
        _ => fail("expected imported nominal target")
      }
    }
    _ => fail("expected preamble-trait orphan diagnostic")
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "external traits on primitives require foreign implementation syntax" {
  let program = collect_program_manifest(
    1880UL,
    ProgramManifest::new([
      ManifestModule::new("app.primitive", [
        ManifestFile::new(
          "primitive.dew", b"open app.traits\nimpl Read for I32 {\n  fn read(self) -> I32 {\n    self\n  }\n}\nforeign impl Read for I64 {\n  fn read(self) -> I32 {\n    64\n  }\n}\n",
        ),
      ]),
      ManifestModule::new("app.traits", [
        ManifestFile::new(
          "traits.dew", b"pub trait Read {\n  fn read(self) -> I32\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let index = analyzed.modules[0].inferred.impl_index
  assert_eq(index.diagnostics.length(), 1)
  match index.diagnostics[0] {
    OrphanTraitImpl(_, _, PrimitiveImplTargetHead(I32Type), _) => ()
    _ => fail("expected primitive orphan implementation diagnostic")
  }
  let local_impl_start = program.modules[0].impls.length() - 2
  assert_false(
    index
    .implementation(program.modules[0].impls[local_impl_start].declaration)
    .unwrap().valid,
  )
  assert_true(
    index
    .implementation(program.modules[0].impls[local_impl_start + 1].declaration)
    .unwrap().coherent,
  )
  assert_eq(analyzed.frozen.interfaces[0].implementations.length(), 0)
}
