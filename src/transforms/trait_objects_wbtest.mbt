///|
fn trait_bytecode_fixture(
  enabled : Bool,
) -> (Machine, @parser.FunctionDeclaration) raise {
  let (machine, compute) = bytecode_machine(
    "fn compute(value: I32) -> I32 {\n read(value)\n}\nfn read(value: Answer) -> I32 {\n value.answer()\n}\ntrait Answer {\n fn answer(self) -> I32\n}\nimpl Answer for I32 {\n fn answer(self) -> I32 {\n self + 2i32\n }\n}\n",
    enabled,
  )
  let file = machine.plan.files[0][0]
  let mut read : @parser.FunctionDeclaration? = None
  let mut method_ : @parser.FunctionDeclaration? = None
  for declaration in file.declarations {
    match declaration {
      @parser.Function(function) if function.name == "read" =>
        read = Some(function)
      @parser.Impl(impl_) => method_ = Some(impl_.methods[0])
      _ => ()
    }
  }
  let read = read.unwrap()
  guard compute.body.tail_expression()
    is Some(@parser.CallExpr(_, arguments, offset)) else {
    fail("compute call is missing")
  }
  machine.plan.add_call_proof(0, "main.dew", offset, 0, "main.dew", read.offset)
  machine.plan.add_trait_object_proof(
    0,
    "main.dew",
    arguments[0].offset(),
    12UL,
    [
      {
        requirement: 123UL,
        slot: 0,
        module_index: 0,
        path: "main.dew",
        offset: method_.unwrap().offset,
        frame: "",
      },
    ],
  )
  guard read.body.tail_expression() is Some(@parser.CallExpr(_, _, offset)) else {
    fail("dynamic call is missing")
  }
  machine.plan.add_call_proof(
    0,
    "main.dew",
    offset,
    -8,
    "main.dew",
    123UL,
    constructor_key="12:0",
    result_kind="I32",
  )
  (machine, compute)
}

///|
test "dynamic trait bytecode and tree keep the same work and allocation charges" {
  let (tree, tree_fn) = trait_bytecode_fixture(false)
  let (vm, vm_fn) = trait_bytecode_fixture(true)
  assert_true(vm.compile_bytecode(0, vm_fn) is Some(_))
  assert_eq(
    raw_bits(tree.source_call(0, 0, tree_fn, [Number(40UL, "I32")])),
    42UL,
  )
  assert_eq(raw_bits(vm.source_call(0, 0, vm_fn, [Number(40UL, "I32")])), 42UL)
  assert_eq(tree.steps, vm.steps)
  assert_eq(tree.allocated, vm.allocated)
  assert_eq(tree.depth, 0)
  assert_eq(vm.depth, 0)
}

///|
test "dynamic trait values keep envelope identity and reject a wrong slot" {
  let machine = builder_machine()
  let receiver = Record("counter", { "value": Number(0UL, "I32") })
  let proof = TraitObjectProof::{ methods: { 123UL: ("12:0", Unsupported) }, }
  let first = machine.trait_object(receiver, proof)
  let second = machine.trait_object(receiver, proof)
  assert_true(reference_equal(first, first))
  assert_false(reference_equal(first, second))
  assert_false(reference_equal(first, receiver))
  assert_false(reference_is_null(first))
  try {
    let _ = machine.dynamic_trait_call(123UL, "12:1", "I32", [first])
    fail("a wrong checked slot must fail")
  } catch {
    Failed(message) =>
      assert_eq(message, "checked dynamic trait method slot mismatch")
    _ => fail("unexpected trait slot failure")
  }
}
