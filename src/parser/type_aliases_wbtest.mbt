///|
test "public generic type aliases preserve recursive targets" {
  assert_eq(
    Parser::from_bytes(b"pub type Rows<t> = Result<List<t>>\n").parse_declaration(),
    Ok(
      TypeAlias({
        visibility: Public,
        name: "Rows",
        name_offset: 9UL,
        type_parameters: [{ name: "t", offset: 14UL }],
        target: AppliedType(
          NamedType("Result", 19UL),
          [AppliedType(NamedType("List", 26UL), [NamedType("t", 31UL)], 30UL)],
          25UL,
        ),
        offset: 0UL,
      }),
    ),
  )
}

///|
test "type alias targets may begin on the next physical line" {
  match
    Parser::from_bytes(b"type Nested<t> =\n  Map<String,\n    List<t>,\n  >\n").parse_declaration() {
    Ok(TypeAlias(declaration)) => {
      assert_eq(declaration.visibility, ModuleVisible)
      match declaration.target {
        AppliedType(NamedType("Map", _), arguments, _) =>
          assert_eq(arguments.length(), 2)
        _ => fail("expected applied alias target")
      }
    }
    _ => fail("expected multiline type alias")
  }
}

///|
test "simple type aliases accept EOF as their final newline" {
  assert_eq(
    Parser::from_bytes(b"type UserId = U64").parse_declaration(),
    Ok(
      TypeAlias({
        visibility: ModuleVisible,
        name: "UserId",
        name_offset: 5UL,
        type_parameters: [],
        target: NamedType("U64", 14UL),
        offset: 0UL,
      }),
    ),
  )
}

///|
test "type aliases diagnose missing names equals and targets" {
  match Parser::from_bytes(b"type = I32\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(TypeAliasName, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Equal) => ()
        _ => fail("expected alias equals")
      }
    _ => fail("expected missing type alias name")
  }
  match Parser::from_bytes(b"type Alias I32\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(Equal, Some(token))) =>
      match token.kind() {
        @tokenizer.Identifier("I32") => ()
        _ => fail("expected alias target")
      }
    _ => fail("expected missing type alias equals")
  }
  match Parser::from_bytes(b"type Alias =\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(Type, None)) => ()
    _ => fail("expected missing type alias target")
  }
}

///|
test "type aliases require their target to end the declaration" {
  match Parser::from_bytes(b"type Alias = I32 extra\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(LineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Identifier("extra") => ()
        _ => fail("expected extra alias token")
      }
    _ => fail("expected type alias line-end diagnostic")
  }
}

///|
test "type aliases retain contextual nested generic closers" {
  match
    Parser::from_bytes(b"type Deep<a> = Outer<Inner<Result<a>>>\n").parse_declaration() {
    Ok(TypeAlias(declaration)) =>
      match declaration.target {
        AppliedType(_, [AppliedType(_, [AppliedType(_, [_], _)], _)], _) => ()
        _ => fail("expected three nested alias applications")
      }
    _ => fail("expected nested type alias")
  }
}

///|
test "type alias declarations require newline separation" {
  match
    Parser::from_bytes(b"type First = I32 type Second = I64\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(LineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Type) => ()
        _ => fail("expected second type keyword")
      }
    _ => fail("expected missing type alias declaration newline")
  }
}
