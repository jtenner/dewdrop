///|
test "sets emit collision-safe insert remove and clear" {
  let program = @semantic.collect_program_manifest(
    2615UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.set\npub fn run() -> Bool {\n  let values = Set::singleton(1)\n  values.insert(17)\n  values.remove(1)\n  values.contains(17)\n}\n",
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
  assert_eq(link.diagnostics, [])
  match emit_starshine_program_module(lowering, link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => fail(@debug.to_string(error))
  }
}

///|
test "set growth emits a valid body and clear" {
  let program = @semantic.collect_program_manifest(
    2617UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.set\npub fn run() -> Unit {\n  let values = Set::singleton(0u32)\n  values.insert(1u32)\n  values.insert(2u32)\n  values.insert(3u32)\n  values.insert(4u32)\n  values.insert(5u32)\n  values.insert(6u32)\n  values.insert(7u32)\n  values.insert(8u32)\n  values.insert(9u32)\n  values.insert(10u32)\n  values.insert(11u32)\n  values.insert(12u32)\n  values.insert(13u32)\n  values.insert(14u32)\n  values.insert(15u32)\n  values.insert(16u32)\n  values.clear()\n}\n",
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
  assert_eq(link.diagnostics, [])
  match emit_starshine_program_module(lowering, link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => fail(@debug.to_string(error))
  }
}
