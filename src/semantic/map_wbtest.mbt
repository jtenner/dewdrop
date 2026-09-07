///|
test "Map declares storage and ordinary Dew functions" {
  let module_id = standard_library_module_id(11)
  let collected = collect_program_files_with_frozen_standard_imports(
    module_id,
    standard_library_program_files(
      module_id,
      "std/map.dew",
      StandardLibrarySources::new([
        ManifestFile::new(
          "std/map.dew",
          @standard_sources.standard_map_source(),
        ),
      ]),
      false,
      false,
    ),
  )
  assert_eq(collected.diagnostics.length(), 0)
  assert_true(collected.lookup_type("Map") is Some(_))
  assert_true(collected.lookup_type("MapEntry") is Some(_))
  assert_true(collected.lookup_value("map_singleton") is Some(_))
  assert_true(collected.callables.length() > 0)
  for callable in collected.callables {
    assert_true(collected.body_of(callable.declaration) is Some(_))
  }
}

///|
test "Map calls use ordinary method and index lowering" {
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
  let lowering = plan_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics, [])
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics, [])
}

///|
test "Map remove and clear infer and lower without diagnostics" {
  let program = collect_program_manifest(
    2621UL,
    ProgramManifest::new([
      ManifestModule::new("fixture.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.map\npub fn run() -> Bool {\n  let values = Map::singleton(1, 10)\n  let removed = values.remove(1)\n  values.clear()\n  removed && values.length() == 0u32\n}\n",
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
test "Map rejects keys without Hash evidence" {
  let program = collect_program_manifest(
    2616UL,
    ProgramManifest::new([
      ManifestModule::new("fixture.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.map\nstruct Key {}\npub fn run() -> I32 {\n  let values = Map::singleton(Key::{}, 1)\n  values[Key::{}]\n}\n",
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

///|
test "Hash implementations require collision equality" {
  let program = collect_program_manifest(
    2617UL,
    ProgramManifest::new([
      ManifestModule::new("fixture.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.map\nstruct Key {}\nimpl Hash for Key {\n  fn hash(self) -> U64 {\n    0u64\n  }\n}\npub fn run() -> I32 {\n  let values = Map::singleton(Key::{}, 1)\n  values[Key::{}]\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let diagnostics = plan_program_wasmgc_link(analyzed, lowering, 0).diagnostics
  assert_eq(diagnostics.length(), 1)
  assert_true(
    diagnostics[0]
    is ProgramCompileTimeFailure(
      _,
      _,
      _,
      _,
      "CT-040 trait implementation has no required method",
      _
    ),
  )
}

///|
test "Hash implementations must return U64" {
  let program = collect_program_manifest(
    2618UL,
    ProgramManifest::new([
      ManifestModule::new("fixture.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.map\nstruct Key {}\nimpl Hash for Key {\n  fn hash(self) -> I32 {\n    0\n  }\n  fn hash_eq(self, right: Key) -> Bool {\n    true\n  }\n}\npub fn run() -> I32 {\n  let values = Map::singleton(Key::{}, 1)\n  values[Key::{}]\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let diagnostics = plan_program_wasmgc_link(analyzed, lowering, 0).diagnostics
  assert_eq(diagnostics.length(), 1)
  assert_true(
    diagnostics[0]
    is ProgramCompileTimeFailure(
      _,
      _,
      _,
      _,
      "CT-040 guarded implementation signature mismatch",
      _
    ),
  )
}
