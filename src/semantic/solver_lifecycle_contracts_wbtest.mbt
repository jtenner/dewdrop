///|
test "failed unification finishes its owned work before the next operation" {
  let solver = root_contract_fixture()
  let i32 = solver.resolved_type(solver.resolved.primitive(I32Type))
  let i64 = solver.resolved_type(solver.resolved.primitive(I64Type))
  let left = solver.product_type([i32, i32])
  let right = solver.product_type([i64, i32])
  assert_false(solver.unify(left, right, synthetic_type_origin(0, 0UL)))
  assert_eq(solver.unify_left.length(), 0)
  assert_eq(solver.unify_right.length(), 0)
  assert_eq(solver.diagnostics.length(), 1)
  assert_true(solver.unify(i32, i32, synthetic_type_origin(0, 0UL)))
}

///|
test "occurs and unresolved searches finish their owned work" {
  let solver = root_contract_fixture()
  let first = solver.variable_types[0]
  let second = solver.variable_types[1]
  let product = solver.product_type([first, second])
  assert_true(solver.occurs_in(0, product))
  assert_eq(solver.occurs_stack.length(), 0)
  assert_true(solver.has_unresolved_variable(product))
  assert_eq(solver.occurs_stack.length(), 0)
}

///|
test "zonk returns its result without keeping a stale work result" {
  let solver = root_contract_fixture()
  let scalar = solver.resolved_type(solver.resolved.primitive(I32Type))
  let product = solver.product_type([scalar, scalar])
  assert_eq(solver.zonk_type(product), product)
  assert_eq(solver.zonk_task_types.length(), 0)
  assert_eq(solver.zonk_task_states.length(), 0)
  assert_eq(solver.zonk_result_starts.length(), 0)
  assert_eq(solver.zonk_results.length(), 0)
  assert_eq(solver.zonk_application_scratch.length(), 0)
  assert_eq(solver.zonk_type(scalar), scalar)
}

///|
test "solver boundaries preserve exact broken-array and pending-work records" {
  let solver = root_contract_fixture()
  assert_eq(solver.check_solver_boundary(true, 0), Ok(()))
  ignore(solver.zonk_values.pop())
  assert_eq(
    solver.check_solver_boundary(true, 0),
    Err({ code: 206, module_id: 80UL, expected: 3, actual: 2, detail: 12, }),
  )
  solver.zonk_values.push(0)
  solver.unify_left.push(0)
  assert_eq(
    solver.check_solver_boundary(true, 0),
    Err({ code: 206, module_id: 80UL, expected: 1, actual: 0, detail: 20, }),
  )
  solver.unify_right.push(0)
  assert_eq(
    solver.check_solver_boundary(true, 0),
    Err({ code: 206, module_id: 80UL, expected: 0, actual: 1, detail: 40, }),
  )
  solver.unify_left.clear()
  solver.unify_right.clear()
  solver.occurs_stack.push(0)
  assert_eq(
    solver.check_solver_boundary(true, 0),
    Err({ code: 206, module_id: 80UL, expected: 0, actual: 1, detail: 41, }),
  )
  solver.occurs_stack.clear()
  assert_eq(solver.check_solver_boundary(true, 0), Ok(()))
  solver.reset()
  assert_eq(solver.check_solver_boundary(true, 0), Ok(()))
}

///|
test "solver snapshots check LIFO and saved arena bounds before mutation" {
  let solver = root_contract_fixture()
  let outer = solver.snapshot()
  let inner = solver.snapshot()
  assert_eq(
    solver.check_solver_boundary(true, 0),
    Err({ code: 206, module_id: 80UL, expected: 0, actual: 2, detail: 0, }),
  )
  assert_eq(
    solver.check_snapshot_state(outer),
    Err({ code: 204, module_id: 80UL, expected: 1, actual: 0, detail: 2, }),
  )
  let invalid = { ..inner, argument_count: 1, }
  solver.snapshots[1] = invalid
  assert_eq(
    solver.check_snapshot_state(invalid),
    Err({ code: 204, module_id: 80UL, expected: 1, actual: 0, detail: 12, }),
  )
  assert_eq(solver.snapshots.length(), 2)
  solver.snapshots[1] = inner
  solver.commit(inner)
  solver.rollback(outer)
  assert_eq(
    solver.check_snapshot_state(outer),
    Err({ code: 204, module_id: 80UL, expected: 1, actual: 0, detail: 0, }),
  )
  assert_eq(solver.check_solver_boundary(true, 0), Ok(()))
}

///|
test "reset cannot discard an undo record without an owner snapshot" {
  let solver = root_contract_fixture()
  solver.undo_kinds.push(0)
  solver.undo_indices.push(0)
  solver.undo_values.push(0)
  assert_eq(
    solver.check_solver_boundary(true, 0),
    Err({ code: 205, module_id: 80UL, expected: 0, actual: 1, detail: 3, }),
  )
  assert_eq(solver.undo_kinds, [0])
  solver.undo_kinds.clear()
  solver.undo_indices.clear()
  solver.undo_values.clear()
  assert_eq(solver.check_solver_boundary(true, 0), Ok(()))
}
