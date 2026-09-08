///|
test "removed Bytes write runtime requires the Dew library function" {
  // This old algorithm builtin is intentionally unsupported. The shared WASI
  // corpus checks successful, partial, empty, and invalid-host library writes.
  assert_true(
    emit_starshine_text_runtime_function(b"dew_wasi_fd_write", 0) is None,
  )
}
