///|
fn lambda_contract_test_link() -> PlannedProgramWasmGCLink raise {
  let stages = compiler_test_stages(28161UL, [
    CompilerTestModule::new("app.lambda_contract", [
      CompilerTestSource::new(
        "main.dew", b"pub fn make(left: I64, right: I64) -> fn() -> I64 {\n  fn() -> I64 {\n    left - right\n  }\n}\n",
      ),
    ]),
  ])
  assert_eq(stages.diagnostics(), [])
  stages.link
}

///|
fn lambda_contract_failure(
  code : Int32,
  expected : UInt64,
  actual : UInt64,
  role : UInt64,
  slot : Int32,
) -> ProgramPhysicalTypeFailure {
  physical_type_failure(28161UL, 0UL, code, expected, actual, role, slot)
}

///|
test "lambda closure lookup rejects a wrong in-range type before emission" {
  let link = lambda_contract_test_link()
  let module_ = link.modules[0]
  assert_eq(verify_module_lambda_closure_types(module_), Ok(()))
  module_.lambda_closure_type_indices[0] = module_.closure_type_index
  assert_eq(
    verify_module_lambda_closure_types(module_),
    Err(lambda_contract_failure(504, 0UL, 0xffffffffUL, 101UL, 0)),
  )
}

///|
test "lambda closure entry and capture fields retain their contracts" {
  let module_ = lambda_contract_test_link().modules[0]
  let index = module_.lambda_closure_type_indices[0]
  let type_ = module_.physical_types[index]
  let entry = module_.fields[type_.fields.start]
  for
    field in [
      { ..entry, mutable_: true, },
      { ..entry, storage: WasmI64Storage, },
      { ..entry, role: WasmLambdaCaptureField(0, 0), },
    ] {
    module_.fields[type_.fields.start] = field
    assert_eq(
      verify_module_lambda_closure_types(module_),
      Err(lambda_contract_failure(504, 1UL, 0UL, 105UL, index)),
    )
  }
  module_.fields[type_.fields.start] = entry
  let slot = type_.fields.start + 1
  let capture = module_.fields[slot]
  for
    field in [
      { ..capture, mutable_: true, },
      { ..capture, role: WasmLambdaCaptureField(1, 0), },
      { ..capture, physical_index: 2, },
    ] {
    module_.fields[slot] = field
    assert_eq(
      verify_module_lambda_closure_types(module_),
      Err(lambda_contract_failure(504, 1UL, 0UL, 106UL, slot)),
    )
  }
}

///|
test "lambda closure maps have exact reverse coverage and safe spans" {
  let module_ = lambda_contract_test_link().modules[0]
  let index = module_.lambda_closure_type_indices[0]
  module_.lambda_closure_type_indices[0] = -1
  assert_eq(
    verify_module_lambda_closure_types(module_),
    Err(lambda_contract_failure(503, 1UL, 0UL, 107UL, index)),
  )
  module_.lambda_closure_type_indices[0] = index
  let type_ = module_.physical_types[index]
  let span = { start: module_.fields.length(), length: 1, }
  module_.physical_types[index] = { ..type_, fields: span, }
  assert_eq(
    verify_module_lambda_closure_types(module_),
    Err(
      lambda_contract_failure(
        101,
        module_.fields.length().to_uint64(),
        program_function_span_code(span),
        104UL,
        index,
      ),
    ),
  )
  module_.physical_types[index] = type_
  let absent = { ..module_, closure_type_index: -1, }
  assert_eq(
    verify_module_lambda_closure_types(absent),
    Err(lambda_contract_failure(503, 1UL, 0UL, 108UL, index)),
  )
}

///|
test "lambda closure capture maps retain source ownership order and storage" {
  let stages = compiler_test_stages(28161UL, [
    CompilerTestModule::new("app.lambda_contract", [
      CompilerTestSource::new(
        "main.dew", b"pub fn make(left: I64, right: I64) -> fn() -> I64 {\n  fn() -> I64 {\n    left - right\n  }\n}\n",
      ),
    ]),
  ])
  assert_eq(stages.diagnostics(), [])
  let lowering = stages.lowering.modules[0]
  let module_ = stages.link.modules[0]
  assert_eq(verify_lambda_capture_layout(lowering, module_, 0), Ok(()))
  let first = module_.lambda_capture_field_indices[0]
  module_.lambda_capture_field_indices[0] = module_.lambda_capture_field_indices[1]
  assert_eq(
    verify_lambda_capture_layout(lowering, module_, 0),
    Err(lambda_contract_failure(504, 1UL, 2UL, 114UL, 0)),
  )
  module_.lambda_capture_field_indices[0] = first
  let type_ = module_.physical_types[module_.lambda_closure_type_indices[0]]
  let field_index = type_.fields.start + first
  let field = module_.fields[field_index]
  module_.fields[field_index] = { ..field, storage: WasmI32Storage, }
  assert_eq(
    verify_lambda_capture_layout(lowering, module_, 0),
    Err(lambda_contract_failure(504, 1UL, 0UL, 117UL, 0)),
  )
}

