///|
fn large_match_expression(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 28 + 32)
  output.write_string_utf8("match value {\n")
  for index in 0..<arm_count {
    output.write_string_utf8("  Variant_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" => ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_byte(b'}')
  output.to_bytes()
}

///|
fn large_alternative_match_expression(pattern_count : Int) -> Bytes {
  let output = Buffer(size_hint=pattern_count * 18 + 48)
  output.write_string_utf8("match value {\n  ")
  for index in 0..<pattern_count {
    if index > 0 {
      output.write_string_utf8(",\n  ")
    }
    output.write_string_utf8("Variant_")
    output.write_string_utf8(index.to_string())
  }
  output.write_string_utf8(" if ready => result\n}")
  output.to_bytes()
}

///|
test "match expressions preserve unit tuple and struct patterns" {
  match
    parse_test_expression(
      b"match option {\n  Option::None => fallback\n  Option::Some(value) => value\n  Message::Data {\n    item\n  } => item\n}",
    ) {
    Ok(MatchExpr(NameExpr("option", _), arms, 0UL)) => {
      assert_eq(arms.length(), 3)
      match arms[0].pattern {
        QualifiedPattern(BindingPattern("Option", _), "None", _) => ()
        _ => fail("expected unit variant pattern")
      }
      match arms[1].pattern {
        TuplePattern(QualifiedPattern(_, "Some", _), [_], _) => ()
        _ => fail("expected tuple variant pattern")
      }
      match arms[2].pattern {
        StructPattern(QualifiedPattern(_, "Data", _), [field], None, _) =>
          assert_eq(field.name, "item")
        _ => fail("expected struct variant pattern")
      }
    }
    _ => fail("expected mixed match expression")
  }
}

///|
test "match arms accept comma-separated alternatives and if guards" {
  match
    parse_test_expression(
      b"match value {\n  Option::Some(item), Result::Ok(item) if item > 0 => item\n  Option::None, Result::Err(_) => fallback\n}",
    ) {
    Ok(MatchExpr(_, arms, _)) => {
      assert_eq(arms.length(), 2)
      match arms[0].pattern {
        AlternativePattern(
          TuplePattern(QualifiedPattern(_, "Some", _), [_], _),
          [TuplePattern(QualifiedPattern(_, "Ok", _), [_], _)],
          _
        ) => ()
        _ => fail("expected tuple pattern alternatives")
      }
      match arms[0].guard_condition {
        Some(BinaryExpr(Greater, NameExpr("item", _), I32Expr(0UL, _), _)) => ()
        _ => fail("expected guarded first arm")
      }
      match arms[1].pattern {
        AlternativePattern(
          QualifiedPattern(_, "None", _),
          [TuplePattern(QualifiedPattern(_, "Err", _), [_], _)],
          _
        ) => ()
        _ => fail("expected unit and tuple alternatives")
      }
      assert_eq(arms[1].guard_condition, None)
    }
    _ => fail("expected guarded alternative match arms")
  }
}

///|
test "underscore-prefixed alternative bindings are discarded independently" {
  match
    parse_test_expression(
      b"match value {\n  Option::Some(_left), Result::Ok(_right) => fallback\n}\n",
    ) {
    Ok(MatchExpr(_, [arm], _)) =>
      match arm.pattern {
        AlternativePattern(
          TuplePattern(_, [WildcardPattern(_)], _),
          [TuplePattern(_, [WildcardPattern(_)], _)],
          _
        ) => ()
        _ => fail("expected discarded alternative payload bindings")
      }
    _ => fail("expected underscore-discard alternatives")
  }
}

///|
test "alternative patterns may continue after comma newlines" {
  match
    parse_test_expression(
      b"match value {\n  First,\n  Second,\n  Third if ready => result\n}\n",
    ) {
    Ok(MatchExpr(_, [arm], _)) => {
      match arm.pattern {
        AlternativePattern(BindingPattern("First", _), alternatives, _) => {
          assert_eq(alternatives.length(), 2)
          assert_eq(alternatives[1], BindingPattern("Third", 35UL))
        }
        _ => fail("expected multiline alternatives")
      }
      assert_eq(arm.guard_condition, Some(NameExpr("ready", 44UL)))
    }
    _ => fail("expected multiline alternative arm")
  }
}

///|
test "match arms combine rest patterns alternatives and guards" {
  match
    parse_test_expression(
      b"match value {\n  List::Cons(head, ...), Vector::Items(head, ...) if head > 0 => head\n  Message::Data {\n    value\n    ...\n  } => value\n}\n",
    ) {
    Ok(MatchExpr(_, arms, _)) => {
      match arms[0].pattern {
        AlternativePattern(
          TuplePattern(_, [BindingPattern("head", _), RestPattern(_)], _),
          [TuplePattern(_, [BindingPattern("head", _), RestPattern(_)], _)],
          _
        ) => ()
        _ => fail("expected tuple rest alternatives")
      }
      match arms[1].pattern {
        StructPattern(_, [field], Some(_), _) => assert_eq(field.name, "value")
        _ => fail("expected struct rest arm")
      }
    }
    _ => fail("expected guarded rest-pattern match")
  }
}

///|
test "match arms accept return expressions" {
  let parsed = parse_test_expression(
    b"match value {\n  Ok(item) => return None\n  Err(_) => ()\n}",
  )
  match parsed {
    Ok(MatchExpr(_, arms, _)) => {
      match arms[0].body {
        BlockExpr({ items: [ReturnItem(Some(NameExpr("None", _)), _)], .. }) => ()
        _ => fail("expected return expression block")
      }
    }
    _ => fail("expected match return expression")
  }
}

///|
test "bare return is an expression" {
  assert_eq(
    parse_test_expression(b"return"),
    Ok(BlockExpr({ items: [ReturnItem(None, 0UL)], offset: 0UL })),
  )
}

///|
test "match arms accept expression and reusable block bodies" {
  match
    parse_test_expression(
      b"match value {\n  true => 1\n  false => {\n    let result = 2\n    result\n  }\n}",
    ) {
    Ok(MatchExpr(_, arms, _)) => {
      assert_eq(arms.length(), 2)
      assert_eq(arms[0].body, I32Expr(1UL, 24UL))
      match arms[1].body {
        BlockExpr(block) => {
          assert_eq(block.items.length(), 2)
          assert_eq(block.tail_expression(), Some(NameExpr("result", 62UL)))
        }
        _ => fail("expected block match arm")
      }
    }
    _ => fail("expected block-bodied match")
  }
}

///|
test "direct match-arm braces are blocks and parenthesized braces are objects" {
  match
    parse_test_expression(
      b"match value {\n  Block => {}\n  Object => ({\n    field: 1\n  })\n}",
    ) {
    Ok(MatchExpr(_, arms, _)) => {
      match arms[0].body {
        BlockExpr({ items: [], .. }) => ()
        _ => fail("expected direct empty block")
      }
      match arms[1].body {
        ObjectExpr([field], _) => assert_eq(field.name, "field")
        _ => fail("expected parenthesized object expression")
      }
    }
    _ => fail("expected block and object match arms")
  }
}

///|
test "match arm bodies may begin after the fat arrow newline" {
  match
    parse_test_expression(
      b"match value {\n  First =>\n    value\n  Second =>\n    {\n      result\n    }\n}\n",
    ) {
    Ok(MatchExpr(_, arms, _)) => {
      assert_eq(arms.length(), 2)
      assert_eq(arms[0].body, NameExpr("value", 29UL))
      match arms[1].body {
        BlockExpr(block) =>
          assert_eq(block.tail_expression(), Some(NameExpr("result", 59UL)))
        _ => fail("expected multiline block arm")
      }
    }
    _ => fail("expected multiline match arm bodies")
  }
}

///|
test "match scrutinees stop before ungrouped braces" {
  match parse_test_expression(b"match left + right {\n  _ => result\n}") {
    Ok(
      MatchExpr(
        BinaryExpr(Add, NameExpr("left", _), NameExpr("right", _), _),
        [_],
        _
      )
    ) => ()
    _ => fail("expected binary match scrutinee")
  }
}

///|
test "explicit constructors remain valid match scrutinees" {
  match parse_test_expression(b"match Point::{} {\n  _ => valid\n}") {
    Ok(MatchExpr(ConstructExpr(NameExpr("Point", _), [], _), [_], _)) => ()
    _ => fail("expected explicit constructor scrutinee")
  }
}

///|
test "match expressions remain in binary-seeking mode" {
  match parse_test_expression(b"match value {\n  _ => result\n}.field(1)") {
    Ok(
      CallExpr(
        FieldExpr(MatchExpr(_, [_], _), "field", _),
        [I32Expr(1UL, _)],
        _
      )
    ) => ()
    _ => fail("expected postfix continuation after match")
  }
}

///|
test "empty compact and multiline matches are syntactically retained" {
  assert_eq(
    parse_test_expression(b"match value {}"),
    Ok(MatchExpr(NameExpr("value", 6UL), [], 0UL)),
  )
  assert_eq(
    parse_test_expression(b"match value {\n\n}"),
    Ok(MatchExpr(NameExpr("value", 6UL), [], 0UL)),
  )
}

///|
test "nested match and if expressions compose in arm bodies" {
  match
    parse_test_expression(
      b"match outer {\n  _ => match inner {\n    true => if ready {\n      yes\n    } else {\n      no\n    }\n    false => fallback\n  }\n}",
    ) {
    Ok(MatchExpr(_, [{ body: MatchExpr(_, inner_arms, _), .. }], _)) => {
      assert_eq(inner_arms.length(), 2)
      match inner_arms[0].body {
        IfExpr(_, _, Some(BlockExpr(_)), _) => ()
        _ => fail("expected if expression inside nested match")
      }
    }
    _ => fail("expected nested match expression")
  }
}

///|
test "match bodies and arms require structural newlines" {
  match parse_test_expression(b"match value { _ => result\n}") {
    Err(ExpectedMatchBodyNewline(Some(token), _)) =>
      match token.kind() {
        @tokenizer.Identifier("_") => ()
        _ => fail("expected same-line match pattern")
      }
    _ => fail("expected match body newline")
  }
  match parse_test_expression(b"match value {\n  _ => result}") {
    Err(ExpectedMatchArmNewline(Some(token), _)) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightBrace) => ()
        _ => fail("expected match closing brace")
      }
    _ => fail("expected match arm newline")
  }
}

