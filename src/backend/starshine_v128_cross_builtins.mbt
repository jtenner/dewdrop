///|
fn starshine_v128_cross_builtin_instructions(
  name : Bytes,
) -> Array[@lib.Instruction]? {
  if name == b"dew_i8x16_narrow_i16x8_s" {
    Some([@lib.Instruction::i8x16_narrow_i16x8s()])
  } else if name == b"dew_u8x16_narrow_i16x8_u" {
    Some([@lib.Instruction::i8x16_narrow_i16x8u()])
  } else if name == b"dew_i8x16_swizzle" {
    Some([@lib.Instruction::i8x16_swizzle()])
  } else if name == b"dew_u8x16_swizzle" {
    Some([@lib.Instruction::i8x16_swizzle()])
  } else if name == b"dew_i16x8_narrow_i32x4_s" {
    Some([@lib.Instruction::i16x8_narrow_i32x4s()])
  } else if name == b"dew_u16x8_narrow_i32x4_u" {
    Some([@lib.Instruction::i16x8_narrow_i32x4u()])
  } else if name == b"dew_i16x8_extend_low_i8x16_s" {
    Some([@lib.Instruction::i16x8_extend_low_i8x16s()])
  } else if name == b"dew_i16x8_extend_high_i8x16_s" {
    Some([@lib.Instruction::i16x8_extend_high_i8x16s()])
  } else if name == b"dew_u16x8_extend_low_i8x16_u" {
    Some([@lib.Instruction::i16x8_extend_low_i8x16u()])
  } else if name == b"dew_u16x8_extend_high_i8x16_u" {
    Some([@lib.Instruction::i16x8_extend_high_i8x16u()])
  } else if name == b"dew_i16x8_extadd_pairwise_i8x16_s" {
    Some([@lib.Instruction::i16x8_extadd_pairwise_i8x16s()])
  } else if name == b"dew_u16x8_extadd_pairwise_i8x16_u" {
    Some([@lib.Instruction::i16x8_extadd_pairwise_i8x16u()])
  } else if name == b"dew_i16x8_extmul_low_i8x16_s" {
    Some([@lib.Instruction::i16x8_extmul_low_i8x16s()])
  } else if name == b"dew_i16x8_extmul_high_i8x16_s" {
    Some([@lib.Instruction::i16x8_extmul_high_i8x16s()])
  } else if name == b"dew_u16x8_extmul_low_i8x16_u" {
    Some([@lib.Instruction::i16x8_extmul_low_i8x16u()])
  } else if name == b"dew_u16x8_extmul_high_i8x16_u" {
    Some([@lib.Instruction::i16x8_extmul_high_i8x16u()])
  } else if name == b"dew_i32x4_extend_low_i16x8_s" {
    Some([@lib.Instruction::i32x4_extend_low_i16x8s()])
  } else if name == b"dew_i32x4_extend_high_i16x8_s" {
    Some([@lib.Instruction::i32x4_extend_high_i16x8s()])
  } else if name == b"dew_u32x4_extend_low_i16x8_u" {
    Some([@lib.Instruction::i32x4_extend_low_i16x8u()])
  } else if name == b"dew_u32x4_extend_high_i16x8_u" {
    Some([@lib.Instruction::i32x4_extend_high_i16x8u()])
  } else if name == b"dew_i32x4_extadd_pairwise_i16x8_s" {
    Some([@lib.Instruction::i32x4_extadd_pairwise_i16x8s()])
  } else if name == b"dew_u32x4_extadd_pairwise_i16x8_u" {
    Some([@lib.Instruction::i32x4_extadd_pairwise_i16x8u()])
  } else if name == b"dew_i32x4_extmul_low_i16x8_s" {
    Some([@lib.Instruction::i32x4_extmul_low_i16x8s()])
  } else if name == b"dew_i32x4_extmul_high_i16x8_s" {
    Some([@lib.Instruction::i32x4_extmul_high_i16x8s()])
  } else if name == b"dew_u32x4_extmul_low_i16x8_u" {
    Some([@lib.Instruction::i32x4_extmul_low_i16x8u()])
  } else if name == b"dew_u32x4_extmul_high_i16x8_u" {
    Some([@lib.Instruction::i32x4_extmul_high_i16x8u()])
  } else if name == b"dew_i32x4_dot_i16x8_s" {
    Some([@lib.Instruction::i32x4_dot_i16x8s()])
  } else if name == b"dew_i64x2_extend_low_i32x4_s" {
    Some([@lib.Instruction::i64x2_extend_low_i32x4s()])
  } else if name == b"dew_i64x2_extend_high_i32x4_s" {
    Some([@lib.Instruction::i64x2_extend_high_i32x4s()])
  } else if name == b"dew_u64x2_extend_low_i32x4_u" {
    Some([@lib.Instruction::i64x2_extend_low_i32x4u()])
  } else if name == b"dew_u64x2_extend_high_i32x4_u" {
    Some([@lib.Instruction::i64x2_extend_high_i32x4u()])
  } else if name == b"dew_i64x2_extmul_low_i32x4_s" {
    Some([@lib.Instruction::i64x2_extmul_low_i32x4s()])
  } else if name == b"dew_i64x2_extmul_high_i32x4_s" {
    Some([@lib.Instruction::i64x2_extmul_high_i32x4s()])
  } else if name == b"dew_u64x2_extmul_low_i32x4_u" {
    Some([@lib.Instruction::i64x2_extmul_low_i32x4u()])
  } else if name == b"dew_u64x2_extmul_high_i32x4_u" {
    Some([@lib.Instruction::i64x2_extmul_high_i32x4u()])
  } else if name == b"dew_f32x4_convert_i32x4_s" {
    Some([@lib.Instruction::f32x4_convert_i32x4s()])
  } else if name == b"dew_f32x4_convert_i32x4_u" {
    Some([@lib.Instruction::f32x4_convert_i32x4u()])
  } else if name == b"dew_f32x4_demote_f64x2_zero" {
    Some([@lib.Instruction::f32x4_demote_f64x2_zero()])
  } else if name == b"dew_f64x2_convert_low_i32x4_s" {
    Some([@lib.Instruction::f64x2_convert_low_i32x4s()])
  } else if name == b"dew_f64x2_convert_low_i32x4_u" {
    Some([@lib.Instruction::f64x2_convert_low_i32x4u()])
  } else if name == b"dew_f64x2_promote_low_f32x4" {
    Some([@lib.Instruction::f64x2_promote_low_f32x4()])
  } else if name == b"dew_i32x4_trunc_sat_f32x4_s" {
    Some([@lib.Instruction::i32x4_trunc_sat_f32x4s()])
  } else if name == b"dew_u32x4_trunc_sat_f32x4_u" {
    Some([@lib.Instruction::i32x4_trunc_sat_f32x4u()])
  } else if name == b"dew_i32x4_trunc_sat_f64x2_s_zero" {
    Some([@lib.Instruction::i32x4_trunc_sat_f64x2s_zero()])
  } else if name == b"dew_u32x4_trunc_sat_f64x2_u_zero" {
    Some([@lib.Instruction::i32x4_trunc_sat_f64x2u_zero()])
  } else {
    None
  }
}
