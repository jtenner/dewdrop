///|
fn large_object_declaration(field_count : Int) -> Bytes {
  let output = Buffer(size_hint=field_count * 16)
  output.write_string_utf8("let object = {\n")
  for index in 0..<field_count {
    output.write_string_utf8("  field_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(": ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
test "let declarations bind immutable values by default" {
  assert_eq(
    Parser::from_bytes(b"let val = 1\n").parse_declaration(),
    Ok(
      Let({
        visibility: ModuleVisible,
        mutable_: false,
        name: "val",
        name_offset: 4UL,
        value: I32Expr(1UL, 10UL),
        offset: 0UL,
      }),
    ),
  )
}

///|
test "let mut declarations retain mutability" {
  match Parser::from_bytes(b"let mut val = source\n").parse_declaration() {
    Ok(Let(declaration)) => {
      assert_eq(declaration.visibility, ModuleVisible)
      assert_eq(declaration.mutable_, true)
      assert_eq(declaration.name, "val")
      assert_eq(declaration.value, NameExpr("source", 14UL))
    }
    _ => fail("expected mutable let declaration")
  }
}

///|
test "public let declarations use public module visibility" {
  match Parser::from_bytes(b"pub let answer = 42\n").parse_declaration() {
    Ok(Let(declaration)) => {
      assert_eq(declaration.visibility, Public)
      assert_eq(declaration.name, "answer")
      assert_eq(declaration.value, I32Expr(42UL, 17UL))
    }
    _ => fail("expected public let declaration")
  }
}

///|
test "end of input is an implicit final newline" {
  match Parser::from_bytes(b"let value = 1").parse_declaration() {
    Ok(Let(declaration)) => assert_eq(declaration.name, "value")
    _ => fail("expected EOF-terminated let declaration")
  }
  match
    Parser::from_bytes(b"builtin value() -> I32 = \"value\"").parse_declaration() {
    Ok(Builtin(declaration)) => assert_eq(declaration.name, "value")
    _ => fail("expected EOF-terminated builtin declaration")
  }
}

///|
test "physical newline is required between declarations" {
  match
    Parser::from_bytes(b"let first = 1 let second = 2\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(LineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Let) => ()
        _ => fail("expected second let keyword")
      }
    _ => fail("expected missing declaration newline")
  }
}

///|
test "blank lines are skipped between declarations" {
  let parser = Parser::from_bytes(b"let first = 1\n\n\nlet second = 2\n")
  match parser.parse_declaration() {
    Ok(Let(declaration)) => assert_eq(declaration.name, "first")
    _ => fail("expected first let")
  }
  match parser.parse_declaration() {
    Ok(Let(declaration)) => assert_eq(declaration.name, "second")
    _ => fail("expected second let")
  }
}

///|
test "newlines are skipped while an expression wants a value" {
  match
    Parser::from_bytes(b"let value =\n  (\n    1 +\n    2\n  )\n").parse_declaration() {
    Ok(Let(declaration)) =>
      assert_eq(
        declaration.value,
        BinaryExpr(Add, I32Expr(1UL, 20UL), I32Expr(2UL, 28UL), 22UL),
      )
    _ => fail("expected multiline incomplete expression")
  }
}

///|
test "newlines are allowed after call commas" {
  match
    Parser::from_bytes(b"let value = call(\n  1,\n  2,\n)\n").parse_declaration() {
    Ok(Let(declaration)) =>
      match declaration.value {
        CallExpr(NameExpr("call", _), arguments, _) => {
          assert_eq(arguments.length(), 2)
          assert_eq(arguments[0], I32Expr(1UL, 20UL))
          assert_eq(arguments[1], I32Expr(2UL, 25UL))
        }
        _ => fail("expected call expression")
      }
    _ => fail("expected multiline call")
  }
}

///|
test "a newline after a complete top-level value ends the let" {
  let parser = Parser::from_bytes(b"let value = function\n(argument)\n")
  match parser.parse_declaration() {
    Ok(Let(declaration)) =>
      assert_eq(declaration.value, NameExpr("function", 12UL))
    _ => fail("expected first line to end after function name")
  }
  match parser.parse_declaration() {
    Err(ExpectedDeclarationSyntax(DeclarationKeyword, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftParen) => ()
        _ => fail("expected opening parenthesis on the second line")
      }
    _ => fail("expected second line not to continue the call")
  }
}

///|
test "inline object fields are newline delimited" {
  let parser = Parser::from_bytes(
    b"let obj = {\n  a: \"b\" // first field\n  c: 39\n  d: {}\n}\n",
  )
  match parser.parse_declaration() {
    Ok(Let(declaration)) =>
      match declaration.value {
        ObjectExpr(fields, _) => {
          assert_eq(fields.length(), 3)
          assert_eq(fields[0].name, "a")
          assert_eq(fields[0].value, StringExpr(b"b", 17UL))
          assert_eq(fields[1].name, "c")
          assert_eq(fields[1].value, I32Expr(39UL, 41UL))
          assert_eq(fields[2].name, "d")
          match fields[2].value {
            ObjectExpr(nested, _) => assert_eq(nested.length(), 0)
            _ => fail("expected empty nested object")
          }
        }
        _ => fail("expected object expression")
      }
    _ => fail("expected object-valued let declaration")
  }
}

///|
test "large inline objects parse iteratively by field count" {
  match Parser::from_bytes(large_object_declaration(512)).parse_declaration() {
    Ok(Let(declaration)) =>
      match declaration.value {
        ObjectExpr(fields, _) => {
          assert_eq(fields.length(), 512)
          assert_eq(fields[0].name, "field_0")
          assert_eq(fields[511].name, "field_511")
        }
        _ => fail("expected object expression")
      }
    _ => fail("expected large object declaration")
  }
}

///|
test "multiline string scanning preserves an object field newline" {
  match
    Parser::from_bytes(
      b"let obj = {\n  text: #|first\n    #|second\n  count: 2\n}\n",
    ).parse_declaration() {
    Ok(Let(declaration)) =>
      match declaration.value {
        ObjectExpr(fields, _) => {
          assert_eq(fields.length(), 2)
          assert_eq(fields[0].value, StringExpr(b"first\nsecond", 20UL))
          assert_eq(fields[1].name, "count")
        }
        _ => fail("expected object expression")
      }
    _ => fail("expected multiline string object field")
  }
}

///|
test "malformed let headers report their exact expectation" {
  match Parser::from_bytes(b"let mut = 1\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(BindingName, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Equal) => ()
        _ => fail("expected equal after missing binding name")
      }
    _ => fail("expected missing binding name")
  }
  match Parser::from_bytes(b"let value 1\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(Equal, Some(token))) =>
      match token.kind() {
        @tokenizer.I32(1UL) => ()
        _ => fail("expected initializer token")
      }
    _ => fail("expected missing binding equal")
  }
  match Parser::from_bytes(b"let value =\n").parse_declaration() {
    Err(DeclarationExpressionError(ExpectedValue(None))) => ()
    _ => fail("expected missing initializer expression")
  }
}

///|
test "malformed object fields report names colons and closure" {
  match Parser::from_bytes(b"let obj = {\n  : 1\n}\n").parse_declaration() {
    Err(DeclarationExpressionError(ExpectedObjectField(Some(token), _))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Colon) => ()
        _ => fail("expected colon in field-name position")
      }
    _ => fail("expected missing object field name")
  }
  match Parser::from_bytes(b"let obj = {\n  field 1\n}\n").parse_declaration() {
    Err(DeclarationExpressionError(ExpectedObjectColon(Some(token), _))) =>
      match token.kind() {
        @tokenizer.I32(1UL) => ()
        _ => fail("expected value in colon position")
      }
    _ => fail("expected missing object field colon")
  }
  match Parser::from_bytes(b"let obj = {\n  field: 1\n").parse_declaration() {
    Err(DeclarationExpressionError(UnclosedObject(_))) => ()
    _ => fail("expected unclosed object")
  }
}

///|
test "object fields require a terminating newline" {
  match Parser::from_bytes(b"let obj = { a: 1 }\n").parse_declaration() {
    Err(DeclarationExpressionError(ExpectedObjectFieldNewline(Some(token), _))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightBrace) => ()
        _ => fail("expected closing brace")
      }
    _ => fail("expected missing object field newline")
  }
  match Parser::from_bytes(b"let obj = { a: 1 b: 2\n}\n").parse_declaration() {
    Err(DeclarationExpressionError(ExpectedObjectFieldNewline(Some(token), _))) =>
      match token.kind() {
        @tokenizer.Identifier("b") => ()
        _ => fail("expected adjacent field name")
      }
    _ => fail("expected adjacent fields without newline to fail")
  }
}
