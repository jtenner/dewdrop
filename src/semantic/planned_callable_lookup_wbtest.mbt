///|
fn callable_lookup_test_functions() -> PlannedModuleFunctions raise {
  let collected = collect_bytes(
    5100UL, b"fn first() -> U32 {\n  1u32\n}\npub fn run() -> U32 {\n  first()\n}\n",
  )
  let functions = plan_module_functions(collected, resolve_module_types(collected))
  assert_eq(functions.callables.length(), 2)
  let declaration = make_semantic_id(5100UL, 0)
  assert_eq(functions.callable_of(declaration), Some(functions.callables[0]))
  functions
}

///|
test "callable lookup keeps missing and external declarations absent" {
  let functions = callable_lookup_test_functions()
  assert_eq(functions.callable_of(make_semantic_id(5101UL, 0)), None)
  assert_eq(functions.callable_of(make_semantic_id(5100UL, 99)), None)
  functions.callable_by_declaration[0] = -1
  assert_eq(functions.callable_of(make_semantic_id(5100UL, 0)), None)
}

///|
test "callable lookup reports invalid selected entries before access" {
  for invalid in [-2, 2] {
    let functions = callable_lookup_test_functions()
    let declaration = make_semantic_id(5100UL, 0)
    functions.callable_by_declaration[0] = invalid
    assert_eq(check_planned_callable_lookup(functions, declaration), Err({
      code: 105, phase: 5, module_id: 5100UL, declaration, body: 0UL,
      expression: 0xffffffffU, expected: 2UL,
      actual: invalid.reinterpret_as_uint().to_uint64(), detail: 0UL,
    }))
  }
}

///|
test "callable lookup reports another stored declaration" {
  let functions = callable_lookup_test_functions()
  let declaration = make_semantic_id(5100UL, 0)
  functions.callable_by_declaration[0] = 1
  assert_eq(check_planned_callable_lookup(functions, declaration), Err({
    code: 106, phase: 5, module_id: 5100UL, declaration, body: 0UL,
    expression: 0xffffffffU, expected: declaration,
    actual: make_semantic_id(5100UL, 1), detail: 1UL,
  }))
}
