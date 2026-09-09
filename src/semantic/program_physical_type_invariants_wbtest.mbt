///|
fn physical_type_test_link() -> PlannedProgramWasmGCLink raise {
  let stages = compiler_test_stages(23960UL, [
    CompilerTestModule::new("app.types", [CompilerTestSource::new(
      "main.dew", b"pub struct Pair {\n  left: I32\n  right: I64\n}\npub fn read(value: Pair) -> I64 {\n  value.right\n}\n",
    )]),
  ])
  let link = plan_program_wasmgc_link(stages.analyzed, stages.lowering, 0)
  assert_eq(link.diagnostics, [])
  assert_eq(link.modules[0].physical_types.length(), 1)
  assert_eq(link.modules[0].fields.length(), 2)
  assert_eq(verify_program_physical_type_fragments(link), Ok(()))
  link
}

///|
test "physical type fragments are valid before mutation" {
  let _ = physical_type_test_link()
}

///|
test "physical type stored indices match their owned table slots" {
  let link = physical_type_test_link()
  let original = link.modules[0].physical_types[0]
  link.modules[0].physical_types[0] = { ..original, type_index: 1, }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 502, phase: 5, module_id: 23960UL, declaration: make_semantic_id(23960UL, 0),
    body: 0UL, expression: 0xffffffffU, expected: 0UL, actual: 1UL, detail: 4UL << 32,
  }))
}

///|
test "physical field spans are checked before reads" {
  let link = physical_type_test_link()
  let original = link.modules[0].physical_types[0]
  link.modules[0].physical_types[0] = {
    ..original, fields: { ..original.fields, start: -1, },
  }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 101, phase: 5, module_id: 23960UL, declaration: make_semantic_id(23960UL, 0),
    body: 0UL, expression: 0xffffffffU, expected: 2UL, actual: 0xffffffff00000002UL, detail: 6UL << 32,
  }))
}

///|
test "physical field positions retain their declared order" {
  let link = physical_type_test_link()
  let original = link.modules[0].fields[1]
  link.modules[0].fields[1] = { ..original, physical_index: 0, }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 504, phase: 5, module_id: 23960UL, declaration: make_semantic_id(23960UL, 0),
    body: 0UL, expression: 0xffffffffU, expected: 1UL, actual: 0UL, detail: (7UL << 32) | 1UL,
  }))
}

///|
test "physical type groups cannot silently omit a member" {
  let link = physical_type_test_link()
  let original = link.modules[0].type_groups[0]
  link.modules[0].type_groups[0] = {
    ..original, types: { ..original.types, length: 0, },
  }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 404, phase: 5, module_id: 23960UL, declaration: make_semantic_id(23960UL, 0),
    body: 0UL, expression: 0xffffffffU, expected: 1UL, actual: 0UL, detail: 11UL << 32,
  }))
}

///|
test "physical type relocation tables remain parallel" {
  let link = physical_type_test_link()
  let count = link.modules.length()
  let _ = link.module_type_indices.pop()
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 103, phase: 5, module_id: 0UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: count.to_uint64(), actual: (count - 1).to_uint64(), detail: 1UL << 32,
  }))
}

///|
test "each physical type has one owned relocation slot" {
  let link = physical_type_test_link()
  link.module_type_indices[0] = []
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 103, phase: 5, module_id: 23960UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: 1UL, actual: 0UL, detail: 12UL << 32,
  }))
}

///|
test "missing physical type relocations remain errors" {
  let link = physical_type_test_link()
  link.module_type_indices[0][0] = -1
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 503, phase: 5, module_id: 23960UL, declaration: make_semantic_id(23960UL, 0),
    body: 0UL, expression: 0xffffffffU, expected: link.type_count.to_uint64(), actual: 0xffffffffUL, detail: 14UL << 32,
  }))
}

