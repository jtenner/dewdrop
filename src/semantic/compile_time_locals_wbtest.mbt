///|
test "compile time dead locals keep logical types but allocate no storage" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\npub fn main(flag: Bool) -> I32 {\n  if is_unit::<Unit>() {\n    let live = 7i32\n    live\n  } else {\n    let dead = 9i64\n    0i32\n  }\n}\n",
  )
  let module_ = lowering.modules[0]
  let mut dead_count = 0
  for local_ in module_.locals {
    if local_.shape is I64PlannedValueShape {
      dead_count += 1
      assert_true(
        local_.elided,
        msg="discarded local must not allocate storage",
      )
    } else {
      assert_false(local_.elided)
    }
  }
  assert_eq(dead_count, 1)
}

///|
test "compile time dead pattern storage does not create nominal fragments" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nenum Dead {\n  Value(I64)\n}\npub fn main() -> I32 {\n  if is_unit::<Unit>() {\n    7i32\n  } else {\n    match Dead::Value(9i64) {\n      Dead::Value(item) => 0i32\n    }\n  }\n}\n",
  )
  let dead = program.modules[0].lookup_type("Dead").unwrap()
  for pattern in lowering.modules[0].patterns {
    assert_true(pattern.elided)
  }
  let analyzed = analyze_program_semantics(program)
  let fragments = plan_program_wasmgc_fragments(analyzed, lowering)
  for module_ in fragments.modules {
    for type_ in module_.physical_types {
      assert_false(
        type_.kind is PlannedWasmEnumBaseType(owner) && owner == dead,
      )
      assert_false(
        type_.kind is PlannedWasmEnumSubtypeType(owner, _, _) && owner == dead,
      )
    }
  }
}
