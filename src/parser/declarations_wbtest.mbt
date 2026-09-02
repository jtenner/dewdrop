///|
fn parse_test_declaration(
  source : Bytes,
) -> Result[Declaration, DeclarationError] {
  Parser::from_bytes(source).parse_declaration()
}

///|
test "public builtin declaration preserves complete signature" {
  assert_eq(
    parse_test_declaration(
      b"pub builtin i32_add(a: I32, b: I32) -> I32 = \"i32_add\"",
    ),
    Ok(
      Builtin({
        visibility: Public,
        name: "i32_add",
        name_offset: 12UL,
        type_parameters: [],
        parameters: [
          { name: "a", type_: NamedType("I32", 23UL), offset: 20UL, },
          { name: "b", type_: NamedType("I32", 31UL), offset: 28UL, },
        ],
        return_type: NamedType("I32", 39UL),
        builtin_name: b"i32_add",
        offset: 0UL,
      }),
    ),
  )
}

///|
test "product types preserve order nesting and trailing commas" {
  match
    parse_test_declaration(
      b"builtin split(value: U64) -> (U32, (U16, U8), U32,) = \"split\"",
    ) {
    Ok(Builtin(declaration)) =>
      assert_eq(
        declaration.return_type,
        ProductType(
          [
            NamedType("U32", 30UL),
            ProductType([NamedType("U16", 36UL), NamedType("U8", 41UL)], 35UL),
            NamedType("U32", 46UL),
          ],
          29UL,
        ),
      )
    _ => fail("expected product return type")
  }
}

///|
test "function types preserve parameter and result structure" {
  match
    parse_test_declaration(
      b"builtin apply(callback: fn(I32, Bool) -> I64) -> fn(I32) -> I64 = \"apply\"",
    ) {
    Ok(Builtin(declaration)) => {
      assert_eq(declaration.parameters.length(), 1)
      match declaration.parameters[0].type_ {
        FunctionType(parameters, NamedType("I64", _), _) => {
          assert_eq(parameters.length(), 2)
          assert_eq(parameters[0], NamedType("I32", 27UL))
          assert_eq(parameters[1], NamedType("Bool", 32UL))
        }
        _ => fail("expected callback function type")
      }
      match declaration.return_type {
        FunctionType(parameters, NamedType("I64", _), _) => {
          assert_eq(parameters.length(), 1)
          assert_eq(parameters[0], NamedType("I32", 52UL))
        }
        _ => fail("expected returned function type")
      }
    }
    _ => fail("expected builtin with function types")
  }
}

///|
test "non-public builtins remain module visible" {
  assert_eq(
    parse_test_declaration(b"builtin clock() -> I64 = \"clock\""),
    Ok(
      Builtin({
        visibility: ModuleVisible,
        name: "clock",
        name_offset: 8UL,
        type_parameters: [],
        parameters: [],
        return_type: NamedType("I64", 19UL),
        builtin_name: b"clock",
        offset: 0UL,
      }),
    ),
  )
}

///|
test "generic builtins retain type and value parameter information" {
  match
    parse_test_declaration(
      b"pub builtin select<t, u,>(value: t, fallback: u,) -> t = \"select\"",
    ) {
    Ok(Builtin(declaration)) => {
      assert_eq(declaration.visibility, Public)
      assert_eq(declaration.name, "select")
      assert_eq(declaration.type_parameters.length(), 2)
      assert_eq(declaration.type_parameters[0].name, "t")
      assert_eq(declaration.type_parameters[1].name, "u")
      assert_eq(declaration.parameters.length(), 2)
      assert_eq(declaration.parameters[0].name, "value")
      assert_eq(declaration.parameters[0].type_, NamedType("t", 33UL))
      assert_eq(declaration.parameters[1].name, "fallback")
      assert_eq(declaration.parameters[1].type_, NamedType("u", 46UL))
      assert_eq(declaration.return_type, NamedType("t", 53UL))
      assert_eq(declaration.builtin_name, b"select")
    }
    _ => fail("expected generic builtin declaration")
  }
}

///|
test "newlines are accepted in declaration lists after commas" {
  match
    parse_test_declaration(
      b"builtin select<\n  t,\n  u,\n>(\n  value: t,\n  fallback: u,\n) -> t = \"select\"\n",
    ) {
    Ok(Builtin(declaration)) => {
      assert_eq(declaration.type_parameters.length(), 2)
      assert_eq(declaration.parameters.length(), 2)
    }
    _ => fail("expected multiline builtin signature")
  }
}

