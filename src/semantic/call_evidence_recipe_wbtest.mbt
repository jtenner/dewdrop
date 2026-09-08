///|
fn call_evidence_recipe_test_link() -> (
  PlannedProgramWasmGCLink,
  ProgramSpecializedCallKey,
  DeclId,
  HirSpan,
) raise {
  let program = collect_program_manifest(
    24913UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Left {\n  fn left(self) -> I32\n}\ntrait Right {\n  fn right(self) -> I32\n}\nimpl Left for I32 {\n  fn left(self) -> I32 {\n    self\n  }\n}\nimpl Right for I64 {\n  fn right(self) -> I32 {\n    2i32\n  }\n}\nfn need<a: Left, b: Right>(left: a, right: b) -> I32 {\n  left.left() + right.right()\n}\npub fn relay<a: Left, b: Right>(left: a, right: b) -> I32 {\n  need(left, right)\n}\npub fn main() -> I32 {\n  relay(1i32, 2i64)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(
    collect_compiler_source_diagnostics(program, analyzed, lowering, link),
    [],
  )
  let declaration = program.modules[0].lookup_value("need").unwrap()
  let keys : Array[ProgramSpecializedCallKey] = []
  for key, span in link.specialized_call_runtime_evidence_lookup {
    if span.length == 2 &&
      link.specialized_call_targets[key].declaration == declaration {
      keys.push(key)
    }
  }
  assert_eq(keys.length(), 1)
  let key = keys[0]
  (link, key, declaration, link.specialized_call_runtime_evidence_lookup[key])
}

///|
test "a trait argument cannot be changed after its call recipe is frozen" {
  let (link, key, declaration, span) = call_evidence_recipe_test_link()
  let expected = link.specialized_call_runtime_evidence_parameters[span.start]
  let actual = link.specialized_call_runtime_evidence_parameters[span.start + 1]
  assert_true(expected >= 0 && actual >= 0 && expected != actual)
  assert_eq(link.specialized_call_targets[key].runtime_evidence_operands, [
    expected, actual,
  ])
  assert_eq(
    check_program_specialized_call_runtime_evidence(
      link,
      key.body,
      key.specialization_abi_key,
      key.expression,
    ),
    Ok(Some(span)),
  )
  link.specialized_call_runtime_evidence_parameters[span.start] = actual
  assert_eq(link.specialized_call_targets[key].runtime_evidence_operands, [
    expected, actual,
  ])
  assert_eq(
    check_program_specialized_call_runtime_evidence(
      link,
      key.body,
      key.specialization_abi_key,
      key.expression,
    ),
    Err({
      code: 704,
      phase: 5,
      module_id: 24913UL,
      declaration,
      body: key.body,
      expression: key.expression.reinterpret_as_uint(),
      expected: expected.to_uint64(),
      actual: actual.to_uint64(),
      detail: 0UL,
    }),
  )
}

///|
fn call_evidence_recipe_assert_failure(
  link : PlannedProgramWasmGCLink,
  key : ProgramSpecializedCallKey,
  declaration : DeclId,
  code : Int,
  expected : UInt64,
  actual : UInt64,
  detail : UInt64,
) -> Unit raise {
  let failure : ProgramFunctionLookupFailure = {
    code,
    phase: 5,
    module_id: 24913UL,
    declaration,
    body: key.body,
    expression: key.expression.reinterpret_as_uint(),
    expected,
    actual,
    detail,
  }
  assert_eq(
    check_program_specialized_call_runtime_evidence(
      link,
      key.body,
      key.specialization_abi_key,
      key.expression,
    ),
    Err(failure),
  )
  assert_eq(verify_program_call_evidence_recipes(link), Err(failure))
}

///|
test "a frozen trait recipe must retain every hidden operand" {
  let (link, key, declaration, span) = call_evidence_recipe_test_link()
  link.specialized_call_runtime_evidence_lookup[key] = {
    start: span.start,
    length: 1,
  }
  call_evidence_recipe_assert_failure(
    link, key, declaration, 703, 2UL, 1UL, 0UL,
  )
  let _ = link.specialized_call_runtime_evidence_lookup.remove(key)
  call_evidence_recipe_assert_failure(
    link, key, declaration, 703, 2UL, 0UL, 0UL,
  )
  link.specialized_call_runtime_evidence_lookup[key] = span
  assert_eq(verify_program_call_evidence_recipes(link), Ok(()))
}

///|
test "trait operand spans are checked before reads" {
  let (link, key, declaration, original) = call_evidence_recipe_test_link()
  let length = link.specialized_call_runtime_evidence_parameters.length()
  for
    span in [
      { start: -1, length: 2, },
      { start: length, length: 2, },
      { start: original.start, length: -1, },
    ] {
    link.specialized_call_runtime_evidence_lookup[key] = span
    call_evidence_recipe_assert_failure(
      link,
      key,
      declaration,
      101,
      length.to_uint64(),
      (span.start.reinterpret_as_uint().to_uint64() << 32) |
      span.length.reinterpret_as_uint().to_uint64(),
      0UL,
    )
  }
  link.specialized_call_runtime_evidence_lookup[key] = original
}

///|
test "negative trait operands remain a visible recipe error" {
  let (link, key, declaration, span) = call_evidence_recipe_test_link()
  let original = link.specialized_call_runtime_evidence_parameters[span.start]
  link.specialized_call_runtime_evidence_parameters[span.start] = -1
  call_evidence_recipe_assert_failure(
    link,
    key,
    declaration,
    704,
    original.to_uint64(),
    0xffffffffUL,
    0UL,
  )
  link.specialized_call_runtime_evidence_parameters[span.start] = original
}

///|
test "a physical target replay must retain its trait operands" {
  let (link, key, declaration, span) = call_evidence_recipe_test_link()
  let witness = link.specialized_call_targets[key]
  let function_ = link.functions[witness.function_table_index]
  let call : PlannedProgramSpecializedCall = {
    caller_body: key.body,
    caller_specialization_abi_key: key.specialization_abi_key,
    expression: key.expression,
    target: declaration,
    target_specialization_abi_key: witness.specialization_abi_key,
    runtime_evidence_parameters: span,
  }
  let targets : Map[ProgramSpecializedCallKey, PlannedProgramPhysicalCallTarget] = Map::default()
  let values = link.specialized_call_runtime_evidence_parameters
  assert_eq(
    record_program_physical_call_target(
      targets,
      call,
      witness.function_table_index,
      function_,
      values,
    ),
    Ok(()),
  )
  assert_eq(targets[key], witness)
  let original = values[span.start]
  let actual = values[span.start + 1]
  values[span.start] = actual
  assert_eq(
    record_program_physical_call_target(
      targets,
      call,
      witness.function_table_index,
      function_,
      values,
    ),
    Err({
      code: 303,
      phase: 5,
      module_id: 24913UL,
      declaration,
      body: key.body,
      expression: key.expression.reinterpret_as_uint(),
      expected: original.to_uint64(),
      actual: actual.to_uint64(),
      detail: 5UL << 32,
    }),
  )
  assert_eq(targets[key], witness)
  values[span.start] = original
  let shorter = {
    ..call,
    runtime_evidence_parameters: { start: span.start, length: 1, },
  }
  assert_eq(
    record_program_physical_call_target(
      targets,
      shorter,
      witness.function_table_index,
      function_,
      values,
    ),
    Err({
      code: 303,
      phase: 5,
      module_id: 24913UL,
      declaration,
      body: key.body,
      expression: key.expression.reinterpret_as_uint(),
      expected: 2UL,
      actual: 1UL,
      detail: 4UL,
    }),
  )
  assert_eq(targets[key], witness)
}

///|
test "a recipe without a target cannot reach the emitter" {
  let (link, _, _, span) = call_evidence_recipe_test_link()
  let key = program_specialized_call_key(0UL, "", 0)
  link.specialized_call_runtime_evidence_lookup[key] = span
  let failure : ProgramFunctionLookupFailure = {
    code: 304,
    phase: 5,
    module_id: 0UL,
    declaration: 0UL,
    body: 0UL,
    expression: 0U,
    expected: 1UL,
    actual: 0UL,
    detail: 2UL,
  }
  assert_eq(
    check_program_specialized_call_runtime_evidence(link, 0UL, "", 0),
    Err(failure),
  )
  assert_eq(verify_program_call_evidence_recipes(link), Err(failure))
}

///|
test "invalid trait operands cannot be published in a target witness" {
  let (link, key, declaration, span) = call_evidence_recipe_test_link()
  let witness = link.specialized_call_targets[key]
  let function_ = link.functions[witness.function_table_index]
  let call : PlannedProgramSpecializedCall = {
    caller_body: key.body,
    caller_specialization_abi_key: key.specialization_abi_key,
    expression: key.expression,
    target: declaration,
    target_specialization_abi_key: witness.specialization_abi_key,
    runtime_evidence_parameters: span,
  }
  let targets : Map[ProgramSpecializedCallKey, PlannedProgramPhysicalCallTarget] = Map::default()
  let values = link.specialized_call_runtime_evidence_parameters
  let invalid = {
    ..call,
    runtime_evidence_parameters: { start: -1, length: span.length, },
  }
  assert_eq(
    record_program_physical_call_target(
      targets,
      invalid,
      witness.function_table_index,
      function_,
      values,
    ),
    Err({
      code: 101,
      phase: 5,
      module_id: 24913UL,
      declaration,
      body: key.body,
      expression: key.expression.reinterpret_as_uint(),
      expected: values.length().to_uint64(),
      actual: (0xffffffffUL << 32) | span.length.to_uint64(),
      detail: 4UL,
    }),
  )
  assert_eq(targets.get(key), None)
  let original = values[span.start]
  values[span.start] = -1
  assert_eq(
    record_program_physical_call_target(
      targets,
      call,
      witness.function_table_index,
      function_,
      values,
    ),
    Err({
      code: 704,
      phase: 5,
      module_id: 24913UL,
      declaration,
      body: key.body,
      expression: key.expression.reinterpret_as_uint(),
      expected: 0UL,
      actual: 0xffffffffUL,
      detail: 0UL,
    }),
  )
  assert_eq(targets.get(key), None)
  values[span.start] = original
}
