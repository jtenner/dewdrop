///|
fn syntax_test_body(source : String) -> @parser.Block raise {
  for
    event in @parser.parse_bytes(
      bytes("fn sample() -> I32 {\n" + source + "\n}\n"),
    ) {
    match event {
      @parser.Declaration(@parser.Function(value)) => return value.body
      @parser.Diagnostic(error) =>
        fail("syntax test parse error: " + error.error.offset().to_string())
      _ => ()
    }
  }
  fail("syntax test expected a function")
}

///|
test "original syntax tree keeps block order and operator labels" {
  let m = builder_machine()
  let tree = m.syntax_block(
    syntax_test_body("let answer = 40i32\nanswer + 2i32"),
    0,
  )
  assert_eq(string(field(tree, "kind")), "block")
  let items = m.sequence_values(field(tree, "children"))
  assert_eq(items.length(), 2)
  assert_eq(string(field(items[0], "kind")), "bind")
  assert_eq(string(field(items[0], "label")), "answer")
  assert_eq(string(field(items[1], "kind")), "binary")
  assert_eq(string(field(items[1], "label")), "+")
  assert_true(raw_bits(field(items[1], "offset")) > 0UL)
}

///|
test "syntax reflection handles patterns and raw bytes without lossy text" {
  let m = builder_machine()
  let tree = m.syntax_block(
    syntax_test_body(
      "match input {\n Box {\n value: x\n ...\n } => x\n}\nb\"\\xff\\x00\"",
    ),
    0,
  )
  let items = m.sequence_values(field(tree, "children"))
  let match_children = m.sequence_values(field(items[0], "children"))
  let arm_children = m.sequence_values(field(match_children[1], "children"))
  assert_eq(string(field(arm_children[0], "kind")), "pattern_record")
  assert_eq(m.sequence_values(field(arm_children[0], "children")).length(), 3)
  let values = m.sequence_values(field(items[1], "children"))
  assert_eq(string(field(values[0], "label")), "255")
  assert_eq(string(field(values[1], "label")), "0")
}

///|
test "syntax reflection bounds recursive source trees" {
  let m = builder_machine()
  let body = syntax_test_body("-".repeat(129) + "1i32")
  try {
    let _ = m.syntax_block(body, 0)
    fail("deep syntax must fail")
  } catch {
    Failed(message) => assert_true(message.contains("syntax tree depth limit"))
    _ => fail("expected syntax depth diagnostic")
  }
}
