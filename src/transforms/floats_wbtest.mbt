///|
test "floating-point operations preserve Wasm rounding and signed zero" {
  fn f(value : Double) -> Value {
    float_result(value, "F64")
  }
  assert_true(equal(float_intrinsic("f64.nearest", [f(2.5)]), f(2.0)))
  assert_true(equal(float_intrinsic("f64.nearest", [f(3.5)]), f(4.0)))
  assert_true(equal(float_intrinsic("f64.nearest", [f(-2.5)]), f(-2.0)))
  assert_true(
    float_intrinsic("f64.nearest", [f(-0.5)])
    is Floating(9223372036854775808UL, "F64"),
  )
  assert_true(
    float_intrinsic("f64.min", [f(0.0), f(-0.0)])
    is Floating(9223372036854775808UL, "F64"),
  )
  assert_true(
    float_intrinsic("f64.max", [f(-0.0), f(0.0)]) is Floating(0UL, "F64"),
  )
  assert_true(
    float_intrinsic("f64.div", [f(0.0), f(0.0)])
    is Floating(9221120237041090560UL, "F64"),
  )
  assert_true(
    float_intrinsic("f64.eq", [f(0.0 / 0.0), f(0.0 / 0.0)]) is Boolean(false),
  )
  let rounded = float_intrinsic("f32.add", [
    float_result(16777216.0, "F32"),
    float_result(1.0, "F32"),
  ])
  assert_true(equal(rounded, float_result(16777216.0, "F32")))
}

///|
test "float conversions trap before invalid host conversions" {
  assert_eq(
    raw_bits(float_intrinsic("i32.trunc_f64_u", [float_result(-0.75, "F64")])),
    0UL,
  )
  assert_eq(
    raw_bits(
      float_intrinsic("i64.trunc_f64_u", [
        float_result(9223372036854775808.0, "F64"),
      ]),
    ),
    9223372036854775808UL,
  )
  assert_eq(
    raw_bits(
      float_intrinsic("i64.trunc_sat_f64_u", [
        float_result(18446744073709551616.0, "F64"),
      ]),
    ),
    18446744073709551615UL,
  )
  for value in [2147483648.0, -2147483649.0, 0.0 / 0.0] {
    try {
      let _ = float_intrinsic("i32.trunc_f64_s", [float_result(value, "F64")])
      fail("out-of-range conversion must fail")
    } catch {
      Failed(message) => assert_true(message.contains("conversion trap"))
      _ => fail("unexpected float error")
    }
  }
  try {
    let _ = raw_bits(float_result(1.0, "F64"))
    fail("float must not use integer carrier")
  } catch {
    Failed(_) => ()
    _ => fail("unexpected carrier error")
  }
}

///|
test "checked primitive float operator uses float execution" {
  let machine = builder_machine()
  machine.plan.scalar_proofs[(0, 0, 7)] = b"primitive"
  let events = @parser.parse_bytes(
    b"fn calculate() -> F64 {\n6.0f64 * 7.0f64\n}\n",
  ).collect()
  guard events is [@parser.Declaration(@parser.Function(function))] else {
    abort("float regression lost its parsed function")
  }
  let op = match function.body.items[0] {
    @parser.ExpressionItem(@parser.BinaryExpr(op, _, _, _), _) => op
    _ => abort("float regression lost its parsed binary expression")
  }
  let value = machine.scalar_binary(
    0,
    7UL,
    op,
    float_result(6.0, "F64"),
    float_result(7.0, "F64"),
  )
  assert_true(equal(value, float_result(42.0, "F64")))
}
