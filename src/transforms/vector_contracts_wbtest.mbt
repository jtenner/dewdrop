///|
test "vector contract rejects names absent from the exact Wasm catalog" {
  try {
    let _ = vector_intrinsic("i8x16.mul", [Vector(0UL, 0UL)])
    fail("a missing Wasm instruction must not execute")
  } catch {
    Failed(message) =>
      assert_true(message.contains("unsupported Wasm vector"), msg=message)
    _ => fail("unexpected vector contract error")
  }
  try {
    let _ = vector_intrinsic("i64x2.popcnt", [Vector(0UL, 0UL)])
    fail("a missing Wasm instruction must not execute")
  } catch {
    Failed(message) =>
      assert_true(message.contains("unsupported Wasm vector"), msg=message)
    _ => fail("unexpected vector contract error")
  }
  try {
    let _ = vector_intrinsic("f32x4.copysign", [Vector(0UL, 0UL)])
    fail("a missing Wasm instruction must not execute")
  } catch {
    Failed(message) =>
      assert_true(message.contains("unsupported Wasm vector"), msg=message)
    _ => fail("unexpected vector contract error")
  }
  try {
    let _ = vector_intrinsic("i32x4.extract_lane_s 0", [Vector(0UL, 0UL)])
    fail("a missing Wasm instruction must not execute")
  } catch {
    Failed(message) =>
      assert_true(message.contains("unsupported Wasm vector"), msg=message)
    _ => fail("unexpected vector contract error")
  }
  try {
    let _ = vector_intrinsic("i8x16.narrow_bad", [Vector(0UL, 0UL)])
    fail("a missing Wasm instruction must not execute")
  } catch {
    Failed(message) =>
      assert_true(message.contains("unsupported Wasm vector"), msg=message)
    _ => fail("unexpected vector contract error")
  }
  try {
    let _ = vector_intrinsic("i8x16.extract_lane_u 00", [Vector(0UL, 0UL)])
    fail("a missing Wasm instruction must not execute")
  } catch {
    Failed(message) =>
      assert_true(message.contains("unsupported Wasm vector"), msg=message)
    _ => fail("unexpected vector contract error")
  }
  try {
    let _ = vector_intrinsic("v128.load", [Vector(0UL, 0UL)])
    fail("a missing Wasm instruction must not execute")
  } catch {
    Failed(message) =>
      assert_true(message.contains("unsupported Wasm vector"), msg=message)
    _ => fail("unexpected vector contract error")
  }
}

///|
test "vector contract checks argument count before operand access" {
  try {
    let _ = vector_intrinsic("i8x16.narrow_i16x8_s", [Vector(0UL, 0UL)])
    fail("wrong vector argument count must fail")
  } catch {
    Failed(message) =>
      assert_true(message.contains("argument count mismatch"), msg=message)
    _ => fail("unexpected vector argument error")
  }
  try {
    let _ = vector_intrinsic("i16x8.extmul_low_i8x16_u", [Vector(0UL, 0UL)])
    fail("wrong vector argument count must fail")
  } catch {
    Failed(message) =>
      assert_true(message.contains("argument count mismatch"), msg=message)
    _ => fail("unexpected vector argument error")
  }
  try {
    let _ = vector_intrinsic("i8x16.replace_lane 0", [Vector(0UL, 0UL)])
    fail("wrong vector argument count must fail")
  } catch {
    Failed(message) =>
      assert_true(message.contains("argument count mismatch"), msg=message)
    _ => fail("unexpected vector argument error")
  }
  try {
    let _ = vector_intrinsic("v128.bitselect", [Vector(0UL, 0UL)])
    fail("wrong vector argument count must fail")
  } catch {
    Failed(message) =>
      assert_true(message.contains("argument count mismatch"), msg=message)
    _ => fail("unexpected vector argument error")
  }
  try {
    let _ = vector_intrinsic(
      "i8x16.shuffle 31 0 30 1 29 2 28 3 27 4 26 5 25 6 24 7",
      [Vector(0UL, 0UL)],
    )
    fail("wrong vector argument count must fail")
  } catch {
    Failed(message) =>
      assert_true(message.contains("argument count mismatch"), msg=message)
    _ => fail("unexpected vector argument error")
  }
}

