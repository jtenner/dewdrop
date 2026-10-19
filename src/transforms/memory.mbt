///|
struct MemoryOpcode {
  mode : Int32
  size : Int32
  lane : Int32
  signed_ : Bool
  kind : String
}

///|
// Exact instruction spellings, including canonical lane immediates.
fn memory_opcode(opcode : String) -> MemoryOpcode? {
  match opcode {
    "i32.load" =>
      Some({ mode: 0, size: 4, lane: 0, signed_: false, kind: "I32", })
    "i32.load8_s" =>
      Some({ mode: 0, size: 1, lane: 0, signed_: true, kind: "I32", })
    "i32.load8_u" =>
      Some({ mode: 0, size: 1, lane: 0, signed_: false, kind: "I32", })
    "i32.load16_s" =>
      Some({ mode: 0, size: 2, lane: 0, signed_: true, kind: "I32", })
    "i32.load16_u" =>
      Some({ mode: 0, size: 2, lane: 0, signed_: false, kind: "I32", })
    "i64.load" =>
      Some({ mode: 0, size: 8, lane: 0, signed_: false, kind: "I64", })
    "f32.load" =>
      Some({ mode: 0, size: 4, lane: 0, signed_: false, kind: "F32", })
    "f64.load" =>
      Some({ mode: 0, size: 8, lane: 0, signed_: false, kind: "F64", })
    "i32.store" =>
      Some({ mode: 1, size: 4, lane: 0, signed_: false, kind: "I32", })
    "i32.store8" =>
      Some({ mode: 1, size: 1, lane: 0, signed_: false, kind: "I32", })
    "i32.store16" =>
      Some({ mode: 1, size: 2, lane: 0, signed_: false, kind: "I32", })
    "i64.store" =>
      Some({ mode: 1, size: 8, lane: 0, signed_: false, kind: "I64", })
    "f32.store" =>
      Some({ mode: 1, size: 4, lane: 0, signed_: false, kind: "F32", })
    "f64.store" =>
      Some({ mode: 1, size: 8, lane: 0, signed_: false, kind: "F64", })
    "v128.load" =>
      Some({ mode: 2, size: 16, lane: 0, signed_: false, kind: "V128", })
    "v128.store" =>
      Some({ mode: 3, size: 16, lane: 0, signed_: false, kind: "V128", })
    "v128.load8_splat" =>
      Some({ mode: 4, size: 1, lane: 0, signed_: false, kind: "V128", })
    "v128.load8_lane 0" =>
      Some({ mode: 7, size: 1, lane: 0, signed_: false, kind: "V128", })
    "v128.store8_lane 0" =>
      Some({ mode: 8, size: 1, lane: 0, signed_: false, kind: "V128", })
    "v128.load8_lane 1" =>
      Some({ mode: 7, size: 1, lane: 1, signed_: false, kind: "V128", })
    "v128.store8_lane 1" =>
      Some({ mode: 8, size: 1, lane: 1, signed_: false, kind: "V128", })
    "v128.load8_lane 2" =>
      Some({ mode: 7, size: 1, lane: 2, signed_: false, kind: "V128", })
    "v128.store8_lane 2" =>
      Some({ mode: 8, size: 1, lane: 2, signed_: false, kind: "V128", })
    "v128.load8_lane 3" =>
      Some({ mode: 7, size: 1, lane: 3, signed_: false, kind: "V128", })
    "v128.store8_lane 3" =>
      Some({ mode: 8, size: 1, lane: 3, signed_: false, kind: "V128", })
    "v128.load8_lane 4" =>
      Some({ mode: 7, size: 1, lane: 4, signed_: false, kind: "V128", })
    "v128.store8_lane 4" =>
      Some({ mode: 8, size: 1, lane: 4, signed_: false, kind: "V128", })
    "v128.load8_lane 5" =>
      Some({ mode: 7, size: 1, lane: 5, signed_: false, kind: "V128", })
    "v128.store8_lane 5" =>
      Some({ mode: 8, size: 1, lane: 5, signed_: false, kind: "V128", })
    "v128.load8_lane 6" =>
      Some({ mode: 7, size: 1, lane: 6, signed_: false, kind: "V128", })
    "v128.store8_lane 6" =>
      Some({ mode: 8, size: 1, lane: 6, signed_: false, kind: "V128", })
    "v128.load8_lane 7" =>
      Some({ mode: 7, size: 1, lane: 7, signed_: false, kind: "V128", })
    "v128.store8_lane 7" =>
      Some({ mode: 8, size: 1, lane: 7, signed_: false, kind: "V128", })
    "v128.load8_lane 8" =>
      Some({ mode: 7, size: 1, lane: 8, signed_: false, kind: "V128", })
    "v128.store8_lane 8" =>
      Some({ mode: 8, size: 1, lane: 8, signed_: false, kind: "V128", })
    "v128.load8_lane 9" =>
      Some({ mode: 7, size: 1, lane: 9, signed_: false, kind: "V128", })
    "v128.store8_lane 9" =>
      Some({ mode: 8, size: 1, lane: 9, signed_: false, kind: "V128", })
    "v128.load8_lane 10" =>
      Some({ mode: 7, size: 1, lane: 10, signed_: false, kind: "V128", })
    "v128.store8_lane 10" =>
      Some({ mode: 8, size: 1, lane: 10, signed_: false, kind: "V128", })
    "v128.load8_lane 11" =>
      Some({ mode: 7, size: 1, lane: 11, signed_: false, kind: "V128", })
    "v128.store8_lane 11" =>
      Some({ mode: 8, size: 1, lane: 11, signed_: false, kind: "V128", })
    "v128.load8_lane 12" =>
      Some({ mode: 7, size: 1, lane: 12, signed_: false, kind: "V128", })
    "v128.store8_lane 12" =>
      Some({ mode: 8, size: 1, lane: 12, signed_: false, kind: "V128", })
    "v128.load8_lane 13" =>
      Some({ mode: 7, size: 1, lane: 13, signed_: false, kind: "V128", })
    "v128.store8_lane 13" =>
      Some({ mode: 8, size: 1, lane: 13, signed_: false, kind: "V128", })
    "v128.load8_lane 14" =>
      Some({ mode: 7, size: 1, lane: 14, signed_: false, kind: "V128", })
    "v128.store8_lane 14" =>
      Some({ mode: 8, size: 1, lane: 14, signed_: false, kind: "V128", })
    "v128.load8_lane 15" =>
      Some({ mode: 7, size: 1, lane: 15, signed_: false, kind: "V128", })
    "v128.store8_lane 15" =>
      Some({ mode: 8, size: 1, lane: 15, signed_: false, kind: "V128", })
    "v128.load16_splat" =>
      Some({ mode: 4, size: 2, lane: 0, signed_: false, kind: "V128", })
    "v128.load16_lane 0" =>
      Some({ mode: 7, size: 2, lane: 0, signed_: false, kind: "V128", })
    "v128.store16_lane 0" =>
      Some({ mode: 8, size: 2, lane: 0, signed_: false, kind: "V128", })
    "v128.load16_lane 1" =>
      Some({ mode: 7, size: 2, lane: 1, signed_: false, kind: "V128", })
    "v128.store16_lane 1" =>
      Some({ mode: 8, size: 2, lane: 1, signed_: false, kind: "V128", })
    "v128.load16_lane 2" =>
      Some({ mode: 7, size: 2, lane: 2, signed_: false, kind: "V128", })
    "v128.store16_lane 2" =>
      Some({ mode: 8, size: 2, lane: 2, signed_: false, kind: "V128", })
    "v128.load16_lane 3" =>
      Some({ mode: 7, size: 2, lane: 3, signed_: false, kind: "V128", })
    "v128.store16_lane 3" =>
      Some({ mode: 8, size: 2, lane: 3, signed_: false, kind: "V128", })
    "v128.load16_lane 4" =>
      Some({ mode: 7, size: 2, lane: 4, signed_: false, kind: "V128", })
    "v128.store16_lane 4" =>
      Some({ mode: 8, size: 2, lane: 4, signed_: false, kind: "V128", })
    "v128.load16_lane 5" =>
      Some({ mode: 7, size: 2, lane: 5, signed_: false, kind: "V128", })
    "v128.store16_lane 5" =>
      Some({ mode: 8, size: 2, lane: 5, signed_: false, kind: "V128", })
    "v128.load16_lane 6" =>
      Some({ mode: 7, size: 2, lane: 6, signed_: false, kind: "V128", })
    "v128.store16_lane 6" =>
      Some({ mode: 8, size: 2, lane: 6, signed_: false, kind: "V128", })
    "v128.load16_lane 7" =>
      Some({ mode: 7, size: 2, lane: 7, signed_: false, kind: "V128", })
    "v128.store16_lane 7" =>
      Some({ mode: 8, size: 2, lane: 7, signed_: false, kind: "V128", })
    "v128.load32_splat" =>
      Some({ mode: 4, size: 4, lane: 0, signed_: false, kind: "V128", })
    "v128.load32_lane 0" =>
      Some({ mode: 7, size: 4, lane: 0, signed_: false, kind: "V128", })
    "v128.store32_lane 0" =>
      Some({ mode: 8, size: 4, lane: 0, signed_: false, kind: "V128", })
    "v128.load32_lane 1" =>
      Some({ mode: 7, size: 4, lane: 1, signed_: false, kind: "V128", })
    "v128.store32_lane 1" =>
      Some({ mode: 8, size: 4, lane: 1, signed_: false, kind: "V128", })
    "v128.load32_lane 2" =>
      Some({ mode: 7, size: 4, lane: 2, signed_: false, kind: "V128", })
    "v128.store32_lane 2" =>
      Some({ mode: 8, size: 4, lane: 2, signed_: false, kind: "V128", })
    "v128.load32_lane 3" =>
      Some({ mode: 7, size: 4, lane: 3, signed_: false, kind: "V128", })
    "v128.store32_lane 3" =>
      Some({ mode: 8, size: 4, lane: 3, signed_: false, kind: "V128", })
    "v128.load64_splat" =>
      Some({ mode: 4, size: 8, lane: 0, signed_: false, kind: "V128", })
    "v128.load64_lane 0" =>
      Some({ mode: 7, size: 8, lane: 0, signed_: false, kind: "V128", })
    "v128.store64_lane 0" =>
      Some({ mode: 8, size: 8, lane: 0, signed_: false, kind: "V128", })
    "v128.load64_lane 1" =>
      Some({ mode: 7, size: 8, lane: 1, signed_: false, kind: "V128", })
    "v128.store64_lane 1" =>
      Some({ mode: 8, size: 8, lane: 1, signed_: false, kind: "V128", })
    "v128.load8x8_s" =>
      Some({ mode: 5, size: 1, lane: 0, signed_: true, kind: "V128", })
    "v128.load8x8_u" =>
      Some({ mode: 5, size: 1, lane: 0, signed_: false, kind: "V128", })
    "v128.load16x4_s" =>
      Some({ mode: 5, size: 2, lane: 0, signed_: true, kind: "V128", })
    "v128.load16x4_u" =>
      Some({ mode: 5, size: 2, lane: 0, signed_: false, kind: "V128", })
    "v128.load32x2_s" =>
      Some({ mode: 5, size: 4, lane: 0, signed_: true, kind: "V128", })
    "v128.load32x2_u" =>
      Some({ mode: 5, size: 4, lane: 0, signed_: false, kind: "V128", })
    "v128.load32_zero" =>
      Some({ mode: 6, size: 4, lane: 0, signed_: false, kind: "V128", })
    "v128.load64_zero" =>
      Some({ mode: 6, size: 8, lane: 0, signed_: false, kind: "V128", })
    _ => None
  }
}

