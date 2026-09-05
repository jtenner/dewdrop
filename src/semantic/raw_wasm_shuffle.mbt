///|
// Canonical Wasm text: exactly sixteen decimal indices in 0..31.
// The compiler does not own a table of library permutation recipes.
pub fn raw_wasm_shuffle_immediates(name : Bytes) -> Array[Int]? {
  let prefix = b"i8x16.shuffle "
  if name.length() < 45 || name.length() > 61 {
    return None
  }
  for index in 0..<prefix.length() {
    if name[index] != prefix[index] {
      return None
    }
  }
  let indices = []
  let mut cursor = prefix.length()
  for slot in 0..<16 {
    if cursor >= name.length() || name[cursor] < b'0' || name[cursor] > b'9' {
      return None
    }
    let mut value = name[cursor].to_int() - 48
    cursor += 1
    if cursor < name.length() && name[cursor] >= b'0' && name[cursor] <= b'9' {
      if value == 0 {
        return None
      }
      value = value * 10 + name[cursor].to_int() - 48
      cursor += 1
    }
    if value > 31 {
      return None
    }
    indices.push(value)
    if slot < 15 {
      if cursor >= name.length() || name[cursor] != b' ' {
        return None
      }
      cursor += 1
    } else if cursor != name.length() {
      return None
    }
  }
  Some(indices)
}

///|
fn raw_wasm_shuffle_signature(name : Bytes) -> RawWasmIntrinsicSignature? {
  match raw_wasm_shuffle_immediates(name) {
    Some(_) =>
      Some({
        inputs: [WasmV128Value, WasmV128Value],
        result: Some(WasmV128Value),
      })
    None => None
  }
}
