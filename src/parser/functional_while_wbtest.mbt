///|
fn large_functional_while(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 38 + 48)
  output.write_string_utf8("while state {\n")
  for index in 0..<arm_count {
    output.write_string_utf8("  State_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" => continue ")
    output.write_string_utf8((index + 1).to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("  _ => break 0\n}")
  output.to_bytes()
}

///|
test "functional while retains initial state guarded arms and transfers" {
  match
    parse_test_expression(
      b"while init {\n  State::Next(value) if value > 0 => {\n    continue next\n  }\n  _ => break 0\n}\n",
    ) {
    Ok(WhileExpr(NameExpr("init", _), arms, 0UL)) => {
      assert_eq(arms.length(), 2)
      match arms[0].pattern {
        TuplePattern(
          QualifiedPattern(_, "Next", _),
          [BindingPattern("value", _)],
          _
        ) => ()
        _ => fail("expected state payload pattern")
      }
      match arms[0].guard_condition {
        Some(BinaryExpr(Greater, NameExpr("value", _), I32Expr(0UL, _), _)) =>
          ()
        _ => fail("expected functional while guard")
      }
      match arms[0].body {
        BlockExpr(
          {
            items: [ExpressionItem(ContinueExpr(NameExpr("next", _), _), _)],
            ..,
          }
        ) => ()
        _ => fail("expected block continue transfer")
      }
      assert_eq(arms[1].body, BreakExpr(I32Expr(0UL, 87UL), 81UL))
    }
    _ => fail("expected functional while expression")
  }
}

///|
test "functional while accepts direct continue and break arm bodies" {
  match
    parse_test_expression(
      b"while current {\n  Some(next) => continue next\n  None => break 0\n}\n",
    ) {
    Ok(WhileExpr(_, arms, _)) => {
      assert_eq(arms.length(), 2)
      match arms[0].body {
        ContinueExpr(NameExpr("next", _), _) => ()
        _ => fail("expected direct continue expression")
      }
      match arms[1].body {
        BreakExpr(I32Expr(0UL, _), _) => ()
        _ => fail("expected direct break expression")
      }
    }
    _ => fail("expected direct functional transfers")
  }
}

///|
test "functional while reuses alternatives rest and discard patterns" {
  match
    parse_test_expression(
      b"while state {\n  List::Cons(head, ...), Vector::Items(head, ...) if head > 0 => continue head\n  Message::Data {\n    _metadata\n    ...\n  } => break 1\n  _ => break 0\n}\n",
    ) {
    Ok(WhileExpr(_, arms, _)) => {
      assert_eq(arms.length(), 3)
      match arms[0].pattern {
        AlternativePattern(
          TuplePattern(_, [BindingPattern("head", _), RestPattern(_)], _),
          [TuplePattern(_, [BindingPattern("head", _), RestPattern(_)], _)],
          _
        ) => ()
        _ => fail("expected rest alternatives")
      }
      match arms[1].pattern {
        StructPattern(_, [field], Some(_), _) => {
          assert_eq(field.name, "_metadata")
          assert_eq(field.pattern, WildcardPattern(field.offset))
        }
        _ => fail("expected struct rest and discard")
      }
    }
    _ => fail("expected compositional functional while patterns")
  }
}

///|
test "functional transfers compose inside nested if blocks" {
  match
    parse_test_expression(
      b"while state {\n  State::Next(next) => {\n    if ready {\n      continue next\n    }\n    break 0\n  }\n  _ => break 1\n}\n",
    ) {
    Ok(WhileExpr(_, [first, _], _)) =>
      match first.body {
        BlockExpr(
          {
            items: [
              ExpressionItem(IfExpr(_, then_block, None, _), _),
              ExpressionItem(BreakExpr(_, _), _),
            ],
            ..,
          }
        ) =>
          match then_block.items {
            [ExpressionItem(ContinueExpr(NameExpr("next", _), _), _)] => ()
            _ => fail("expected continue inside if branch")
          }
        _ => fail("expected nested transfer block")
      }
    _ => fail("expected functional while with nested transfers")
  }
}

///|
test "functional while initial constructors require grouping" {
  match parse_test_expression(b"while (State {}) {\n  _ => break 0\n}") {
    Ok(WhileExpr(ConstructExpr(NameExpr("State", _), [], _), [_], _)) => ()
    _ => fail("expected grouped constructor initial state")
  }
}

///|
test "functional while remains in binary-seeking mode" {
  match
    parse_test_expression(b"while state {\n  _ => break result\n}.field + 1") {
    Ok(
      BinaryExpr(
        Add,
        FieldExpr(WhileExpr(_, [_], _), "field", _),
        I32Expr(1UL, _),
        _
      )
    ) => ()
    _ => fail("expected postfix and infix continuation")
  }
}

///|
test "break and continue are value-carrying expressions" {
  assert_eq(
    Parser::from_bytes(b"break 1 + 2").parse_expression(),
    Ok(
      BreakExpr(
        BinaryExpr(Add, I32Expr(1UL, 6UL), I32Expr(2UL, 10UL), 8UL),
        0UL,
      ),
    ),
  )
  assert_eq(
    Parser::from_bytes(b"continue next").parse_expression(),
    Ok(ContinueExpr(NameExpr("next", 9UL), 0UL)),
  )
}

///|
test "break and continue require same-line values" {
  match Parser::from_bytes(b"break\nvalue").parse_expression() {
    Err(ExpectedBreakValue(Some(token), 0UL)) =>
      match token.kind() {
        @tokenizer.Newline => ()
        _ => fail("expected newline after break")
      }
    _ => fail("expected missing break value diagnostic")
  }
  match Parser::from_bytes(b"continue\nvalue").parse_expression() {
    Err(ExpectedContinueValue(Some(token), 0UL)) =>
      match token.kind() {
        @tokenizer.Newline => ()
        _ => fail("expected newline after continue")
      }
    _ => fail("expected missing continue value diagnostic")
  }
}

///|
test "functional while reports missing initial states and bodies" {
  match parse_test_expression(b"while {\n}") {
    Err(ExpectedValue(Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftBrace) => ()
        _ => fail("expected body brace without initial state")
      }
    _ => fail("expected missing initial state diagnostic")
  }
  match parse_test_expression(b"while state trailing") {
    Err(ExpectedWhileBody(Some(token), 0UL)) =>
      match token.kind() {
        @tokenizer.Identifier("trailing") => ()
        _ => fail("expected token before missing while body")
      }
    _ => fail("expected missing while body diagnostic")
  }
}

///|
test "functional while bodies and arms require structural syntax" {
  match parse_test_expression(b"while state { _ => break 0\n}") {
    Err(ExpectedWhileBodyNewline(Some(token), _)) =>
      match token.kind() {
        @tokenizer.Identifier("_") => ()
        _ => fail("expected same-line while arm")
      }
    _ => fail("expected while body newline diagnostic")
  }
  match parse_test_expression(b"while state {\n  _ break 0\n}") {
    Err(ExpectedWhileArmArrow(Some(token), _)) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Break) => ()
        _ => fail("expected transfer without arrow")
      }
    _ => fail("expected while arm arrow diagnostic")
  }
  match parse_test_expression(b"while state {\n  _ => break 0}") {
    Err(ExpectedWhileArmNewline(Some(token), _)) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightBrace) => ()
        _ => fail("expected while closing brace")
      }
    _ => fail("expected while arm newline diagnostic")
  }
}

///|
test "empty and unclosed functional while bodies are retained precisely" {
  assert_eq(
    parse_test_expression(b"while state {}"),
    Ok(WhileExpr(NameExpr("state", 6UL), [], 0UL)),
  )
  assert_eq(parse_test_expression(b"while state {\n"), Err(UnclosedWhile(0UL)))
  assert_eq(
    parse_test_expression(b"while state {\n  _ => break 0\n"),
    Err(UnclosedWhile(0UL)),
  )
}

///|
test "large functional while arm sets parse iteratively" {
  match parse_test_expression(large_functional_while(512)) {
    Ok(WhileExpr(NameExpr("state", _), arms, _)) => {
      assert_eq(arms.length(), 513)
      assert_eq(arms[0].pattern, BindingPattern("State_0", 16UL))
      match arms[511].body {
        ContinueExpr(I32Expr(512UL, _), _) => ()
        _ => fail("expected final generated continue")
      }
      match arms[512].body {
        BreakExpr(I32Expr(0UL, _), _) => ()
        _ => fail("expected generated default break")
      }
    }
    _ => fail("expected large functional while")
  }
}
