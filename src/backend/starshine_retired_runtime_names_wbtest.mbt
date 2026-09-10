///|
test "native emission rejects the removed compiler-owned Bytes read runtime" {
  // These algorithms are intentionally unsupported as builtins; their Dew
  // library implementations have separate shared execution coverage.
  for name in [
    b"dew_wasi_fd_read",
  ] {
    assert_eq(starshine_inline_builtin_instructions(name), Err(UnsupportedBuiltin(name)))
  }
}

///|
test "native emission rejects the removed compiler-owned Bytes write runtime" {
  // These algorithms are intentionally unsupported as builtins; their Dew
  // library implementations have separate shared execution coverage.
  for name in [
    b"dew_wasi_fd_write",
  ] {
    assert_eq(starshine_inline_builtin_instructions(name), Err(UnsupportedBuiltin(name)))
  }
}

///|
test "native emission rejects removed compiler-owned Bytes staging runtimes" {
  // These algorithms are intentionally unsupported as builtins; their Dew
  // library implementations have separate shared execution coverage.
  for name in [
    b"dew_bench_wasi_stage_write",
    b"dew_bench_wasi_stage_read",
  ] {
    assert_eq(starshine_inline_builtin_instructions(name), Err(UnsupportedBuiltin(name)))
  }
}

///|
test "native emission rejects removed compiler-owned integer Debug runtimes" {
  // These algorithms are intentionally unsupported as builtins; their Dew
  // library implementations have separate shared execution coverage.
  for name in [
    b"dew_debug_i8",
    b"dew_debug_i16",
    b"dew_debug_i32",
    b"dew_debug_i64",
    b"dew_debug_u8",
    b"dew_debug_u16",
    b"dew_debug_u32",
    b"dew_debug_u64",
  ] {
    assert_eq(starshine_inline_builtin_instructions(name), Err(UnsupportedBuiltin(name)))
  }
}

///|
test "native emission rejects removed compiler-owned float Debug runtimes" {
  // These algorithms are intentionally unsupported as builtins; their Dew
  // library implementations have separate shared execution coverage.
  for name in [
    b"dew_debug_f32",
    b"dew_debug_f64",
  ] {
    assert_eq(starshine_inline_builtin_instructions(name), Err(UnsupportedBuiltin(name)))
  }
}

///|
test "native emission rejects removed compiler-owned String Debug runtime" {
  // These algorithms are intentionally unsupported as builtins; their Dew
  // library implementations have separate shared execution coverage.
  for name in [
    b"dew_debug_string",
  ] {
    assert_eq(starshine_inline_builtin_instructions(name), Err(UnsupportedBuiltin(name)))
  }
}

///|
test "native emission rejects removed compiler-owned Bytes Debug runtime" {
  // These algorithms are intentionally unsupported as builtins; their Dew
  // library implementations have separate shared execution coverage.
  for name in [
    b"dew_debug_bytes",
  ] {
    assert_eq(starshine_inline_builtin_instructions(name), Err(UnsupportedBuiltin(name)))
  }
}

///|
test "native emission rejects removed compiler-owned V128 Debug runtime" {
  // These algorithms are intentionally unsupported as builtins; their Dew
  // library implementations have separate shared execution coverage.
  for name in [
    b"dew_debug_v128",
  ] {
    assert_eq(starshine_inline_builtin_instructions(name), Err(UnsupportedBuiltin(name)))
  }
}

///|
test "native emission rejects removed compiler-owned StringView algorithms" {
  // These algorithms are intentionally unsupported as builtins; their Dew
  // library implementations have separate shared execution coverage.
  for name in [
    b"dew_string_view_byte_length",
    b"dew_string_view_byte_at",
    b"dew_string_view_to_string",
    b"dew_string_view_utf16_length",
    b"dew_string_view_equals",
    b"dew_string_view_hash",
    b"dew_string_view_find",
    b"dew_string_view_find_string",
    b"dew_string_view_starts_with",
    b"dew_string_view_starts_with_string",
    b"dew_string_view_ends_with",
    b"dew_string_view_ends_with_string",
    b"dew_string_view_as_bytes",
  ] {
    assert_eq(starshine_inline_builtin_instructions(name), Err(UnsupportedBuiltin(name)))
  }
}

