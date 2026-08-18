///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "set standard source has stable compiler-owned identities" {
  let module_id = standard_library_module_id(12)
  let collected = collect_program_files_with_frozen_standard_imports(
    module_id,
    standard_library_program_files(
      module_id,
      "std/set.dew",
      StandardLibrarySources::new([
        ManifestFile::new(
          "std/set.dew",
          @standard_sources.standard_set_source(),
        ),
      ]),
      false,
      false,
    ),
  )
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(semantic_id_local(collected.lookup_type("Set").unwrap()), 0)
  assert_eq(semantic_id_local(collected.lookup_value("set_empty").unwrap()), 1)
  assert_eq(collected.callables.length(), 22)
  assert_eq(semantic_id_local(collected.callables[8].declaration), 10)
  assert_eq(semantic_id_local(collected.callables[15].declaration), 17)
  assert_eq(semantic_id_local(collected.callables[16].declaration), 19)
  assert_eq(semantic_id_local(collected.callables[18].declaration), 21)
  assert_eq(semantic_id_local(collected.callables[19].declaration), 23)
  assert_eq(semantic_id_local(collected.callables[21].declaration), 26)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "compiler-owned Set selects Hash evidence" {
  let program = collect_program_manifest(
    2614UL,
    ProgramManifest::new([
      ManifestModule::new("fixture.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.set\npub fn run() -> Bool {\n  let values = Set::singleton(1)\n  values.insert(17)\n  values.contains(17)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let mut selected_hash = false
  let mut selected_equality = false
  for target in analyzed.modules[0].inferred.map_hash_targets {
    match target {
      SelectedInferredCallTarget(_, _) => selected_hash = true
      _ => ()
    }
  }
  for target in analyzed.modules[0].inferred.map_eq_targets {
    match target {
      SelectedInferredCallTarget(_, _) => selected_equality = true
      _ => ()
    }
  }
  assert_true(selected_hash)
  assert_true(selected_equality)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "Set empty and every mutation method infer without diagnostics" {
  let program = collect_program_manifest(
    2619UL,
    ProgramManifest::new([
      ManifestModule::new("fixture.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.set\nfn empty_values() -> Set<I32> {\n  Set::empty()\n}\npub fn run() -> Bool {\n  let values = empty_values()\n  values.is_empty()\n  values.insert(1)\n  values.contains(1)\n  values.remove(1)\n  values.clear()\n  values.length() == 0u32\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics.length(), 0)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "Set rejects keys without Hash evidence" {
  let program = collect_program_manifest(
    2620UL,
    ProgramManifest::new([
      ManifestModule::new("fixture.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.set\nstruct Key {}\npub fn run() -> Bool {\n  let values = Set::singleton(Key::{})\n  values.contains(Key::{})\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_true(analyzed.modules[0].inferred.diagnostics.length() > 0)
}
