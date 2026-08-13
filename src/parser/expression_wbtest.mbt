///|
fn parse_test_expression(source : Bytes) -> Result[Expr, ExpressionError] {
  Parser::from_bytes(source).parse_expression()
}

///|
fn repeated_test_expression(term_count : Int, operator : String) -> Bytes {
  let output = Buffer(size_hint=term_count * (operator.length() + 1))
  for index in 0..<term_count {
    if index > 0 {
      output.write_string_utf8(operator)
    }
    output.write_byte(b'1')
  }
  output.to_bytes()
}

///|
fn nested_group_test_expression(depth : Int) -> Bytes {
  let output = Buffer(size_hint=depth * 2 + 1)
  for _ in 0..<depth {
    output.write_byte(b'(')
  }
  output.write_byte(b'1')
  for _ in 0..<depth {
    output.write_byte(b')')
  }
  output.to_bytes()
}

///|
test "multiplication binds more tightly than addition" {
  assert_eq(
    parse_test_expression(b"1 + 2 * 3"),
    Ok(
      BinaryExpr(
        Add,
        I32Expr(1UL, 0UL),
        BinaryExpr(Multiply, I32Expr(2UL, 4UL), I32Expr(3UL, 8UL), 6UL),
        2UL,
      ),
    ),
  )
}

///|
test "left associative operators reduce before equal precedence" {
  assert_eq(
    parse_test_expression(b"10 - 3 - 2"),
    Ok(
      BinaryExpr(
        Subtract,
        BinaryExpr(Subtract, I32Expr(10UL, 0UL), I32Expr(3UL, 5UL), 3UL),
        I32Expr(2UL, 9UL),
        7UL,
      ),
    ),
  )
}

///|
test "exponentiation is right associative" {
  assert_eq(
    parse_test_expression(b"2 ** 3 ** 2"),
    Ok(
      BinaryExpr(
        Exponentiate,
        I32Expr(2UL, 0UL),
        BinaryExpr(Exponentiate, I32Expr(3UL, 5UL), I32Expr(2UL, 10UL), 7UL),
        2UL,
      ),
    ),
  )
}

///|
test "is parses a constructor pattern as a boolean expression" {
  assert_eq(
    parse_test_expression(b"value is Option::Some(bound)"),
    Ok(
      IsExpr(
        NameExpr("value", 0UL),
        TuplePattern(
          QualifiedPattern(BindingPattern("Option", 9UL), "Some", 15UL),
          [BindingPattern("bound", 22UL)],
          21UL,
        ),
        6UL,
      ),
    ),
  )
}

///|
test "is binds more tightly than logical conjunction" {
  match parse_test_expression(b"ready && value is Option::Some(bound)") {
    Ok(
      BinaryExpr(
        LogicalAnd,
        NameExpr("ready", _),
        IsExpr(NameExpr("value", _), _, _),
        _
      )
    ) => ()
    _ => fail("expected is expression on the right of logical conjunction")
  }
}

///|
test "is reports missing and invalid patterns" {
  assert_eq(
    parse_test_expression(b"value is"),
    Err(MatchPatternError(ExpectedPattern(None))),
  )
  assert_eq(
    parse_test_expression(b"value is ..."),
    Err(MatchPatternError(RestPatternNotAllowed(9UL))),
  )
}

///|
test "assignment is not an expression operator" {
  let parser = Parser::from_bytes(b"a = b")
  assert_eq(parser.parse_expression(), Ok(NameExpr("a", 0UL)))
  match parser.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Equal) => ()
        _ => fail("expected assignment token to remain in lookahead")
      }
    None => fail("expected assignment token to remain in lookahead")
  }
}

///|
test "comparison operators cannot be chained" {
  assert_eq(parse_test_expression(b"a < b <= c"), Err(ChainedComparison(6UL)))
  assert_eq(parse_test_expression(b"a == b != c"), Err(ChainedComparison(7UL)))
  assert_eq(parse_test_expression(b"a < b == c"), Err(ChainedComparison(6UL)))
  assert_eq(parse_test_expression(b"a == b < c"), Err(ChainedComparison(7UL)))
}

