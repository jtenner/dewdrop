///|
test "generic Unit loop and match bindings need no physical local" {
  for
    source in [
      b"fn identity<t>(value: t) -> t {\n  while value {\n    current => break current\n  }\n}\npub fn main() -> I32 {\n  identity(())\n  42i32\n}\n",
      b"fn identity<t>(value: t) -> t {\n  match value {\n    current => current\n  }\n}\npub fn main() -> I32 {\n  identity(())\n  42i32\n}\n",
      b"fn unit_loop() -> Unit {\n  while () {\n    current => break current\n  }\n}\npub fn main() -> I32 {\n  unit_loop()\n  42i32\n}\n",
    ] {
    let module_ = starshine_while_test_module(source)
    assert_eq(@validate.validate_module(module_), Ok(()))
    let bytes = @binary.encode_module(module_).unwrap()
    let decoded = @binary.decode_module(bytes).unwrap()
    assert_eq(@validate.validate_module(decoded), Ok(()))
  }
}

///|
test "generic loop bindings retain scalar and reference carriers" {
  let module_ = starshine_while_test_module(
    b"fn identity<t>(value: t) -> t {\n  while value {\n    current => break current\n  }\n}\nstruct Item {\n  value: I32\n}\npub fn main() -> I32 {\n  let first = identity(42i32)\n  let second = identity(42i64)\n  let third = identity(1.5f32)\n  let fourth = identity(1.5f64)\n  let item = identity(Item::{\n    value: first\n  })\n  if second == 42i64 && third == 1.5f32 && fourth == 1.5f64 {\n    item.value\n  } else {\n    0i32\n  }\n}\n",
  )
  assert_eq(@validate.validate_module(module_), Ok(()))
}