///|
test "one trailing comma is accepted but an empty parameter is not" {
  match parse_test_declaration(b"builtin ok(a: I32,) -> I32 = \"ok\"") {
    Ok(Builtin(declaration)) => assert_eq(declaration.parameters.length(), 1)
    _ => fail("expected one trailing parameter comma")
  }
  match parse_test_declaration(b"builtin bad(a: I32,,) -> I32 = \"bad\"") {
    Err(ExpectedDeclarationSyntax(ParameterName, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Comma) => ()
        _ => fail("expected second comma to fail as a parameter name")
      }
    _ => fail("expected duplicate parameter comma to fail")
  }
}

///|
test "declaration parser leaves the next declaration untouched" {
  let parser = Parser::from_bytes(
    b"builtin first() -> I32 = \"first\"\nbuiltin second() -> I32 = \"second\"\n",
  )
  match parser.parse_declaration() {
    Ok(Builtin(declaration)) => assert_eq(declaration.name, "first")
    _ => fail("expected first builtin")
  }
  match parser.parse_declaration() {
    Ok(Builtin(declaration)) => assert_eq(declaration.name, "second")
    _ => fail("expected second builtin")
  }
  assert_eq(parser.peek_token(), None)
}

///|
test "builtin declarations require an arrow return type" {
  match
    parse_test_declaration(b"builtin log(value: String) -> Unit = \"log\"") {
    Ok(Builtin(declaration)) =>
      assert_eq(declaration.return_type, NamedType("Unit", 30UL))
    _ => fail("expected explicit Unit return type")
  }
  match parse_test_declaration(b"builtin missing() = \"missing\"") {
    Err(ExpectedDeclarationSyntax(Arrow, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Equal) => ()
        _ => fail("expected equal where arrow was required")
      }
    _ => fail("expected missing return type to fail")
  }
}

///|
test "builtin names accept standard quoted string literals" {
  match
    parse_test_declaration(
      b"builtin extension() -> I32 = \"custom namespace/value\"",
    ) {
    Ok(Builtin(declaration)) =>
      assert_eq(declaration.builtin_name, b"custom namespace/value")
    _ => fail("expected unrestricted quoted builtin name")
  }
  match parse_test_declaration(b"builtin raw() -> I32 = \"\xFF\"") {
    Ok(Builtin(declaration)) => assert_eq(declaration.builtin_name, b"\xFF")
    _ => fail("expected losslessly represented builtin name")
  }
}

///|
test "builtin names reject multiline string syntax" {
  match
    parse_test_declaration(b"builtin multiline() -> I32 = #|custom\n  #|name") {
    Err(ExpectedDeclarationSyntax(BuiltinString, Some(token))) =>
      match token.kind() {
        @tokenizer.MultilineString(_) => ()
        _ => fail("expected multiline string token")
      }
    _ => fail("expected multiline builtin name to be rejected")
  }
}

///|
test "generic builtin bounds are retained" {
  match
    parse_test_declaration(
      b"builtin bounded<t: Eq>(value: t) -> t = \"bounded\"",
    ) {
    Ok(Builtin(declaration)) =>
      assert_eq(declaration.type_parameters[0].bounds, [NamedType("Eq", 19UL)])
    _ => fail("expected bounded generic builtin")
  }
}

///|
test "builtin source names may be overloaded" {
  let parser = Parser::from_bytes(
    b"builtin convert(value: I32) -> I64 = \"convert_i32\"\nbuiltin convert(value: F32) -> F64 = \"convert_f32\"\n",
  )
  match parser.parse_declaration() {
    Ok(Builtin(declaration)) => {
      assert_eq(declaration.name, "convert")
      assert_eq(declaration.parameters[0].type_, NamedType("I32", 23UL))
    }
    _ => fail("expected first overload")
  }
  match parser.parse_declaration() {
    Ok(Builtin(declaration)) => {
      assert_eq(declaration.name, "convert")
      assert_eq(declaration.parameters[0].type_, NamedType("F32", 74UL))
    }
    _ => fail("expected second overload")
  }
}

///|
test "pub must be followed by a declaration keyword" {
  assert_eq(
    parse_test_declaration(b"pub"),
    Err(ExpectedDeclarationSyntax(DeclarationKeyword, None)),
  )
}

///|
test "there is no private declaration modifier" {
  match
    parse_test_declaration(b"private builtin hidden() -> I32 = \"hidden\"") {
    Err(ExpectedDeclarationSyntax(DeclarationKeyword, Some(token))) =>
      match token.kind() {
        @tokenizer.Identifier("private") => ()
        _ => fail("expected private to remain an ordinary identifier")
      }
    _ => fail("expected private modifier to be rejected")
  }
}
