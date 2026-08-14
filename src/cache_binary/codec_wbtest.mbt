///|
test "binary primitives have canonical golden bytes" {
  let writer = Writer::new(size_hint=64)
  writer.write_var_u64(0UL)
  writer.write_var_u64(127UL)
  writer.write_var_u64(128UL)
  writer.write_var_u64(0xffffffffffffffffUL)
  writer.write_zigzag_int(0)
  writer.write_zigzag_int(-1)
  writer.write_zigzag_int(1)
  writer.write_zigzag_int(-2147483647 - 1)
  writer.write_zigzag_int(2147483647)
  writer.write_u32_le(0x78563412U)
  writer.write_u64_le(0x8877665544332211UL)
  writer.write_f32(Float::reinterpret_from_uint(0x80000000U))
  writer.write_f64(0x7ff8000000000001UL.reinterpret_as_double())
  writer.write_bool(false)
  writer.write_bool(true)
  assert_eq(
    writer.to_bytes(),
    b"\x00\x7f\x80\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x01\x02\xff\xff\xff\xff\x0f\xfe\xff\xff\xff\x0f\x12\x34\x56\x78\x11\x22\x33\x44\x55\x66\x77\x88\x00\x00\x00\x80\x01\x00\x00\x00\x00\x00\xf8\x7f\x00\x01",
  )
}

///|
test "binary reader round trips boundaries and exact float bits" {
  let writer = Writer::new()
  for
    value in [
      0UL, 1UL, 127UL, 128UL, 16383UL, 16384UL, 0xffffffffUL, 0xffffffffffffffffUL,
    ] {
    writer.write_var_u64(value)
  }
  for value in [-2147483647 - 1, -1, 0, 1, 2147483647] {
    writer.write_zigzag_int(value)
  }
  writer.write_u32_le(0xffffffffU)
  writer.write_u64_le(0xffffffffffffffffUL)
  writer.write_f32(Float::reinterpret_from_uint(0x7fc00001U))
  writer.write_f64(0xfff0000000000000UL.reinterpret_as_double())
  let reader = Reader::new(writer.to_bytes(), context="root")
  for
    expected in [
      0UL, 1UL, 127UL, 128UL, 16383UL, 16384UL, 0xffffffffUL, 0xffffffffffffffffUL,
    ] {
    assert_eq(reader.read_var_u64("varint"), expected)
  }
  for expected in [-2147483647 - 1, -1, 0, 1, 2147483647] {
    assert_eq(reader.read_zigzag_int("zigzag"), expected)
  }
  assert_eq(reader.read_u32_le("u32"), 0xffffffffU)
  assert_eq(reader.read_u64_le("u64"), 0xffffffffffffffffUL)
  assert_eq(reader.read_f32("f32").reinterpret_as_uint(), 0x7fc00001U)
  assert_eq(
    reader.read_f64("f64").reinterpret_as_uint64(),
    0xfff0000000000000UL,
  )
  assert_eq(reader.finish(), Ok(()))
}

///|
test "binary reader rejects noncanonical, truncated, invalid tags, and UTF-8" {
  let overlong = Reader::new(b"\x80\x00", context="test")
  ignore(overlong.read_var_u64("count"))
  assert_true(overlong.finish() is Err(_))
  let overflow = Reader::new(
    b"\xff\xff\xff\xff\xff\xff\xff\xff\xff\x02",
    context="test",
  )
  ignore(overflow.read_var_u64("count"))
  assert_true(overflow.finish() is Err(_))
  let truncated = Reader::new(b"\x80", context="test")
  ignore(truncated.read_var_u64("count"))
  assert_true(truncated.finish() is Err(_))
  let invalid_bool = Reader::new(b"\x02", context="test")
  ignore(invalid_bool.read_bool("flag"))
  assert_true(invalid_bool.finish() is Err(_))
  let invalid_option = Reader::new(b"\x02", context="test")
  ignore(invalid_option.read_option_tag("optional"))
  assert_true(invalid_option.finish() is Err(_))
  let invalid_utf8 = Reader::new(b"\x01\xff", context="test")
  ignore(invalid_utf8.read_string(8, "name"))
  assert_true(invalid_utf8.finish() is Err(_))
}

///|
test "binary strings, bytes, sections, and deterministic encoding are bounded" {
  let encode = fn() {
    let writer = Writer::new(size_hint=32)
    writer.write_bytes(b"")
    writer.write_bytes(b"abc")
    writer.write_string("Dew")
    let section = Writer::new()
    section.write_var_u64(42UL)
    writer.write_section(section.to_bytes())
    writer.to_bytes()
  }
  let first = encode()
  assert_eq(encode(), first)
  let reader = Reader::new(first, context="root")
  assert_eq(reader.read_bytes(16, "empty"), b"")
  assert_eq(reader.read_bytes(16, "bytes"), b"abc")
  assert_eq(reader.read_string(16, "text"), "Dew")
  let section = reader.read_section(16, "section")
  assert_eq(section.read_var_u64("answer"), 42UL)
  assert_eq(section.finish(), Ok(()))
  assert_eq(reader.finish(), Ok(()))

  let under = Reader::new(b"\x02\x01\x00", context="root")
  let child = under.read_section(8, "child")
  ignore(child.read_byte("one"))
  assert_true(child.finish() is Err(_))
  assert_eq(under.finish(), Ok(()))

  let over = Reader::new(b"\x01\x00", context="root")
  ignore(over.read_section(0, "child"))
  assert_true(over.finish() is Err(_))
}

///|
test "artifact container binds kind version provenance checksum and end" {
  let provenance = [@crypto.sha256(b"source"), @crypto.sha256(b"context")]
  let encoded = wrap_artifact(3, 4U, provenance, b"payload").unwrap()
  assert_eq(unwrap_artifact(encoded, 3, 4U, provenance).unwrap(), b"payload")
  assert_true(unwrap_artifact(encoded, 2, 4U, provenance) is Err(_))
  assert_true(unwrap_artifact(encoded, 3, 5U, provenance) is Err(_))
  let wrong = [@crypto.sha256(b"changed"), provenance[1]]
  assert_true(unwrap_artifact(encoded, 3, 4U, wrong) is Err(_))
  let corrupt = Buffer(size_hint=encoded.length())
  for index in 0..<(encoded.length() - 1) {
    corrupt.write_byte(encoded[index])
  }
  corrupt.write_byte(b'x')
  assert_true(unwrap_artifact(corrupt.to_bytes(), 3, 4U, provenance) is Err(_))
  let trailing = Buffer()
  trailing.write_bytes(encoded)
  trailing.write_byte(0)
  assert_true(unwrap_artifact(trailing.to_bytes(), 3, 4U, provenance) is Err(_))
}
