///|
fn function_type_preflight_fixture() -> PlannedModuleWasmGCFragments raise {
  let stages = compiler_test_stages(24020UL, [
    CompilerTestModule::new("app.signatures", [
      CompilerTestSource::new(
        "main.dew", b"pub fn keep(value: fn(I32) -> I64) -> fn(I32) -> I64 {\n  value\n}\n",
      ),
    ]),
  ])
  assert_eq(stages.diagnostics(), [])
  let link = plan_program_wasmgc_link(stages.analyzed, stages.lowering, 0)
  assert_eq(link.diagnostics, [])
  let module_ = link.modules[0]
  assert_eq(module_.function_types.length(), 2)
  assert_true(module_.function_types[0].resolved_type >= 0)
  assert_eq(module_.function_types[1].resolved_type, -1)
  assert_eq(verify_module_physical_type_fragments(module_), Ok(()))
  module_
}

///|
fn function_type_preflight_error(
  code : Int,
  expected : UInt64,
  actual : UInt64,
  role : UInt64,
  slot : Int,
) -> ProgramPhysicalTypeFailure {
  {
    code,
    phase: 5,
    module_id: 24020UL,
    declaration: 0UL,
    body: 0UL,
    expression: 0xffffffffU,
    expected,
    actual,
    detail: (role << 32) | slot.reinterpret_as_uint().to_uint64(),
  }
}

///|
test "function type preflight accepts the complete source table" {
  let _ = function_type_preflight_fixture()
}

///|
test "function type parameter spans are checked before interning" {
  let module_ = function_type_preflight_fixture()
  let source = module_.function_types[0]
  let span = { start: -1, length: source.parameters.length, }
  module_.function_types[0] = { ..source, parameters: span, }
  assert_eq(
    verify_module_physical_type_fragments(module_),
    Err(
      function_type_preflight_error(
        101,
        module_.function_value_types.length().to_uint64(),
        program_function_span_code(span),
        77UL,
        0,
      ),
    ),
  )
}

///|
test "function type result spans cannot cross the source value arena" {
  let module_ = function_type_preflight_fixture()
  let source = module_.function_types[0]
  let span = { start: module_.function_value_types.length(), length: 1, }
  module_.function_types[0] = { ..source, results: span, }
  assert_eq(
    verify_module_physical_type_fragments(module_),
    Err(
      function_type_preflight_error(
        101,
        module_.function_value_types.length().to_uint64(),
        program_function_span_code(span),
        78UL,
        0,
      ),
    ),
  )
}

///|
test "function type local signatures cannot use the missing sentinel" {
  let module_ = function_type_preflight_fixture()
  let source = module_.function_types[0]
  module_.function_types[0] = { ..source, signature_type_index: -1, }
  assert_eq(
    verify_module_physical_type_fragments(module_),
    Err(
      function_type_preflight_error(
        101,
        (module_.physical_types.length() + module_.signature_type_count).to_uint64(),
        0xffffffffUL,
        79UL,
        0,
      ),
    ),
  )
}

///|
test "function type resolved identities remain in their source arena" {
  let module_ = function_type_preflight_fixture()
  let source = module_.function_types[0]
  module_.function_types[0] = { ..source, resolved_type: -2, }
  assert_eq(
    verify_module_physical_type_fragments(module_),
    Err(
      function_type_preflight_error(
        101,
        module_.function_type_by_resolved.length().to_uint64(),
        0xfffffffeUL,
        80UL,
        0,
      ),
    ),
  )
}

///|
test "function type resolved lookup retains the stored signature identity" {
  let module_ = function_type_preflight_fixture()
  let source = module_.function_types[0]
  module_.function_type_by_resolved[source.resolved_type] = -1
  assert_eq(
    verify_module_physical_type_fragments(module_),
    Err(
      function_type_preflight_error(
        106,
        source.signature_type_index.to_uint64(),
        0xffffffffUL,
        81UL,
        0,
      ),
    ),
  )
}

