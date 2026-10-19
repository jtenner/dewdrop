///|
test "raw text casts retain identity and use checked field order" {
  let machine = builder_machine()
  machine.plan.add_raw_layout(
    "fixture::View",
    "record:123",
    ["data", "begin", "size"],
    ["array:v128", "i32", "i32"],
  )
  let original = Text("aλ🧪")
  let view = machine.reference_cast(original, "record:123")
  assert_true(reference_equal(original, view))
  assert_true(reference_equal(original, machine.reference_cast(view, "String")))
  assert_eq(raw_bits(machine.read_field(view, "begin")), 0UL)
  assert_eq(raw_bits(machine.read_field(view, "size")), 7UL)
  let backing = machine.read_field(view, "data")
  assert_true(reference_equal(backing, machine.read_field(view, "data")))
  assert_eq(machine.text_storage.length(), 1)
  machine.plan.add_raw_layout("fixture::Wrong", "record:124", ["only"], ["i32"])
  try {
    let _ = machine.reference_cast(original, "record:124")
    fail("incompatible reference casts must fail")
  } catch {
    Failed(message) => assert_true(message.contains("heap type mismatch"))
    _ => fail("unexpected cast failure")
  }
}

///|
test "byte vector intrinsics preserve lanes and masks" {
  let original = vector_intrinsic("i8x16.splat", [Number(128UL, "U8")])
  assert_eq(raw_bits(vector_intrinsic("i8x16.bitmask", [original])), 65535UL)
  let changed = vector_intrinsic("i8x16.replace_lane 15", [
    original,
    Number(7UL, "U8"),
  ])
  assert_eq(vector_byte(changed, 15), 7UL)
  assert_eq(vector_byte(original, 15), 128UL)
  let equal = vector_intrinsic("i8x16.eq", [original, changed])
  assert_eq(raw_bits(vector_intrinsic("i8x16.bitmask", [equal])), 32767UL)
  let invalid = vector_intrinsic("i8x16.splat", [Number(16UL, "U8")])
  let zero = vector_intrinsic("i8x16.swizzle", [original, invalid])
  assert_eq(vector_byte(zero, 0), 0UL)
  assert_eq(
    raw_bits(vector_intrinsic("i8x16.extract_lane_u 15", [changed])),
    7UL,
  )
}

///|
test "raw text casts reject mutable and different nested storage" {
  for
    storage in [
      ["mut:array:v128", "i32", "i32"],
      ["array:i32", "i32", "i32"],
      ["record:999", "i32", "i32"],
      ["unsupported", "i32", "i32"],
    ] {
    let machine = builder_machine()
    machine.plan.add_raw_layout(
      "fixture::Wrong",
      "record:124",
      ["data", "begin", "size"],
      storage,
    )
    try {
      let _ = machine.reference_cast(Text("text"), "record:124")
      fail("incompatible nested or mutable field must fail")
    } catch {
      Failed(message) => assert_true(message.contains("heap type mismatch"))
      _ => fail("unexpected cast failure")
    }
  }
}

///|
test "text backing lookup keeps linear work and tuple identity" {
  let machine = builder_machine()
  let before = machine.steps
  for _ in 0..<500 {
    let _ = machine.raw_struct_get(Text("same text"), 0)
  }
  let first = before - machine.steps
  let before = machine.steps
  for _ in 0..<500 {
    let _ = machine.raw_struct_get(Text("same text"), 0)
  }
  let second = before - machine.steps
  assert_eq(machine.text_storage.length(), 1)
  assert_true(second <= first)
  let values = [Number(1UL, "I32")]
  assert_true(reference_equal(Sequence(values), Sequence(values)))
  assert_false(
    reference_equal(Sequence(values), Sequence([Number(1UL, "I32")])),
  )
}

///|
test "function and closure reference identity uses the stored instance" {
  let function = Function(Unsupported, [], FunctionInstance)
  assert_true(reference_equal(function, function))
  assert_false(
    reference_equal(function, Function(Unsupported, [], FunctionInstance)),
  )
  let body = syntax_test_body("0i32")
  let closure = Closure(0, 0, [], body, {}, "")
  assert_true(reference_equal(closure, closure))
  assert_false(reference_equal(closure, Closure(0, 0, [], body, {}, "")))
  assert_false(reference_equal(function, closure))
  assert_false(reference_is_null(function))
  assert_false(reference_is_null(closure))
}

///|
test "checked named functions use declaration singletons and defer generic ABI identity" {
  let first = Function(Unsupported, [], FunctionSingleton(123UL))
  let second = Function(Unsupported, [], FunctionSingleton(123UL))
  assert_true(reference_equal(first, second))
  assert_false(
    reference_equal(first, Function(Unsupported, [], FunctionSingleton(124UL))),
  )
  let generic = Function(Unsupported, [], GenericFunctionSingleton(125UL))
  assert_true(reference_equal(generic, generic))
  try {
    let _ = reference_equal(
      generic,
      Function(Unsupported, [], GenericFunctionSingleton(125UL)),
    )
    fail("different generic reference expressions need exact ABI identity")
  } catch {
    Failed(message) => assert_true(message.contains("checked ABI identity"))
    _ => fail("unexpected generic function identity error")
  }
}

///|
test "generic function singleton identity includes checked specialization" {
  let first = Function(Unsupported, [], FunctionSpecialization(123UL, 0U))
  let same = Function(Unsupported, [], FunctionSpecialization(123UL, 0U))
  let other = Function(Unsupported, [], FunctionSpecialization(123UL, 1U))
  assert_true(reference_equal(first, same))
  assert_false(reference_equal(first, other))
  assert_false(
    reference_equal(
      first,
      Function(Unsupported, [], FunctionSpecialization(124UL, 0U)),
    ),
  )
  assert_false(
    reference_equal(first, Function(Unsupported, [], FunctionSingleton(123UL))),
  )
}

///|
test "generic identity with a missing proof remains diagnostic" {
  let first = Function(Unsupported, [], FunctionSpecialization(123UL, 0U))
  let missing = Function(Unsupported, [], GenericFunctionSingleton(123UL))
  try reference_equal(first, missing) catch {
    Failed(message) => assert_true(message.contains("checked ABI identity"))
    _ => fail("unexpected generic identity failure")
  } noraise {
    _ => fail("missing generic proof must report its limit")
  }
}
