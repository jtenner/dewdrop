///|
fn raw_bits(value : Value) -> UInt64 raise EvalError {
  match value {
    Number(bits, kind) if kind == "I8" || kind == "I16" =>
      signed(bits, kind).reinterpret_as_uint64()
    Number(bits, _) => bits
    Boolean(value) => if value { 1UL } else { 0UL }
    DefaultValue => 0UL
    _ => raise Failed("Wasm integer intrinsic requires an integer")
  }
}

///|
fn intrinsic_kind(value : Value, kind : String) -> Value raise EvalError {
  guard !kind.has_prefix("unsupported:") else {
    return eval_fail(
      "unsupported scalar type at compile time: " +
      kind.substring(start=12).to_string(),
    )
  }
  if kind == "Never" {
    return eval_fail("uninhabited type has no compile-time value")
  }
  if value is DefaultValue && kind == "Unit" {
    return Unit
  }
  if value is DefaultValue && kind.has_prefix("unit-product:") {
    return unit_product_default(kind.substring(start=13).to_string())
  }
  if kind == "nullable" || kind == "function" || kind.has_prefix("trait:") || kind.has_prefix("array:") {
    if value is DefaultValue {
      return NullValue
    }
    let _ = reference_is_null(value)
  }
  if (value is DefaultValue || value is NullValue) &&
    (
      kind.has_prefix("record:") ||
      kind == "product" ||
      ["String", "Bytes", "StringView", "StringBuilder", "BytesBuilder"].contains(
        kind,
      )
    ) {
    return eval_fail(
      "null reference read requires a non-null value at compile time",
    )
  }
  if kind == "product" || kind.has_prefix("unit-product:") {
    guard value is Sequence(_) else {
      return eval_fail("product value has an incompatible checked carrier")
    }
    return value
  }
  if kind == "F32" || kind == "F64" {
    return match value {
      DefaultValue => Floating(0UL, kind)
      Floating(_, actual) if kind == actual => value
      _ => eval_fail("floating-point value has an incompatible checked carrier")
    }
  }
  if kind == "V128" && value is DefaultValue {
    return Vector(0UL, 0UL)
  }
  check_intrinsic_result_carrier(value, kind)
  if value is RawArray(storage) && kind.has_prefix("array:") {
    storage.default_kind = kind.substring(start=6).to_string()
    value
  } else if kind == "Bool" {
    Boolean(raw_bits(value) != 0UL)
  } else if ["I8", "U8", "I16", "U16", "I32", "U32", "I64", "U64"].contains(
      kind,
    ) {
    normalized(raw_bits(value), kind)
  } else {
    value
  }
}

