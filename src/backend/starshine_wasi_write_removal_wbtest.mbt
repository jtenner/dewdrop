///|
test "removed Bytes write runtime requires the Dew library function" {
  // This old algorithm builtin is intentionally unsupported. The shared WASI
  // corpus checks successful, partial, empty, and invalid-host library writes.
  assert_eq(
    starshine_inline_builtin_instructions(b"dew_wasi_fd_write"),
    Err(UnsupportedBuiltin(b"dew_wasi_fd_write")),
  )
}
