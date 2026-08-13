///|
fn nested_else_if_expression(depth : Int) -> Bytes {
  let output = Buffer(size_hint=depth * 32 + 32)
  for index in 0..<depth {
    if index == 0 {
      output.write_string_utf8("if condition_")
    } else {
      output.write_string_utf8(" else if condition_")
    }
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" {\n  ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\n}")
  }
  output.write_string_utf8(" else {\n  0\n}")
  output.to_bytes()
}

///|
test "using desugars acquisition binding and automatic disposal" {
  match
    Parser::from_bytes(
      b"fn run() -> Unit {\n  using resource = acquire()\n  use(resource)\n}\n",
    ).parse_declaration() {
    Ok(Function(declaration)) => {
      assert_eq(declaration.body.items.length(), 5)
      match declaration.body.items[0] {
        LetItem(
          false,
          "resource",
          _,
          CallExpr(NameExpr("acquire", _), [], _),
          _
        ) => ()
        _ => fail("expected using acquisition binding")
      }
      assert_true(
        declaration.body.items[1] is LetItem(_, _, _, LambdaExpr(_, _, _, _), _),
      )
      match declaration.body.items[3] {
        ExpressionItem(CallExpr(NameExpr(name, _), [], _), _) =>
          assert_true(name.contains("dew_defer_"))
        _ => fail("expected automatic disposal call")
      }
    }
    _ => fail("expected using function")
  }
}

///|
test "using diagnostics respect nested lexical shadowing" {
  match
    Parser::from_bytes(
      b"fn run() -> Unit {\n  using resource = acquire()\n  if true {\n    let resource = acquire()\n    resource.dispose()\n  }\n}\n",
    ).parse_declaration() {
    Ok(Function(_)) => ()
    _ => fail("expected shadowed manual disposal to remain independent")
  }
}

///|
test "defer desugars normal scope exit in LIFO order" {
  match
    Parser::from_bytes(
      b"fn run() -> I32 {\n  defer first()\n  defer second()\n  tail()\n}\n",
    ).parse_declaration() {
    Ok(Function(declaration)) => {
      assert_eq(declaration.body.items.length(), 6)
      assert_true(
        declaration.body.items[0] is LetItem(_, _, _, LambdaExpr(_, _, _, _), _),
      )
      assert_true(
        declaration.body.items[1] is LetItem(_, _, _, LambdaExpr(_, _, _, _), _),
      )
      assert_true(
        declaration.body.items[2]
        is LetItem(_, _, _, CallExpr(NameExpr("tail", _), [], _), _),
      )
      match declaration.body.items[3] {
        ExpressionItem(CallExpr(NameExpr(name, _), [], _), _) =>
          assert_true(name.contains("dew_defer_"))
        _ => fail("expected second cleanup call")
      }
      match declaration.body.items[4] {
        ExpressionItem(CallExpr(NameExpr(name, _), [], _), _) =>
          assert_true(name.contains("dew_defer_"))
        _ => fail("expected first cleanup call")
      }
      assert_true(
        declaration.body.items[5] is ExpressionItem(NameExpr(_, _), _),
      )
    }
    _ => fail("expected deferred function")
  }
}

///|
test "defer evaluates return values before cleanup" {
  match
    Parser::from_bytes(
      b"fn run() -> I32 {\n  defer cleanup()\n  return value()\n}\n",
    ).parse_declaration() {
    Ok(Function(declaration)) => {
      assert_eq(declaration.body.items.length(), 4)
      assert_true(
        declaration.body.items[0] is LetItem(_, _, _, LambdaExpr(_, _, _, _), _),
      )
      assert_true(
        declaration.body.items[1]
        is LetItem(_, _, _, CallExpr(NameExpr("value", _), [], _), _),
      )
      assert_true(
        declaration.body.items[2]
        is ExpressionItem(CallExpr(NameExpr(_, _), [], _), _),
      )
      assert_true(
        declaration.body.items[3] is ReturnItem(Some(NameExpr(_, _)), _),
      )
    }
    _ => fail("expected deferred return function")
  }
}

///|
test "if is condition desugars to a binding match" {
  match
    parse_test_expression(
      b"if get_it(42) is Option::Some(bound) {\n  bound\n} else {\n  0\n}",
    ) {
    Ok(
      MatchExpr(CallExpr(NameExpr("get_it", _), [_], _), [matched, fallback], _)
    ) => {
      match matched.pattern {
        TuplePattern(
          QualifiedPattern(_, "Some", _),
          [BindingPattern("bound", _)],
          _
        ) => ()
        _ => fail("expected constructor binding pattern")
      }
      match matched.body {
        BlockExpr(block) =>
          assert_eq(block.tail_expression(), Some(NameExpr("bound", 41UL)))
        _ => fail("expected true branch block")
      }
      assert_true(fallback.pattern is WildcardPattern(_))
    }
    _ => fail("expected if-is match desugaring")
  }
}

