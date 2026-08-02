///|
test "module preamble parses qualified and open imports" {
  let events = parse_bytes(
    b"open dew.std.preamble\nimport dew.std.map\nfn run() -> Unit {}\n",
  ).to_array()
  assert_eq(events.length(), 3)
  assert_eq(
    events[0],
    Declaration(
      Import({
        open_: true,
        path: ["dew", "std", "preamble"],
        wildcard: false,
        import_alias: None,
        import_alias_offset: 0UL,
        offset: 0UL,
      }),
    ),
  )
  assert_eq(
    events[1],
    Declaration(
      Import({
        open_: false,
        path: ["dew", "std", "map"],
        wildcard: false,
        import_alias: None,
        import_alias_offset: 22UL,
        offset: 22UL,
      }),
    ),
  )
  match events[2] {
    Declaration(Function({ name: "run", .. })) => ()
    _ => fail("expected function after imports")
  }
}

///|
test "module preamble parses terminal wildcard imports" {
  let events = parse_bytes(b"open dew.std.*\nfn run() -> Unit {}\n").to_array()
  assert_eq(events.length(), 2)
  assert_eq(
    events[0],
    Declaration(
      Import({
        open_: true,
        path: ["dew", "std"],
        wildcard: true,
        import_alias: None,
        import_alias_offset: 0UL,
        offset: 0UL,
      }),
    ),
  )
}

///|
test "imports parse explicit at aliases" {
  let events = parse_bytes(
    b"import my.lib as @custom\nfn run() -> Unit {\n  @custom.my_func()\n}\n",
  ).to_array()
  assert_eq(events.length(), 2)
  assert_eq(
    events[0],
    Declaration(
      Import({
        open_: false,
        path: ["my", "lib"],
        wildcard: false,
        import_alias: Some("custom"),
        import_alias_offset: 17UL,
        offset: 0UL,
      }),
    ),
  )
}

///|
test "open imports reject aliases" {
  let events = parse_bytes(b"open my.lib as @custom\n").to_array()
  assert_eq(events.length(), 1)
  match events[0] {
    Diagnostic({ error: ExpectedDeclarationSyntax(ImportAlias, _), .. }) => ()
    _ => fail("expected open-import alias diagnostic")
  }
}

///|
test "qualified imports reject wildcards" {
  let events = parse_bytes(b"import my.*\n").to_array()
  assert_eq(events.length(), 1)
  match events[0] {
    Diagnostic({ error: ExpectedDeclarationSyntax(ImportWildcard, _), .. }) =>
      ()
    _ => fail("expected qualified-import wildcard diagnostic")
  }
}

///|
test "wildcard aliases are rejected" {
  let events = parse_bytes(b"import my.* as @custom\n").to_array()
  assert_eq(events.length(), 1)
  match events[0] {
    Diagnostic({ error: ExpectedDeclarationSyntax(ImportAlias, _), .. }) => ()
    _ => fail("expected wildcard import-alias diagnostic")
  }
}

///|
test "wildcard must terminate an import path" {
  let events = parse_bytes(b"open dew.std.*.string\n").to_array()
  assert_eq(events.length(), 1)
  match events[0] {
    Diagnostic({ error: ExpectedDeclarationSyntax(LineEnd, _), .. }) => ()
    _ => fail("expected terminal-wildcard diagnostic")
  }
}

///|
test "imports are rejected after the first ordinary declaration" {
  let events = parse_bytes(
    b"fn run() -> Unit {}\nopen dew.std.map\ntype Value = I32\n",
  ).to_array()
  assert_eq(events.length(), 3)
  match events[1] {
    Diagnostic({ error: ImportAfterDeclaration(20UL), .. }) => ()
    _ => fail("expected late-import diagnostic")
  }
  match events[2] {
    Declaration(TypeAlias({ name: "Value", .. })) => ()
    _ => fail("expected declaration after late import")
  }
}

///|
test "removed global keyword is not an open declaration" {
  let events = parse_bytes(b"global fn run() -> Unit {}\n").to_array()
  assert_eq(events.length(), 1)
  match events[0] {
    Diagnostic({ error: ExpectedDeclarationSyntax(DeclarationKeyword, _), .. }) =>
      ()
    _ => fail("expected removed-global diagnostic")
  }
}
