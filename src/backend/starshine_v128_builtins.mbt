///|
fn starshine_v128_builtin_instructions(
  name : Bytes,
) -> Array[@lib.Instruction]? {
  match starshine_v128_lane_builtin_instructions(name) {
    Some(instructions) => return Some(instructions)
    None => ()
  }
  match starshine_v128_cross_builtin_instructions(name) {
    Some(instructions) => return Some(instructions)
    None => ()
  }
  match starshine_v128_memory_builtin_instructions(name) {
    Some(instructions) => return Some(instructions)
    None => ()
  }
  match starshine_v128_shuffle_builtin_instructions(name) {
    Some(instructions) => return Some(instructions)
    None => ()
  }
  if name == b"dew_v128_not" {
    Some([@lib.Instruction::v128_not()])
  } else if name == b"dew_v128_andnot" {
    Some([@lib.Instruction::v128_andnot()])
  } else if name == b"dew_v128_bitselect" {
    Some([@lib.Instruction::v128_bitselect()])
  } else if name == b"dew_v128_any_true" {
    Some([@lib.Instruction::v128_any_true()])
  } else if name == b"dew_v128_splat_i8" {
    Some([@lib.Instruction::i8x16_splat()])
  } else if name == b"dew_v128_splat_i16" {
    Some([@lib.Instruction::i16x8_splat()])
  } else if name == b"dew_v128_splat_i32" {
    Some([@lib.Instruction::i32x4_splat()])
  } else if name == b"dew_v128_splat_i64" {
    Some([@lib.Instruction::i64x2_splat()])
  } else if name == b"dew_v128_splat_f32" {
    Some([@lib.Instruction::f32x4_splat()])
  } else if name == b"dew_v128_splat_f64" {
    Some([@lib.Instruction::f64x2_splat()])
  } else if name == b"dew_v128_add_i8" {
    Some([@lib.Instruction::i8x16_add()])
  } else if name == b"dew_v128_sub_i8" {
    Some([@lib.Instruction::i8x16_sub()])
  } else if name == b"dew_v128_min_s_i8" {
    Some([@lib.Instruction::i8x16_min_s()])
  } else if name == b"dew_v128_min_u_i8" {
    Some([@lib.Instruction::i8x16_min_u()])
  } else if name == b"dew_v128_max_s_i8" {
    Some([@lib.Instruction::i8x16_max_s()])
  } else if name == b"dew_v128_max_u_i8" {
    Some([@lib.Instruction::i8x16_max_u()])
  } else if name == b"dew_v128_avgr_u_i8" {
    Some([@lib.Instruction::i8x16_avgr_u()])
  } else if name == b"dew_v128_add_sat_s_i8" {
    Some([@lib.Instruction::i8x16_add_sat_s()])
  } else if name == b"dew_v128_add_sat_u_i8" {
    Some([@lib.Instruction::i8x16_add_sat_u()])
  } else if name == b"dew_v128_sub_sat_s_i8" {
    Some([@lib.Instruction::i8x16_sub_sat_s()])
  } else if name == b"dew_v128_sub_sat_u_i8" {
    Some([@lib.Instruction::i8x16_sub_sat_u()])
  } else if name == b"dew_v128_eq_i8" {
    Some([@lib.Instruction::i8x16_eq()])
  } else if name == b"dew_v128_ne_i8" {
    Some([@lib.Instruction::i8x16_ne()])
  } else if name == b"dew_v128_lt_s_i8" {
    Some([@lib.Instruction::i8x16_lt_s()])
  } else if name == b"dew_v128_lt_u_i8" {
    Some([@lib.Instruction::i8x16_lt_u()])
  } else if name == b"dew_v128_le_s_i8" {
    Some([@lib.Instruction::i8x16_le_s()])
  } else if name == b"dew_v128_le_u_i8" {
    Some([@lib.Instruction::i8x16_le_u()])
  } else if name == b"dew_v128_gt_s_i8" {
    Some([@lib.Instruction::i8x16_gt_s()])
  } else if name == b"dew_v128_gt_u_i8" {
    Some([@lib.Instruction::i8x16_gt_u()])
  } else if name == b"dew_v128_ge_s_i8" {
    Some([@lib.Instruction::i8x16_ge_s()])
  } else if name == b"dew_v128_ge_u_i8" {
    Some([@lib.Instruction::i8x16_ge_u()])
  } else if name == b"dew_v128_abs_i8" {
    Some([@lib.Instruction::i8x16_abs()])
  } else if name == b"dew_v128_neg_i8" {
    Some([@lib.Instruction::i8x16_neg()])
  } else if name == b"dew_v128_popcnt_i8" {
    Some([@lib.Instruction::i8x16_popcnt()])
  } else if name == b"dew_v128_all_true_i8" {
    Some([@lib.Instruction::i8x16_all_true()])
  } else if name == b"dew_v128_bitmask_i8" {
    Some([@lib.Instruction::i8x16_bitmask()])
  } else if name == b"dew_v128_shl_i8" {
    Some([@lib.Instruction::i8x16_shl()])
  } else if name == b"dew_v128_shr_s_i8" {
    Some([@lib.Instruction::i8x16_shr_s()])
  } else if name == b"dew_v128_shr_u_i8" {
    Some([@lib.Instruction::i8x16_shr_u()])
  } else if name == b"dew_v128_add_i16" {
    Some([@lib.Instruction::i16x8_add()])
  } else if name == b"dew_v128_sub_i16" {
    Some([@lib.Instruction::i16x8_sub()])
  } else if name == b"dew_v128_mul_i16" {
    Some([@lib.Instruction::i16x8_mul()])
  } else if name == b"dew_v128_min_s_i16" {
    Some([@lib.Instruction::i16x8_min_s()])
  } else if name == b"dew_v128_min_u_i16" {
    Some([@lib.Instruction::i16x8_min_u()])
  } else if name == b"dew_v128_max_s_i16" {
    Some([@lib.Instruction::i16x8_max_s()])
  } else if name == b"dew_v128_max_u_i16" {
    Some([@lib.Instruction::i16x8_max_u()])
  } else if name == b"dew_v128_avgr_u_i16" {
    Some([@lib.Instruction::i16x8_avgr_u()])
  } else if name == b"dew_v128_add_sat_s_i16" {
    Some([@lib.Instruction::i16x8_add_sat_s()])
  } else if name == b"dew_v128_add_sat_u_i16" {
    Some([@lib.Instruction::i16x8_add_sat_u()])
  } else if name == b"dew_v128_sub_sat_s_i16" {
    Some([@lib.Instruction::i16x8_sub_sat_s()])
  } else if name == b"dew_v128_sub_sat_u_i16" {
    Some([@lib.Instruction::i16x8_sub_sat_u()])
  } else if name == b"dew_v128_eq_i16" {
    Some([@lib.Instruction::i16x8_eq()])
  } else if name == b"dew_v128_ne_i16" {
    Some([@lib.Instruction::i16x8_ne()])
  } else if name == b"dew_v128_lt_s_i16" {
    Some([@lib.Instruction::i16x8_lt_s()])
  } else if name == b"dew_v128_lt_u_i16" {
    Some([@lib.Instruction::i16x8_lt_u()])
  } else if name == b"dew_v128_le_s_i16" {
    Some([@lib.Instruction::i16x8_le_s()])
  } else if name == b"dew_v128_le_u_i16" {
    Some([@lib.Instruction::i16x8_le_u()])
  } else if name == b"dew_v128_gt_s_i16" {
    Some([@lib.Instruction::i16x8_gt_s()])
  } else if name == b"dew_v128_gt_u_i16" {
    Some([@lib.Instruction::i16x8_gt_u()])
  } else if name == b"dew_v128_ge_s_i16" {
    Some([@lib.Instruction::i16x8_ge_s()])
  } else if name == b"dew_v128_ge_u_i16" {
    Some([@lib.Instruction::i16x8_ge_u()])
  } else if name == b"dew_v128_abs_i16" {
    Some([@lib.Instruction::i16x8_abs()])
  } else if name == b"dew_v128_neg_i16" {
    Some([@lib.Instruction::i16x8_neg()])
  } else if name == b"dew_v128_all_true_i16" {
    Some([@lib.Instruction::i16x8_all_true()])
  } else if name == b"dew_v128_bitmask_i16" {
    Some([@lib.Instruction::i16x8_bitmask()])
  } else if name == b"dew_v128_shl_i16" {
    Some([@lib.Instruction::i16x8_shl()])
  } else if name == b"dew_v128_shr_s_i16" {
    Some([@lib.Instruction::i16x8_shr_s()])
  } else if name == b"dew_v128_shr_u_i16" {
    Some([@lib.Instruction::i16x8_shr_u()])
  } else if name == b"dew_v128_add_i32" {
    Some([@lib.Instruction::i32x4_add()])
  } else if name == b"dew_v128_sub_i32" {
    Some([@lib.Instruction::i32x4_sub()])
  } else if name == b"dew_v128_mul_i32" {
    Some([@lib.Instruction::i32x4_mul()])
  } else if name == b"dew_v128_min_s_i32" {
    Some([@lib.Instruction::i32x4_min_s()])
  } else if name == b"dew_v128_min_u_i32" {
    Some([@lib.Instruction::i32x4_min_u()])
  } else if name == b"dew_v128_max_s_i32" {
    Some([@lib.Instruction::i32x4_max_s()])
  } else if name == b"dew_v128_max_u_i32" {
    Some([@lib.Instruction::i32x4_max_u()])
  } else if name == b"dew_v128_eq_i32" {
    Some([@lib.Instruction::i32x4_eq()])
  } else if name == b"dew_v128_ne_i32" {
    Some([@lib.Instruction::i32x4_ne()])
  } else if name == b"dew_v128_lt_s_i32" {
    Some([@lib.Instruction::i32x4_lt_s()])
  } else if name == b"dew_v128_lt_u_i32" {
    Some([@lib.Instruction::i32x4_lt_u()])
  } else if name == b"dew_v128_le_s_i32" {
    Some([@lib.Instruction::i32x4_le_s()])
  } else if name == b"dew_v128_le_u_i32" {
    Some([@lib.Instruction::i32x4_le_u()])
  } else if name == b"dew_v128_gt_s_i32" {
    Some([@lib.Instruction::i32x4_gt_s()])
  } else if name == b"dew_v128_gt_u_i32" {
    Some([@lib.Instruction::i32x4_gt_u()])
  } else if name == b"dew_v128_ge_s_i32" {
    Some([@lib.Instruction::i32x4_ge_s()])
  } else if name == b"dew_v128_ge_u_i32" {
    Some([@lib.Instruction::i32x4_ge_u()])
  } else if name == b"dew_v128_abs_i32" {
    Some([@lib.Instruction::i32x4_abs()])
  } else if name == b"dew_v128_neg_i32" {
    Some([@lib.Instruction::i32x4_neg()])
  } else if name == b"dew_v128_all_true_i32" {
    Some([@lib.Instruction::i32x4_all_true()])
  } else if name == b"dew_v128_bitmask_i32" {
    Some([@lib.Instruction::i32x4_bitmask()])
  } else if name == b"dew_v128_shl_i32" {
    Some([@lib.Instruction::i32x4_shl()])
  } else if name == b"dew_v128_shr_s_i32" {
    Some([@lib.Instruction::i32x4_shr_s()])
  } else if name == b"dew_v128_shr_u_i32" {
    Some([@lib.Instruction::i32x4_shr_u()])
  } else if name == b"dew_v128_add_i64" {
    Some([@lib.Instruction::i64x2_add()])
  } else if name == b"dew_v128_sub_i64" {
    Some([@lib.Instruction::i64x2_sub()])
  } else if name == b"dew_v128_mul_i64" {
    Some([@lib.Instruction::i64x2_mul()])
  } else if name == b"dew_v128_eq_i64" {
    Some([@lib.Instruction::i64x2_eq()])
  } else if name == b"dew_v128_ne_i64" {
    Some([@lib.Instruction::i64x2_ne()])
  } else if name == b"dew_v128_lt_s_i64" {
    Some([@lib.Instruction::i64x2_lt_s()])
  } else if name == b"dew_v128_le_s_i64" {
    Some([@lib.Instruction::i64x2_le_s()])
  } else if name == b"dew_v128_gt_s_i64" {
    Some([@lib.Instruction::i64x2_gt_s()])
  } else if name == b"dew_v128_ge_s_i64" {
    Some([@lib.Instruction::i64x2_ge_s()])
  } else if name == b"dew_v128_abs_i64" {
    Some([@lib.Instruction::i64x2_abs()])
  } else if name == b"dew_v128_neg_i64" {
    Some([@lib.Instruction::i64x2_neg()])
  } else if name == b"dew_v128_all_true_i64" {
    Some([@lib.Instruction::i64x2_all_true()])
  } else if name == b"dew_v128_bitmask_i64" {
    Some([@lib.Instruction::i64x2_bitmask()])
  } else if name == b"dew_v128_shl_i64" {
    Some([@lib.Instruction::i64x2_shl()])
  } else if name == b"dew_v128_shr_s_i64" {
    Some([@lib.Instruction::i64x2_shr_s()])
  } else if name == b"dew_v128_shr_u_i64" {
    Some([@lib.Instruction::i64x2_shr_u()])
  } else if name == b"dew_v128_add_f32" {
    Some([@lib.Instruction::f32x4_add()])
  } else if name == b"dew_v128_sub_f32" {
    Some([@lib.Instruction::f32x4_sub()])
  } else if name == b"dew_v128_mul_f32" {
    Some([@lib.Instruction::f32x4_mul()])
  } else if name == b"dew_v128_div_f32" {
    Some([@lib.Instruction::f32x4_div()])
  } else if name == b"dew_v128_min_f32" {
    Some([@lib.Instruction::f32x4_min()])
  } else if name == b"dew_v128_max_f32" {
    Some([@lib.Instruction::f32x4_max()])
  } else if name == b"dew_v128_pmin_f32" {
    Some([@lib.Instruction::f32x4_pmin()])
  } else if name == b"dew_v128_pmax_f32" {
    Some([@lib.Instruction::f32x4_pmax()])
  } else if name == b"dew_v128_eq_f32" {
    Some([@lib.Instruction::f32x4_eq()])
  } else if name == b"dew_v128_ne_f32" {
    Some([@lib.Instruction::f32x4_ne()])
  } else if name == b"dew_v128_lt_f32" {
    Some([@lib.Instruction::f32x4_lt()])
  } else if name == b"dew_v128_le_f32" {
    Some([@lib.Instruction::f32x4_le()])
  } else if name == b"dew_v128_gt_f32" {
    Some([@lib.Instruction::f32x4_gt()])
  } else if name == b"dew_v128_ge_f32" {
    Some([@lib.Instruction::f32x4_ge()])
  } else if name == b"dew_v128_abs_f32" {
    Some([@lib.Instruction::f32x4_abs()])
  } else if name == b"dew_v128_neg_f32" {
    Some([@lib.Instruction::f32x4_neg()])
  } else if name == b"dew_v128_sqrt_f32" {
    Some([@lib.Instruction::f32x4_sqrt()])
  } else if name == b"dew_v128_ceil_f32" {
    Some([@lib.Instruction::f32x4_ceil()])
  } else if name == b"dew_v128_floor_f32" {
    Some([@lib.Instruction::f32x4_floor()])
  } else if name == b"dew_v128_trunc_f32" {
    Some([@lib.Instruction::f32x4_trunc()])
  } else if name == b"dew_v128_nearest_f32" {
    Some([@lib.Instruction::f32x4_nearest()])
  } else if name == b"dew_v128_add_f64" {
    Some([@lib.Instruction::f64x2_add()])
  } else if name == b"dew_v128_sub_f64" {
    Some([@lib.Instruction::f64x2_sub()])
  } else if name == b"dew_v128_mul_f64" {
    Some([@lib.Instruction::f64x2_mul()])
  } else if name == b"dew_v128_div_f64" {
    Some([@lib.Instruction::f64x2_div()])
  } else if name == b"dew_v128_min_f64" {
    Some([@lib.Instruction::f64x2_min()])
  } else if name == b"dew_v128_max_f64" {
    Some([@lib.Instruction::f64x2_max()])
  } else if name == b"dew_v128_pmin_f64" {
    Some([@lib.Instruction::f64x2_pmin()])
  } else if name == b"dew_v128_pmax_f64" {
    Some([@lib.Instruction::f64x2_pmax()])
  } else if name == b"dew_v128_eq_f64" {
    Some([@lib.Instruction::f64x2_eq()])
  } else if name == b"dew_v128_ne_f64" {
    Some([@lib.Instruction::f64x2_ne()])
  } else if name == b"dew_v128_lt_f64" {
    Some([@lib.Instruction::f64x2_lt()])
  } else if name == b"dew_v128_le_f64" {
    Some([@lib.Instruction::f64x2_le()])
  } else if name == b"dew_v128_gt_f64" {
    Some([@lib.Instruction::f64x2_gt()])
  } else if name == b"dew_v128_ge_f64" {
    Some([@lib.Instruction::f64x2_ge()])
  } else if name == b"dew_v128_abs_f64" {
    Some([@lib.Instruction::f64x2_abs()])
  } else if name == b"dew_v128_neg_f64" {
    Some([@lib.Instruction::f64x2_neg()])
  } else if name == b"dew_v128_sqrt_f64" {
    Some([@lib.Instruction::f64x2_sqrt()])
  } else if name == b"dew_v128_ceil_f64" {
    Some([@lib.Instruction::f64x2_ceil()])
  } else if name == b"dew_v128_floor_f64" {
    Some([@lib.Instruction::f64x2_floor()])
  } else if name == b"dew_v128_trunc_f64" {
    Some([@lib.Instruction::f64x2_trunc()])
  } else if name == b"dew_v128_nearest_f64" {
    Some([@lib.Instruction::f64x2_nearest()])
  } else {
    None
  }
}
