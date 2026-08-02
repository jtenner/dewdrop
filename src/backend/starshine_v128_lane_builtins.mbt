///|
fn starshine_v128_lane_builtin_instructions(
  name : Bytes,
) -> Array[@lib.Instruction]? {
  if name == b"dew_i8x16_extract_0" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_i8x16_replace_0" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_i8x16_extract_1" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_i8x16_replace_1" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_i8x16_extract_2" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x02'))])
  } else if name == b"dew_i8x16_replace_2" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x02'))])
  } else if name == b"dew_i8x16_extract_3" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x03'))])
  } else if name == b"dew_i8x16_replace_3" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x03'))])
  } else if name == b"dew_i8x16_extract_4" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x04'))])
  } else if name == b"dew_i8x16_replace_4" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x04'))])
  } else if name == b"dew_i8x16_extract_5" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x05'))])
  } else if name == b"dew_i8x16_replace_5" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x05'))])
  } else if name == b"dew_i8x16_extract_6" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x06'))])
  } else if name == b"dew_i8x16_replace_6" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x06'))])
  } else if name == b"dew_i8x16_extract_7" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x07'))])
  } else if name == b"dew_i8x16_replace_7" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x07'))])
  } else if name == b"dew_i8x16_extract_8" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x08'))])
  } else if name == b"dew_i8x16_replace_8" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x08'))])
  } else if name == b"dew_i8x16_extract_9" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x09'))])
  } else if name == b"dew_i8x16_replace_9" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x09'))])
  } else if name == b"dew_i8x16_extract_10" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x0A'))])
  } else if name == b"dew_i8x16_replace_10" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x0A'))])
  } else if name == b"dew_i8x16_extract_11" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x0B'))])
  } else if name == b"dew_i8x16_replace_11" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x0B'))])
  } else if name == b"dew_i8x16_extract_12" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x0C'))])
  } else if name == b"dew_i8x16_replace_12" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x0C'))])
  } else if name == b"dew_i8x16_extract_13" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x0D'))])
  } else if name == b"dew_i8x16_replace_13" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x0D'))])
  } else if name == b"dew_i8x16_extract_14" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x0E'))])
  } else if name == b"dew_i8x16_replace_14" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x0E'))])
  } else if name == b"dew_i8x16_extract_15" {
    Some([@lib.Instruction::i8x16_extract_lane_s(@lib.LaneIdx::new(b'\x0F'))])
  } else if name == b"dew_i8x16_replace_15" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x0F'))])
  } else if name == b"dew_u8x16_extract_0" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_u8x16_replace_0" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_u8x16_extract_1" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_u8x16_replace_1" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_u8x16_extract_2" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x02'))])
  } else if name == b"dew_u8x16_replace_2" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x02'))])
  } else if name == b"dew_u8x16_extract_3" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x03'))])
  } else if name == b"dew_u8x16_replace_3" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x03'))])
  } else if name == b"dew_u8x16_extract_4" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x04'))])
  } else if name == b"dew_u8x16_replace_4" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x04'))])
  } else if name == b"dew_u8x16_extract_5" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x05'))])
  } else if name == b"dew_u8x16_replace_5" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x05'))])
  } else if name == b"dew_u8x16_extract_6" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x06'))])
  } else if name == b"dew_u8x16_replace_6" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x06'))])
  } else if name == b"dew_u8x16_extract_7" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x07'))])
  } else if name == b"dew_u8x16_replace_7" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x07'))])
  } else if name == b"dew_u8x16_extract_8" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x08'))])
  } else if name == b"dew_u8x16_replace_8" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x08'))])
  } else if name == b"dew_u8x16_extract_9" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x09'))])
  } else if name == b"dew_u8x16_replace_9" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x09'))])
  } else if name == b"dew_u8x16_extract_10" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x0A'))])
  } else if name == b"dew_u8x16_replace_10" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x0A'))])
  } else if name == b"dew_u8x16_extract_11" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x0B'))])
  } else if name == b"dew_u8x16_replace_11" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x0B'))])
  } else if name == b"dew_u8x16_extract_12" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x0C'))])
  } else if name == b"dew_u8x16_replace_12" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x0C'))])
  } else if name == b"dew_u8x16_extract_13" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x0D'))])
  } else if name == b"dew_u8x16_replace_13" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x0D'))])
  } else if name == b"dew_u8x16_extract_14" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x0E'))])
  } else if name == b"dew_u8x16_replace_14" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x0E'))])
  } else if name == b"dew_u8x16_extract_15" {
    Some([@lib.Instruction::i8x16_extract_lane_u(@lib.LaneIdx::new(b'\x0F'))])
  } else if name == b"dew_u8x16_replace_15" {
    Some([@lib.Instruction::i8x16_replace_lane(@lib.LaneIdx::new(b'\x0F'))])
  } else if name == b"dew_i16x8_extract_0" {
    Some([@lib.Instruction::i16x8_extract_lane_s(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_i16x8_replace_0" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_i16x8_extract_1" {
    Some([@lib.Instruction::i16x8_extract_lane_s(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_i16x8_replace_1" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_i16x8_extract_2" {
    Some([@lib.Instruction::i16x8_extract_lane_s(@lib.LaneIdx::new(b'\x02'))])
  } else if name == b"dew_i16x8_replace_2" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x02'))])
  } else if name == b"dew_i16x8_extract_3" {
    Some([@lib.Instruction::i16x8_extract_lane_s(@lib.LaneIdx::new(b'\x03'))])
  } else if name == b"dew_i16x8_replace_3" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x03'))])
  } else if name == b"dew_i16x8_extract_4" {
    Some([@lib.Instruction::i16x8_extract_lane_s(@lib.LaneIdx::new(b'\x04'))])
  } else if name == b"dew_i16x8_replace_4" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x04'))])
  } else if name == b"dew_i16x8_extract_5" {
    Some([@lib.Instruction::i16x8_extract_lane_s(@lib.LaneIdx::new(b'\x05'))])
  } else if name == b"dew_i16x8_replace_5" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x05'))])
  } else if name == b"dew_i16x8_extract_6" {
    Some([@lib.Instruction::i16x8_extract_lane_s(@lib.LaneIdx::new(b'\x06'))])
  } else if name == b"dew_i16x8_replace_6" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x06'))])
  } else if name == b"dew_i16x8_extract_7" {
    Some([@lib.Instruction::i16x8_extract_lane_s(@lib.LaneIdx::new(b'\x07'))])
  } else if name == b"dew_i16x8_replace_7" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x07'))])
  } else if name == b"dew_u16x8_extract_0" {
    Some([@lib.Instruction::i16x8_extract_lane_u(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_u16x8_replace_0" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_u16x8_extract_1" {
    Some([@lib.Instruction::i16x8_extract_lane_u(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_u16x8_replace_1" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_u16x8_extract_2" {
    Some([@lib.Instruction::i16x8_extract_lane_u(@lib.LaneIdx::new(b'\x02'))])
  } else if name == b"dew_u16x8_replace_2" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x02'))])
  } else if name == b"dew_u16x8_extract_3" {
    Some([@lib.Instruction::i16x8_extract_lane_u(@lib.LaneIdx::new(b'\x03'))])
  } else if name == b"dew_u16x8_replace_3" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x03'))])
  } else if name == b"dew_u16x8_extract_4" {
    Some([@lib.Instruction::i16x8_extract_lane_u(@lib.LaneIdx::new(b'\x04'))])
  } else if name == b"dew_u16x8_replace_4" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x04'))])
  } else if name == b"dew_u16x8_extract_5" {
    Some([@lib.Instruction::i16x8_extract_lane_u(@lib.LaneIdx::new(b'\x05'))])
  } else if name == b"dew_u16x8_replace_5" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x05'))])
  } else if name == b"dew_u16x8_extract_6" {
    Some([@lib.Instruction::i16x8_extract_lane_u(@lib.LaneIdx::new(b'\x06'))])
  } else if name == b"dew_u16x8_replace_6" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x06'))])
  } else if name == b"dew_u16x8_extract_7" {
    Some([@lib.Instruction::i16x8_extract_lane_u(@lib.LaneIdx::new(b'\x07'))])
  } else if name == b"dew_u16x8_replace_7" {
    Some([@lib.Instruction::i16x8_replace_lane(@lib.LaneIdx::new(b'\x07'))])
  } else if name == b"dew_i32x4_extract_0" {
    Some([@lib.Instruction::i32x4_extract_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_i32x4_replace_0" {
    Some([@lib.Instruction::i32x4_replace_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_i32x4_extract_1" {
    Some([@lib.Instruction::i32x4_extract_lane(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_i32x4_replace_1" {
    Some([@lib.Instruction::i32x4_replace_lane(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_i32x4_extract_2" {
    Some([@lib.Instruction::i32x4_extract_lane(@lib.LaneIdx::new(b'\x02'))])
  } else if name == b"dew_i32x4_replace_2" {
    Some([@lib.Instruction::i32x4_replace_lane(@lib.LaneIdx::new(b'\x02'))])
  } else if name == b"dew_i32x4_extract_3" {
    Some([@lib.Instruction::i32x4_extract_lane(@lib.LaneIdx::new(b'\x03'))])
  } else if name == b"dew_i32x4_replace_3" {
    Some([@lib.Instruction::i32x4_replace_lane(@lib.LaneIdx::new(b'\x03'))])
  } else if name == b"dew_u32x4_extract_0" {
    Some([@lib.Instruction::i32x4_extract_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_u32x4_replace_0" {
    Some([@lib.Instruction::i32x4_replace_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_u32x4_extract_1" {
    Some([@lib.Instruction::i32x4_extract_lane(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_u32x4_replace_1" {
    Some([@lib.Instruction::i32x4_replace_lane(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_u32x4_extract_2" {
    Some([@lib.Instruction::i32x4_extract_lane(@lib.LaneIdx::new(b'\x02'))])
  } else if name == b"dew_u32x4_replace_2" {
    Some([@lib.Instruction::i32x4_replace_lane(@lib.LaneIdx::new(b'\x02'))])
  } else if name == b"dew_u32x4_extract_3" {
    Some([@lib.Instruction::i32x4_extract_lane(@lib.LaneIdx::new(b'\x03'))])
  } else if name == b"dew_u32x4_replace_3" {
    Some([@lib.Instruction::i32x4_replace_lane(@lib.LaneIdx::new(b'\x03'))])
  } else if name == b"dew_i64x2_extract_0" {
    Some([@lib.Instruction::i64x2_extract_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_i64x2_replace_0" {
    Some([@lib.Instruction::i64x2_replace_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_i64x2_extract_1" {
    Some([@lib.Instruction::i64x2_extract_lane(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_i64x2_replace_1" {
    Some([@lib.Instruction::i64x2_replace_lane(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_u64x2_extract_0" {
    Some([@lib.Instruction::i64x2_extract_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_u64x2_replace_0" {
    Some([@lib.Instruction::i64x2_replace_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_u64x2_extract_1" {
    Some([@lib.Instruction::i64x2_extract_lane(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_u64x2_replace_1" {
    Some([@lib.Instruction::i64x2_replace_lane(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_f32x4_extract_0" {
    Some([@lib.Instruction::f32x4_extract_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_f32x4_replace_0" {
    Some([@lib.Instruction::f32x4_replace_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_f32x4_extract_1" {
    Some([@lib.Instruction::f32x4_extract_lane(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_f32x4_replace_1" {
    Some([@lib.Instruction::f32x4_replace_lane(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_f32x4_extract_2" {
    Some([@lib.Instruction::f32x4_extract_lane(@lib.LaneIdx::new(b'\x02'))])
  } else if name == b"dew_f32x4_replace_2" {
    Some([@lib.Instruction::f32x4_replace_lane(@lib.LaneIdx::new(b'\x02'))])
  } else if name == b"dew_f32x4_extract_3" {
    Some([@lib.Instruction::f32x4_extract_lane(@lib.LaneIdx::new(b'\x03'))])
  } else if name == b"dew_f32x4_replace_3" {
    Some([@lib.Instruction::f32x4_replace_lane(@lib.LaneIdx::new(b'\x03'))])
  } else if name == b"dew_f64x2_extract_0" {
    Some([@lib.Instruction::f64x2_extract_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_f64x2_replace_0" {
    Some([@lib.Instruction::f64x2_replace_lane(@lib.LaneIdx::new(b'\x00'))])
  } else if name == b"dew_f64x2_extract_1" {
    Some([@lib.Instruction::f64x2_extract_lane(@lib.LaneIdx::new(b'\x01'))])
  } else if name == b"dew_f64x2_replace_1" {
    Some([@lib.Instruction::f64x2_replace_lane(@lib.LaneIdx::new(b'\x01'))])
  } else {
    None
  }
}
