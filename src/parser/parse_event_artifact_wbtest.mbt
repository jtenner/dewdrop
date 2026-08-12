///|
test "parse-event artifact round-trips complete declarations and diagnostics" {
  let events = parse_bytes(
    b"open app.library\npub fn value(input: F32) -> F32 {\n  input + 1.5f32\n}\npub struct Pair {\n  left: I32\n  right: I32\n}\ninvalid declaration\n",
  ).to_array()
  let payload = serialize_parse_events(events).unwrap()
  assert_eq(deserialize_parse_events(payload).unwrap(), events)
  assert_eq(
    serialize_parse_events(deserialize_parse_events(payload).unwrap()).unwrap(),
    payload,
  )
}

///|
test "parse-event artifact preserves non-finite F32 payload bits" {
  let before = Float::reinterpret_from_uint(0x7fc00001U)
  let events : Array[ParseEvent] = [
    Declaration(
      Let({
        visibility: ModuleVisible,
        mutable_: false,
        name: "value",
        name_offset: 4UL,
        value: F32Expr(before, 12UL),
        offset: 0UL,
      }),
    ),
  ]
  let payload = serialize_parse_events(events).unwrap()
  let restored = deserialize_parse_events(payload).unwrap()
  match restored[0] {
    Declaration(Let({ value: F32Expr(after, _), .. })) =>
      assert_eq(before.reinterpret_as_uint(), after.reinterpret_as_uint())
    _ => fail("expected one F32 let declaration")
  }
}

///|
test "parse-event artifact rejects malformed payloads" {
  match deserialize_parse_events(b"not-json") {
    Err(error) => assert_true(error.contains("valid JSON"))
    Ok(_) => fail("expected malformed parse-event payload")
  }
}
