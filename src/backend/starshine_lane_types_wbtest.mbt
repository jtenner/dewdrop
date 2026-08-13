///|
test "typed V128 lane families validate with native SIMD instructions" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"open dew.std.i8x16\nopen dew.std.u8x16\nopen dew.std.i16x8\nopen dew.std.u16x8\nopen dew.std.i32x4\nopen dew.std.u32x4\nopen dew.std.i64x2\nopen dew.std.u64x2\nopen dew.std.f32x4\nopen dew.std.f64x2\npub fn bytes_signed(left: I8, right: I8) -> I8x16 {\n  i8x16_shl(i8x16_min_s(i8x16_add_sat_s(i8x16_add(i8x16_splat(left), i8x16_splat(right)), i8x16_splat(1i8)), i8x16_splat(100i8)), 1u32)\n}\npub fn bytes_unsigned(left: U8, right: U8) -> U8x16 {\n  u8x16_max_u(u8x16_avgr_u(u8x16_add_sat_u(u8x16_add(u8x16_splat(left), u8x16_splat(right)), u8x16_splat(1u8)), u8x16_splat(2u8)), u8x16_splat(3u8))\n}\npub fn words_signed(left: I16, right: I16) -> I16x8 {\n  i16x8_abs(i16x8_sub_sat_s(i16x8_mul(i16x8_splat(left), i16x8_splat(right)), i16x8_splat(1i16)))\n}\npub fn words_unsigned(left: U16, right: U16) -> U16x8 {\n  u16x8_shr_u(u16x8_add_sat_u(u16x8_mul(u16x8_splat(left), u16x8_splat(right)), u16x8_splat(1u16)), 2u32)\n}\npub fn ints_signed(left: I32, right: I32) -> I32x4 {\n  i32x4_neg(i32x4_min_s(i32x4_mul(i32x4_splat(left), i32x4_splat(right)), i32x4_splat(7i32)))\n}\npub fn ints_unsigned(left: U32, right: U32) -> U32x4 {\n  u32x4_shr_u(u32x4_max_u(u32x4_mul(u32x4_splat(left), u32x4_splat(right)), u32x4_splat(7u32)), 3u32)\n}\npub fn longs_signed(left: I64, right: I64) -> I64x2 {\n  i64x2_neg(i64x2_mul(i64x2_splat(left), i64x2_splat(right)))\n}\npub fn longs_unsigned(left: U64, right: U64) -> U64x2 {\n  u64x2_shr_u(u64x2_mul(u64x2_splat(left), u64x2_splat(right)), 4u32)\n}\npub fn floats(left: F32, right: F32) -> F32x4 {\n  f32x4_abs(f32x4_pmin(f32x4_mul(f32x4_splat(left), f32x4_splat(right)), f32x4_splat(1.0f32)))\n}\npub fn doubles(left: F64, right: F64) -> F64x2 {\n  f64x2_neg(f64x2_pmax(f64x2_div(f64x2_splat(left), f64x2_splat(right)), f64x2_splat(1.0f64)))\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_eq(fragments.imported_function_count, 0)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, fragments).unwrap().length() > 8,
  )
}

///|
test "typed lane reinterpretation memory and aggregates preserve raw carriers" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"open dew.std.i16x4\nopen dew.std.f32x4\nopen dew.std.i32x4\npub struct Lanes {\n  compact: I16x4\n  native: F32x4\n}\npub fn reinterpret(value: F32x4) -> I32x4 {\n  i32x4_from_v128(f32x4_to_v128(value))\n}\npub fn roundtrip_native(address: U32, value: I32x4) -> I32x4 {\n  i32x4_store(address, value)\n  i32x4_load(address)\n}\npub fn roundtrip_compact(address: U32, value: I16x4) -> I16x4 {\n  i16x4_store(address, value)\n  i16x4_load(address)\n}\npub fn build(compact: I16x4, native: F32x4) -> Lanes {\n  Lanes::{\n    compact: compact\n    native: native\n  }\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_true(backend_program_uses_linear_memory(fragments))
  assert_eq(fragments.imported_function_count, 0)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, fragments).unwrap().length() > 8,
  )
}

