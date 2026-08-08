///|
fn large_enum_declaration(variant_count : Int) -> Bytes {
  let output = Buffer(size_hint=variant_count * 20)
  output.write_string_utf8("enum Large {\n")
  for index in 0..<variant_count {
    output.write_string_utf8("  Variant_")
    output.write_string_utf8(index.to_string())
    output.write_byte(0x0A)
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
test "public generic enums preserve unit and tuple variants" {
  assert_eq(
    Parser::from_bytes(b"pub enum Option<t> {\n  None\n  Some(t)\n}\n").parse_declaration(),
    Ok(
      Enum({
        visibility: Public,
        name: "Option",
        name_offset: 9UL,
        type_parameters: [{ name: "t", offset: 16UL }],
        variants: [
          UnitVariant("None", 23UL),
          TupleVariant("Some", [NamedType("t", 35UL)], 30UL),
        ],
        derives: [],
        offset: 0UL,
      }),
    ),
  )
}

///|
test "enum declarations retain postfix derive requests" {
  match
    Parser::from_bytes(
      b"enum Choice {\n  No\n  Yes(I32)\n} derive(Eq, Debug)\n",
    ).parse_declaration() {
    Ok(Enum(declaration)) =>
      assert_eq(declaration.derives, [
        { name: "Eq", offset: 39UL },
        { name: "Debug", offset: 43UL },
      ])
    _ => fail("expected derived enum declaration")
  }
}

///|
test "enum variant accessors preserve names and offsets" {
  let unit = UnitVariant("None", 4UL)
  let tuple = TupleVariant("Some", [NamedType("I32", 9UL)], 7UL)
  let struct_ = StructVariant("Error", [], 13UL)
  assert_eq(unit.name(), "None")
  assert_eq(tuple.name(), "Some")
  assert_eq(struct_.name(), "Error")
  assert_eq(unit.offset(), 4UL)
  assert_eq(tuple.offset(), 7UL)
  assert_eq(struct_.offset(), 13UL)
}

///|
test "tuple variants accept recursively applied types" {
  match
    Parser::from_bytes(
      b"enum Result<t, e> {\n  Ok(List<t>)\n  Err(Map<String, List<e>>)\n}\n",
    ).parse_declaration() {
    Ok(Enum(declaration)) => {
      assert_eq(declaration.visibility, ModuleVisible)
      assert_eq(declaration.type_parameters.length(), 2)
      assert_eq(declaration.variants.length(), 2)
      match declaration.variants[1] {
        TupleVariant("Err", [AppliedType(NamedType("Map", _), arguments, _)], _) => {
          assert_eq(arguments.length(), 2)
          assert_eq(arguments[0], NamedType("String", 44UL))
          match arguments[1] {
            AppliedType(NamedType("List", _), inner, _) =>
              assert_eq(inner.length(), 1)
            _ => fail("expected nested List payload type")
          }
        }
        _ => fail("expected tuple-like Err variant")
      }
    }
    _ => fail("expected generic result enum")
  }
}

///|
test "tuple variants allow newlines and one trailing comma" {
  match
    Parser::from_bytes(
      b"enum Event {\n  Changed(\n    String,\n    List<I32>,\n  )\n}\n",
    ).parse_declaration() {
    Ok(Enum(declaration)) =>
      match declaration.variants[0] {
        TupleVariant("Changed", types, _) => assert_eq(types.length(), 2)
        _ => fail("expected multiline tuple variant")
      }
    _ => fail("expected multiline tuple enum")
  }
}

///|
test "struct-like variants preserve newline-delimited fields" {
  match
    Parser::from_bytes(
      b"enum Message<t> {\n  Quit\n  Data {\n    value: t\n    headers: Map<String, String>\n  }\n}\n",
    ).parse_declaration() {
    Ok(Enum(declaration)) => {
      assert_eq(declaration.variants.length(), 2)
      match declaration.variants[1] {
        StructVariant("Data", fields, _) => {
          assert_eq(fields.length(), 2)
          assert_eq(fields[0].name, "value")
          assert_eq(fields[1].name, "headers")
        }
        _ => fail("expected struct-like Data variant")
      }
    }
    _ => fail("expected mixed enum declaration")
  }
}

///|
test "compact and multiline empty enums are accepted" {
  match Parser::from_bytes(b"enum Never {}").parse_declaration() {
    Ok(Enum(declaration)) => assert_eq(declaration.variants.length(), 0)
    _ => fail("expected compact empty enum")
  }
  match Parser::from_bytes(b"enum Never {\n\n}\n").parse_declaration() {
    Ok(Enum(declaration)) => assert_eq(declaration.variants.length(), 0)
    _ => fail("expected multiline empty enum")
  }
}

///|
test "compact empty struct-like variants are distinct" {
  match
    Parser::from_bytes(b"enum State {\n  Unknown {}\n  Missing\n}\n").parse_declaration() {
    Ok(Enum(declaration)) => {
      assert_eq(declaration.variants.length(), 2)
      assert_eq(declaration.variants[0], StructVariant("Unknown", [], 15UL))
      assert_eq(declaration.variants[1], UnitVariant("Missing", 28UL))
    }
    _ => fail("expected empty struct-like enum variant")
  }
}

///|
test "enum declarations require a name" {
  match Parser::from_bytes(b"enum {\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(EnumName, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftBrace) => ()
        _ => fail("expected enum opening brace")
      }
    _ => fail("expected missing enum name")
  }
}

///|
test "nonempty enum bodies begin with a newline" {
  match Parser::from_bytes(b"enum SameLine { First\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(EnumBodyNewline, Some(token))) =>
      match token.kind() {
        @tokenizer.Identifier("First") => ()
        _ => fail("expected variant identifier")
      }
    _ => fail("expected enum body newline diagnostic")
  }
}

///|
test "unit and payload variants require terminating newlines" {
  match
    Parser::from_bytes(b"enum Bad {\n  First Second\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(EnumVariantPayloadOrLineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Identifier("Second") => ()
        _ => fail("expected adjacent variant name")
      }
    _ => fail("expected missing unit variant newline")
  }
  match Parser::from_bytes(b"enum Bad {\n  Some(I32)}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(LineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightBrace) => ()
        _ => fail("expected enum closing brace")
      }
    _ => fail("expected missing tuple variant newline")
  }
}

