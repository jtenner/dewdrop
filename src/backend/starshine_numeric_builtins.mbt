///|
fn starshine_numeric_builtin_instructions(
  name : Bytes,
) -> Array[@lib.Instruction]? {
  if name == b"dew_i8_or" {
    Some([@lib.Instruction::i32_or(), @lib.Instruction::i32_extend8s()])
  } else if name == b"dew_i8_xor" {
    Some([@lib.Instruction::i32_xor(), @lib.Instruction::i32_extend8s()])
  } else if name == b"dew_i8_and" {
    Some([@lib.Instruction::i32_and(), @lib.Instruction::i32_extend8s()])
  } else if name == b"dew_i8_eq" {
    Some([@lib.Instruction::i32_eq()])
  } else if name == b"dew_i8_ne" {
    Some([@lib.Instruction::i32_ne()])
  } else if name == b"dew_i8_lt" {
    Some([@lib.Instruction::i32_lt_s()])
  } else if name == b"dew_i8_lte" {
    Some([@lib.Instruction::i32_le_s()])
  } else if name == b"dew_i8_gt" {
    Some([@lib.Instruction::i32_gt_s()])
  } else if name == b"dew_i8_gte" {
    Some([@lib.Instruction::i32_ge_s()])
  } else if name == b"dew_i8_shl" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(7)),
      @lib.Instruction::i32_and(),
      @lib.Instruction::i32_shl(),
      @lib.Instruction::i32_extend8s(),
    ])
  } else if name == b"dew_i8_shr" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(7)),
      @lib.Instruction::i32_and(),
      @lib.Instruction::i32_shr_s(),
      @lib.Instruction::i32_extend8s(),
    ])
  } else if name == b"dew_i8_add" {
    Some([@lib.Instruction::i32_add(), @lib.Instruction::i32_extend8s()])
  } else if name == b"dew_i8_sub" {
    Some([@lib.Instruction::i32_sub(), @lib.Instruction::i32_extend8s()])
  } else if name == b"dew_i8_mul" {
    Some([@lib.Instruction::i32_mul(), @lib.Instruction::i32_extend8s()])
  } else if name == b"dew_i8_div" {
    Some([@lib.Instruction::i32_div_s(), @lib.Instruction::i32_extend8s()])
  } else if name == b"dew_i8_rem" {
    Some([@lib.Instruction::i32_rem_s(), @lib.Instruction::i32_extend8s()])
  } else if name == b"dew_i16_or" {
    Some([@lib.Instruction::i32_or(), @lib.Instruction::i32_extend16s()])
  } else if name == b"dew_i16_xor" {
    Some([@lib.Instruction::i32_xor(), @lib.Instruction::i32_extend16s()])
  } else if name == b"dew_i16_and" {
    Some([@lib.Instruction::i32_and(), @lib.Instruction::i32_extend16s()])
  } else if name == b"dew_i16_eq" {
    Some([@lib.Instruction::i32_eq()])
  } else if name == b"dew_i16_ne" {
    Some([@lib.Instruction::i32_ne()])
  } else if name == b"dew_i16_lt" {
    Some([@lib.Instruction::i32_lt_s()])
  } else if name == b"dew_i16_lte" {
    Some([@lib.Instruction::i32_le_s()])
  } else if name == b"dew_i16_gt" {
    Some([@lib.Instruction::i32_gt_s()])
  } else if name == b"dew_i16_gte" {
    Some([@lib.Instruction::i32_ge_s()])
  } else if name == b"dew_i16_shl" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(15)),
      @lib.Instruction::i32_and(),
      @lib.Instruction::i32_shl(),
      @lib.Instruction::i32_extend16s(),
    ])
  } else if name == b"dew_i16_shr" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(15)),
      @lib.Instruction::i32_and(),
      @lib.Instruction::i32_shr_s(),
      @lib.Instruction::i32_extend16s(),
    ])
  } else if name == b"dew_i16_add" {
    Some([@lib.Instruction::i32_add(), @lib.Instruction::i32_extend16s()])
  } else if name == b"dew_i16_sub" {
    Some([@lib.Instruction::i32_sub(), @lib.Instruction::i32_extend16s()])
  } else if name == b"dew_i16_mul" {
    Some([@lib.Instruction::i32_mul(), @lib.Instruction::i32_extend16s()])
  } else if name == b"dew_i16_div" {
    Some([@lib.Instruction::i32_div_s(), @lib.Instruction::i32_extend16s()])
  } else if name == b"dew_i16_rem" {
    Some([@lib.Instruction::i32_rem_s(), @lib.Instruction::i32_extend16s()])
  } else if name == b"dew_i32_or" {
    Some([@lib.Instruction::i32_or()])
  } else if name == b"dew_i32_xor" {
    Some([@lib.Instruction::i32_xor()])
  } else if name == b"dew_i32_and" {
    Some([@lib.Instruction::i32_and()])
  } else if name == b"dew_i32_eq" {
    Some([@lib.Instruction::i32_eq()])
  } else if name == b"dew_i32_ne" {
    Some([@lib.Instruction::i32_ne()])
  } else if name == b"dew_i32_lt" {
    Some([@lib.Instruction::i32_lt_s()])
  } else if name == b"dew_i32_gt" {
    Some([@lib.Instruction::i32_gt_s()])
  } else if name == b"dew_i32_gte" {
    Some([@lib.Instruction::i32_ge_s()])
  } else if name == b"dew_i32_shl" {
    Some([@lib.Instruction::i32_shl()])
  } else if name == b"dew_i32_shr" {
    Some([@lib.Instruction::i32_shr_s()])
  } else if name == b"dew_i32_mul" {
    Some([@lib.Instruction::i32_mul()])
  } else if name == b"dew_i32_div" {
    Some([@lib.Instruction::i32_div_s()])
  } else if name == b"dew_i32_rem" {
    Some([@lib.Instruction::i32_rem_s()])
  } else if name == b"dew_i64_or" {
    Some([@lib.Instruction::i64_or()])
  } else if name == b"dew_i64_xor" {
    Some([@lib.Instruction::i64_xor()])
  } else if name == b"dew_i64_and" {
    Some([@lib.Instruction::i64_and()])
  } else if name == b"dew_i64_eq" {
    Some([@lib.Instruction::i64_eq()])
  } else if name == b"dew_i64_ne" {
    Some([@lib.Instruction::i64_ne()])
  } else if name == b"dew_i64_lt" {
    Some([@lib.Instruction::i64_lt_s()])
  } else if name == b"dew_i64_lte" {
    Some([@lib.Instruction::i64_le_s()])
  } else if name == b"dew_i64_gt" {
    Some([@lib.Instruction::i64_gt_s()])
  } else if name == b"dew_i64_gte" {
    Some([@lib.Instruction::i64_ge_s()])
  } else if name == b"dew_i64_shl" {
    Some([@lib.Instruction::i64_shl()])
  } else if name == b"dew_i64_shr" {
    Some([@lib.Instruction::i64_shr_s()])
  } else if name == b"dew_i64_add" {
    Some([@lib.Instruction::i64_add()])
  } else if name == b"dew_i64_sub" {
    Some([@lib.Instruction::i64_sub()])
  } else if name == b"dew_i64_mul" {
    Some([@lib.Instruction::i64_mul()])
  } else if name == b"dew_i64_div" {
    Some([@lib.Instruction::i64_div_s()])
  } else if name == b"dew_i64_rem" {
    Some([@lib.Instruction::i64_rem_s()])
  } else if name == b"dew_u8_or" {
    Some([
      @lib.Instruction::i32_or(),
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u8_xor" {
    Some([
      @lib.Instruction::i32_xor(),
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u8_and" {
    Some([
      @lib.Instruction::i32_and(),
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u8_eq" {
    Some([@lib.Instruction::i32_eq()])
  } else if name == b"dew_u8_ne" {
    Some([@lib.Instruction::i32_ne()])
  } else if name == b"dew_u8_lt" {
    Some([@lib.Instruction::i32_lt_u()])
  } else if name == b"dew_u8_lte" {
    Some([@lib.Instruction::i32_le_u()])
  } else if name == b"dew_u8_gt" {
    Some([@lib.Instruction::i32_gt_u()])
  } else if name == b"dew_u8_gte" {
    Some([@lib.Instruction::i32_ge_u()])
  } else if name == b"dew_u8_shl" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(7)),
      @lib.Instruction::i32_and(),
      @lib.Instruction::i32_shl(),
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u8_shr" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(7)),
      @lib.Instruction::i32_and(),
      @lib.Instruction::i32_shr_u(),
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u8_add" {
    Some([
      @lib.Instruction::i32_add(),
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u8_sub" {
    Some([
      @lib.Instruction::i32_sub(),
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u8_mul" {
    Some([
      @lib.Instruction::i32_mul(),
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u8_div" {
    Some([
      @lib.Instruction::i32_div_u(),
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u8_rem" {
    Some([
      @lib.Instruction::i32_rem_u(),
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u16_or" {
    Some([
      @lib.Instruction::i32_or(),
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u16_xor" {
    Some([
      @lib.Instruction::i32_xor(),
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u16_and" {
    Some([
      @lib.Instruction::i32_and(),
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u16_eq" {
    Some([@lib.Instruction::i32_eq()])
  } else if name == b"dew_u16_ne" {
    Some([@lib.Instruction::i32_ne()])
  } else if name == b"dew_u16_lt" {
    Some([@lib.Instruction::i32_lt_u()])
  } else if name == b"dew_u16_lte" {
    Some([@lib.Instruction::i32_le_u()])
  } else if name == b"dew_u16_gt" {
    Some([@lib.Instruction::i32_gt_u()])
  } else if name == b"dew_u16_gte" {
    Some([@lib.Instruction::i32_ge_u()])
  } else if name == b"dew_u16_shl" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(15)),
      @lib.Instruction::i32_and(),
      @lib.Instruction::i32_shl(),
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u16_shr" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(15)),
      @lib.Instruction::i32_and(),
      @lib.Instruction::i32_shr_u(),
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u16_add" {
    Some([
      @lib.Instruction::i32_add(),
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u16_sub" {
    Some([
      @lib.Instruction::i32_sub(),
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u16_mul" {
    Some([
      @lib.Instruction::i32_mul(),
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u16_div" {
    Some([
      @lib.Instruction::i32_div_u(),
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u16_rem" {
    Some([
      @lib.Instruction::i32_rem_u(),
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u32_or" {
    Some([@lib.Instruction::i32_or()])
  } else if name == b"dew_u32_xor" {
    Some([@lib.Instruction::i32_xor()])
  } else if name == b"dew_u32_and" {
    Some([@lib.Instruction::i32_and()])
  } else if name == b"dew_u32_eq" {
    Some([@lib.Instruction::i32_eq()])
  } else if name == b"dew_u32_ne" {
    Some([@lib.Instruction::i32_ne()])
  } else if name == b"dew_u32_lt" {
    Some([@lib.Instruction::i32_lt_u()])
  } else if name == b"dew_u32_lte" {
    Some([@lib.Instruction::i32_le_u()])
  } else if name == b"dew_u32_gt" {
    Some([@lib.Instruction::i32_gt_u()])
  } else if name == b"dew_u32_gte" {
    Some([@lib.Instruction::i32_ge_u()])
  } else if name == b"dew_u32_shl" {
    Some([@lib.Instruction::i32_shl()])
  } else if name == b"dew_u32_shr" {
    Some([@lib.Instruction::i32_shr_u()])
  } else if name == b"dew_u32_add" {
    Some([@lib.Instruction::i32_add()])
  } else if name == b"dew_u32_sub" {
    Some([@lib.Instruction::i32_sub()])
  } else if name == b"dew_u32_mul" {
    Some([@lib.Instruction::i32_mul()])
  } else if name == b"dew_u32_div" {
    Some([@lib.Instruction::i32_div_u()])
  } else if name == b"dew_u32_rem" {
    Some([@lib.Instruction::i32_rem_u()])
  } else if name == b"dew_u64_or" {
    Some([@lib.Instruction::i64_or()])
  } else if name == b"dew_u64_xor" {
    Some([@lib.Instruction::i64_xor()])
  } else if name == b"dew_u64_and" {
    Some([@lib.Instruction::i64_and()])
  } else if name == b"dew_u64_eq" {
    Some([@lib.Instruction::i64_eq()])
  } else if name == b"dew_u64_ne" {
    Some([@lib.Instruction::i64_ne()])
  } else if name == b"dew_u64_lt" {
    Some([@lib.Instruction::i64_lt_u()])
  } else if name == b"dew_u64_lte" {
    Some([@lib.Instruction::i64_le_u()])
  } else if name == b"dew_u64_gt" {
    Some([@lib.Instruction::i64_gt_u()])
  } else if name == b"dew_u64_gte" {
    Some([@lib.Instruction::i64_ge_u()])
  } else if name == b"dew_u64_shl" {
    Some([@lib.Instruction::i64_shl()])
  } else if name == b"dew_u64_shr" {
    Some([@lib.Instruction::i64_shr_u()])
  } else if name == b"dew_u64_add" {
    Some([@lib.Instruction::i64_add()])
  } else if name == b"dew_u64_sub" {
    Some([@lib.Instruction::i64_sub()])
  } else if name == b"dew_u64_mul" {
    Some([@lib.Instruction::i64_mul()])
  } else if name == b"dew_u64_div" {
    Some([@lib.Instruction::i64_div_u()])
  } else if name == b"dew_u64_rem" {
    Some([@lib.Instruction::i64_rem_u()])
  } else if name == b"dew_f32_eq" {
    Some([@lib.Instruction::f32_eq()])
  } else if name == b"dew_f32_ne" {
    Some([@lib.Instruction::f32_ne()])
  } else if name == b"dew_f32_lt" {
    Some([@lib.Instruction::f32_lt()])
  } else if name == b"dew_f32_lte" {
    Some([@lib.Instruction::f32_le()])
  } else if name == b"dew_f32_gt" {
    Some([@lib.Instruction::f32_gt()])
  } else if name == b"dew_f32_gte" {
    Some([@lib.Instruction::f32_ge()])
  } else if name == b"dew_f32_add" {
    Some([@lib.Instruction::f32_add()])
  } else if name == b"dew_f32_sub" {
    Some([@lib.Instruction::f32_sub()])
  } else if name == b"dew_f32_mul" {
    Some([@lib.Instruction::f32_mul()])
  } else if name == b"dew_f32_div" {
    Some([@lib.Instruction::f32_div()])
  } else if name == b"dew_f64_eq" {
    Some([@lib.Instruction::f64_eq()])
  } else if name == b"dew_f64_ne" {
    Some([@lib.Instruction::f64_ne()])
  } else if name == b"dew_f64_lt" {
    Some([@lib.Instruction::f64_lt()])
  } else if name == b"dew_f64_lte" {
    Some([@lib.Instruction::f64_le()])
  } else if name == b"dew_f64_gt" {
    Some([@lib.Instruction::f64_gt()])
  } else if name == b"dew_f64_gte" {
    Some([@lib.Instruction::f64_ge()])
  } else if name == b"dew_f64_add" {
    Some([@lib.Instruction::f64_add()])
  } else if name == b"dew_f64_sub" {
    Some([@lib.Instruction::f64_sub()])
  } else if name == b"dew_f64_mul" {
    Some([@lib.Instruction::f64_mul()])
  } else if name == b"dew_f64_div" {
    Some([@lib.Instruction::f64_div()])
  } else {
    None
  }
}
