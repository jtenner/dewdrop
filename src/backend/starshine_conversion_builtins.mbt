///|
fn starshine_conversion_trap_if() -> @lib.Instruction {
  @lib.Instruction::if_(
    @lib.BlockType::void_(),
    [@lib.Instruction::unreachable_()],
    None,
  )
}

///|
fn starshine_conversion_builtin_needs_scratch(name : Bytes) -> Bool {
  name == b"dew_f32_into_i8" ||
  name == b"dew_f32_into_i16" ||
  name == b"dew_f32_into_u8" ||
  name == b"dew_f32_into_u16" ||
  name == b"dew_f64_into_i8" ||
  name == b"dew_f64_into_i16" ||
  name == b"dew_f64_into_u8" ||
  name == b"dew_f64_into_u16"
}

///|
fn starshine_conversion_builtin_instructions(
  name : Bytes,
  scratch_index : Int,
) -> Array[@lib.Instruction]? {
  let scratch = @lib.LocalIdx::new(scratch_index.reinterpret_as_uint())
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
  } else if name == b"dew_f32_into_i8" {
    Some([
      @lib.Instruction::i32_trunc_f32s(),
      @lib.Instruction::local_tee(scratch),
      @lib.Instruction::i32_const(@lib.I32::new(-128)),
      @lib.Instruction::i32_lt_s(),
      starshine_conversion_trap_if(),
      @lib.Instruction::local_get(scratch),
      @lib.Instruction::i32_const(@lib.I32::new(127)),
      @lib.Instruction::i32_gt_s(),
      starshine_conversion_trap_if(),
      @lib.Instruction::local_get(scratch),
    ])
  } else if name == b"dew_f32_into_i16" {
    Some([
      @lib.Instruction::i32_trunc_f32s(),
      @lib.Instruction::local_tee(scratch),
      @lib.Instruction::i32_const(@lib.I32::new(-32768)),
      @lib.Instruction::i32_lt_s(),
      starshine_conversion_trap_if(),
      @lib.Instruction::local_get(scratch),
      @lib.Instruction::i32_const(@lib.I32::new(32767)),
      @lib.Instruction::i32_gt_s(),
      starshine_conversion_trap_if(),
      @lib.Instruction::local_get(scratch),
    ])
  } else if name == b"dew_f32_into_i32" {
    Some([@lib.Instruction::i32_trunc_f32s()])
  } else if name == b"dew_f32_into_i64" {
    Some([@lib.Instruction::i64_trunc_f32s()])
  } else if name == b"dew_f32_into_u8" {
    Some([
      @lib.Instruction::i32_trunc_f32u(),
      @lib.Instruction::local_tee(scratch),
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_gt_u(),
      starshine_conversion_trap_if(),
      @lib.Instruction::local_get(scratch),
    ])
  } else if name == b"dew_f32_into_u16" {
    Some([
      @lib.Instruction::i32_trunc_f32u(),
      @lib.Instruction::local_tee(scratch),
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_gt_u(),
      starshine_conversion_trap_if(),
      @lib.Instruction::local_get(scratch),
    ])
  } else if name == b"dew_f32_into_u32" {
    Some([@lib.Instruction::i32_trunc_f32u()])
  } else if name == b"dew_f32_into_u64" {
    Some([@lib.Instruction::i64_trunc_f32u()])
  } else if name == b"dew_f32_into_f32" {
    Some([])
  } else if name == b"dew_f32_into_f64" {
    Some([@lib.Instruction::f64_promote_f32()])
  } else if name == b"dew_f64_into_i8" {
    Some([
      @lib.Instruction::i32_trunc_f64s(),
      @lib.Instruction::local_tee(scratch),
      @lib.Instruction::i32_const(@lib.I32::new(-128)),
      @lib.Instruction::i32_lt_s(),
      starshine_conversion_trap_if(),
      @lib.Instruction::local_get(scratch),
      @lib.Instruction::i32_const(@lib.I32::new(127)),
      @lib.Instruction::i32_gt_s(),
      starshine_conversion_trap_if(),
      @lib.Instruction::local_get(scratch),
    ])
  } else if name == b"dew_f64_into_i16" {
    Some([
      @lib.Instruction::i32_trunc_f64s(),
      @lib.Instruction::local_tee(scratch),
      @lib.Instruction::i32_const(@lib.I32::new(-32768)),
      @lib.Instruction::i32_lt_s(),
      starshine_conversion_trap_if(),
      @lib.Instruction::local_get(scratch),
      @lib.Instruction::i32_const(@lib.I32::new(32767)),
      @lib.Instruction::i32_gt_s(),
      starshine_conversion_trap_if(),
      @lib.Instruction::local_get(scratch),
    ])
  } else if name == b"dew_f64_into_i32" {
    Some([@lib.Instruction::i32_trunc_f64s()])
  } else if name == b"dew_f64_into_i64" {
    Some([@lib.Instruction::i64_trunc_f64s()])
  } else if name == b"dew_f64_into_u8" {
    Some([
      @lib.Instruction::i32_trunc_f64u(),
      @lib.Instruction::local_tee(scratch),
      @lib.Instruction::i32_const(@lib.I32::new(255)),
      @lib.Instruction::i32_gt_u(),
      starshine_conversion_trap_if(),
      @lib.Instruction::local_get(scratch),
    ])
  } else if name == b"dew_f64_into_u16" {
    Some([
      @lib.Instruction::i32_trunc_f64u(),
      @lib.Instruction::local_tee(scratch),
      @lib.Instruction::i32_const(@lib.I32::new(65535)),
      @lib.Instruction::i32_gt_u(),
      starshine_conversion_trap_if(),
      @lib.Instruction::local_get(scratch),
    ])
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
