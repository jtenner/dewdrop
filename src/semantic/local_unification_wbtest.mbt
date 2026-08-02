///|
fn unification_test_types() -> (CollectedModule, ResolvedModuleTypes) {
  let collected = collect_bytes(
    80UL, b"struct Pair<a, b> {}\nstruct List<t> {}\nfn accept(value: Pair<I32, String>) -> Unit {}\n",
  )
  (collected, resolve_module_types(collected))
}

///|
test "local unification binds and unions body-local variables" {
  let (_, resolved) = unification_test_types()
  let solver = LocalTypeSolver::new(resolved)
  let first = solver.fresh_variable()
  let second = solver.fresh_variable()
  let i32 = solver.resolved_type(resolved.primitive(I32Type))
  let origin = synthetic_type_origin(0, 1UL)
  assert_true(solver.unify(first, second, origin))
  assert_true(solver.unify(second, i32, origin))
  assert_eq(solver.representative_type(first), i32)
  assert_eq(solver.representative_type(second), i32)
  assert_eq(solver.diagnostics.length(), 0)
}

///|
test "local unification decomposes resolved and inferred applications" {
  let (collected, resolved) = unification_test_types()
  let solver = LocalTypeSolver::new(resolved)
  let first = solver.fresh_variable()
  let second = solver.fresh_variable()
  let pair = solver.resolved_type(
    resolved.declaration_type(collected.declarations[0].id),
  )
  let inferred = solver.applied_type(pair, [first, second])
  let declared = solver.resolved_type(resolved.parameter_types[0])
  assert_true(solver.unify(inferred, declared, synthetic_type_origin(1, 2UL)))
  assert_eq(
    solver.representative_type(first),
    solver.resolved_type(resolved.primitive(I32Type)),
  )
  assert_eq(
    solver.representative_type(second),
    solver.resolved_type(resolved.primitive(StringType)),
  )
}

///|
test "local unification reports one mismatch and poisons its variable" {
  let (_, resolved) = unification_test_types()
  let solver = LocalTypeSolver::new(resolved)
  let variable = solver.fresh_variable()
  let i32 = solver.resolved_type(resolved.primitive(I32Type))
  let string = solver.resolved_type(resolved.primitive(StringType))
  let origin = synthetic_type_origin(2, 3UL)
  assert_true(solver.unify(variable, i32, origin))
  assert_false(solver.unify(variable, string, origin))
  assert_eq(solver.representative_type(variable), solver.error_type())
  assert_eq(solver.diagnostics.length(), 1)
  match solver.diagnostics[0] {
    LocalTypeMismatch(actual, expected, diagnostic_origin) => {
      assert_eq(actual, i32)
      assert_eq(expected, string)
      assert_eq(diagnostic_origin, origin)
    }
    _ => fail("expected local type mismatch")
  }
  assert_true(solver.unify(variable, string, origin))
  assert_eq(solver.diagnostics.length(), 1)
}

///|
test "local unification rejects infinite types with an iterative occurs check" {
  let (collected, resolved) = unification_test_types()
  let solver = LocalTypeSolver::new(resolved)
  let variable = solver.fresh_variable()
  let list = solver.resolved_type(
    resolved.declaration_type(collected.declarations[1].id),
  )
  let recursive = solver.applied_type(list, [variable])
  let origin = synthetic_type_origin(3, 4UL)
  assert_false(solver.unify(variable, recursive, origin))
  assert_eq(solver.representative_type(variable), solver.error_type())
  assert_eq(solver.diagnostics.length(), 1)
  match solver.diagnostics[0] {
    InfiniteLocalType(_, type_, diagnostic_origin) => {
      assert_eq(type_, recursive)
      assert_eq(diagnostic_origin, origin)
    }
    _ => fail("expected infinite local type")
  }
}

///|
test "inference snapshots roll back bindings allocations and diagnostics" {
  let (_, resolved) = unification_test_types()
  let solver = LocalTypeSolver::new(resolved)
  let variable = solver.fresh_variable()
  let i32 = solver.resolved_type(resolved.primitive(I32Type))
  let string = solver.resolved_type(resolved.primitive(StringType))
  let origin = synthetic_type_origin(4, 5UL)
  let type_count = solver.types.length()
  let snapshot = solver.snapshot()
  let temporary = solver.fresh_variable()
  ignore(solver.applied_type(i32, [temporary]))
  assert_true(solver.unify(variable, i32, origin))
  assert_false(solver.unify(variable, string, origin))
  assert_eq(solver.diagnostics.length(), 1)
  solver.rollback(snapshot)
  assert_eq(solver.types.length(), type_count)
  assert_eq(solver.diagnostics.length(), 0)
  assert_true(solver.has_unresolved_variable(variable))
  assert_true(solver.unify(variable, string, origin))
  assert_eq(solver.representative_type(variable), string)
}

