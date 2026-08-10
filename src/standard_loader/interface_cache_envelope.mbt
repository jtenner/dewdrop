///|
let interface_bundle_cache_file_magic : Bytes = b"DEW_STD_INTERFACE_CACHE_V11\x00"

///|
fn wrap_interface_cache_payload(payload : Bytes) -> Bytes {
  let output = Buffer()
  output.write_bytes(interface_bundle_cache_file_magic)
  let digest = @crypto.sha256(payload)
  for byte in digest {
    output.write_byte(byte)
  }
  output.write_bytes(payload)
  output.to_bytes()
}

///|
fn unwrap_interface_cache_payload(bytes : Bytes) -> Result[Bytes, String] {
  let header_length = interface_bundle_cache_file_magic.length()
  let digest_length = 32
  if bytes.length() < header_length + digest_length {
    return Err("truncated standard-interface cache envelope")
  }
  for index in 0..<header_length {
    if bytes[index] != interface_bundle_cache_file_magic[index] {
      return Err("unsupported standard-interface cache envelope")
    }
  }
  let payload = Buffer()
  let mut payload_index = header_length + digest_length
  while payload_index < bytes.length() {
    payload.write_byte(bytes[payload_index])
    payload_index += 1
  }
  let payload_bytes = payload.to_bytes()
  let actual = @crypto.sha256(payload_bytes)
  for index in 0..<digest_length {
    if bytes[header_length + index] != actual[index] {
      return Err("standard-interface cache checksum mismatch")
    }
  }
  Ok(payload_bytes)
}
