///|
let body_inference_cache_file_magic : Bytes = b"DEW_BODY_INFERENCE_CACHE_V1\x00"

///|
let body_inference_family_cache_file_magic : Bytes = b"DEW_BODY_FAMILY_CACHE_V1\x00"

///|
fn wrap_body_inference_cache_payload(
  key : FixedArray[Byte],
  source : FixedArray[Byte],
  interface_ : FixedArray[Byte],
  payload : Bytes,
) -> Result[Bytes, String] {
  if key.length() != 32 || source.length() != 32 || interface_.length() != 32 {
    return Err("body-inference cache provenance digests must be SHA-256")
  }
  let output = Buffer(
    size_hint=body_inference_cache_file_magic.length() + 128 + payload.length(),
  )
  output.write_bytes(body_inference_cache_file_magic)
  for byte in key {
    output.write_byte(byte)
  }
  for byte in source {
    output.write_byte(byte)
  }
  for byte in interface_ {
    output.write_byte(byte)
  }
  for byte in @crypto.sha256(payload) {
    output.write_byte(byte)
  }
  output.write_bytes(payload)
  Ok(output.to_bytes())
}

///|
fn unwrap_body_inference_cache_payload(
  bytes : Bytes,
  key : FixedArray[Byte],
  source : FixedArray[Byte],
  interface_ : FixedArray[Byte],
) -> Result[Bytes, String] {
  let header_length = body_inference_cache_file_magic.length()
  let digest_length = 32
  let provenance_length = digest_length * 4
  if bytes.length() < header_length + provenance_length {
    return Err("truncated body-inference cache envelope")
  }
  for index in 0..<header_length {
    if bytes[index] != body_inference_cache_file_magic[index] {
      return Err("unsupported body-inference cache envelope")
    }
  }
  if key.length() != digest_length ||
    source.length() != digest_length ||
    interface_.length() != digest_length {
    return Err("invalid body-inference cache provenance request")
  }
  for index in 0..<digest_length {
    if bytes[header_length + index] != key[index] {
      return Err("body-inference cache key provenance mismatch")
    }
    if bytes[header_length + digest_length + index] != source[index] {
      return Err("body-inference cache source provenance mismatch")
    }
    if bytes[header_length + digest_length * 2 + index] != interface_[index] {
      return Err("body-inference cache interface provenance mismatch")
    }
  }
  let payload_start = header_length + provenance_length
  let payload = Buffer(size_hint=bytes.length() - payload_start)
  for index in payload_start..<bytes.length() {
    payload.write_byte(bytes[index])
  }
  let payload_bytes = payload.to_bytes()
  let actual = @crypto.sha256(payload_bytes)
  for index in 0..<digest_length {
    if bytes[header_length + digest_length * 3 + index] != actual[index] {
      return Err("body-inference cache checksum mismatch")
    }
  }
  Ok(payload_bytes)
}

///|
fn wrap_body_inference_family_cache_payload(
  key : FixedArray[Byte],
  source : FixedArray[Byte],
  context : FixedArray[Byte],
  payload : Bytes,
) -> Result[Bytes, String] {
  if key.length() != 32 || source.length() != 32 || context.length() != 32 {
    return Err("body-family cache provenance digests must be SHA-256")
  }
  let output = Buffer(
    size_hint=body_inference_family_cache_file_magic.length() +
      128 +
      payload.length(),
  )
  output.write_bytes(body_inference_family_cache_file_magic)
  for byte in key {
    output.write_byte(byte)
  }
  for byte in source {
    output.write_byte(byte)
  }
  for byte in context {
    output.write_byte(byte)
  }
  for byte in @crypto.sha256(payload) {
    output.write_byte(byte)
  }
  output.write_bytes(payload)
  Ok(output.to_bytes())
}

///|
fn unwrap_body_inference_family_cache_payload(
  bytes : Bytes,
  key : FixedArray[Byte],
  source : FixedArray[Byte],
  context : FixedArray[Byte],
) -> Result[Bytes, String] {
  let header_length = body_inference_family_cache_file_magic.length()
  let digest_length = 32
  let provenance_length = digest_length * 4
  if bytes.length() < header_length + provenance_length {
    return Err("truncated body-family cache envelope")
  }
  for index in 0..<header_length {
    if bytes[index] != body_inference_family_cache_file_magic[index] {
      return Err("unsupported body-family cache envelope")
    }
  }
  if key.length() != digest_length ||
    source.length() != digest_length ||
    context.length() != digest_length {
    return Err("invalid body-family cache provenance request")
  }
  for index in 0..<digest_length {
    if bytes[header_length + index] != key[index] {
      return Err("body-family cache key provenance mismatch")
    }
    if bytes[header_length + digest_length + index] != source[index] {
      return Err("body-family cache source provenance mismatch")
    }
    if bytes[header_length + digest_length * 2 + index] != context[index] {
      return Err("body-family cache context provenance mismatch")
    }
  }
  let payload_start = header_length + provenance_length
  let payload = Buffer(size_hint=bytes.length() - payload_start)
  for index in payload_start..<bytes.length() {
    payload.write_byte(bytes[index])
  }
  let payload_bytes = payload.to_bytes()
  let actual = @crypto.sha256(payload_bytes)
  for index in 0..<digest_length {
    if bytes[header_length + digest_length * 3 + index] != actual[index] {
      return Err("body-family cache checksum mismatch")
    }
  }
  Ok(payload_bytes)
}
