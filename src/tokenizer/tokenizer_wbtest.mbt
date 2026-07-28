///|
test "empty in-memory input" {
  let cursor = Utf8Cursor::new(b"")
  assert_eq(cursor.buffer_capacity(), 0)
  assert_eq(cursor.byte_offset(), 0UL)
  assert_eq(cursor.next(), None)
  assert_true(cursor.is_done())
}

///|
test "ascii code points preserve byte offsets" {
  let cursor = Utf8Cursor::new(b"dew")
  assert_eq(cursor.next(), Some((0x64U, 0UL)))
  assert_eq(cursor.next(), Some((0x65U, 1UL)))
  assert_eq(cursor.next(), Some((0x77U, 2UL)))
  assert_eq(cursor.next(), None)
  assert_eq(cursor.byte_offset(), 3UL)
}

///|
test "wtf8 decodes one through four byte sequences" {
  let cursor = Utf8Cursor::new(b"\x24\xC2\xA2\xE2\x82\xAC\xF0\x90\x8D\x88")
  assert_eq(cursor.next(), Some((0x24U, 0UL)))
  assert_eq(cursor.next(), Some((0xA2U, 1UL)))
  assert_eq(cursor.next(), Some((0x20ACU, 3UL)))
  assert_eq(cursor.next(), Some((0x10348U, 6UL)))
  assert_eq(cursor.next(), None)
  assert_eq(cursor.byte_offset(), 10UL)
}

///|
test "wtf8 accepts surrogate code points" {
  let cursor = Utf8Cursor::new(b"\xED\xA0\x80\xED\xBF\xBF")
  assert_eq(cursor.next(), Some((0xD800U, 0UL)))
  assert_eq(cursor.next(), Some((0xDFFFU, 3UL)))
  assert_true(is_surrogate(0xD800U))
  assert_false(is_unicode_scalar(0xD800U))
  assert_true(is_wtf8_codepoint(0xD800U))
}

///|
test "malformed bytes use lossless sentinels" {
  let cursor = Utf8Cursor::new(b"\xFF\x80A")
  let first = INVALID_BYTE_BASE + 0xFFU
  let second = INVALID_BYTE_BASE + 0x80U
  assert_eq(cursor.next(), Some((first, 0UL)))
  assert_eq(cursor.next(), Some((second, 1UL)))
  assert_eq(cursor.next(), Some((0x41U, 2UL)))
  assert_true(is_invalid_byte(first))
  assert_eq(invalid_byte(first), Some(b'\xFF'))
  assert_eq(invalid_byte(second), Some(b'\x80'))
  assert_eq(cursor.next(), None)
}

///|
test "literal replacement character differs from malformed byte" {
  let cursor = Utf8Cursor::new(b"\xEF\xBF\xBD\xFF")
  assert_eq(cursor.next(), Some((0xFFFDU, 0UL)))
  assert_eq(cursor.next(), Some((INVALID_BYTE_BASE + 0xFFU, 3UL)))
}

///|
test "overlong encodings preserve each malformed byte" {
  let cursor = Utf8Cursor::new(b"\xC0\xAF")
  assert_eq(cursor.next(), Some((INVALID_BYTE_BASE + 0xC0U, 0UL)))
  assert_eq(cursor.next(), Some((INVALID_BYTE_BASE + 0xAFU, 1UL)))
  assert_eq(cursor.next(), None)
}

///|
test "code points above unicode maximum preserve each malformed byte" {
  let cursor = Utf8Cursor::new(b"\xF4\x90\x80\x80")
  assert_eq(cursor.next(), Some((INVALID_BYTE_BASE + 0xF4U, 0UL)))
  assert_eq(cursor.next(), Some((INVALID_BYTE_BASE + 0x90U, 1UL)))
  assert_eq(cursor.next(), Some((INVALID_BYTE_BASE + 0x80U, 2UL)))
  assert_eq(cursor.next(), Some((INVALID_BYTE_BASE + 0x80U, 3UL)))
  assert_eq(cursor.next(), None)
}

