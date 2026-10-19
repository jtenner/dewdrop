///|
test "ref.eq accepts equality references in direct and outlined calls" {
  let stages = backend_test_single_module_stages(
    28214UL,
    b"pub struct Box {\n  value: I32\n}\npub enum Value {\n  Number(I32)\n}\nbuiltin same_box(left: Box, right: Box) -> Bool = \"ref.eq\"\nbuiltin same_value(left: Value, right: Value) -> Bool = \"ref.eq\"\npub fn direct(left: Box, right: Box) -> Bool {\n  same_box(left, right)\n}\npub fn enum_direct(left: Value, right: Value) -> Bool {\n  same_value(left, right)\n}\npub fn callback() -> fn(Box, Box) -> Bool {\n  same_box\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.imported_function_count, 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
  assert_eq(
    starshine_inline_builtin_instructions(b"ref.eq"),
    Ok([@lib.Instruction::ref_eq()]),
  )
}

///|
test "ref.eq rejects scalars wrong arity and wrong results" {
  for (parameters, result, arguments) in [
    ("left: I32, right: Box", "Bool", "left, right"),
    ("left: Box, right: I64", "Bool", "left, right"),
    ("left: Box", "Bool", "left"),
    ("left: Box, right: Box", "I64", "left, right"),
    ("left: Box, right: Box", "Unit", "left, right"),
  ] {
    let stages = backend_test_single_module_stages(
      28215UL,
      @utf8.encode(
        "pub struct Box {\n  value: I32\n}\nbuiltin same(\{parameters}) -> \{result} = \"ref.eq\"\npub fn run(\{parameters}) -> \{result} {\n  same(\{arguments})\n}\n",
      ),
    )
    assert_eq(stages.diagnostic_count(), 0)
    match emit_starshine_program_module(stages.lowering, stages.link) {
      Err(InvalidBuiltinSignature(name, _, _)) => assert_eq(name, b"ref.eq")
      Err(error) => fail(@debug.to_string(error))
      Ok(_) =>
        fail("invalid ref.eq stack types emitted a Wasm module: (\{parameters}) -> \{result}")
    }
  }
}
