///|
fn builder_machine() -> Machine raise {
  {
    plan: fixture(""),
    steps: 100_000,
    depth: 0,
    allocated: 0,
    file_index: 0,
    frame: "",
    functions: {},
    imports: {},
    globals: {},
    initializing: {},
    text_storage: {},
    memory: None,
    bytecode_enabled: true,
    bytecode: {},
    bytecode_compile_work: 1048576,
    bytecode_bytes_left: 8388608,
  }
}

///|
test "syntax builders render paths fields calls tuples and wide values" {
  let m = builder_machine()
  let name = Variant("dewdrop.ast::ExprNode::Name", [Text("value")])
  let integer = Variant("dewdrop.ast::ExprNode::Integer", [Number(42UL, "I32")])
  for
    (node, expected) in [
      (Variant("dewdrop.ast::ExprNode::Unit", []), "()"),
      (
        Variant("dewdrop.ast::ExprNode::Integer64", [
          Number(18446744073709551615UL, "I64"),
        ]),
        "-1i64",
      ),
      (
        Variant("dewdrop.ast::ExprNode::Unsigned64", [
          Number(18446744073709551615UL, "U64"),
        ]),
        "18446744073709551615u64",
      ),
      (
        Variant("dewdrop.ast::ExprNode::Path", [Text("@tools.Value::make")]),
        "@tools.Value::make",
      ),
      (
        Variant("dewdrop.ast::ExprNode::Field", [name, Text("answer")]),
        "(value).answer",
      ),
      (
        Variant("dewdrop.ast::ExprNode::Index", [name, integer]),
        "(value)[42i32]",
      ),
      (
        Variant("dewdrop.ast::ExprNode::MethodCall", [
          name,
          Text("answer"),
          Sequence([integer]),
        ]),
        "(value).answer(42i32)",
      ),
      (
        Variant("dewdrop.ast::ExprNode::Prefix", [Text("-"), integer]),
        "-(42i32)",
      ),
      (
        Variant("dewdrop.ast::ExprNode::Array", [Sequence([integer])]),
        "[42i32]",
      ),
      (
        Variant("dewdrop.ast::ExprNode::Tuple", [Sequence([integer, integer])]),
        "(42i32, 42i32)",
      ),
      (
        Variant("dewdrop.ast::ExprNode::MutableBind", [Text("value"), integer]),
        "let mut value = 42i32",
      ),
      (
        Variant("dewdrop.ast::ExprNode::Assign", [name, integer]),
        "value = 42i32",
      ),
    ] {
    assert_eq(m.render(node, 0), expected)
  }
}

///|
test "syntax builders reject injected names paths and operators" {
  let m = builder_machine()
  let unit = Variant("dewdrop.ast::ExprNode::Unit", [])
  for
    node in [
      Variant("dewdrop.ast::ExprNode::Field", [unit, Text("x) + 1")]),
      Variant("dewdrop.ast::ExprNode::MethodCall", [
        unit,
        Text("f()"),
        Sequence([]),
      ]),
      Variant("dewdrop.ast::ExprNode::Path", [Text("@tools.f()")]),
      Variant("dewdrop.ast::ExprNode::Prefix", [Text("return"), unit]),
      Variant("dewdrop.ast::ExprNode::MutableBind", [Text("x\nfn bad"), unit]),
      Variant("dewdrop.ast::ExprNode::Tuple", [Sequence([unit])]),
    ] {
    try {
      let _ = m.render(node, 0)
      fail("invalid builder input must fail")
    } catch {
      Failed(message) => assert_true(message.length() > 0)
      _ => fail("expected a builder diagnostic")
    }
  }
}

///|
test "packed signed values extend before physical integer operations" {
  assert_eq(raw_bits(Number(255UL, "I8")), 18446744073709551615UL)
  assert_eq(raw_bits(Number(65535UL, "I16")), 18446744073709551615UL)
  assert_eq(raw_bits(Number(255UL, "U8")), 255UL)
  assert_eq(raw_bits(Number(65535UL, "U16")), 65535UL)
}
