///|
test "field nominal references must remain inside their source arena" {
  let link = physical_type_test_link()
  let field = link.modules[0].fields[0]
  link.modules[0].fields[0] = {
    ..field, storage: WasmNominalRefStorage(WasmModuleTypeReference(-1)),
  }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 101, phase: 5, module_id: 23960UL, declaration: 23960UL << 32,
    body: 0UL, expression: 0xffffffffU, expected: 1UL, actual: 0xffffffffUL, detail: 49UL << 32,
  }))
}

///|
test "recursive field references must remain inside their owning group" {
  let link = physical_type_test_link()
  let field = link.modules[0].fields[0]
  link.modules[0].fields[0] = {
    ..field, storage: WasmNullableNominalRefStorage(WasmRecursiveTypeReference(1)),
  }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 101, phase: 5, module_id: 23960UL, declaration: 23960UL << 32,
    body: 0UL, expression: 0xffffffffU, expected: 1UL, actual: 1UL, detail: 50UL << 32,
  }))
}

///|
test "function field references cannot select a struct heap type" {
  let link = physical_type_test_link()
  let field = link.modules[0].fields[0]
  link.modules[0].fields[0] = { ..field, storage: WasmFunctionRefStorage(0), }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 504, phase: 5, module_id: 23960UL, declaration: 23960UL << 32,
    body: 0UL, expression: 0xffffffffU, expected: 1UL, actual: 0UL, detail: 51UL << 32,
  }))
}

///|
test "raw array field references require a known storage carrier" {
  let link = physical_type_test_link()
  let field = link.modules[0].fields[0]
  link.modules[0].fields[0] = { ..field, storage: WasmFixedArrayRefStorage(8), }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 101, phase: 5, module_id: 23960UL, declaration: 23960UL << 32,
    body: 0UL, expression: 0xffffffffU, expected: 8UL, actual: 8UL, detail: 52UL << 32,
  }))
}

///|
test "external field references cannot become missing heap indices" {
  let link = physical_type_test_link()
  let field = link.modules[0].fields[0]
  let declaration = 23961UL << 32
  link.modules[0].fields[0] = { ..field, storage: WasmExternalNominalRefStorage(declaration), }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 503, phase: 5, module_id: 23960UL, declaration: 23960UL << 32,
    body: 0UL, expression: 0xffffffffU, expected: declaration, actual: 0xffffffffUL, detail: 53UL << 32,
  }))
}

///|
test "signature value references retain the owning function context" {
  let link = physical_type_test_link()
  let declaration = make_semantic_id(23960UL, 1)
  let source = link.modules[0].function_of(declaration).unwrap()
  let slot = source.parameters.start
  link.modules[0].function_value_types[slot] = WasmNullableNominalRefValue(-1)
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 101, phase: 5, module_id: 23960UL, declaration,
    body: 0UL, expression: 0xffffffffU, expected: 1UL, actual: 0xffffffffUL,
    detail: (49UL << 32) | slot.to_uint64(),
  }))
}
