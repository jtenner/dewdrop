///|
test "missing source function entries stay missing at lookup" {
  let link = physical_type_test_link()
  let module_ = link.modules[0]
  let declaration = make_semantic_id(module_.module_id, 1)
  assert_true(module_.function_of(declaration) is Some(_))
  module_.function_by_declaration[1] = -1
  assert_eq(module_.function_of(declaration), None)
}

///|
test "source function lookup bounds failures retain complete numeric context" {
  for bad in [-2, 1] {
    let link = physical_type_test_link()
    let module_ = link.modules[0]
    let declaration = make_semantic_id(module_.module_id, 1)
    module_.function_by_declaration[1] = bad
    let expected : ProgramPhysicalTypeFailure = {
      code: 101,
      phase: 5,
      module_id: 23960UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: 1UL,
      actual: bad.reinterpret_as_uint().to_uint64(),
      detail: (70UL << 32) | bad.reinterpret_as_uint().to_uint64(),
    }
    assert_eq(check_module_function_lookup(module_, declaration), Err(expected))
    assert_eq(verify_program_physical_type_fragments(link), Err(expected))
  }
}

///|
test "source function lookup verifies the stored declaration" {
  let link = physical_type_test_link()
  let module_ = link.modules[0]
  let declaration = make_semantic_id(module_.module_id, 0)
  module_.function_by_declaration[0] = 0
  assert_eq(
    check_module_function_lookup(module_, declaration),
    Err({
      code: 504,
      phase: 5,
      module_id: 23960UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: declaration,
      actual: make_semantic_id(23960UL, 1),
      detail: 71UL << 32,
    }),
  )
}

///|
test "plain source lookup cannot substitute a lambda" {
  let link = physical_type_test_link()
  let module_ = link.modules[0]
  let declaration = make_semantic_id(module_.module_id, 1)
  let original = module_.functions[0]
  module_.functions[0] = { ..original, lambda: 7, }
  assert_eq(
    check_module_function_lookup(module_, declaration),
    Err({
      code: 504,
      phase: 5,
      module_id: 23960UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: 0xffffffffUL,
      actual: 7UL,
      detail: 72UL << 32,
    }),
  )
}

///|
test "plain source lookup cannot substitute a specialization" {
  let link = physical_type_test_link()
  let module_ = link.modules[0]
  let declaration = make_semantic_id(module_.module_id, 1)
  let original = module_.functions[0]
  module_.functions[0] = {
    ..original,
    specialization_abi_key: "wrong-instance",
  }
  assert_eq(
    check_module_function_lookup(module_, declaration),
    Err({
      code: 304,
      phase: 5,
      module_id: 23960UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: 0UL,
      actual: 1UL,
      detail: 73UL << 32,
    }),
  )
}

///|
test "source table preflight requires every owned plain function entry" {
  let link = physical_type_test_link()
  let module_ = link.modules[0]
  let declaration = make_semantic_id(module_.module_id, 1)
  module_.function_by_declaration[1] = -1
  assert_eq(check_module_function_lookup(module_, declaration), Ok(None))
  assert_eq(
    verify_program_physical_type_fragments(link),
    Err({
      code: 503,
      phase: 5,
      module_id: 23960UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: 0UL,
      actual: 0xffffffffUL,
      detail: 75UL << 32,
    }),
  )
}

///|
test "source table preflight requires the complete declaration slot arena" {
  let link = physical_type_test_link()
  let module_ = link.modules[0]
  let declaration = make_semantic_id(module_.module_id, 1)
  assert_eq(module_.function_by_declaration.length(), 2)
  let _ = module_.function_by_declaration.pop()
  assert_eq(
    verify_program_physical_type_fragments(link),
    Err({
      code: 101,
      phase: 5,
      module_id: 23960UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: 1UL,
      actual: 1UL,
      detail: 75UL << 32,
    }),
  )
}

///|
fn imported_function_lookup_fixture() -> (
  PlannedModuleWasmGCFragments,
  DeclId,
  Int,
) raise {
  let stages = compiler_test_stages(23970UL, [
    CompilerTestModule::new("lookup.traits", [
      CompilerTestSource::new(
        "trait.dew", b"pub trait Read {\n  fn read(self) -> I32\n}\n",
      ),
    ]),
    CompilerTestModule::new("lookup.consumer", [
      CompilerTestSource::new(
        "consumer.dew", b"open lookup.traits\npub fn invoke(value: Read) -> I32 {\n  value.read()\n}\n",
      ),
    ]),
  ])
  assert_eq(stages.diagnostics(), [])
  let link = plan_program_wasmgc_link(stages.analyzed, stages.lowering, 1)
  assert_eq(link.diagnostics, [])
  let module_ = link.modules[1]
  let mut declaration = 0UL
  let mut selected = -1
  for index, source in module_.functions {
    if semantic_id_module(source.declaration) == 23970UL &&
      source.kind is PlannedWasmSignatureOnlyFunction {
      assert_eq(selected, -1)
      selected = index
      declaration = source.declaration
    }
  }
  assert_true(selected >= 0)
  assert_eq(
    check_module_function_lookup(module_, declaration),
    Ok(Some(module_.functions[selected])),
  )
  assert_eq(verify_module_function_lookups(module_), Ok(()))
  (module_, declaration, selected)
}

///|
test "imported source function lookup rejects ambiguous plain records" {
  let (module_, declaration, index) = imported_function_lookup_fixture()
  module_.functions.push(module_.functions[index])
  let failure : ProgramPhysicalTypeFailure = {
    code: 304,
    phase: 5,
    module_id: 23971UL,
    declaration,
    body: 0UL,
    expression: 0xffffffffU,
    expected: 1UL,
    actual: 2UL,
    detail: (76UL << 32) | index.to_uint64(),
  }
  assert_eq(check_module_function_lookup(module_, declaration), Err(failure))
  assert_eq(verify_module_function_lookups(module_), Err(failure))
}

///|
test "an imported specialization is not a plain source lookup fallback" {
  let (module_, declaration, index) = imported_function_lookup_fixture()
  let source = module_.functions[index]
  module_.functions[index] = {
    ..source,
    specialization_abi_key: "wrong-instance",
  }
  assert_eq(check_module_function_lookup(module_, declaration), Ok(None))
  assert_eq(module_.function_of(declaration), None)
}
