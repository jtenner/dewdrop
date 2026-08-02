///|
test "Bool literal match emits valid WasmGC" {
  let program = @semantic.collect_program_manifest(
    24146UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"fn to_number(value: Bool) -> I32 {\n  match value {\n    true => 1\n    false => 0\n  }\n}\npub fn main() -> I32 {\n  to_number(true)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}

///|
test "scalar literal matches use carrier-typed scratch locals" {
  let program = @semantic.collect_program_manifest(
    24147UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"fn match_i32(value: I32) -> I32 {\n  match value {\n    7 => 1\n    _ => 0\n  }\n}\nfn match_i64(value: I64) -> I32 {\n  match value {\n    7i64 => 1\n    _ => 0\n  }\n}\nfn match_f32(value: F32) -> I32 {\n  match value {\n    7.5f32 => 1\n    _ => 0\n  }\n}\nfn match_f64(value: F64) -> I32 {\n  match value {\n    7.5 => 1\n    _ => 0\n  }\n}\npub fn main() -> I32 {\n  match_i32(7) + match_i64(7i64) + match_f32(7.5f32) + match_f64(7.5)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}
