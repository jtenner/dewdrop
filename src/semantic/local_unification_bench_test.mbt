///|
fn unification_benchmark_types() -> (CollectedModule, ResolvedModuleTypes) {
  let collected = collect_bytes(
    1UL, b"struct Pair<a, b> {}\nstruct List<t> {}\nfn accept(value: Pair<I32, String>) -> Unit {}\n",
  )
  (collected, resolve_module_types(collected))
}

///|
fn benchmark_parameter_argument(
  resolved : ResolvedModuleTypes,
  index : Int,
) -> ResolvedTypeId {
  let parameter = resolved.parameter_types[0]
  match resolved.types[parameter] {
    AppliedType(_, arguments) =>
      resolved.type_arguments[arguments.start + index]
    _ => abort("expected benchmark Pair application")
  }
}

///|
test "bench inference union variables n=4096" (it : @bench.T) {
  let (_, resolved) = unification_benchmark_types()
  let i32_resolved = benchmark_parameter_argument(resolved, 0)
  it.bench(fn() {
    let solver = LocalTypeSolver::new(resolved)
    let variables : Array[BodyTypeId] = []
    for _ in 0..<4096 {
      variables.push(solver.fresh_variable())
    }
    let origin = synthetic_type_origin(0, 0UL)
    for index in 1..<variables.length() {
      ignore(solver.unify(variables[0], variables[index], origin))
    }
    ignore(
      solver.unify(variables[0], solver.resolved_type(i32_resolved), origin),
    )
    it.keep(solver.representative_type(variables[4095]))
  })
}

///|
test "bench inference unify nested applications depth=512" (it : @bench.T) {
  let (collected, resolved) = unification_benchmark_types()
  let list_resolved = resolved.declaration_type(collected.declarations[1].id)
  let i32_resolved = benchmark_parameter_argument(resolved, 0)
  it.bench(fn() {
    let solver = LocalTypeSolver::new(resolved)
    let list = solver.resolved_type(list_resolved)
    let variable = solver.fresh_variable()
    let mut left = solver.resolved_type(i32_resolved)
    let mut right = variable
    for _ in 0..<512 {
      left = solver.applied_type(list, [left])
      right = solver.applied_type(list, [right])
    }
    ignore(solver.unify(left, right, synthetic_type_origin(0, 0UL)))
    it.keep(solver.representative_type(variable))
  })
}

///|
test "bench inference occurs check depth=1024" (it : @bench.T) {
  let (collected, resolved) = unification_benchmark_types()
  let list_resolved = resolved.declaration_type(collected.declarations[1].id)
  it.bench(fn() {
    let solver = LocalTypeSolver::new(resolved)
    let list = solver.resolved_type(list_resolved)
    let variable = solver.fresh_variable()
    let mut recursive = variable
    for _ in 0..<1024 {
      recursive = solver.applied_type(list, [recursive])
    }
    ignore(solver.unify(variable, recursive, synthetic_type_origin(0, 0UL)))
    it.keep(solver.diagnostics.length())
  })
}

///|
test "bench inference rollback candidate trials n=256" (it : @bench.T) {
  let (collected, resolved) = unification_benchmark_types()
  let pair_resolved = resolved.declaration_type(collected.declarations[0].id)
  let i32_resolved = benchmark_parameter_argument(resolved, 0)
  let string_resolved = benchmark_parameter_argument(resolved, 1)
  it.bench(fn() {
    let solver = LocalTypeSolver::new(resolved)
    let pair = solver.resolved_type(pair_resolved)
    let origin = synthetic_type_origin(0, 0UL)
    for index in 0..<256 {
      let snapshot = solver.snapshot()
      let variable = solver.fresh_variable()
      let primitive = if index % 2 == 0 {
        solver.resolved_type(i32_resolved)
      } else {
        solver.resolved_type(string_resolved)
      }
      ignore(solver.applied_type(pair, [variable, primitive]))
      ignore(solver.unify(variable, primitive, origin))
      solver.rollback(snapshot)
    }
    it.keep(solver.types.length())
  })
}

///|
test "bench inference mixed resolved application n=1024" (it : @bench.T) {
  let (_, resolved) = unification_benchmark_types()
  let declared_resolved = resolved.parameter_types[0]
  it.bench(fn() {
    let solver = LocalTypeSolver::new(resolved)
    let declared = solver.resolved_type(declared_resolved)
    let origin = synthetic_type_origin(0, 0UL)
    let mut completed = 0
    for _ in 0..<1024 {
      let first = solver.fresh_variable()
      let second = solver.fresh_variable()
      let pair_base = match resolved.types[declared_resolved] {
        AppliedType(base, _) => solver.resolved_type(base)
        _ => abort("expected benchmark Pair application")
      }
      let inferred = solver.applied_type(pair_base, [first, second])
      if solver.unify(inferred, declared, origin) {
        completed += 1
      }
    }
    it.keep(completed)
  })
}

///|
test "bench inference zonk applications depth=512" (it : @bench.T) {
  let (collected, resolved) = unification_benchmark_types()
  let list_resolved = resolved.declaration_type(collected.declarations[1].id)
  let i32_resolved = benchmark_parameter_argument(resolved, 0)
  it.bench(fn() {
    let solver = LocalTypeSolver::new(resolved)
    let list = solver.resolved_type(list_resolved)
    let variable = solver.fresh_variable()
    let mut nested = variable
    for _ in 0..<512 {
      nested = solver.applied_type(list, [nested])
    }
    ignore(
      solver.unify(
        variable,
        solver.resolved_type(i32_resolved),
        synthetic_type_origin(0, 0UL),
      ),
    )
    it.keep(solver.zonk_type(nested))
  })
}
