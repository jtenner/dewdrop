///|
/// Parse the same canonical decimal lane grammar as the raw Wasm catalog.
fn vector_shuffle_lanes(opcode : String) -> Array[Int32]? {
  guard opcode.has_prefix("i8x16.shuffle ") else { return None }
  let lanes : Array[Int32] = []
  let mut at = 14
  for lane in 0..<16 {
    guard at < opcode.length() else { return None }
    let first = opcode.code_unit_at(at).to_int() - 48
    guard first >= 0 && first <= 9 else { return None }
    let mut selected = first
    at += 1
    if at < opcode.length() && opcode.code_unit_at(at).to_int() != 32 {
      guard first != 0 else { return None }
      let second = opcode.code_unit_at(at).to_int() - 48
      guard second >= 0 && second <= 9 else { return None }
      selected = first * 10 + second
      at += 1
    }
    guard selected < 32 else { return None }
    lanes.push(selected)
    if lane < 15 {
      guard at < opcode.length() && opcode.code_unit_at(at).to_int() == 32 else {
        return None
      }
      at += 1
    } else {
      guard at == opcode.length() else { return None }
    }
  }
  Some(lanes)
}
