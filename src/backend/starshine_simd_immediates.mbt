///|
fn starshine_simd_shuffle_instruction(name : Bytes) -> @lib.Instruction? {
  let lanes = match @semantic.raw_wasm_shuffle_immediates(name) {
    Some(values) => values
    None => return None
  }
  Some(
    @lib.Instruction::i8x16_shuffle(
      @lib.LaneIdx::new(lanes[0].to_byte()),
      @lib.LaneIdx::new(lanes[1].to_byte()),
      @lib.LaneIdx::new(lanes[2].to_byte()),
      @lib.LaneIdx::new(lanes[3].to_byte()),
      @lib.LaneIdx::new(lanes[4].to_byte()),
      @lib.LaneIdx::new(lanes[5].to_byte()),
      @lib.LaneIdx::new(lanes[6].to_byte()),
      @lib.LaneIdx::new(lanes[7].to_byte()),
      @lib.LaneIdx::new(lanes[8].to_byte()),
      @lib.LaneIdx::new(lanes[9].to_byte()),
      @lib.LaneIdx::new(lanes[10].to_byte()),
      @lib.LaneIdx::new(lanes[11].to_byte()),
      @lib.LaneIdx::new(lanes[12].to_byte()),
      @lib.LaneIdx::new(lanes[13].to_byte()),
      @lib.LaneIdx::new(lanes[14].to_byte()),
      @lib.LaneIdx::new(lanes[15].to_byte()),
    ),
  )
}
