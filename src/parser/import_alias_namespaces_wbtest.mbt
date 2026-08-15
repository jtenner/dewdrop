///|
test "import aliases qualify named and applied types" {
  match
    Parser::from_bytes(
      b"fn use(value: @model.Box<@text.Name>) -> @model.Box<I32> {\n  value\n}\n",
    ).parse_declaration() {
    Ok(Function(declaration)) => {
      match declaration.parameters[0].type_ {
        AppliedType(
          QualifiedType("model", "Box", 14UL, 21UL),
          [QualifiedType("text", "Name", 25UL, 31UL)],
          _
        ) => ()
        _ => fail("expected alias-qualified parameter type")
      }
      match declaration.return_type {
        AppliedType(
          QualifiedType("model", "Box", 41UL, 48UL),
          [NamedType("I32", _)],
          _
        ) => ()
        _ => fail("expected alias-qualified result type")
      }
    }
    _ => fail("expected function with alias-qualified types")
  }
}

///|
test "import aliases qualify trait bounds and implementation heads" {
  match
    Parser::from_bytes(
      b"impl<t: @contracts.Measure> @contracts.Measure for @model.Box<t> {\n}\n",
    ).parse_declaration() {
    Ok(Impl(declaration)) => {
      match declaration.type_parameters[0].bounds[0] {
        QualifiedType("contracts", "Measure", _, _) => ()
        _ => fail("expected alias-qualified generic bound")
      }
      match declaration.trait_type {
        Some(QualifiedType("contracts", "Measure", _, _)) => ()
        _ => fail("expected alias-qualified implementation trait")
      }
      match declaration.target_type {
        AppliedType(QualifiedType("model", "Box", _, _), [NamedType("t", _)], _) =>
          ()
        _ => fail("expected alias-qualified implementation target")
      }
    }
    _ => fail("expected alias-qualified implementation")
  }
}

///|
test "import aliases qualify enum constructors in expressions" {
  assert_eq(
    parse_test_expression(b"@messages.Message::Some(1)"),
    Ok(
      CallExpr(
        QualifiedExpr(
          QualifiedExpr(ImportAliasExpr("messages", 0UL), "Message", 9UL),
          "Some",
          17UL,
        ),
        [I32Expr(1UL, 24UL)],
        23UL,
      ),
    ),
  )
}

///|
test "import aliases qualify enum constructors in patterns" {
  match Parser::from_bytes(b"@messages.Message::Some(value)").parse_pattern() {
    Ok(
      TuplePattern(
        QualifiedPattern(
          QualifiedPattern(ImportAliasPattern("messages", 0UL), "Message", 9UL),
          "Some",
          17UL
        ),
        [BindingPattern("value", _)],
        _
      )
    ) => ()
    _ => fail("expected alias-qualified constructor pattern")
  }
}

///|
test "parse-event artifacts retain alias-qualified namespace syntax" {
  let events = parse_bytes(
    b"import app.model as @model\nfn read(value: @model.Box<I32>) -> I32 {\n  match @model.Message::Some(value.value) {\n    @model.Message::Some(item) => item\n  }\n}\n",
  ).to_array()
  let payload = serialize_parse_events(events).unwrap()
  assert_eq(deserialize_parse_events(payload).unwrap(), events)
  assert_eq(
    serialize_parse_events(deserialize_parse_events(payload).unwrap()).unwrap(),
    payload,
  )
}