///|
test "if is bindings remain available through conjunction chains" {
  match
    parse_test_expression(
      b"if get_it(42) is Option::Some(bound) && bound > 0 && bound < 100 {\n  bound\n}",
    ) {
    Ok(MatchExpr(_, [matched, _], _)) =>
      match matched.guard_condition {
        Some(
          BinaryExpr(
            LogicalAnd,
            BinaryExpr(Greater, NameExpr("bound", _), _, _),
            BinaryExpr(Less, NameExpr("bound", _), _, _),
            _
          )
        ) => ()
        _ => fail("expected complete conjunction chain in match guard")
      }
    _ => fail("expected conjunction chain to desugar through one match")
  }
}

///|
test "if without else retains a unit-capable optional branch" {
  match parse_test_expression(b"if ready {\n  run()\n}") {
    Ok(IfExpr(NameExpr("ready", _), block, None, 0UL)) => {
      assert_eq(block.items.length(), 1)
      match block.items[0] {
        ExpressionItem(CallExpr(NameExpr("run", _), [], _), _) => ()
        _ => fail("expected effect expression in if block")
      }
    }
    _ => fail("expected if expression without else")
  }
}

///|
test "if with else retains value-producing branch blocks" {
  match parse_test_expression(b"if ready {\n  1\n} else {\n  2\n}") {
    Ok(IfExpr(NameExpr("ready", _), then_block, Some(BlockExpr(else_block)), _)) => {
      assert_eq(then_block.tail_expression(), Some(I32Expr(1UL, 13UL)))
      assert_eq(else_block.tail_expression(), Some(I32Expr(2UL, 26UL)))
    }
    _ => fail("expected if expression with else block")
  }
}

///|
test "else-if chains are represented as nested if expressions" {
  match
    parse_test_expression(
      b"if first {\n  1\n} else if second {\n  2\n} else {\n  3\n}",
    ) {
    Ok(IfExpr(NameExpr("first", _), _, Some(nested), _)) =>
      match nested {
        IfExpr(NameExpr("second", _), _, Some(BlockExpr(final_block)), _) =>
          assert_eq(final_block.tail_expression(), Some(I32Expr(3UL, 49UL)))
        _ => fail("expected nested else-if expression")
      }
    _ => fail("expected outer if expression")
  }
}

///|
test "if expressions compose with infix and postfix continuations" {
  match
    parse_test_expression(
      b"1 + if ready {\n  left\n} else {\n  right\n}.finish()",
    ) {
    Ok(
      BinaryExpr(
        Add,
        I32Expr(1UL, _),
        CallExpr(FieldExpr(IfExpr(_, _, Some(_), _), "finish", _), [], _),
        _
      )
    ) => ()
    _ => fail("expected postfix continuation after if expression")
  }
}

///|
test "constructor fields may contain if expressions" {
  match
    parse_test_expression(
      b"Config::{\n  value: if ready {\n    first\n  } else {\n    second\n  }\n}",
    ) {
    Ok(ConstructExpr(NameExpr("Config", _), [field], _)) =>
      match field.value {
        IfExpr(_, _, Some(BlockExpr(_)), _) => ()
        _ => fail("expected if-valued constructor field")
      }
    _ => fail("expected constructor containing if expression")
  }
}

///|
test "if conditions stop before their ungrouped body brace" {
  match parse_test_expression(b"if left + right {\n  result\n}") {
    Ok(
      IfExpr(
        BinaryExpr(Add, NameExpr("left", _), NameExpr("right", _), _),
        _,
        None,
        _
      )
    ) => ()
    _ => fail("expected binary condition before block")
  }
}

///|
test "explicit constructor expressions remain valid conditions" {
  match parse_test_expression(b"if Point::{} {\n  valid\n}") {
    Ok(IfExpr(ConstructExpr(NameExpr("Point", _), [], _), _, None, _)) => ()
    _ => fail("expected explicit constructor condition")
  }
}

///|
test "else must share the closing-brace line to preserve one lookahead" {
  let parser = Parser::from_bytes(
    b"if ready {\n  run()\n}\nelse {\n  stop()\n}",
  )
  match parser.parse_expression() {
    Ok(IfExpr(_, _, None, _)) => ()
    _ => fail("expected if to terminate before next-line else")
  }
  match parser.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Newline => ()
        _ => fail("expected retained newline before else")
      }
    None => fail("expected newline before else")
  }
}

