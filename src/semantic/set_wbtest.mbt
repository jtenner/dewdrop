///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "Set declares storage and ordinary Dew functions" {
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
  assert_true(collected.lookup_type("Set") is Some(_))
  assert_true(collected.lookup_type("SetIter") is Some(_))
  assert_true(collected.callables.length() > 0)
  for callable in collected.callables {
    assert_true(collected.body_of(callable.declaration) is Some(_))
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "Set calls use ordinary method lowering" {
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
  let lowering = plan_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics, [])
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics, [])
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
  assert_eq(analyzed.modules[0].inferred.diagnostics, [])
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_true(link.diagnostics.length() > 0)
  for diagnostic in link.diagnostics {
    assert_true(
      diagnostic
      is ProgramCompileTimeFailure(
        _,
        _,
        _,
        _,
        "CT-021 static assertion failed: Map keys must implement Hash",
        _
      ),
    )
  }
}
