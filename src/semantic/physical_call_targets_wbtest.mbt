///|
test "physical call target replay cannot overwrite its frozen identity" {
  let (link, declaration) = ambiguous_specialization_test_link()
  let keys : Array[ProgramSpecializedCallKey] = []
  for key, witness in link.specialized_call_targets {
    if witness.declaration == declaration {
      keys.push(key)
    }
  }
  assert_eq(keys.length(), 2)
  let key = keys[0]
  let witness = link.specialized_call_targets[key]
  let other = link.specialized_call_targets[keys[1]]
  let call : PlannedProgramSpecializedCall = {
    caller_body: key.body,
    caller_specialization_abi_key: key.specialization_abi_key,
    expression: key.expression,
    target: declaration,
    target_specialization_abi_key: witness.specialization_abi_key,
    runtime_evidence_parameters: { start: 0, length: 0, },
  }
  let targets : Map[ProgramSpecializedCallKey, PlannedProgramPhysicalCallTarget] = Map::default()
  let function_ = link.functions[witness.function_table_index]
  assert_eq(
    record_program_physical_call_target(
      targets,
      call,
      witness.function_table_index,
      function_,
    ),
    Ok(()),
  )
  assert_eq(targets[key], witness)
  assert_eq(
    record_program_physical_call_target(
      targets,
      call,
      witness.function_table_index,
      function_,
    ),
    Ok(()),
  )
  let changes = [
    (
      call,
      witness.function_table_index,
      { ..function_, function_index: function_.function_index + 1, },
      witness.function_index.to_uint64(),
      (witness.function_index + 1).to_uint64(),
      2UL,
    ),
    (
      call,
      witness.function_table_index + 1,
      function_,
      witness.function_table_index.to_uint64(),
      (witness.function_table_index + 1).to_uint64(),
      3UL,
    ),
    (
      { ..call, target_specialization_abi_key: other.specialization_abi_key, },
      other.function_table_index,
      link.functions[other.function_table_index],
      1UL,
      0UL,
      1UL,
    ),
  ]
  for item in changes {
    let (changed, index, selected, expected, actual, detail) = item
    assert_eq(
      record_program_physical_call_target(targets, changed, index, selected),
      Err({
        code: 303,
        phase: 5,
        module_id: 24912UL,
        declaration,
        body: key.body,
        expression: key.expression.reinterpret_as_uint(),
        expected,
        actual,
        detail,
      }),
    )
    assert_eq(targets[key], witness)
  }
}

///|
test "physical call target insertion checks the selected declaration and key" {
  let (link, declaration) = ambiguous_specialization_test_link(two=false)
  let mut checked = 0
  for key, witness in link.specialized_call_targets {
    if witness.declaration != declaration {
      continue
    }
    checked += 1
    let call : PlannedProgramSpecializedCall = {
      caller_body: key.body,
      caller_specialization_abi_key: key.specialization_abi_key,
      expression: key.expression,
      target: declaration,
      target_specialization_abi_key: witness.specialization_abi_key,
      runtime_evidence_parameters: { start: 0, length: 0, },
    }
    let targets : Map[
      ProgramSpecializedCallKey,
      PlannedProgramPhysicalCallTarget,
    ] = Map::default()
    let function_ = link.functions[witness.function_table_index]
    for
      item in [
        (
          { ..function_, declaration: declaration + 1UL, },
          declaration,
          declaration + 1UL,
          6UL,
        ),
        ({ ..function_, specialization_abi_key: "wrong", }, 1UL, 0UL, 7UL),
      ] {
      let (selected, expected, actual, detail) = item
      assert_eq(
        record_program_physical_call_target(
          targets,
          call,
          witness.function_table_index,
          selected,
        ),
        Err({
          code: 504,
          phase: 5,
          module_id: 24912UL,
          declaration,
          body: key.body,
          expression: key.expression.reinterpret_as_uint(),
          expected,
          actual,
          detail,
        }),
      )
      assert_eq(targets.get(key), None)
    }
  }
  assert_eq(checked, 1)
}
