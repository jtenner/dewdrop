///|
test "for desugars to one iterator binding and an Option while" {
  match parse_test_expression(b"for value in values {\n  consume(value)\n}\n") {
    Ok(
      BlockExpr(
        {
          items: [
            LetItem(
              false,
              iterator_name,
              _,
              CallExpr(FieldExpr(NameExpr("values", _), "iter", _), [], _),
              _
            ),
            ExpressionItem(WhileExpr(initial, arms, _), _),
          ],
          ..,
        }
      )
    ) => {
      assert_true(iterator_name.has_prefix("$for_iter_"))
      match initial {
        CallExpr(FieldExpr(NameExpr(initial_name, _), "next", _), [], _) =>
          assert_eq(initial_name, iterator_name)
        _ => fail("expected iterator next initial state")
      }
      assert_eq(arms.length(), 2)
      match arms[0].pattern {
        TuplePattern(
          QualifiedPattern(BindingPattern("Option", _), "Some", _),
          [BindingPattern("value", _)],
          _
        ) => ()
        _ => fail("expected Option::Some loop pattern")
      }
      match arms[0].body {
        BlockExpr(
          {
            items: [
              ExpressionItem(
                CallExpr(NameExpr("consume", _), [NameExpr("value", _)], _),
                _
              ),
              ExpressionItem(ContinueExpr(next, _), _),
            ],
            ..,
          }
        ) =>
          match next {
            CallExpr(FieldExpr(NameExpr(next_name, _), "next", _), [], _) =>
              assert_eq(next_name, iterator_name)
            _ => fail("expected next iterator state")
          }
        _ => fail("expected original body followed by continue")
      }
      match (arms[1].pattern, arms[1].body) {
        (
          QualifiedPattern(BindingPattern("Option", _), "None", _),
          BreakExpr(BlockExpr({ items: [], .. }), _),
        ) => ()
        _ => fail("expected Option::None unit break")
      }
    }
    _ => fail("expected desugared for expression")
  }
}

///|
test "for accepts nested patterns" {
  match
    parse_test_expression(
      b"for Pair::Item(left, right) in pairs {\n  left + right\n}",
    ) {
    Ok(
      BlockExpr(
        { items: [_, ExpressionItem(WhileExpr(_, [first, _], _), _)], .. }
      )
    ) =>
      match first.pattern {
        TuplePattern(
          _,
          [
            TuplePattern(
              QualifiedPattern(_, "Item", _),
              [BindingPattern("left", _), BindingPattern("right", _)],
              _
            ),
          ],
          _
        ) => ()
        _ => fail("expected nested user pattern inside Option::Some")
      }
    _ => fail("expected patterned for expression")
  }
}

///|
test "for reports missing in and body tokens" {
  match parse_test_expression(b"for value values {\n}") {
    Err(ExpectedForIn(Some(token), 0UL)) =>
      match token.kind() {
        @tokenizer.Identifier("values") => ()
        _ => fail("expected token in place of in")
      }
    _ => fail("expected missing in diagnostic")
  }
  match parse_test_expression(b"for value in values trailing") {
    Err(ExpectedForBody(Some(token), 0UL)) =>
      match token.kind() {
        @tokenizer.Identifier("trailing") => ()
        _ => fail("expected token in place of for body")
      }
    _ => fail("expected missing for body diagnostic")
  }
}
