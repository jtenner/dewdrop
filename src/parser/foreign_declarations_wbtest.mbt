///|
test "foreign types and linked namespaces parse" {
  match
    Parser::from_bytes(b"foreign type StarshineModule\n").parse_declaration() {
    Ok(ForeignType(value)) => {
      assert_eq(value.visibility, ModuleVisible)
      assert_eq(value.name, "StarshineModule")
    }
    _ => fail("expected foreign type declaration")
  }
  match
    Parser::from_bytes(
      b"foreign impl \"starshine\" as Starshine {\n  fn module_new() -> StarshineModule = \"module_new\"\n}\n",
    ).parse_declaration() {
    Ok(ForeignLibrary(value)) => {
      assert_eq(value.logical_name, b"starshine")
      assert_eq(value.namespace_alias, "Starshine")
      assert_eq(value.members.length(), 1)
      assert_eq(value.members[0].name, "module_new")
      assert_eq(value.members[0].export_name, b"module_new")
      assert_eq(value.members[0].parameters.length(), 0)
      assert_eq(
        value.members[0].return_type,
        NamedType("StarshineModule", 61UL),
      )
    }
    _ => fail("expected foreign library declaration")
  }
}

///|
test "public foreign types parse but public linked namespaces do not" {
  match
    Parser::from_bytes(b"pub foreign type StarshineModule\n").parse_declaration() {
    Ok(ForeignType(value)) => assert_eq(value.visibility, Public)
    _ => fail("expected public foreign type")
  }
  assert_eq(
    Parser::from_bytes(b"pub foreign impl \"starshine\" as Starshine {}\n").parse_declaration(),
    Err(PublicForeignLibraryNotAllowed(0UL)),
  )
}

///|
test "linked namespace members preserve exact parameters and symbols" {
  match
    Parser::from_bytes(
      b"foreign impl \"starshine\" as Starshine {\n  fn module_identity(value: StarshineModule) -> StarshineModule = \"module_identity\"\n  fn module_accept(value: StarshineModule) -> U32 = \"module_accept\"\n}\n",
    ).parse_declaration() {
    Ok(ForeignLibrary(value)) => {
      assert_eq(value.members.length(), 2)
      assert_eq(value.members[0].parameters[0].name, "value")
      assert_eq(value.members[1].export_name, b"module_accept")
    }
    _ => fail("expected linked namespace members")
  }
}

///|
test "linked namespace calls use ordinary qualification" {
  match
    Parser::from_bytes(
      b"fn use() -> StarshineModule {\n  Starshine::module_new()\n}\n",
    ).parse_declaration() {
    Ok(Function(value)) =>
      match value.body.items[0] {
        ExpressionItem(
          CallExpr(
            QualifiedExpr(NameExpr("Starshine", _), "module_new", _),
            [],
            _
          ),
          _
        ) => ()
        _ => fail("expected qualified linked namespace call")
      }
    _ => fail("expected function declaration")
  }
}

///|
test "foreign trait implementations keep their old syntax" {
  match
    Parser::from_bytes(
      b"foreign impl Display for External {\n  fn display(self) -> String {\n    \"external\"\n  }\n}\n",
    ).parse_declaration() {
    Ok(Impl(value)) => {
      assert_true(value.foreign_)
      assert_eq(value.trait_type, Some(NamedType("Display", 13UL)))
    }
    _ => fail("expected existing foreign trait implementation")
  }
}

///|
test "linked namespace syntax rejects unsupported member forms" {
  assert_true(
    Parser::from_bytes(
      b"foreign impl \"x\" as X {\n  pub fn f() -> U32 = \"f\"\n}\n",
    ).parse_declaration()
    is Err(PublicForeignLibraryMemberNotAllowed(_)),
  )
  assert_true(
    Parser::from_bytes(
      b"foreign impl \"x\" as X {\n  fn f<a>() -> U32 = \"f\"\n}\n",
    ).parse_declaration()
    is Err(GenericForeignLibraryMemberNotAllowed(_)),
  )
  assert_true(
    Parser::from_bytes(
      b"foreign impl \"x\" as X {\n  fn f(self: U32) -> U32 = \"f\"\n}\n",
    ).parse_declaration()
    is Err(ReceiverForeignLibraryMemberNotAllowed(_)),
  )
  assert_true(
    Parser::from_bytes(
      b"foreign impl \"x\" as X {\n  fn f() -> U32 {\n    1u32\n  }\n}\n",
    ).parse_declaration()
    is Err(ForeignLibraryMemberBodyNotAllowed(_)),
  )
}

///|
test "linked namespaces require as and export strings" {
  assert_true(
    Parser::from_bytes(b"foreign impl \"x\" X {}\n").parse_declaration()
    is Err(ExpectedDeclarationSyntax(ForeignLibraryAlias, _)),
  )
  assert_true(
    Parser::from_bytes(b"foreign impl \"x\" as X {\n  fn f() -> U32\n}\n").parse_declaration()
    is Err(ExpectedDeclarationSyntax(Equal, _)),
  )
  assert_true(
    Parser::from_bytes(
      b"foreign impl \"x\" as X {\n  fn f() -> U32 = value\n}\n",
    ).parse_declaration()
    is Err(ExpectedDeclarationSyntax(ForeignLibraryExportName, _)),
  )
}
