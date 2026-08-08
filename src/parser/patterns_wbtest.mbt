///|
test "patterns parse wildcard binding and literal bases separately" {
  assert_eq(Parser::from_bytes(b"_").parse_pattern(), Ok(WildcardPattern(0UL)))
  assert_eq(
    Parser::from_bytes(b"value").parse_pattern(),
    Ok(BindingPattern("value", 0UL)),
  )
  assert_eq(
    Parser::from_bytes(b"_ignored").parse_pattern(),
    Ok(WildcardPattern(0UL)),
  )
  assert_eq(
    Parser::from_bytes(b"__temporary").parse_pattern(),
    Ok(WildcardPattern(0UL)),
  )
  assert_eq(
    Parser::from_bytes(b"42").parse_pattern(),
    Ok(LiteralPattern(I32Expr(42UL, 0UL), 0UL)),
  )
  assert_eq(
    Parser::from_bytes(b"true").parse_pattern(),
    Ok(LiteralPattern(BoolExpr(true, 0UL), 0UL)),
  )
  assert_eq(
    Parser::from_bytes(b"-42").parse_pattern(),
    Ok(LiteralPattern(PrefixExpr(Negative, I32Expr(42UL, 1UL), 0UL), 0UL)),
  )
}

///|
test "patterns accept every numeric literal width" {
  let cases = [
    (b"1i8", I8Expr(1UL, 0UL)),
    (b"2i16", I16Expr(2UL, 0UL)),
    (b"3i32", I32Expr(3UL, 0UL)),
    (b"4i64", I64Expr(4UL, 0UL)),
    (b"5u8", U8Expr(5UL, 0UL)),
    (b"6u16", U16Expr(6UL, 0UL)),
    (b"7u32", U32Expr(7UL, 0UL)),
    (b"8u64", U64Expr(8UL, 0UL)),
    (b"9.5f32", F32Expr(9.5, 0UL)),
    (b"10.5f64", F64Expr(10.5, 0UL)),
  ]
  for case in cases {
    let (source, expression) = case
    assert_eq(
      Parser::from_bytes(source).parse_pattern(),
      Ok(LiteralPattern(expression, 0UL)),
    )
  }
  assert_eq(
    Parser::from_bytes(b"-128i8").parse_pattern(),
    Ok(LiteralPattern(PrefixExpr(Negative, I8Expr(128UL, 1UL), 0UL), 0UL)),
  )
  assert_eq(
    Parser::from_bytes(b"+65535u16").parse_pattern(),
    Ok(LiteralPattern(PrefixExpr(Positive, U16Expr(65535UL, 1UL), 0UL), 0UL)),
  )
}

///|
test "qualified tuple patterns preserve nested bindings" {
  match
    Parser::from_bytes(b"Option::Some(Result::Ok(value),)").parse_pattern() {
    Ok(
      TuplePattern(
        QualifiedPattern(BindingPattern("Option", _), "Some", _),
        [
          TuplePattern(
            QualifiedPattern(BindingPattern("Result", _), "Ok", _),
            [BindingPattern("value", _)],
            _
          ),
        ],
        _
      )
    ) => ()
    _ => fail("expected nested qualified tuple pattern")
  }
}

///|
test "tuple patterns allow newlines and one trailing comma" {
  match
    Parser::from_bytes(b"Pair(\n  first,\n  Option::Some(second),\n)").parse_pattern() {
    Ok(TuplePattern(BindingPattern("Pair", _), arguments, _)) => {
      assert_eq(arguments.length(), 2)
      assert_eq(arguments[0], BindingPattern("first", 8UL))
    }
    _ => fail("expected multiline tuple pattern")
  }
}

///|
test "struct patterns support shorthand renamed and nested fields" {
  match
    Parser::from_bytes(
      b"Message::Data {\n  value\n  metadata: details\n  nested: Option::Some(item)\n}",
    ).parse_pattern() {
    Ok(StructPattern(QualifiedPattern(_, "Data", _), fields, None, _)) => {
      assert_eq(fields.length(), 3)
      assert_eq(fields[0].name, "value")
      assert_eq(fields[0].pattern, BindingPattern("value", 18UL))
      assert_eq(fields[1].pattern, BindingPattern("details", 36UL))
      match fields[2].pattern {
        TuplePattern(QualifiedPattern(_, "Some", _), [_], _) => ()
        _ => fail("expected nested tuple field pattern")
      }
    }
    _ => fail("expected struct-like variant pattern")
  }
}

///|
test "underscore-prefixed struct shorthand fields discard their values" {
  match Parser::from_bytes(b"Data {\n  _metadata\n}").parse_pattern() {
    Ok(StructPattern(_, [field], None, _)) => {
      assert_eq(field.name, "_metadata")
      assert_eq(field.pattern, WildcardPattern(9UL))
    }
    _ => fail("expected discarded underscore-prefixed shorthand field")
  }
}

