///|
test "compile time names preserve declaration order and generic owners" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nopen dew.std.array\nstruct Record<t> {\n  second: t\n  first: I64\n}\nenum Message<t> {\n  Last\n  First(t)\n}\npub fn fields() -> Array<String> {\n  field_names::<Record<I32>>()\n}\npub fn variants() -> Array<String> {\n  variant_names::<Message<I64>>()\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics, [])
  let arrays = []
  for expression in lowering.modules[0].expressions {
    if expression.kind is PlannedStringArrayConst(values) {
      arrays.push(values)
    }
  }
  assert_eq(arrays, [[b"second", b"first"], [b"Last", b"First"]])
}

///|
test "compile time layouts describe scalars not GC objects" {
  for
    entry in [
      (I8Type, 1),
      (U16Type, 2),
      (I32Type, 4),
      (F64Type, 8),
      (V128Type, 16),
      (UnitType, 0),
    ] {
    let (type_, size) = entry
    assert_eq(
      evaluate_compile_time_type_query(b"types.size_of", [CtPrimitive(type_)]),
      Ok(Some(CtU32(size))),
    )
    assert_eq(
      evaluate_compile_time_type_query(b"types.align_of", [CtPrimitive(type_)]),
      Ok(Some(CtU32(if size == 0 { 1 } else { size }))),
    )
  }
  for
    type_ in [
      CtNominal(42UL),
      CtPrimitive(StringType),
      CtPrimitive(NeverType),
      CtProduct([CtPrimitive(I32Type)]),
    ] {
    assert_eq(
      evaluate_compile_time_type_query(b"types.size_of", [type_]),
      Err(CtWrongTypeCategory(b"types.size_of")),
    )
  }
}

///|
test "compile time module identity does not collide with Facet" {
  let program = collect_program_manifest(
    24900UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.*\npub fn main() -> Unit {}\n",
        ),
      ]),
    ]),
  )
  let owners : Map[ModuleId, String] = {}
  for index, module_ in program.modules {
    assert_false(
      owners.contains(module_.module_id),
      msg="duplicate standard module identity: " + program.module_paths[index],
    )
    owners[module_.module_id] = program.module_paths[index]
  }
}
