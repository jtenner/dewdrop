///|
// Only raw single-instruction conversions belong in the backend.
fn starshine_conversion_builtin_instructions(
  name : Bytes,
) -> Array[@lib.Instruction]? {
  if name == b"i32.extend8_s" {
    Some([@lib.Instruction::i32_extend8s()])
  } else if name == b"i32.extend16_s" {
    Some([@lib.Instruction::i32_extend16s()])
  } else if name == b"i32.wrap_i64" {
    Some([@lib.Instruction::i32_wrap_i64()])
  } else if name == b"i64.extend_i32_s" {
    Some([@lib.Instruction::i64_extend_i32s()])
  } else if name == b"i64.extend_i32_u" {
    Some([@lib.Instruction::i64_extend_i32u()])
  } else if name == b"f32.convert_i32_s" {
    Some([@lib.Instruction::f32_convert_i32s()])
  } else if name == b"i32.trunc_f32_s" {
    Some([@lib.Instruction::i32_trunc_f32s()])
  } else if name == b"f32.convert_i32_u" {
    Some([@lib.Instruction::f32_convert_i32u()])
  } else if name == b"i32.trunc_f32_u" {
    Some([@lib.Instruction::i32_trunc_f32u()])
  } else if name == b"f32.convert_i64_s" {
    Some([@lib.Instruction::f32_convert_i64s()])
  } else if name == b"i64.trunc_f32_s" {
    Some([@lib.Instruction::i64_trunc_f32s()])
  } else if name == b"f32.convert_i64_u" {
    Some([@lib.Instruction::f32_convert_i64u()])
  } else if name == b"i64.trunc_f32_u" {
    Some([@lib.Instruction::i64_trunc_f32u()])
  } else if name == b"f64.convert_i32_s" {
    Some([@lib.Instruction::f64_convert_i32s()])
  } else if name == b"i32.trunc_f64_s" {
    Some([@lib.Instruction::i32_trunc_f64s()])
  } else if name == b"f64.convert_i32_u" {
    Some([@lib.Instruction::f64_convert_i32u()])
  } else if name == b"i32.trunc_f64_u" {
    Some([@lib.Instruction::i32_trunc_f64u()])
  } else if name == b"f64.convert_i64_s" {
    Some([@lib.Instruction::f64_convert_i64s()])
  } else if name == b"i64.trunc_f64_s" {
    Some([@lib.Instruction::i64_trunc_f64s()])
  } else if name == b"f64.convert_i64_u" {
    Some([@lib.Instruction::f64_convert_i64u()])
  } else if name == b"i64.trunc_f64_u" {
    Some([@lib.Instruction::i64_trunc_f64u()])
  } else if name == b"f32.demote_f64" {
    Some([@lib.Instruction::f32_demote_f64()])
  } else if name == b"f64.promote_f32" {
    Some([@lib.Instruction::f64_promote_f32()])
  } else {
    None
  }
}