///|
test "explicit groups separate comparisons" {
  assert_eq(
    parse_test_expression(b"(a < b) == c"),
    Ok(
      BinaryExpr(
        Equal,
        BinaryExpr(Less, NameExpr("a", 1UL), NameExpr("b", 5UL), 3UL),
        NameExpr("c", 11UL),
        8UL,
      ),
    ),
  )
}

///|
test "groups override normal precedence" {
  assert_eq(
    parse_test_expression(b"(1 + 2) * 3"),
    Ok(
      BinaryExpr(
        Multiply,
        BinaryExpr(Add, I32Expr(1UL, 1UL), I32Expr(2UL, 5UL), 3UL),
        I32Expr(3UL, 10UL),
        8UL,
      ),
    ),
  )
}

///|
test "prefix operators bind above exponentiation" {
  assert_eq(
    parse_test_expression(b"!-+x ** y"),
    Ok(
      BinaryExpr(
        Exponentiate,
        PrefixExpr(
          LogicalNot,
          PrefixExpr(
            Negative,
            PrefixExpr(Positive, NameExpr("x", 3UL), 2UL),
            1UL,
          ),
          0UL,
        ),
        NameExpr("y", 8UL),
        5UL,
      ),
    ),
  )
}

///|
test "prefix operators wait for postfix calls" {
  assert_eq(
    parse_test_expression(b"-f(1 + 2, 3)"),
    Ok(
      PrefixExpr(
        Negative,
        CallExpr(
          NameExpr("f", 1UL),
          [
            BinaryExpr(Add, I32Expr(1UL, 3UL), I32Expr(2UL, 7UL), 5UL),
            I32Expr(3UL, 10UL),
          ],
          2UL,
        ),
        0UL,
      ),
    ),
  )
}

///|
test "lambda expressions reuse typed parameters and block bodies" {
  match parse_test_expression(b"fn(value: I32) -> I32 {\n  value + 1\n}") {
    Ok(LambdaExpr([parameter], NamedType("I32", _), body, 0UL)) => {
      assert_eq(parameter.name, "value")
      assert_eq(parameter.type_, NamedType("I32", 10UL))
      match body.tail_expression() {
        Some(BinaryExpr(Add, NameExpr("value", _), I32Expr(1UL, _), _)) => ()
        _ => fail("expected lambda block tail")
      }
    }
    _ => fail("expected typed lambda expression")
  }
}

///|
test "lambda expressions enter postfix mode without parser rewinding" {
  match
    parse_test_expression(b"fn(value: I32) -> I32 {\n  value\n}(41).result") {
    Ok(
      FieldExpr(
        CallExpr(
          LambdaExpr([_], NamedType("I32", _), _, 0UL),
          [I32Expr(41UL, _)],
          _
        ),
        "result",
        _
      )
    ) => ()
    _ => fail("expected postfix continuation after lambda")
  }
}

///|
test "lambda headers fail deterministically at the forward cursor" {
  match parse_test_expression(b"fn(: I32) -> I32 {\n  0\n}") {
    Err(ExpectedLambdaSyntax(ParameterName, Some(token), 0UL)) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Colon) => ()
        _ => fail("expected colon at the lambda parameter cursor")
      }
    _ => fail("expected deterministic lambda parameter error")
  }
}

///|
test "calls chain without expression backtracking" {
  assert_eq(
    parse_test_expression(b"f()(1)"),
    Ok(
      CallExpr(CallExpr(NameExpr("f", 0UL), [], 1UL), [I32Expr(1UL, 4UL)], 3UL),
    ),
  )
}

