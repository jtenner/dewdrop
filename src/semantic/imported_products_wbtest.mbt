///|
test "imported product fields use destination-owned argument spans" {
  let (program, frozen, imports, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn read() -> I64 {\n let (left, right) = pair()\n right\n}\n",
    b"pub fn pair() -> (I32, I64) {\n (1i32, 2i64)\n}\n",
  )
  assert_eq(frozen.import_diagnostics, [])
  assert_eq(names.diagnostics, [])
  assert_eq(inferred.diagnostics, [])
  let target = frozen.interfaces[1].callables_named("pair")[0].declaration
  let result = imports.callable(target).unwrap().result_type
  let resolved = frozen.interfaces[0].resolved_types
  guard resolved.types[result] is ProductType(fields) else { fail("imported product result") }
  assert_eq(fields.length, 2)
  assert_eq(resolved.types[resolved.type_arguments[fields.start]], PrimitiveType(I32Type))
  assert_eq(resolved.types[resolved.type_arguments[fields.start + 1]], PrimitiveType(I64Type))
  let body = program.modules[0].bodies[0]
  let locals = names.body(body.id).unwrap().locals
  assert_call_primitive(inferred, resolved, inferred.local_types[locals.start + locals.length - 1], I64Type)
}

///|
test "imported products rebuild nested fields and share structural identity" {
  let (_, frozen, imports, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn read() -> I64 {\n let ((left, right), tail) = nested()\n right\n}\n",
    b"pub fn nested() -> ((I32, I64), Bool) {\n ((1i32, 2i64), true)\n}\npub fn same() -> ((I32, I64), Bool) {\n ((3i32, 4i64), false)\n}\n",
  )
  assert_eq(frozen.import_diagnostics, [])
  assert_eq(names.diagnostics, [])
  assert_eq(inferred.diagnostics, [])
  let nested = imports.callable(frozen.interfaces[1].callables_named("nested")[0].declaration).unwrap().result_type
  let same = imports.callable(frozen.interfaces[1].callables_named("same")[0].declaration).unwrap().result_type
  assert_eq(nested, same)
  let resolved = frozen.interfaces[0].resolved_types
  guard resolved.types[nested] is ProductType(outer) else { fail("outer imported product") }
  assert_eq(outer.length, 2)
  assert_eq(resolved.types[resolved.type_arguments[outer.start + 1]], PrimitiveType(BoolType))
  guard resolved.types[resolved.type_arguments[outer.start]] is ProductType(inner) else { fail("inner imported product") }
  assert_eq(inner.length, 2)
  assert_eq(resolved.types[resolved.type_arguments[inner.start]], PrimitiveType(I32Type))
  assert_eq(resolved.types[resolved.type_arguments[inner.start + 1]], PrimitiveType(I64Type))
}
