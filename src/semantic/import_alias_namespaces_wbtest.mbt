///|
test "import aliases resolve types traits constructors patterns and static implementations" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"import app.library as @api\nstruct Local {\n  value: I32\n}\nimpl @api.Measure for Local {\n  fn measure(self) -> I32 {\n    self.value\n  }\n}\nfn measured<t: @api.Measure>(value: t) -> I32 {\n  value.measure()\n}\npub fn run(input: @api.Box<I32>) -> I32 {\n  let made = @api.Box::make(input.value)\n  let tuple = @api.Message::Number(made.value)\n  let tuple_value = match tuple {\n    @api.Message::Number(value) => value\n    @api.Message::Idle => 0\n    @api.Message::Data {\n      value\n    } => value\n  }\n  let structured = @api.Message::Data::{\n    value: tuple_value\n  }\n  let structured_value = match structured {\n    @api.Message::Data {\n      value\n    } => value\n    @api.Message::Idle => 0\n    @api.Message::Number(value) => value\n  }\n  let idle_value = match @api.Message::Idle {\n    @api.Message::Idle => 1\n    @api.Message::Number(value) => value\n    @api.Message::Data {\n      value\n    } => value\n  }\n  let local = Local::{\n    value: structured_value + idle_value\n  }\n  measured(local) + @api.Measure::measure(local) - local.value\n}\n",
    b"pub trait Measure {\n  fn measure(self) -> I32\n}\npub struct Box<t> {\n  value: t\n}\nimpl Box<I32> {\n  fn make(value: I32) -> Box<I32> {\n    Box::{\n      value: value\n    }\n  }\n}\npub enum Message {\n  Idle\n  Number(I32)\n  Data {\n    value: I32\n  }\n}\n",
  )
  assert_eq(frozen.import_diagnostics.length(), 0)
  assert_eq(frozen.interfaces[0].resolved_types.diagnostics, [])
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.impl_index.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  assert_eq(program.modules[0].diagnostics, [])
}

///|
test "default import aliases qualify types and patterns" {
  let (_, frozen, _, names, inferred) = imported_semantic_program(
    b"import app.library\npub fn read(value: @library.Message) -> I32 {\n  match value {\n    @library.Message::Value(item) => item\n  }\n}\n",
    b"pub enum Message {\n  Value(I32)\n}\n",
  )
  assert_eq(frozen.import_diagnostics.length(), 0)
  assert_eq(frozen.interfaces[0].resolved_types.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
}

///|
test "import aliases resolve transparent aliases and their static methods" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"import app.library as @api\npub fn run() -> @api.Counter {\n  @api.Counter::empty().add(2u64)\n}\n",
    b"pub type Counter = U64\nimpl Counter {\n  fn empty() -> Counter {\n    0u64\n  }\n  fn add(self, value: U64) -> Counter {\n    self + value\n  }\n}\n",
  )
  assert_eq(frozen.import_diagnostics.length(), 0)
  assert_eq(frozen.interfaces[0].resolved_types.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let collected = program.modules[0]
  let body = collected.body_of(collected.lookup_value("run").unwrap()).unwrap()
  assert_eq(body_calls(collected, body).length(), 2)
}

///|
test "exact import aliases disambiguate equal type and constructor names" {
  let program = collect_program_manifest(
    1890UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"import app.first as @first\nimport app.second as @second\npub fn first(value: @first.Item) -> I32 {\n  match @first.Message::Value(value.value) {\n    @first.Message::Value(result) => result\n  }\n}\npub fn second(value: @second.Item) -> I32 {\n  match @second.Message::Value(value.value) {\n    @second.Message::Value(result) => result\n  }\n}\n",
        ),
      ]),
      ManifestModule::new("app.first", [
        ManifestFile::new(
          "first.dew", b"pub struct Item {\n  value: I32\n}\npub enum Message {\n  Value(I32)\n}\n",
        ),
      ]),
      ManifestModule::new("app.second", [
        ManifestFile::new(
          "second.dew", b"pub struct Item {\n  value: I32\n}\npub enum Message {\n  Value(I32)\n}\n",
        ),
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
  assert_eq(frozen.import_diagnostics.length(), 0)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(
    resolved.types[resolved.parameter_types[0]],
    NominalType(frozen.interfaces[1].declarations[0].declaration),
  )
  assert_eq(inferred.diagnostics, [])
}

///|
test "unknown members in alias-qualified type and trait namespaces diagnose" {
  let (program, frozen, _, _, _) = imported_semantic_program(
    b"import app.library as @api\nfn missing_type(value: @api.Missing) -> Unit {\n}\nfn missing_trait<t: @api.Absent>(value: t) -> Unit {\n}\n",
    b"pub struct Present {}\npub trait Available {\n  fn available(self) -> Unit\n}\n",
  )
  let diagnostics = frozen.interfaces[0].resolved_types.diagnostics
  assert_eq(diagnostics.length(), 2)
  let mut unknown_type = false
  let mut unknown_trait = false
  for diagnostic in diagnostics {
    match diagnostic {
      UnknownType(name, _, _) if program.modules[0].name(name) == "Missing" =>
        unknown_type = true
      UnknownTrait(name, _, _) if program.modules[0].name(name) == "Absent" =>
        unknown_trait = true
      _ => ()
    }
  }
  assert_true(unknown_type)
  assert_true(unknown_trait)
}

///|
test "unknown import aliases in type and pattern namespaces diagnose" {
  let (_, frozen, _, names, _) = imported_semantic_program(
    b"import app.library as @api\nfn missing_type(value: @missing.Item) -> Unit {\n}\nfn missing_pattern(value: @api.Message) -> I32 {\n  match value {\n    @missing.Message::Value(item) => item\n  }\n}\n",
    b"pub struct Item {}\npub enum Message {\n  Value(I32)\n}\n",
  )
  assert_eq(frozen.interfaces[0].resolved_types.diagnostics.length(), 1)
  match frozen.interfaces[0].resolved_types.diagnostics[0] {
    UnknownType(_, _, _) => ()
    _ => fail("expected unknown alias-qualified type diagnostic")
  }
  let mut alias_diagnostic = false
  for diagnostic in names.diagnostics {
    if diagnostic is UnknownPatternImportAlias(_, _, _) {
      alias_diagnostic = true
    }
  }
  assert_true(alias_diagnostic)
}
