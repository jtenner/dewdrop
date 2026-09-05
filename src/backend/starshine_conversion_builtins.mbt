///|
fn starshine_conversion_builtin_instructions(
  name : Bytes,
) -> Array[@lib.Instruction]? {
  if name == b"dew_i8_into_i8" {
    Some([@lib.Instruction::i32_extend8s()])
  } else if name == b"dew_i8_into_i16" {
    Some([@lib.Instruction::i32_extend16s()])
  } else if name == b"dew_i8_into_i32" {
    Some([])
  } else if name == b"dew_i8_into_i64" {
    Some([@lib.Instruction::i64_extend_i32s()])
  } else if name == b"dew_i8_into_u8" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_i8_into_u16" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_i8_into_u32" {
    Some([])
  } else if name == b"dew_i8_into_u64" {
    Some([@lib.Instruction::i64_extend_i32s()])
  } else if name == b"dew_i8_into_f32" {
    Some([@lib.Instruction::f32_convert_i32s()])
  } else if name == b"dew_i8_into_f64" {
    Some([@lib.Instruction::f64_convert_i32s()])
  } else if name == b"dew_i16_into_i8" {
    Some([@lib.Instruction::i32_extend8s()])
  } else if name == b"dew_i16_into_i16" {
    Some([@lib.Instruction::i32_extend16s()])
  } else if name == b"dew_i16_into_i32" {
    Some([])
  } else if name == b"dew_i16_into_i64" {
    Some([@lib.Instruction::i64_extend_i32s()])
  } else if name == b"dew_i16_into_u8" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_i16_into_u16" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_i16_into_u32" {
    Some([])
  } else if name == b"dew_i16_into_u64" {
    Some([@lib.Instruction::i64_extend_i32s()])
  } else if name == b"dew_i16_into_f32" {
    Some([@lib.Instruction::f32_convert_i32s()])
  } else if name == b"dew_i16_into_f64" {
    Some([@lib.Instruction::f64_convert_i32s()])
  } else if name == b"dew_i32_into_i8" {
    Some([@lib.Instruction::i32_extend8s()])
  } else if name == b"dew_i32_into_i16" {
    Some([@lib.Instruction::i32_extend16s()])
  } else if name == b"dew_i32_into_i32" {
    Some([])
  } else if name == b"dew_i32_into_i64" {
    Some([@lib.Instruction::i64_extend_i32s()])
  } else if name == b"dew_i32_into_u8" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_i32_into_u16" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_i32_into_u32" {
    Some([])
  } else if name == b"dew_i32_into_u64" {
    Some([@lib.Instruction::i64_extend_i32s()])
  } else if name == b"dew_i32_into_f32" {
    Some([@lib.Instruction::f32_convert_i32s()])
  } else if name == b"dew_i32_into_f64" {
    Some([@lib.Instruction::f64_convert_i32s()])
  } else if name == b"dew_i64_into_i8" {
    Some([@lib.Instruction::i32_wrap_i64(), @lib.Instruction::i32_extend8s()])
  } else if name == b"dew_i64_into_i16" {
    Some([@lib.Instruction::i32_wrap_i64(), @lib.Instruction::i32_extend16s()])
  } else if name == b"dew_i64_into_i32" {
    Some([@lib.Instruction::i32_wrap_i64()])
  } else if name == b"dew_i64_into_i64" {
    Some([])
  } else if name == b"dew_i64_into_u8" {
    Some([
      @lib.Instruction::i32_wrap_i64(),
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_i64_into_u16" {
    Some([
      @lib.Instruction::i32_wrap_i64(),
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_i64_into_u32" {
    Some([@lib.Instruction::i32_wrap_i64()])
  } else if name == b"dew_i64_into_u64" {
    Some([])
  } else if name == b"dew_i64_into_f32" {
    Some([@lib.Instruction::f32_convert_i64s()])
  } else if name == b"dew_i64_into_f64" {
    Some([@lib.Instruction::f64_convert_i64s()])
  } else if name == b"dew_u8_into_i8" {
    Some([@lib.Instruction::i32_extend8s()])
  } else if name == b"dew_u8_into_i16" {
    Some([@lib.Instruction::i32_extend16s()])
  } else if name == b"dew_u8_into_i32" {
    Some([])
  } else if name == b"dew_u8_into_i64" {
    Some([@lib.Instruction::i64_extend_i32u()])
  } else if name == b"dew_u8_into_u8" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u8_into_u16" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u8_into_u32" {
    Some([])
  } else if name == b"dew_u8_into_u64" {
    Some([@lib.Instruction::i64_extend_i32u()])
  } else if name == b"dew_u8_into_f32" {
    Some([@lib.Instruction::f32_convert_i32u()])
  } else if name == b"dew_u8_into_f64" {
    Some([@lib.Instruction::f64_convert_i32u()])
  } else if name == b"dew_u16_into_i8" {
    Some([@lib.Instruction::i32_extend8s()])
  } else if name == b"dew_u16_into_i16" {
    Some([@lib.Instruction::i32_extend16s()])
  } else if name == b"dew_u16_into_i32" {
    Some([])
  } else if name == b"dew_u16_into_i64" {
    Some([@lib.Instruction::i64_extend_i32u()])
  } else if name == b"dew_u16_into_u8" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u16_into_u16" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u16_into_u32" {
    Some([])
  } else if name == b"dew_u16_into_u64" {
    Some([@lib.Instruction::i64_extend_i32u()])
  } else if name == b"dew_u16_into_f32" {
    Some([@lib.Instruction::f32_convert_i32u()])
  } else if name == b"dew_u16_into_f64" {
    Some([@lib.Instruction::f64_convert_i32u()])
  } else if name == b"dew_u32_into_i8" {
    Some([@lib.Instruction::i32_extend8s()])
  } else if name == b"dew_u32_into_i16" {
    Some([@lib.Instruction::i32_extend16s()])
  } else if name == b"dew_u32_into_i32" {
    Some([])
  } else if name == b"dew_u32_into_i64" {
    Some([@lib.Instruction::i64_extend_i32u()])
  } else if name == b"dew_u32_into_u8" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u32_into_u16" {
    Some([
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u32_into_u32" {
    Some([])
  } else if name == b"dew_u32_into_u64" {
    Some([@lib.Instruction::i64_extend_i32u()])
  } else if name == b"dew_u32_into_f32" {
    Some([@lib.Instruction::f32_convert_i32u()])
  } else if name == b"dew_u32_into_f64" {
    Some([@lib.Instruction::f64_convert_i32u()])
  } else if name == b"dew_u64_into_i8" {
    Some([@lib.Instruction::i32_wrap_i64(), @lib.Instruction::i32_extend8s()])
  } else if name == b"dew_u64_into_i16" {
    Some([@lib.Instruction::i32_wrap_i64(), @lib.Instruction::i32_extend16s()])
  } else if name == b"dew_u64_into_i32" {
    Some([@lib.Instruction::i32_wrap_i64()])
  } else if name == b"dew_u64_into_i64" {
    Some([])
  } else if name == b"dew_u64_into_u8" {
    Some([
      @lib.Instruction::i32_wrap_i64(),
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u64_into_u16" {
    Some([
      @lib.Instruction::i32_wrap_i64(),
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_and(),
    ])
  } else if name == b"dew_u64_into_u32" {
    Some([@lib.Instruction::i32_wrap_i64()])
  } else if name == b"dew_u64_into_u64" {
    Some([])
  } else if name == b"dew_u64_into_f32" {
    Some([@lib.Instruction::f32_convert_i64u()])
  } else if name == b"dew_u64_into_f64" {
    Some([@lib.Instruction::f64_convert_i64u()])
  } else if name == b"dew_f32_into_i32" {
    Some([@lib.Instruction::i32_trunc_f32s()])
  } else if name == b"dew_f32_into_i64" {
    Some([@lib.Instruction::i64_trunc_f32s()])
  } else if name == b"dew_f32_into_u32" {
    Some([@lib.Instruction::i32_trunc_f32u()])
  } else if name == b"dew_f32_into_u64" {
    Some([@lib.Instruction::i64_trunc_f32u()])
  } else if name == b"dew_f32_into_f32" {
    Some([])
  } else if name == b"dew_f32_into_f64" {
    Some([@lib.Instruction::f64_promote_f32()])
  } else if name == b"dew_f64_into_i32" {
    Some([@lib.Instruction::i32_trunc_f64s()])
  } else if name == b"dew_f64_into_i64" {
    Some([@lib.Instruction::i64_trunc_f64s()])
  } else if name == b"dew_f64_into_u32" {
    Some([@lib.Instruction::i32_trunc_f64u()])
  } else if name == b"dew_f64_into_u64" {
    Some([@lib.Instruction::i64_trunc_f64u()])
  } else if name == b"dew_f64_into_f32" {
    Some([@lib.Instruction::f32_demote_f64()])
  } else if name == b"dew_f64_into_f64" {
    Some([])
  } else {
    None
  }
}
