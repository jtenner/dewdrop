///|
fn impl_walk_context(resolved : ResolvedModuleTypes) -> ImplTypeContext {
  {
    generic_parameters: { start: 0, length: 0 },
    generic_arguments: { start: 0, length: 0 },
    method_parameters: { start: 0, length: 0 },
    method_arguments: { start: 0, length: 0 },
    self_owner: 0UL,
    self_type: resolved.error_type,
  }
}

///|
test "implementation comparison handles deep shared graphs" {
  let resolved = resolve_module_types(collect_bytes(6010UL, b""))
  let context = impl_walk_context(resolved)
  let mut left = resolved.primitive(I32Type)
  let mut right = left
  let first = resolved.type_arguments.length()
  for _ in 0..<1025 {
    let start = resolved.type_arguments.length()
    resolved.type_arguments.push(left)
    resolved.type_arguments.push(left)
    resolved.type_arguments.push(right)
    resolved.type_arguments.push(right)
    left = resolved.types.length()
    resolved.types.push(ProductType({ start, length: 2 }))
    right = resolved.types.length()
    resolved.types.push(ProductType({ start: start + 2, length: 2 }))
  }
  assert_eq(check_impl_signature_types_equal(resolved, left, context, right, context), Ok(true))
  resolved.type_arguments[first + 2] = resolved.primitive(I64Type)
  assert_eq(check_impl_signature_types_equal(resolved, left, context, right, context), Ok(false))
}

///|
test "same product identity does not hide different substitutions" {
  let resolved = resolve_module_types(collect_bytes(6011UL, b"struct Box<t> {}\n"))
  let start = resolved.type_arguments.length()
  resolved.type_arguments.push(resolved.primitive(I32Type))
  resolved.type_arguments.push(resolved.primitive(I64Type))
  resolved.type_arguments.push(resolved.generic_parameter_types[0])
  resolved.type_arguments.push(resolved.primitive(BoolType))
  let root = resolved.types.length()
  resolved.types.push(ProductType({ start: start + 2, length: 2 }))
  let left = { ..impl_walk_context(resolved), generic_parameters: { start: 0, length: 1 }, generic_arguments: { start, length: 1 } }
  let right = { ..left, generic_arguments: { start: start + 1, length: 1 } }
  assert_eq(check_impl_signature_types_equal(resolved, root, left, root, left), Ok(true))
  assert_eq(check_impl_signature_types_equal(resolved, root, left, root, right), Ok(false))
}

///|
test "implementation comparison diagnoses cycles before identity or error shortcuts" {
  let resolved = resolve_module_types(collect_bytes(6012UL, b""))
  let context = impl_walk_context(resolved)
  let root = resolved.types.length()
  let start = resolved.type_arguments.length()
  resolved.type_arguments.push(resolved.error_type)
  resolved.type_arguments.push(root)
  resolved.types.push(ProductType({ start, length: 2 }))
  let expected : Result[Bool, ImplTypeWalkFailure] = Err({ code: 211, module_id: 6012UL, root, expected: 0, actual: root, detail: 1 })
  assert_eq(check_impl_signature_types_equal(resolved, root, context, root, context), expected)
  assert_eq(check_impl_signature_types_equal(resolved, resolved.error_type, context, root, context), expected)
  resolved.type_arguments[start + 1] = resolved.primitive(I32Type)
  assert_eq(check_impl_signature_types_equal(resolved, root, context, root, context), Ok(true))
  resolved.types[root] = ProductType({ start: resolved.type_arguments.length(), length: 1 })
  assert_eq(check_impl_signature_types_equal(resolved, root, context, root, context), Err({
    code: 101, module_id: 6012UL, root, expected: resolved.type_arguments.length(), actual: resolved.type_arguments.length(), detail: 1,
  }))
}

///|
test "implementation substitutions diagnose a cycle and an invalid target" {
  let resolved = resolve_module_types(collect_bytes(6013UL, b"struct Box<t, u> {}\n"))
  let start = resolved.type_arguments.length()
  let first = resolved.generic_parameter_types[0]
  let second = resolved.generic_parameter_types[1]
  resolved.type_arguments.push(second)
  resolved.type_arguments.push(first)
  let context = { ..impl_walk_context(resolved), generic_parameters: { start: 0, length: 2 }, generic_arguments: { start, length: 2 } }
  assert_eq(check_impl_signature_types_equal(resolved, first, context, first, context), Err({
    code: 211, module_id: 6013UL, root: first, expected: 0, actual: first, detail: 1,
  }))
  resolved.type_arguments[start + 1] = resolved.primitive(I32Type)
  assert_eq(check_impl_signature_types_equal(resolved, first, context, resolved.primitive(I32Type), context), Ok(true))
  resolved.type_arguments[start] = resolved.types.length()
  assert_eq(check_impl_signature_types_equal(resolved, first, context, first, context), Err({
    code: 104, module_id: 6013UL, root: first, expected: resolved.types.length(), actual: resolved.types.length(), detail: 0,
  }))
}