///|
test "committed inference snapshots preserve selected candidate bindings" {
  let (_, resolved) = unification_test_types()
  let solver = LocalTypeSolver::new(resolved)
  let variable = solver.fresh_variable()
  let i32 = solver.resolved_type(resolved.primitive(I32Type))
  let snapshot = solver.snapshot()
  assert_true(solver.unify(variable, i32, synthetic_type_origin(5, 6UL)))
  solver.commit(snapshot)
  assert_eq(solver.representative_type(variable), i32)
  assert_eq(solver.snapshots.length(), 0)
  assert_eq(solver.undo_kinds.length(), 0)
}

///|
test "nested inference snapshots remain rollback-safe" {
  let (_, resolved) = unification_test_types()
  let solver = LocalTypeSolver::new(resolved)
  let first = solver.fresh_variable()
  let i32 = solver.resolved_type(resolved.primitive(I32Type))
  let outer = solver.snapshot()
  assert_true(solver.unify(first, i32, synthetic_type_origin(6, 7UL)))
  let inner = solver.snapshot()
  let second = solver.fresh_variable()
  assert_true(solver.unify(second, i32, synthetic_type_origin(7, 8UL)))
  solver.commit(inner)
  solver.rollback(outer)
  assert_true(solver.has_unresolved_variable(first))
  assert_eq(solver.variable_parents.length(), 1)
}

///|
test "zonking freezes bound application variables and propagates poison" {
  let (collected, resolved) = unification_test_types()
  let solver = LocalTypeSolver::new(resolved)
  let first = solver.fresh_variable()
  let second = solver.fresh_variable()
  let pair = solver.resolved_type(
    resolved.declaration_type(collected.declarations[0].id),
  )
  let inferred = solver.applied_type(pair, [first, second])
  assert_true(
    solver.unify(
      first,
      solver.resolved_type(resolved.primitive(I32Type)),
      synthetic_type_origin(8, 9UL),
    ),
  )
  assert_true(
    solver.unify(
      second,
      solver.resolved_type(resolved.primitive(StringType)),
      synthetic_type_origin(9, 10UL),
    ),
  )
  let frozen = solver.zonk_type(inferred)
  assert_false(solver.has_unresolved_variable(frozen))
  match solver.type_term(frozen) {
    BodyAppliedType(base, arguments) => {
      assert_eq(base, pair)
      assert_eq(
        solver.type_arguments[arguments.start],
        solver.resolved_type(resolved.primitive(I32Type)),
      )
      assert_eq(
        solver.type_arguments[arguments.start + 1],
        solver.resolved_type(resolved.primitive(StringType)),
      )
    }
    _ => fail("expected frozen applied body type")
  }
  let poisoned = solver.applied_type(pair, [solver.error_type(), second])
  assert_eq(solver.zonk_type(poisoned), solver.error_type())
}

///|
test "unification and occurs checking remain iterative at depth 1024" {
  let (collected, resolved) = unification_test_types()
  let solver = LocalTypeSolver::new(resolved)
  let list = solver.resolved_type(
    resolved.declaration_type(collected.declarations[1].id),
  )
  let variable = solver.fresh_variable()
  let mut nested = variable
  for _ in 0..<1024 {
    nested = solver.applied_type(list, [nested])
  }
  assert_false(solver.unify(variable, nested, synthetic_type_origin(10, 11UL)))
  assert_eq(solver.representative_type(variable), solver.error_type())
}

///|
test "union-find remains iterative for 1024 equivalent variables" {
  let (_, resolved) = unification_test_types()
  let solver = LocalTypeSolver::new(resolved)
  let variables : Array[BodyTypeId] = []
  for _ in 0..<1024 {
    variables.push(solver.fresh_variable())
  }
  let origin = synthetic_type_origin(11, 12UL)
  for index in 1..<variables.length() {
    assert_true(solver.unify(variables[0], variables[index], origin))
  }
  let i32 = solver.resolved_type(resolved.primitive(I32Type))
  assert_true(solver.unify(variables[variables.length() - 1], i32, origin))
  for variable in variables {
    assert_eq(solver.representative_type(variable), i32)
  }
}
