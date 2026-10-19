///|
fn closure_type_test_stages() -> SemanticCompilerTestStages raise {
  let stages = compiler_test_stages(28160UL, [
    CompilerTestModule::new("app.closures", [
      CompilerTestSource::new(
        "main.dew", b"pub struct Boxed {\n  value: I64\n}\npub fn keep(value: Boxed) -> Boxed {\n  value\n}\npub fn make(value: I64) -> fn() -> I64 {\n  fn() -> I64 {\n    value\n  }\n}\n",
      ),
    ]),
  ])
  assert_eq(stages.diagnostics(), [])
  assert_eq(verify_program_physical_type_fragments(stages.link), Ok(()))
  stages
}

///|
fn closure_type_test_failure(
  code : Int32,
  expected : UInt64,
  actual : UInt64,
  role : UInt64,
  slot : Int32,
) -> ProgramPhysicalTypeFailure {
  {
    code,
    phase: 5,
    module_id: 28160UL,
    declaration: 0UL,
    body: 0UL,
    expression: 0xffffffffU,
    expected,
    actual,
    detail: (role << 32) | slot.reinterpret_as_uint().to_uint64(),
  }
}

///|
test "common closure lookup rejects a wrong in-range physical type" {
  let stages = closure_type_test_stages()
  let module_ = stages.link.modules[0]
  let wrong = module_.type_index_of(28160UL << 32).unwrap()
  assert_true(wrong >= 0 && wrong != module_.closure_type_index)
  stages.link.modules[0] = { ..module_, closure_type_index: wrong, }
  assert_eq(
    verify_program_physical_type_fragments(stages.link),
    Err(closure_type_test_failure(504, 1UL, 0UL, 91UL, wrong)),
  )
}

///|
fn closure_type_test_reject(
  link : PlannedProgramWasmGCLink,
  failure : ProgramPhysicalTypeFailure,
) -> Unit raise {
  assert_eq(verify_module_closure_type(link.modules[0]), Err(failure))
  assert_eq(verify_program_physical_type_fragments(link), Err(failure))
}

///|
test "common closure lookup bounds are checked before physical reads" {
  let stages = closure_type_test_stages()
  let module_ = stages.link.modules[0]
  for index in [-2, module_.physical_types.length(), 0x7fffffff] {
    stages.link.modules[0] = { ..module_, closure_type_index: index, }
    closure_type_test_reject(
      stages.link,
      closure_type_test_failure(
        101,
        module_.physical_types.length().to_uint64(),
        index.reinterpret_as_uint().to_uint64(),
        90UL,
        0,
      ),
    )
  }
}

///|
test "common closure lookup requires the declared kind and stored index" {
  let stages = closure_type_test_stages()
  let module_ = stages.link.modules[0]
  let index = module_.closure_type_index
  let original = module_.physical_types[index]
  for kind in [PlannedWasmLambdaClosureType(0), PlannedWasmStructType(0UL)] {
    module_.physical_types[index] = { ..original, kind, }
    closure_type_test_reject(
      stages.link,
      closure_type_test_failure(504, 1UL, 0UL, 91UL, index),
    )
  }
  module_.physical_types[index] = { ..original, type_index: index + 1, }
  closure_type_test_reject(
    stages.link,
    closure_type_test_failure(
      502,
      index.to_uint64(),
      (index + 1).to_uint64(),
      92UL,
      index,
    ),
  )
}

///|
test "common closure types retain one exact reverse lookup" {
  let stages = closure_type_test_stages()
  let module_ = stages.link.modules[0]
  let index = module_.closure_type_index
  stages.link.modules[0] = { ..module_, closure_type_index: -1, }
  closure_type_test_reject(
    stages.link,
    closure_type_test_failure(503, index.to_uint64(), 0xffffffffUL, 99UL, index),
  )
  stages.link.modules[0] = module_
  let duplicate = module_.physical_types.length()
  module_.physical_types.push({
    ..module_.physical_types[index],
    type_index: duplicate,
    group_index: module_.type_groups.length(),
  })
  module_.type_groups.push({
    types: { start: duplicate, length: 1, },
    first_type_index: duplicate,
  })
  closure_type_test_reject(
    stages.link,
    closure_type_test_failure(
      504,
      duplicate.to_uint64(),
      index.to_uint64(),
      99UL,
      duplicate,
    ),
  )
}

///|
test "common closure field spans are checked before field reads" {
  let stages = closure_type_test_stages()
  let module_ = stages.link.modules[0]
  let index = module_.closure_type_index
  let original = module_.physical_types[index]
  let field_count = module_.fields.length()
  for
    span in [
      { start: -1, length: 1, },
      { start: 0, length: -1, },
      { start: field_count + 1, length: 0, },
      { start: field_count, length: 1, },
      { start: 0x7fffffff, length: 0x7fffffff, },
    ] {
    module_.physical_types[index] = { ..original, fields: span, }
    closure_type_test_reject(
      stages.link,
      closure_type_test_failure(
        101,
        field_count.to_uint64(),
        program_function_span_code(span),
        93UL,
        index,
      ),
    )
  }
  for length in [0, 2] {
    let span = { start: original.fields.start, length, }
    assert_true(span.start + length <= field_count)
    module_.physical_types[index] = { ..original, fields: span, }
    closure_type_test_reject(
      stages.link,
      closure_type_test_failure(504, 1UL, length.to_uint64(), 94UL, index),
    )
  }
}

