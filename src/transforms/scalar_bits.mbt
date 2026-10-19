///|
fn scalar_bit_opcode(opcode : String) -> Bool {
  [
    "i32.clz", "i64.clz", "i32.ctz", "i64.ctz", "i32.popcnt", "i64.popcnt", "i32.rotl",
    "i64.rotl", "i32.rotr", "i64.rotr", "i64.extend8_s", "i64.extend16_s", "i64.extend32_s",
  ].contains(opcode)
}

///|
fn scalar_bit_intrinsic(
  opcode : String,
  args : Array[Value],
) -> Value raise EvalError {
  let width = if opcode.has_prefix("i32.") { 32 } else { 64 }
  let kind = if width == 32 { "I32" } else { "I64" }
  let rotate = opcode.has_suffix(".rotl") || opcode.has_suffix(".rotr")
  guard args.length() == (if rotate { 2 } else { 1 }) else {
    return eval_fail("Wasm integer intrinsic argument count mismatch")
  }
  let mask = if width == 32 { 4294967295UL } else { 18446744073709551615UL }
  let bits = raw_bits(args[0]) & mask
  if opcode.has_prefix("i64.extend") {
    let shift = if opcode == "i64.extend8_s" {
      56
    } else if opcode == "i64.extend16_s" {
      48
    } else {
      32
    }
    return Number(
      (bits.reinterpret_as_int64() << shift >> shift).reinterpret_as_uint64(),
      kind,
    )
  }
  if rotate {
    let shift = (raw_bits(args[1]) & (width - 1).to_uint64()).to_int()
    if shift == 0 {
      return Number(bits, kind)
    }
    return Number(
      (if opcode.has_suffix(".rotl") {
        (bits << shift) | (bits >> (width - shift))
      } else {
        (bits >> shift) | (bits << (width - shift))
      }) &
      mask,
      kind,
    )
  }
  if bits == 0UL {
    return Number(
      if opcode.has_suffix(".popcnt") {
        0UL
      } else {
        width.to_uint64()
      },
      kind,
    )
  }
  let mut remaining = bits
  let mut count = 0UL
  if opcode.has_suffix(".popcnt") {
    while remaining != 0UL {
      remaining = remaining & (remaining - 1UL)
      count += 1UL
    }
  } else if opcode.has_suffix(".ctz") {
    while (remaining & 1UL) == 0UL {
      remaining = remaining >> 1
      count += 1UL
    }
  } else {
    let top = 1UL << (width - 1)
    while (remaining & top) == 0UL {
      remaining = remaining << 1
      count += 1UL
    }
  }
  Number(count, kind)
}
