///|
fn lambda_function_lookup_test_link() -> PlannedProgramWasmGCLink raise {
  let stages = compiler_test_stages(28164UL, [
    CompilerTestModule::new("app.lambda_functions", [
      CompilerTestSource::new(
        "main.dew", b"pub fn make(flag: Bool) -> fn() -> I32 {\n  if flag {\n    fn() -> I32 {\n      1\n    }\n  } else {\n    fn() -> I32 {\n      2\n    }\n  }\n}\n",
      ),
    ]),
  ])
  assert_eq(stages.diagnostics(), [])
  stages.link
}

///|
fn lambda_function_lookup_failure(
  code : Int32,
  expected : UInt64,
  actual : UInt64,
  role : UInt64,
  slot : Int32,
) -> ProgramPhysicalTypeFailure {
  physical_type_failure(28164UL, 0UL, code, expected, actual, role, slot)
}

///|
test "lambda function lookup rejects another valid same-signature lambda" {
  let link = lambda_function_lookup_test_link()
  let module_ = link.modules[0]
  assert_eq(module_.lambda_function_indices.length(), 2)
  assert_eq(verify_program_physical_type_fragments(link), Ok(()))
  let first = module_.lambda_function_indices[0]
  let second = module_.lambda_function_indices[1]
  assert_true(first != second)
  assert_eq(
    module_.functions[first].signature_type_index,
    module_.functions[second].signature_type_index,
  )
  module_.lambda_function_indices[0] = second
  assert_eq(
    verify_program_physical_type_fragments(link),
    Err(lambda_function_lookup_failure(504, 0UL, 1UL, 122UL, 0)),
  )
}

///|
test "lambda function tables require complete parallel dimensions" {
  let module_ = lambda_function_lookup_test_link().modules[0]
  assert_eq(
    verify_module_lambda_function_lookups({
      ..module_,
      lambda_function_indices: [],
    }),
    Err(lambda_function_lookup_failure(103, 2UL, 0UL, 120UL, 0)),
  )
  assert_eq(
    verify_module_lambda_function_lookups({
      ..module_,
      lambda_entry_signature_indices: [],
    }),
    Err(lambda_function_lookup_failure(103, 2UL, 0UL, 120UL, 1)),
  )
}

///|
test "lambda function and signature bounds are checked before reads" {
  let module_ = lambda_function_lookup_test_link().modules[0]
  let original = module_.lambda_function_indices[0]
  for index in [-2, module_.functions.length()] {
    module_.lambda_function_indices[0] = index
    assert_eq(
      verify_module_lambda_function_lookups(module_),
      Err(
        lambda_function_lookup_failure(
          101,
          module_.functions.length().to_uint64(),
          index.reinterpret_as_uint().to_uint64(),
          121UL,
          0,
        ),
      ),
    )
  }
  module_.lambda_function_indices[0] = original
  let limit = module_.physical_types.length() + module_.signature_type_count
  for entry in [-2, module_.closure_type_index, limit] {
    assert_true(entry < module_.physical_types.length() || entry >= limit)
    module_.lambda_entry_signature_indices[0] = entry
    assert_eq(
      verify_module_lambda_function_lookups(module_),
      Err(
        lambda_function_lookup_failure(
          101,
          limit.to_uint64(),
          entry.reinterpret_as_uint().to_uint64(),
          125UL,
          0,
        ),
      ),
    )
  }
}

///|
test "lambda function kind and entry signature retain their identities" {
  let module_ = lambda_function_lookup_test_link().modules[0]
  let index = module_.lambda_function_indices[0]
  let source = module_.functions[index]
  module_.functions[index] = {
    ..source,
    kind: PlannedWasmDefinedLambdaFunction(1),
  }
  assert_eq(
    verify_module_lambda_function_lookups(module_),
    Err(lambda_function_lookup_failure(504, 0UL, 1UL, 123UL, 0)),
  )
  module_.functions[index] = source
  let other = module_.functions[0].signature_type_index
  assert_true(other != source.signature_type_index)
  module_.lambda_entry_signature_indices[0] = other
  assert_eq(
    verify_module_lambda_function_lookups(module_),
    Err(
      lambda_function_lookup_failure(
        504,
        source.signature_type_index.to_uint64(),
        other.to_uint64(),
        124UL,
        0,
      ),
    ),
  )
  module_.lambda_entry_signature_indices[0] = -1
  assert_eq(
    verify_module_lambda_function_lookups(module_),
    Err(
      lambda_function_lookup_failure(
        503,
        source.signature_type_index.to_uint64(),
        0xffffffffUL,
        124UL,
        0,
      ),
    ),
  )
}

///|
test "missing lambda functions cannot leave signatures or orphan plain fragments" {
  let module_ = lambda_function_lookup_test_link().modules[0]
  let index = module_.lambda_function_indices[0]
  module_.lambda_function_indices[0] = -1
  assert_eq(
    verify_module_lambda_function_lookups(module_),
    Err(lambda_function_lookup_failure(503, 1UL, 0UL, 130UL, 0)),
  )
  module_.lambda_entry_signature_indices[0] = -1
  assert_eq(
    verify_module_lambda_function_lookups(module_),
    Err(
      lambda_function_lookup_failure(
        503,
        index.to_uint64(),
        0xffffffffUL,
        129UL,
        0,
      ),
    ),
  )
}

