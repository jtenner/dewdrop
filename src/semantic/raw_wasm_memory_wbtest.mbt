///|
test "linear memory use follows opcode contracts not name fragments" {
  assert_true(wasmgc_builtin_uses_linear_memory(b"v128.load8_splat"))
  assert_true(wasmgc_builtin_uses_linear_memory(b"v128.store64_lane 1"))
  assert_false(wasmgc_builtin_uses_linear_memory(b"v128.load8_lane 16"))
  assert_false(wasmgc_builtin_uses_linear_memory(b"v128.not"))
  assert_false(wasmgc_builtin_uses_linear_memory(b"dew_user_load_something"))
  assert_false(wasmgc_builtin_uses_linear_memory(b"dew_user_store_something"))
}