///|
test "compact empty struct patterns remain distinct" {
  assert_eq(
    Parser::from_bytes(b"State::Unknown {}").parse_pattern(),
    Ok(
      StructPattern(
        QualifiedPattern(BindingPattern("State", 0UL), "Unknown", 5UL),
        [],
        None,
        15UL,
      ),
    ),
  )
}

///|
test "tuple and struct patterns accept one ellipsis rest pattern" {
  match Parser::from_bytes(b"Packet(head, ..., tail)").parse_pattern() {
    Ok(
      TuplePattern(
        BindingPattern("Packet", _),
        [BindingPattern("head", _), RestPattern(_), BindingPattern("tail", _)],
        _
      )
    ) => ()
    _ => fail("expected tuple rest pattern")
  }
  match
    Parser::from_bytes(b"Message::Data {\n  value\n  ...\n}").parse_pattern() {
    Ok(StructPattern(QualifiedPattern(_, "Data", _), [field], Some(_), _)) =>
      assert_eq(field.name, "value")
    _ => fail("expected struct rest pattern")
  }
}

///|
test "rest patterns are restricted and unique within one payload" {
  assert_eq(
    Parser::from_bytes(b"...").parse_pattern(),
    Err(RestPatternNotAllowed(0UL)),
  )
  match Parser::from_bytes(b"Packet(..., ...)").parse_pattern() {
    Err(DuplicateRestPattern(_)) => ()
    _ => fail("expected duplicate tuple rest diagnostic")
  }
  match Parser::from_bytes(b"Data {\n  ...\n  ...\n}").parse_pattern() {
    Err(DuplicateRestPattern(_)) => ()
    _ => fail("expected duplicate struct rest diagnostic")
  }
  match Parser::from_bytes(b"Data {\n  field: ...\n}").parse_pattern() {
    Err(RestPatternNotAllowed(_)) => ()
    _ => fail("expected rest restriction in named field")
  }
}

///|
test "mutable pattern bindings are rejected" {
  match Parser::from_bytes(b"Some(mut value)").parse_pattern() {
    Err(ExpectedPattern(Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Mut) => ()
        _ => fail("expected mut keyword")
      }
    _ => fail("expected mutable pattern binding rejection")
  }
}

///|
test "pattern parsing leaves expression operators untouched" {
  let parser = Parser::from_bytes(b"value + other")
  assert_eq(parser.parse_pattern(), Ok(BindingPattern("value", 0UL)))
  match parser.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Plus) => ()
        _ => fail("expected retained expression operator")
      }
    None => fail("expected plus token")
  }
}

///|
test "patterns diagnose missing properties and tuple payloads" {
  assert_eq(
    Parser::from_bytes(b"Option::").parse_pattern(),
    Err(ExpectedPatternProperty(None)),
  )
  assert_eq(
    Parser::from_bytes(b"Empty()").parse_pattern(),
    Err(EmptyTuplePattern(5UL)),
  )
  match Parser::from_bytes(b"Pair(first second)").parse_pattern() {
    Err(ExpectedPatternDelimiter(Some(token), 4UL)) =>
      match token.kind() {
        @tokenizer.Identifier("second") => ()
        _ => fail("expected adjacent tuple pattern")
      }
    _ => fail("expected tuple delimiter diagnostic")
  }
}

///|
test "struct patterns require structural newlines" {
  match Parser::from_bytes(b"Data { value\n}").parse_pattern() {
    Err(ExpectedPatternBodyNewline(Some(token), 5UL)) =>
      match token.kind() {
        @tokenizer.Identifier("value") => ()
        _ => fail("expected same-line pattern field")
      }
    _ => fail("expected pattern body newline")
  }
  match Parser::from_bytes(b"Data {\n  value}").parse_pattern() {
    Err(ExpectedPatternFieldNewline(Some(token), 5UL)) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightBrace) => ()
        _ => fail("expected struct pattern closing brace")
      }
    _ => fail("expected pattern field newline")
  }
}

///|
test "unclosed tuple and struct patterns retain opening offsets" {
  assert_eq(
    Parser::from_bytes(b"Some(value").parse_pattern(),
    Err(UnclosedTuplePattern(4UL)),
  )
  assert_eq(
    Parser::from_bytes(b"Data {\n  value\n").parse_pattern(),
    Err(UnclosedStructPattern(5UL)),
  )
}

///|
test "long qualified patterns parse iteratively" {
  let output = Buffer(size_hint=4096)
  output.write_string_utf8("Root")
  for index in 0..<512 {
    output.write_string_utf8("::Part_")
    output.write_string_utf8(index.to_string())
  }
  match Parser::from_bytes(output.to_bytes()).parse_pattern() {
    Ok(pattern) => {
      let mut current = pattern
      let mut count = 0
      while true {
        match current {
          QualifiedPattern(target, _, _) => {
            count += 1
            current = target
          }
          BindingPattern("Root", _) => break
          _ => fail("expected qualified pattern chain")
        }
      }
      assert_eq(count, 512)
    }
    _ => fail("expected long qualified pattern")
  }
}
