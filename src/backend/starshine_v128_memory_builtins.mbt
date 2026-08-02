///|
fn starshine_v128_memory_builtin_instructions(
  name : Bytes,
) -> Array[@lib.Instruction]? {
  if name == b"dew_i8x16_load_splat" {
    Some([@lib.Instruction::v128_load8_splat(starshine_memory_argument(0U))])
  } else if name == b"dew_i8x16_load_lane_0" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_0" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_i8x16_load_lane_1" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_1" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_i8x16_load_lane_2" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x02'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_2" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x02'),
      ),
    ])
  } else if name == b"dew_i8x16_load_lane_3" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x03'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_3" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x03'),
      ),
    ])
  } else if name == b"dew_i8x16_load_lane_4" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x04'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_4" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x04'),
      ),
    ])
  } else if name == b"dew_i8x16_load_lane_5" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x05'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_5" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x05'),
      ),
    ])
  } else if name == b"dew_i8x16_load_lane_6" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x06'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_6" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x06'),
      ),
    ])
  } else if name == b"dew_i8x16_load_lane_7" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x07'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_7" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x07'),
      ),
    ])
  } else if name == b"dew_i8x16_load_lane_8" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x08'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_8" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x08'),
      ),
    ])
  } else if name == b"dew_i8x16_load_lane_9" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x09'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_9" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x09'),
      ),
    ])
  } else if name == b"dew_i8x16_load_lane_10" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0A'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_10" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0A'),
      ),
    ])
  } else if name == b"dew_i8x16_load_lane_11" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0B'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_11" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0B'),
      ),
    ])
  } else if name == b"dew_i8x16_load_lane_12" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0C'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_12" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0C'),
      ),
    ])
  } else if name == b"dew_i8x16_load_lane_13" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0D'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_13" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0D'),
      ),
    ])
  } else if name == b"dew_i8x16_load_lane_14" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0E'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_14" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0E'),
      ),
    ])
  } else if name == b"dew_i8x16_load_lane_15" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0F'),
      ),
    ])
  } else if name == b"dew_i8x16_store_lane_15" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0F'),
      ),
    ])
  } else if name == b"dew_u8x16_load_splat" {
    Some([@lib.Instruction::v128_load8_splat(starshine_memory_argument(0U))])
  } else if name == b"dew_u8x16_load_lane_0" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_0" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_u8x16_load_lane_1" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_1" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_u8x16_load_lane_2" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x02'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_2" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x02'),
      ),
    ])
  } else if name == b"dew_u8x16_load_lane_3" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x03'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_3" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x03'),
      ),
    ])
  } else if name == b"dew_u8x16_load_lane_4" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x04'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_4" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x04'),
      ),
    ])
  } else if name == b"dew_u8x16_load_lane_5" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x05'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_5" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x05'),
      ),
    ])
  } else if name == b"dew_u8x16_load_lane_6" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x06'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_6" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x06'),
      ),
    ])
  } else if name == b"dew_u8x16_load_lane_7" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x07'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_7" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x07'),
      ),
    ])
  } else if name == b"dew_u8x16_load_lane_8" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x08'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_8" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x08'),
      ),
    ])
  } else if name == b"dew_u8x16_load_lane_9" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x09'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_9" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x09'),
      ),
    ])
  } else if name == b"dew_u8x16_load_lane_10" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0A'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_10" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0A'),
      ),
    ])
  } else if name == b"dew_u8x16_load_lane_11" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0B'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_11" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0B'),
      ),
    ])
  } else if name == b"dew_u8x16_load_lane_12" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0C'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_12" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0C'),
      ),
    ])
  } else if name == b"dew_u8x16_load_lane_13" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0D'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_13" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0D'),
      ),
    ])
  } else if name == b"dew_u8x16_load_lane_14" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0E'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_14" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0E'),
      ),
    ])
  } else if name == b"dew_u8x16_load_lane_15" {
    Some([
      @lib.Instruction::v128_load8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0F'),
      ),
    ])
  } else if name == b"dew_u8x16_store_lane_15" {
    Some([
      @lib.Instruction::v128_store8_lane(
        starshine_memory_argument(0U),
        @lib.LaneIdx::new(b'\x0F'),
      ),
    ])
  } else if name == b"dew_i16x8_load_splat" {
    Some([@lib.Instruction::v128_load16_splat(starshine_memory_argument(1U))])
  } else if name == b"dew_i16x8_load_lane_0" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_i16x8_store_lane_0" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_i16x8_load_lane_1" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_i16x8_store_lane_1" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_i16x8_load_lane_2" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x02'),
      ),
    ])
  } else if name == b"dew_i16x8_store_lane_2" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x02'),
      ),
    ])
  } else if name == b"dew_i16x8_load_lane_3" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x03'),
      ),
    ])
  } else if name == b"dew_i16x8_store_lane_3" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x03'),
      ),
    ])
  } else if name == b"dew_i16x8_load_lane_4" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x04'),
      ),
    ])
  } else if name == b"dew_i16x8_store_lane_4" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x04'),
      ),
    ])
  } else if name == b"dew_i16x8_load_lane_5" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x05'),
      ),
    ])
  } else if name == b"dew_i16x8_store_lane_5" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x05'),
      ),
    ])
  } else if name == b"dew_i16x8_load_lane_6" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x06'),
      ),
    ])
  } else if name == b"dew_i16x8_store_lane_6" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x06'),
      ),
    ])
  } else if name == b"dew_i16x8_load_lane_7" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x07'),
      ),
    ])
  } else if name == b"dew_i16x8_store_lane_7" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x07'),
      ),
    ])
  } else if name == b"dew_u16x8_load_splat" {
    Some([@lib.Instruction::v128_load16_splat(starshine_memory_argument(1U))])
  } else if name == b"dew_u16x8_load_lane_0" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_u16x8_store_lane_0" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_u16x8_load_lane_1" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_u16x8_store_lane_1" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_u16x8_load_lane_2" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x02'),
      ),
    ])
  } else if name == b"dew_u16x8_store_lane_2" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x02'),
      ),
    ])
  } else if name == b"dew_u16x8_load_lane_3" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x03'),
      ),
    ])
  } else if name == b"dew_u16x8_store_lane_3" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x03'),
      ),
    ])
  } else if name == b"dew_u16x8_load_lane_4" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x04'),
      ),
    ])
  } else if name == b"dew_u16x8_store_lane_4" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x04'),
      ),
    ])
  } else if name == b"dew_u16x8_load_lane_5" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x05'),
      ),
    ])
  } else if name == b"dew_u16x8_store_lane_5" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x05'),
      ),
    ])
  } else if name == b"dew_u16x8_load_lane_6" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x06'),
      ),
    ])
  } else if name == b"dew_u16x8_store_lane_6" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x06'),
      ),
    ])
  } else if name == b"dew_u16x8_load_lane_7" {
    Some([
      @lib.Instruction::v128_load16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x07'),
      ),
    ])
  } else if name == b"dew_u16x8_store_lane_7" {
    Some([
      @lib.Instruction::v128_store16_lane(
        starshine_memory_argument(1U),
        @lib.LaneIdx::new(b'\x07'),
      ),
    ])
  } else if name == b"dew_i32x4_load_splat" {
    Some([@lib.Instruction::v128_load32_splat(starshine_memory_argument(2U))])
  } else if name == b"dew_i32x4_load_lane_0" {
    Some([
      @lib.Instruction::v128_load32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_i32x4_store_lane_0" {
    Some([
      @lib.Instruction::v128_store32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_i32x4_load_lane_1" {
    Some([
      @lib.Instruction::v128_load32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_i32x4_store_lane_1" {
    Some([
      @lib.Instruction::v128_store32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_i32x4_load_lane_2" {
    Some([
      @lib.Instruction::v128_load32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x02'),
      ),
    ])
  } else if name == b"dew_i32x4_store_lane_2" {
    Some([
      @lib.Instruction::v128_store32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x02'),
      ),
    ])
  } else if name == b"dew_i32x4_load_lane_3" {
    Some([
      @lib.Instruction::v128_load32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x03'),
      ),
    ])
  } else if name == b"dew_i32x4_store_lane_3" {
    Some([
      @lib.Instruction::v128_store32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x03'),
      ),
    ])
  } else if name == b"dew_u32x4_load_splat" {
    Some([@lib.Instruction::v128_load32_splat(starshine_memory_argument(2U))])
  } else if name == b"dew_u32x4_load_lane_0" {
    Some([
      @lib.Instruction::v128_load32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_u32x4_store_lane_0" {
    Some([
      @lib.Instruction::v128_store32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_u32x4_load_lane_1" {
    Some([
      @lib.Instruction::v128_load32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_u32x4_store_lane_1" {
    Some([
      @lib.Instruction::v128_store32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_u32x4_load_lane_2" {
    Some([
      @lib.Instruction::v128_load32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x02'),
      ),
    ])
  } else if name == b"dew_u32x4_store_lane_2" {
    Some([
      @lib.Instruction::v128_store32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x02'),
      ),
    ])
  } else if name == b"dew_u32x4_load_lane_3" {
    Some([
      @lib.Instruction::v128_load32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x03'),
      ),
    ])
  } else if name == b"dew_u32x4_store_lane_3" {
    Some([
      @lib.Instruction::v128_store32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x03'),
      ),
    ])
  } else if name == b"dew_i64x2_load_splat" {
    Some([@lib.Instruction::v128_load64_splat(starshine_memory_argument(3U))])
  } else if name == b"dew_i64x2_load_lane_0" {
    Some([
      @lib.Instruction::v128_load64_lane(
        starshine_memory_argument(3U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_i64x2_store_lane_0" {
    Some([
      @lib.Instruction::v128_store64_lane(
        starshine_memory_argument(3U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_i64x2_load_lane_1" {
    Some([
      @lib.Instruction::v128_load64_lane(
        starshine_memory_argument(3U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_i64x2_store_lane_1" {
    Some([
      @lib.Instruction::v128_store64_lane(
        starshine_memory_argument(3U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_u64x2_load_splat" {
    Some([@lib.Instruction::v128_load64_splat(starshine_memory_argument(3U))])
  } else if name == b"dew_u64x2_load_lane_0" {
    Some([
      @lib.Instruction::v128_load64_lane(
        starshine_memory_argument(3U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_u64x2_store_lane_0" {
    Some([
      @lib.Instruction::v128_store64_lane(
        starshine_memory_argument(3U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_u64x2_load_lane_1" {
    Some([
      @lib.Instruction::v128_load64_lane(
        starshine_memory_argument(3U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_u64x2_store_lane_1" {
    Some([
      @lib.Instruction::v128_store64_lane(
        starshine_memory_argument(3U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_f32x4_load_splat" {
    Some([@lib.Instruction::v128_load32_splat(starshine_memory_argument(2U))])
  } else if name == b"dew_f32x4_load_lane_0" {
    Some([
      @lib.Instruction::v128_load32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_f32x4_store_lane_0" {
    Some([
      @lib.Instruction::v128_store32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_f32x4_load_lane_1" {
    Some([
      @lib.Instruction::v128_load32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_f32x4_store_lane_1" {
    Some([
      @lib.Instruction::v128_store32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_f32x4_load_lane_2" {
    Some([
      @lib.Instruction::v128_load32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x02'),
      ),
    ])
  } else if name == b"dew_f32x4_store_lane_2" {
    Some([
      @lib.Instruction::v128_store32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x02'),
      ),
    ])
  } else if name == b"dew_f32x4_load_lane_3" {
    Some([
      @lib.Instruction::v128_load32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x03'),
      ),
    ])
  } else if name == b"dew_f32x4_store_lane_3" {
    Some([
      @lib.Instruction::v128_store32_lane(
        starshine_memory_argument(2U),
        @lib.LaneIdx::new(b'\x03'),
      ),
    ])
  } else if name == b"dew_f64x2_load_splat" {
    Some([@lib.Instruction::v128_load64_splat(starshine_memory_argument(3U))])
  } else if name == b"dew_f64x2_load_lane_0" {
    Some([
      @lib.Instruction::v128_load64_lane(
        starshine_memory_argument(3U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_f64x2_store_lane_0" {
    Some([
      @lib.Instruction::v128_store64_lane(
        starshine_memory_argument(3U),
        @lib.LaneIdx::new(b'\x00'),
      ),
    ])
  } else if name == b"dew_f64x2_load_lane_1" {
    Some([
      @lib.Instruction::v128_load64_lane(
        starshine_memory_argument(3U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_f64x2_store_lane_1" {
    Some([
      @lib.Instruction::v128_store64_lane(
        starshine_memory_argument(3U),
        @lib.LaneIdx::new(b'\x01'),
      ),
    ])
  } else if name == b"dew_i16x8_load_extend_i8x8_s" {
    Some([@lib.Instruction::v128_load8x8s(starshine_memory_argument(3U))])
  } else if name == b"dew_u16x8_load_extend_u8x8_u" {
    Some([@lib.Instruction::v128_load8x8u(starshine_memory_argument(3U))])
  } else if name == b"dew_i32x4_load_extend_i16x4_s" {
    Some([@lib.Instruction::v128_load16x4s(starshine_memory_argument(3U))])
  } else if name == b"dew_u32x4_load_extend_u16x4_u" {
    Some([@lib.Instruction::v128_load16x4u(starshine_memory_argument(3U))])
  } else if name == b"dew_i64x2_load_extend_i32x2_s" {
    Some([@lib.Instruction::v128_load32x2s(starshine_memory_argument(3U))])
  } else if name == b"dew_u64x2_load_extend_u32x2_u" {
    Some([@lib.Instruction::v128_load32x2u(starshine_memory_argument(3U))])
  } else if name == b"dew_i32x4_load_zero" {
    Some([@lib.Instruction::v128_load32_zero(starshine_memory_argument(2U))])
  } else if name == b"dew_u32x4_load_zero" {
    Some([@lib.Instruction::v128_load32_zero(starshine_memory_argument(2U))])
  } else if name == b"dew_f32x4_load_zero" {
    Some([@lib.Instruction::v128_load32_zero(starshine_memory_argument(2U))])
  } else if name == b"dew_i64x2_load_zero" {
    Some([@lib.Instruction::v128_load64_zero(starshine_memory_argument(3U))])
  } else if name == b"dew_u64x2_load_zero" {
    Some([@lib.Instruction::v128_load64_zero(starshine_memory_argument(3U))])
  } else if name == b"dew_f64x2_load_zero" {
    Some([@lib.Instruction::v128_load64_zero(starshine_memory_argument(3U))])
  } else {
    None
  }
}