///|
test "vector shuffle uses canonical decimal selectors" {
  try {
    let _ = vector_intrinsic(
      "i8x16.shuffle 01 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15",
      [Vector(0UL, 0UL), Vector(0UL, 0UL)],
    )
    fail("bad shuffle text must fail before execution")
  } catch {
    Failed(message) =>
      assert_true(message.contains("invalid Wasm vector shuffle"), msg=message)
    _ => fail("unexpected shuffle grammar error")
  }
  try {
    let _ = vector_intrinsic(
      "i8x16.shuffle 32 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15",
      [Vector(0UL, 0UL), Vector(0UL, 0UL)],
    )
    fail("bad shuffle text must fail before execution")
  } catch {
    Failed(message) =>
      assert_true(message.contains("invalid Wasm vector shuffle"), msg=message)
    _ => fail("unexpected shuffle grammar error")
  }
  try {
    let _ = vector_intrinsic(
      "i8x16.shuffle -1 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15",
      [Vector(0UL, 0UL), Vector(0UL, 0UL)],
    )
    fail("bad shuffle text must fail before execution")
  } catch {
    Failed(message) =>
      assert_true(message.contains("invalid Wasm vector shuffle"), msg=message)
    _ => fail("unexpected shuffle grammar error")
  }
  try {
    let _ = vector_intrinsic(
      "i8x16.shuffle 0  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15",
      [Vector(0UL, 0UL), Vector(0UL, 0UL)],
    )
    fail("bad shuffle text must fail before execution")
  } catch {
    Failed(message) =>
      assert_true(message.contains("invalid Wasm vector shuffle"), msg=message)
    _ => fail("unexpected shuffle grammar error")
  }
  try {
    let _ = vector_intrinsic(
      "i8x16.shuffle 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 ",
      [Vector(0UL, 0UL), Vector(0UL, 0UL)],
    )
    fail("bad shuffle text must fail before execution")
  } catch {
    Failed(message) =>
      assert_true(message.contains("invalid Wasm vector shuffle"), msg=message)
    _ => fail("unexpected shuffle grammar error")
  }
  try {
    let _ = vector_intrinsic(
      "i8x16.shuffle 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 0",
      [Vector(0UL, 0UL), Vector(0UL, 0UL)],
    )
    fail("bad shuffle text must fail before execution")
  } catch {
    Failed(message) =>
      assert_true(message.contains("invalid Wasm vector shuffle"), msg=message)
    _ => fail("unexpected shuffle grammar error")
  }
  try {
    let _ = vector_intrinsic(
      "i8x16.shuffle 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14",
      [Vector(0UL, 0UL), Vector(0UL, 0UL)],
    )
    fail("bad shuffle text must fail before execution")
  } catch {
    Failed(message) =>
      assert_true(message.contains("invalid Wasm vector shuffle"), msg=message)
    _ => fail("unexpected shuffle grammar error")
  }
  try {
    let _ = vector_intrinsic(
      "i8x16.shuffle 0\t1 2 3 4 5 6 7 8 9 10 11 12 13 14 15",
      [Vector(0UL, 0UL), Vector(0UL, 0UL)],
    )
    fail("bad shuffle text must fail before execution")
  } catch {
    Failed(message) =>
      assert_true(message.contains("invalid Wasm vector shuffle"), msg=message)
    _ => fail("unexpected shuffle grammar error")
  }
  try {
    let _ = vector_intrinsic(
      "i8x16.shuffle 000 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15",
      [Vector(0UL, 0UL), Vector(0UL, 0UL)],
    )
    fail("bad shuffle text must fail before execution")
  } catch {
    Failed(message) =>
      assert_true(message.contains("invalid Wasm vector shuffle"), msg=message)
    _ => fail("unexpected shuffle grammar error")
  }
}

///|
test "vector shuffle keeps valid dynamic boundary lanes" {
  let left = vector_intrinsic("i8x16.splat", [Number(40UL, "I32")])
  let right = vector_intrinsic("i8x16.splat", [Number(2UL, "I32")])
  let result = vector_intrinsic(
    "i8x16.shuffle 31 0 30 1 29 2 28 3 27 4 26 5 25 6 24 7",
    [left, right],
  )
  for lane in 0..<16 {
    assert_eq(vector_byte(result, lane), if lane % 2 == 0 { 2UL } else { 40UL })
  }
}
