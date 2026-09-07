///|
fn interface_walk_fixture() -> ResolvedModuleTypes {
  resolve_module_types(collect_bytes(6000UL, b""))
}

///|
test "interface visibility handles deep types and shared children" {
  let resolved = interface_walk_fixture()
  let mut root = resolved.primitive(I32Type)
  for _ in 0..<1025 {
    let start = resolved.type_arguments.length()
    resolved.type_arguments.push(root)
    resolved.type_arguments.push(root)
    root = resolved.types.length()
    resolved.types.push(ProductType({ start, length: 2, }))
  }
  assert_eq(check_frozen_impl_type_visibility(resolved, root, {}), Ok(true))
  let leaf = resolved.primitive(I32Type)
  let owner = make_semantic_id(6000UL, 17)
  resolved.types[leaf] = NominalType(owner)
  assert_eq(check_frozen_impl_type_visibility(resolved, root, {}), Ok(false))
  let exported : Map[DeclId, Bool] = {}
  exported[owner] = true
  assert_eq(
    check_frozen_impl_type_visibility(resolved, root, exported),
    Ok(true),
  )
  let projection = resolved.types.length()
  resolved.types.push(MemberTypeProjection(leaf, b"types.field_type", "field"))
  assert_eq(
    check_frozen_impl_type_visibility(resolved, projection, {}),
    Ok(false),
  )
  assert_eq(
    check_frozen_impl_type_visibility(resolved, projection, exported),
    Ok(true),
  )
}

///|
test "interface visibility reports an exact cycle record" {
  let resolved = interface_walk_fixture()
  let root = resolved.primitive(I32Type)
  let start = resolved.type_arguments.length()
  resolved.type_arguments.push(resolved.error_type)
  resolved.type_arguments.push(root)
  assert_eq(check_frozen_impl_type_visibility(resolved, root, {}), Ok(true))
  resolved.types[root] = ProductType({ start, length: 2, })
  assert_eq(
    check_frozen_impl_type_visibility(resolved, root, {}),
    Err({
      code: 211,
      module_id: 6000UL,
      root,
      expected: 0,
      actual: root,
      detail: 1,
    }),
  )
}

///|
test "interface visibility reports bad type IDs and owned spans" {
  let resolved = interface_walk_fixture()
  let root = resolved.types.length()
  assert_eq(
    check_frozen_impl_type_visibility(resolved, root, {}),
    Err({
      code: 104,
      module_id: 6000UL,
      root,
      expected: root,
      actual: root,
      detail: 0,
    }),
  )
  let root = resolved.primitive(I32Type)
  let start = resolved.type_arguments.length()
  resolved.types[root] = ProductType({ start, length: 1, })
  assert_eq(
    check_frozen_impl_type_visibility(resolved, root, {}),
    Err({
      code: 101,
      module_id: 6000UL,
      root,
      expected: start,
      actual: start,
      detail: 1,
    }),
  )
}
