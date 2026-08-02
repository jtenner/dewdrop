///|
fn large_function_declaration(item_count : Int) -> Bytes {
  let output = Buffer(size_hint=item_count * 28)
  output.write_string_utf8("fn large(value: I32) -> I32 {\n")
  for index in 0..<item_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = value + ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("  value\n}\n")
  output.to_bytes()
}

///|
test "public generic functions preserve parameters return type and body" {
  let parser = Parser::from_bytes(
    b"pub fn compute<t>(\n  value: t,\n) -> t {\n  let mut current = value\n  return current\n}\n",
  )
  match parser.parse_declaration() {
    Ok(Function(declaration)) => {
      assert_eq(declaration.visibility, Public)
      assert_eq(declaration.name, "compute")
      assert_eq(declaration.type_parameters.length(), 1)
      assert_eq(declaration.parameters.length(), 1)
      assert_eq(declaration.return_type, NamedType("t", 36UL))
      assert_eq(declaration.body.items.length(), 2)
      match declaration.body.items[0] {
        LetItem(true, "current", _, NameExpr("value", _), _) => ()
        _ => fail("expected mutable function-local let")
      }
      match declaration.body.items[1] {
        ReturnItem(Some(NameExpr("current", _)), _) => ()
        _ => fail("expected explicit return")
      }
    }
    _ => fail("expected public generic function")
  }
}

///|
test "final expression lines are retained as body items" {
  match
    Parser::from_bytes(b"fn identity(value: I32) -> I32 {\n  value\n}\n").parse_declaration() {
    Ok(Function(declaration)) => {
      assert_eq(declaration.body.items.length(), 1)
      match declaration.body.items[0] {
        ExpressionItem(NameExpr("value", _), _) => ()
        _ => fail("expected final expression item")
      }
    }
    _ => fail("expected expression-bodied block")
  }
}

///|
test "return without a value is represented explicitly" {
  match
    Parser::from_bytes(b"fn stop() -> Unit {\n  return\n}\n").parse_declaration() {
    Ok(Function(declaration)) =>
      assert_eq(declaration.body.items, [ReturnItem(None, 22UL)])
    _ => fail("expected empty return")
  }
}

///|
test "regular functions become methods when self is first" {
  match
    Parser::from_bytes(b"fn length(self: List<I32>) -> I32 {\n  0\n}\n").parse_declaration() {
    Ok(Function(declaration)) => {
      assert_true(declaration.has_receiver())
      assert_eq(declaration.parameters.length(), 0)
      match declaration.receiver {
        Some(
          {
            explicit_type: Some(AppliedType(NamedType("List", _), arguments, _)),
            ..,
          }
        ) => {
          assert_eq(arguments.length(), 1)
          assert_eq(arguments[0], NamedType("I32", 21UL))
        }
        _ => fail("expected explicitly typed receiver")
      }
    }
    _ => fail("expected receiver function")
  }
  match
    Parser::from_bytes(b"fn clone(self) -> Self {\n  self\n}\n").parse_declaration() {
    Ok(Function(declaration)) => {
      assert_true(declaration.has_receiver())
      assert_eq(
        declaration.receiver,
        Some({ explicit_type: None, offset: 9UL }),
      )
    }
    _ => fail("expected shorthand receiver function")
  }
}

///|
test "self remains restricted to the first regular function parameter" {
  match
    Parser::from_bytes(b"fn bad(value: I32, self) -> Unit {}\n").parse_declaration() {
    Err(ReceiverMustBeFirst(_)) => ()
    _ => fail("expected receiver position error")
  }
}

///|
test "nested applied types handle adjacent closing angles" {
  match
    Parser::from_bytes(
      b"fn nested(value: Outer<Inner<I32>>) -> Result<List<I32>> {}\n",
    ).parse_declaration() {
    Ok(Function(declaration)) => {
      match declaration.parameters[0] {
        { type_: AppliedType(NamedType("Outer", _), outer_arguments, _), .. } =>
          match outer_arguments[0] {
            AppliedType(NamedType("Inner", _), inner_arguments, _) =>
              assert_eq(inner_arguments[0], NamedType("I32", 29UL))
            _ => fail("expected nested inner type")
          }
        _ => fail("expected applied parameter type")
      }
      match declaration.return_type {
        AppliedType(NamedType("Result", _), result_arguments, _) =>
          match result_arguments[0] {
            AppliedType(NamedType("List", _), _, _) => ()
            _ => fail("expected nested result argument")
          }
        _ => fail("expected applied result type")
      }
    }
    _ => fail("expected nested applied types")
  }
}

///|
test "extra adjacent type closers are rejected" {
  match
    Parser::from_bytes(b"fn bad(value: List<I32>>) -> Unit {}\n").parse_declaration() {
    Err(UnexpectedTypeCloser(_)) => ()
    _ => fail("expected extra type closer")
  }
}

///|
test "compact empty function bodies are accepted" {
  match Parser::from_bytes(b"fn empty() -> Unit {}").parse_declaration() {
    Ok(Function(declaration)) => assert_eq(declaration.body.items.length(), 0)
    _ => fail("expected compact empty body")
  }
}

///|
test "nonempty function bodies require structural newlines" {
  match
    Parser::from_bytes(b"fn bad() -> Unit { return\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(FunctionBodyNewline, Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Return) => ()
        _ => fail("expected return keyword")
      }
    _ => fail("expected missing body-opening newline")
  }
  match
    Parser::from_bytes(b"fn bad(value: I32) -> I32 {\n  value}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(LineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightBrace) => ()
        _ => fail("expected closing brace")
      }
    _ => fail("expected missing expression-line newline")
  }
}

///|
test "function-local declarations cannot be public" {
  match
    Parser::from_bytes(b"fn bad() -> Unit {\n  pub let value = 1\n}\n").parse_declaration() {
    Err(DeclarationExpressionError(ExpectedValue(Some(token)))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Pub) => ()
        _ => fail("expected pub keyword")
      }
    _ => fail("expected public local declaration to fail")
  }
}

///|
test "applied type argument lists accept newlines and one trailing comma" {
  match
    Parser::from_bytes(
      b"fn use(value: Map<\n  String,\n  List<I32>,\n>) -> Unit {}\n",
    ).parse_declaration() {
    Ok(Function(declaration)) =>
      match declaration.parameters[0].type_ {
        AppliedType(NamedType("Map", _), arguments, _) => {
          assert_eq(arguments.length(), 2)
          match arguments[1] {
            AppliedType(NamedType("List", _), _, _) => ()
            _ => fail("expected nested List argument")
          }
        }
        _ => fail("expected applied Map type")
      }
    _ => fail("expected multiline applied type")
  }
}

///|
test "large function bodies parse iteratively by item count" {
  match
    Parser::from_bytes(large_function_declaration(512)).parse_declaration() {
    Ok(Function(declaration)) => {
      assert_eq(declaration.body.items.length(), 513)
      match declaration.body.items[511] {
        LetItem(_, "value_511", _, _, _) => ()
        _ => fail("expected final generated let item")
      }
    }
    _ => fail("expected large function declaration")
  }
}

///|
test "unclosed functions retain their declaration offset" {
  assert_eq(
    Parser::from_bytes(b"fn unfinished() -> Unit {\n").parse_declaration(),
    Err(UnclosedFunction(0UL)),
  )
  assert_eq(
    Parser::from_bytes(b"fn unfinished() -> Unit {\n  return\n").parse_declaration(),
    Err(UnclosedFunction(0UL)),
  )
}
