///|
test "struct fields retain explicit module privacy and public defaults" {
  match
    Parser::from_bytes(
      b"pub struct Record<t> {\n  private mut value: t\n  public_value: I32\n}\n",
    ).parse_declaration() {
    Ok(Struct(value)) => {
      assert_eq(value.fields.length(), 2)
      assert_true(value.fields[0].module_private)
      assert_true(value.fields[0].mutable_)
      assert_eq(value.fields[0].name, "value")
      assert_false(value.fields[1].module_private)
    }
    _ => fail("expected private field")
  }
}

///|
test "private remains a valid unmarked struct field name" {
  match
    Parser::from_bytes(b"struct Record {\n  private: I32\n}\n").parse_declaration() {
    Ok(Struct(value)) => {
      assert_eq(value.fields[0].name, "private")
      assert_false(value.fields[0].module_private)
    }
    _ => fail("expected field named private")
  }
}

///|
test "parse-event artifact preserves module private field flags" {
  let events = parse_bytes(
    b"pub struct Record {\n  private mut value: I32\n  label: I32\n}\n",
  ).to_array()
  assert_false(events.any(fn(event) { event is Diagnostic(_) }))
  let restored = deserialize_parse_events(
    serialize_parse_events(events).unwrap(),
  ).unwrap()
  assert_eq(restored, events)
}
