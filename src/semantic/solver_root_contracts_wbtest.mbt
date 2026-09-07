///|
fn root_contract_fixture() -> LocalTypeSolver {
  let resolved = resolve_module_types(collect_bytes(80UL, b""))
  let solver = LocalTypeSolver::new(resolved)
  ignore(solver.fresh_variable())
  ignore(solver.fresh_variable())
  solver
}

///|
test "solver parent walks check cycles indices and parallel arrays" {
  let solver = root_contract_fixture()
  solver.variable_parents[1] = 0
  assert_eq(solver.check_variable_root(1), Ok(0))
  solver.variable_parents[0] = 1
  assert_eq(
    solver.check_variable_root(0),
    Err({ code: 202, module_id: 80UL, expected: 2, actual: 2, detail: 0, }),
  )
  solver.variable_parents[0] = 2
  assert_eq(
    solver.check_variable_root(0),
    Err({ code: 202, module_id: 80UL, expected: 2, actual: 2, detail: 0, }),
  )
  solver.variable_parents[0] = 0
  ignore(solver.variable_sizes.pop())
  assert_eq(
    solver.check_variable_root(0),
    Err({ code: 201, module_id: 80UL, expected: 2, actual: 1, detail: 1, }),
  )
}

///|
test "solver binding cycles are distinct from a valid parent forest" {
  let solver = root_contract_fixture()
  let first = solver.variable_types[0]
  let second = solver.variable_types[1]
  solver.variable_bindings[0] = second
  assert_eq(solver.check_representative_type(first), Ok(second))
  solver.variable_bindings[1] = first
  assert_eq(
    solver.check_representative_type(first),
    Err({ code: 202, module_id: 80UL, expected: 2, actual: 2, detail: first, }),
  )
}

///|
test "solver representative reads check binding IDs and stored variable identities" {
  let solver = root_contract_fixture()
  let first = solver.variable_types[0]
  solver.variable_bindings[0] = solver.types.length()
  assert_eq(
    solver.check_representative_type(first),
    Err({
      code: 104,
      module_id: 80UL,
      expected: solver.types.length(),
      actual: solver.types.length(),
      detail: first,
    }),
  )
  solver.variable_bindings[0] = -1
  solver.variable_types[0] = solver.variable_types[1]
  assert_eq(
    solver.check_representative_type(first),
    Err({
      code: 201,
      module_id: 80UL,
      expected: 0,
      actual: solver.variable_types[1],
      detail: 4,
    }),
  )
}

///|
test "checked solver roots keep compression outside transactions only" {
  let solver = root_contract_fixture()
  ignore(solver.fresh_variable())
  solver.variable_parents[2] = 1
  solver.variable_parents[1] = 0
  let before = solver.variable_parents.copy()
  let snapshot = solver.snapshot()
  assert_eq(solver.find_variable_root(2), 0)
  assert_eq(solver.variable_parents, before)
  solver.rollback(snapshot)
  assert_eq(solver.find_variable_root(2), 0)
  assert_eq(solver.variable_parents, [0, 0, 0])
}
