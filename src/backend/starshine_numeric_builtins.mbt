///|
// Every entry is one Wasm instruction; narrow arithmetic is ordinary Dew code.
fn starshine_numeric_builtin_instructions(
  name : Bytes,
) -> Array[@lib.Instruction]? {
  if name == b"i32.add" {
    Some([@lib.Instruction::i32_add()])
  } else if name == b"i32.sub" {
    Some([@lib.Instruction::i32_sub()])
  } else if name == b"i32.le_s" {
    Some([@lib.Instruction::i32_le_s()])
  } else if name == b"i32.or" {
    Some([@lib.Instruction::i32_or()])
  } else if name == b"i32.xor" {
    Some([@lib.Instruction::i32_xor()])
  } else if name == b"i32.and" {
    Some([@lib.Instruction::i32_and()])
  } else if name == b"i32.eq" {
    Some([@lib.Instruction::i32_eq()])
  } else if name == b"i32.ne" {
    Some([@lib.Instruction::i32_ne()])
  } else if name == b"i32.lt_s" {
    Some([@lib.Instruction::i32_lt_s()])
  } else if name == b"i32.gt_s" {
    Some([@lib.Instruction::i32_gt_s()])
  } else if name == b"i32.ge_s" {
    Some([@lib.Instruction::i32_ge_s()])
  } else if name == b"i32.shl" {
    Some([@lib.Instruction::i32_shl()])
  } else if name == b"i32.shr_s" {
    Some([@lib.Instruction::i32_shr_s()])
  } else if name == b"i32.mul" {
    Some([@lib.Instruction::i32_mul()])
  } else if name == b"i32.div_s" {
    Some([@lib.Instruction::i32_div_s()])
  } else if name == b"i32.rem_s" {
    Some([@lib.Instruction::i32_rem_s()])
  } else if name == b"i64.or" {
    Some([@lib.Instruction::i64_or()])
  } else if name == b"i64.xor" {
    Some([@lib.Instruction::i64_xor()])
  } else if name == b"i64.and" {
    Some([@lib.Instruction::i64_and()])
  } else if name == b"i64.eq" {
    Some([@lib.Instruction::i64_eq()])
  } else if name == b"i64.ne" {
    Some([@lib.Instruction::i64_ne()])
  } else if name == b"i64.lt_s" {
    Some([@lib.Instruction::i64_lt_s()])
  } else if name == b"i64.le_s" {
    Some([@lib.Instruction::i64_le_s()])
  } else if name == b"i64.gt_s" {
    Some([@lib.Instruction::i64_gt_s()])
  } else if name == b"i64.ge_s" {
    Some([@lib.Instruction::i64_ge_s()])
  } else if name == b"i64.shl" {
    Some([@lib.Instruction::i64_shl()])
  } else if name == b"i64.shr_s" {
    Some([@lib.Instruction::i64_shr_s()])
  } else if name == b"i64.add" {
    Some([@lib.Instruction::i64_add()])
  } else if name == b"i64.sub" {
    Some([@lib.Instruction::i64_sub()])
  } else if name == b"i64.mul" {
    Some([@lib.Instruction::i64_mul()])
  } else if name == b"i64.div_s" {
    Some([@lib.Instruction::i64_div_s()])
  } else if name == b"i64.rem_s" {
    Some([@lib.Instruction::i64_rem_s()])
  } else if name == b"i32.lt_u" {
    Some([@lib.Instruction::i32_lt_u()])
  } else if name == b"i32.le_u" {
    Some([@lib.Instruction::i32_le_u()])
  } else if name == b"i32.gt_u" {
    Some([@lib.Instruction::i32_gt_u()])
  } else if name == b"i32.ge_u" {
    Some([@lib.Instruction::i32_ge_u()])
  } else if name == b"i32.shr_u" {
    Some([@lib.Instruction::i32_shr_u()])
  } else if name == b"i32.div_u" {
    Some([@lib.Instruction::i32_div_u()])
  } else if name == b"i32.rem_u" {
    Some([@lib.Instruction::i32_rem_u()])
  } else if name == b"i64.lt_u" {
    Some([@lib.Instruction::i64_lt_u()])
  } else if name == b"i64.le_u" {
    Some([@lib.Instruction::i64_le_u()])
  } else if name == b"i64.gt_u" {
    Some([@lib.Instruction::i64_gt_u()])
  } else if name == b"i64.ge_u" {
    Some([@lib.Instruction::i64_ge_u()])
  } else if name == b"i64.shr_u" {
    Some([@lib.Instruction::i64_shr_u()])
  } else if name == b"i64.div_u" {
    Some([@lib.Instruction::i64_div_u()])
  } else if name == b"i64.rem_u" {
    Some([@lib.Instruction::i64_rem_u()])
  } else if name == b"f32.eq" {
    Some([@lib.Instruction::f32_eq()])
  } else if name == b"f32.ne" {
    Some([@lib.Instruction::f32_ne()])
  } else if name == b"f32.lt" {
    Some([@lib.Instruction::f32_lt()])
  } else if name == b"f32.le" {
    Some([@lib.Instruction::f32_le()])
  } else if name == b"f32.gt" {
    Some([@lib.Instruction::f32_gt()])
  } else if name == b"f32.ge" {
    Some([@lib.Instruction::f32_ge()])
  } else if name == b"f32.add" {
    Some([@lib.Instruction::f32_add()])
  } else if name == b"f32.sub" {
    Some([@lib.Instruction::f32_sub()])
  } else if name == b"f32.mul" {
    Some([@lib.Instruction::f32_mul()])
  } else if name == b"f32.div" {
    Some([@lib.Instruction::f32_div()])
  } else if name == b"f64.eq" {
    Some([@lib.Instruction::f64_eq()])
  } else if name == b"f64.ne" {
    Some([@lib.Instruction::f64_ne()])
  } else if name == b"f64.lt" {
    Some([@lib.Instruction::f64_lt()])
  } else if name == b"f64.le" {
    Some([@lib.Instruction::f64_le()])
  } else if name == b"f64.gt" {
    Some([@lib.Instruction::f64_gt()])
  } else if name == b"f64.ge" {
    Some([@lib.Instruction::f64_ge()])
  } else if name == b"f64.add" {
    Some([@lib.Instruction::f64_add()])
  } else if name == b"f64.sub" {
    Some([@lib.Instruction::f64_sub()])
  } else if name == b"f64.mul" {
    Some([@lib.Instruction::f64_mul()])
  } else if name == b"f64.div" {
    Some([@lib.Instruction::f64_div()])
  } else if name == b"i32.ctz" {
    Some([@lib.Instruction::i32_ctz()])
  } else if name == b"i32.reinterpret_f32" {
    Some([@lib.Instruction::i32_reinterpret_f32()])
  } else if name == b"f32.reinterpret_i32" {
    Some([@lib.Instruction::f32_reinterpret_i32()])
  } else if name == b"f32.abs" {
    Some([@lib.Instruction::f32_abs()])
  } else if name == b"f32.sqrt" {
    Some([@lib.Instruction::f32_sqrt()])
  } else if name == b"f32.ceil" {
    Some([@lib.Instruction::f32_ceil()])
  } else if name == b"f32.floor" {
    Some([@lib.Instruction::f32_floor()])
  } else if name == b"f32.trunc" {
    Some([@lib.Instruction::f32_trunc()])
  } else if name == b"f32.nearest" {
    Some([@lib.Instruction::f32_nearest()])
  } else if name == b"i64.reinterpret_f64" {
    Some([@lib.Instruction::i64_reinterpret_f64()])
  } else if name == b"f64.reinterpret_i64" {
    Some([@lib.Instruction::f64_reinterpret_i64()])
  } else if name == b"f64.abs" {
    Some([@lib.Instruction::f64_abs()])
  } else if name == b"f64.sqrt" {
    Some([@lib.Instruction::f64_sqrt()])
  } else if name == b"f64.ceil" {
    Some([@lib.Instruction::f64_ceil()])
  } else if name == b"f64.floor" {
    Some([@lib.Instruction::f64_floor()])
  } else if name == b"f64.trunc" {
    Some([@lib.Instruction::f64_trunc()])
  } else if name == b"f64.nearest" {
    Some([@lib.Instruction::f64_nearest()])
  } else {
    None
  }
}
