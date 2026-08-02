///|
fn nested_recovery_module(declaration_count : Int) -> Bytes {
  let output = Buffer(size_hint=declaration_count * 140)
  for index in 0..<declaration_count {
    output.write_string_utf8("fn Broken_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(
      "() -> Unit {\n  if ready {\n    match state {\n      _ => malformed +\n    }\n  }\n}\ntype Alias_",
    )
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = I32\n")
  }
  output.to_bytes()
}

///|
fn deeply_grouped_recovery_module(group_count : Int) -> Bytes {
  let output = Buffer(size_hint=group_count * 2 + 96)
  output.write_string_utf8("fn Broken() -> Unit {\n  let value = ")
  for _ in 0..<group_count {
    output.write_byte(b'(')
  }
  output.write_string_utf8("value +")
  for _ in 0..<group_count {
    output.write_byte(b')')
  }
  output.write_string_utf8("\n}\ntype After = I32\n")
  output.to_bytes()
}

///|
test "module event streams preserve declaration order and blank lines" {
  let events = parse_bytes(
    b"\n\ntype UserId = U64\n\nstruct Point {\n  x: I32\n}\n\nenum Option<t> {\n  None\n  Some(t)\n}\n",
  ).to_array()
  assert_eq(events.length(), 3)
  match events[0] {
    Declaration(TypeAlias(declaration)) => assert_eq(declaration.name, "UserId")
    _ => fail("expected type alias event")
  }
  match events[1] {
    Declaration(Struct(declaration)) => assert_eq(declaration.name, "Point")
    _ => fail("expected struct event")
  }
  match events[2] {
    Declaration(Enum(declaration)) => assert_eq(declaration.name, "Option")
    _ => fail("expected enum event")
  }
}

///|
test "module streams emit diagnostics and recover at declaration lines" {
  let events = parse_bytes(
    b"type First = I32\nnot a declaration\ntype Second = I64\n",
  ).to_array()
  assert_eq(events.length(), 3)
  match events[0] {
    Declaration(TypeAlias(declaration)) => assert_eq(declaration.name, "First")
    _ => fail("expected first alias")
  }
  match events[1] {
    Diagnostic(diagnostic) => {
      assert_eq(diagnostic.severity, Error)
      match diagnostic.error {
        ExpectedDeclarationSyntax(DeclarationKeyword, Some(token)) =>
          match token.kind() {
            @tokenizer.Identifier("not") => ()
            _ => fail("expected malformed declaration identifier")
          }
        _ => fail("expected declaration-keyword diagnostic")
      }
    }
    _ => fail("expected interleaved diagnostic")
  }
  match events[2] {
    Declaration(TypeAlias(declaration)) => assert_eq(declaration.name, "Second")
    _ => fail("expected recovered alias")
  }
}

///|
test "module recovery skips malformed declaration body remainder" {
  let events = parse_bytes(
    b"struct Broken {\n  value I32\n  ignored: I64\n}\ntype After = Bool\n",
  ).to_array()
  assert_eq(events.length(), 2)
  match events[0] {
    Diagnostic(diagnostic) =>
      match diagnostic.error {
        ExpectedDeclarationSyntax(Colon, Some(token)) =>
          match token.kind() {
            @tokenizer.Identifier("I32") => ()
            _ => fail("expected malformed field type")
          }
        _ => fail("expected missing field colon")
      }
    _ => fail("expected malformed struct diagnostic")
  }
  match events[1] {
    Declaration(TypeAlias(declaration)) => assert_eq(declaration.name, "After")
    _ => fail("expected declaration after malformed struct")
  }
}

///|
test "module recovery skips nested trait methods" {
  let events = parse_bytes(
    b"trait Broken {\n  fn missing_arrow() I32\n  fn nested() -> I32\n}\ntype After = Bool\n",
  ).to_array()
  assert_eq(events.length(), 2)
  match events[0] {
    Diagnostic({ error: ExpectedDeclarationSyntax(Arrow, _), .. }) => ()
    _ => fail("expected malformed trait method diagnostic")
  }
  match events[1] {
    Declaration(TypeAlias({ name: "After", .. })) => ()
    _ => fail("expected alias after malformed trait")
  }
}

///|
test "module recovery skips nested impl methods" {
  let events = parse_bytes(
    b"impl Value {\n  fn broken(self) -> Unit {\n    let value =\n  }\n  fn nested(self) -> Unit {}\n}\ntype After = Bool\n",
  ).to_array()
  assert_eq(events.length(), 2)
  match events[0] {
    Diagnostic({ error: DeclarationExpressionError(ExpectedValue(_)), .. }) =>
      ()
    _ => fail("expected malformed impl method diagnostic")
  }
  match events[1] {
    Declaration(TypeAlias({ name: "After", .. })) => ()
    _ => fail("expected alias after malformed impl")
  }
}

