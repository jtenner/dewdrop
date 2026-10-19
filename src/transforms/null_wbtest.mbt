///|
test "raw defaults distinguish scalar zero from null reference" {
  assert_true(intrinsic_kind(DefaultValue, "nullable") is NullValue)
  assert_eq(raw_bits(intrinsic_kind(DefaultValue, "U32")), 0UL)
  assert_true(intrinsic_kind(DefaultValue, "Bool") is Boolean(false))
  assert_true(intrinsic_kind(DefaultValue, "F64") is Floating(0UL, "F64"))
  assert_true(intrinsic_kind(DefaultValue, "V128") is Vector(0UL, 0UL))
  assert_true(reference_is_null(NullValue))
  assert_true(reference_equal(NullValue, NullValue))
  assert_false(reference_equal(NullValue, Text("present")))
  for kind in ["record:1", "String", "array:U32"] {
    try {
      let _ = intrinsic_kind(DefaultValue, kind)
      fail("default non-null reference must trap")
    } catch {
      Failed(message) => assert_true(message.contains("null reference"))
      _ => fail("unexpected null error")
    }
  }
  try {
    let _ = reference_is_null(Number(0UL, "U32"))
    fail("integer zero is not a null reference")
  } catch {
    Failed(_) => ()
    _ => fail("unexpected null error")
  }
}

///|
test "validation preserves canonical type order after leading import file" {
  let plan = prepare([
    {
      path: "app",
      files: [
        { path: "app.dew", source: b"transform fn marker() -> Unit {}\n", },
      ],
    },
    {
      path: "dew.std.wasm.intrinsics",
      files: [
        { path: "imports.dew", source: b"", },
        {
          path: "types.dew",
          source: b"pub struct WasmArray<t> {}\npub struct NullableRef<t> {}\n",
        },
      ],
    },
  ]).unwrap()
  let names : Array[String] = []
  for file in plan.validation_sources()[1].files {
    for event in @parser.parse_bytes(file.source) {
      match event {
        @parser.Declaration(@parser.Struct(value)) => names.push(value.name)
        @parser.Declaration(@parser.Builtin(value)) => names.push(value.name)
        @parser.Diagnostic(_) => fail("validation source must parse")
        _ => ()
      }
    }
  }
  assert_eq(names[0], "WasmArray")
  assert_eq(names[1], "NullableRef")
  assert_eq(names.length(), 3)
}

///|
test "null tests require a proved reference for tuple values" {
  try {
    let _ = reference_null_test(Sequence([Number(1UL, "I32"), Number(2UL, "I32")]))
    fail("an unresolved tuple is not proof of one reference operand")
  } catch {
    Failed(message) => assert_true(message.contains("checked reference carrier"))
    _ => fail("unexpected tuple null-test error")
  }
  assert_false(reference_null_test(Function(Unsupported, [], FunctionInstance)))
  assert_true(reference_null_test(NullValue))
}
