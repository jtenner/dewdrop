///|
test "parse-event cache envelope verifies checksum and provenance" {
  let key = @crypto.sha256(b"key")
  let source = @crypto.sha256(b"source")
  let payload = b"payload"
  let wrapped = wrap_parse_event_cache_payload(key, source, payload).unwrap()
  assert_eq(
    unwrap_parse_event_cache_payload(wrapped, key, source).unwrap(),
    payload,
  )
  let changed_key = @crypto.sha256(b"other-key")
  match unwrap_parse_event_cache_payload(wrapped, changed_key, source) {
    Err(error) => assert_eq(error, "parse-event cache key provenance mismatch")
    Ok(_) => fail("expected key provenance mismatch")
  }
  let corrupt = Buffer()
  for index in 0..<(wrapped.length() - 1) {
    corrupt.write_byte(wrapped[index])
  }
  corrupt.write_byte(b'x')
  match unwrap_parse_event_cache_payload(corrupt.to_bytes(), key, source) {
    Err(error) => assert_eq(error, "parse-event cache checksum mismatch")
    Ok(_) => fail("expected checksum mismatch")
  }
}
