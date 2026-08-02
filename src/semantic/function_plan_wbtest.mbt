///|
test "function plans retain top-level and builtin ABI shapes" {
  let collected = collect_bytes(
    961UL, b"builtin identity<t>(value: t) -> t = \"identity\"\nfn widen(value: I32) -> I64 {\n  1L\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let functions = plan_module_functions(collected, resolved)
  assert_eq(functions.callables.length(), 2)
  let builtin = functions.callables[0]
  match builtin.kind {
    PlannedBuiltinCallable(name) => assert_eq(name, b"identity")
    _ => fail("expected builtin callable")
  }
  assert_eq(builtin.generic_parameters.length, 1)
  assert_eq(builtin.result_shape, GenericPlannedValueShape)
  assert_eq(
    functions.parameters[builtin.parameters.start].shape,
    GenericPlannedValueShape,
  )
  let function_ = functions.callables[1]
  match function_.kind {
    PlannedFunctionCallable(body) => assert_eq(body, collected.bodies[0].id)
    _ => fail("expected function callable")
  }
  assert_eq(
    functions.parameters[function_.parameters.start].shape,
    I32PlannedValueShape,
  )
  assert_eq(function_.result_shape, I64PlannedValueShape)
}

///|
test "function plans substitute impl Self shape for reference and scalar receivers" {
  let collected = collect_bytes(
    962UL, b"struct Item {}\nimpl Item {\n  fn read(self) -> I32 {\n    1\n  }\n}\nimpl I32 {\n  fn next(self) -> I32 {\n    self + 1\n  }\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let functions = plan_module_functions(collected, resolved)
  assert_eq(functions.callables.length(), 2)
  let reference_method = functions.callables[0]
  match reference_method.kind {
    PlannedImplMethodCallable(parent, Some(_)) =>
      assert_eq(parent, collected.impls[0].declaration)
    _ => fail("expected impl method")
  }
  assert_eq(reference_method.self_shape, RefPlannedValueShape)
  assert_eq(
    functions.parameters[reference_method.parameters.start].shape,
    RefPlannedValueShape,
  )
  let scalar_method = functions.callables[1]
  assert_eq(scalar_method.self_shape, I32PlannedValueShape)
  assert_eq(
    functions.parameters[scalar_method.parameters.start].shape,
    I32PlannedValueShape,
  )
}

///|
test "explicit top-level receivers retain their concrete ABI shape" {
  let collected = collect_bytes(
    966UL, b"fn increment(self: I32) -> I32 {\n  self + 1\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let functions = plan_module_functions(collected, resolved)
  assert_true(functions.callables[0].has_receiver)
  assert_eq(functions.callables[0].self_shape, I32PlannedValueShape)
  assert_eq(
    functions.parameters[functions.callables[0].parameters.start].shape,
    I32PlannedValueShape,
  )
}

///|
test "trait requirement plans retain generic Self ABI boundaries" {
  let collected = collect_bytes(
    963UL, b"trait Convert<t> {\n  fn convert(self, value: t) -> Self\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let functions = plan_module_functions(collected, resolved)
  let requirement = functions.callables[0]
  match requirement.kind {
    PlannedTraitMethodCallable(parent) =>
      assert_eq(parent, collected.declarations[0].id)
    _ => fail("expected trait requirement")
  }
  assert_eq(requirement.owner_generic_parameters.length, 1)
  assert_eq(requirement.self_shape, GenericPlannedValueShape)
  assert_eq(requirement.result_shape, GenericPlannedValueShape)
}

///|
test "function planning remains iterative for 1024 methods" {
  let collected = collect_bytes(965UL, many_inherent_methods_source(1024))
  let resolved = resolve_module_types(collected)
  let functions = plan_module_functions(collected, resolved)
  assert_eq(functions.callables.length(), 1025)
  assert_eq(functions.parameters.length(), 1025)
  match functions.callables[1023].kind {
    PlannedImplMethodCallable(_, Some(_)) => ()
    _ => fail("expected final planned method")
  }
  match functions.callables[1024].kind {
    PlannedFunctionCallable(_) => ()
    _ => fail("expected use function")
  }
}

///|
test "function plan lookup uses stable declaration identity" {
  let collected = collect_bytes(
    964UL, b"fn first() -> I32 {\n  1\n}\nfn second() -> I32 {\n  2\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let functions = plan_module_functions(collected, resolved)
  assert_eq(
    functions.callable_of(collected.declarations[1].id).unwrap(),
    functions.callables[1],
  )
  assert_eq(functions.callable_of(0UL), None)
}
