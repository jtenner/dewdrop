///|
let parse_event_cache_file_magic : Bytes = b"DEW_PARSE_EVENT_CACHE_V3\x00"

///|
fn wrap_parse_event_cache_payload(
  key_digest : FixedArray[Byte],
  source_digest : FixedArray[Byte],
  payload : Bytes,
) -> Result[Bytes, String] {
  if key_digest.length() != 32 || source_digest.length() != 32 {
    return Err("invalid parse-event cache provenance digest")
  }
  let output = Buffer()
  output.write_bytes(parse_event_cache_file_magic)
  for byte in key_digest {
    output.write_byte(byte)
  }
  for byte in source_digest {
    output.write_byte(byte)
  }
  for byte in @crypto.sha256(payload) {
    output.write_byte(byte)
  }
  output.write_bytes(payload)
  Ok(output.to_bytes())
}

///|
fn unwrap_parse_event_cache_payload(
  bytes : Bytes,
  expected_key_digest : FixedArray[Byte],
  expected_source_digest : FixedArray[Byte],
) -> Result[Bytes, String] {
  let header_length = parse_event_cache_file_magic.length()
  let digest_length = 32
  let provenance_length = digest_length * 3
  if bytes.length() < header_length + provenance_length {
    return Err("truncated parse-event cache envelope")
  }
  for index in 0..<header_length {
    if bytes[index] != parse_event_cache_file_magic[index] {
      return Err("unsupported parse-event cache envelope")
    }
  }
  if expected_key_digest.length() != digest_length ||
    expected_source_digest.length() != digest_length {
    return Err("invalid expected parse-event cache provenance")
  }
  for index in 0..<digest_length {
    if bytes[header_length + index] != expected_key_digest[index] {
      return Err("parse-event cache key provenance mismatch")
    }
    if bytes[header_length + digest_length + index] !=
      expected_source_digest[index] {
      return Err("parse-event cache source provenance mismatch")
    }
  }
  let payload = Buffer()
  let payload_start = header_length + provenance_length
  for index in payload_start..<bytes.length() {
    payload.write_byte(bytes[index])
  }
  let payload_bytes = payload.to_bytes()
  let actual = @crypto.sha256(payload_bytes)
  for index in 0..<digest_length {
    if bytes[header_length + digest_length * 2 + index] != actual[index] {
      return Err("parse-event cache checksum mismatch")
    }
  }
  Ok(payload_bytes)
}
