///|
// Negative cases compare all nine fields of the failure record.
fn initialization_contract_fixture() -> (CollectedModule, InferredModuleValues) raise {
  let (collected, inferred, plan) = initialization_test_module(
    993UL, b"let first = second\nlet second = 42i64\n",
  )
  assert_eq(plan.diagnostics, [])
  assert_eq(plan.steps.length(), 2)
  match check_module_initialization_inputs(collected, inferred.module_values) {
    Ok((_, bodies)) => assert_eq(bodies.length(), 2)
    Err(error) => fail(@debug.to_string(error))
  }
  (collected, inferred.module_values)
}

///|
fn initialization_contract_expect(
  collected : CollectedModule,
  values : InferredModuleValues,
  code : Int,
  declaration : UInt64,
  expected : UInt64,
  actual : UInt64,
  detail : UInt64,
  body? : UInt64 = 0UL,
) -> Unit raise {
  match check_module_initialization_inputs(collected, values) {
    Ok(_) => fail("invalid startup inputs were accepted")
    Err(error) =>
      assert_eq(error, {
        code,
        phase: 3,
        module_id: 993UL,
        declaration,
        body,
        expression: 0xffffffffU,
        expected,
        actual,
        detail,
      })
  }
}

///|
test "module startup contracts reject an omitted SCC member" {
  let (collected, values) = initialization_contract_fixture()
  ignore(values.dependencies.sccs.pop())
  initialization_contract_expect(collected, values, 501, 0UL, 2UL, 1UL, 8UL)
}

///|
test "module startup contracts reject a duplicate SCC member" {
  let (collected, values) = initialization_contract_fixture()
  values.dependencies.scc_declarations[1] = values.dependencies.scc_declarations[0]
  initialization_contract_expect(
    collected,
    values,
    501,
    (993UL << 32) | 1UL,
    1UL,
    2UL,
    9UL,
  )
}

///|
test "module startup contracts check SCC spans before indexing" {
  let (collected, values) = initialization_contract_fixture()
  values.dependencies.sccs[0] = { start: -1, length: 1, }
  initialization_contract_expect(
    collected,
    values,
    101,
    0UL,
    2UL,
    1UL,
    (7UL << 32) | 0xffffffffUL,
  )
}

///|
test "module startup contracts keep value types parallel" {
  let (collected, values) = initialization_contract_fixture()
  ignore(values.let_types.pop())
  initialization_contract_expect(collected, values, 103, 0UL, 2UL, 1UL, 4UL)
}

///|
test "module startup contracts reject missing source bodies" {
  let (collected, values) = initialization_contract_fixture()
  ignore(collected.bodies.pop())
  initialization_contract_expect(
    collected,
    values,
    610,
    (993UL << 32) | 1UL,
    1UL,
    0UL,
    12UL,
  )
}

///|
test "module startup contracts reject a stale body lookup" {
  let (collected, values) = initialization_contract_fixture()
  collected.body_by_declaration[1] = 0
  initialization_contract_expect(
    collected,
    values,
    106,
    (993UL << 32) | 1UL,
    (993UL << 32) | 1UL,
    993UL << 32,
    13UL,
    body=993UL << 32,
  )
}

///|
test "module startup contracts check every dependency component order" {
  let (collected, inferred, plan) = initialization_test_module(
    993UL, b"let first = second\nlet second = third\nlet third = 42i64\n",
  )
  assert_eq(plan.diagnostics, [])
  let values = inferred.module_values
  values.dependencies.dependency_declarations[1] = collected.lets[0].declaration
  initialization_contract_expect(
    collected,
    values,
    501,
    (993UL << 32) | 1UL,
    1UL,
    2UL,
    993UL << 32,
  )
}

///|
test "module startup contracts check source declaration lookups" {
  let (collected, values) = initialization_contract_fixture()
  collected.declaration_locations[0] = 99
  initialization_contract_expect(
    collected,
    values,
    101,
    993UL << 32,
    2UL,
    99UL,
    19UL,
  )
}

///|
test "module startup contracts reject empty SCC spans" {
  let (collected, values) = initialization_contract_fixture()
  values.dependencies.sccs[0] = { start: 0, length: 0, }
  initialization_contract_expect(
    collected,
    values,
    501,
    0UL,
    1UL,
    0UL,
    10UL << 32,
  )
}

///|
test "module startup contracts reject foreign SCC declarations" {
  let (collected, values) = initialization_contract_fixture()
  values.dependencies.scc_declarations[0] = 994UL << 32
  initialization_contract_expect(
    collected,
    values,
    107,
    994UL << 32,
    993UL,
    994UL,
    16UL,
  )
}
