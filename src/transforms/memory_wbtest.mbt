///|
test "memory is lazy, bounded and charged before allocation" {
  let (machine, _) = bytecode_machine(
    "fn compute() -> I32 {\n 42i32\n}\n", true,
  )
  let load = memory_opcode("i32.load8_u").unwrap()
  assert_true(machine.memory is None)
  let last = machine.memory_instruction(load, [Number(65535UL, "U32")])
  assert_true(last is Number(0UL, "I32"))
  assert_eq(machine.allocated, 65536)
  let again = machine.memory_instruction(load, [Number(65535UL, "U32")])
  assert_true(again is Number(0UL, "I32"))
  assert_eq(machine.allocated, 65536)
  let (limited, _) = bytecode_machine(
    "fn compute() -> I32 {\n 42i32\n}\n", true,
  )
  limited.allocated = 4194304 - 65536 + 1
  try {
    let _ = limited.memory_instruction(load, [Number(0UL, "U32")])
    fail("memory allocation limit must fail")
  } catch {
    Failed(message) => assert_eq(message, "transform allocation limit exceeded")
    _ => fail("unexpected memory limit error")
  }
  assert_true(limited.memory is None)
}

///|
test "failed memory stores do not write bytes" {
  let (machine, _) = bytecode_machine(
    "fn compute() -> I32 {\n 42i32\n}\n", true,
  )
  let store = memory_opcode("i32.store").unwrap()
  let load = memory_opcode("i32.load").unwrap()
  let _ = machine.memory_instruction(store, [
    Number(65532UL, "U32"),
    Number(42UL, "U32"),
  ])
  for address in [65533UL, 65536UL, 4294967295UL, 18446744073709551615UL] {
    try {
      let _ = machine.memory_instruction(store, [
        Number(address, "U32"),
        Number(123UL, "U32"),
      ])
      fail("out of bounds store must fail")
    } catch {
      Failed(message) =>
        assert_eq(message, "Wasm memory access out of bounds at compile time")
      _ => fail("unexpected memory bounds error")
    }
    assert_true(
      machine.memory_instruction(load, [Number(65532UL, "U32")])
      is Number(42UL, "I32"),
    )
  }
  assert_true(memory_opcode("v128.load8_lane 16") is None)
  assert_true(memory_opcode("v128.load8_lane 01") is None)
  assert_true(memory_opcode("v128.store64_lane 2") is None)
  assert_true(memory_opcode("user.load") is None)
}

///|
test "memory carriers and arity are checked before allocation" {
  for
    args in [[], [Number(0UL, "I64")], [Number(0UL, "U32"), Number(1UL, "I32")]] {
    let (machine, _) = bytecode_machine(
      "fn compute() -> I32 {\n 42i32\n}\n", true,
    )
    try {
      let _ = machine.memory_instruction(
        memory_opcode("i32.load").unwrap(),
        args,
      )
      fail("invalid memory operands must fail")
    } catch {
      Failed(message) =>
        assert_eq(
          message,
          if args.length() == 1 {
            "Wasm memory address requires an i32 carrier"
          } else {
            "Wasm memory instruction argument count mismatch"
          },
        )
      _ => fail("unexpected memory carrier error")
    }
    assert_true(machine.memory is None)
  }
  let (machine, _) = bytecode_machine(
    "fn compute() -> I32 {\n 42i32\n}\n", true,
  )
  try {
    let _ = machine.memory_instruction(memory_opcode("f32.store").unwrap(), [
      Number(0UL, "U32"),
      Number(1UL, "I32"),
    ])
    fail("integer value cannot enter float store")
  } catch {
    Failed(message) =>
      assert_eq(message, "Wasm memory value has an incompatible carrier")
    _ => fail("unexpected memory carrier error")
  }
  assert_true(machine.memory is None)
}

