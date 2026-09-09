///|
fn startup_selected_query_stages() -> SemanticCompilerTestStages raise {
  let program = compiler_test_single_module_program(
    24914UL, b"builtin is_unit<t>() -> Bool = \"types.is_unit\"\nfn choose<t>() -> I64 {\n  if is_unit::<t>() {\n    answer\n  } else {\n    42i64\n  }\n}\nlet answer = choose::<I32>()\npub fn main() -> I64 {\n  answer\n}\n",
  )
  let analyzed = compiler_test_analyze(program)
  let lowering = compiler_test_lower(program, analyzed)
  for module_ in lowering.modules {
    assert_eq(module_.diagnostics, [])
  }
  let link = compiler_test_link(analyzed, lowering)
  assert_eq(link.diagnostics, [])
  assert_eq(link.initializers.length(), 1)
  { program, analyzed, lowering, link, }
}

///|
test "startup selected query ignores a global read in its removed branch" {
  let _ = startup_selected_query_stages()
}

///|
test "startup selected query keeps a cycle in the selected branch" {
  let stages = compiler_test_stages(24914UL, [
    CompilerTestModule::new("app.main", [
      CompilerTestSource::new(
        "main.dew", b"builtin is_unit<t>() -> Bool = \"types.is_unit\"\nfn choose<t>() -> I64 {\n  if is_unit::<t>() {\n    answer\n  } else {\n    42i64\n  }\n}\nlet answer = choose::<Unit>()\npub fn main() -> I64 {\n  answer\n}\n",
      ),
    ]),
  ])
  let answer = (24914UL << 32) | 2UL
  assert_eq(stages.link.diagnostics, [
    EagerProgramInitializationCycle(answer, answer),
  ])
}

///|
test "startup selected query visits two logical instances of one body" {
  let stages = compiler_test_stages(24914UL, [
    CompilerTestModule::new("app.main", [
      CompilerTestSource::new(
        "main.dew", b"builtin is_unit<t>() -> Bool = \"types.is_unit\"\nlet left = 19i64\nlet right = 23i64\nfn choose<t>() -> I64 {\n  if is_unit::<t>() {\n    left\n  } else {\n    right\n  }\n}\npub let answer = choose::<Unit>() + choose::<I32>()\n",
      ),
    ]),
  ])
  assert_eq(stages.link.diagnostics, [])
  let fragments = plan_program_wasmgc_fragments(
    stages.analyzed,
    stages.lowering,
  )
  let calls = check_program_initializer_call_lookup(fragments.specialized_calls).unwrap()
  let candidates = stages.link.initializers
  let lookup = check_program_initializer_candidate_lookup(candidates).unwrap()
  let values = check_program_initializer_dependencies(
    stages.lowering,
    candidates[2],
    lookup,
    candidates,
    calls~,
  ).unwrap()
  assert_eq(values.length(), 2)
  assert_true(values.contains(0))
  assert_true(values.contains(1))
}

///|
test "startup selected query rejects a missing call map instead of using its template" {
  let stages = startup_selected_query_stages()
  let candidates = stages.link.initializers
  let lookup = check_program_initializer_candidate_lookup(candidates).unwrap()
  assert_eq(
    check_program_initializer_dependencies(
      stages.lowering,
      candidates[0],
      lookup,
      candidates,
    ),
    Err({
      code: 304,
      phase: 5,
      module_id: 24914UL,
      declaration: (24914UL << 32) | 1UL,
      body: 24914UL << 32,
      expression: 0xffffffffU,
      expected: 1UL,
      actual: 0UL,
      detail: 23UL,
    }),
  )
}

///|
test "startup selected query checks cached instance declaration identity" {
  let stages = startup_selected_query_stages()
  let fragments = plan_program_wasmgc_fragments(
    stages.analyzed,
    stages.lowering,
  )
  let calls = check_program_initializer_call_lookup(fragments.specialized_calls).unwrap()
  let candidates = stages.link.initializers
  let lookup = check_program_initializer_candidate_lookup(candidates).unwrap()
  let context = stages.lowering.compile_time.unwrap()
  for call in fragments.specialized_calls {
    if call.caller_body == candidates[0].body {
      let original = context.instances[call.target_specialization_abi_key]
      context.instances[call.target_specialization_abi_key] = {
        ..original,
        declaration: original.declaration + 1UL,
      }
    }
  }
  assert_eq(
    check_program_initializer_dependencies(
      stages.lowering,
      candidates[0],
      lookup,
      candidates,
      calls~,
    ),
    Err({
      code: 106,
      phase: 5,
      module_id: 24914UL,
      declaration: (24914UL << 32) | 1UL,
      body: 24914UL << 32,
      expression: 0xffffffffU,
      expected: (24914UL << 32) | 1UL,
      actual: (24914UL << 32) | 2UL,
      detail: 23UL,
    }),
  )
}

