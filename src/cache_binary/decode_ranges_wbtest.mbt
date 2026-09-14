///|
test "bulk decode respects bytes strings and bounded reader ranges" {
  let reader = Reader::new(b"!abc?")
  reader.skip(1, "prefix")
  assert_eq(reader.read_raw_bytes(3, 3, "value"), b"abc")
  assert_eq(reader.position(), 4)
  assert_eq(reader.read_raw_bytes(1, 1, "tail"), b"?")
  assert_eq(reader.finish(), Ok(()))
  let outer = Reader::new(b"\x03abcZ")
  let section = outer.read_section(3, "section")
  assert_eq(section.read_raw_bytes(3, 3, "value"), b"abc")
  assert_eq(section.finish(), Ok(()))
  assert_eq(outer.read_raw_bytes(1, 1, "tail"), b"Z")
  assert_eq(outer.finish(), Ok(()))
  for value in ["", "ascii", "é水😀"] {
    let writer = Writer::new()
    writer.write_string(value)
    let reader = Reader::new(writer.to_bytes())
    assert_eq(reader.read_string(1024, "text"), value)
    assert_eq(reader.finish(), Ok(()))
  }
}

///|
test "bulk decode keeps diagnostic errors and failed read positions" {
  for
    (length, limit, message) in [
      (-1, 4, "byte length exceeds limit"),
      (5, 4, "byte length exceeds limit"),
      (4, 4, "truncated byte string"),
    ] {
    let reader = Reader::new(b"abc")
    assert_eq(reader.read_raw_bytes(length, limit, "value"), b"")
    assert_eq(reader.position(), 0)
    assert_true(reader.finish() is Err(_))
    assert_eq(reader.error, Some("artifact.value at byte 0: " + message))
  }
  let reader = Reader::new(b"\x02\xff\xff")
  assert_eq(reader.read_string(2, "text"), "")
  assert_eq(reader.position(), 3)
  assert_true(reader.finish() is Err(_))
  let outer = Reader::new(b"\x01aZ")
  let section = outer.read_section(1, "section")
  assert_eq(section.read_raw_bytes(2, 2, "value"), b"")
  assert_eq(section.position(), 0)
  assert_true(section.finish() is Err(_))
  assert_eq(outer.read_byte("tail"), b'Z')
}