///|
test "reusable blocks preserve lets returns expressions and tail lookup" {
  match
    Parser::from_bytes(
      b"fn compute(value: I32) -> I32 {\n  let mut current = value\n  if current {\n    return current\n  }\n  current\n}\n",
    ).parse_declaration() {
    Ok(Function(declaration)) => {
      assert_eq(declaration.body.items.length(), 3)
      match declaration.body.items[0] {
        LetItem(true, "current", _, NameExpr("value", _), _) => ()
        _ => fail("expected block-local mutable let")
      }
      match declaration.body.items[1] {
        ExpressionItem(IfExpr(_, nested, None, _), _) =>
          match nested.items[0] {
            ReturnItem(Some(NameExpr("current", _)), _) => ()
            _ => fail("expected nested block return")
          }
        _ => fail("expected if expression block item")
      }
      assert_eq(
        declaration.body.tail_expression(),
        Some(NameExpr("current", 98UL)),
      )
    }
    _ => fail("expected function with reusable blocks")
  }
}

///|
test "local and index setting are block items rather than expressions" {
  match
    Parser::from_bytes(
      b"fn update(array: Values, index: U32, value: I32) -> Unit {\n  array[index] = value\n}\n",
    ).parse_declaration() {
    Ok(Function(declaration)) =>
      match declaration.body.items[0] {
        IndexSetItem(
          IndexExpr(NameExpr("array", _), NameExpr("index", _), _),
          NameExpr("value", _),
          _
        ) => ()
        _ => fail("expected indexed block mutation")
      }
    _ => fail("expected function containing indexed mutation")
  }
  match
    Parser::from_bytes(
      b"fn update() -> Unit {\n  let mut value = 0\n  value = 1\n}\n",
    ).parse_declaration() {
    Ok(Function(declaration)) =>
      match declaration.body.items[1] {
        AssignmentItem(NameExpr("value", _), I32Expr(1UL, _), _) => ()
        _ => fail("expected local assignment block item")
      }
    _ => fail("expected function containing local assignment")
  }
  match
    Parser::from_bytes(
      b"fn invalid(value: Item) -> Unit {\n  value.field = 1\n}\n",
    ).parse_declaration() {
    Err(DeclarationExpressionError(ExpectedAssignmentTarget(_, _))) => ()
    _ => fail("expected an invalid assignment target diagnostic")
  }
}

///|
test "if and block syntax report deterministic errors" {
  match parse_test_expression(b"if {\n}\n") {
    Err(ExpectedValue(Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftBrace) => ()
        _ => fail("expected body brace in condition position")
      }
    _ => fail("expected missing if condition")
  }
  match parse_test_expression(b"if ready value") {
    Err(ExpectedIfBody(Some(token), 0UL)) =>
      match token.kind() {
        @tokenizer.Identifier("value") => ()
        _ => fail("expected invalid if body token")
      }
    _ => fail("expected missing if body")
  }
  match parse_test_expression(b"if ready { value\n}") {
    Err(ExpectedBlockNewline(Some(token), _)) =>
      match token.kind() {
        @tokenizer.Identifier("value") => ()
        _ => fail("expected same-line block value")
      }
    _ => fail("expected block opening newline")
  }
  match parse_test_expression(b"if ready {\n  value}\n") {
    Err(ExpectedBlockItemNewline(Some(token), _)) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightBrace) => ()
        _ => fail("expected closing block brace")
      }
    _ => fail("expected block item newline")
  }
  assert_eq(
    parse_test_expression(b"if ready {\n  value\n"),
    Err(UnclosedBlock(9UL)),
  )
}

///|
test "else branches require a block or nested if" {
  match parse_test_expression(b"if ready {} else value") {
    Err(ExpectedElseBranch(Some(token), 0UL)) =>
      match token.kind() {
        @tokenizer.Identifier("value") => ()
        _ => fail("expected invalid else value")
      }
    _ => fail("expected invalid else branch")
  }
}

///|
test "deep else-if chains retain every arm" {
  let depth = 1024
  match parse_test_expression(nested_else_if_expression(depth)) {
    Ok(expression) => {
      let mut current = expression
      let mut count = 0
      while true {
        match current {
          IfExpr(_, _, Some(next), _) => {
            count += 1
            current = next
          }
          BlockExpr(_) => break
          _ => fail("expected if or final block in chain")
        }
      }
      assert_eq(count, depth)
    }
    _ => fail("expected deep else-if chain")
  }
}
