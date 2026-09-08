///|
fn physical_alias_test_link() -> PlannedProgramWasmGCLink raise {
  let stages = compiler_test_stages(23964UL, [
    CompilerTestModule::new("alias.a", [CompilerTestSource::new(
      "a.dew", b"pub fn first(value: I32) -> I32 {\n  value\n}\npub fn second(value: I32) -> I32 {\n  value + 1\n}\npub fn callback() -> fn(I32) -> I32 {\n  first\n}\n",
    )]),
    CompilerTestModule::new("alias.b", [CompilerTestSource::new(
      "b.dew", b"pub fn third(value: I32) -> I32 {\n  value\n}\npub fn callback() -> fn(I32) -> I32 {\n  third\n}\n",
    )]),
  ])
  let link = plan_program_wasmgc_link(stages.analyzed, stages.lowering, 0)
  assert_eq(link.diagnostics, [])
  assert_true(!link.program_type_groups.is_empty())
  assert_eq(verify_program_physical_type_fragments(link), Ok(()))
  link
}

///|
test "canonical closure fields retain mutability in every source module" {
  let link = physical_alias_test_link()
  let owner = 1
  let module_ = link.modules[owner]
  let type_ = module_.physical_types[module_.closure_type_index]
  let field = module_.fields[type_.fields.start]
  assert_true(!field.mutable_)
  module_.fields[type_.fields.start] = { ..field, mutable_: true, }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 504, phase: 5, module_id: 23965UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: 0UL, actual: 1UL,
    detail: (64UL << 32) | type_.fields.start.to_uint64(),
  }))
}

///|
test "canonical closure fields retain their full storage type" {
  let link = physical_alias_test_link()
  let module_ = link.modules[1]
  let type_ = module_.physical_types[module_.closure_type_index]
  let field = module_.fields[type_.fields.start]
  assert_eq(field.storage, WasmNullableFunctionRefStorage)
  module_.fields[type_.fields.start] = { ..field, storage: WasmNullableEqRefStorage, }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 504, phase: 5, module_id: 23965UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: 9UL << 32, actual: 8UL << 32,
    detail: (65UL << 32) | type_.fields.start.to_uint64(),
  }))
}

///|
test "canonical function signatures cannot hide a changed source parameter" {
  let link = physical_alias_test_link()
  let module_ = link.modules[0]
  let declaration = make_semantic_id(23964UL, 1)
  let source = module_.function_of(declaration).unwrap()
  module_.function_value_types[source.parameters.start] = WasmI64Value
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 504, phase: 5, module_id: 23964UL, declaration,
    body: 0UL, expression: 0xffffffffU, expected: 3UL << 32, actual: 4UL << 32,
    detail: (61UL << 32) | source.parameters.start.to_uint64(),
  }))
}

///|
test "canonical closure fields retain their logical field identity" {
  let link = physical_alias_test_link()
  let module_ = link.modules[1]
  let type_ = module_.physical_types[module_.closure_type_index]
  let field = module_.fields[type_.fields.start]
  module_.fields[type_.fields.start] = { ..field, role: WasmEnumTagField, }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 504, phase: 5, module_id: 23965UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: 1UL, actual: 0UL,
    detail: (67UL << 32) | type_.fields.start.to_uint64(),
  }))
}

///|
test "canonical closure fields cannot disappear from one source alias" {
  let link = physical_alias_test_link()
  let module_ = link.modules[1]
  let local = module_.closure_type_index
  let type_ = module_.physical_types[local]
  module_.physical_types[local] = { ..type_, fields: { ..type_.fields, length: 0, }, }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 504, phase: 5, module_id: 23965UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: 1UL, actual: 0UL,
    detail: (66UL << 32) | local.to_uint64(),
  }))
}

///|
fn physical_nominal_alias_test_link() -> PlannedProgramWasmGCLink raise {
  let stages = compiler_test_stages(23966UL, [
    CompilerTestModule::new("alias.nominal", [CompilerTestSource::new(
      "main.dew", b"pub struct Pair {\n  value: I32\n}\npub struct Other {\n  value: I32\n}\npub fn first(value: Pair) -> I32 {\n  value.value\n}\npub fn second(value: Pair) -> I32 {\n  value.value + 1\n}\npub fn third(value: Other) -> I32 {\n  value.value\n}\npub fn callback() -> fn(Pair) -> I32 {\n  first\n}\n",
    )]),
  ])
  let link = plan_program_wasmgc_link(stages.analyzed, stages.lowering, 0)
  assert_eq(link.diagnostics, [])
  assert_eq(verify_program_physical_type_fragments(link), Ok(()))
  link
}

