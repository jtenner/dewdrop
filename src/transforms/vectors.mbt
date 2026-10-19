///|
fn vector_byte(value : Value, lane : Int) -> UInt64 raise EvalError {
  guard value is Vector(low, high) && lane >= 0 && lane < 16 else {
    raise Failed("Wasm vector instruction requires a 128-bit vector and valid lane")
  }
  if lane < 8 { (low >> (lane * 8)) & 255UL } else { (high >> ((lane - 8) * 8)) & 255UL }
}

///|
fn vector_replace(value : Value, lane : Int, byte : UInt64) -> Value raise EvalError {
  guard value is Vector(low, high) && lane >= 0 && lane < 16 else {
    return eval_fail("Wasm vector lane out of bounds at compile time")
  }
  if lane < 8 {
    let shift = lane * 8
    Vector((low & (255UL << shift).lnot()) | ((byte & 255UL) << shift), high)
  } else {
    let shift = (lane - 8) * 8
    Vector(low, (high & (255UL << shift).lnot()) | ((byte & 255UL) << shift))
  }
}

///|
fn vector_intrinsic(opcode : String, args : Array[Value]) -> Value raise EvalError {
  match (opcode, args[:]) {
    ("i8x16.splat", [value]) => {
      let lane = raw_bits(value) & 255UL
      let packed = lane * 72340172838076673UL
      Vector(packed, packed)
    }
    ("i64x2.splat", [value]) => { let bits = raw_bits(value); Vector(bits, bits) }
    ("v128.bitselect", [Vector(al, ah), Vector(bl, bh), Vector(ml, mh)]) =>
      Vector((al & ml) | (bl & ml.lnot()), (ah & mh) | (bh & mh.lnot()))
    (name, [left, right]) if ["i8x16.eq", "i8x16.swizzle", "i8x16.add", "i8x16.sub", "v128.or", "v128.and", "v128.xor", "i8x16.lt_u"].contains(name) => {
      let mut result = Vector(0UL, 0UL)
      for lane in 0..<16 {
        let a = vector_byte(left, lane)
        let b = vector_byte(right, lane)
        let byte = if opcode == "i8x16.add" { a + b
        } else if opcode == "i8x16.sub" { a - b
        } else if opcode == "v128.or" { a | b
        } else if opcode == "v128.and" { a & b
        } else if opcode == "v128.xor" { a ^ b
        } else if opcode == "i8x16.lt_u" { if a < b { 255UL } else { 0UL }
        } else if opcode == "i8x16.eq" {
          if vector_byte(left, lane) == vector_byte(right, lane) { 255UL } else { 0UL }
        } else {
          let index = vector_byte(right, lane)
          if index < 16UL { vector_byte(left, index.to_int()) } else { 0UL }
        }
        result = vector_replace(result, lane, byte)
      }
      result
    }
    ("i8x16.bitmask", [value]) => {
      let mut result = 0UL
      for lane in 0..<16 {
        result = result | ((vector_byte(value, lane) >> 7) << lane)
      }
      Number(result, "U32")
    }
    (_, [value]) => match raw_immediate(opcode, "i8x16.extract_lane_u ") {
      Some(lane) => Number(vector_byte(value, lane), "U8")
      None => eval_fail("unsupported Wasm vector intrinsic: " + opcode)
    }
    (_, [value, byte]) => {
      if raw_immediate(opcode, "i64x2.replace_lane ") is Some(lane) {
        guard value is Vector(low, high) && lane >= 0 && lane < 2 else { return eval_fail("Wasm vector lane out of bounds at compile time") }
        if lane == 0 { Vector(raw_bits(byte), high) } else { Vector(low, raw_bits(byte)) }
      } else {
        match raw_immediate(opcode, "i8x16.replace_lane ") {
          Some(lane) => vector_replace(value, lane, raw_bits(byte))
          None => eval_fail("unsupported Wasm vector intrinsic: " + opcode)
        }
      }
    }
    _ => eval_fail("Wasm vector intrinsic argument count mismatch")
  }
}