///|
test "module recovery crosses nested function control flow" {
  let events = parse_bytes(
    b"fn broken() -> Unit {\n  if ready {\n    match state {\n      _ => malformed +\n    }\n  }\n  let local = 1\n}\ntype After = Bool\n",
  ).to_array()
  assert_eq(events.length(), 2)
  match events[0] {
    Diagnostic({ error: DeclarationExpressionError(ExpectedValue(_)), .. }) =>
      ()
    _ => fail("expected nested expression diagnostic")
  }
  match events[1] {
    Declaration(TypeAlias({ name: "After", .. })) => ()
    _ => fail("expected alias after malformed function")
  }
}

///|
test "module recovery preserves nested pattern delimiters" {
  let events = parse_bytes(
    b"fn broken() -> Unit {\n  let value = match state {\n    Some(first second) => first\n    _ => fallback\n  }\n}\ntype After = Bool\n",
  ).to_array()
  assert_eq(events.length(), 2)
  match events[0] {
    Diagnostic(
      {
        error: DeclarationExpressionError(
          MatchPatternError(ExpectedPatternDelimiter(_, _))
        ),
        ..,
      }
    ) => ()
    _ => fail("expected nested pattern delimiter diagnostic")
  }
  match events[1] {
    Declaration(TypeAlias({ name: "After", .. })) => ()
    _ => fail("expected alias after malformed nested pattern")
  }
}

///|
test "module recovery crosses malformed functional while arms" {
  let events = parse_bytes(
    b"fn broken() -> Unit {\n  let value = while state {\n    State::Next(next) => continue\n    _ => break 0\n  }\n}\ntype After = Bool\n",
  ).to_array()
  assert_eq(events.length(), 2)
  match events[0] {
    Diagnostic(
      { error: DeclarationExpressionError(ExpectedContinueValue(_, _)), .. }
    ) => ()
    _ => fail("expected missing continue value diagnostic")
  }
  match events[1] {
    Declaration(TypeAlias({ name: "After", .. })) => ()
    _ => fail("expected alias after malformed functional while")
  }
}

///|
test "module recovery crosses enum struct variant bodies" {
  let events = parse_bytes(
    b"enum Broken {\n  Data {\n    value I32\n  }\n  Other\n}\ntype After = Bool\n",
  ).to_array()
  assert_eq(events.length(), 2)
  match events[0] {
    Diagnostic({ error: ExpectedDeclarationSyntax(Colon, _), .. }) => ()
    _ => fail("expected malformed enum field diagnostic")
  }
  match events[1] {
    Declaration(TypeAlias({ name: "After", .. })) => ()
    _ => fail("expected alias after malformed enum")
  }
}

///|
test "module recovery respects multiline parameter fences" {
  let events = parse_bytes(
    b"fn broken(\n  value I32\n) -> Unit {}\ntype After = Bool\n",
  ).to_array()
  assert_eq(events.length(), 2)
  match events[0] {
    Diagnostic({ error: ExpectedDeclarationSyntax(Colon, _), .. }) => ()
    _ => fail("expected malformed parameter diagnostic")
  }
  match events[1] {
    Declaration(TypeAlias({ name: "After", .. })) => ()
    _ => fail("expected alias after malformed parameter list")
  }
}

///|
test "module recovery respects generic and grouping fences" {
  let events = parse_bytes(
    b"type Broken<\n  value,\n  =\n> = I32\nlet grouped = (\n  value +\n)\ntype After = Bool\n",
  ).to_array()
  assert_eq(events.length(), 3)
  match events[0] {
    Diagnostic({ error: ExpectedDeclarationSyntax(TypeParameter, _), .. }) => ()
    _ => fail("expected malformed generic parameter diagnostic")
  }
  match events[1] {
    Diagnostic({ error: DeclarationExpressionError(ExpectedValue(_)), .. }) =>
      ()
    _ => fail("expected malformed grouped expression diagnostic")
  }
  match events[2] {
    Declaration(TypeAlias({ name: "After", .. })) => ()
    _ => fail("expected alias after generic and group recovery")
  }
}

///|
test "closed declaration line errors do not retain body fences" {
  let events = parse_bytes(b"trait Broken {} extra\ntype After = Bool\n").to_array()
  assert_eq(events.length(), 2)
  match events[0] {
    Diagnostic({ error: ExpectedDeclarationSyntax(LineEnd, _), .. }) => ()
    _ => fail("expected trailing trait token diagnostic")
  }
  match events[1] {
    Declaration(TypeAlias({ name: "After", .. })) => ()
    _ => fail("expected alias after closed trait line error")
  }
}