///|
test "typed native lane memory and string-oriented byte shuffles validate" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"open dew.std.u8x16\nopen dew.std.i16x8\nopen dew.std.f64x2\nopen dew.std.u16x8\nopen dew.std.u32x4\npub fn scan_window(address: U32, left: U8x16, right: U8x16) -> U32 {\n  let loaded = u8x16_load_splat(address)\n  let shifted = left.concat_shift_15(right)\n  let zipped = shifted.zip_low(loaded).unzip_even(loaded)\n  zipped.reverse().bitmask()\n}\npub fn patch(address: U32, value: I16x8) -> I16x8 {\n  let changed = value.load_lane_7(address)\n  changed.store_lane_7(address)\n  changed\n}\npub fn lane64(address: U32, value: F64x2) -> F64x2 {\n  value.load_lane_1(address)\n}\npub fn widen_bytes(address: U32) -> U16x8 {\n  u16x8_load_extend_u8x8_u(address)\n}\npub fn zero_word(address: U32) -> U32x4 {\n  u32x4_load_zero(address)\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_true(backend_program_uses_linear_memory(fragments))
  assert_eq(fragments.imported_function_count, 0)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, fragments).unwrap().length() > 8,
  )
}

///|
test "typed native widening narrowing dot and numeric conversions validate" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"open dew.std.i8x16\nopen dew.std.u8x16\nopen dew.std.i16x8\nopen dew.std.u16x8\nopen dew.std.i32x4\nopen dew.std.u32x4\nopen dew.std.i64x2\nopen dew.std.u64x2\nopen dew.std.f32x4\nopen dew.std.f64x2\npub fn narrow8s(low: I16x8, high: I16x8) -> I8x16 {\n  i8x16_narrow_i16x8_s(low, high)\n}\npub fn narrow8u(low: U16x8, high: U16x8) -> U8x16 {\n  u8x16_narrow_i16x8_u(low, high)\n}\npub fn widen16(value: I8x16) -> I16x8 {\n  i16x8_extend_high_i8x16_s(value)\n}\npub fn multiply16(left: U8x16, right: U8x16) -> U16x8 {\n  u16x8_extmul_low_i8x16_u(left, right)\n}\npub fn narrow16(low: I32x4, high: I32x4) -> I16x8 {\n  i16x8_narrow_i32x4_s(low, high)\n}\npub fn widen32(value: U16x8) -> U32x4 {\n  u32x4_extend_low_i16x8_u(value)\n}\npub fn dot(left: I16x8, right: I16x8) -> I32x4 {\n  i32x4_dot_i16x8_s(left, right)\n}\npub fn widen64(value: I32x4) -> I64x2 {\n  i64x2_extend_high_i32x4_s(value)\n}\npub fn multiply64(left: U32x4, right: U32x4) -> U64x2 {\n  u64x2_extmul_low_i32x4_u(left, right)\n}\npub fn to_float(value: I32x4) -> F32x4 {\n  f32x4_convert_i32x4_s(value)\n}\npub fn to_double(value: U32x4) -> F64x2 {\n  f64x2_convert_low_i32x4_u(value)\n}\npub fn to_int(value: F32x4) -> I32x4 {\n  i32x4_trunc_sat_f32x4_s(value)\n}\npub fn demote(value: F64x2) -> F32x4 {\n  f32x4_demote_f64x2_zero(value)\n}\npub fn swizzle(value: U8x16, indices: U8x16) -> U8x16 {\n  u8x16_swizzle(value, indices)\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_eq(fragments.imported_function_count, 0)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, fragments).unwrap().length() > 8,
  )
}

