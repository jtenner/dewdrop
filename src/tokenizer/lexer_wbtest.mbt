///|
fn token_kinds(bytes : Bytes) -> Array[TokenKind] {
  tokens(bytes).map(token => token.kind()).to_array()
}

///|
test "fixed symbols and compound operators" {
  assert_eq(
    token_kinds(b"(){}[]^+-*/**%:::= == => != <= >= << >> && || ,;...<>!&|->"),
    [
      Symbol(LeftParen),
      Symbol(RightParen),
      Symbol(LeftBrace),
      Symbol(RightBrace),
      Symbol(LeftBracket),
      Symbol(RightBracket),
      Symbol(Caret),
      Symbol(Plus),
      Symbol(Minus),
      Symbol(Star),
      Symbol(Slash),
      Symbol(Exponent),
      Symbol(Percent),
      Symbol(DoubleColon),
      Symbol(Colon),
      Symbol(Equal),
      Symbol(EqualEqual),
      Symbol(FatArrow),
      Symbol(BangEqual),
      Symbol(LessEqual),
      Symbol(GreaterEqual),
      Symbol(ShiftLeft),
      Symbol(ShiftRight),
      Symbol(LogicalAnd),
      Symbol(LogicalOr),
      Symbol(Comma),
      Symbol(Semicolon),
      Symbol(Ellipsis),
      Symbol(Less),
      Symbol(Greater),
      Symbol(Bang),
      Symbol(Ampersand),
      Symbol(Pipe),
      Symbol(Arrow),
    ],
  )
}

///|
test "compound symbols use longest valid match" {
  assert_eq(token_kinds(b"=== ==> =>> !== <<< >>> &&& |||"), [
    Symbol(EqualEqual),
    Symbol(Equal),
    Symbol(EqualEqual),
    Symbol(Greater),
    Symbol(FatArrow),
    Symbol(Greater),
    Symbol(BangEqual),
    Symbol(Equal),
    Symbol(ShiftLeft),
    Symbol(Less),
    Symbol(ShiftRight),
    Symbol(Greater),
    Symbol(LogicalAnd),
    Symbol(Ampersand),
    Symbol(LogicalOr),
    Symbol(Pipe),
  ])
}

///|
test "keywords are separated from identifiers" {
  assert_eq(
    token_kinds(
      b"fn test pub builtin foreign impl trait for enum struct type let mut if else match is while loop return break continue true false as in where open import export package global ordinary",
    ),
    [
      Keyword(Fn),
      Keyword(Test),
      Keyword(Pub),
      Keyword(Builtin),
      Keyword(Foreign),
      Keyword(Impl),
      Keyword(Trait),
      Keyword(For),
      Keyword(Enum),
      Keyword(Struct),
      Keyword(Type),
      Keyword(Let),
      Keyword(Mut),
      Keyword(If),
      Keyword(Else),
      Keyword(Match),
      Keyword(Is),
      Keyword(While),
      Keyword(Loop),
      Keyword(Return),
      Keyword(Break),
      Keyword(Continue),
      Keyword(True),
      Keyword(False),
      Keyword(As),
      Keyword(In),
      Keyword(Where),
      Keyword(Open),
      Keyword(Import),
      Keyword(Export),
      Keyword(Package),
      Identifier("global"),
      Identifier("ordinary"),
    ],
  )
}

///|
test "unicode and at identifiers" {
  assert_eq(token_kinds(b"alpha snake_case \xCE\xBB @wasm.i64_trunc_i32"), [
    Identifier("alpha"),
    Identifier("snake_case"),
    Identifier("λ"),
    AtIdentifier("wasm"),
    Symbol(Dot),
    Identifier("i64_trunc_i32"),
  ])
}

///|
test "invalid at identifier leaves following input available" {
  assert_eq(token_kinds(b"@ 42"), [Error(InvalidAtIdentifier), I32(42UL)])
}

///|
test "integer suffixes select fixed widths" {
  assert_eq(
    token_kinds(b"1i8 2i16 3i32 4i64 5u8 6u16 7u32 8u64 9 10U 11L 12UL 1_000"),
    [
      I8(1UL),
      I16(2UL),
      I32(3UL),
      I64(4UL),
      U8(5UL),
      U16(6UL),
      U32(7UL),
      U64(8UL),
      I32(9UL),
      U32(10UL),
      I64(11UL),
      U64(12UL),
      I32(1000UL),
    ],
  )
}

///|
test "dotted literals default to f64 and suffixes select float width" {
  let kinds = token_kinds(
    b"1.25 .5 6.022e23 1_000.5 1.0e-3 2.5F .25F 3.5f32 4.5f64",
  )
  assert_eq(kinds.length(), 9)
  match kinds[0] {
    F64(value) => assert_eq(value, 1.25)
    _ => fail("expected f64 token at index 0")
  }
  match kinds[1] {
    F64(value) => assert_eq(value, 0.5)
    _ => fail("expected f64 token at index 1")
  }
  match kinds[2] {
    F64(value) => assert_eq(value, 6.022e23)
    _ => fail("expected f64 token at index 2")
  }
  match kinds[3] {
    F64(value) => assert_eq(value, 1000.5)
    _ => fail("expected f64 token at index 3")
  }
  match kinds[4] {
    F64(value) => assert_eq(value, 0.001)
    _ => fail("expected f64 token at index 4")
  }
  match kinds[5] {
    F32(value) => assert_eq(value, Float::from_double(2.5))
    _ => fail("expected f32 token at index 5")
  }
  match kinds[6] {
    F32(value) => assert_eq(value, Float::from_double(0.25))
    _ => fail("expected f32 token at index 6")
  }
  match kinds[7] {
    F32(value) => assert_eq(value, Float::from_double(3.5))
    _ => fail("expected f32 token at index 7")
  }
  match kinds[8] {
    F64(value) => assert_eq(value, 4.5)
    _ => fail("expected f64 token at index 8")
  }
}

