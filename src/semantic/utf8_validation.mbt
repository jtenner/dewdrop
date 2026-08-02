///| Strict RFC 3629 validation used for source String literals. Bytes literals

///|
/// deliberately bypass this check.
fn semantic_utf8_is_valid(input : Bytes) -> Bool {
  let mut index = 0
  while index < input.length() {
    let b0 = input[index].to_uint().reinterpret_as_int()
    if b0 < 0x80 {
      index += 1
      continue
    }
    if b0 < 0xC2 {
      return false
    }
    if b0 < 0xE0 {
      if index + 2 > input.length() {
        return false
      }
      let b1 = input[index + 1].to_uint().reinterpret_as_int()
      if (b1 & 0xC0) != 0x80 {
        return false
      }
      index += 2
      continue
    }
    if b0 < 0xF0 {
      if index + 3 > input.length() {
        return false
      }
      let b1 = input[index + 1].to_uint().reinterpret_as_int()
      let b2 = input[index + 2].to_uint().reinterpret_as_int()
      if b0 == 0xE0 {
        if b1 < 0xA0 || b1 > 0xBF {
          return false
        }
      } else if b0 == 0xED {
        if b1 < 0x80 || b1 > 0x9F {
          return false
        }
      } else if (b1 & 0xC0) != 0x80 {
        return false
      }
      if (b2 & 0xC0) != 0x80 {
        return false
      }
      index += 3
      continue
    }
    if b0 <= 0xF4 {
      if index + 4 > input.length() {
        return false
      }
      let b1 = input[index + 1].to_uint().reinterpret_as_int()
      let b2 = input[index + 2].to_uint().reinterpret_as_int()
      let b3 = input[index + 3].to_uint().reinterpret_as_int()
      if b0 == 0xF0 {
        if b1 < 0x90 || b1 > 0xBF {
          return false
        }
      } else if b0 == 0xF4 {
        if b1 < 0x80 || b1 > 0x8F {
          return false
        }
      } else if (b1 & 0xC0) != 0x80 {
        return false
      }
      if (b2 & 0xC0) != 0x80 || (b3 & 0xC0) != 0x80 {
        return false
      }
      index += 4
      continue
    }
    return false
  }
  true
}