///|
test "plain lambda fragments must have one exact base record" {
  let module_ = lambda_function_lookup_test_link().modules[0]
  let index = module_.lambda_function_indices[0]
  let duplicate = module_.functions.length()
  module_.functions.push(module_.functions[index])
  assert_eq(
    verify_module_lambda_function_lookups(module_),
    Err(
      lambda_function_lookup_failure(
        504,
        index.to_uint64(),
        duplicate.to_uint64(),
        128UL,
        0,
      ),
    ),
  )
}

///|
test "unselected lambda instances still require valid stored lambda identities" {
  let module_ = lambda_function_lookup_test_link().modules[0]
  let index = module_.lambda_function_indices[0]
  let source = module_.functions[index]
  let slot = module_.functions.length()
  module_.functions.push({
    ..source,
    lambda: 2,
    specialization_abi_key: "unselected-instance",
  })
  assert_eq(
    verify_module_lambda_function_lookups(module_),
    Err(lambda_function_lookup_failure(101, 2UL, 2UL, 126UL, slot)),
  )
  module_.functions[slot] = {
    ..source,
    kind: PlannedWasmSignatureOnlyFunction,
    specialization_abi_key: "unselected-instance",
  }
  assert_eq(
    verify_module_lambda_function_lookups(module_),
    Err(lambda_function_lookup_failure(504, 0UL, 0xffffffffUL, 127UL, slot)),
  )
}

///|
test "generic lambda views retain all instances without requiring base map coverage" {
  let program = collect_program_manifest(
    28164UL,
    ProgramManifest::new([
      ManifestModule::new("app.lambda_functions", [
        ManifestFile::new(
          "main.dew", b"open dew.std.types\nfn capture<t>(value: t) -> fn() -> t {\n  fn() -> t {\n    let _ = is_unit::<t>()\n    value\n  }\n}\npub fn main() -> I64 {\n  let unit = capture::<Unit>(())\n  let scalar = capture::<I64>(42i64)\n  unit()\n  scalar()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  let planned = plan_program_wasmgc_fragments(analyzed, lowering)
  let fragments = planned.modules[0]
  assert_eq(fragments.lambda_function_indices, [-1])
  assert_eq(fragments.lambda_entry_signature_indices, [-1])
  assert_eq(verify_module_lambda_function_lookups(fragments), Ok(()))
  let mut checked = 0
  for key, _ in fragments.specialized_lambda_layouts {
    let instance = program_function_lowering(lowering, 0, key)
    let selected = program_function_fragments(instance, fragments, key)
    assert_eq(
      verify_module_lambda_function_lookups(selected, selected_key=key),
      Ok(()),
    )
    let function_ = selected.functions[selected.lambda_function_indices[0]]
    assert_eq(function_.specialization_abi_key, key)
    assert_false(function_.elided)
    assert_eq(
      verify_module_lambda_function_lookups(selected),
      Err(lambda_function_lookup_failure(504, 1UL, 0UL, 131UL, 0)),
    )
    let selected_index = selected.lambda_function_indices[0]
    selected.functions[selected_index] = {
      ..function_,
      specialization_abi_key: "wrong-owner-instance",
    }
    assert_eq(
      verify_module_lambda_function_lookups(selected, selected_key=key),
      Err(lambda_function_lookup_failure(504, 1UL, 0UL, 131UL, 0)),
    )
    selected.functions[selected_index] = function_
    checked += 1
  }
  assert_eq(checked, 2)
}

///|
test "runtime generic lambda views retain an elided plain template" {
  let program = collect_program_manifest(
    28164UL,
    ProgramManifest::new([
      ManifestModule::new("app.lambda_functions", [
        ManifestFile::new(
          "main.dew", b"pub fn capture<t>(value: t) -> fn() -> t {\n  fn() -> t {\n    value\n  }\n}\npub fn main() -> I64 {\n  let callback = capture::<I64>(42i64)\n  callback()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  let planned = plan_program_wasmgc_fragments(analyzed, lowering)
  let fragments = planned.modules[0]
  assert_eq(verify_module_lambda_function_lookups(fragments), Ok(()))
  let base = fragments.lambda_function_indices[0]
  assert_true(base >= 0)
  assert_true(fragments.functions[base].elided)
  let mut checked = 0
  for key, _ in fragments.specialized_lambda_layouts {
    let instance = program_function_lowering(lowering, 0, key)
    let selected = program_function_fragments(instance, fragments, key)
    assert_eq(
      verify_module_lambda_function_lookups(selected, selected_key=key),
      Ok(()),
    )
    assert_true(selected.lambda_function_indices[0] != base)
    checked += 1
  }
  assert_true(checked > 0)
}
