///|
test "expression type queries ignore unrelated search entries" {
  let mut expected_work = 0
  let mut expected_allocation = 0
  for padding in [0, 512] {
    let (machine, _) = bytecode_machine(
      "fn compute() -> I32 {\n 42i32\n}\n", false,
    )
    let function = machine.plan.files[0][0].functions[0]
    let type_ : ReflectedType = { kind: "named", name: "I32", arguments: [], }
    for _ in 0..<padding {
      machine.plan.add_expression_type(0, "main.dew", 0UL, "I32", type_)
    }
    machine.plan.add_expression_type(
      0,
      "main.dew",
      function.declaration.body.offset,
      "block",
      type_,
    )
    let before = machine.steps
    let allocated = machine.allocated
    let _ = machine.expression_type_nodes(function)
    if padding == 0 {
      expected_work = before - machine.steps
      expected_allocation = machine.allocated - allocated
    } else {
      assert_eq(before - machine.steps, expected_work)
      assert_eq(machine.allocated - allocated, expected_allocation)
    }
  }
}

///|
test "discard bindings evaluate once with the same block cost" {
  for enabled in [false, true] {
    let (machine, function) = bytecode_machine(
      "fn compute() -> I32 {\n let _ = 1i32\n 42i32\n}\n", enabled,
    )
    assert_eq(raw_bits(machine.source_call(0, 0, function, [])), 42UL)
    assert_eq(100000 - machine.steps, 6)
    assert_eq(machine.allocated, 96)
  }
}

///|
test "qualified unit patterns use one checked pattern event" {
  let (machine, _) = bytecode_machine(
    "fn compute() -> I32 {\n 42i32\n}\n", false,
  )
  let pattern = match @parser.Parser::from_bytes(b"Flag::Off").parse_pattern() {
    Ok(value) => value
    Err(_) => fail("qualified pattern fixture did not parse")
  }
  machine.plan.add_pattern_proof(
    0,
    "main.dew",
    pattern.offset(),
    "app::Flag::Off",
  )
  let before = machine.steps
  let allocated = machine.allocated
  assert_true(machine.pattern(0, pattern, Variant("app::Flag::Off", []), {}))
  assert_eq(before - machine.steps, 1)
  assert_eq(machine.allocated - allocated, 16)
}

///|
test "diagnostic metadata costs do not depend on message formatting" {
  let machine = builder_machine()
  machine.plan.set_reflection_error("short")
  let before = machine.steps
  let allocated = machine.allocated
  let _ = machine.reflection_errors()
  let work = before - machine.steps
  let allocation_work = machine.allocated - allocated
  machine.plan.reflection_errors.clear()
  machine.plan.set_reflection_error(
    "long diagnostic with a source location and detailed type names",
  )
  let before = machine.steps
  let allocated = machine.allocated
  let _ = machine.reflection_errors()
  assert_eq(before - machine.steps, work)
  assert_eq(machine.allocated - allocated, allocation_work)
}

///|
test "source calls have equal cold and warm resource costs" {
  for enabled in [false, true] {
    let (machine, _) = bytecode_machine(
      "fn compute(value: I32) -> I32 {\n value\n}\n", enabled,
    )
    assert_true(
      machine.call("app::compute", [Number(42UL, "I32")]) is Number(42UL, "I32"),
    )
    let cold_work = 100000 - machine.steps
    let cold_allocated = machine.allocated
    assert_eq(cold_work, 4)
    assert_eq(cold_allocated, 96)
    machine.steps = 100000
    machine.allocated = 0
    assert_true(
      machine.call("app::compute", [Number(42UL, "I32")]) is Number(42UL, "I32"),
    )
    assert_eq(100000 - machine.steps, cold_work)
    assert_eq(machine.allocated, cold_allocated)
  }
}

///|
test "failed resource charges keep counters within their bounds" {
  let machine = builder_machine()
  machine.steps = 0
  machine.allocated = 7
  try {
    machine.charge(100)
    fail("work exhaustion must fail")
  } catch {
    Failed(message) => assert_eq(message, "transform work limit exceeded")
    error => raise error
  }
  assert_eq(machine.steps, 0)
  assert_eq(machine.allocated, 7)
  machine.steps = 1
  machine.allocated = 4194303
  try {
    machine.charge(2)
    fail("allocation exhaustion must fail")
  } catch {
    Failed(message) => assert_eq(message, "transform allocation limit exceeded")
    error => raise error
  }
  assert_eq(machine.steps, 0)
  assert_eq(machine.allocated, 4194303)
}

///|
test "primitive arithmetic has one cost across execution paths" {
  for enabled in [false, true] {
    let (machine, function) = bytecode_machine(
      "fn compute() -> I32 {\n 40i32 + 2i32\n}\n", enabled,
    )
    if enabled {
      assert_true(machine.compile_bytecode(0, function) is Some(_))
    }
    assert_eq(raw_bits(machine.source_call(0, 0, function, [])), 42UL)
    assert_eq(100000 - machine.steps, 6)
    assert_eq(machine.allocated, 96)
  }
}