///|
test "module recovery respects call and index fences" {
  let events = parse_bytes(
    b"let first = call(\n  value +\n)\nlet second = values[\n  index +\n]\ntype After = Bool\n",
  ).to_array()
  assert_eq(events.length(), 3)
  match events[0] {
    Diagnostic({ error: DeclarationExpressionError(ExpectedValue(_)), .. }) =>
      ()
    _ => fail("expected malformed call diagnostic")
  }
  match events[1] {
    Diagnostic({ error: DeclarationExpressionError(ExpectedValue(_)), .. }) =>
      ()
    _ => fail("expected malformed index diagnostic")
  }
  match events[2] {
    Declaration(TypeAlias({ name: "After", .. })) => ()
    _ => fail("expected alias after delimiter failures")
  }
}

///|
test "unclosed declaration recovery conservatively reaches eof" {
  let events = parse_bytes(
    b"fn broken() -> Unit {\n  malformed +\ntype Uncertain = I32\n",
  ).to_array()
  assert_eq(events.length(), 1)
  match events[0] {
    Diagnostic(_) => ()
    _ => fail("expected one unclosed declaration diagnostic")
  }
}

///|
test "deep delimiter recovery remains iterative" {
  let events = parse_bytes(deeply_grouped_recovery_module(1024)).to_array()
  assert_eq(events.length(), 2)
  match events[0] {
    Diagnostic({ error: DeclarationExpressionError(ExpectedValue(_)), .. }) =>
      ()
    _ => fail("expected deeply grouped recovery diagnostic")
  }
  match events[1] {
    Declaration(TypeAlias({ name: "After", .. })) => ()
    _ => fail("expected alias after deep delimiter recovery")
  }
}

///|
test "nested declaration recovery remains iterative at scale" {
  let events = parse_bytes(nested_recovery_module(256)).to_array()
  assert_eq(events.length(), 512)
  for index in 0..<256 {
    match events[index * 2] {
      Diagnostic({ error: DeclarationExpressionError(ExpectedValue(_)), .. }) =>
        ()
      _ => fail("expected nested recovery diagnostic")
    }
    match events[index * 2 + 1] {
      Declaration(TypeAlias(declaration)) =>
        assert_eq(declaration.name, "Alias_" + index.to_string())
      _ => fail("expected alias after nested recovery diagnostic")
    }
  }
}

///|
test "module streams expose lexical failures as diagnostics" {
  let source : Bytes = [
    0xFF, 0x0A, 0x74, 0x79, 0x70, 0x65, 0x20, 0x41, 0x20, 0x3D, 0x20, 0x49, 0x33,
    0x32, 0x0A,
  ]
  let events = parse_bytes(source).to_array()
  assert_eq(events.length(), 2)
  match events[0] {
    Diagnostic(diagnostic) =>
      match diagnostic.error {
        DeclarationLexicalError(_, 0UL) => ()
        _ => fail("expected lexical declaration diagnostic")
      }
    _ => fail("expected lexical diagnostic event")
  }
  match events[1] {
    Declaration(TypeAlias(declaration)) => assert_eq(declaration.name, "A")
    _ => fail("expected alias after lexical failure")
  }
}

///|
test "module event iteration remains lazy" {
  let parser = Parser::from_bytes(b"type First = I32\ntype Second = I64\n")
  let events = parser.parse_events()
  match events.next() {
    Some(Declaration(TypeAlias(declaration))) =>
      assert_eq(declaration.name, "First")
    _ => fail("expected first lazy event")
  }
  match parser.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Type) => ()
        _ => fail("expected unconsumed second declaration")
      }
    None => fail("expected second declaration token")
  }
  match events.next() {
    Some(Declaration(TypeAlias(declaration))) =>
      assert_eq(declaration.name, "Second")
    _ => fail("expected second lazy event")
  }
  assert_eq(events.next(), None)
}

///|
test "module token-stream entry point matches byte entry point" {
  let source = b"type Alias = I32\n"
  assert_eq(
    parse(@tokenizer.tokens(source)).to_array(),
    parse_bytes(source).to_array(),
  )
}

///|
test "module streams do not diagnose blank input or final newlines" {
  assert_eq(parse_bytes(b"").to_array(), [])
  assert_eq(parse_bytes(b"\n\n\n").to_array(), [])
}

///|
test "diagnostic severity ordering is stable" {
  assert_eq(Error.rank(), 0)
  assert_eq(Warning.rank(), 1)
  assert_eq(Info.rank(), 2)
  assert_eq(Hint.rank(), 3)
}