///|
test "common closure entry has exact position identity mutability and storage" {
  let stages = closure_type_test_stages()
  let module_ = stages.link.modules[0]
  let closure = module_.physical_types[module_.closure_type_index]
  let slot = closure.fields.start
  let original = module_.fields[slot]
  for physical_index in [-1, 1] {
    module_.fields[slot] = { ..original, physical_index, }
    closure_type_test_reject(
      stages.link,
      closure_type_test_failure(
        504,
        0UL,
        physical_index.reinterpret_as_uint().to_uint64(),
        95UL,
        slot,
      ),
    )
  }
  for
    role in [
      WasmEnumTagField,
      WasmCaptureCellValueField(0),
      WasmLambdaCaptureField(0, 0),
    ] {
    module_.fields[slot] = { ..original, role, }
    closure_type_test_reject(
      stages.link,
      closure_type_test_failure(504, 1UL, 0UL, 96UL, slot),
    )
  }
  module_.fields[slot] = { ..original, mutable_: true, }
  closure_type_test_reject(
    stages.link,
    closure_type_test_failure(504, 0UL, 1UL, 97UL, slot),
  )
  for
    storage in [
      WasmI8SignedStorage,
      WasmI8UnsignedStorage,
      WasmI16SignedStorage,
      WasmI16UnsignedStorage,
      WasmI32Storage,
      WasmI64Storage,
      WasmF32Storage,
      WasmF64Storage,
      WasmV128Storage,
      WasmStringRefStorage,
      WasmNullableEqRefStorage,
      WasmFunctionRefStorage(0),
      WasmNominalRefStorage(WasmModuleTypeReference(0)),
      WasmExternalNominalRefStorage(0UL),
      WasmFixedArrayRefStorage(0),
      WasmNullableNominalRefStorage(WasmModuleTypeReference(0)),
      WasmNullableExternalNominalRefStorage(0UL),
    ] {
    module_.fields[slot] = { ..original, storage, }
    closure_type_test_reject(
      stages.link,
      closure_type_test_failure(504, 1UL, 0UL, 98UL, slot),
    )
  }
}

///|
test "common closure contracts accept each module planning option" {
  for
    source in [
      b"pub fn run() -> I64 {\n  42i64\n}\n", b"pub fn answer() -> I64 {\n  42i64\n}\npub fn make() -> fn() -> I64 {\n  answer\n}\n",
      b"pub fn make(value: I64) -> fn() -> I64 {\n  fn() -> I64 {\n    value\n  }\n}\n",
      b"pub fn make<t>(value: t) -> fn() -> t {\n  fn() -> t {\n    value\n  }\n}\n",
    ] {
    let (resolved, lowering) = wasmgc_test_inputs(28160UL, source)
    assert_eq(lowering.diagnostics, [])
    let default_module = plan_module_wasmgc_fragments(resolved, lowering)
    assert_eq(verify_module_closure_type(default_module), Ok(()))
    assert_eq(verify_module_physical_type_fragments(default_module), Ok(()))
    for
      options in [
        WasmGCPlanningOptions::subtype_families(),
        WasmGCPlanningOptions::optimized_subtype_families(),
        WasmGCPlanningOptions::test_mode(),
      ] {
      let module_ = plan_module_wasmgc_fragments_with_options(
        resolved, lowering, options,
      )
      assert_eq(verify_module_closure_type(module_), Ok(()))
      assert_eq(verify_module_physical_type_fragments(module_), Ok(()))
    }
  }
}

///|
test "selected generic common closures preserve their module contract" {
  let stages = compiler_test_stages(28160UL, [
    CompilerTestModule::new("app.closures", [
      CompilerTestSource::new(
        "main.dew", b"pub fn make<t>(value: t) -> fn() -> t {\n  fn() -> t {\n    value\n  }\n}\npub fn read() -> I64 {\n  let callback = make(42i64)\n  callback()\n}\n",
      ),
    ]),
  ])
  assert_eq(stages.diagnostics(), [])
  let module_ = stages.link.modules[0]
  assert_true(module_.closure_type_index >= 0)
  assert_eq(verify_module_closure_type(module_), Ok(()))
  assert_eq(verify_program_physical_type_fragments(stages.link), Ok(()))
  stages.link.modules[0] = { ..module_, closure_type_index: -1, }
  closure_type_test_reject(
    stages.link,
    closure_type_test_failure(
      503,
      module_.closure_type_index.to_uint64(),
      0xffffffffUL,
      99UL,
      module_.closure_type_index,
    ),
  )
}
