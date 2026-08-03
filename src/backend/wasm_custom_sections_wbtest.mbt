///|
test "append deterministic Wasm custom section" {
  let module_ = b"\x00asm\x01\x00\x00\x00"
  let result = append_wasm_custom_section(module_, "dew.tests", b"abc")
  assert_eq(result, b"\x00asm\x01\x00\x00\x00\x00\x0D\x09dew.testsabc")
}

///|
test "append deterministic Wasm static metrics section" {
  let module_ = b"\x00asm\x01\x00\x00\x00"
  let result = append_wasm_metrics_section(module_, 2)
  assert_eq(
    result, b"\x00asm\x01\x00\x00\x00\x00\x14\x0Bdew.metricsDWM1\x02\x00\x00\x00",
  )
}

///|
test "custom section lengths use unsigned LEB128" {
  let payload = Buffer(size_hint=128)
  for _ in 0..<128 {
    payload.write_byte(0)
  }
  let result = append_wasm_custom_section(
    b"\x00asm\x01\x00\x00\x00",
    "x",
    payload.to_bytes(),
  )
  assert_eq(result[8], 0)
  assert_eq(result[9], 130)
  assert_eq(result[10], 1)
  assert_eq(result[11], 1)
  assert_eq(result[12], b'x')
  assert_eq(result.length(), 141)
}