///|
test "a physical type cannot select another in-range linked index" {
  let link = physical_type_test_link()
  let original = link.module_type_indices[0][0]
  let other = original + 1
  assert_true(other < link.type_count)
  link.module_type_indices[0][0] = other
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 504, phase: 5, module_id: 23960UL, declaration: make_semantic_id(23960UL, 0),
    body: 0UL, expression: 0xffffffffU, expected: original.to_uint64(), actual: other.to_uint64(), detail: 17UL << 32,
  }))
}

///|
test "recursive group spans are checked before reads" {
  let link = physical_type_test_link()
  let original = link.modules[0].type_groups[0]
  link.modules[0].type_groups[0] = { ..original, types: { start: 1, length: 1, }, }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 101, phase: 5, module_id: 23960UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: 1UL, actual: 0x100000001UL, detail: 8UL << 32,
  }))
}

///|
test "nominal type lookup cannot lose its physical declaration" {
  let link = physical_type_test_link()
  let declaration = make_semantic_id(23960UL, 0)
  let index = link.type_lookup[declaration]
  let _ = link.type_lookup.remove(declaration)
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 504, phase: 5, module_id: 23960UL, declaration,
    body: 0UL, expression: 0xffffffffU, expected: index.to_uint64(), actual: 0xffffffffUL, detail: 28UL << 32,
  }))
}

///|
test "physical modules retain their semantic identity" {
  let link = physical_type_test_link()
  link.module_lookup[23960UL] = 1
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 504, phase: 5, module_id: 23960UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: 0UL, actual: 1UL, detail: 27UL << 32,
  }))
}

///|
fn physical_type_test_cycle() -> PlannedProgramWasmGCLink raise {
  let program = collect_program_manifest(23962UL, ProgramManifest::new([
    ManifestModule::new("cycle.a", [ManifestFile::new("a.dew", b"open cycle.b\npub struct A {\n  b: B\n}\n")]),
    ManifestModule::new("cycle.b", [ManifestFile::new("b.dew", b"open cycle.a\npub struct B {\n  a: A\n}\n")]),
  ]))
  let analyzed = analyze_program_semantics(program)
  let link = plan_program_wasmgc_link(analyzed, plan_program_lowering(program, analyzed), 0)
  assert_eq(link.diagnostics, [])
  assert_true(!link.program_type_groups.is_empty())
  assert_eq(verify_program_physical_type_fragments(link), Ok(()))
  link
}

///|
fn physical_type_test_array_cycle() -> PlannedProgramWasmGCLink raise {
  let program = collect_program_manifest(23969UL, ProgramManifest::new([
    ManifestModule::new("cycle.a", [ManifestFile::new("a.dew", b"open cycle.b\nopen dew.std.wasm.intrinsics\npub struct A {\n  peer: B\n  chunks: WasmArray<V128>\n}\n")]),
    ManifestModule::new("cycle.b", [ManifestFile::new("b.dew", b"open cycle.a\npub struct B {\n  peer: A\n}\n")]),
  ]))
  let analyzed = analyze_program_semantics(program)
  let link = plan_program_wasmgc_link(analyzed, plan_program_lowering(program, analyzed), 0)
  assert_eq(link.diagnostics, [])
  assert_true(!link.program_type_groups.is_empty())
  assert_eq(link.fixed_array_type_base, 0)
  assert_eq(link.program_type_groups[0].first_type_index, 8)
  assert_eq(verify_program_physical_type_fragments(link), Ok(()))
  link
}

///|
test "raw array type prefixes cannot move behind nominal groups" {
  let link = physical_type_test_array_cycle()
  assert_eq(verify_program_physical_type_fragments({ ..link, fixed_array_type_base: 1, }), Err({
    code: 502, phase: 5, module_id: 0UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: 0UL, actual: 1UL, detail: 40UL << 32,
  }))
}

///|
test "recursive physical indices include the raw array type prefix" {
  let link = physical_type_test_array_cycle()
  let original = link.program_type_groups[0]
  link.program_type_groups[0] = { ..original, first_type_index: 0, }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 504, phase: 5, module_id: 0UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: 8UL, actual: 0UL, detail: 19UL << 32,
  }))
}

