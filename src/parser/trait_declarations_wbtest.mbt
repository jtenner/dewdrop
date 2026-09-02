///|
fn large_trait_declaration(method_count : Int) -> Bytes {
  let output = Buffer(size_hint=method_count * 40)
  output.write_string_utf8("trait Large {\n")
  for index in 0..<method_count {
    output.write_string_utf8("  fn method_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(value: I32) -> I32\n")
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
test "generic trait declarations preserve method signatures" {
  assert_eq(
    Parser::from_bytes(b"trait Add<t> {\n  fn add(left: t, right: t) -> t\n}\n").parse_declaration(),
    Ok(
      Trait({
        visibility: ModuleVisible,
        name: "Add",
        name_offset: 6UL,
        type_parameters: [{ name: "t", bounds: [], offset: 10UL, }],
        methods: [
          {
            name: "add",
            name_offset: 20UL,
            type_parameters: [],
            receiver: None,
            parameters: [
              { name: "left", type_: NamedType("t", 30UL), offset: 24UL, },
              { name: "right", type_: NamedType("t", 40UL), offset: 33UL, },
            ],
            return_type: NamedType("t", 46UL),
            offset: 17UL,
          },
        ],
        offset: 0UL,
      }),
    ),
  )
}

///|
test "public traits retain receiver and static methods" {
  let parser = Parser::from_bytes(
    b"pub trait Convert<t> {\n  fn convert(self) -> t\n  fn create(value: t) -> Self\n}\n",
  )
  match parser.parse_declaration() {
    Ok(Trait(declaration)) => {
      assert_eq(declaration.visibility, Public)
      assert_eq(declaration.name, "Convert")
      assert_eq(declaration.methods.length(), 2)
      assert_true(declaration.methods[0].has_receiver())
      assert_eq(
        declaration.methods[0].receiver,
        Some({ explicit_type: None, offset: 36UL, }),
      )
      assert_eq(declaration.methods[0].parameters.length(), 0)
      assert_false(declaration.methods[1].has_receiver())
      assert_eq(declaration.methods[1].parameters.length(), 1)
      assert_eq(declaration.methods[1].return_type, NamedType("Self", 72UL))
    }
    _ => fail("expected public trait declaration")
  }
}

///|
test "explicit self Self receiver syntax is accepted" {
  match
    Parser::from_bytes(
      b"trait Explicit {\n  fn use(self: Self, value: I32,) -> Unit\n}\n",
    ).parse_declaration() {
    Ok(Trait(declaration)) => {
      let parsed_method = declaration.methods[0]
      assert_eq(
        parsed_method.receiver,
        Some({ explicit_type: None, offset: 26UL, }),
      )
      assert_eq(parsed_method.parameters.length(), 1)
      assert_eq(parsed_method.parameters[0], {
        name: "value",
        type_: NamedType("I32", 45UL),
        offset: 38UL,
      })
    }
    _ => fail("expected explicit Self receiver")
  }
}

///|
test "receiver must be first and have Self type when explicit" {
  match
    Parser::from_bytes(b"trait Bad {\n  fn use(value: I32, self) -> Unit\n}\n").parse_declaration() {
    Err(ReceiverMustBeFirst(_)) => ()
    _ => fail("expected receiver-position error")
  }
  match
    Parser::from_bytes(b"trait Bad {\n  fn use(self: I32) -> Unit\n}\n").parse_declaration() {
    Err(InvalidReceiverType(NamedType("I32", _), _)) => ()
    _ => fail("expected receiver-type error")
  }
}

///|
test "zero-argument trait methods are static" {
  match
    Parser::from_bytes(b"trait Factory {\n  fn create() -> Self\n}\n").parse_declaration() {
    Ok(Trait(declaration)) => {
      assert_eq(declaration.methods[0].parameters.length(), 0)
      assert_false(declaration.methods[0].has_receiver())
    }
    _ => fail("expected static zero-argument method")
  }
}

///|
test "empty traits support compact and multiline bodies" {
  match Parser::from_bytes(b"trait Compact {}").parse_declaration() {
    Ok(Trait(declaration)) => assert_eq(declaration.methods.length(), 0)
    _ => fail("expected compact empty trait")
  }
  match Parser::from_bytes(b"trait Multiline {\n\n}\n").parse_declaration() {
    Ok(Trait(declaration)) => assert_eq(declaration.methods.length(), 0)
    _ => fail("expected multiline empty trait")
  }
}

///|
test "trait signatures allow newlines after commas" {
  match
    Parser::from_bytes(
      b"trait Combine<\n  left,\n  right,\n> {\n  fn combine(\n    first: left,\n    second: right,\n  ) -> left\n}\n",
    ).parse_declaration() {
    Ok(Trait(declaration)) => {
      assert_eq(declaration.type_parameters.length(), 2)
      assert_eq(declaration.methods[0].parameters.length(), 2)
    }
    _ => fail("expected multiline trait signature")
  }
}

///|
test "nonempty trait bodies begin and end members with newlines" {
  match
    Parser::from_bytes(b"trait SameLine { fn value() -> I32\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(TraitBodyNewline, Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Fn) => ()
        _ => fail("expected method keyword")
      }
    _ => fail("expected missing trait body newline")
  }
  match
    Parser::from_bytes(b"trait SameLine {\n  fn value() -> I32}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(LineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightBrace) => ()
        _ => fail("expected closing brace")
      }
    _ => fail("expected missing method newline")
  }
}