///|
test "lambda closure direct capture parameters retain their exact order" {
  let stages = compiler_test_stages(28161UL, [
    CompilerTestModule::new("app.lambda_contract", [
      CompilerTestSource::new(
        "main.dew", b"pub fn run(left: I64, right: I64) -> I64 {\n  let callback = fn() -> I64 {\n    left - right\n  }\n  callback()\n}\n",
      ),
    ]),
  ])
  assert_eq(stages.diagnostics(), [])
  let lowering = stages.lowering.modules[0]
  let module_ = stages.link.modules[0]
  assert_true(lowering.lambdas[0].directized)
  assert_eq(verify_lambda_capture_layout(lowering, module_, 0), Ok(()))
  module_.lambda_capture_parameter_indices[0] = 1
  assert_eq(
    verify_lambda_capture_layout(lowering, module_, 0),
    Err(lambda_contract_failure(504, 0UL, 1UL, 114UL, 0)),
  )
}

///|
test "lambda closure selected generic layouts retain type identity and coverage" {
  let stages = compiler_test_stages(28161UL, [
    CompilerTestModule::new("app.lambda_contract", [
      CompilerTestSource::new(
        "main.dew", b"pub fn make<t>(value: t) -> fn() -> t {\n  fn() -> t {\n    value\n  }\n}\npub fn one(value: I32) -> fn() -> I32 {\n  make(value)\n}\npub fn two(value: I64) -> fn() -> I64 {\n  make(value)\n}\n",
      ),
    ]),
  ])
  assert_eq(stages.diagnostics(), [])
  let module_ = stages.link.modules[0]
  assert_eq(verify_module_lambda_closure_types(module_), Ok(()))
  let mut checked = false
  for _, layout in module_.specialized_lambda_layouts {
    layout.closure_types[0] = module_.closure_type_index
    assert_eq(
      verify_module_lambda_closure_types(module_),
      Err(lambda_contract_failure(504, 0UL, 0xffffffffUL, 101UL, 0)),
    )
    checked = true
    break
  }
  assert_true(checked)
}

///|
test "lambda closure storage checks preserve erased packed product and mutable captures" {
  for
    source in [
      b"pub fn make(value: Unit) -> fn() -> Unit {\n  fn() -> Unit {\n    value\n  }\n}\n",
      b"pub fn make(value: I8) -> fn() -> I8 {\n  fn() -> I8 {\n    value\n  }\n}\n",
      b"pub fn make(value: (I64, I32)) -> fn() -> (I64, I32) {\n  fn() -> (I64, I32) {\n    value\n  }\n}\n",
      b"pub fn make(value: I64) -> fn() -> I64 {\n  let mut held = value\n  fn() -> I64 {\n    held = value\n    held\n  }\n}\n",
    ] {
    let stages = compiler_test_stages(28161UL, [
      CompilerTestModule::new("app.lambda_contract", [
        CompilerTestSource::new("main.dew", source),
      ]),
    ])
    assert_eq(stages.diagnostics(), [])
    assert_eq(
      verify_module_lambda_closure_types(stages.link.modules[0]),
      Ok(()),
    )
    assert_eq(
      verify_lambda_capture_layout(
        stages.lowering.modules[0],
        stages.link.modules[0],
        0,
      ),
      Ok(()),
    )
  }
}

///|
test "lambda closure saved Error leaves survive generic tuple resolution" {
  let stages = compiler_test_stages(28161UL, [
    CompilerTestModule::new("app.lambda_contract", [
      CompilerTestSource::new(
        "main.dew", b"pub fn make<t>(value: (t, t)) -> fn() -> (t, t) {\n  fn() -> (t, t) {\n    value\n  }\n}\n",
      ),
    ]),
  ])
  assert_eq(stages.diagnostics(), [])
  let module_ = stages.link.modules[0]
  let mut checked = false
  for function_ in module_.functions {
    if function_.lambda < 0 ||
      function_.elided ||
      function_.specialization_abi_key == "" {
      continue
    }
    let lowering = program_function_lowering(
      stages.lowering,
      0,
      function_.specialization_abi_key,
    )
    let selected = program_function_fragments(
      lowering,
      module_,
      function_.specialization_abi_key,
    )
    let lambda = function_.lambda
    let global = lowering.lambdas[lambda].captures.start
    let capture = lowering.captures[global]
    assert_false(capture.mutable_)
    assert_eq(verify_lambda_capture_layout(lowering, selected, lambda), Ok(()))
    for
      shape in [
        ProductPlannedValueShape([
          ErrorPlannedValueShape,
          GenericPlannedValueShape,
        ]),
        ProductPlannedValueShape([
          GenericPlannedValueShape,
          ErrorPlannedValueShape,
        ]),
        ProductPlannedValueShape([
          ProductPlannedValueShape([ErrorPlannedValueShape]),
          GenericPlannedValueShape,
        ]),
        ProductPlannedValueShape([
          GenericPlannedValueShape,
          ProductPlannedValueShape([ErrorPlannedValueShape]),
        ]),
      ] {
      lowering.captures[global] = { ..capture, shape, }
      assert_eq(
        verify_lambda_capture_layout(lowering, selected, lambda),
        Err(lambda_contract_failure(301, 0UL, 2UL, 117UL, global)),
      )
    }
    lowering.captures[global] = capture
    checked = true
  }
  assert_true(checked)
}