///|
test "cross-module physical type nodes require a valid source module" {
  let link = physical_type_test_cycle()
  let original = link.program_physical_types[0]
  link.program_physical_types[0] = { ..original, module_index: -1, }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 101, phase: 5, module_id: 0UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: link.modules.length().to_uint64(), actual: 0xffffffffUL, detail: 21UL << 32,
  }))
}

///|
test "cross-module recursive groups cannot erase their members" {
  let link = physical_type_test_cycle()
  let original = link.program_type_groups[0]
  link.program_type_groups[0] = { ..original, types: { ..original.types, length: 0, }, }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 404, phase: 5, module_id: 0UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: 1UL, actual: 0UL, detail: 20UL << 32,
  }))
}

///|
test "canonical signature owners are checked before reads" {
  let link = physical_type_test_link()
  let original = link.program_signature_types[0]
  link.program_signature_types[0] = { ..original, module_index: -1, }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 101, phase: 5, module_id: 0UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: link.modules.length().to_uint64(), actual: 0xffffffffUL, detail: 29UL << 32,
  }))
}

///|
test "canonical signatures require their source function" {
  let link = physical_type_test_link()
  let original = link.program_signature_types[0]
  assert_true(original.kind is PlannedProgramFunctionSignature(_))
  link.program_signature_types[0] = { ..original, kind: PlannedProgramFunctionSignature(-1), }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 101, phase: 5, module_id: 23960UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: link.modules[0].functions.length().to_uint64(), actual: 0xffffffffUL, detail: 31UL << 32,
  }))
}

///|
test "canonical signature physical indices cannot be duplicated" {
  let link = physical_type_test_link()
  let duplicate = link.program_signature_types[0]
  let slot = link.program_signature_types.length()
  assert_true(duplicate.kind is PlannedProgramFunctionSignature(_))
  link.program_signature_types.push(duplicate)
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 502, phase: 5, module_id: 23960UL, declaration: make_semantic_id(23960UL, 1),
    body: 0UL, expression: 0xffffffffU, expected: 1UL, actual: 2UL, detail: (35UL << 32) | slot.to_uint64(),
  }))
}

///|
test "the physical type count cannot include an unassigned slot" {
  let original = physical_type_test_link()
  let link = { ..original, type_count: original.type_count + 1, }
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 502, phase: 5, module_id: 0UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: link.type_count.to_uint64(), actual: original.type_count.to_uint64(), detail: 45UL << 32,
  }))
}

///|
test "erased boxes cannot reuse an existing physical type index" {
  let link = physical_type_test_link()
  assert_eq(link.erased_box_type_indices, [-1, -1, -1, -1, -1])
  assert_eq(link.initializer_type_index, -1)
  link.erased_box_type_indices[0] = 0
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 502, phase: 5, module_id: 0UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: link.type_count.to_uint64(), actual: 0UL, detail: 43UL << 32,
  }))
}

///|
test "the type section cannot omit all source signatures" {
  let link = physical_type_test_link()
  let count = link.type_count
  assert_eq(link.program_signature_types.length(), 1)
  link.program_signature_types.clear()
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 502, phase: 5, module_id: 0UL, declaration: 0UL,
    body: 0UL, expression: 0xffffffffU, expected: count.to_uint64(), actual: (count - 1).to_uint64(), detail: 45UL << 32,
  }))
}

///|
test "a value declaration cannot acquire a nominal type lookup entry" {
  let link = physical_type_test_link()
  let declaration = make_semantic_id(23960UL, 1)
  link.type_lookup[declaration] = link.module_type_indices[0][0]
  assert_eq(verify_program_physical_type_fragments(link), Err({
    code: 101, phase: 5, module_id: 23960UL, declaration,
    body: 0UL, expression: 0xffffffffU, expected: 1UL, actual: 0xffffffffUL, detail: 47UL << 32,
  }))
}
