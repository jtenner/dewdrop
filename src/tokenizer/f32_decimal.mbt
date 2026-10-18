///|
/// Compare a valid positive decimal with an exactly represented F32 midpoint.
/// The midpoint needs at most 113 decimal digits, independent of source length.
fn compare_decimal_f32_midpoint(text : String, midpoint : Double) -> Int32 {
  let bits = midpoint.reinterpret_as_uint64()
  let mut significand = (bits & 0xFFFFFFFFFFFFFUL) | 0x10000000000000UL
  let mut exponent = ((bits >> 52).to_int() & 2047) - 1075
  while (significand & 1UL) == 0UL {
    significand = significand >> 1
    exponent += 1
  }
  let digits : Array[Int32] = []
  while significand > 0UL {
    digits.push((significand % 10UL).to_int())
    significand = significand / 10UL
  }
  let factor = if exponent < 0 { 5 } else { 2 }
  for step = 0; step < exponent.abs(); step = step + 1 {
    let mut carry = 0
    for index = 0; index < digits.length(); index = index + 1 {
      let product = digits[index] * factor + carry
      digits[index] = product % 10
      carry = product / 10
    }
    if carry > 0 {
      digits.push(carry)
    }
  }
  let mut fraction_digits = 0
  let mut after_dot = false
  let mut first_digit = -1
  let mut significant_digits = 0
  let mut index = 0
  while index < text.length() && text[index] != 'e' && text[index] != 'E' {
    let unit = text[index]
    if unit == '_' {
      index += 1
      continue
    }
    if unit == '.' {
      after_dot = true
    } else {
      if after_dot {
        fraction_digits += 1
      }
      if first_digit < 0 && unit != '0' {
        first_digit = index
      }
      if first_digit >= 0 {
        significant_digits += 1
      }
    }
    index += 1
  }
  let mantissa_end = index
  let mut decimal_exponent = 0L
  if index < text.length() {
    index += 1
    let negative = text[index] == '-'
    if text[index] == '-' || text[index] == '+' {
      index += 1
    }
    while index < text.length() {
      if text[index] == '_' {
        index += 1
        continue
      }
      // Larger exponents cannot be balanced by a resident String's length.
      if decimal_exponent < 4000000000L {
        decimal_exponent = decimal_exponent * 10L +
          (text[index].to_int() - 48).to_int64()
      }
      index += 1
    }
    if negative {
      decimal_exponent = -decimal_exponent
    }
  }
  let source_order = significant_digits.to_int64() -
    fraction_digits.to_int64() +
    decimal_exponent
  let midpoint_order = (digits.length() +
  (if exponent < 0 { exponent } else { 0 })).to_int64()
  if source_order != midpoint_order {
    return if source_order < midpoint_order { -1 } else { 1 }
  }
  let mut expected_index = digits.length() - 1
  for index = first_digit; index < mantissa_end; index = index + 1 {
    if text[index] == '.' || text[index] == '_' {
      continue
    }
    let actual = text[index].to_int() - 48
    let expected = if expected_index >= 0 { digits[expected_index] } else { 0 }
    if actual != expected {
      return if actual < expected { -1 } else { 1 }
    }
    expected_index -= 1
  }
  while expected_index >= 0 {
    if digits[expected_index] != 0 {
      return -1
    }
    expected_index -= 1
  }
  0
}

///|
/// The F64 parse is sufficient unless it lands exactly on an F32 midpoint.
fn round_f32_decimal(text : String, value : Double) -> Float {
  let narrowed = Float::from_double(value)
  // An F32 midpoint has at most 25 significant binary digits.
  if (value.reinterpret_as_uint64() & 0xFFFFFFFUL) != 0UL {
    return narrowed
  }
  let bits = narrowed.reinterpret_as_uint()
  let exact = narrowed.to_double()
  if value == exact || value.is_inf() {
    return narrowed
  }
  let lower_bits = if exact > value { bits - 1U } else { bits }
  let lower = Float::reinterpret_from_uint(lower_bits).to_double()
  let upper = if lower_bits == 0x7F7FFFFFU {
    // The finite successor used to define the overflow midpoint is 2^128.
    340282366920938463463374607431768211456.0
  } else {
    Float::reinterpret_from_uint(lower_bits + 1U).to_double()
  }
  let midpoint = (lower + upper) * 0.5
  if value != midpoint {
    return narrowed
  }
  let comparison = compare_decimal_f32_midpoint(text, midpoint)
  if comparison < 0 {
    Float::reinterpret_from_uint(lower_bits)
  } else if comparison > 0 {
    Float::reinterpret_from_uint(lower_bits + 1U)
  } else {
    narrowed
  }
}