///|
test "truncated sequences preserve one byte per sentinel" {
  let cursor = Utf8Cursor::new(b"\xE2\x82")
  assert_eq(cursor.next(), Some((INVALID_BYTE_BASE + 0xE2U, 0UL)))
  assert_eq(cursor.next(), Some((INVALID_BYTE_BASE + 0x82U, 1UL)))
  assert_eq(cursor.next(), None)
}

///|
test "iterator yields codepoint before byte offset" {
  assert_eq(codepoints(b"A\xC2\xA2").to_array(), [(0x41U, 0UL), (0xA2U, 1UL)])
}

///|
test "callback traversal shares the cursor without collecting" {
  let cursor = Utf8Cursor::new(b"A\xE2\x82\xAC")
  let mut count = 0
  let mut codepoint_sum = 0U
  let mut offset_sum = 0UL
  cursor.each(fn(codepoint, offset) {
    count += 1
    codepoint_sum += codepoint
    offset_sum += offset
  })
  assert_eq(count, 2)
  assert_eq(codepoint_sum, 0x41U + 0x20ACU)
  assert_eq(offset_sum, 1UL)
  assert_true(cursor.is_done())
}

///|
#cfg(target="native")
test "file descriptor cursor reuses one small buffer across boundaries" {
  let input = b"ABC\xE2\x82\xACZ"
  let fd = tokenizer_test_open_bytes(input, input.length())
  assert_true(fd >= 0)
  let cursor = Utf8Cursor::from_fd(fd, buffer_size=4)
  assert_eq(cursor.buffer_capacity(), 4)
  assert_eq(cursor.next(), Some((0x41U, 0UL)))
  assert_eq(cursor.next(), Some((0x42U, 1UL)))
  assert_eq(cursor.next(), Some((0x43U, 2UL)))
  assert_eq(cursor.next(), Some((0x20ACU, 3UL)))
  assert_eq(cursor.next(), Some((0x5AU, 6UL)))
  assert_eq(cursor.next(), None)
  assert_eq(cursor.byte_offset(), 7UL)
  assert_true(cursor.is_done())
  assert_eq(tokenizer_test_close_fd(fd), 0)
}

///|
#cfg(target="native")
test "four byte wtf8 sequence can cross a refill boundary" {
  let input = b"ABC\xF0\x90\x8D\x88Z"
  let fd = tokenizer_test_open_bytes(input, input.length())
  assert_true(fd >= 0)
  let cursor = Utf8Cursor::from_fd(fd, buffer_size=4)
  assert_eq(cursor.next(), Some((0x41U, 0UL)))
  assert_eq(cursor.next(), Some((0x42U, 1UL)))
  assert_eq(cursor.next(), Some((0x43U, 2UL)))
  assert_eq(cursor.next(), Some((0x10348U, 3UL)))
  assert_eq(cursor.next(), Some((0x5AU, 7UL)))
  assert_eq(cursor.next(), None)
  assert_eq(tokenizer_test_close_fd(fd), 0)
}

///|
#cfg(target="native")
test "file descriptor cursor preserves malformed bytes across boundaries" {
  let input = b"ABC\xE2\x82"
  let fd = tokenizer_test_open_bytes(input, input.length())
  assert_true(fd >= 0)
  let cursor = Utf8Cursor::from_fd(fd, buffer_size=4)
  assert_eq(cursor.next(), Some((0x41U, 0UL)))
  assert_eq(cursor.next(), Some((0x42U, 1UL)))
  assert_eq(cursor.next(), Some((0x43U, 2UL)))
  assert_eq(cursor.next(), Some((INVALID_BYTE_BASE + 0xE2U, 3UL)))
  assert_eq(cursor.next(), Some((INVALID_BYTE_BASE + 0x82U, 4UL)))
  assert_eq(cursor.next(), None)
  assert_eq(tokenizer_test_close_fd(fd), 0)
}

///|
#cfg(target="native")
test "descriptor errors yield one terminal sentinel" {
  let cursor = Utf8Cursor::from_fd(-1, buffer_size=4)
  let item = cursor.next()
  match item {
    Some((value, offset)) => {
      assert_true(is_io_error(value))
      assert_eq(offset, 0UL)
      assert_true(io_error_code(value).unwrap() > 0)
    }
    None => fail("expected I/O error sentinel")
  }
  assert_eq(cursor.next(), None)
  assert_true(cursor.is_done())
}