///|
test "float syntax requires a decimal point" {
  assert_eq(token_kinds(b"1e+ 2e3 4F next"), [
    Error(InvalidFloat("1e+")),
    Error(InvalidFloat("2e3")),
    Error(InvalidFloat("4F")),
    Identifier("next"),
  ])
}

///|
test "numeric separators and integer ranges are validated" {
  assert_eq(
    token_kinds(
      b"1__2 3_ 4.0__5 18446744073709551615UL 18446744073709551616UL 129i8 256u8 32769i16 65536u16 2147483649i32 4294967296u32 9223372036854775809i64",
    ),
    [
      Error(InvalidInteger("1__2")),
      Error(InvalidInteger("3_")),
      Error(InvalidFloat("4.0__5")),
      U64(0xFFFFFFFFFFFFFFFFUL),
      Error(InvalidInteger("18446744073709551616UL")),
      Error(InvalidInteger("129i8")),
      Error(InvalidInteger("256u8")),
      Error(InvalidInteger("32769i16")),
      Error(InvalidInteger("65536u16")),
      Error(InvalidInteger("2147483649i32")),
      Error(InvalidInteger("4294967296u32")),
      Error(InvalidInteger("9223372036854775809i64")),
    ],
  )
}

///|
test "double quoted strings decode escapes" {
  assert_eq(token_kinds(b"\"line\\nquote: \\\" byte: \\xFF\""), [
    StringLiteral(b"line\nquote: \" byte: \xFF"),
  ])
}

///|
test "b-prefixed strings produce exact byte literals" {
  assert_eq(token_kinds(b"b\"utf8: λ \\x00\\xFF\""), [
    BytesLiteral(b"utf8: λ \x00\xFF"),
  ])
}

///|
test "string literals preserve malformed source bytes" {
  assert_eq(token_kinds(b"\"\xFF\""), [StringLiteral(b"\xFF")])
}

///|
test "string literals preserve wtf8 surrogates" {
  assert_eq(token_kinds(b"\"\xED\xA0\x80\""), [StringLiteral(b"\xED\xA0\x80")])
}

///|
test "moonbit style multiline strings join marked lines" {
  assert_eq(token_kinds(b"#|alpha\n  #|beta\n  let"), [
    MultilineString(b"alpha\nbeta"),
    Newline,
    Keyword(Let),
  ])
}

///|
test "line comments preserve their terminating newline" {
  assert_eq(token_kinds(b"fn // ignored\nname"), [
    Keyword(Fn),
    Newline,
    Identifier("name"),
  ])
}

///|
test "lf crlf and cr each emit one newline token" {
  let result = tokens(b"a\nb\r\nc\rd").to_array()
  assert_eq(result.map(token => token.kind()), [
    Identifier("a"),
    Newline,
    Identifier("b"),
    Newline,
    Identifier("c"),
    Newline,
    Identifier("d"),
  ])
  assert_eq(result.map(token => token.offset()), [
    0UL, 1UL, 2UL, 3UL, 5UL, 6UL, 7UL,
  ])
}

///|
test "malformed bytes outside strings become errors" {
  assert_eq(token_kinds(b"\xFF"), [
    Error(UnexpectedUnit(INVALID_BYTE_BASE + 0xFFU)),
  ])
}

///|
test "token offsets and indexes are stable" {
  let output = tokens(b"fn value").to_array()
  assert_eq(output.length(), 2)
  assert_eq(output[0].offset(), 0UL)
  assert_eq(output[0].index(), 0)
  assert_eq(output[1].offset(), 3UL)
  assert_eq(output[1].index(), 1)
}

///|
#cfg(target="native")
test "crlf tokenization crosses a reusable buffer refill" {
  let input = b"abc\r\ndef"
  let fd = tokenizer_test_open_bytes(input, input.length())
  assert_true(fd >= 0)
  let tokenizer = Tokenizer::from_fd(fd, buffer_size=4)
  assert_eq(tokenizer.iter().map(token => token.kind()).to_array(), [
    Identifier("abc"),
    Newline,
    Identifier("def"),
  ])
  assert_eq(tokenizer_test_close_fd(fd), 0)
}

///|
#cfg(target="native")
test "fat arrow tokenization crosses a reusable buffer refill" {
  let input = b"ab => value"
  let fd = tokenizer_test_open_bytes(input, input.length())
  assert_true(fd >= 0)
  let tokenizer = Tokenizer::from_fd(fd, buffer_size=4)
  assert_eq(tokenizer.iter().map(token => token.kind()).to_array(), [
    Identifier("ab"),
    Symbol(FatArrow),
    Identifier("value"),
  ])
  assert_eq(tokenizer_test_close_fd(fd), 0)
}

///|
#cfg(target="native")
test "tokenization continues across reusable buffer refills" {
  let input = b"pub long_identifier_name = 1.5"
  let fd = tokenizer_test_open_bytes(input, input.length())
  assert_true(fd >= 0)
  let tokenizer = Tokenizer::from_fd(fd, buffer_size=4)
  assert_eq(tokenizer.iter().map(token => token.kind()).to_array(), [
    Keyword(Pub),
    Identifier("long_identifier_name"),
    Symbol(Equal),
    F64(1.5),
  ])
  assert_eq(tokenizer_test_close_fd(fd), 0)
}
