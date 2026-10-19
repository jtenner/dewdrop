///|
test "query references keep both exact logical function singletons" {
  let stages = backend_test_single_module_stages(
    28264UL, b"builtin equal<a, b>() -> Bool = \"types.type_equal\"\nfn flag<t>(value: t) -> Bool {\n  let _ = value\n  equal::<t, I32>()\n}\npub fn signed() -> fn(I32) -> Bool {\n  flag\n}\npub fn unsigned() -> fn(U32) -> Bool {\n  flag\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let declaration = stages.program.modules[0].lookup_value("flag").unwrap()
  let targets : Map[Int32, Bool] = {}
  for function_ in stages.link.functions {
    if function_.declaration == declaration &&
      function_.function_index >= 0 &&
      !function_.elided {
      targets[function_.function_index] = true
    }
  }
  assert_eq(targets.length(), 2)
  let mut references = 0
  for singleton in stages.link.function_reference_singletons {
    if singleton.declaration == declaration {
      assert_true(targets.contains(singleton.function_index))
      ignore(targets.remove(singleton.function_index))
      references += 1
    }
  }
  assert_eq(references, 2)
  assert_true(targets.is_empty())
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "ordinary references share one canonical function singleton" {
  let stages = backend_test_single_module_stages(
    28264UL, b"fn identity<t>(value: t) -> t {\n  value\n}\npub fn signed() -> fn(I32) -> I32 {\n  identity\n}\npub fn unsigned() -> fn(U32) -> U32 {\n  identity\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let declaration = stages.program.modules[0].lookup_value("identity").unwrap()
  let targets : Map[Int32, Bool] = {}
  for function_ in stages.link.functions {
    if function_.declaration == declaration &&
      function_.function_index >= 0 &&
      !function_.elided {
      targets[function_.function_index] = true
    }
  }
  assert_eq(targets.length(), 1)
  let mut references = 0
  for singleton in stages.link.function_reference_singletons {
    if singleton.declaration == declaration {
      assert_true(targets.contains(singleton.function_index))
      ignore(targets.remove(singleton.function_index))
      references += 1
    }
  }
  assert_eq(references, 1)
  assert_true(targets.is_empty())
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "concrete generic trait references need no fresh witness closure" {
  let stages = backend_test_single_module_stages(
    28265UL, b"builtin same<a, b>(left: a, right: b) -> Bool = \"ref.eq\"\ntrait Mark {\n  fn mark(self) -> I32\n}\nstruct Left {}\nstruct Right {}\nimpl Mark for Left {\n  fn mark(self) -> I32 {\n    40i32\n  }\n}\nimpl Mark for Right {\n  fn mark(self) -> I32 {\n    2i32\n  }\n}\nfn bounded<t: Mark>(value: t) -> I32 {\n  value.mark()\n}\nfn wrap<t: Mark>() -> fn(t) -> I32 {\n  bounded\n}\nfn forward<t: Mark>() -> fn(t) -> I32 {\n  wrap::<t>()\n}\npub fn main() -> I32 {\n  if same(wrap::<Left>(), forward::<Left>()) && !same(wrap::<Left>(), wrap::<Right>()) && forward::<Left>()(Left::{}) == 40i32 && wrap::<Right>()(Right::{}) == 2i32 {\n    42i32\n  } else {\n    0i32\n  }\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.evidence_function_references.length(), 0)
  let declaration = stages.program.modules[0].lookup_value("bounded").unwrap()
  let mut references = 0
  for singleton in stages.link.function_reference_singletons {
    if singleton.declaration == declaration {
      references += 1
    }
  }
  assert_eq(references, 2)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}
