///|
fn write_wasm_u32_leb(output : Buffer, initial : Int) -> Unit {
  let mut value = initial
  while value >= 128 {
    output.write_byte(((value & 127) | 128).to_byte())
    value = value >> 7
  }
  output.write_byte(value.to_byte())
}

///|
fn wasm_u32_leb_length(initial : Int) -> Int {
  let mut value = initial
  let mut length = 1
  while value >= 128 {
    value = value >> 7
    length += 1
  }
  length
}

///| Append one deterministic custom section to an already validated and encoded

///| WebAssembly module. Custom sections do not alter validation semantics and

///|
/// are legal after every standard section.
pub fn append_wasm_custom_section(
  module_ : Bytes,
  name : String,
  payload : Bytes,
) -> Bytes {
  let name_buffer = Buffer(size_hint=name.length())
  name_buffer.write_string_utf8(name)
  let name_bytes = name_buffer.to_bytes()
  let content_length = wasm_u32_leb_length(name_bytes.length()) +
    name_bytes.length() +
    payload.length()
  let output = Buffer(
    size_hint=module_.length() +
      wasm_u32_leb_length(content_length) +
      content_length +
      1,
  )
  output.write_bytes(module_)
  output.write_byte(0)
  write_wasm_u32_leb(output, content_length)
  write_wasm_u32_leb(output, name_bytes.length())
  output.write_bytes(name_bytes)
  output.write_bytes(payload)
  output.to_bytes()
}