///|
test "startup selected query rejects a different duplicate target key" {
  let stages = startup_selected_query_stages()
  let fragments = plan_program_wasmgc_fragments(
    stages.analyzed,
    stages.lowering,
  )
  let call = fragments.specialized_calls[0]
  assert_true(check_program_initializer_call_lookup([call, call]) is Ok(_))
  assert_eq(
    check_program_initializer_call_lookup([
      call,
      {
        ..call,
        target_specialization_abi_key: call.target_specialization_abi_key +
        "changed",
      },
    ]),
    Err({
      code: 303,
      phase: 5,
      module_id: 24914UL,
      declaration: call.target,
      body: call.caller_body,
      expression: call.expression.reinterpret_as_uint(),
      expected: 1UL,
      actual: 2UL,
      detail: 24UL,
    }),
  )
}

///|
test "startup selected query rejects an absent or foreign cached instance" {
  for mutation in 0..<2 {
    let stages = startup_selected_query_stages()
    let fragments = plan_program_wasmgc_fragments(
      stages.analyzed,
      stages.lowering,
    )
    let calls = check_program_initializer_call_lookup(
      fragments.specialized_calls,
    ).unwrap()
    let candidates = stages.link.initializers
    let lookup = check_program_initializer_candidate_lookup(candidates).unwrap()
    let context = stages.lowering.compile_time.unwrap()
    for call in fragments.specialized_calls {
      if call.caller_body == candidates[0].body {
        if mutation == 0 {
          context.instances.remove(call.target_specialization_abi_key)
        } else {
          let original = context.instances[call.target_specialization_abi_key]
          context.instances[call.target_specialization_abi_key] = {
            ..original,
            module_: { ..original.module_, module_id: 24915UL, },
          }
        }
      }
    }
    assert_eq(
      check_program_initializer_dependencies(
        stages.lowering,
        candidates[0],
        lookup,
        candidates,
        calls~,
      ),
      Err({
        code: if mutation == 0 {
          304
        } else {
          107
        },
        phase: 5,
        module_id: 24914UL,
        declaration: (24914UL << 32) | 1UL,
        body: 24914UL << 32,
        expression: 0xffffffffU,
        expected: if mutation == 0 {
          1UL
        } else {
          24914UL
        },
        actual: if mutation == 0 {
          0UL
        } else {
          24915UL
        },
        detail: 23UL,
      }),
    )
  }
}

///|
test "startup selected query checks all stored call identities" {
  for mutation in 0..<4 {
    let stages = startup_selected_query_stages()
    let fragments = plan_program_wasmgc_fragments(
      stages.analyzed,
      stages.lowering,
    )
    let calls = check_program_initializer_call_lookup(
      fragments.specialized_calls,
    ).unwrap()
    let candidates = stages.link.initializers
    let lookup = check_program_initializer_candidate_lookup(candidates).unwrap()
    let caller = stages.lowering.modules[0].bodies[semantic_id_local(
        candidates[0].body,
      )]
    let mut observed = false
    for call in fragments.specialized_calls {
      if call.caller_body != caller.body ||
        !(stages.lowering.modules[0].expressions[call.expression].kind
        is PlannedDirectCall(_, _, _, _)) {
        continue
      }
      observed = true
      let key : ProgramSpecializedCallKey = {
        body: call.caller_body,
        specialization_abi_key: call.caller_specialization_abi_key,
        expression: call.expression,
      }
      let (changed, expected, actual) = match mutation {
        0 =>
          (
            { ..call, caller_body: call.caller_body + 1UL, },
            call.caller_body,
            call.caller_body + 1UL,
          )
        1 =>
          (
            { ..call, expression: call.expression + 1, },
            call.expression.to_uint64(),
            (call.expression + 1).to_uint64(),
          )
        2 => ({ ..call, caller_specialization_abi_key: "wrong", }, 1UL, 0UL)
        _ =>
          (
            { ..call, target: call.target + 1UL, },
            call.target,
            call.target + 1UL,
          )
      }
      calls[key] = changed
      assert_eq(
        check_program_initializer_dependencies(
          stages.lowering,
          candidates[0],
          lookup,
          candidates,
          calls~,
        ),
        Err({
          code: if mutation == 2 {
            303
          } else {
            106
          },
          phase: 5,
          module_id: 24914UL,
          declaration: caller.declaration,
          body: caller.body,
          expression: call.expression.reinterpret_as_uint(),
          expected,
          actual,
          detail: 25UL,
        }),
      )
    }
    assert_true(observed)
  }
}
