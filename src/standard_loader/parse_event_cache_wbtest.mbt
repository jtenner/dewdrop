///|
test "parse-event cache envelope verifies checksum and provenance" {
  let key = @crypto.sha256(b"key")
  let source = @crypto.sha256(b"source")
  let payload = b"payload"
  let wrapped = wrap_parse_event_cache_payload(key, source, payload).unwrap()
  assert_eq(wrapped[8], 1)
  assert_eq(wrapped[9], 1)
  assert_eq(wrapped[10], 0)
  assert_eq(wrapped[11], 0)
  assert_eq(wrapped[12], 0)
  assert_true(
    parse_event_cache_file(key).has_suffix(
      "/parse-events/v1-" + @crypto.bytes_to_hex_string(key) + ".dpe",
    ),
  )
  assert_eq(
    unwrap_parse_event_cache_payload(wrapped, key, source).unwrap(),
    payload,
  )
  for cut in 0..<wrapped.length() {
    let truncated = Buffer(size_hint=cut)
    for index in 0..<cut {
      truncated.write_byte(wrapped[index])
    }
    assert_true(
      unwrap_parse_event_cache_payload(truncated.to_bytes(), key, source)
      is Err(_),
    )
  }
  for selected in 0..<wrapped.length() {
    let mutated = Buffer(size_hint=wrapped.length())
    for index in 0..<wrapped.length() {
      mutated.write_byte(
        if index == selected {
          wrapped[index] ^ 0x80
        } else {
          wrapped[index]
        },
      )
    }
    assert_true(
      unwrap_parse_event_cache_payload(mutated.to_bytes(), key, source)
      is Err(_),
    )
  }
  let changed_key = @crypto.sha256(b"other-key")
  match unwrap_parse_event_cache_payload(wrapped, changed_key, source) {
    Err(error) => assert_true(error.contains("provenance mismatch"))
    Ok(_) => fail("expected key provenance mismatch")
  }
  let corrupt = Buffer()
  for index in 0..<(wrapped.length() - 1) {
    corrupt.write_byte(wrapped[index])
  }
  corrupt.write_byte(b'x')
  match unwrap_parse_event_cache_payload(corrupt.to_bytes(), key, source) {
    Err(error) => assert_true(error.contains("checksum mismatch"))
    Ok(_) => fail("expected checksum mismatch")
  }
}
