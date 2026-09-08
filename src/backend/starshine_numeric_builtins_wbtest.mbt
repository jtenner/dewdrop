///|
test "raw unreachable emits one Wasm instruction" {
  assert_eq(
    starshine_inline_builtin_instructions(b"unreachable"),
    Ok([@lib.Instruction::unreachable_()]),
  )
  let stages = backend_test_single_module_stages(
    29382UL, b"builtin stop() -> Never = \"unreachable\"\npub fn main(flag: Bool) -> I32 {\n  if flag {\n    stop()\n  } else {\n    7i32\n  }\n}\n",
  )
  assert_eq(
    @semantic.collect_compiler_source_diagnostics(
      stages.program,
      stages.analyzed,
      stages.lowering,
      stages.link,
    ),
    [],
  )
  assert_eq(stages.link.imported_function_count, 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "scalar math builtins map to deterministic Wasm instructions" {
  assert_eq(
    starshine_numeric_builtin_instructions(b"i32.reinterpret_f32"),
    Some([@lib.Instruction::i32_reinterpret_f32()]),
  )
  assert_eq(
    starshine_numeric_builtin_instructions(b"f32.sqrt"),
    Some([@lib.Instruction::f32_sqrt()]),
  )
  assert_eq(
    starshine_numeric_builtin_instructions(b"f64.reinterpret_i64"),
    Some([@lib.Instruction::f64_reinterpret_i64()]),
  )
  assert_eq(
    starshine_numeric_builtin_instructions(b"f64.nearest"),
    Some([@lib.Instruction::f64_nearest()]),
  )
  assert_eq(
    starshine_numeric_builtin_instructions(b"i32.ctz"),
    Some([@lib.Instruction::i32_ctz()]),
  )
  assert_eq(
    starshine_numeric_builtin_instructions(b"i32.popcnt"),
    Some([@lib.Instruction::i32_popcnt()]),
  )
}
