///|
test "bench deep cached expression terms=128" (it : @bench.T) {
  let source = Buffer()
  source.write_string_utf8("fn value() -> I32 {\n ")
  for i in 0..<128 {
    if i > 0 {
      source.write_string_utf8(" + ")
    }
    source.write_string_utf8("1")
  }
  source.write_string_utf8("\n}\n")
  let events = parse_bytes(source.to_bytes()).to_array()
  if events.any(fn(event) { event is Diagnostic(_) }) {
    abort("invalid benchmark source")
  }
  let encoded = serialize_parse_events(events).unwrap()
  it.bench(fn() { it.keep(deserialize_parse_events(encoded).unwrap()) })
}

///|
test "bench deep cached expression terms=1024" (it : @bench.T) {
  let source = Buffer()
  source.write_string_utf8("fn value() -> I32 {\n ")
  for i in 0..<1024 {
    if i > 0 {
      source.write_string_utf8(" + ")
    }
    source.write_string_utf8("1")
  }
  source.write_string_utf8("\n}\n")
  let events = parse_bytes(source.to_bytes()).to_array()
  if events.any(fn(event) { event is Diagnostic(_) }) {
    abort("invalid benchmark source")
  }
  let encoded = serialize_parse_events(events).unwrap()
  it.bench(fn() { it.keep(deserialize_parse_events(encoded).unwrap()) })
}