///|
fn Machine::intrinsic(
  self : Machine,
  builtin : @parser.BuiltinDeclaration,
  args : Array[Value],
  result_kind~ : String = "",
) -> Value raise EvalError {
  self.charge(16)
  let opcode = text(builtin.builtin_name)
  let args = intrinsic_arguments(builtin, args)
  self.check_intrinsic_contract(opcode, args, result_kind)
  if memory_opcode(opcode) is Some(code) {
    return self.memory_instruction(code, args)
  }
  if float_opcode(opcode) {
    return float_intrinsic(opcode, args)
  }
  if scalar_bit_opcode(opcode) {
    return scalar_bit_intrinsic(opcode, args)
  }
  if vector_opcode(opcode) {
    return vector_intrinsic(opcode, args)
  }
  if raw_immediate(opcode, "struct.get ") is Some(index) && args.length() == 1 {
    return self.raw_struct_get(args[0], index)
  }
  if opcode == "array.len" && args.length() == 1 {
    return Number(self.raw_array_length(args[0]), "U32")
  }
  if opcode == "array.get" && args.length() == 2 {
    return self.raw_array_get(args[0], raw_bits(args[1]))
  }
  if opcode == "array.copy" && args.length() == 5 {
    return self.raw_array_copy(
      args[0],
      raw_bits(args[1]),
      args[2],
      raw_bits(args[3]),
      raw_bits(args[4]),
    )
  }
  let result = match (opcode, args[:]) {
    ("ref_null", []) => NullValue
    ("ref_is_null", [value]) => {
      guard ["Bool", "I8", "U8", "I16", "U16", "I32", "U32"].contains(
        result_kind,
      ) else {
        return eval_fail("Wasm null test requires an i32 result carrier")
      }
      Boolean(reference_null_test(value))
    }
    ("ref_as_non_null", [value]) => {
      if reference_is_null(value) {
        return eval_fail("null reference assertion trap at compile time")
      }
      value
    }
    ("ref.cast", [value]) => self.reference_cast(value, result_kind)
    ("ref.eq", [left, right]) => Boolean(reference_equal(left, right))
    ("unreachable", []) =>
      return eval_fail("unreachable executed at compile time")
    ("array.new_default", [length]) | ("array.new", [length, _]) => {
      let count = raw_bits(length)
      guard count <= ((4_194_304 - self.allocated) / 16).to_uint64() else {
        return eval_fail("transform allocation limit exceeded")
      }
      self.charge(count.to_int() * 16)
      let value = if args.length() == 2 { args[1] } else { DefaultValue }
      RawArray({ values: Array::make(count.to_int(), value), default_kind: "", })
    }
    ("array.set", [RawArray(storage), index, value]) => {
      let values = storage.values
      let index = raw_bits(index)
      guard index < values.length().to_uint64() else {
        return eval_fail("Wasm array index out of bounds at compile time")
      }
      values[index.to_int()] = value
      Unit
    }
    ("unsafe.bitcast", [Floating(_, kind) as value]) if result_kind == kind =>
      value
    ("unsafe.bitcast", [Vector(_, _) as value]) if result_kind == "V128" =>
      value
    ("unsafe.bitcast", [value]) => {
      let _ = raw_bits(value)
      value
    }
    ("i32.extend8_s", [value]) =>
      Number(
        (raw_bits(value).to_int64() << 56 >> 56).reinterpret_as_uint64() &
        4294967295UL,
        "I32",
      )
    ("i32.extend16_s", [value]) =>
      Number(
        (raw_bits(value).to_int64() << 48 >> 48).reinterpret_as_uint64() &
        4294967295UL,
        "I32",
      )
    ("i32.wrap_i64", [value]) => Number(raw_bits(value) & 4294967295UL, "I32")
    ("i64.extend_i32_u", [value]) =>
      Number(raw_bits(value) & 4294967295UL, "U64")
    ("i64.extend_i32_s", [value]) =>
      Number(
        (raw_bits(value).to_int64() << 32 >> 32).reinterpret_as_uint64(),
        "I64",
      )
    (name, [value]) if name == "i32.eqz" || name == "i64.eqz" =>
      Boolean(raw_bits(value) == 0UL)
    (name, [left, right]) if name.has_prefix("i32.") || name.has_prefix("i64.") => {
      let kind = if name.has_prefix("i64.") {
        if name.has_suffix("_u") {
          "U64"
        } else {
          "I64"
        }
      } else if name.has_suffix("_u") {
        "U32"
      } else {
        "I32"
      }
      let a = normalized(raw_bits(left), kind)
      let b = normalized(raw_bits(right), kind)
      let op = if name.has_suffix(".add") {
        Add
      } else if name.has_suffix(".sub") {
        Subtract
      } else if name.has_suffix(".mul") {
        Multiply
      } else if name.has_suffix(".and") {
        BitAnd
      } else if name.has_suffix(".or") {
        BitOr
      } else if name.has_suffix(".xor") {
        BitXor
      } else if name.has_suffix(".shl") {
        ShiftLeft
      } else if name.has_suffix(".shr_s") || name.has_suffix(".shr_u") {
        ShiftRight
      } else if name.has_suffix(".eq") {
        Equal
      } else if name.has_suffix(".ne") {
        NotEqual
      } else if name.has_suffix(".lt_s") || name.has_suffix(".lt_u") {
        Less
      } else if name.has_suffix(".le_s") || name.has_suffix(".le_u") {
        LessEqual
      } else if name.has_suffix(".gt_s") || name.has_suffix(".gt_u") {
        Greater
      } else if name.has_suffix(".ge_s") || name.has_suffix(".ge_u") {
        GreaterEqual
      } else if name.has_suffix(".div_s") || name.has_suffix(".div_u") {
        Divide
      } else if name.has_suffix(".rem_s") || name.has_suffix(".rem_u") {
        Remainder
      } else {
        return eval_fail("unsupported Wasm integer intrinsic: " + opcode)
      }
      binary(op, a, b)
    }
    _ =>
      return eval_fail("unsupported Wasm intrinsic at compile time: " + opcode)
  }
  result
}
