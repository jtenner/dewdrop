///|
test "compile time flow removes calls and later operands after a Never argument" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nbuiltin stop() -> Never = \"unreachable\"\nfn later() -> I32 {\n  9i32\n}\nfn consume(left: I32, middle: I32, right: I32) -> I32 {\n  right\n}\npub fn main() -> I32 {\n  let _ = is_unit::<Unit>()\n  consume(1i32, stop(), later())\n}\n",
  )
  let module_ = lowering.modules[0]
  assert_eq(module_.diagnostics, [])
  let consume = program.modules[0].lookup_value("consume").unwrap()
  let later = program.modules[0].lookup_value("later").unwrap()
  let main = program.modules[0].lookup_value("main").unwrap()
  let body = program.modules[0].body_of(main).unwrap()
  for offset in 0..<body.expressions.length {
    let expression = module_.expressions[body.expressions.start + offset]
    if expression.kind is PlannedDirectCall(target, _, _, _) {
      assert_true(
        target != consume && target != later,
        msg="non-returning operand must remove the call and later evaluations",
      )
    }
  }
  let tail = optimization_test_body_tail(module_, body.id)
  assert_false(module_.expressions[tail].flow.may_fall_through())
  let count = module_.expression_children.length()
  prune_compile_time_branches(module_, Some(main))
  assert_eq(module_.expression_children.length(), count)
}

///|
test "compile time flow removes statements after a selected return" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nfn later() -> I32 {\n  9i32\n}\npub fn main() -> I32 {\n  if is_unit::<Unit>() {\n    return 7i32\n  } else {\n    ()\n  }\n  later()\n}\n",
  )
  let module_ = lowering.modules[0]
  assert_eq(module_.diagnostics, [])
  let later = program.modules[0].lookup_value("later").unwrap()
  let main = program.modules[0].lookup_value("main").unwrap()
  let body = program.modules[0].body_of(main).unwrap()
  for offset in 0..<body.expressions.length {
    let kind = module_.expressions[body.expressions.start + offset].kind
    assert_false(kind is PlannedDirectCall(target, _, _, _) && target == later)
  }
  let root = module_.bodies[semantic_id_local(body.id)].root
  if root is BlockBodyRoot(block) {
    assert_false(module_.blocks[block].flow.may_fall_through())
  } else {
    fail("test requires a block root")
  }
}