///|
test "postfix access binds above prefix and exponentiation" {
  assert_eq(
    parse_test_expression(b"-a.b[0] ** c"),
    Ok(
      BinaryExpr(
        Exponentiate,
        PrefixExpr(
          Negative,
          IndexExpr(
            FieldExpr(NameExpr("a", 1UL), "b", 2UL),
            I32Expr(0UL, 5UL),
            4UL,
          ),
          0UL,
        ),
        NameExpr("c", 11UL),
        8UL,
      ),
    ),
  )
}

///|
test "field, index, and call postfix forms chain" {
  assert_eq(
    parse_test_expression(b"items[index + 1].value(2,)"),
    Ok(
      CallExpr(
        FieldExpr(
          IndexExpr(
            NameExpr("items", 0UL),
            BinaryExpr(Add, NameExpr("index", 6UL), I32Expr(1UL, 14UL), 12UL),
            5UL,
          ),
          "value",
          16UL,
        ),
        [I32Expr(2UL, 23UL)],
        22UL,
      ),
    ),
  )
}

///|
test "qualified access consumes a right property and remains postfix-seeking" {
  assert_eq(
    parse_test_expression(b"Type::method(value).field[0]"),
    Ok(
      IndexExpr(
        FieldExpr(
          CallExpr(
            QualifiedExpr(NameExpr("Type", 0UL), "method", 4UL),
            [NameExpr("value", 13UL)],
            12UL,
          ),
          "field",
          19UL,
        ),
        I32Expr(0UL, 26UL),
        25UL,
      ),
    ),
  )
}

///|
test "qualified access chains left-to-right at postfix precedence" {
  assert_eq(
    parse_test_expression(b"left + Type::Namespace::value * right"),
    Ok(
      BinaryExpr(
        Add,
        NameExpr("left", 0UL),
        BinaryExpr(
          Multiply,
          QualifiedExpr(
            QualifiedExpr(NameExpr("Type", 7UL), "Namespace", 11UL),
            "value",
            22UL,
          ),
          NameExpr("right", 32UL),
          30UL,
        ),
        5UL,
      ),
    ),
  )
}

///|
test "qualified access permits a soft newline after double colon" {
  assert_eq(
    parse_test_expression(b"Type::\n  method(1)"),
    Ok(
      CallExpr(
        QualifiedExpr(NameExpr("Type", 0UL), "method", 4UL),
        [I32Expr(1UL, 16UL)],
        15UL,
      ),
    ),
  )
}

///|
test "qualified access requires an identifier property" {
  assert_eq(parse_test_expression(b"Type::"), Err(ExpectedQualifiedName(None)))
  match parse_test_expression(b"Type::(value)") {
    Err(ExpectedQualifiedName(Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftParen) => ()
        _ => fail("expected left parenthesis after double colon")
      }
    _ => fail("expected qualified property diagnostic")
  }
}

///|
test "legacy bare-brace struct construction is rejected" {
  let parser = Parser::from_bytes(b"Point {}")
  assert_eq(parser.parse_expression(), Ok(NameExpr("Point", 0UL)))
  match parser.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftBrace) => ()
        _ => fail("expected legacy construction brace to remain")
      }
    None => fail("expected legacy construction brace")
  }
}

///|
test "named and qualified values accept double-colon construction bodies" {
  assert_eq(
    parse_test_expression(b"Point::{\n  x: 10\n  y: 20\n}"),
    Ok(
      ConstructExpr(
        NameExpr("Point", 0UL),
        [
          { name: "x", value: I32Expr(10UL, 14UL), offset: 11UL },
          { name: "y", value: I32Expr(20UL, 22UL), offset: 19UL },
        ],
        7UL,
      ),
    ),
  )
  assert_eq(
    parse_test_expression(b"Message::Data::{}"),
    Ok(
      ConstructExpr(
        QualifiedExpr(NameExpr("Message", 0UL), "Data", 7UL),
        [],
        15UL,
      ),
    ),
  )
}

