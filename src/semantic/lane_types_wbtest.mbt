///|
test "all typed packed lane primitives resolve as distinct types" {
  let collected = collect_program_bytes(
    2999UL, b"pub fn keep_i8x4(value: I8x4) -> I8x4 {\n  value\n}\npub fn keep_u8x4(value: U8x4) -> U8x4 {\n  value\n}\npub fn keep_i16x2(value: I16x2) -> I16x2 {\n  value\n}\npub fn keep_u16x2(value: U16x2) -> U16x2 {\n  value\n}\npub fn keep_i8x8(value: I8x8) -> I8x8 {\n  value\n}\npub fn keep_u8x8(value: U8x8) -> U8x8 {\n  value\n}\npub fn keep_i16x4(value: I16x4) -> I16x4 {\n  value\n}\npub fn keep_u16x4(value: U16x4) -> U16x4 {\n  value\n}\npub fn keep_i32x2(value: I32x2) -> I32x2 {\n  value\n}\npub fn keep_u32x2(value: U32x2) -> U32x2 {\n  value\n}\npub fn keep_i8x16(value: I8x16) -> I8x16 {\n  value\n}\npub fn keep_u8x16(value: U8x16) -> U8x16 {\n  value\n}\npub fn keep_i16x8(value: I16x8) -> I16x8 {\n  value\n}\npub fn keep_u16x8(value: U16x8) -> U16x8 {\n  value\n}\npub fn keep_i32x4(value: I32x4) -> I32x4 {\n  value\n}\npub fn keep_u32x4(value: U32x4) -> U32x4 {\n  value\n}\npub fn keep_i64x2(value: I64x2) -> I64x2 {\n  value\n}\npub fn keep_u64x2(value: U64x2) -> U64x2 {\n  value\n}\npub fn keep_f32x4(value: F32x4) -> F32x4 {\n  value\n}\npub fn keep_f64x2(value: F64x2) -> F64x2 {\n  value\n}\n",
  )
  let resolved = resolve_module_types(collected)
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(collected.preamble_declaration_count, 1311)
}

///|
test "String literals require strict UTF-8 while Bytes remain arbitrary" {
  let invalid_string = collect_program_bytes(
    2997UL, b"pub fn invalid() -> String {\n  \"\\xED\\xA0\\x80\"\n}\n",
  )
  assert_eq(invalid_string.diagnostics.length(), 1)
  match invalid_string.diagnostics[0] {
    InvalidUtf8StringLiteral(_, _) => ()
    _ => fail("expected invalid UTF-8 String literal")
  }
  let arbitrary_bytes = collect_program_bytes(
    2996UL, b"pub fn arbitrary() -> Bytes {\n  b\"\\xED\\xA0\\x80\\xFF\"\n}\n",
  )
  assert_eq(arbitrary_bytes.diagnostics.length(), 0)
}

///|
test "typed native and scalar packed lane operations infer through frozen interfaces" {
  let program = collect_program_manifest(
    2998UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.i8x16\nopen dew.std.i32x2\npub fn native_add(left: I8, right: I8) -> I8x16 {\n  i8x16_splat(left) + i8x16_splat(right)\n}\npub fn native_sat(left: I8, right: I8) -> I8x16 {\n  i8x16_splat(left).add_sat(i8x16_splat(right))\n}\npub fn scalar_add(left: I32, right: I32) -> I32x2 {\n  i32x2_splat(left) + i32x2_splat(right)\n}\npub fn scalar_extract(value: I32x2) -> I32 {\n  value.extract(1u8)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(program.modules[0].diagnostics.length(), 0)
  assert_eq(
    analyzed.frozen.interfaces[0].resolved_types.diagnostics.length(),
    0,
  )
  assert_eq(analyzed.modules[0].names.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.impl_index.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
}
