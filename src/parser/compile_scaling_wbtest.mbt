///|
test "deep cached syntax preserves bytes and complete truncated field paths" {
  let source = Buffer()
  source.write_string_utf8("fn value() -> I32 {\n  1")
  for _ in 0..<128 {
    source.write_string_utf8(" + 1")
  }
  source.write_string_utf8("\n}\n")
  let events = parse_bytes(source.to_bytes()).to_array()
  for event in events {
    assert_false(event is Diagnostic(_))
  }
  let encoded = serialize_parse_events(events).unwrap()
  assert_eq(deserialize_parse_events(encoded).unwrap(), events)
  assert_eq(
    serialize_parse_events(deserialize_parse_events(encoded).unwrap()).unwrap(),
    encoded,
  )
  // Every truncation must retain the old decoder's exact diagnostic.
  for cut in 0..<encoded.length() {
    let truncated = encoded[:cut].to_owned()
    let detailed = parse_decode_events(truncated, detailed_paths=true)
    assert_true(detailed is Err(_))
    assert_eq(deserialize_parse_events(truncated), detailed)
  }
}
