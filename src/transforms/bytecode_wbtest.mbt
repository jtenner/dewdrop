///|
fn bytecode_machine(
  source : String,
  enabled : Bool,
) -> (Machine, @parser.FunctionDeclaration) raise {
  let plan = fixture(source + "\ntransform fn marker() -> Unit {\n}\n")
  // These isolated VM fixtures contain primitive operations and local bindings
  // only. Checked-source driver tests separately exercise semantic proof export.
  for token in @tokenizer.tokens(bytes(source)) {
    plan.add_scalar_proof(0, "main.dew", token.offset(), b"primitive")
    plan.add_pattern_proof(0, "main.dew", token.offset(), "")
  }
  let machine : Machine = {
    bytecode_enabled: enabled,
    bytecode: {},
    bytecode_compile_work: 1048576,
    bytecode_bytes_left: 8388608,
    plan,
    steps: 100000,
    depth: 0,
    allocated: 0,
    functions: {},
    imports: {},
    globals: {},
    initializing: {},
    file_index: 0,
    frame: "",
    text_storage: {},
    memory: None,
  }
  (machine, plan.files[0][0].functions[0].declaration)
}

///|
fn bytecode_compare(source : String, expected : UInt64) -> Unit raise {
  let (tree, tree_fn) = bytecode_machine(source, false)
  let (vm, vm_fn) = bytecode_machine(source, true)
  assert_true(vm.compile_bytecode(0, vm_fn) is Some(_))
  let left = tree.source_call(0, 0, tree_fn, [])
  let right = vm.source_call(0, 0, vm_fn, [])
  assert_eq(raw_bits(left), expected)
  assert_eq(raw_bits(right), expected)
  assert_eq(vm.steps, tree.steps)
  assert_eq(vm.allocated, tree.allocated)
  assert_eq(vm.depth, 0)
  assert_eq(tree.depth, 0)
}

///|
test "bytecode keeps lexical shadow slots and branch values" {
  bytecode_compare(
    "fn compute() -> I32 {\n let mut count = 20i32\n let nested = if true {\n  let count = 200i32\n  if count == 200i32 {\n   21i32\n  } else {\n   0i32\n  }\n } else {\n  0i32\n }\n count = count + 1i32\n count + nested\n}\n",
    42UL,
  )
}

///|
test "bytecode short circuit skips a trapping right operand" {
  bytecode_compare(
    "fn compute() -> I32 {\n if (false && 1i32 / 0i32 == 0i32) || (true || 1i32 / 0i32 == 1i32) {\n  42i32\n } else {\n  0i32\n }\n}\n",
    42UL,
  )
}

///|
test "bytecode return skips the rest of a nested expression" {
  bytecode_compare(
    "fn compute() -> I32 {\n let answer = 1i32 + if true {\n  return 42i32\n } else {\n  0i32\n }\n answer\n}\n",
    42UL,
  )
}

///|
test "bytecode functional loops keep nested break and continue targets" {
  bytecode_compare(
    "fn compute() -> I32 {\n let mut sum = 0i32\n let result = while 0i32 {\n  i if i < 3i32 => {\n   let inner = while 0i32 {\n    j if j < 2i32 => {\n     if j == 0i32 {\n      continue j + 1i32\n     }\n     break 7i32\n    }\n    _ => break 0i32\n   }\n   sum = sum + inner\n   continue i + 1i32\n  }\n  _ => break sum\n }\n result + sum\n}\n",
    42UL,
  )
}

///|
test "bytecode falls back for captured mutable cells" {
  let (machine, function) = bytecode_machine(
    "fn compute() -> I32 {\n let mut count = 40i32\n let increment = fn() -> I32 {\n  count = count + 1i32\n  count\n }\n let _ = increment()\n increment()\n}\n",
    true,
  )
  assert_true(machine.compile_bytecode(0, function) is None)
}

///|
test "bytecode work failures restore depth and retain diagnostic" {
  let (machine, function) = bytecode_machine(
    "fn compute() -> I32 {\n 42i32\n}\n", true,
  )
  let code = machine.compile_bytecode(0, function).unwrap()
  machine.steps = 2
  machine.depth = 7
  try {
    let _ = machine.run_bytecode(code, [])
    fail("bytecode work exhaustion must stay visible")
  } catch {
    Failed(message) => assert_eq(message, "transform work limit exceeded")
    _ => fail("unexpected bytecode limit error")
  }
  assert_eq(machine.depth, 7)
}

