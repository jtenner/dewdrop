///|
test "debug emission preserves Option traffic in for loops" {
  let program = @semantic.collect_program_manifest(
    2668UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.array\npub fn consume(values: Array<I32>) -> I32 {\n  let mut sum = 0\n  for value in values {\n    sum = sum + value\n  }\n  sum\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics, [])
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  for module_ in lowering.modules {
    assert_eq(module_.diagnostics, [])
  }
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics, [])
  let declaration = program.modules[0].lookup_value("consume").unwrap()
  let function_index = link.function_of(declaration).unwrap().function_index
  let unoptimized = emit_starshine_program_module(lowering, link).unwrap()
  let bytes = emit_starshine_program_binary(lowering, link).unwrap()
  let emitted = @binary.decode_module(bytes).unwrap()
  assert_eq(@validate.validate_module(emitted), Ok(()))

  let option_module = @semantic.semantic_id_module(
    @semantic.standard_option_some_variant(),
  )
  let option_module_index = link.module_lookup.get(option_module).unwrap()
  let option_plan = link.modules[option_module_index]
  let some_physical = starshine_variant_payload_physical_type_for_fields(
    option_plan,
    @semantic.standard_option_some_variant(),
    StarshineExpectedTupleFields([@semantic.planned_i32_shape()]),
  ).unwrap()
  let none_physical = starshine_variant_payload_physical_type(
    option_plan,
    @semantic.standard_option_none_variant(),
  ).unwrap()
  let some_type = link.physical_type_index(
    option_module_index,
    some_physical.type_index,
  )
  let none_type = link.physical_type_index(
    option_module_index,
    none_physical.type_index,
  )
  let some_allocation = "struct.new (Type \{some_type})"
  let none_allocation = "struct.new (Type \{none_type})"
  let before = unoptimized.pretty_print_func(
    @lib.FuncIdx::new(function_index.reinterpret_as_uint()),
  )
  let after = emitted.pretty_print_func(
    @lib.FuncIdx::new(function_index.reinterpret_as_uint()),
  )
  assert_true(before.contains(some_allocation), msg=before)
  assert_true(before.contains(none_allocation), msg=before)
  assert_true(after.contains(some_allocation), msg=after)
  assert_true(after.contains(none_allocation), msg=after)
}
