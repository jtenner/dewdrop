///|
fn backend_numeric_constant_source() -> Bytes {
  b"pub fn signed8() -> I8 {\n  127i8\n}\npub fn signed16() -> I16 {\n  32767i16\n}\npub fn unsigned8() -> U8 {\n  255u8\n}\npub fn unsigned16() -> U16 {\n  65535u16\n}\npub fn signed64() -> I64 {\n  -9223372036854775808i64\n}\npub fn unsigned64() -> U64 {\n  18446744073709551615u64\n}\npub fn float32() -> F32 {\n  1.5f32\n}\npub fn float64() -> F64 {\n  2.25f64\n}\npub fn negative_zero32() -> F32 {\n  -0.0f32\n}\npub fn negative_zero64() -> F64 {\n  -0.0f64\n}\npub fn infinity32() -> F32 {\n  1.0e99f32\n}\npub fn infinity64() -> F64 {\n  1.0e999f64\n}\npub fn text() -> String {\n  \"hello λ\"\n}\npub fn bytes() -> Bytes {\n  b\"utf8 \\x00\\xFF\"\n}\n"
}

///|
fn backend_numeric_constant_pipeline() -> (
  @semantic.PlannedModuleLowering,
  @semantic.PlannedModuleWasmGCFragments,
) {
  let collected = @semantic.collect_program_bytes(
    2500UL,
    backend_numeric_constant_source(),
  )
  let resolved = @semantic.resolve_module_types(collected)
  let names = @semantic.resolve_module_names(collected)
  let inferred = @semantic.infer_module_bodies(collected, resolved, names)
  let layouts = @semantic.plan_module_type_layouts(collected, resolved)
  let functions = @semantic.plan_module_functions(collected, resolved)
  let initialization = @semantic.plan_module_initialization(
    collected,
    inferred.module_values,
  )
  let flows = @semantic.analyze_module_flows(collected, resolved, inferred)
  let lowering = @semantic.plan_module_lowering(
    collected, resolved, layouts, initialization, functions, names, inferred, flows,
  )
  let fragments = @semantic.plan_module_wasmgc_fragments(resolved, lowering)
  (lowering, fragments)
}

///|
test "all numeric constant widths emit valid Starshine modules" {
  let (lowering, fragments) = backend_numeric_constant_pipeline()
  let module_ = emit_starshine_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_binary(lowering, fragments) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to encode numeric constant module")
  }
}

///|
test "all numeric constant widths survive program linking" {
  let program = @semantic.collect_program_manifest(
    2510UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew",
          backend_numeric_constant_source(),
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_program_binary(lowering, link) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to encode linked numeric constant module")
  }
}
