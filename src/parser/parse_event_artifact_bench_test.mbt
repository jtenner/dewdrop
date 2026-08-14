///|
fn parse_event_binary_benchmark_events() -> Array[ParseEvent] {
  let source = Buffer()
  for index in 0..<128 {
    source.write_string_utf8(
      "fn value_\{index}(input: I32) -> I32 {\n  if input < \{index} {\n    input + \{index}\n  } else {\n    input - \{index}\n  }\n}\n",
    )
  }
  parse_bytes(source.to_bytes()).to_array()
}

///|
test "bench parse-event binary encode 128 declarations" (it : @bench.T) {
  let events = parse_event_binary_benchmark_events()
  it.bench(fn() {
    let encoded = serialize_parse_events(events).unwrap()
    it.keep(encoded.length())
  })
}

///|
test "bench parse-event binary decode 128 declarations" (it : @bench.T) {
  let encoded = serialize_parse_events(parse_event_binary_benchmark_events()).unwrap()
  it.bench(fn() {
    let decoded = deserialize_parse_events(encoded).unwrap()
    it.keep(decoded.length())
  })
}

///|
test "bench parse-event legacy JSON encode 128 declarations" (it : @bench.T) {
  let events = parse_event_binary_benchmark_events()
  it.bench(fn() {
    let encoded = @utf8.encode(events.to_json().stringify())
    it.keep(encoded.length())
  })
}

///|
test "bench parse-event legacy JSON decode 128 declarations" (it : @bench.T) {
  let encoded = @utf8.encode(
    parse_event_binary_benchmark_events().to_json().stringify(),
  )
  it.bench(fn() {
    let text = @utf8.decode(encoded) catch { _ => abort("valid UTF-8") }
    let json = @json.parse(text) catch { _ => abort("valid JSON") }
    let decoded : Array[ParseEvent] = @json.from_json(json) catch {
      _ => abort("valid parser-event JSON")
    }
    it.keep(decoded.length())
  })
}
