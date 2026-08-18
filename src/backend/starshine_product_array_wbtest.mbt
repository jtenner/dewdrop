///|
test "array literals emit exact-capacity WasmGC arrays" {
  let stages = backend_test_single_module_stages(
    28111UL, b"open dew.std.array\npub fn run() -> I32 {\n  let values = [10, 20, 30]\n  values[0u32] + values[2u32]\n}\npub fn pairs() -> Array<(I32, I64)> {\n  [(1, 2L), (3, 4L)]\n}\npub fn first_pair() -> (I32, I64) {\n  let values = pairs()\n  values[0u32]\n}\npub fn empty() -> Array<I32> {\n  []\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => {
      debug_inspect(error)
      fail("array literal emission failed")
    }
  }
}

///|
test "products use multivalue ABIs and box only at storage boundaries" {
  let stages = backend_test_single_module_stages(
    28112UL, b"open dew.std.array\nfn pair() -> (I32, I64) {\n  (7, 9L)\n}\nlet stored = pair()\nfn identity(value: (I32, I64)) -> (I32, I64) {\n  value\n}\npub fn choose(flag: Bool) -> (I32, I64) {\n  if flag {\n    identity(pair())\n  } else {\n    (11, 13L)\n  }\n}\npub fn choose_match(flag: Bool) -> (I32, I64) {\n  match flag {\n    true => pair()\n    false => (17, 19L)\n  }\n}\npub fn forward() -> (I32, I64) {\n  let value = pair()\n  identity(value)\n}\npub fn destructure() -> (I32, I64) {\n  let (first, second) = pair()\n  (first, second)\n}\nfn nested() -> (I32, (I64, Bool)) {\n  (23, (29L, true))\n}\npub fn destructure_nested() -> (I32, (I64, Bool)) {\n  let (first, (second, third)) = nested()\n  (first, (second, third))\n}\npub fn captured() -> (I32, I64) {\n  let value = pair()\n  let read = fn() -> (I32, I64) {\n    value\n  }\n  read()\n}\npub fn lambda_parameter() -> (I32, I64) {\n  let identity = fn(value: (I32, I64)) -> (I32, I64) {\n    value\n  }\n  identity(pair())\n}\nfn generic_identity<t>(value: (t, t)) -> (t, t) {\n  value\n}\npub fn generic_pair() -> (I32, I32) {\n  generic_identity((41, 43))\n}\nfn generic_array<t>(value: t) -> Array<(t, t)> {\n  [(value, value)]\n}\npub fn generic_array_i32() -> Array<(I32, I32)> {\n  generic_array(59)\n}\npub fn captured_mut() -> (I32, I64) {\n  let mut value = pair()\n  let update = fn() -> (I32, I64) {\n    value = (31, 37L)\n    value\n  }\n  update()\n}\nstruct Holder {\n  value: (I32, I64)\n}\nenum Stored {\n  Pair((I32, I64))\n  Empty\n}\npub fn holder() -> Holder {\n  Holder::{\n    value: pair()\n  }\n}\npub fn stored_enum() -> Stored {\n  Stored::Pair(pair())\n}\npub fn stored_enum_value() -> (I32, I64) {\n  match stored_enum() {\n    Stored::Pair(value) => value\n    Stored::Empty => pair()\n  }\n}\npub fn holder_value() -> (I32, I64) {\n  holder().value\n}\npub fn holder_match() -> (I32, I64) {\n  match holder() {\n    Holder {\n      value: value\n    } => value\n  }\n}\npub fn stored_value() -> (I32, I64) {\n  stored\n}\npub fn loop_product() -> (I32, I64) {\n  while pair() {\n    value => break value\n  }\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => {
      debug_inspect(error)
      fail("product emission failed")
    }
  }
}
