///|
fn vector_mask(width : Int32) -> UInt64 {
  if width == 64 {
    18446744073709551615UL
  } else {
    (1UL << width) - 1UL
  }
}

///|
fn vector_lane(
  value : Value,
  lane : Int32,
  width : Int32,
) -> UInt64 raise EvalError {
  guard value is Vector(low, high) && lane >= 0 && lane < 128 / width else {
    raise Failed(
      "Wasm vector instruction requires a 128-bit vector and valid lane",
    )
  }
  let offset = lane * width
  (if offset < 64 { low >> offset } else { high >> (offset - 64) }) &
  vector_mask(width)
}

///|
fn vector_set_lane(
  value : Value,
  lane : Int32,
  width : Int32,
  bits : UInt64,
) -> Value raise EvalError {
  guard value is Vector(low, high) && lane >= 0 && lane < 128 / width else {
    return eval_fail("Wasm vector lane out of bounds at compile time")
  }
  let offset = lane * width
  let shift = offset % 64
  let mask = vector_mask(width)
  if offset < 64 {
    Vector((low & (mask << shift).lnot()) | ((bits & mask) << shift), high)
  } else {
    Vector(low, (high & (mask << shift).lnot()) | ((bits & mask) << shift))
  }
}

///|
fn vector_byte(value : Value, lane : Int32) -> UInt64 raise EvalError {
  vector_lane(value, lane, 8)
}

///|
fn vector_replace(
  value : Value,
  lane : Int32,
  byte : UInt64,
) -> Value raise EvalError {
  vector_set_lane(value, lane, 8, byte)
}

///|
fn vector_signed(bits : UInt64, width : Int32) -> Int64 {
  bits.reinterpret_as_int64() << (64 - width) >> (64 - width)
}

///|
fn vector_scalar_bits(value : Value) -> UInt64 raise EvalError {
  match value {
    Floating(bits, _) => bits
    _ => raw_bits(value)
  }
}

///|
fn vector_opcode(opcode : String) -> Bool {
  ["v128.", "i8x16.", "i16x8.", "i32x4.", "i64x2.", "f32x4.", "f64x2."].any(prefix => {
    opcode.has_prefix(prefix)
  })
}

///|
fn vector_cross(opcode : String, args : Array[Value]) -> Value? raise EvalError {
  let family = opcode.split(".").to_array()[0].to_string()
  let width = match family {
    "i8x16" => 8
    "i16x8" => 16
    "i32x4" | "f32x4" => 32
    _ => 64
  }
  let signed_ = opcode.has_suffix("_s")
  let count = 128 / width
  if opcode.contains(".narrow_") {
    let mut result = Vector(0UL, 0UL)
    for lane in 0..<count {
      let source = args[if lane < count / 2 { 0 } else { 1 }]
      let value = vector_signed(
        vector_lane(source, lane % (count / 2), width * 2),
        width * 2,
      )
      let low = if signed_ { -(1L << (width - 1)) } else { 0L }
      let high = if signed_ {
        (1L << (width - 1)) - 1L
      } else {
        (1L << width) - 1L
      }
      result = vector_set_lane(
        result,
        lane,
        width,
        (if value < low { low } else if value > high { high } else { value }).reinterpret_as_uint64(),
      )
    }
    return Some(result)
  }
  if opcode.contains(".extend_") ||
    opcode.contains(".extmul_") ||
    opcode.contains(".extadd_pairwise_") {
    let small = width / 2
    let start = if opcode.contains("_high_") { count } else { 0 }
    let mut result = Vector(0UL, 0UL)
    for lane in 0..<count {
      let pairwise = opcode.contains(".extadd_pairwise_")
      let source_lane = if pairwise { lane * 2 } else { start + lane }
      let first = vector_lane(args[0], source_lane, small)
      let first = if signed_ {
        vector_signed(first, small).reinterpret_as_uint64()
      } else {
        first
      }
      let bits = if opcode.contains(".extmul_") {
        let second = vector_lane(args[1], source_lane, small)
        first *
        (if signed_ {
          vector_signed(second, small).reinterpret_as_uint64()
        } else {
          second
        })
      } else if pairwise {
        let second = vector_lane(args[0], source_lane + 1, small)
        first +
        (if signed_ {
          vector_signed(second, small).reinterpret_as_uint64()
        } else {
          second
        })
      } else {
        first
      }
      result = vector_set_lane(result, lane, width, bits)
    }
    return Some(result)
  }
  if opcode == "i32x4.dot_i16x8_s" {
    let mut result = Vector(0UL, 0UL)
    for lane in 0..<4 {
      let mut sum = 0L
      for part in 0..<2 {
        let index = lane * 2 + part
        sum += vector_signed(vector_lane(args[0], index, 16), 16) *
          vector_signed(vector_lane(args[1], index, 16), 16)
      }
      result = vector_set_lane(result, lane, 32, sum.reinterpret_as_uint64())
    }
    return Some(result)
  }
  let conversion = match opcode {
    "f32x4.convert_i32x4_s" => Some((32, 32, "f32.convert_i32_s", false))
    "f32x4.convert_i32x4_u" => Some((32, 32, "f32.convert_i32_u", false))
    "f64x2.convert_low_i32x4_s" => Some((32, 64, "f64.convert_i32_s", false))
    "f64x2.convert_low_i32x4_u" => Some((32, 64, "f64.convert_i32_u", false))
    "f32x4.demote_f64x2_zero" => Some((64, 32, "f32.demote_f64", true))
    "f64x2.promote_low_f32x4" => Some((32, 64, "f64.promote_f32", true))
    "i32x4.trunc_sat_f32x4_s" => Some((32, 32, "i32.trunc_sat_f32_s", true))
    "i32x4.trunc_sat_f32x4_u" => Some((32, 32, "i32.trunc_sat_f32_u", true))
    "i32x4.trunc_sat_f64x2_s_zero" =>
      Some((64, 32, "i32.trunc_sat_f64_s", true))
    "i32x4.trunc_sat_f64x2_u_zero" =>
      Some((64, 32, "i32.trunc_sat_f64_u", true))
    _ => None
  }
  if conversion is Some((input_width, output_width, scalar, input_float)) {
    let mut result = Vector(0UL, 0UL)
    let lanes = if input_width > output_width {
      128 / input_width
    } else {
      128 / output_width
    }
    for lane in 0..<lanes {
      let bits = vector_lane(args[0], lane, input_width)
      let value = if input_float {
        Floating(bits, if input_width == 32 { "F32" } else { "F64" })
      } else {
        Number(bits, "I32")
      }
      result = vector_set_lane(
        result,
        lane,
        output_width,
        vector_scalar_bits(float_intrinsic(scalar, [value])),
      )
    }
    return Some(result)
  }
  None
}

