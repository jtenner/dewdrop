///|
fn starshine_memory_argument(align : UInt) -> @lib.MemArg {
  @lib.MemArg::new(@lib.U32::new(align), None, @lib.U64::new(0UL))
}

///|
fn starshine_memory_builtin_instructions(
  name : Bytes,
) -> Array[@lib.Instruction]? {
  if name == b"dew_i8_load" {
    Some([@lib.Instruction::i32_load8s(starshine_memory_argument(0U))])
  } else if name == b"dew_i8_store" {
    Some([@lib.Instruction::i32_store8(starshine_memory_argument(0U))])
  } else if name == b"dew_u8_load" {
    Some([@lib.Instruction::i32_load8u(starshine_memory_argument(0U))])
  } else if name == b"dew_u8_store" {
    Some([@lib.Instruction::i32_store8(starshine_memory_argument(0U))])
  } else if name == b"dew_i16_load" {
    Some([@lib.Instruction::i32_load16s(starshine_memory_argument(1U))])
  } else if name == b"dew_i16_store" {
    Some([@lib.Instruction::i32_store16(starshine_memory_argument(1U))])
  } else if name == b"dew_u16_load" {
    Some([@lib.Instruction::i32_load16u(starshine_memory_argument(1U))])
  } else if name == b"dew_u16_store" {
    Some([@lib.Instruction::i32_store16(starshine_memory_argument(1U))])
  } else if name == b"i32.load" {
    Some([@lib.Instruction::i32_load(starshine_memory_argument(2U))])
  } else if name == b"i32.store" {
    Some([@lib.Instruction::i32_store(starshine_memory_argument(2U))])
  } else if name == b"i64.load" {
    Some([@lib.Instruction::i64_load(starshine_memory_argument(3U))])
  } else if name == b"i64.store" {
    Some([@lib.Instruction::i64_store(starshine_memory_argument(3U))])
  } else if name == b"dew_f32_load" {
    Some([@lib.Instruction::f32_load(starshine_memory_argument(2U))])
  } else if name == b"dew_f32_store" {
    Some([@lib.Instruction::f32_store(starshine_memory_argument(2U))])
  } else if name == b"dew_f64_load" {
    Some([@lib.Instruction::f64_load(starshine_memory_argument(3U))])
  } else if name == b"dew_f64_store" {
    Some([@lib.Instruction::f64_store(starshine_memory_argument(3U))])
  } else if name == b"v128.load" {
    Some([@lib.Instruction::v128_load(starshine_memory_argument(4U))])
  } else if name == b"v128.store" {
    Some([@lib.Instruction::v128_store(starshine_memory_argument(4U))])
  } else {
    None
  }
}