///|
test "trait comments preserve member newlines" {
  match
    Parser::from_bytes(
      b"trait Commented { // body starts\n  // before method\n  fn value() -> Unit // method ends\n  // before close\n}\n",
    ).parse_declaration() {
    Ok(Trait(declaration)) => assert_eq(declaration.methods.length(), 1)
    _ => fail("expected commented trait declaration")
  }
}

///|
test "trait methods require return types and accept method generics" {
  match
    Parser::from_bytes(b"trait Bad {\n  fn value()\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(Arrow, Some(token))) =>
      match token.kind() {
        @tokenizer.Newline => ()
        _ => fail("expected method newline")
      }
    _ => fail("expected missing method return type")
  }
  match
    Parser::from_bytes(
      b"trait Convert<t> {\n  fn convert<u: Eq>(self, value: u) -> u\n}\n",
    ).parse_declaration() {
    Ok(Trait(declaration)) => {
      let requirement = declaration.methods[0]
      assert_eq(requirement.type_parameters.length(), 1)
      assert_eq(requirement.type_parameters[0].name, "u")
      assert_eq(requirement.type_parameters[0].bounds, [NamedType("Eq", 35UL)])
      assert_eq(requirement.parameters.length(), 1)
      assert_true(requirement.has_receiver())
    }
    _ => fail("expected method-level generics to parse")
  }
  match
    Parser::from_bytes(b"trait Default {\n  fn value() -> I32 {\n  }\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(LineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftBrace) => ()
        _ => fail("expected default method body opener")
      }
    _ => fail("expected default method body to be rejected")
  }
}

///|
test "trait generic bounds are retained" {
  match
    Parser::from_bytes(
      b"trait Bounded<t: Eq> {\n  fn value(value: t) -> t\n}\n",
    ).parse_declaration() {
    Ok(Trait(declaration)) =>
      assert_eq(declaration.type_parameters[0].bounds, [NamedType("Eq", 17UL)])
    _ => fail("expected bounded trait declaration")
  }
}

///|
test "trait bodies contain method signatures only" {
  match
    Parser::from_bytes(b"trait Bad {\n  let value = 1\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(TraitMethodKeyword, Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Let) => ()
        _ => fail("expected let keyword")
      }
    _ => fail("expected non-method trait member to fail")
  }
}

///|
test "unclosed traits report their declaration offset" {
  assert_eq(
    Parser::from_bytes(b"trait Open {\n").parse_declaration(),
    Err(UnclosedTrait(0UL)),
  )
  assert_eq(
    Parser::from_bytes(b"trait Open {\n  fn value() -> I32\n").parse_declaration(),
    Err(UnclosedTrait(0UL)),
  )
}

///|
test "traits require newline separation from following declarations" {
  match
    Parser::from_bytes(b"trait First {} trait Second {}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(LineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Trait) => ()
        _ => fail("expected second trait keyword")
      }
    _ => fail("expected missing trait declaration newline")
  }
}

///|
test "large trait bodies parse iteratively by method count" {
  match Parser::from_bytes(large_trait_declaration(512)).parse_declaration() {
    Ok(Trait(declaration)) => {
      assert_eq(declaration.methods.length(), 512)
      assert_eq(declaration.methods[0].name, "method_0")
      assert_eq(declaration.methods[511].name, "method_511")
    }
    _ => fail("expected large trait declaration")
  }
}
