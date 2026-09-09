///|
fn planning_codec_test_stages() -> SemanticCompilerTestStages {
  compiler_test_stages(23950UL, [
    CompilerTestModule::new("cache.plans", [
      CompilerTestSource::new(
        "main.dew", b"struct Pair<t> {\n  first: t\n  second: I64\n}\nenum Choice<t> {\n  Empty\n  One(t)\n  Named {\n    value: t\n  }\n}\nfn hidden(value: I32) -> I32 {\n  value + 1\n}\npub fn apply(value: I32) -> I32 {\n  let callback = fn(item: I32) -> I32 {\n    hidden(item)\n  }\n  callback(value)\n}\n",
      ),
    ]),
  ])
}

///|
test "WasmGC codec retains outlined intrinsic identity" {
  let stages = compiler_test_stages(23953UL, [
    CompilerTestModule::new("cache.builtin", [
      CompilerTestSource::new(
        "main.dew", b"builtin add(a: I32, b: I32) -> I32 = \"i32.add\"\npub fn factory() -> fn(I32, I32) -> I32 {\n  add\n}\n",
      ),
    ]),
  ])
  let fragments = plan_program_wasmgc_fragments(
      stages.analyzed,
      stages.lowering,
    ).modules[0]
  assert_true(
    fragments.functions[0].kind is PlannedWasmOutlinedBuiltinFunction(_),
  )
  let encoded = serialize_planned_module_wasmgc_fragments(fragments).unwrap()
  assert_eq(deserialize_planned_module_wasmgc_fragments(encoded).unwrap(), fragments)
}

///|
test "WasmGC codec retains raw struct owners and field immediates" {
  let stages = compiler_test_stages(23954UL, [
    CompilerTestModule::new("cache.struct_get", [
      CompilerTestSource::new(
        "main.dew", b"builtin size(value: Bytes) -> U32 = \"struct.get 2\"\npub fn factory() -> fn(Bytes) -> U32 {\n  size\n}\n",
      ),
    ]),
  ])
  let fragments = plan_program_wasmgc_fragments(
      stages.analyzed,
      stages.lowering,
    ).modules[0]
  match fragments.functions[0].kind {
    PlannedWasmOutlinedStructGetFunction(recipe) => {
      assert_eq(recipe.owner, PrimitiveRawStructOwner(BytesType))
      assert_eq(recipe.field_index, 2)
      assert_eq(recipe.opcode, b"struct.get 2")
    }
    _ => fail("expected an outlined struct.get recipe")
  }
  let encoded = serialize_planned_module_wasmgc_fragments(fragments).unwrap()
  assert_eq(
    deserialize_planned_module_wasmgc_fragments(encoded).unwrap(),
    fragments,
  )
}

///|
test "planned type layouts use a canonical bounded binary round trip" {
  let stages = planning_codec_test_stages()
  let layouts = stages.lowering.modules[0].type_layouts
  let encoded = serialize_planned_module_type_layouts(layouts).unwrap()
  let decoded = deserialize_planned_module_type_layouts(encoded).unwrap()
  assert_eq(decoded, layouts)
  assert_eq(serialize_planned_module_type_layouts(decoded).unwrap(), encoded)
  assert_true(deserialize_planned_module_type_layouts(b"bad") is Err(_))
  let trailing = Buffer(size_hint=encoded.length() + 1)
  trailing.write_bytes(encoded)
  trailing.write_byte(0)
  assert_true(
    deserialize_planned_module_type_layouts(trailing.to_bytes()) is Err(_),
  )
}

///|
test "planned WasmGC fragments use a canonical bounded binary round trip" {
  let stages = planning_codec_test_stages()
  let fragments = plan_program_wasmgc_fragments(
      stages.analyzed,
      stages.lowering,
    ).modules[0]
  let encoded = serialize_planned_module_wasmgc_fragments(fragments).unwrap()
  let decoded = deserialize_planned_module_wasmgc_fragments(encoded).unwrap()
  assert_eq(decoded, fragments)
  assert_eq(
    serialize_planned_module_wasmgc_fragments(decoded).unwrap(),
    encoded,
  )
  assert_true(deserialize_planned_module_wasmgc_fragments(b"bad") is Err(_))
  for cut in [0, 1, encoded.length() / 2, encoded.length() - 1] {
    let truncated = Buffer(size_hint=cut)
    for index in 0..<cut {
      truncated.write_byte(encoded[index])
    }
    assert_true(
      deserialize_planned_module_wasmgc_fragments(truncated.to_bytes())
      is Err(_),
    )
  }
}

///|
test "WasmGC fragment codec preserves generic and runtime-trait specialization" {
  let stages = compiler_test_stages(23952UL, [
    CompilerTestModule::new("cache.specialized", [
      CompilerTestSource::new(
        "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\nimpl Value for U32 {\n  fn value(self) -> I32 {\n    2\n  }\n}\nfn read<t: Value>(value: t) -> I32 {\n  value.value()\n}\npub fn signed() -> I32 {\n  read(1)\n}\npub fn unsigned() -> I32 {\n  read(1u32)\n}\n",
      ),
    ]),
  ])
  let fragments = plan_program_wasmgc_fragments(
      stages.analyzed,
      stages.lowering,
    ).modules[0]
  let encoded = serialize_planned_module_wasmgc_fragments(fragments).unwrap()
  assert_eq(
    deserialize_planned_module_wasmgc_fragments(encoded).unwrap(),
    fragments,
  )
  assert_true(
    validate_cached_module_wasmgc_fragments(
      fragments,
      fragments.module_id,
      WasmGCPlanningOptions::optimized_subtype_families(),
    )
    is Err(_),
  )
}

///|
test "planning payload validation rejects inconsistent arenas" {
  let stages = planning_codec_test_stages()
  let layouts = stages.lowering.modules[0].type_layouts
  assert_true(
    serialize_planned_module_type_layouts({
      ..layouts,
      layout_by_declaration: [-1],
    })
    is Err(_),
  )
  let fragments = plan_program_wasmgc_fragments(
      stages.analyzed,
      stages.lowering,
    ).modules[0]
  assert_true(
    serialize_planned_module_wasmgc_fragments({
      ..fragments,
      function_by_declaration: [999999],
    })
    is Err(_),
  )
}
