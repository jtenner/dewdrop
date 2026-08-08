///|
fn large_struct_declaration(field_count : Int) -> Bytes {
  let output = Buffer(size_hint=field_count * 28)
  output.write_string_utf8("struct Large {\n")
  for index in 0..<field_count {
    output.write_string_utf8("  field_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(": I32\n")
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
test "public generic structs preserve ordered fields" {
  assert_eq(
    Parser::from_bytes(b"pub struct Point<t> {\n  x: t\n  y: t\n}\n").parse_declaration(),
    Ok(
      Struct({
        visibility: Public,
        name: "Point",
        name_offset: 11UL,
        type_parameters: [{ name: "t", offset: 17UL }],
        fields: [
          { name: "x", type_: NamedType("t", 27UL), offset: 24UL },
          { name: "y", type_: NamedType("t", 34UL), offset: 31UL },
        ],
        derives: [],
        offset: 0UL,
      }),
    ),
  )
}

///|
test "struct declarations retain postfix derive requests" {
  match
    Parser::from_bytes(
      b"struct Pair {\n  left: I32\n  right: I32\n} derive(Eq, Debug)\n",
    ).parse_declaration() {
    Ok(Struct(declaration)) =>
      assert_eq(declaration.derives, [
        { name: "Eq", offset: 48UL },
        { name: "Debug", offset: 52UL },
      ])
    _ => fail("expected derived struct declaration")
  }
}

///|
test "struct fields accept recursively applied types" {
  match
    Parser::from_bytes(
      b"struct Cache<t> {\n  entries: Map<String, List<t>>\n}\n",
    ).parse_declaration() {
    Ok(Struct(declaration)) => {
      assert_eq(declaration.visibility, ModuleVisible)
      assert_eq(declaration.fields.length(), 1)
      match declaration.fields[0].type_ {
        AppliedType(NamedType("Map", _), arguments, _) => {
          assert_eq(arguments.length(), 2)
          assert_eq(arguments[0], NamedType("String", 33UL))
          match arguments[1] {
            AppliedType(NamedType("List", _), inner, _) =>
              assert_eq(inner[0], NamedType("t", 46UL))
            _ => fail("expected nested List field type")
          }
        }
        _ => fail("expected applied Map field type")
      }
    }
    _ => fail("expected generic struct declaration")
  }
}

///|
test "struct type parameter lists allow newlines and trailing commas" {
  match
    Parser::from_bytes(
      b"struct Pair<\n  left,\n  right,\n> {\n  first: left\n  second: right\n}\n",
    ).parse_declaration() {
    Ok(Struct(declaration)) => {
      assert_eq(declaration.type_parameters.length(), 2)
      assert_eq(declaration.fields.length(), 2)
    }
    _ => fail("expected multiline generic struct")
  }
}

///|
test "compact and multiline empty structs are accepted" {
  match Parser::from_bytes(b"struct Empty {}").parse_declaration() {
    Ok(Struct(declaration)) => assert_eq(declaration.fields.length(), 0)
    _ => fail("expected compact empty struct")
  }
  match Parser::from_bytes(b"struct Empty {\n\n}\n").parse_declaration() {
    Ok(Struct(declaration)) => assert_eq(declaration.fields.length(), 0)
    _ => fail("expected multiline empty struct")
  }
}

///|
test "nonempty struct bodies begin with a newline" {
  match
    Parser::from_bytes(b"struct SameLine { field: I32\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(StructBodyNewline, Some(token))) =>
      match token.kind() {
        @tokenizer.Identifier("field") => ()
        _ => fail("expected field identifier")
      }
    _ => fail("expected missing struct body newline")
  }
}

///|
test "every struct field requires a terminating newline" {
  match
    Parser::from_bytes(b"struct Bad {\n  field: I32}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(LineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightBrace) => ()
        _ => fail("expected closing brace")
      }
    _ => fail("expected missing field newline")
  }
  match
    Parser::from_bytes(b"struct Bad {\n  first: I32 second: I32\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(LineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Identifier("second") => ()
        _ => fail("expected adjacent field")
      }
    _ => fail("expected adjacent fields without newline to fail")
  }
}

///|
test "struct fields do not use comma separators" {
  match
    Parser::from_bytes(b"struct Bad {\n  field: I32,\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(LineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Comma) => ()
        _ => fail("expected field comma")
      }
    _ => fail("expected comma-separated field to fail")
  }
}

///|
test "malformed struct fields report names colons and types" {
  match Parser::from_bytes(b"struct Bad {\n  : I32\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(StructFieldName, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Colon) => ()
        _ => fail("expected colon in field-name position")
      }
    _ => fail("expected missing field name")
  }
  match
    Parser::from_bytes(b"struct Bad {\n  field I32\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(Colon, Some(token))) =>
      match token.kind() {
        @tokenizer.Identifier("I32") => ()
        _ => fail("expected field type")
      }
    _ => fail("expected missing field colon")
  }
  match Parser::from_bytes(b"struct Bad {\n  field:\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(Type, Some(token))) =>
      match token.kind() {
        @tokenizer.Newline => ()
        _ => fail("expected newline after missing type")
      }
    _ => fail("expected missing field type")
  }
}

///|
test "struct fields do not have separate visibility modifiers" {
  match
    Parser::from_bytes(b"pub struct Bad {\n  pub field: I32\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(StructFieldName, Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Pub) => ()
        _ => fail("expected pub field modifier")
      }
    _ => fail("expected field visibility modifier to fail")
  }
}

///|
test "comments and blank lines preserve struct field boundaries" {
  match
    Parser::from_bytes(
      b"struct Commented { // starts\n\n  // before field\n  value: I32 // field ends\n\n}\n",
    ).parse_declaration() {
    Ok(Struct(declaration)) => assert_eq(declaration.fields.length(), 1)
    _ => fail("expected commented struct")
  }
}

///|
test "unclosed structs retain their declaration offset" {
  assert_eq(
    Parser::from_bytes(b"struct Open {\n").parse_declaration(),
    Err(UnclosedStruct(0UL)),
  )
  assert_eq(
    Parser::from_bytes(b"struct Open {\n  field: I32\n").parse_declaration(),
    Err(UnclosedStruct(0UL)),
  )
}

///|
test "struct declarations require newline separation" {
  match
    Parser::from_bytes(b"struct First {} struct Second {}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(LineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Struct) => ()
        _ => fail("expected second struct keyword")
      }
    _ => fail("expected missing struct declaration newline")
  }
}

///|
test "large struct bodies parse iteratively by field count" {
  match Parser::from_bytes(large_struct_declaration(1024)).parse_declaration() {
    Ok(Struct(declaration)) => {
      assert_eq(declaration.fields.length(), 1024)
      assert_eq(declaration.fields[0].name, "field_0")
      assert_eq(declaration.fields[1023].name, "field_1023")
    }
    _ => fail("expected large struct declaration")
  }
}
