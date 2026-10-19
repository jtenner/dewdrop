///|
fn float_opcode(opcode : String) -> Bool {
  opcode.has_prefix("f32.") ||
  opcode.has_prefix("f64.") ||
  opcode.contains(".trunc_f") ||
  opcode.contains(".trunc_sat_f") ||
  opcode == "i32.reinterpret_f32" ||
  opcode == "i64.reinterpret_f64"
}

///|
fn float_double(value : Value, kind : String) -> Double raise EvalError {
  match value {
    Floating(bits, actual) if actual == kind =>
      if kind == "F32" {
        Float::reinterpret_from_uint(bits.to_uint()).to_double()
      } else {
        bits.reinterpret_as_double()
      }
    _ => raise Failed("Wasm floating-point intrinsic requires a matching float")
  }
}

///|
fn float_result(value : Double, kind : String) -> Value {
  if value.is_nan() {
    Floating(
      if kind == "F32" {
        2143289344UL
      } else {
        9221120237041090560UL
      },
      kind,
    )
  } else if kind == "F32" {
    Floating(Float::from_double(value).reinterpret_as_uint().to_uint64(), kind)
  } else {
    Floating(value.reinterpret_as_uint64(), kind)
  }
}

///|
fn float_nearest(value : Double) -> Double {
  if value.is_nan() ||
    value.is_inf() ||
    value == 0.0 ||
    value.abs() >= 4503599627370496.0 {
    return value
  }
  let floor = value.floor()
  let delta = value - floor
  let rounded = if delta < 0.5 {
    floor
  } else if delta > 0.5 {
    floor + 1.0
  } else if floor.to_int64() % 2L == 0L {
    floor
  } else {
    floor + 1.0
  }
  if rounded == 0.0 && value < 0.0 {
    -0.0
  } else {
    rounded
  }
}

///|
fn float_truncate(opcode : String, value : Double) -> Value raise EvalError {
  let wide = opcode.has_prefix("i64.")
  let unsigned = opcode.has_suffix("_u")
  let kind = if wide {
    if unsigned {
      "U64"
    } else {
      "I64"
    }
  } else if unsigned {
    "U32"
  } else {
    "I32"
  }
  let upper = if wide {
    if unsigned {
      18446744073709551616.0
    } else {
      9223372036854775808.0
    }
  } else if unsigned {
    4294967296.0
  } else {
    2147483648.0
  }
  let lower = if unsigned { 0.0 } else { -upper }
  let truncated = value.trunc()
  if value.is_nan() || truncated < lower || truncated >= upper {
    if !opcode.contains("trunc_sat") {
      return eval_fail("Wasm float-to-integer conversion trap at compile time")
    }
    if value.is_nan() {
      return normalized(0UL, kind)
    }
    return if value < lower {
      normalized(
        if unsigned {
          0UL
        } else if wide {
          9223372036854775808UL
        } else {
          2147483648UL
        },
        kind,
      )
    } else {
      normalized(
        if unsigned {
          if wide {
            18446744073709551615UL
          } else {
            4294967295UL
          }
        } else if wide {
          9223372036854775807UL
        } else {
          2147483647UL
        },
        kind,
      )
    }
  }
  let bits = if unsigned && wide && truncated >= 9223372036854775808.0 {
    (truncated - 9223372036854775808.0).to_int64().reinterpret_as_uint64() |
    9223372036854775808UL
  } else {
    truncated.to_int64().reinterpret_as_uint64()
  }
  normalized(bits, kind)
}