///|
test "native emission rejects removed compiler-owned String algorithms" {
  // These algorithms are intentionally unsupported as builtins; their Dew
  // library implementations have separate shared execution coverage.
  for name in [
    b"dew_string_byte_length",
    b"dew_string_byte_at",
    b"dew_string_equals",
    b"dew_string_utf16_length",
    b"dew_string_hash",
    b"dew_string_find",
    b"dew_string_find_view",
    b"dew_string_starts_with",
    b"dew_string_starts_with_view",
    b"dew_string_ends_with",
    b"dew_string_ends_with_view",
    b"dew_string_concat",
    b"dew_string_concat_view",
    b"dew_string_load_u8x16",
    b"dew_string_builder_byte_length",
    b"dew_string_builder_new",
    b"dew_string_as_bytes",
    b"dew_string_builder_append",
    b"dew_string_builder_append_view",
    b"dew_string_builder_append_ascii",
    b"dew_string_builder_with_capacity",
    b"dew_string_builder_append_scalar",
    b"dew_string_builder_finish",
    b"dew_string_view",
    b"dew_string_view_view",
  ] {
    assert_eq(starshine_inline_builtin_instructions(name), Err(UnsupportedBuiltin(name)))
  }
}

///|
test "native emission rejects removed compiler-owned Bytes algorithms" {
  // These algorithms are intentionally unsupported as builtins; their Dew
  // library implementations have separate shared execution coverage.
  for name in [
    b"dew_bytes_is_valid_utf8",
    b"dew_bytes_to_string",
    b"dew_bytes_equals",
    b"dew_bytes_hash",
    b"dew_bytes_find_byte",
    b"dew_bytes_find",
    b"dew_bytes_starts_with",
    b"dew_bytes_ends_with",
    b"dew_bytes_concat",
    b"dew_bytes_load_u8x16",
    b"dew_bytes_byte_length",
    b"dew_bytes_builder_byte_length",
    b"dew_bytes_builder_new",
    b"dew_bytes_to_string_unchecked",
    b"dew_bytes_view",
    b"dew_bytes_byte_at",
    b"dew_bytes_builder_with_capacity",
    b"dew_bytes_builder_append",
    b"dew_bytes_builder_append_byte",
    b"dew_bytes_builder_finish",
  ] {
    assert_eq(starshine_inline_builtin_instructions(name), Err(UnsupportedBuiltin(name)))
  }
}

///|
test "native emission rejects removed compiler-owned Map runtimes" {
  // These algorithms are intentionally unsupported as builtins; their Dew
  // library implementations have separate shared execution coverage.
  for name in [
    b"dew_map_empty",
    b"dew_map_length",
    b"dew_map_set",
    b"dew_map_insert",
    b"dew_map_get_unchecked",
    b"dew_map_get",
    b"dew_map_contains_key",
  ] {
    assert_eq(starshine_inline_builtin_instructions(name), Err(UnsupportedBuiltin(name)))
  }
}

///|
test "native emission rejects removed compiler-owned Array runtimes" {
  // These algorithms are intentionally unsupported as builtins; their Dew
  // library implementations have separate shared execution coverage.
  for name in [
    b"dew_array_new",
    b"dew_array_with_capacity",
    b"dew_array_make",
    b"dew_array_length",
    b"dew_array_capacity",
    b"dew_array_backing_length_i32",
    b"dew_array_backing_length_ref",
    b"dew_array_push",
    b"dew_array_get",
    b"dew_array_get_unchecked",
    b"dew_array_set_unchecked",
    b"dew_array_pop",
    b"dew_array_iter",
    b"dew_array_iter_has_next",
    b"dew_array_iter_next",
    b"dew_array_iter_next_option",
    b"dew_array_truncate",
    b"dew_array_clear",
  ] {
    assert_eq(starshine_inline_builtin_instructions(name), Err(UnsupportedBuiltin(name)))
  }
}