///|
test "function type source signatures have one fragment" {
  let module_ = function_type_preflight_fixture()
  module_.function_types.push(module_.function_types[0])
  assert_eq(
    verify_module_physical_type_fragments(module_),
    Err(function_type_preflight_error(404, 1UL, 2UL, 82UL, 2)),
  )
}

///|
test "function type reverse lookup cannot retain an orphan entry" {
  let module_ = function_type_preflight_fixture()
  let source = module_.function_types[0]
  let missing = { ..module_, function_types: [module_.function_types[1]], }
  assert_eq(
    verify_module_physical_type_fragments(missing),
    Err(
      function_type_preflight_error(404, 1UL, 0UL, 83UL, source.resolved_type),
    ),
  )
}

///|
test "function type expansion rejects a structural signature cycle" {
  let module_ = function_type_preflight_fixture()
  let source = module_.function_types[0]
  module_.function_value_types[source.parameters.start] = WasmFunctionRefValue(
    source.signature_type_index,
  )
  assert_eq(
    verify_module_physical_type_fragments(module_),
    Err(function_type_preflight_error(108, 0UL, 1UL, 86UL, 0)),
  )
}

///|
test "function type callback maps remain parallel" {
  let module_ = function_type_preflight_fixture()
  let _ = module_.closure_entry_type_by_resolved.pop()
  assert_eq(
    verify_module_physical_type_fragments(module_),
    Err(
      function_type_preflight_error(
        103,
        module_.function_type_by_resolved.length().to_uint64(),
        module_.closure_entry_type_by_resolved.length().to_uint64(),
        84UL,
        0,
      ),
    ),
  )
}

///|
test "function type graphs permit shared acyclic children" {
  let module_ = function_type_preflight_fixture()
  let leaf = module_.function_types[0]
  let entry = module_.function_types[1]
  module_.function_value_types[entry.parameters.start] = WasmFunctionRefValue(
    leaf.signature_type_index,
  )
  module_.function_value_types[entry.results.start] = WasmFunctionRefValue(
    leaf.signature_type_index,
  )
  assert_eq(verify_module_physical_type_fragments(module_), Ok(()))
}

///|
test "function type values check referenced signature bounds before expansion" {
  let module_ = function_type_preflight_fixture()
  let source = module_.function_types[0]
  module_.function_value_types[source.parameters.start] = WasmFunctionRefValue(
    -1,
  )
  assert_eq(
    verify_module_physical_type_fragments(module_),
    Err(
      function_type_preflight_error(
        101,
        (module_.physical_types.length() + module_.signature_type_count).to_uint64(),
        0xffffffffUL,
        51UL,
        source.parameters.start,
      ),
    ),
  )
}

///|
test "a source signature cannot impersonate a synthetic callback signature" {
  let module_ = function_type_preflight_fixture()
  let source = module_.function_types[0]
  module_.function_types[0] = { ..source, resolved_type: -1, }
  assert_eq(
    verify_module_physical_type_fragments(module_),
    Err(
      function_type_preflight_error(404, 1UL, 0UL, 83UL, source.resolved_type),
    ),
  )
}

///|
test "callback signature maps cannot reference an absent signature" {
  let module_ = function_type_preflight_fixture()
  let source = module_.function_types[0]
  module_.closure_entry_type_by_resolved[source.resolved_type] = -2
  assert_eq(
    verify_module_physical_type_fragments(module_),
    Err(
      function_type_preflight_error(
        503,
        1UL,
        0xfffffffeUL,
        85UL,
        source.resolved_type,
      ),
    ),
  )
}

///|
test "named signature spans retain declaration context before interning" {
  let module_ = function_type_preflight_fixture()
  let source = module_.functions[0]
  let span = { start: -1, length: source.parameters.length, }
  module_.functions[0] = { ..source, parameters: span, }
  let expected = function_type_preflight_error(
    101,
    module_.function_value_types.length().to_uint64(),
    program_function_span_code(span),
    77UL,
    0,
  )
  assert_eq(
    verify_module_physical_type_fragments(module_),
    Err({ ..expected, declaration: source.declaration, }),
  )
}