///|
fn memory_boundary_case(
  opcode : String,
  width : Int32,
  extra : Value?,
) -> Unit raise {
  let (machine, _) = bytecode_machine(
    "fn compute() -> I32 {\n 42i32\n}\n", true,
  )
  let code = memory_opcode(opcode).unwrap()
  let args = [Number((65536 - width).to_uint64(), "U32")]
  if extra is Some(value) {
    args.push(value)
  }
  let _ = machine.memory_instruction(code, args)
  let memory = machine.memory.unwrap()
  let before = Array::makei(16, i => memory[65520 + i])
  if extra is Some(value) {
    args[1] = match value {
      Number(_, kind) => Number(0UL, kind)
      Floating(_, kind) => Floating(0UL, kind)
      Vector(_, _) => Vector(0UL, 0UL)
      _ => fail("invalid memory test value")
    }
  }
  for address in [(65537 - width).to_uint64(), 4294967295UL] {
    args[0] = Number(address, "U32")
    try {
      let _ = machine.memory_instruction(code, args)
      fail("out of bounds instruction must trap: " + opcode)
    } catch {
      Failed(message) =>
        assert_eq(message, "Wasm memory access out of bounds at compile time")
      _ => fail("unexpected memory boundary error")
    }
    for i in 0..<16 {
      assert_eq(memory[65520 + i], before[i])
    }
  }
}

///|
test "all memory instructions keep their exact page edge" {
  memory_boundary_case("i32.load", 4, None)
  memory_boundary_case("i32.load8_s", 1, None)
  memory_boundary_case("i32.load8_u", 1, None)
  memory_boundary_case("i32.load16_s", 2, None)
  memory_boundary_case("i32.load16_u", 2, None)
  memory_boundary_case("i64.load", 8, None)
  memory_boundary_case("f32.load", 4, None)
  memory_boundary_case("f64.load", 8, None)
  memory_boundary_case("i32.store", 4, Some(Number(287454020UL, "I32")))
  memory_boundary_case("i32.store8", 1, Some(Number(287454020UL, "I32")))
  memory_boundary_case("i32.store16", 2, Some(Number(287454020UL, "I32")))
  memory_boundary_case(
    "i64.store",
    8,
    Some(Number(1234605616436508552UL, "I64")),
  )
  memory_boundary_case("f32.store", 4, Some(Floating(287454020UL, "F32")))
  memory_boundary_case(
    "f64.store",
    8,
    Some(Floating(1234605616436508552UL, "F64")),
  )
  memory_boundary_case("v128.load", 16, None)
  memory_boundary_case(
    "v128.store",
    16,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case("v128.load8_splat", 1, None)
  memory_boundary_case(
    "v128.load8_lane 0",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 0",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load8_lane 1",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 1",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load8_lane 2",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 2",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load8_lane 3",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 3",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load8_lane 4",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 4",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load8_lane 5",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 5",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load8_lane 6",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 6",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load8_lane 7",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 7",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load8_lane 8",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 8",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load8_lane 9",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 9",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load8_lane 10",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 10",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load8_lane 11",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 11",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load8_lane 12",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 12",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load8_lane 13",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 13",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load8_lane 14",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 14",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load8_lane 15",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store8_lane 15",
    1,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case("v128.load16_splat", 2, None)
  memory_boundary_case(
    "v128.load16_lane 0",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store16_lane 0",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load16_lane 1",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store16_lane 1",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load16_lane 2",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store16_lane 2",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load16_lane 3",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store16_lane 3",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load16_lane 4",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store16_lane 4",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load16_lane 5",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store16_lane 5",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load16_lane 6",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store16_lane 6",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load16_lane 7",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store16_lane 7",
    2,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case("v128.load32_splat", 4, None)
  memory_boundary_case(
    "v128.load32_lane 0",
    4,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store32_lane 0",
    4,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load32_lane 1",
    4,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store32_lane 1",
    4,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load32_lane 2",
    4,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store32_lane 2",
    4,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load32_lane 3",
    4,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store32_lane 3",
    4,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case("v128.load64_splat", 8, None)
  memory_boundary_case(
    "v128.load64_lane 0",
    8,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store64_lane 0",
    8,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.load64_lane 1",
    8,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case(
    "v128.store64_lane 1",
    8,
    Some(Vector(578437695752307201UL, 1157159078456920585UL)),
  )
  memory_boundary_case("v128.load8x8_s", 8, None)
  memory_boundary_case("v128.load8x8_u", 8, None)
  memory_boundary_case("v128.load16x4_s", 8, None)
  memory_boundary_case("v128.load16x4_u", 8, None)
  memory_boundary_case("v128.load32x2_s", 8, None)
  memory_boundary_case("v128.load32x2_u", 8, None)
  memory_boundary_case("v128.load32_zero", 4, None)
  memory_boundary_case("v128.load64_zero", 8, None)
}
