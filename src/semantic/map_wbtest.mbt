///|
test "map standard source has stable compiler-owned identities" {
  let module_id = standard_library_module_id(11)
  let collected = collect_program_files_with_frozen_standard_imports(
    module_id,
    standard_library_program_files(
      module_id,
      "std/map.dew",
      standard_map_source(),
      false,
      false,
    ),
  )
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(semantic_id_local(collected.lookup_type("Map").unwrap()), 0)
  assert_eq(
    semantic_id_local(collected.lookup_value("map_singleton").unwrap()),
    1,
  )
  assert_eq(collected.callables.length(), 18)
  assert_eq(semantic_id_local(collected.callables[7].declaration), 9)
  assert_eq(semantic_id_local(collected.callables[15].declaration), 18)
  assert_eq(semantic_id_local(collected.callables[16].declaration), 20)
  assert_eq(semantic_id_local(collected.callables[17].declaration), 21)
}

///|
test "compiler-owned Map selects Hash and Eq evidence" {
  let program = collect_program_manifest(
    2612UL,
    ProgramManifest::new([
      ManifestModule::new("fixture.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.map\npub fn run() -> I32 {\n  let values = Map::singleton(1, 10)\n  values.insert(17, 20)\n  values[17]\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let mut selected_hash = false
  let mut selected_eq = false
  for target in analyzed.modules[0].inferred.map_hash_targets {
    match target {
      SelectedInferredCallTarget(_, _) => selected_hash = true
      _ => ()
    }
  }
  for target in analyzed.modules[0].inferred.map_eq_targets {
    match target {
      SelectedInferredCallTarget(_, _) => selected_eq = true
      _ => ()
    }
  }
  assert_true(selected_hash)
  assert_true(selected_eq)
}

///|
test "Map rejects keys without Hash evidence" {
  let program = collect_program_manifest(
    2616UL,
    ProgramManifest::new([
      ManifestModule::new("fixture.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.map\nstruct Key {}\npub fn run() -> I32 {\n  let values = Map::singleton(Key {}, 1)\n  values[Key {}]\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let mut missing_hash = 0
  for diagnostic in analyzed.modules[0].inferred.diagnostics {
    match diagnostic {
      NoMatchingMethod(_, _, _) | AmbiguousMethod(_, _, _, _, _, _) =>
        missing_hash += 1
      _ => ()
    }
  }
  assert_true(missing_hash > 0)
}

///|
test "Hash implementations require collision equality" {
  let program = collect_program_manifest(
    2617UL,
    ProgramManifest::new([
      ManifestModule::new("fixture.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.map\nstruct Key {}\nimpl Hash for Key {\n  fn hash(self) -> U64 {\n    0u64\n  }\n}\npub fn run() -> I32 {\n  let values = Map::singleton(Key {}, 1)\n  values[Key {}]\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_true(analyzed.modules[0].inferred.diagnostics.length() > 0)
}

///|
test "Hash implementations must return U64" {
  let program = collect_program_manifest(
    2618UL,
    ProgramManifest::new([
      ManifestModule::new("fixture.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.map\nstruct Key {}\nimpl Hash for Key {\n  fn hash(self) -> I32 {\n    0\n  }\n  fn hash_eq(self, right: Key) -> Bool {\n    true\n  }\n}\npub fn run() -> I32 {\n  let values = Map::singleton(Key {}, 1)\n  values[Key {}]\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_true(analyzed.modules[0].inferred.diagnostics.length() > 0)
}