///|
fn Machine::memory_instruction(
  self : Machine,
  code : MemoryOpcode,
  args : Array[Value],
) -> Value raise EvalError {
  let store = code.mode == 1 || code.mode == 3 || code.mode == 8
  let arity = if store || code.mode == 7 { 2 } else { 1 }
  guard args.length() == arity else {
    return eval_fail("Wasm memory instruction argument count mismatch")
  }
  guard intrinsic_value_carrier(args[0]) == "i32" else {
    return eval_fail("Wasm memory address requires an i32 carrier")
  }
  if arity == 2 {
    guard intrinsic_value_carrier(args[1]) == intrinsic_kind_carrier(code.kind) else {
      return eval_fail("Wasm memory value has an incompatible carrier")
    }
  }
  let size = if code.mode == 5 { 8 } else { code.size }
  let address = raw_bits(args[0]) & 4294967295UL
  guard address <= 65536UL && size.to_uint64() <= 65536UL - address else {
    return eval_fail("Wasm memory access out of bounds at compile time")
  }
  let memory = match self.memory {
    Some(value) => value
    None => {
      self.charge(65536)
      let value = FixedArray::make(65536, b'\x00')
      self.memory = Some(value)
      value
    }
  }
  let at = address.to_int()
  if store {
    let bits = if code.mode == 1 { vector_scalar_bits(args[1]) } else { 0UL }
    for i in 0..<size {
      memory[at + i] = if code.mode == 1 {
        (bits >> (i * 8)).to_byte()
      } else {
        vector_byte(
          args[1],
          (if code.mode == 8 { code.lane * size } else { 0 }) + i,
        ).to_byte()
      }
    }
    return Unit
  }
  if code.mode == 0 {
    let mut bits = 0UL
    for i in 0..<size {
      bits = bits | (memory[at + i].to_uint64() << (i * 8))
    }
    if code.signed_ {
      bits = vector_signed(bits, size * 8).reinterpret_as_uint64()
    }
    return if code.kind == "F32" || code.kind == "F64" {
      Floating(bits, code.kind)
    } else {
      normalized(bits, code.kind)
    }
  }
  let mut result = if code.mode == 7 { args[1] } else { Vector(0UL, 0UL) }
  let count = if code.mode == 7 || code.mode == 6 { size } else { 16 }
  for i in 0..<count {
    let byte = if code.mode == 4 {
      memory[at + i % size]
    } else if code.mode == 5 {
      let lane = i / (code.size * 2)
      let index = i % (code.size * 2)
      if index < code.size {
        memory[at + lane * code.size + index]
      } else if code.signed_ &&
        (memory[at + (lane + 1) * code.size - 1].to_uint() & 128U) != 0U {
        b'\xff'
      } else {
        b'\x00'
      }
    } else {
      memory[at + i]
    }
    result = vector_replace(
      result,
      (if code.mode == 7 { code.lane * size } else { 0 }) + i,
      byte.to_uint64(),
    )
  }
  result
}
