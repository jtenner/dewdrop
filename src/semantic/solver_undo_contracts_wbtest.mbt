///|
/// Start from real union records and change one field at a time.
test "solver undo records reject length kind index and old value corruption" {
  let solver = root_contract_fixture()
  let snapshot = solver.snapshot()
  ignore(solver.union_variables(0, 1))
  assert_eq(solver.check_undo_restore(snapshot.undo_start), Ok(()))
  let count = solver.undo_kinds.length()
  let old_index = solver.undo_indices[count - 1]
  ignore(solver.undo_indices.pop())
  assert_eq(
    solver.check_undo_restore(0),
    Err({
      code: 205,
      module_id: 80UL,
      expected: count,
      actual: count - 1,
      detail: 1,
    }),
  )
  solver.undo_indices.push(old_index)
  let old_value = solver.undo_values[count - 1]
  ignore(solver.undo_values.pop())
  assert_eq(
    solver.check_undo_restore(0),
    Err({
      code: 205,
      module_id: 80UL,
      expected: count,
      actual: count - 1,
      detail: 2,
    }),
  )
  solver.undo_values.push(old_value)
  let kind = solver.undo_kinds[0]
  solver.undo_kinds[0] = 3
  assert_eq(
    solver.check_undo_record(0),
    Err({ code: 205, module_id: 80UL, expected: 2, actual: 3, detail: 0, }),
  )
  solver.undo_kinds[0] = kind
  let index = solver.undo_indices[0]
  solver.undo_indices[0] = 2
  assert_eq(
    solver.check_undo_record(0),
    Err({ code: 205, module_id: 80UL, expected: 2, actual: 2, detail: kind, }),
  )
  solver.undo_indices[0] = index
  let value = solver.undo_values[0]
  solver.undo_values[0] = 2
  assert_eq(
    solver.check_undo_record(0),
    Err({ code: 205, module_id: 80UL, expected: 2, actual: 2, detail: index, }),
  )
  solver.undo_values[0] = value
  solver.rollback(snapshot)
  assert_eq(solver.variable_parents, [0, 1])
  assert_eq(solver.variable_sizes, [1, 1])
  assert_eq(solver.variable_bindings, [-1, -1])
  assert_eq(solver.undo_kinds, [])
  assert_eq(solver.undo_indices, [])
  assert_eq(solver.undo_values, [])
}

///|
test "solver undo validates every record before restoring any state" {
  let solver = root_contract_fixture()
  let snapshot = solver.snapshot()
  ignore(solver.union_variables(0, 1))
  solver.undo_kinds[0] = -1
  let parents = solver.variable_parents.copy()
  let sizes = solver.variable_sizes.copy()
  let kinds = solver.undo_kinds.copy()
  assert_eq(
    solver.check_undo_restore(0),
    Err({ code: 205, module_id: 80UL, expected: 2, actual: -1, detail: 0, }),
  )
  assert_eq(solver.variable_parents, parents)
  assert_eq(solver.variable_sizes, sizes)
  assert_eq(solver.undo_kinds, kinds)
  solver.undo_kinds[0] = 0
  solver.rollback(snapshot)
}

///|
test "solver undo rejects invalid ranges and binding certificates" {
  let solver = root_contract_fixture()
  assert_eq(
    solver.check_undo_restore(-1),
    Err({ code: 205, module_id: 80UL, expected: 0, actual: -1, detail: 0, }),
  )
  assert_eq(
    solver.check_undo_restore(1),
    Err({ code: 205, module_id: 80UL, expected: 0, actual: 1, detail: 0, }),
  )
  solver.undo_kinds.push(2)
  solver.undo_indices.push(0)
  solver.undo_values.push(solver.types.length())
  assert_eq(
    solver.check_undo_record(0),
    Err({
      code: 205,
      module_id: 80UL,
      expected: solver.types.length(),
      actual: solver.types.length(),
      detail: 0,
    }),
  )
  solver.undo_values[0] = -2147483648
  assert_eq(
    solver.check_undo_record(0),
    Err({
      code: 205,
      module_id: 80UL,
      expected: solver.resolved.types.length(),
      actual: 2147483646,
      detail: 0,
    }),
  )
  solver.undo_values[0] = -1
  assert_eq(solver.check_undo_record(0), Ok(()))
  solver.undo_kinds[0] = 1
  solver.undo_values[0] = 0
  assert_eq(
    solver.check_undo_record(0),
    Err({ code: 205, module_id: 80UL, expected: 2, actual: 0, detail: 0, }),
  )
}

///|
test "nested rollback restores complete saved arena and binding contents" {
  let solver = root_contract_fixture()
  let first = solver.variable_types[0]
  let second = solver.variable_types[1]
  let i32 = solver.resolved_type(solver.resolved.primitive(I32Type))
  let string = solver.resolved_type(solver.resolved.primitive(StringType))
  ignore(solver.product_type([first, i32]))
  let types = solver.types.copy()
  let arguments = solver.type_arguments.copy()
  let parents = solver.variable_parents.copy()
  let sizes = solver.variable_sizes.copy()
  let bindings = solver.variable_bindings.copy()
  let variables = solver.variable_types.copy()
  let diagnostics = solver.diagnostics.copy()
  let outer = solver.snapshot()
  assert_true(solver.unify(first, second, synthetic_type_origin(0, 0UL)))
  let inner = solver.snapshot()
  let temporary = solver.fresh_variable()
  ignore(solver.product_type([temporary, first]))
  assert_true(solver.unify(first, i32, synthetic_type_origin(0, 0UL)))
  assert_false(solver.unify(first, string, synthetic_type_origin(0, 0UL)))
  solver.commit(inner)
  solver.rollback(outer)
  assert_eq(solver.types, types)
  assert_eq(solver.type_arguments, arguments)
  assert_eq(solver.variable_parents, parents)
  assert_eq(solver.variable_sizes, sizes)
  assert_eq(solver.variable_bindings, bindings)
  assert_eq(solver.variable_types, variables)
  assert_eq(solver.diagnostics, diagnostics)
  assert_eq(solver.snapshots, [])
  assert_eq(solver.undo_kinds, [])
  assert_eq(solver.undo_indices, [])
  assert_eq(solver.undo_values, [])
}
