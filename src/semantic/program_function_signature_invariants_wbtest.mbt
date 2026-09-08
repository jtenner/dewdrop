///|
test "named linked signatures retain the source parameter span" {
  let (link, declaration, index) = function_lookup_test_link()
  let original = link.functions[index]
  assert_eq(original.parameters.length, 1)
  assert_eq(
    check_program_named_function_lookup(link, declaration),
    Ok(Some(original)),
  )
  link.functions[index] = {
    ..original,
    parameters: { ..original.parameters, length: 0, },
  }
  assert_eq(
    check_program_named_function_lookup(link, declaration),
    Err({
      code: 504,
      phase: 5,
      module_id: 2100UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: (original.parameters.start.to_uint64() << 32) | 1UL,
      actual: original.parameters.start.to_uint64() << 32,
      detail: (9UL << 32) | index.to_uint64(),
    }),
  )
}

///|
test "linked function copies retain every physical signature field" {
  let (link, declaration, index) = function_lookup_test_link()
  let original = link.functions[index]
  let cases : Array[(PlannedProgramWasmFunction, UInt64, UInt64, UInt64)] = [
    (
      { ..original, results: { ..original.results, length: 0, }, },
      10UL,
      program_function_span_code(original.results),
      original.results.start.to_uint64() << 32,
    ),
    (
      {
        ..original,
        specialization_shapes: { ..original.specialization_shapes, start: -1, },
      },
      11UL,
      program_function_span_code(original.specialization_shapes),
      0xffffffff00000000UL,
    ),
    (
      {
        ..original,
        specialization_evidence: {
          ..original.specialization_evidence,
          start: -1,
        },
      },
      12UL,
      program_function_span_code(original.specialization_evidence),
      0xffffffff00000000UL,
    ),
    ({ ..original, direct_builtin: b"i32.add", }, 13UL, 1UL, 0UL),
    ({ ..original, elided: true, }, 14UL, 0UL, 1UL),
    (
      { ..original, signature_type_index: -1, },
      15UL,
      original.signature_type_index.to_uint64(),
      0xffffffffUL,
    ),
  ]
  for item in cases {
    let (changed, role, expected, actual) = item
    link.functions[index] = changed
    let failure : ProgramFunctionLookupFailure = {
      code: 504,
      phase: 5,
      module_id: 2100UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected,
      actual,
      detail: (role << 32) | index.to_uint64(),
    }
    assert_eq(
      check_program_named_function_lookup(link, declaration),
      Err(failure),
    )
    assert_eq(verify_program_source_function_fragments(link), Err(failure))
  }
  link.functions[index] = original
  assert_eq(verify_program_source_function_fragments(link), Ok(()))
}

///|
test "source signature spans are checked against their arena" {
  let (link, declaration, index) = function_lookup_test_link()
  let function_ = link.functions[index]
  let original = link.modules[function_.module_index]
  link.modules[function_.module_index] = {
    ..original,
    function_value_types: [],
  }
  assert_eq(
    check_program_named_function_lookup(link, declaration),
    Err({
      code: 101,
      phase: 5,
      module_id: 2100UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: 0UL,
      actual: program_function_span_code(function_.parameters),
      detail: (9UL << 32) | index.to_uint64(),
    }),
  )
}

///|
test "signature relocation rejects missing maps and unassigned indices" {
  let (link, declaration, index) = function_lookup_test_link()
  let function_ = link.functions[index]
  let module_ = link.modules[function_.module_index]
  let source = module_.functions[function_.fragment_index]
  let local_slot = source.signature_type_index - module_.physical_types.length()
  assert_true(local_slot >= 0)
  let indices = link.module_signature_indices[function_.module_index]
  let original = indices[local_slot]
  indices[local_slot] = -1
  assert_eq(
    check_program_named_function_lookup(link, declaration),
    Err({
      code: 503,
      phase: 5,
      module_id: 2100UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: link.type_count.to_uint64(),
      actual: 0xffffffffUL,
      detail: (18UL << 32) | index.to_uint64(),
    }),
  )
  indices[local_slot] = original
  let changed = { ..link, module_signature_indices: [], }
  assert_eq(
    check_program_named_function_lookup(changed, declaration),
    Err({
      code: 101,
      phase: 5,
      module_id: 2100UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: 0UL,
      actual: function_.module_index.to_uint64(),
      detail: (16UL << 32) | index.to_uint64(),
    }),
  )
  link.module_signature_indices[function_.module_index] = []
  assert_eq(
    check_program_named_function_lookup(link, declaration),
    Err({
      code: 101,
      phase: 5,
      module_id: 2100UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: 0UL,
      actual: local_slot.to_uint64(),
      detail: (17UL << 32) | index.to_uint64(),
    }),
  )
}

///|
test "every source function fragment has exactly one linked record" {
  let (link, declaration, index) = function_lookup_test_link()
  let function_ = link.functions[index]
  let duplicate_index = link.functions.length()
  link.functions.push(function_)
  assert_eq(
    verify_program_source_function_fragments(link),
    Err({
      code: 404,
      phase: 5,
      module_id: 2100UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: 1UL,
      actual: 2UL,
      detail: duplicate_index.to_uint64(),
    }),
  )
  let _ = link.functions.pop()
  let remaining = link.functions.filter(fn(value) { value != function_ })
  assert_eq(remaining.length(), link.functions.length() - 1)
  let missing = { ..link, functions: remaining, }
  assert_eq(
    verify_program_source_function_fragments(missing),
    Err({
      code: 404,
      phase: 5,
      module_id: 2100UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: 1UL,
      actual: 0UL,
      detail: (function_.module_index.to_uint64() << 32) |
      function_.fragment_index.to_uint64(),
    }),
  )
}

///|
test "specialized functions retain their source result signature" {
  let (link, key, index) = call_witness_lookup_test_link()
  let original = link.functions[index]
  assert_true(original.specialization_shapes.length > 0)
  assert_eq(original.results.length, 1)
  assert_eq(verify_program_source_function_fragments(link), Ok(()))
  link.functions[index] = {
    ..original,
    results: { ..original.results, length: 0, },
  }
  assert_eq(
    verify_program_source_function_fragments(link),
    Err({
      code: 504,
      phase: 5,
      module_id: 24912UL,
      declaration: original.declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: program_function_span_code(original.results),
      actual: original.results.start.to_uint64() << 32,
      detail: (10UL << 32) | index.to_uint64(),
    }),
  )
  assert_eq(link.specialized_call_lookup[key], index)
}