///|
test "malformed alternatives and guards retain precise diagnostics" {
  match parse_test_expression(b"match value {\n  First, => result\n}") {
    Err(MatchPatternError(ExpectedPattern(Some(token)))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.FatArrow) => ()
        _ => fail("expected fat arrow after trailing alternative comma")
      }
    _ => fail("expected missing alternative pattern diagnostic")
  }
  match parse_test_expression(b"match value {\n  First if => result\n}") {
    Err(ExpectedValue(Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.FatArrow) => ()
        _ => fail("expected fat arrow after empty guard")
      }
    _ => fail("expected missing guard expression diagnostic")
  }
}

///|
test "match arms require fat arrows" {
  match parse_test_expression(b"match value {\n  _ result\n}") {
    Err(ExpectedMatchArmArrow(Some(token), _)) =>
      match token.kind() {
        @tokenizer.Identifier("result") => ()
        _ => fail("expected arm result without arrow")
      }
    _ => fail("expected match arm arrow")
  }
}

///|
test "match surfaces separate pattern diagnostics" {
  match parse_test_expression(b"match value {\n  Some() => value\n}") {
    Err(MatchPatternError(EmptyTuplePattern(_))) => ()
    _ => fail("expected empty tuple pattern diagnostic")
  }
  match parse_test_expression(b"match value {\n  ::Bad => value\n}") {
    Err(MatchPatternError(ExpectedPattern(Some(token)))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.DoubleColon) => ()
        _ => fail("expected leading qualification token")
      }
    _ => fail("expected missing pattern diagnostic")
  }
}

