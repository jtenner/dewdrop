///|
test "generic mutable lambdas select owner instances without type queries" {
  let program = collect_program_manifest(
    28134UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn select<t>(first: t, second: t) -> t {\n  let mut item = first\n  let update = fn() -> t {\n    item = second\n    item\n  }\n  update()\n}\npub fn run() -> I64 {\n  select((), ())\n  select(1i64, 42i64)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(program.diagnostics, [])
  assert_eq(analyzed.modules[0].inferred.diagnostics, [])
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  let planned = plan_program_wasmgc_fragments(analyzed, lowering)
  let fragments = planned.modules[0]
  assert_eq(validate_module_wasmgc_arenas(fragments), Ok(()))
  let source = lowering.modules[0]
  let owner = program.modules[0].lookup_value("select").unwrap()
  assert_eq(source.lambdas.length(), 1)
  let lambda = source.lambdas[0]
  let mutable_captures = source.captures.filter(capture => capture.mutable_)
  assert_eq(mutable_captures.length(), 1)
  let original = mutable_captures[0]
  assert_eq(original.shape, GenericPlannedValueShape)
  let (body, local_id) = match original.source {
    BodyLocalCapture(body, local) => (body, local)
    _ => fail("expected a body-owned mutable capture")
  }
  let local_index = source.bodies[semantic_id_local(body)].locals.start +
    local_id
  assert_eq(source.locals[local_index].shape, GenericPlannedValueShape)
  let mut scalar_count = 0
  let mut unit_count = 0
  for key, layout in fragments.specialized_lambda_layouts {
    let instance = program_function_lowering(lowering, 0, key)
    let selected = program_function_fragments(instance, fragments, key)
    let function_ = selected.functions[selected.lambda_function_indices[0]]
    assert_eq(function_.specialization_abi_key, key)
    assert_false(function_.elided)
    let capture = instance.captures[lambda.captures.start + original.capture]
    assert_eq(instance.locals[local_index].shape, capture.shape)
    let owner_functions = fragments.functions.filter(function_ => {
      function_.declaration == owner &&
      function_.specialization_abi_key == key &&
      !function_.elided
    })
    assert_eq(owner_functions.length(), 1)
    match capture.shape {
      I64PlannedValueShape => {
        scalar_count += 1
        assert_eq(function_.results.length, 1)
        assert_eq(
          fragments.function_value_types[function_.results.start],
          WasmI64Value,
        )
        let cell_index = fragments.capture_cell_type_indices[1]
        assert_true(cell_index >= 0)
        let cell = fragments.physical_types[cell_index]
        assert_eq(fragments.fields[cell.fields.start].storage, WasmI64Storage)
        assert_true(
          layout.capture_parameters[lambda.captures.start + original.capture] >=
          0,
        )
      }
      UnitPlannedValueShape => {
        unit_count += 1
        assert_eq(function_.results.length, 0)
        assert_eq(
          layout.capture_parameters[lambda.captures.start + original.capture],
          -1,
        )
      }
      shape => fail("unresolved selected capture: " + @debug.to_string(shape))
    }
  }
  assert_eq(scalar_count, 1)
  assert_eq(unit_count, 1)
  assert_eq(source.locals[local_index].shape, GenericPlannedValueShape)
  assert_eq(source.captures[lambda.captures.start + original.capture], original)
}
