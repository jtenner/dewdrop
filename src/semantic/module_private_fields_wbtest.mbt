///|
fn private_field_library() -> Bytes {
  b"pub struct Box<t> {\n  private mut value: t\n  label: I32\n}\npub fn make(value: I32) -> Box<I32> {\n  Box::{\n    value: value\n    label: 7\n  }\n}\nimpl<t> Box<t> {\n  fn value(self) -> t {\n    self.value\n  }\n}\n"
}

///|
test "imported private fields reject reads writes construction and patterns" {
  for
    consumer in [
      b"open app.library\npub fn run(box: Box<I32>) -> I32 {\n  box.value\n}\n",
      b"open app.library\npub fn run(box: Box<I32>) -> Unit {\n  box.value = 3\n}\n",
      b"open app.library\npub fn run() -> Box<I32> {\n  Box::{\n    value: 3\n    label: 7\n  }\n}\n",
      b"open app.library\npub fn run() -> Box<I32> {\n  Box::{\n    label: 7\n  }\n}\n",
      b"open app.library\npub fn run() -> Box<I32> {\n  {\n    value: 3\n    label: 7\n  }\n}\n",
      b"import app.library as @lib\npub fn run(box: @lib.Box<I32>) -> I32 {\n  box.value\n}\n",
      b"open app.library\npub fn run(box: Box<I32>) -> I32 {\n  match box {\n    Box {\n      value: value\n      ...\n    } => value\n  }\n}\n",
    ] {
    let (program, frozen, _, names, inferred) = imported_semantic_program(
      consumer,
      private_field_library(),
    )
    assert_eq(program.diagnostics, [])
    for module_ in program.modules {
      assert_eq(module_.diagnostics, [])
    }
    assert_eq(frozen.import_diagnostics, [])
    assert_eq(names.diagnostics, [])
    assert_true(inferred.diagnostics.length() > 0)
    assert_true(frozen.interfaces[1].fields[0].module_private)
    assert_false(frozen.interfaces[1].fields[1].module_private)
  }
}

///|
test "imported public fields and private field getters remain available" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn run(box: Box<I32>) -> I32 {\n  box.label + box.value()\n}\n",
    private_field_library(),
  )
  assert_eq(program.diagnostics, [])
  assert_eq(frozen.import_diagnostics, [])
  assert_eq(names.diagnostics, [])
  assert_eq(inferred.diagnostics, [])
}

///|
test "frozen interface cache preserves private field source rules" {
  let (program, frozen, _, _, _) = imported_semantic_program(
    b"open app.library\npub fn run(box: Box<I32>) -> I32 {\n  box.value\n}\n",
    private_field_library(),
  )
  let decoded = deserialize_frozen_interfaces(
    serialize_frozen_interfaces(frozen.interfaces).unwrap(),
  ).unwrap()
  assert_eq(decoded, frozen.interfaces)
  assert_true(decoded[1].fields[0].module_private)
  let cached = decoded.map(fn(interface_) { Some(interface_) })
  let reloaded = freeze_program_interfaces_with_cached(program, cached)
  let collected = program.modules[0]
  let scope = reloaded.import_scopes[0]
  let resolved = reloaded.interfaces[0].resolved_types
  let imports = resolve_module_imports(resolved, scope)
  let names = resolve_module_names_with_imports(collected, scope)
  let inferred = infer_module_bodies_with_imports(
    collected, resolved, imports, names,
  )
  assert_true(inferred.diagnostics.length() > 0)
}

///|
test "private fields permit construction mutation and patterns in their module" {
  let (collected, resolved, names, inferred) = infer_test_module(
    28401UL, b"pub struct Box {\n  private mut value: I32\n}\nfn make(value: I32) -> Box {\n  Box::{\n    value: value\n  }\n}\nfn run(box: Box) -> I32 {\n  box.value = 4\n  match box {\n    Box {\n      value\n    } => value\n  }\n}\n",
  )
  assert_eq(collected.diagnostics, [])
  assert_eq(resolved.diagnostics, [])
  assert_eq(names.diagnostics, [])
  assert_eq(inferred.diagnostics, [])
}

///|
test "imported private fields can be ignored by a rest pattern" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn run(box: Box<I32>) -> I32 {\n  match box {\n    Box {\n      label\n      ...\n    } => label\n  }\n}\n",
    private_field_library(),
  )
  assert_eq(program.diagnostics, [])
  assert_eq(frozen.import_diagnostics, [])
  assert_eq(names.diagnostics, [])
  assert_eq(inferred.diagnostics, [])
}

///|
test "private fields remain accessible across files in one module" {
  let program = collect_program_manifest(
    28402UL,
    ProgramManifest::new([
      ManifestModule::new("app.local", [
        ManifestFile::new(
          "type.dew", b"pub struct Box {\n  private mut value: I32\n}\n",
        ),
        ManifestFile::new(
          "use.dew", b"fn run(box: Box) -> I32 {\n  box.value = 4\n  box.value\n}\n",
        ),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  let collected = program.modules[0]
  let resolved = frozen.interfaces[0].resolved_types
  let imports = resolve_module_imports(resolved, frozen.import_scopes[0])
  let names = resolve_module_names_with_imports(
    collected,
    frozen.import_scopes[0],
  )
  let inferred = infer_module_bodies_with_imports(
    collected, resolved, imports, names,
  )
  assert_eq(program.diagnostics, [])
  assert_eq(collected.diagnostics, [])
  assert_eq(resolved.diagnostics, [])
  assert_eq(names.diagnostics, [])
  assert_eq(inferred.diagnostics, [])
}

///|
test "field privacy changes declaration ABI fingerprints" {
  let (_, before, _, _, _) = imported_semantic_program(
    b"open app.library\npub fn run() -> I32 {\n  1\n}\n", b"pub struct Box {\n  value: I32\n}\n",
  )
  let (_, after, _, _, _) = imported_semantic_program(
    b"open app.library\npub fn run() -> I32 {\n  1\n}\n", b"pub struct Box {\n  private value: I32\n}\n",
  )
  assert_true(
    before.interfaces[1].declaration_abi_fingerprints !=
    after.interfaces[1].declaration_abi_fingerprints,
  )
}

///|
test "private fields support methods derives and structural compile time queries" {
  let program = collect_program_manifest(
    28403UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open app.library\nopen dew.std.types\nopen dew.std.array\npub fn fields() -> Array<String> {\n  field_names::<Record>()\n}\npub fn field_is_i32() -> Bool {\n  type_equal::<field_type<Record>(\"value\"), I32>()\n}\npub fn equal(left: Record, right: Record) -> Bool {\n  left == right\n}\npub fn read(value: Record) -> I32 {\n  value.value()\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"pub struct Record {\n  private value: I32\n} derive(Eq, Debug, Hash)\nimpl Record {\n  fn value(self) -> I32 {\n    self.value\n  }\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
    assert_eq(module_.inferred.impl_index.diagnostics, [])
  }
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics, [])
  let mut reflected = false
  let mut type_checked = false
  for expression in lowering.modules[0].expressions {
    match expression.kind {
      PlannedStringArrayConst(names) => {
        assert_eq(names, [b"value"])
        reflected = true
      }
      PlannedBoolConst(true) => type_checked = true
      _ => ()
    }
  }
  assert_true(reflected)
  assert_true(type_checked)
}
