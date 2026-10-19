///|
test "instruction contracts reject bad scalar input and result widths" {
  let machine = builder_machine()
  machine.plan.add_intrinsic_contract(b"i32.add", ["i32", "i32"], "i32")
  for (args, result) in [
    ([Number(1UL, "I32"), Number(2UL, "I32")], "String"),
    ([Number(1UL, "I32"), Number(2UL, "I32")], "I64"),
    ([Number(1UL, "I32"), Number(2UL, "I32")], "Unit"),
    ([Number(1UL, "I64"), Number(2UL, "I64")], "I32"),
  ] {
    try {
      machine.check_intrinsic_contract("i32.add", args, result)
      fail("invalid intrinsic carriers must fail before result coercion")
    } catch {
      Failed(message) => assert_true(message.contains("carrier mismatch"))
      _ => fail("unexpected instruction contract error")
    }
  }
  machine.check_intrinsic_contract("i32.add", [Number(1UL, "I8"), Number(2UL, "U32")], "Bool")
  machine.check_intrinsic_contract("i32.add", [DefaultValue, DefaultValue], "I32")
  try {
    machine.check_intrinsic_contract("i32.add", [Number(1UL, "I32"), Number(2UL, "I32")], "")
    fail("generic scalar results must have positive checked carrier evidence")
  } catch {
    Failed(message) => assert_true(message.contains("concrete checked carrier"))
    _ => fail("unexpected deferred result error")
  }
}

///|
test "checked results reject omitted opcode results and numeric width changes" {
  let result = float_intrinsic("f64.min", [float_result(1.0, "F64"), float_result(2.0, "F64")])
  for (value, kind) in [(result, "String"), (Number(1UL, "I64"), "I32")] {
    try {
      let _ = intrinsic_kind(value, kind)
      fail("checked result coercion must not change its Wasm carrier")
    } catch {
      Failed(message) => assert_true(message.contains("incompatible Wasm carrier"))
      _ => fail("unexpected final carrier error")
    }
  }
  assert_true(intrinsic_kind(Number(1UL, "I8"), "Bool") is Boolean(true))
}

///|
test "instruction contracts check float vector and reference result carriers" {
  let machine = builder_machine()
  for (opcode, inputs, result, args) in [
    (b"f64.add", ["f64", "f64"], "f64", [float_result(1.0, "F64"), float_result(2.0, "F64")]),
    (b"i64x2.splat", ["i64"], "v128", [Number(1UL, "I64")]),
    (b"ref.eq", ["ref", "ref"], "i32", [Text("left"), Text("right")]),
  ] {
    machine.plan.add_intrinsic_contract(opcode, inputs, result)
    try {
      machine.check_intrinsic_contract(text(opcode), args, "String")
      fail("wrong checked result must fail even when ignored")
    } catch {
      Failed(message) => assert_true(message.contains("result carrier mismatch"))
      _ => fail("unexpected instruction result error")
    }
  }
}

///|
test "struct.get contract uses checked field storage" {
  let machine = builder_machine()
  machine.plan.add_raw_layout("fixture::Box", "record:123", ["value"], ["i32"])
  let value = Record("fixture::Box", Map::from_array([("value", Number(1UL, "I32"))]))
  machine.check_intrinsic_contract("struct.get 0", [value], "U32")
  for result in ["String", "I64"] {
    try {
      machine.check_intrinsic_contract("struct.get 0", [value], result)
      fail("struct.get must retain its field carrier")
    } catch {
      Failed(message) => assert_true(message.contains("checked field"))
      _ => fail("unexpected struct.get contract error")
    }
  }
  machine.plan.add_raw_layout("fixture::Chunks", "record:124", ["data"], ["array:v128"])
  let chunks = Record("fixture::Chunks", Map::from_array([("data", RawArray({ values: [], default_kind: "V128", }))]))
  machine.check_intrinsic_contract("struct.get 0", [chunks], "array:V128")
  try {
    machine.check_intrinsic_contract("struct.get 0", [chunks], "array:I32")
    fail("reference fields must retain their checked element storage")
  } catch {
    Failed(message) => assert_true(message.contains("checked field"))
    _ => fail("unexpected reference field error")
  }
}