///|
fn float_intrinsic(
  opcode : String,
  args : Array[Value],
) -> Value raise EvalError {
  let kind = if opcode.has_prefix("f32.") { "F32" } else { "F64" }
  match (opcode, args[:]) {
    ("f32.reinterpret_i32", [value]) =>
      Floating(raw_bits(value) & 4294967295UL, "F32")
    ("f64.reinterpret_i64", [value]) => Floating(raw_bits(value), "F64")
    ("i32.reinterpret_f32", [Floating(bits, "F32")]) => Number(bits, "I32")
    ("i64.reinterpret_f64", [Floating(bits, "F64")]) => Number(bits, "I64")
    ("f32.demote_f64", [value]) =>
      float_result(float_double(value, "F64"), "F32")
    ("f64.promote_f32", [value]) =>
      float_result(float_double(value, "F32"), "F64")
    (name, [value]) if name.contains(".trunc_f") ||
      name.contains(".trunc_sat_f") =>
      float_truncate(
        name,
        float_double(value, if name.contains("_f32_") { "F32" } else { "F64" }),
      )
    (name, [value]) if name.contains(".convert_i") => {
      let wide = name.contains("i64_")
      let unsigned = name.has_suffix("_u")
      let bits = raw_bits(value)
      if kind == "F32" {
        let result = if wide {
          if unsigned {
            bits.to_float()
          } else {
            bits.reinterpret_as_int64().to_float()
          }
        } else if unsigned {
          bits.to_uint().to_float()
        } else {
          bits.to_int().to_float()
        }
        Floating(result.reinterpret_as_uint().to_uint64(), kind)
      } else {
        float_result(
          if wide {
            if unsigned {
              bits.to_double()
            } else {
              bits.reinterpret_as_int64().to_double()
            }
          } else if unsigned {
            bits.to_uint().to_double()
          } else {
            bits.to_int().to_double()
          },
          kind,
        )
      }
    }
    (name, [Floating(bits, actual)]) if kind == actual => {
      let sign = if kind == "F32" {
        2147483648UL
      } else {
        9223372036854775808UL
      }
      if name.has_suffix(".abs") {
        return Floating(bits & sign.lnot(), kind)
      }
      if name.has_suffix(".neg") {
        return Floating(bits ^ sign, kind)
      }
      let value = float_double(args[0], kind)
      let result = if name.has_suffix(".ceil") {
        value.ceil()
      } else if name.has_suffix(".floor") {
        value.floor()
      } else if name.has_suffix(".trunc") {
        value.trunc()
      } else if name.has_suffix(".nearest") {
        float_nearest(value)
      } else if name.has_suffix(".sqrt") {
        if kind == "F32" {
          Float::reinterpret_from_uint(bits.to_uint()).sqrt().to_double()
        } else {
          value.sqrt()
        }
      } else {
        return eval_fail("unsupported Wasm float intrinsic: " + name)
      }
      float_result(result, kind)
    }
    (name, [Floating(a, actual), Floating(b, other)]) if actual == kind &&
      other == kind => {
      let x = float_double(args[0], kind)
      let y = float_double(args[1], kind)
      if name.has_suffix(".eq") {
        return Boolean(x == y)
      }
      if name.has_suffix(".ne") {
        return Boolean(x != y)
      }
      if name.has_suffix(".lt") {
        return Boolean(x < y)
      }
      if name.has_suffix(".le") {
        return Boolean(x <= y)
      }
      if name.has_suffix(".gt") {
        return Boolean(x > y)
      }
      if name.has_suffix(".ge") {
        return Boolean(x >= y)
      }
      let sign = if kind == "F32" {
        2147483648UL
      } else {
        9223372036854775808UL
      }
      if name.has_suffix(".copysign") {
        return Floating((a & sign.lnot()) | (b & sign), kind)
      }
      if name.has_suffix(".min") || name.has_suffix(".max") {
        if x.is_nan() || y.is_nan() {
          return float_result(0.0 / 0.0, kind)
        }
        if x == 0.0 && y == 0.0 {
          return Floating(
            if name.has_suffix(".min") {
              a | b
            } else {
              a & b
            },
            kind,
          )
        }
        return if (name.has_suffix(".min") && x < y) ||
          (name.has_suffix(".max") && x > y) {
          args[0]
        } else {
          args[1]
        }
      }
      let result = if kind == "F32" {
        let x = Float::reinterpret_from_uint(a.to_uint())
        let y = Float::reinterpret_from_uint(b.to_uint())
        (if name.has_suffix(".add") {
          x + y
        } else if name.has_suffix(".sub") {
          x - y
        } else if name.has_suffix(".mul") {
          x * y
        } else if name.has_suffix(".div") {
          x / y
        } else {
          return eval_fail("unsupported Wasm float intrinsic: " + name)
        }).to_double()
      } else if name.has_suffix(".add") {
        x + y
      } else if name.has_suffix(".sub") {
        x - y
      } else if name.has_suffix(".mul") {
        x * y
      } else if name.has_suffix(".div") {
        x / y
      } else {
        return eval_fail("unsupported Wasm float intrinsic: " + name)
      }
      float_result(result, kind)
    }
    _ =>
      eval_fail(
        "Wasm floating-point intrinsic has incompatible arguments: " + opcode,
      )
  }
}

///|
fn float_binary(
  op : Operation,
  left : Value,
  right : Value,
  kind : String,
) -> Value raise EvalError {
  let name = match op {
    Add => "add"
    Subtract => "sub"
    Multiply => "mul"
    Divide => "div"
    Equal => "eq"
    NotEqual => "ne"
    Less => "lt"
    LessEqual => "le"
    Greater => "gt"
    GreaterEqual => "ge"
    _ => return eval_fail("unsupported float operator at compile time")
  }
  float_intrinsic((if kind == "F32" { "f32." } else { "f64." }) + name, [
    left, right,
  ])
}