///|
test "typed native lane extraction and replacement freeze immediate indices" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"open dew.std.i8x16\nopen dew.std.u8x16\nopen dew.std.i16x8\nopen dew.std.u16x8\nopen dew.std.i32x4\nopen dew.std.u32x4\nopen dew.std.i64x2\nopen dew.std.u64x2\nopen dew.std.f32x4\nopen dew.std.f64x2\npub fn byte(value: I8x16, lane: I8) -> I8 {\n  value.replace_15(lane).extract_15()\n}\npub fn ubyte(value: U8x16, lane: U8) -> U8 {\n  value.replace_14(lane).extract_14()\n}\npub fn word(value: I16x8, lane: I16) -> I16 {\n  value.replace_7(lane).extract_7()\n}\npub fn uword(value: U16x8, lane: U16) -> U16 {\n  value.replace_6(lane).extract_6()\n}\npub fn integer(value: I32x4, lane: I32) -> I32 {\n  value.replace_3(lane).extract_3()\n}\npub fn uinteger(value: U32x4, lane: U32) -> U32 {\n  value.replace_2(lane).extract_2()\n}\npub fn long(value: I64x2, lane: I64) -> I64 {\n  value.replace_1(lane).extract_1()\n}\npub fn ulong(value: U64x2, lane: U64) -> U64 {\n  value.replace_1(lane).extract_1()\n}\npub fn float_lane(value: F32x4, lane: F32) -> F32 {\n  value.replace_3(lane).extract_3()\n}\npub fn double_lane(value: F64x2, lane: F64) -> F64 {\n  value.replace_1(lane).extract_1()\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_eq(fragments.imported_function_count, 0)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, fragments).unwrap().length() > 8,
  )
}

///|
test "same-carrier typed lane reinterpretations are zero-wrapper calls" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"open dew.std.f32x4\nopen dew.std.i32x4\nopen dew.std.i32x2\nopen dew.std.u8x8\nopen dew.std.u16x2\nopen dew.std.i8x4\npub fn native(value: F32x4) -> I32x4 {\n  value.reinterpret_as_i32x4()\n}\npub fn scalar64(value: I32x2) -> U8x8 {\n  value.reinterpret_as_u8x8()\n}\npub fn scalar32(value: U16x2) -> I8x4 {\n  value.reinterpret_as_i8x4()\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_eq(fragments.imported_function_count, 0)
  assert_eq(fragments.defined_function_count, 3)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, fragments).unwrap().length() > 8,
  )
}

///|
test "typed Swar32 and Swar64 lane families compile allocation free" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"open dew.std.i8x4\nopen dew.std.u16x2\nopen dew.std.i8x8\nopen dew.std.i16x4\nopen dew.std.i32x2\npub fn i8x4_math(left: I8, right: I8) -> I8 {\n  i8x4_extract(i8x4_shr(i8x4_replace(i8x4_add(i8x4_splat(left), i8x4_splat(right)), 2u8, 7i8), 1u8), 2u8)\n}\npub fn u16x2_math(left: U16, right: U16) -> U16 {\n  u16x2_extract(u16x2_replace(u16x2_sub(u16x2_splat(left), u16x2_splat(right)), 1u8, 65535u16), 1u8)\n}\npub fn i8x8_mask(left: I8, right: I8) -> U32 {\n  i8x8_bitmask(i8x8_popcnt(i8x8_add(i8x8_splat(left), i8x8_splat(right))))\n}\npub fn i16x4_math(left: I16, right: I16) -> I16 {\n  i16x4_extract(i16x4_shl(i16x4_sub(i16x4_splat(left), i16x4_splat(right)), 2u8), 3u8)\n}\npub fn i32x2_math(left: I32, right: I32) -> I32 {\n  i32x2_extract(i32x2_replace(i32x2_add(i32x2_splat(left), i32x2_splat(right)), 1u8, 9i32), 1u8)\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_eq(fragments.imported_function_count, 0)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, fragments).unwrap().length() > 8,
  )
}