///|
test "canonical signature aliases compare reference nullability" {
  let link = physical_nominal_alias_test_link()
  let module_ = link.modules[0]
  let declaration = make_semantic_id(23966UL, 3)
  let source = module_.function_of(declaration).unwrap()
  let local = module_.type_index_of(23966UL << 32).unwrap()
  let physical = link.module_type_indices[0][local].to_uint64()
  assert_eq(module_.function_value_types[source.parameters.start], WasmNominalRefValue(local))
  module_.function_value_types[source.parameters.start] = WasmNullableNominalRefValue(local)
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 504, phase: 5, module_id: 23966UL, declaration,
    body: 0UL, expression: 0xffffffffU, expected: (10UL << 32) | physical, actual: (11UL << 32) | physical,
    detail: (61UL << 32) | source.parameters.start.to_uint64(),
  }))
}

///|
test "canonical signature aliases compare exact heap identity" {
  let link = physical_nominal_alias_test_link()
  let module_ = link.modules[0]
  let declaration = make_semantic_id(23966UL, 3)
  let source = module_.function_of(declaration).unwrap()
  let pair = module_.type_index_of(23966UL << 32).unwrap()
  let other = module_.type_index_of(make_semantic_id(23966UL, 1)).unwrap()
  module_.function_value_types[source.parameters.start] = WasmNominalRefValue(other)
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 504, phase: 5, module_id: 23966UL, declaration,
    body: 0UL, expression: 0xffffffffU,
    expected: (10UL << 32) | link.module_type_indices[0][pair].to_uint64(),
    actual: (10UL << 32) | link.module_type_indices[0][other].to_uint64(),
    detail: (61UL << 32) | source.parameters.start.to_uint64(),
  }))
}

///|
test "shared trait vtables compare their relocated method signature types" {
  let stages = compiler_test_stages(23968UL, [
    CompilerTestModule::new("alias.traits", [CompilerTestSource::new(
      "traits.dew", b"pub trait Read {\n  fn read(self) -> I32\n}\npub fn first(value: Read) -> I32 {\n  value.read()\n}\n",
    )]),
    CompilerTestModule::new("alias.consumer", [CompilerTestSource::new(
      "consumer.dew", b"open alias.traits\npub fn second(value: Read) -> I32 {\n  value.read()\n}\n",
    )]),
  ])
  let link = plan_program_wasmgc_link(stages.analyzed, stages.lowering, 0)
  assert_eq(link.diagnostics, [])
  assert_eq(verify_program_physical_type_fragments(link), Ok(()))
  assert_true(!link.program_type_groups.is_empty())
  let mut checked = false
  for owner, module_ in link.modules {
    for local, type_ in module_.physical_types {
      let declaration = match type_.kind {
        PlannedWasmTraitVTableType(value) => value
        _ => continue
      }
      let canonical = link.program_physical_types[link.module_type_indices[owner][local]]
      if canonical.module_index == owner { continue }
      assert_eq(type_.fields.length, 1)
      let slot = type_.fields.start
      let field = module_.fields[slot]
      let signature = match field.storage {
        WasmFunctionRefStorage(index) => index
        _ => { fail("trait method lacks a typed function reference"); continue }
      }
      let expected = (11UL << 32) | link.signature_type_index(owner, signature).to_uint64()
      module_.fields[slot] = { ..field, storage: WasmNullableFunctionRefStorage, }
      assert_eq(verify_program_physical_type_fragments(link), Err({
        code: 504, phase: 5, module_id: module_.module_id, declaration,
        body: 0UL, expression: 0xffffffffU, expected, actual: 9UL << 32,
        detail: (65UL << 32) | slot.to_uint64(),
      }))
      module_.fields[slot] = field
      checked = true
    }
  }
  assert_true(checked)
}