///|
test "enum variants do not use comma separators" {
  match Parser::from_bytes(b"enum Bad {\n  First,\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(EnumVariantPayloadOrLineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Comma) => ()
        _ => fail("expected variant comma")
      }
    _ => fail("expected comma-separated variant to fail")
  }
}

///|
test "empty tuple variants use the unit spelling instead" {
  assert_eq(
    Parser::from_bytes(b"enum Bad {\n  Empty()\n}\n").parse_declaration(),
    Err(EmptyTupleVariant(13UL)),
  )
}

///|
test "tuple variants reject a second trailing comma" {
  match
    Parser::from_bytes(b"enum Bad {\n  Pair(I32,,)\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(Type, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Comma) => ()
        _ => fail("expected second tuple comma")
      }
    _ => fail("expected second trailing comma to fail")
  }
}

///|
test "tuple variants diagnose separators and unclosed payloads" {
  match
    Parser::from_bytes(b"enum Bad {\n  Pair(I32 String)\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(VariantTypeSeparatorOrClose, Some(token))) =>
      match token.kind() {
        @tokenizer.Identifier("String") => ()
        _ => fail("expected adjacent tuple payload type")
      }
    _ => fail("expected missing tuple payload comma")
  }
  assert_eq(
    Parser::from_bytes(b"enum Bad {\n  Some(I32\n}\n").parse_declaration(),
    Err(UnclosedTupleVariant(13UL)),
  )
}

///|
test "struct-like variants require body and field newlines" {
  match
    Parser::from_bytes(b"enum Bad {\n  Data { value: I32\n  }\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(EnumVariantBodyNewline, Some(token))) =>
      match token.kind() {
        @tokenizer.Identifier("value") => ()
        _ => fail("expected struct-like field")
      }
    _ => fail("expected struct-like body newline")
  }
  match
    Parser::from_bytes(b"enum Bad {\n  Data {\n    value: I32}\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(LineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightBrace) => ()
        _ => fail("expected struct-like closing brace")
      }
    _ => fail("expected struct-like field newline")
  }
}

///|
test "malformed struct-like fields report names colons and types" {
  match
    Parser::from_bytes(b"enum Bad {\n  Data {\n    : I32\n  }\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(EnumVariantFieldName, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Colon) => ()
        _ => fail("expected field colon")
      }
    _ => fail("expected missing variant field name")
  }
  match
    Parser::from_bytes(b"enum Bad {\n  Data {\n    value I32\n  }\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(Colon, Some(token))) =>
      match token.kind() {
        @tokenizer.Identifier("I32") => ()
        _ => fail("expected field type")
      }
    _ => fail("expected missing variant field colon")
  }
  match
    Parser::from_bytes(b"enum Bad {\n  Data {\n    value:\n  }\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(Type, Some(token))) =>
      match token.kind() {
        @tokenizer.Newline => ()
        _ => fail("expected newline after missing field type")
      }
    _ => fail("expected missing variant field type")
  }
}

///|
test "enum variants and fields do not have visibility modifiers" {
  match
    Parser::from_bytes(b"pub enum Bad {\n  pub First\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(EnumVariantName, Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Pub) => ()
        _ => fail("expected pub variant modifier")
      }
    _ => fail("expected variant visibility modifier to fail")
  }
  match
    Parser::from_bytes(b"enum Bad {\n  Data {\n    pub value: I32\n  }\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(EnumVariantFieldName, Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Pub) => ()
        _ => fail("expected pub field modifier")
      }
    _ => fail("expected variant field visibility modifier to fail")
  }
}

///|
test "comments and blank lines preserve enum boundaries" {
  match
    Parser::from_bytes(
      b"enum Commented { // starts\n\n  // unit\n  First // ends\n\n  Data { // opens\n    // field\n    value: I32 // ends\n  } // variant ends\n}\n",
    ).parse_declaration() {
    Ok(Enum(declaration)) => assert_eq(declaration.variants.length(), 2)
    _ => fail("expected commented enum")
  }
}

///|
test "unclosed enums and struct-like variants retain offsets" {
  assert_eq(
    Parser::from_bytes(b"enum Open {\n").parse_declaration(),
    Err(UnclosedEnum(0UL)),
  )
  assert_eq(
    Parser::from_bytes(b"enum Open {\n  Data {\n").parse_declaration(),
    Err(UnclosedStructVariant(14UL)),
  )
}

///|
test "enum declarations require newline separation" {
  match
    Parser::from_bytes(b"enum First {} enum Second {}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(LineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Enum) => ()
        _ => fail("expected second enum keyword")
      }
    _ => fail("expected missing enum declaration newline")
  }
}

///|
test "large enum bodies parse iteratively by variant count" {
  match Parser::from_bytes(large_enum_declaration(1024)).parse_declaration() {
    Ok(Enum(declaration)) => {
      assert_eq(declaration.variants.length(), 1024)
      assert_eq(declaration.variants[0].name(), "Variant_0")
      assert_eq(declaration.variants[1023].name(), "Variant_1023")
    }
    _ => fail("expected large enum declaration")
  }
}
