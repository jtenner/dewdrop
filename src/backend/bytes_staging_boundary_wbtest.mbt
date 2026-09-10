///|
test "byte staging is intentionally not a compiler runtime operation" {
  for name in [b"dew_bench_wasi_stage_write", b"dew_bench_wasi_stage_read"] {
    assert_eq(starshine_inline_builtin_instructions(name), Err(UnsupportedBuiltin(name)))
  }
}