///|
test "unclosed matches retain the match offset" {
  assert_eq(parse_test_expression(b"match value {\n"), Err(UnclosedMatch(0UL)))
  assert_eq(
    parse_test_expression(b"match value {\n  _ => result\n"),
    Err(UnclosedMatch(0UL)),
  )
}

///|
test "comments and blank lines preserve match arm boundaries" {
  match
    parse_test_expression(
      b"match value { // open\n\n  // first\n  true => yes // end\n\n  false => no\n}\n",
    ) {
    Ok(MatchExpr(_, arms, _)) => assert_eq(arms.length(), 2)
    _ => fail("expected commented match")
  }
}

///|
test "large alternative lists parse iteratively" {
  match parse_test_expression(large_alternative_match_expression(512)) {
    Ok(MatchExpr(_, [arm], _)) => {
      match arm.pattern {
        AlternativePattern(BindingPattern("Variant_0", _), alternatives, _) => {
          assert_eq(alternatives.length(), 511)
          assert_eq(
            alternatives[510],
            BindingPattern("Variant_511", alternatives[510].offset()),
          )
        }
        _ => fail("expected large alternative pattern")
      }
      match arm.guard_condition {
        Some(NameExpr("ready", _)) => ()
        _ => fail("expected large alternative guard")
      }
    }
    _ => fail("expected large guarded alternative arm")
  }
}

///|
test "large match expressions parse iteratively by arm count" {
  match parse_test_expression(large_match_expression(512)) {
    Ok(MatchExpr(_, arms, _)) => {
      assert_eq(arms.length(), 512)
      assert_eq(arms[0].pattern, BindingPattern("Variant_0", 16UL))
      assert_eq(arms[511].body, I32Expr(511UL, arms[511].body.offset()))
    }
    _ => fail("expected large match expression")
  }
}
