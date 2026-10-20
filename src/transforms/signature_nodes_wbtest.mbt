///|
fn test_type_node(
  kind : String,
  name : String,
  arguments : Array[Value],
) -> Value {
  record("dewdrop.ast::TypeNode", [
    ("kind", Text(kind)),
    ("name", Text(name)),
    ("arguments", Sequence(arguments)),
  ])
}

///|
test "signature type renderer covers the complete parsed type shape" {
  let machine = builder_machine()
  let i32 = test_type_node("named", "I32", [])
  let boolean = test_type_node("named", "Bool", [])
  for
    (node, expected) in [
      (test_type_node("qualified", "@items.Payload", []), "@items.Payload"),
      (test_type_node("tuple", "", [i32, boolean]), "(I32, Bool)"),
      (
        test_type_node("applied", "", [
          test_type_node("named", "Array", []),
          i32,
        ]),
        "Array<I32>",
      ),
      (test_type_node("function", "", [i32, boolean]), "fn(I32) -> Bool"),
      (test_type_node("function", "", [boolean]), "fn() -> Bool"),
      (
        test_type_node("computed", "Member", [
          test_type_node("named", "Container", []),
        ]),
        "Container(\"Member\")",
      ),
    ] {
    assert_eq(machine.render_type(node, 0), expected)
  }
}

///|
test "signature type renderer rejects malformed node structure" {
  for
    node in [
      test_type_node("named", "I32; injected", []),
      test_type_node("tuple", "", []),
      test_type_node("tuple", "", [test_type_node("named", "I32", [])]),
      test_type_node("applied", "", []),
      test_type_node("function", "", []),
      test_type_node("computed", "x", []),
    ] {
    let machine = builder_machine()
    let rejected = try {
      let _ = machine.render_type(node, 0)
      false
    } catch {
      Failed(_) => true
      _ => false
    }
    assert_true(rejected)
  }
}

///|
test "signature source repair retains physical source identity through a wrapper" {
  let machine = builder_machine()
  let original = Variant("dewdrop.ast::ExprNode::Source", [
    Text("answer(40i32)"),
  ])
  let generated = Variant("dewdrop.ast::ExprNode::Source", [
    Text("answer(40i32)"),
  ])
  machine.render_source = original
  machine.render_replacement = "old_answer(40i32)"
  let wrapped = Variant("dewdrop.ast::ExprNode::Block", [
    Sequence([original, generated]),
  ])
  assert_eq(
    machine.render(wrapped, 0),
    "match () {\n_ => {\nold_answer(40i32)\nanswer(40i32)\n}\n}",
  )
}
