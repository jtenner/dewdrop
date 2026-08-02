///|
test "test declarations preserve their display name and body" {
  match
    Parser::from_bytes(
      b"test \"string byte length\" {\n  assert(\"abc\".byte_length() == 3u32, \"wrong byte length\")\n}\n",
    ).parse_declaration() {
    Ok(Test(declaration)) => {
      assert_eq(declaration.name, b"string byte length")
      assert_eq(declaration.expected_trap, None)
      assert_eq(declaration.return_type, NamedType("Unit", 0UL))
      assert_eq(declaration.body.items.length(), 1)
    }
    _ => fail("expected test declaration")
  }
}

///|
test "test declarations preserve expected trap metadata" {
  match
    Parser::from_bytes(
      b"test \"division traps\" expect_trap \"integer-divide-by-zero\" {\n  1 / 0\n}\n",
    ).parse_declaration() {
    Ok(Test(declaration)) =>
      assert_eq(declaration.expected_trap, Some(b"integer-divide-by-zero"))
    _ => fail("expected test declaration with trap metadata")
  }
  match
    Parser::from_bytes(b"test \"missing trap\" expect_trap missing {\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(TestExpectedTrap, _)) => ()
    _ => fail("expected trap-name diagnostic")
  }
}

///|
test "test declarations require a string display name" {
  match Parser::from_bytes(b"test missing {\n}\n").parse_declaration() {
    Err(ExpectedDeclarationSyntax(TestName, _)) => ()
    _ => fail("expected test-name diagnostic")
  }
}