///|
test "construction permits a soft newline after double colon" {
  assert_eq(
    parse_test_expression(b"Point::\n{\n  x: 10\n}"),
    Ok(
      ConstructExpr(
        NameExpr("Point", 0UL),
        [{ name: "x", value: I32Expr(10UL, 15UL), offset: 12UL }],
        8UL,
      ),
    ),
  )
}

///|
test "construction remains in binary-seeking mode" {
  assert_eq(
    parse_test_expression(b"Message::Data::{\n  value: item\n}.value(1)"),
    Ok(
      CallExpr(
        FieldExpr(
          ConstructExpr(
            QualifiedExpr(NameExpr("Message", 0UL), "Data", 7UL),
            [{ name: "value", value: NameExpr("item", 26UL), offset: 19UL }],
            15UL,
          ),
          "value",
          32UL,
        ),
        [I32Expr(1UL, 39UL)],
        38UL,
      ),
    ),
  )
}

///|
test "a top-level newline terminates before a construction body" {
  let parser = Parser::from_bytes(b"Point\n::{}")
  assert_eq(parser.parse_expression(), Ok(NameExpr("Point", 0UL)))
  match parser.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Newline => ()
        _ => fail("expected construction-separating newline")
      }
    None => fail("expected retained newline")
  }
}

///|
test "construction binds above infix operators" {
  assert_eq(
    parse_test_expression(b"left + Point::{} * right"),
    Ok(
      BinaryExpr(
        Add,
        NameExpr("left", 0UL),
        BinaryExpr(
          Multiply,
          ConstructExpr(NameExpr("Point", 7UL), [], 14UL),
          NameExpr("right", 19UL),
          17UL,
        ),
        5UL,
      ),
    ),
  )
}

///|
test "only one trailing call comma is accepted" {
  match parse_test_expression(b"f(1,,)") {
    Err(ExpectedValue(Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Comma) => ()
        _ => fail("expected the second comma to fail")
      }
    _ => fail("expected duplicate trailing comma to fail")
  }
}

///|
test "field access requires an identifier" {
  assert_eq(parse_test_expression(b"value."), Err(ExpectedFieldName(None)))
}

///|
test "index access requires a closing bracket" {
  assert_eq(parse_test_expression(b"value[1 + 2"), Err(UnclosedIndex(5UL)))
}

///|
test "empty index access reports the closing bracket as the missing value" {
  match parse_test_expression(b"value[]") {
    Err(ExpectedValue(Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightBracket) => ()
        _ => fail("expected right bracket after empty index")
      }
    _ => fail("expected empty index expression to fail")
  }
}

///|
test "unterminated and malformed calls fail without alternatives" {
  assert_eq(parse_test_expression(b"f(1"), Err(UnclosedCall(1UL)))
  match parse_test_expression(b"f(1 2)") {
    Err(ExpectedCallDelimiter(Some(token))) =>
      match token.kind() {
        @tokenizer.I32(2UL) => ()
        _ => fail("expected second value as invalid call delimiter")
      }
    _ => fail("expected malformed call to fail")
  }
}