///|
test "raw reference field work does not depend on field position" {
  let machine = builder_machine()
  machine.plan.add_raw_layout(
    "fixture::View",
    "record:123",
    ["data", "begin", "size"],
    ["array:v128", "i32", "i32"],
  )
  let view = machine.reference_cast(ByteText(b"text"), "record:123")
  let before = machine.steps
  assert_eq(raw_bits(machine.read_field(view, "begin")), 0UL)
  let first = before - machine.steps
  let before = machine.steps
  assert_eq(raw_bits(machine.read_field(view, "size")), 4UL)
  assert_eq(before - machine.steps, first)
}

///|
test "raw text reads have cache independent UTF8 costs" {
  let machine = builder_machine()
  let value = Text("aλ🧪")
  for index in [0, 0, 2] {
    let work = machine.steps
    let allocation = machine.allocated
    let result = machine.raw_struct_get(value, index)
    if index == 2 {
      assert_eq(raw_bits(result), 7UL)
    }
    assert_eq(work - machine.steps, 1)
    assert_eq(machine.allocated - allocation, 23)
  }
  machine.steps = 0
  let allocated = machine.allocated
  try {
    let _ = machine.raw_struct_get(value, 0)
    fail("work limit must fail")
  } catch {
    Failed(message) => assert_eq(message, "transform work limit exceeded")
    error => raise error
  }
  assert_eq(machine.allocated, allocated)
  machine.steps = 1
  machine.allocated = 4194303
  try {
    let _ = machine.raw_struct_get(value, 0)
    fail("allocation limit must fail")
  } catch {
    Failed(message) => assert_eq(message, "transform allocation limit exceeded")
    error => raise error
  }
  assert_eq(machine.steps, 0)
  assert_eq(machine.allocated, 4194303)
}

///|
test "indexed view fields keep first duplicate position" {
  let names = field_names(["same", "a", "b", "c", "d", "e", "f", "g", "same"])
  assert_eq(names.position("same"), Some(0))
  assert_eq(names.position("g"), Some(7))
  assert_eq(names.position("missing"), None)
}

///|
test "failed array copy reads do not commit writes" {
  for steps in [1, 2, 3, 4] {
    let machine = builder_machine()
    let storage : RawStorage = {
      values: [DefaultValue, DefaultValue],
      default_kind: "unit-product:(u)",
    }
    let source = RawArray(storage)
    let target_storage : RawStorage = {
      values: [Number(7UL, "I32"), Number(8UL, "I32")],
      default_kind: "",
    }
    let target = RawArray(target_storage)
    machine.steps = steps
    try {
      let _ = machine.raw_array_copy(target, 0UL, source, 0UL, 2UL)
      fail("copy must hit work limit")
    } catch {
      Failed(message) => assert_eq(message, "transform work limit exceeded")
      error => raise error
    }
    assert_true(target_storage.values[0] is Number(7UL, "I32"))
    assert_true(target_storage.values[1] is Number(8UL, "I32"))
    assert_eq(machine.steps, 0)
  }
}

///|
test "raw array copy keeps overlapping source values" {
  let machine = builder_machine()
  let storage : RawStorage = {
    values: [Number(1UL, "I32"), Number(2UL, "I32"), Number(3UL, "I32")],
    default_kind: "I32",
  }
  let value = RawArray(storage)
  let before = machine.steps
  let _ = machine.raw_array_copy(value, 1UL, value, 0UL, 2UL)
  assert_eq(storage.values.map(raw_bits), [1UL, 1UL, 2UL])
  assert_eq(before - machine.steps, 3)
  assert_eq(machine.allocated, 32)
}

///|
test "adapter names use file order within the module" {
  let source = b"transform fn marker() -> I32 {\n 0i32\n}\n#marker\nfn answer() -> I32 {\n 42i32\n}\n"
  let padding = Array::makei(12, index => {
    path: index.to_string() + ".dew",
    source: b"",
  })
  let plan = prepare([
    { path: "padding", files: padding, },
    {
      path: "app",
      files: [
        { path: "first.dew", source: b"", },
        { path: "target.dew", source, },
      ],
    },
  ]).unwrap()
  let function = plan.files[1][1].functions[1]
  let machine = { ..builder_machine(), plan, }
  assert_eq(
    machine.adapter_name(function),
    "__dew_transform_adapter_1_" + function.start.to_string() + "_0",
  )
}

///|
test "plain matches have the same source event cost in both compilers" {
  for enabled in [false, true] {
    let (machine, function) = bytecode_machine(
      "fn compute() -> I32 {\n match 1i32 {\n  _ => 42i32\n }\n}\n", enabled,
    )
    assert_eq(raw_bits(machine.source_call(0, 0, function, [])), 42UL)
    assert_eq(100000 - machine.steps, 8)
    assert_eq(machine.allocated, 112)
  }
}
