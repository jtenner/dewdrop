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

///|
fn write_wasm_u32_le(output : Buffer, value : Int) -> Unit {
  output.write_byte((value & 255).to_byte())
  output.write_byte(((value >> 8) & 255).to_byte())
  output.write_byte(((value >> 16) & 255).to_byte())
  output.write_byte(((value >> 24) & 255).to_byte())
}

///|
fn write_wasm_abi_string(output : Buffer, value : String) -> Unit {
  let encoded = Buffer()
  encoded.write_string_utf8(value)
  let bytes = encoded.to_bytes()
  write_wasm_u32_le(output, bytes.length())
  output.write_bytes(bytes)
}

///|
/// Append one versioned Dew ABI/interface compatibility record.
pub fn append_wasm_abi_section(
  module_ : Bytes,
  interface_ : @semantic.FrozenModuleInterface,
) -> Bytes {
  let payload = Buffer()
  payload.write_bytes(b"DWA1")
  payload.write_bytes(b"\x01\x01\x01\x01\x01")
  write_wasm_abi_string(payload, interface_.path)
  write_wasm_abi_string(payload, interface_.interface_fingerprint)
  write_wasm_u32_le(payload, interface_.dependencies.length())
  for dependency in interface_.dependencies {
    write_wasm_abi_string(payload, dependency.path)
    write_wasm_abi_string(payload, dependency.content_fingerprint)
  }
  append_wasm_custom_section(module_, "dew.abi", payload.to_bytes())
}

///| Append deterministic compiler-owned static metrics to a validated module.

///|

///| The `dew.metrics` V1 payload is exactly eight bytes: the ASCII magic `DWM1`

///| followed by the materialized generic-specialization count as a little-endian

///|
/// unsigned 32-bit integer.
pub fn append_wasm_metrics_section(
  module_ : Bytes,
  materialized_specializations : Int,
) -> Bytes {
  guard materialized_specializations >= 0 else {
    abort("materialized specialization count cannot be negative")
  }
  let payload = Buffer(size_hint=8)
  payload.write_bytes(b"DWM1")
  payload.write_byte((materialized_specializations & 255).to_byte())
  payload.write_byte(((materialized_specializations >> 8) & 255).to_byte())
  payload.write_byte(((materialized_specializations >> 16) & 255).to_byte())
  payload.write_byte(((materialized_specializations >> 24) & 255).to_byte())
  append_wasm_custom_section(module_, "dew.metrics", payload.to_bytes())
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
