///|
test "computed type calls are accepted in aliases and generic arguments" {
  for
    source in [
      b"type Item = field_type<Record>(\"item\")", b"type Item = @types.field_type::<Record>(\"item\")",
      b"type Payload = variant_payload_types<Message>(\"Value\")", b"type Nested = Box<field_type<Record>(\"item\")>",
    ] {
    match parse_test_declaration(source) {
      Ok(TypeAlias(_)) => ()
      other =>
        fail("expected a computed type alias: " + @debug.to_string(other))
    }
  }
}

///|
test "computed type selectors must be constant strings" {
  for
    source in [
      b"type Item = field_type<Record>(name)", b"type Item = field_type<Record>(123)",
      b"type Item = field_type<Record>(\"first\", \"second\")",
    ] {
    match parse_test_declaration(source) {
      Err(_) => ()
      other =>
        fail("expected a selector diagnostic: " + @debug.to_string(other))
    }
  }
}

///|
test "computed types round trip in version one parse artifacts" {
  let events = parse_bytes(
    b"type Payload = variant_payload_types<Message>(\"Value\")\n",
  ).to_array()
  assert_eq(events.length(), 1)
  assert_true(events[0] is Declaration(TypeAlias(_)))
  let bytes = serialize_parse_events(events).unwrap()
  assert_eq(deserialize_parse_events(bytes).unwrap(), events)
}

///|
test "computed type errors in expressions survive recovery and serialization" {
  match parse_test_expression(b"identity::<field_type<Record>(name)>(value)") {
    Err(TypeArgumentError(Type, Some(token), _)) =>
      assert_true(token.offset() > 0UL)
    other => fail("expected a type argument error: " + @debug.to_string(other))
  }
  for
    source in [
      b"fn bad() -> Unit {\n  identity::<field_type<Record>(name)>(value)\n}\n",
      b"fn bad() -> Unit {\n  identity::<field_type<Record>(123)>(value)\n}\n",
    ] {
    let events = parse_bytes(source).to_array()
    assert_true(events.length() > 0)
    assert_false(events[0] is Declaration(_))
    let bytes = serialize_parse_events(events).unwrap()
    assert_eq(deserialize_parse_events(bytes).unwrap(), events)
  }
  match
    parse_test_declaration(
      b"fn good() -> Unit {\n  identity::<Box<I64>>(value)\n}\n",
    ) {
    Ok(_) => ()
    other =>
      fail("nested type closer consumed a call: " + @debug.to_string(other))
  }
}
