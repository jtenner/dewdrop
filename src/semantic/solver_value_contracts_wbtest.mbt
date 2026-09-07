///| Numeric limits are checked without allocating large arenas.
test "solver union sizes require distinct roots and bounded disjoint sizes" {
  let solver = root_contract_fixture()
  assert_eq(solver.check_union_size(0, 1), Ok(2))
  solver.variable_sizes[0] = 2147483647
  assert_eq(solver.check_union_size(0, 1), Err({
    code: 203, module_id: 80UL, expected: 2, actual: 2147483647, detail: 0,
  }))
  solver.variable_sizes[0] = 0
  assert_eq(solver.check_union_size(0, 1), Err({
    code: 203, module_id: 80UL, expected: 2, actual: 0, detail: 0,
  }))
  solver.variable_sizes[0] = 2
  assert_eq(solver.check_union_size(0, 1), Err({
    code: 203, module_id: 80UL, expected: 0, actual: 1, detail: 1,
  }))
  solver.variable_sizes[0] = 1
  solver.variable_parents[1] = 0
  assert_eq(solver.check_union_size(0, 1), Err({
    code: 203, module_id: 80UL, expected: 0, actual: 1, detail: 0,
  }))
  solver.variable_parents[1] = 1
  assert_eq(solver.check_union_size(0, 0), Err({
    code: 203, module_id: 80UL, expected: 1, actual: 0, detail: 0,
  }))
}

///|
test "solver resolved encoding checks machine limits and source arena bounds" {
  let solver = root_contract_fixture()
  let type_ = solver.resolved.primitive(I32Type)
  assert_eq(solver.check_resolved_type_encoding(type_), Ok(-type_ - 2))
  assert_eq(solver.check_resolved_type_encoding(solver.resolved.error_type), Ok(0))
  assert_eq(solver.check_resolved_type_encoding(2147483647), Err({
    code: 207, module_id: 80UL, expected: 2147483646, actual: 2147483647, detail: 0,
  }))
  assert_eq(solver.check_resolved_type_encoding(-1), Err({
    code: 104, module_id: 80UL, expected: solver.resolved.types.length(), actual: -1, detail: 0,
  }))
  assert_eq(solver.check_resolved_type_encoding(solver.resolved.types.length()), Err({
    code: 104, module_id: 80UL, expected: solver.resolved.types.length(), actual: solver.resolved.types.length(), detail: 0,
  }))
}
