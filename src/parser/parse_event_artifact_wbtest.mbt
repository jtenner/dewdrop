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
test "parse-event artifact locks V4 header and declaration discriminants" {
  let events : Array[ParseEvent] = [
    Declaration(
      Let({
        visibility: ModuleVisible,
        mutable_: false,
        name: "x",
        name_offset: 4UL,
        value: I32Expr(1UL, 8UL),
        offset: 0UL,
      }),
    ),
  ]
  assert_eq(
    serialize_parse_events(events).unwrap(),
    b"\x04\x00\x00\x00\x01\x00\x02\x00\x00\x01x\x04\x02\x01\x08\x00",
  )
}

///|
test "parse-event artifact rejects malformed payloads without panic" {
  assert_true(deserialize_parse_events(b"not-binary") is Err(_))
  let valid = serialize_parse_events(
    parse_bytes(b"fn value() -> I32 {\n  1\n}\n").to_array(),
  ).unwrap()
  for cut in 0..<valid.length() {
    let truncated = Buffer(size_hint=cut)
    for index in 0..<cut {
      truncated.write_byte(valid[index])
    }
    assert_true(deserialize_parse_events(truncated.to_bytes()) is Err(_))
  }
  for selected in 0..<valid.length() {
    let mutated = Buffer(size_hint=valid.length())
    for index in 0..<valid.length() {
      mutated.write_byte(
        if index == selected {
          valid[index] ^ 0xff
        } else {
          valid[index]
        },
      )
    }
    match deserialize_parse_events(mutated.to_bytes()) {
      Ok(value) =>
        assert_eq(serialize_parse_events(value).unwrap(), mutated.to_bytes())
      Err(_) => ()
    }
  }
  let invalid_event_tag = Buffer(size_hint=valid.length())
  for index in 0..<valid.length() {
    invalid_event_tag.write_byte(if index == 5 { 0xff } else { valid[index] })
  }
  assert_true(deserialize_parse_events(invalid_event_tag.to_bytes()) is Err(_))
}
