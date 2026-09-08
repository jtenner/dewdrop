///|
test "byte staging is intentionally not a compiler runtime operation" {
  for name in [b"dew_bench_wasi_stage_write", b"dew_bench_wasi_stage_read"] {
    assert_eq(emit_starshine_text_runtime_function(name, 0, -1), None)
  }
}
