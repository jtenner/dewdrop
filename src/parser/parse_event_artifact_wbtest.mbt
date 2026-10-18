///|
test "parse-event artifact preserves nested product patterns and their errors" {
  let events = parse_bytes(
    b"fn value(input: (I32, I64)) -> I32 {\n match input {\n (left, right) => left\n }\n}\n",
  ).to_array()
  for event in events {
    assert_false(event is Diagnostic(_))
  }
  assert_eq(
    deserialize_parse_events(serialize_parse_events(events).unwrap()).unwrap(),
    events,
  )
  let invalid = parse_bytes(
    b"fn value(input: I32) -> I32 {\n match input {\n (left,) => left\n }\n}\n",
  ).to_array()
  assert_true(invalid.any(fn(event) { event is Diagnostic(_) }))
  assert_eq(
    deserialize_parse_events(serialize_parse_events(invalid).unwrap()).unwrap(),
    invalid,
  )
}

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
test "parse-event artifact preserves local computed type bindings" {
  let events = parse_bytes(
    b"fn main() -> Unit {\n type Item = field_type<Box<I64>>(\"item\")\n}\n",
  ).to_array()
  for event in events {
    assert_false(event is Diagnostic(_))
  }
  let encoded = serialize_parse_events(events).unwrap()
  assert_eq(deserialize_parse_events(encoded).unwrap(), events)
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
test "parse-event artifact locks V1 header and declaration discriminants" {
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
    b"\x01\x00\x00\x00\x01\x00\x02\x00\x00\x01x\x04\x02\x01\x08\x00",
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

///|
test "parse-event cache admission matches the expression depth boundary" {
  for terms in [2044, 2045, 2046, 2055] {
    let source = Buffer()
    source.write_bytes(b"fn value() -> I32 {\n  1")
    for _ in 1..<terms {
      source.write_bytes(b" + 1")
    }
    source.write_bytes(b"\n}\n")
    let events = parse_bytes(source.to_bytes()).to_array()
    assert_false(events.any(fn(event) { event is Diagnostic(_) }))
    if terms <= 2045 {
      let payload = serialize_parse_events_for_cache(events).unwrap()
      assert_eq(deserialize_parse_events(payload).unwrap(), events)
      assert_eq(serialize_parse_events(events).unwrap(), payload)
    } else {
      assert_eq(serialize_parse_events_for_cache(events), None)
      assert_eq(
        serialize_parse_events(events),
        Err("parse_event_payload: syntax nesting exceeds limit"),
      )
    }
  }
}

///|
test "parse-event writer and reader agree on recursive type depth" {
  for depth in [2047, 2048, 2049] {
    let mut value = NamedType("I32", 0UL)
    for _ in 0..<depth {
      value = ComputedType(value, b"item", 0UL)
    }
    let writer = @cache_binary.Writer::new()
    let admission = { rejected: false, items_exceeded: false, }
    parse_write_type(writer, value, admission, 0)
    assert_eq(admission.rejected, depth > parse_event_maximum_depth)
    if !admission.rejected {
      let reader = @cache_binary.Reader::new(
        writer.to_bytes(),
        detailed_paths=false,
      )
      let _ = parse_read_type(reader, "type", 0)
      assert_eq(reader.finish(), Ok(()))
    }
  }
}

///|
test "parse-event writer and reader agree on recursive pattern depth" {
  for depth in [2047, 2048, 2049] {
    let mut value = WildcardPattern(0UL)
    for _ in 0..<depth {
      value = QualifiedPattern(value, "item", 0UL)
    }
    let writer = @cache_binary.Writer::new()
    let admission = { rejected: false, items_exceeded: false, }
    parse_write_pattern(writer, value, admission, 0)
    assert_eq(admission.rejected, depth > parse_event_maximum_depth)
    if !admission.rejected {
      let reader = @cache_binary.Reader::new(
        writer.to_bytes(),
        detailed_paths=false,
      )
      let _ = parse_read_pattern(reader, "pattern", 0)
      assert_eq(reader.finish(), Ok(()))
    }
  }
}

///|
test "parse-event reader still rejects stored syntax above the depth limit" {
  let writer = @cache_binary.Writer::new()
  // Raw prefix-expression bytes bypass writer admission, as corrupt stored
  // bytes can. Positive has discriminant zero; PrefixExpr has tag 25.
  for _ in 0..<(parse_event_maximum_depth + 1) {
    writer.write_byte(25)
    writer.write_byte(0)
  }
  writer.write_byte(2)
  writer.write_var_u64(1UL)
  writer.write_var_u64(0UL)
  for _ in 0..<(parse_event_maximum_depth + 1) {
    writer.write_var_u64(0UL)
  }
  let reader = @cache_binary.Reader::new(
    writer.to_bytes(),
    detailed_paths=false,
  )
  let _ = parse_read_expr(reader, "expression", 0)
  match reader.finish() {
    Err(error) => assert_true(error.contains("syntax nesting exceeds limit"))
    Ok(_) => fail("expected an error for corrupt stored deep syntax")
  }
}

///|
test "parse-event item admission matches reader count boundaries" {
  for maximum in [32, parse_event_maximum_items] {
    for count in [maximum - 1, maximum, maximum + 1] {
      let writer = @cache_binary.Writer::new()
      let admission = { rejected: false, items_exceeded: false, }
      let admitted = parse_write_count(writer, count, admission, maximum~)
      assert_eq(admitted, count <= maximum)
      assert_eq(admission.rejected, count > maximum)
      assert_eq(admission.items_exceeded, count > maximum)
      if admitted {
        // Each list entry requires at least one payload byte. These bytes
        // exercise the reader guard without allocating syntax objects.
        for _ in 0..<count {
          writer.write_byte(0)
        }
        let reader = @cache_binary.Reader::new(writer.to_bytes())
        assert_eq(reader.read_count(maximum, "count"), count)
        reader.skip(count, "items")
        assert_eq(reader.finish(), Ok(()))
      } else {
        assert_eq(writer.length(), 0)
      }
    }
  }
}

///|
test "parse-event oversized array rejects before writing or walking elements" {
  let shared = I32Expr(1UL, 0UL)
  let elements = Array::make(parse_event_maximum_items + 1, shared)
  let writer = @cache_binary.Writer::new()
  let admission = { rejected: false, items_exceeded: false, }
  parse_write_exprs(writer, elements, admission, 0)
  assert_true(admission.rejected)
  assert_true(admission.items_exceeded)
  assert_eq(writer.length(), 0)
  let events = [
    Declaration(
      Let({
        visibility: ModuleVisible,
        mutable_: false,
        name: "large",
        name_offset: 0UL,
        value: ArrayExpr(elements, 0UL),
        offset: 0UL,
      }),
    ),
  ]
  assert_eq(serialize_parse_events_for_cache(events), None)
  assert_eq(
    serialize_parse_events(events),
    Err("parse_event_payload: item count exceeds limit"),
  )
  assert_eq(elements.length(), parse_event_maximum_items + 1)
  assert_eq(elements[0], shared)
  assert_eq(elements[elements.length() - 1], shared)
}

///|
test "parse-event oversized event count rejects before writer allocation" {
  let shared = Diagnostic({
    severity: Error,
    error: ImportAfterDeclaration(0UL),
  })
  let events = Array::make(parse_event_maximum_items + 1, shared)
  assert_eq(serialize_parse_events_for_cache(events), None)
  assert_eq(
    serialize_parse_events(events),
    Err("parse_event_payload: item count exceeds limit"),
  )
}

///|
test "parse-event product diagnostic counts obey the reader bound" {
  for arity in [31, 32, 33] {
    let events = [
      Diagnostic({
        severity: Error,
        error: DeclarationExpressionError(InvalidProductArity(arity, 0UL)),
      }),
      Diagnostic({
        severity: Error,
        error: InvalidProductTypeArity(arity, 0UL),
      }),
    ]
    if arity <= 32 {
      let payload = serialize_parse_events(events).unwrap()
      assert_eq(deserialize_parse_events(payload).unwrap(), events)
    } else {
      assert_eq(serialize_parse_events_for_cache(events), None)
      assert_eq(
        serialize_parse_events(events),
        Err("parse_event_payload: item count exceeds limit"),
      )
    }
  }
}

///|
test "parse-event reader keeps oversized stored counts visible" {
  let writer = @cache_binary.Writer::new()
  writer.write_u32_le(parse_event_payload_version)
  writer.write_var_u64((parse_event_maximum_items + 1).to_uint64())
  match deserialize_parse_events(writer.to_bytes()) {
    Err(error) => assert_true(error.contains("count exceeds limit"))
    Ok(_) => fail("expected stored oversized event count to be rejected")
  }
}

///|
test "parse-event scalar field bounds do not require array payload bytes" {
  let events = [
    Declaration(
      Let({
        visibility: ModuleVisible,
        mutable_: false,
        name: "last",
        name_offset: 0UL,
        value: ProductFieldExpr(NameExpr("value", 0UL), 31, 32, 0UL),
        offset: 0UL,
      }),
    ),
    Diagnostic({
      severity: Error,
      error: DeclarationExpressionError(
        MatchPatternError(
          InvalidProductPatternArity(parse_event_maximum_items, 0UL),
        ),
      ),
    }),
  ]
  let payload = serialize_parse_events(events).unwrap()
  assert_eq(deserialize_parse_events(payload).unwrap(), events)
}
