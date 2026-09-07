///|
test "solver graph checks reject a later cycle after an Error sibling" {
  let solver = root_contract_fixture()
  let product = solver.product_type([0, 0])
  assert_eq(solver.check_type_graph(product), Ok(()))
  let span = match solver.types[product] {
    BodyProductType(span) => span
    _ => abort("product fixture")
  }
  solver.type_arguments[span.start + 1] = product
  assert_eq(
    solver.check_type_graph(product),
    Err({
      code: 206,
      module_id: 80UL,
      expected: 0,
      actual: product,
      detail: product,
    }),
  )
  solver.type_arguments[span.start + 1] = 0
  assert_eq(solver.check_type_graph(product), Ok(()))
}

///|
test "solver graph checks preserve exact owned-span and child failures" {
  let solver = root_contract_fixture()
  let product = solver.product_type([0, 0])
  let original = solver.types[product]
  solver.types[product] = BodyProductType({ start: 2, length: 1, })
  assert_eq(
    solver.check_type_graph(product),
    Err({ code: 101, module_id: 80UL, expected: 2, actual: 2, detail: 1, }),
  )
  solver.types[product] = original
  solver.type_arguments[1] = solver.types.length()
  assert_eq(
    solver.check_type_graph(product),
    Err({ code: 104, module_id: 80UL, expected: 4, actual: 4, detail: 4, }),
  )
  solver.type_arguments[1] = 0
  assert_eq(solver.check_type_graph(product), Ok(()))
}

///|
test "solver type reads cannot turn a missing sentinel into an Error type" {
  let solver = root_contract_fixture()
  assert_eq(
    solver.check_type_term(-1),
    Err({ code: 104, module_id: 80UL, expected: 3, actual: -1, detail: 0, }),
  )
  assert_eq(solver.check_type_term(0), Ok(BodyErrorType))
  let count = solver.resolved.types.length()
  assert_eq(
    solver.check_type_term(-count - 2),
    Err({
      code: 104,
      module_id: 80UL,
      expected: count,
      actual: count,
      detail: -count - 2,
    }),
  )
  assert_eq(
    solver.check_type_term(-2147483648),
    Err({
      code: 104,
      module_id: 80UL,
      expected: count,
      actual: 2147483646,
      detail: -2147483648,
    }),
  )
}

///|
test "solver type graph traversal accepts deep shared structure" {
  let solver = root_contract_fixture()
  let mut root = solver.resolved_type(solver.resolved.primitive(I32Type))
  for _ in 0..<2048 {
    root = solver.product_type([root, root])
  }
  assert_eq(solver.check_type_graph(root), Ok(()))
  assert_eq(solver.zonk_type(root), root)
}
