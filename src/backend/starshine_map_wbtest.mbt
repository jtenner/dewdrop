///|
test "maps emit collision-safe Hash and Eq calls" {
  let program = @semantic.collect_program_manifest(
    2613UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.map\npub fn run() -> I32 {\n  let values = Map::singleton(1, 10)\n  values.insert(17, 20)\n  values[17]\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics.length(), 0)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_true(
    link.type_lookup.get(@semantic.standard_map_type_declaration()) is Some(_),
  )
  match emit_starshine_program_module(lowering, link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => assert_eq(error, UnsupportedBuiltin(b"expected-debug"))
  }
}

///|
test "map remove and clear emit a valid body" {
  let program = @semantic.collect_program_manifest(
    2618UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.map\npub fn run() -> Bool {\n  let values = Map::singleton(1, 10)\n  values.insert(17, 20)\n  let removed = values.remove(1)\n  values.clear()\n  removed\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics.length(), 0)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  match emit_starshine_program_module(lowering, link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => assert_eq(error, UnsupportedBuiltin(b"expected-debug"))
  }
}

///|
test "map growth emits a valid Unit-returning body" {
  let program = @semantic.collect_program_manifest(
    2616UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.map\npub fn run() -> Unit {\n  let values = Map::singleton(0u32, 0)\n  values.insert(1u32, 1)\n  values.insert(2u32, 2)\n  values.insert(3u32, 3)\n  values.insert(4u32, 4)\n  values.insert(5u32, 5)\n  values.insert(6u32, 6)\n  values.insert(7u32, 7)\n  values.insert(8u32, 8)\n  values.insert(9u32, 9)\n  values.insert(10u32, 10)\n  values.insert(11u32, 11)\n  values.insert(12u32, 12)\n  values.insert(13u32, 13)\n  values.insert(14u32, 14)\n  values.insert(15u32, 15)\n  values.insert(16u32, 16)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics.length(), 0)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  match emit_starshine_program_module(lowering, link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => assert_eq(error, UnsupportedBuiltin(b"expected-debug"))
  }
}
