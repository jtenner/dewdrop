///|
fn large_impl_declaration(method_count : Int) -> Bytes {
  let output = Buffer(size_hint=method_count * 56)
  output.write_string_utf8("impl Large {\n")
  for index in 0..<method_count {
    output.write_string_utf8("  fn method_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(self, value: I32) -> I32 {\n")
    output.write_string_utf8("    value\n")
    output.write_string_utf8("  }\n")
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
test "trait impl declarations preserve trait target and method bodies" {
  let parser = Parser::from_bytes(
    b"impl Into<I32> for I64 {\n  fn into(self) -> I32 {\n    @wasm.i64_trunc_i32(self)\n  }\n}\n",
  )
  match parser.parse_declaration() {
    Ok(Impl(declaration)) => {
      assert_false(declaration.foreign_)
      match declaration.trait_type {
        Some(AppliedType(NamedType("Into", _), arguments, _)) =>
          assert_eq(arguments[0], NamedType("I32", 10UL))
        _ => fail("expected applied Into trait")
      }
      assert_eq(declaration.target_type, NamedType("I64", 19UL))
      assert_eq(declaration.methods.length(), 1)
      assert_true(declaration.methods[0].has_receiver())
      match declaration.methods[0].body.items[0] {
        ExpressionItem(
          CallExpr(
            QualifiedExpr(ImportAliasExpr("wasm", _), "i64_trunc_i32", _),
            _,
            _
          ),
          _
        ) => ()
        _ => fail("expected intrinsic implementation body")
      }
    }
    _ => fail("expected trait implementation")
  }
}

///|
test "generic impls parse nested applied trait and target types" {
  match
    Parser::from_bytes(
      b"impl<a> Convert<List<a>> for Wrapper<List<a>> {\n  fn convert(self) -> List<a> {\n    self\n  }\n}\n",
    ).parse_declaration() {
    Ok(Impl(declaration)) => {
      assert_eq(declaration.type_parameters.length(), 1)
      match declaration.trait_type {
        Some(AppliedType(NamedType("Convert", _), arguments, _)) =>
          match arguments[0] {
            AppliedType(NamedType("List", _), _, _) => ()
            _ => fail("expected List trait argument")
          }
        _ => fail("expected generic trait application")
      }
      match declaration.target_type {
        AppliedType(NamedType("Wrapper", _), arguments, _) =>
          match arguments[0] {
            AppliedType(NamedType("List", _), _, _) => ()
            _ => fail("expected nested target argument")
          }
        _ => fail("expected generic target application")
      }
      assert_eq(
        declaration.methods[0].return_type,
        AppliedType(NamedType("List", 70UL), [NamedType("a", 75UL)], 74UL),
      )
    }
    _ => fail("expected generic implementation")
  }
}

///|
test "inherent impls omit the trait type" {
  match
    Parser::from_bytes(
      b"impl Counter {\n  fn increment(self: Counter) -> Counter {\n    self\n  }\n}\n",
    ).parse_declaration() {
    Ok(Impl(declaration)) => {
      assert_eq(declaration.trait_type, None)
      assert_eq(declaration.target_type, NamedType("Counter", 5UL))
      match declaration.methods[0].receiver {
        Some({ explicit_type: Some(NamedType("Counter", _)), .. }) => ()
        _ => fail("expected typed inherent receiver")
      }
    }
    _ => fail("expected inherent implementation")
  }
}

///|
test "foreign impls require an explicit trait and target" {
  match
    Parser::from_bytes(
      b"foreign impl Display for External {\n  fn display(self) -> String {\n    \"external\"\n  }\n}\n",
    ).parse_declaration() {
    Ok(Impl(declaration)) => {
      assert_true(declaration.foreign_)
      assert_eq(declaration.trait_type, Some(NamedType("Display", 13UL)))
      assert_eq(declaration.target_type, NamedType("External", 25UL))
    }
    _ => fail("expected foreign trait implementation")
  }
  assert_eq(
    Parser::from_bytes(b"foreign impl External {}\n").parse_declaration(),
    Err(ForeignImplRequiresTrait(0UL)),
  )
}

///|
test "impl declarations cannot be public" {
  assert_eq(
    Parser::from_bytes(b"pub impl Trait for Type {}\n").parse_declaration(),
    Err(PublicImplNotAllowed(0UL)),
  )
  assert_eq(
    Parser::from_bytes(b"pub foreign impl Trait for Type {}\n").parse_declaration(),
    Err(PublicImplNotAllowed(0UL)),
  )
}

///|
test "compact empty impl bodies are accepted" {
  match Parser::from_bytes(b"impl Marker {}").parse_declaration() {
    Ok(Impl(declaration)) => assert_eq(declaration.methods.length(), 0)
    _ => fail("expected compact empty inherent impl")
  }
  match
    Parser::from_bytes(b"impl MarkerTrait for Marker {}\n").parse_declaration() {
    Ok(Impl(declaration)) => assert_eq(declaration.methods.length(), 0)
    _ => fail("expected compact empty trait impl")
  }
}

///|
test "impl bodies contain ordinary fn declarations only" {
  match
    Parser::from_bytes(b"impl Bad {\n  let value = 1\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(ImplMemberKeyword, Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Let) => ()
        _ => fail("expected let keyword")
      }
    _ => fail("expected non-function impl member to fail")
  }
  match
    Parser::from_bytes(b"impl Bad {\n  pub fn value() -> Unit {}\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(ImplMemberKeyword, Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Pub) => ()
        _ => fail("expected pub keyword")
      }
    _ => fail("expected public impl method to fail")
  }
}

///|
test "nonempty impl bodies require a newline after their opener" {
  match
    Parser::from_bytes(b"impl SameLine { fn value() -> Unit {}\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(FunctionBodyNewline, Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Fn) => ()
        _ => fail("expected fn keyword")
      }
    _ => fail("expected impl body newline")
  }
}

///|
test "unclosed impls retain their declaration offset" {
  assert_eq(
    Parser::from_bytes(b"impl Open {\n").parse_declaration(),
    Err(UnclosedImpl(0UL)),
  )
  assert_eq(
    Parser::from_bytes(b"impl Open {\n  fn value() -> Unit {}\n").parse_declaration(),
    Err(UnclosedImpl(0UL)),
  )
}

///|
test "impl declarations require newline separation" {
  match
    Parser::from_bytes(b"impl First {} impl Second {}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(LineEnd, Some(token))) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Impl) => ()
        _ => fail("expected second impl keyword")
      }
    _ => fail("expected missing impl newline")
  }
}

///|
test "large impl bodies parse iteratively by method count" {
  match Parser::from_bytes(large_impl_declaration(256)).parse_declaration() {
    Ok(Impl(declaration)) => {
      assert_eq(declaration.methods.length(), 256)
      assert_eq(declaration.methods[0].name, "method_0")
      assert_eq(declaration.methods[255].name, "method_255")
      assert_true(declaration.methods[255].has_receiver())
    }
    _ => fail("expected large implementation")
  }
}