///|
fn vector_intrinsic(
  opcode : String,
  args : Array[Value],
) -> Value raise EvalError {
  if opcode.has_prefix("v128.") {
    guard args.length() > 0 && args[0] is Vector(al, ah) else {
      return eval_fail("Wasm vector instruction requires a 128-bit vector")
    }
    if opcode == "v128.any_true" && args.length() == 1 {
      return Boolean((al | ah) != 0UL)
    }
    if opcode == "v128.not" && args.length() == 1 {
      return Vector(al.lnot(), ah.lnot())
    }
    guard args.length() >= 2 && args[1] is Vector(bl, bh) else {
      return eval_fail(
        "Wasm vector instruction requires 128-bit vector operands",
      )
    }
    match opcode {
      "v128.and" => return Vector(al & bl, ah & bh)
      "v128.or" => return Vector(al | bl, ah | bh)
      "v128.xor" => return Vector(al ^ bl, ah ^ bh)
      "v128.andnot" => return Vector(al & bl.lnot(), ah & bh.lnot())
      "v128.bitselect" if args.length() == 3 && args[2] is Vector(ml, mh) =>
        return Vector(
          (al & ml) | (bl & ml.lnot()),
          (ah & mh) | (bh & mh.lnot()),
        )
      _ =>
        return eval_fail(
          "linear memory is not exposed to compile-time vector instructions: " +
          opcode,
        )
    }
  }
  if opcode.has_prefix("i8x16.shuffle ") && args.length() == 2 {
    let lanes = opcode.substring(start=14).split(" ").to_array()
    guard lanes.length() == 16 else {
      return eval_fail("invalid Wasm vector shuffle")
    }
    let mut result = Vector(0UL, 0UL)
    for index, lane in lanes {
      let selected = raw_immediate("lane " + lane.to_owned(), "lane ")
      guard selected is Some(selected) && selected < 32 else {
        return eval_fail("invalid Wasm vector shuffle lane")
      }
      result = vector_replace(
        result,
        index,
        vector_byte(args[if selected < 16 { 0 } else { 1 }], selected % 16),
      )
    }
    return result
  }
  guard args.length() > 0 && args.length() <= 2 else {
    return eval_fail("Wasm vector intrinsic argument count mismatch")
  }
  if vector_cross(opcode, args) is Some(result) {
    return result
  }
  let parts = opcode.split(".").to_array()
  guard parts.length() == 2 else {
    return eval_fail("invalid Wasm vector opcode")
  }
  let family = parts[0].to_string()
  let operation = parts[1].to_string()
  let width = match family {
    "i8x16" => 8
    "i16x8" => 16
    "i32x4" | "f32x4" => 32
    "i64x2" | "f64x2" => 64
    _ => return eval_fail("invalid Wasm vector family")
  }
  let floating = family == "f32x4" || family == "f64x2"
  let kind = if floating {
    if width == 32 {
      "F32"
    } else {
      "F64"
    }
  } else if width == 64 {
    "I64"
  } else {
    "I32"
  }
  let lanes = 128 / width
  let mask = vector_mask(width)
  if operation == "splat" {
    let mut result = Vector(0UL, 0UL)
    for lane in 0..<lanes {
      result = vector_set_lane(result, lane, width, vector_scalar_bits(args[0]))
    }
    return result
  }
  for
    prefix in [
      "extract_lane_s ", "extract_lane_u ", "extract_lane ", "replace_lane ",
    ] {
    if raw_immediate(operation, prefix) is Some(lane) {
      let bits = vector_lane(args[0], lane, width)
      if prefix == "replace_lane " && args.length() == 2 {
        return vector_set_lane(
          args[0],
          lane,
          width,
          vector_scalar_bits(args[1]),
        )
      }
      if floating {
        return Floating(bits, kind)
      }
      return Number(
        if prefix == "extract_lane_s " {
          vector_signed(bits, width).reinterpret_as_uint64() & 4294967295UL
        } else {
          bits
        },
        kind,
      )
    }
  }
  if operation == "all_true" || operation == "bitmask" {
    let mut result = if operation == "all_true" { 1UL } else { 0UL }
    for lane in 0..<lanes {
      let bits = vector_lane(args[0], lane, width)
      if operation == "all_true" {
        if bits == 0UL {
          result = 0UL
        }
      } else {
        result = result | (bits >> (width - 1) << lane)
      }
    }
    return Number(result, "U32")
  }
  let mut result = Vector(0UL, 0UL)
  for lane in 0..<lanes {
    let a = vector_lane(args[0], lane, width)
    let b = if args.length() == 2 {
      if operation == "shl" || operation.has_prefix("shr_") {
        raw_bits(args[1]) & (width - 1).to_uint64()
      } else {
        vector_lane(args[1], lane, width)
      }
    } else {
      0UL
    }
    let x = vector_signed(a, width)
    let y = vector_signed(b, width)
    let comparison = if floating {
      let values = [Floating(a, kind)]
      if args.length() == 2 {
        values.push(Floating(b, kind))
      }
      if operation == "pmin" || operation == "pmax" {
        let left = float_double(values[0], kind)
        let right = float_double(values[1], kind)
        Some(
          if (operation == "pmin" && right < left) ||
            (operation == "pmax" && left < right) {
            b
          } else {
            a
          },
        )
      } else {
        let value = float_intrinsic(
          (if width == 32 { "f32." } else { "f64." }) + operation,
          values,
        )
        Some(
          match value {
            Boolean(value) => if value { mask } else { 0UL }
            _ => vector_scalar_bits(value)
          },
        )
      }
    } else {
      None
    }
    let bits = if comparison is Some(bits) {
      bits
    } else {
      match operation {
        "add" => a + b
        "sub" => a - b
        "mul" => a * b
        "neg" => 0UL - a
        "abs" => if x < 0L { 0UL - a } else { a }
        "popcnt" => {
          let mut bits = a
          let mut count = 0UL
          while bits != 0UL {
            bits = bits & (bits - 1UL)
            count += 1UL
          }
          count
        }
        "shl" => a << b.to_int()
        "shr_s" => (x >> b.to_int()).reinterpret_as_uint64()
        "shr_u" => a >> b.to_int()
        "min_s" => if x < y { a } else { b }
        "min_u" => if a < b { a } else { b }
        "max_s" => if x > y { a } else { b }
        "max_u" => if a > b { a } else { b }
        "avgr_u" => (a + b + 1UL) >> 1
        "add_sat_s" | "sub_sat_s" => {
          let value = if operation == "add_sat_s" { x + y } else { x - y }
          let low = -(1L << (width - 1))
          let high = (1L << (width - 1)) - 1L
          (if value < low { low } else if value > high { high } else { value }).reinterpret_as_uint64()
        }
        "add_sat_u" => if a + b > mask { mask } else { a + b }
        "sub_sat_u" => if a < b { 0UL } else { a - b }
        "swizzle" =>
          if b < 16UL {
            vector_byte(args[0], b.to_int())
          } else {
            0UL
          }
        _ => {
          let condition = match operation {
            "eq" => a == b
            "ne" => a != b
            "lt_s" => x < y
            "lt_u" => a < b
            "le_s" => x <= y
            "le_u" => a <= b
            "gt_s" => x > y
            "gt_u" => a > b
            "ge_s" => x >= y
            "ge_u" => a >= b
            _ =>
              return eval_fail("unsupported Wasm vector intrinsic: " + opcode)
          }
          if condition {
            mask
          } else {
            0UL
          }
        }
      }
    }
    result = vector_set_lane(result, lane, width, bits)
  }
  result
}
