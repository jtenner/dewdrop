///|
test "all specialized call consumers must use the frozen instance witness" {
  let (link, declaration) = ambiguous_specialization_test_link()
  let keys : Array[ProgramSpecializedCallKey] = []
  for key, witness in link.specialized_call_targets {
    if witness.declaration == declaration {
      keys.push(key)
    }
  }
  assert_eq(keys.length(), 2)
  let key = keys[0]
  let original = link.specialized_call_lookup[key]
  let other = link.specialized_call_lookup[keys[1]]
  assert_true(original != other)
  assert_eq(
    check_program_specialized_call_lookup(
      link,
      key.body,
      key.specialization_abi_key,
      key.expression,
    ),
    Ok(Some(link.functions[original])),
  )
  link.specialized_call_lookup[key] = other
  assert_eq(
    check_program_specialized_call_lookup(
      link,
      key.body,
      key.specialization_abi_key,
      key.expression,
    ),
    Err({
      code: 701,
      phase: 5,
      module_id: 24912UL,
      declaration,
      body: key.body,
      expression: key.expression.reinterpret_as_uint(),
      expected: 1UL,
      actual: 0UL,
      detail: (1UL << 32) | other.to_uint64(),
    }),
  )
}

///|
fn call_witness_lookup_test_link() -> (
  PlannedProgramWasmGCLink,
  ProgramSpecializedCallKey,
  Int,
) raise {
  let (link, declaration) = ambiguous_specialization_test_link(two=false)
  let keys : Array[ProgramSpecializedCallKey] = []
  for key, witness in link.specialized_call_targets {
    if witness.declaration == declaration {
      keys.push(key)
    }
  }
  assert_eq(keys.length(), 1)
  let key = keys[0]
  (link, key, link.specialized_call_lookup[key])
}

///|
fn call_witness_lookup_assert_failure(
  link : PlannedProgramWasmGCLink,
  key : ProgramSpecializedCallKey,
  declaration : DeclId,
  code : Int,
  expected : UInt64,
  actual : UInt64,
  detail : UInt64,
) -> Unit raise {
  let failure : ProgramFunctionLookupFailure = {
    code,
    phase: 5,
    module_id: 24912UL,
    declaration,
    body: key.body,
    expression: key.expression.reinterpret_as_uint(),
    expected,
    actual,
    detail,
  }
  assert_eq(
    check_program_specialized_call_lookup(
      link,
      key.body,
      key.specialization_abi_key,
      key.expression,
    ),
    Err(failure),
  )
  assert_eq(verify_program_specialized_call_lookups(link), Err(failure))
}

///|
test "valid indexed calls retain their target and absent probes stay absent" {
  let (link, key, index) = call_witness_lookup_test_link()
  assert_eq(verify_program_specialized_call_lookups(link), Ok(()))
  assert_eq(
    link.specialized_call_function(
      key.body,
      key.specialization_abi_key,
      key.expression,
    ),
    Some(link.functions[index]),
  )
  assert_eq(check_program_specialized_call_lookup(link, 0UL, "", -1), Ok(None))
  assert_eq(verify_program_specialized_call_lookups(link), Ok(()))
}

///|
test "an indexed call and its witness must have the same key set" {
  let (link, key, index) = call_witness_lookup_test_link()
  let witness = link.specialized_call_targets[key]
  let _ = link.specialized_call_lookup.remove(key)
  call_witness_lookup_assert_failure(
    link,
    key,
    witness.declaration,
    304,
    1UL,
    0UL,
    0UL,
  )
  link.specialized_call_lookup[key] = index
  let _ = link.specialized_call_targets.remove(key)
  call_witness_lookup_assert_failure(link, key, 0UL, 304, 1UL, 0UL, 1UL)
  link.specialized_call_targets[key] = witness
  assert_eq(verify_program_specialized_call_lookups(link), Ok(()))
}

///|
test "specialized call table indices are checked before reads" {
  let (link, key, original) = call_witness_lookup_test_link()
  let declaration = link.specialized_call_targets[key].declaration
  for index in [-1, link.functions.length()] {
    link.specialized_call_lookup[key] = index
    call_witness_lookup_assert_failure(
      link,
      key,
      declaration,
      101,
      link.functions.length().to_uint64(),
      index.reinterpret_as_uint().to_uint64(),
      0UL,
    )
  }
  link.specialized_call_lookup[key] = original
}

///|
test "specialized call physical indices remain equal to the saved witness" {
  let (link, key, index) = call_witness_lookup_test_link()
  let witness = link.specialized_call_targets[key]
  link.specialized_call_targets[key] = {
    ..witness,
    function_index: witness.function_index + 1,
  }
  call_witness_lookup_assert_failure(
    link,
    key,
    witness.declaration,
    701,
    (witness.function_index + 1).to_uint64(),
    witness.function_index.to_uint64(),
    (2UL << 32) | index.to_uint64(),
  )
  link.specialized_call_targets[key] = {
    ..witness,
    function_table_index: index + 1,
  }
  call_witness_lookup_assert_failure(
    link,
    key,
    witness.declaration,
    701,
    (index + 1).to_uint64(),
    index.to_uint64(),
    3UL << 32,
  )
  link.specialized_call_targets[key] = witness
}

///|
test "specialized call declaration cannot be replaced by another valid function" {
  let (link, key, original) = call_witness_lookup_test_link()
  let declaration = link.specialized_call_targets[key].declaration
  let other = declaration + 1UL
  let index = link.function_lookup[other]
  assert_eq(link.functions[index].declaration, other)
  link.specialized_call_lookup[key] = index
  call_witness_lookup_assert_failure(
    link,
    key,
    declaration,
    701,
    declaration,
    other,
    index.to_uint64(),
  )
  link.specialized_call_lookup[key] = original
}