///|
test "all literal and name forms enter value mode" {
  assert_eq(parse_test_expression(b"1i8"), Ok(I8Expr(1UL, 0UL)))
  assert_eq(parse_test_expression(b"1i16"), Ok(I16Expr(1UL, 0UL)))
  assert_eq(parse_test_expression(b"1i32"), Ok(I32Expr(1UL, 0UL)))
  assert_eq(parse_test_expression(b"1i64"), Ok(I64Expr(1UL, 0UL)))
  assert_eq(parse_test_expression(b"1u8"), Ok(U8Expr(1UL, 0UL)))
  assert_eq(parse_test_expression(b"1u16"), Ok(U16Expr(1UL, 0UL)))
  assert_eq(parse_test_expression(b"1u32"), Ok(U32Expr(1UL, 0UL)))
  assert_eq(parse_test_expression(b"1u64"), Ok(U64Expr(1UL, 0UL)))
  assert_eq(parse_test_expression(b"1"), Ok(I32Expr(1UL, 0UL)))
  assert_eq(parse_test_expression(b"1U"), Ok(U32Expr(1UL, 0UL)))
  assert_eq(parse_test_expression(b"1L"), Ok(I64Expr(1UL, 0UL)))
  assert_eq(parse_test_expression(b"1UL"), Ok(U64Expr(1UL, 0UL)))
  assert_eq(
    parse_test_expression(b"1.0F"),
    Ok(F32Expr(Float::from_double(1.0), 0UL)),
  )
  assert_eq(
    parse_test_expression(b"1.0f32"),
    Ok(F32Expr(Float::from_double(1.0), 0UL)),
  )
  assert_eq(parse_test_expression(b"1.0f64"), Ok(F64Expr(1.0, 0UL)))
  assert_eq(parse_test_expression(b"1.0"), Ok(F64Expr(1.0, 0UL)))
  assert_eq(parse_test_expression(b"true"), Ok(BoolExpr(true, 0UL)))
  assert_eq(parse_test_expression(b"\"x\""), Ok(StringExpr(b"x", 0UL)))
  assert_eq(parse_test_expression(b"b\"x\\x00\""), Ok(BytesExpr(b"x\x00", 0UL)))
  assert_eq(parse_test_expression(b"name"), Ok(NameExpr("name", 0UL)))
  assert_eq(
    parse_test_expression(b"@intrinsic"),
    Ok(ImportAliasExpr("intrinsic", 0UL)),
  )
}

///|
test "large flat expressions do not recurse by operator count" {
  match parse_test_expression(repeated_test_expression(1024, " + ")) {
    Ok(_) => ()
    Err(_) => fail("expected large left-associative expression to parse")
  }
  match parse_test_expression(repeated_test_expression(512, " ** ")) {
    Ok(_) => ()
    Err(_) => fail("expected large right-associative expression to parse")
  }
}

///|
test "deep grouping uses the iterative operator stack" {
  match parse_test_expression(nested_group_test_expression(1024)) {
    Ok(I32Expr(1UL, 1024UL)) => ()
    _ => fail("expected deeply grouped literal to parse")
  }
}

///|
test "expression terminator remains in one-token lookahead" {
  let parser = Parser::from_bytes(b"1 + 2, 3")
  assert_eq(
    parser.parse_expression(),
    Ok(BinaryExpr(Add, I32Expr(1UL, 0UL), I32Expr(2UL, 4UL), 2UL)),
  )
  match parser.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Comma) => ()
        _ => fail("expected comma lookahead")
      }
    None => fail("expected comma lookahead")
  }
  ignore(parser.take_token())
  assert_eq(parser.parse_expression(), Ok(I32Expr(3UL, 7UL)))
}

///|
test "an unmatched outer right parenthesis is not consumed" {
  let parser = Parser::from_bytes(b"1)")
  assert_eq(parser.parse_expression(), Ok(I32Expr(1UL, 0UL)))
  match parser.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightParen) => ()
        _ => fail("expected right parenthesis lookahead")
      }
    None => fail("expected right parenthesis lookahead")
  }
}

///|
test "trailing operators report a missing value" {
  assert_eq(parse_test_expression(b"1 +"), Err(ExpectedValue(None)))
}

///|
test "unclosed groups retain their opening offset" {
  assert_eq(parse_test_expression(b"(1 + 2"), Err(UnclosedGroup(0UL)))
}

///|
test "lexical errors flow into expression errors" {
  match parse_test_expression(b"1e3") {
    Err(LexicalError(error, 0UL)) =>
      match error {
        @tokenizer.InvalidFloat("1e3") => ()
        _ => fail("expected invalid float lexical error")
      }
    _ => fail("expected lexical expression error")
  }
}