///|
test "bytecode preserves checked guard-break" {
  bytecode_compare(
    "fn compute() -> I32 {\n  while false {\n    _ if if true {\n      break 42i32\n    } else {\n      false\n    } => break 0i32\n    false => break 1i32\n    true => break 2i32\n  }\n}\n",
    42UL,
  )
}

///|
test "bytecode preserves checked guard-continue" {
  bytecode_compare(
    "fn compute() -> I32 {\n  while false {\n    state if if !state {\n      continue true\n    } else {\n      true\n    } => break 42i32\n    false => break 0i32\n    true => break 1i32\n  }\n}\n",
    42UL,
  )
}

///|
test "bytecode preserves checked initial-outer-break" {
  bytecode_compare(
    "fn compute() -> I32 {\n  while 0i32 {\n    _ => {\n      let _ = while if true {\n        break 42i32\n      } else {\n        0i32\n      } {\n        _ => break 0i32\n      }\n      break 1i32\n    }\n  }\n}\n",
    42UL,
  )
}

///|
test "bytecode failed entries and frame maps share the cache budget" {
  let (machine, function) = bytecode_machine(
    "fn compute() -> I32 {\n 42i32\n}\n", true,
  )
  machine.bytecode_bytes_left = 383
  assert_eq(raw_bits(machine.source_call(0, 0, function, [])), 42UL)
  assert_true(machine.bytecode.is_empty())
  assert_eq(machine.bytecode_bytes_left, 383)
  machine.bytecode_bytes_left = 384
  assert_eq(raw_bits(machine.source_call(0, 0, function, [])), 42UL)
  assert_eq(machine.bytecode_bytes_left, 0)
  assert_eq(machine.bytecode.length(), 1)
  assert_eq(machine.bytecode.get("").unwrap().length(), 1)
  let marker = machine.plan.files[0][0].functions[1].declaration
  let _ = machine.source_call(0, 0, marker, [])
  assert_eq(machine.bytecode.get("").unwrap().length(), 1)
}

///|
test "bytecode compile work exhaustion keeps the tree result" {
  let (machine, function) = bytecode_machine(
    "fn compute() -> I32 {\n 40i32 + 2i32\n}\n", true,
  )
  machine.bytecode_compile_work = 1
  assert_eq(raw_bits(machine.source_call(0, 0, function, [])), 42UL)
  assert_eq(machine.bytecode_compile_work, 0)
  assert_true(
    machine.bytecode.get("").unwrap().get((0, 0, function.offset.to_int()))
    is Some(None),
  )
}

///|
test "bytecode oversized local frames fall back as a whole" {
  let source = StringBuilder::new()
  source.write_string("fn compute() -> I32 {\n")
  for i in 0..<513 {
    source.write_string(" let local_")
    source.write_string(i.to_string())
    source.write_string(" = 0i32\n")
  }
  source.write_string(" 42i32\n}\n")
  let (machine, function) = bytecode_machine(source.to_string(), true)
  assert_true(machine.compile_bytecode(0, function) is None)
  assert_eq(raw_bits(machine.source_call(0, 0, function, [])), 42UL)
}

///|
fn bytecode_outcome(
  machine : Machine,
  function : @parser.FunctionDeclaration,
) -> String raise {
  try {
    let _ = machine.source_call(0, 0, function, [])
    "ok"
  } catch {
    Failed(message) => message
    _ => fail("unexpected bytecode boundary control flow")
  }
}

///|
test "bytecode and tree exact failure counters" {
  for
    source in [
      "fn compute() -> I32 {\n 42i32\n}\n", "fn compute() -> I32 {\n 1i32 / 0i32\n}\n",
      "fn compute() -> I32 {\n while false {\n false => break 42i32\n true => break 0i32\n }\n}\n",
    ] {
    let (tree, tree_fn) = bytecode_machine(source, false)
    let (vm, vm_fn) = bytecode_machine(source, true)
    assert_true(vm.compile_bytecode(0, vm_fn) is Some(_))
    for depth in [0, 126, 127, 128] {
      for budget in [0, 1, 2, 3, 4, 5, 6, 8, 12, 32, 100000] {
        for allocation in [0, 4194272, 4194304] {
          tree.depth = depth
          vm.depth = depth
          tree.steps = budget
          vm.steps = budget
          tree.allocated = allocation
          vm.allocated = allocation
          assert_eq(
            bytecode_outcome(vm, vm_fn),
            bytecode_outcome(tree, tree_fn),
          )
          assert_eq(vm.depth, depth)
          assert_eq(tree.depth, depth)
          assert_eq(vm.steps, tree.steps)
          assert_eq(vm.allocated, tree.allocated)
        }
      }
    }
  }
}
