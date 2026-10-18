///|
test "invalid escapes preserve the closing quote and following delimiters" {
  for source in [b"\"\\q\", fn() {", b"\"\\xG0\", fn() {", b"b\"\\x0\", fn() {"] {
    let kinds = token_kinds(source)
    assert_eq(kinds.length(), 6)
    assert_true(kinds[0] is Error(InvalidEscape(_)))
    assert_eq(kinds[1], Symbol(Comma))
    assert_eq(kinds[2], Keyword(Fn))
    assert_eq(kinds[3], Symbol(LeftParen))
    assert_eq(kinds[4], Symbol(RightParen))
    assert_eq(kinds[5], Symbol(LeftBrace))
  }
}

///|
test "invalid string escape recovery respects escaped quotes and newlines" {
  assert_eq(token_kinds(b"\"\\q\\\"tail\" after"), [
    Error(InvalidEscape(0x71U)),
    Identifier("after"),
  ])
  for source in [b"\"\\q\nafter", b"\"\\x\nafter", b"\"\\x0\r\nafter"] {
    let kinds = token_kinds(source)
    assert_eq(kinds.length(), 3)
    assert_true(kinds[0] is Error(InvalidEscape(_)))
    assert_eq(kinds[1], Newline)
    assert_eq(kinds[2], Identifier("after"))
  }
  assert_eq(token_kinds(b"\"\\\nafter"), [
    Error(UnterminatedString),
    Newline,
    Identifier("after"),
  ])
}

///|
#cfg(target="native")
test "invalid escape tail preserves terminal source errors" {
  let tokenizer = tokenizer_with_terminal_error(b"\"\\qtail", 5)
  assert_eq(tokenizer.iter().map(token => token.kind()).to_array(), [
    Error(SourceIo(5)),
  ])
}
