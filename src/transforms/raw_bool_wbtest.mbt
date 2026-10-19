///|
test "checked raw Bool retains its i32 bits" {
  for bits in [0UL, 1UL, 42UL, 4294967295UL, 4294967296UL] {
    let value = intrinsic_kind(Number(bits, "I32"), "Bool")
    assert_eq(raw_bits(value), bits & 4294967295UL)
    assert_eq(truth(value), (bits & 4294967295UL) != 0UL)
    if bits <= 1UL {
      assert_true(value is Boolean(_))
    }
  }
}

///|
test "raw Bool pattern equality compares bits in either order" {
  for bits in [0UL, 1UL, 42UL, 4294967295UL] {
    let value = Number(bits, "Bool")
    assert_eq(equal(Boolean(true), value), bits == 1UL)
    assert_eq(equal(value, Boolean(true)), bits == 1UL)
    assert_eq(equal(Boolean(false), value), bits == 0UL)
    assert_eq(equal(value, Boolean(false)), bits == 0UL)
  }
}

///|
test "raw Bool short circuit and not agree in tree and bytecode" {
  for (expression, preserve, canonical) in [
    ("true && value", true, 0UL),
    ("false || value", true, 0UL),
    ("value && true", false, 1UL),
    ("value || false", false, 1UL),
    ("!value", false, 0UL),
  ] {
    let source = "fn compute(value: Bool) -> Bool {\n " + expression + "\n}\n"
    let (tree, tree_fn) = bytecode_machine(source, false)
    let (vm, vm_fn) = bytecode_machine(source, true)
    assert_true(vm.compile_bytecode(0, vm_fn) is Some(_))
    for bits in [0UL, 1UL, 42UL, 4294967295UL] {
      let expected = if preserve { bits } else if bits == 0UL {
        if expression == "!value" { 1UL } else { 0UL }
      } else { canonical }
      let left = tree.source_call(0, 0, tree_fn, [Number(bits, "Bool")])
      let right = vm.source_call(0, 0, vm_fn, [Number(bits, "Bool")])
      assert_eq(raw_bits(left), expected, msg=expression)
      assert_eq(raw_bits(right), expected, msg=expression)
      assert_eq(vm.steps, tree.steps)
      assert_eq(vm.allocated, tree.allocated)
      assert_eq(vm.depth, 0)
      assert_eq(tree.depth, 0)
    }
  }
}

///|
test "Boolean AST rendering accepts only checked Bool values" {
  let (machine, _) = bytecode_machine("fn compute() -> Bool {\n true\n}\n", true)
  for bits in [0UL, 1UL, 42UL, 4294967295UL] {
    let value = Variant("dewdrop.ast::ExprNode::Boolean", [Number(bits, "Bool")])
    assert_eq(machine.render(value, 0), if bits == 0UL { "false" } else { "true" })
  }
  try {
    let _ = machine.render(Variant("dewdrop.ast::ExprNode::Boolean", [Number(42UL, "I32")]), 0)
    fail("unchecked integer must not render as Bool")
  } catch {
    Failed(_) => ()
    _ => fail("unexpected Bool rendering error")
  }
}

///|
test "raw Bool operator shortcut retains the checked source body" {
  let source = "fn compute(value: Bool) -> Bool {\n true == value\n}\nfn checked_eq(left: Bool, right: Bool) -> Bool {\n if left {\n  right\n } else {\n  !right\n }\n}\n"
  let (tree, tree_fn) = bytecode_machine(source, false)
  let (vm, vm_fn) = bytecode_machine(source, true)
  for machine in [tree, vm] {
    let target = machine.plan.files[0][0].functions[1].declaration
    for token in @tokenizer.tokens(bytes(source)) {
      machine.plan.add_call_proof(0, "main.dew", token.offset(), 0, "main.dew", target.offset, result_kind="Bool")
    }
  }
  assert_true(vm.compile_bytecode(0, vm_fn) is Some(_))
  for bits in [0UL, 1UL, 42UL, 4294967295UL] {
    assert_eq(raw_bits(tree.source_call(0, 0, tree_fn, [Number(bits, "Bool")])), bits)
    assert_eq(raw_bits(vm.source_call(0, 0, vm_fn, [Number(bits, "Bool")])), bits)
    assert_eq(vm.steps, tree.steps)
    assert_eq(vm.allocated, tree.allocated)
  }
}
