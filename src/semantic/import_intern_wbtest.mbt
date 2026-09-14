///|
test "import interning preserves first IDs and owns scratch keys" {
  let resolved = resolve_module_types(collect_bytes(77UL, b""))
  let first = resolved.types.length()
  let nominal = NominalType(make_semantic_id(77UL, 7))
  resolved.types.push(nominal)
  resolved.types.push(nominal)
  let importer = InterfaceTypeImporter::new(resolved, [])
  assert_eq(importer.intern_simple(0, nominal), first)
  let scratch = [first]
  let product = importer.intern_product(scratch)
  let applied = importer.intern_applied(first, scratch)
  let function_ = importer.intern_function(scratch, first)
  scratch[0] = resolved.error_type
  assert_eq(importer.intern_product([first]), product)
  assert_eq(importer.intern_applied(first, [first]), applied)
  assert_eq(importer.intern_function([first], first), function_)
  assert_true(importer.intern_product(scratch) != product)
  assert_true(importer.intern_applied(first, scratch) != applied)
  assert_true(importer.intern_function(scratch, first) != function_)
  let seeded = InterfaceTypeImporter::new(resolved, [])
  assert_eq(seeded.intern_product([first]), product)
  assert_eq(seeded.intern_applied(first, [first]), applied)
  assert_eq(seeded.intern_function([first], first), function_)
  assert_eq(seeded.intern_simple(0, ErrorType), resolved.error_type)
}

///|
test "import interning separates projections and structural heads" {
  let resolved = resolve_module_types(collect_bytes(77UL, b""))
  let importer = InterfaceTypeImporter::new(resolved, [])
  let a = importer.intern_simple(0, MemberTypeProjection(0, b"a", "Item"))
  let b = importer.intern_simple(0, MemberTypeProjection(0, b"b", "Item"))
  assert_true(a != b)
  assert_eq(importer.intern_simple(0, MemberTypeProjection(0, b"a", "Item")), a)
  assert_true(importer.intern_function([a], a) != importer.intern_function([a], b))
  assert_true(importer.intern_applied(a, [a]) != importer.intern_applied(b, [a]))
  assert_true(importer.intern_product([a, b]) != importer.intern_product([b, a]))
  assert_eq(importer.intern_product([]), importer.intern_product([]))
}
