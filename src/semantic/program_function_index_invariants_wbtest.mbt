///|
test "physical function indices are a total unique partition" {
  let (program, analyzed) = scalar_link_program()
  let link = plan_program_wasmgc_link(
    analyzed,
    plan_program_lowering(program, analyzed),
    0,
  )
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(verify_program_function_indices(link), Ok(()))
  // Table order is not physical identity in the native compiler.
  let slots : Array[Int] = []
  for index, function_ in link.functions {
    if function_.function_index >= 0 {
      slots.push(index)
    }
  }
  assert_eq(slots.length(), 2)
  let left = slots[0]
  let right = slots[1]
  let first = link.functions[left]
  link.functions[left] = link.functions[right]
  link.functions[right] = first
  assert_eq(verify_program_function_indices(link), Ok(()))
  let original = link.functions[right].function_index
  link.functions[right].function_index = link.functions[left].function_index
  assert_eq(
    verify_program_function_indices(link),
    Err({
      function_slot: right,
      expected: 0,
      actual: link.functions[left].function_index,
      detail: 1,
    }),
  )
  link.functions[right].function_index = original
  link.functions[right].function_index = 99
  assert_eq(
    verify_program_function_indices(link),
    Err({ function_slot: right, expected: 2, actual: 99, detail: 0, }),
  )
}

///|
test "missing physical functions cannot leave an unassigned index" {
  let (program, analyzed) = scalar_link_program()
  let link = plan_program_wasmgc_link(
    analyzed,
    plan_program_lowering(program, analyzed),
    0,
  )
  let missing = link.functions.pop().unwrap().function_index
  assert_eq(
    verify_program_function_indices(link),
    Err({ function_slot: -1, expected: 1, actual: missing, detail: 2, }),
  )
}

///|
test "function import counts cannot reclassify a definition" {
  let (program, analyzed) = scalar_link_program()
  let link = plan_program_wasmgc_link(
    analyzed,
    plan_program_lowering(program, analyzed),
    0,
  )
  let invalid = {
    ..link,
    imported_function_count: 1,
    defined_function_count: 1,
  }
  match verify_program_function_indices(invalid) {
    Err(failure) => {
      assert_eq(failure.expected, 1)
      assert_eq(failure.actual, 0)
      assert_eq(failure.detail, 6)
    }
    Ok(_) => fail("wrong import prefix must be rejected")
  }
}

///|
test "physical function counts cannot overflow" {
  let (program, analyzed) = scalar_link_program()
  let link = plan_program_wasmgc_link(
    analyzed,
    plan_program_lowering(program, analyzed),
    0,
  )
  let invalid = { ..link, imported_function_count: 2147483647, }
  assert_eq(
    verify_program_function_indices(invalid),
    Err({
      function_slot: -1,
      expected: 2147483647,
      actual: 2147483647,
      detail: 3,
    }),
  )
}
