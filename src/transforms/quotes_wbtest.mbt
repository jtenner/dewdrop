///|
fn quote_node(parts : Array[String], splices : Array[Value]) -> Value {
  Variant("dewdrop.ast::ExprNode::Quote", [
    Sequence(parts.map(fn(part) { Text(part) })),
    Sequence(splices),
  ])
}

///|
test "quotes splice expressions and keep local names away from target names" {
  let m = builder_machine()
  let result = m.render(
    quote_node(["let $saved = 2i32\n", " + $saved"], [
      Variant("dewdrop.ast::ExprNode::Source", [Text("__dew_quote_0")]),
    ]),
    0,
  )
  assert_true(result.contains("let __dew_quote_0_ = 2i32"))
  assert_true(result.contains("(__dew_quote_0) + __dew_quote_0_"))
}

///|
test "quote names in strings and comments stay unchanged" {
  let result = builder_machine().render(
    quote_node(["// $comment\nlet $saved = \"$text\"\n$saved"], []),
    0,
  )
  assert_true(result.contains("// $comment"))
  assert_true(result.contains("\"$text\""))
  assert_true(result.contains("let __dew_quote_0 ="))
}

///|
test "nested quotes have distinct local scopes and avoid capture" {
  let inner = quote_node(["let $x = 40i32\n$x"], [])
  let result = builder_machine().render(
    quote_node(["let $x = 2i32\n", " + $x"], [inner]),
    0,
  )
  assert_true(result.contains("let __dew_quote_0 = 40i32"))
  assert_true(result.contains("let __dew_quote_0_ = 2i32"))
}

///|
test "quotes reject part counts invalid local names and excessive shared text" {
  let giant = "x".repeat(900_000)
  for
    node in [
      quote_node([], []),
      quote_node(["$ 1i32"], []),
      quote_node([giant, giant], [Variant("dewdrop.ast::ExprNode::Unit", [])]),
    ] {
    try {
      let _ = builder_machine().render(node, 0)
      fail("invalid quote must fail")
    } catch {
      Failed(message) => assert_true(message.length() > 0)
      _ => fail("expected quote diagnostic")
    }
  }
}

///|
test "quotes reject splices inside strings comments and quote-local source" {
  let unit = Variant("dewdrop.ast::ExprNode::Integer", [Number(1UL, "I32")])
  for
    node in [
      quote_node(["\"prefix", "$text\""], [unit]),
      quote_node(["//", " $text\n42i32"], [unit]),
      quote_node(["", ""], [
        Variant("dewdrop.ast::ExprNode::Source", [Text("$local")]),
      ]),
    ] {
    try {
      let _ = builder_machine().render(node, 0)
      fail("invalid splice must fail")
    } catch {
      Failed(message) => assert_true(message.contains("quote"))
      _ => fail("expected quote diagnostic")
    }
  }
}
