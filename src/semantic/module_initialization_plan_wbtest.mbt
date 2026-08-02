///|
fn initialization_test_module(
  module_id : UInt64,
  source : Bytes,
) -> (CollectedModule, InferredModuleBodies, PlannedModuleInitialization) {
  let collected = collect_bytes(module_id, source)
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let initialization = plan_module_initialization(
    collected,
    inferred.module_values,
  )
  (collected, inferred, initialization)
}

///|
test "module initialization steps are dependency first" {
  let (collected, inferred, initialization) = initialization_test_module(
    941UL, b"let first = second + 1\nlet second = 2\nlet third = first + second\n",
  )
  assert_eq(initialization.diagnostics.length(), 0)
  assert_eq(initialization.steps.length(), 3)
  let expected = [
    collected.lets[1].declaration,
    collected.lets[0].declaration,
    collected.lets[2].declaration,
  ]
  for index in 0..<expected.length() {
    match initialization.steps[index].kind {
      PlannedInitializeModuleValue(declaration, body, type_) => {
        assert_eq(declaration, expected[index])
        assert_eq(body, collected.body_of(declaration).unwrap().id)
        let let_index = if declaration == collected.lets[0].declaration {
          0
        } else if declaration == collected.lets[1].declaration {
          1
        } else {
          2
        }
        assert_eq(type_, inferred.module_values.let_types[let_index])
      }
      _ => fail("expected eager initialization step")
    }
  }
}

///|
test "mutual and self module initialization cycles are explicit" {
  let (collected, _, initialization) = initialization_test_module(
    942UL, b"let first = second\nlet second = first\nlet self = self\nlet independent = 1\n",
  )
  assert_eq(initialization.diagnostics.length(), 2)
  assert_eq(initialization.cycle_declarations.length(), 3)
  let mut mutual = false
  let mut self_cycle = false
  for step in initialization.steps {
    match step.kind {
      PlannedCyclicModuleValues(members) =>
        if members.length == 2 {
          mutual = true
          assert_eq(
            initialization.cycle_declarations[members.start],
            collected.lets[0].declaration,
          )
          assert_eq(
            initialization.cycle_declarations[members.start + 1],
            collected.lets[1].declaration,
          )
        } else {
          self_cycle = true
          assert_eq(
            initialization.cycle_declarations[members.start],
            collected.lets[2].declaration,
          )
        }
      PlannedInitializeModuleValue(_, _, _) => ()
    }
  }
  assert_true(mutual)
  assert_true(self_cycle)
  assert_eq(
    initialization.declaration_steps[semantic_id_local(
      collected.lets[0].declaration,
    )],
    initialization.declaration_steps[semantic_id_local(
      collected.lets[1].declaration,
    )],
  )
}

///|
test "type-constrained recursive module values remain runtime-illegal" {
  let (_, inferred, initialization) = initialization_test_module(
    943UL, b"let first = second\nlet second = first + 1\n",
  )
  assert_eq(inferred.diagnostics.length(), 0)
  assert_eq(initialization.diagnostics.length(), 1)
  match initialization.steps[0].kind {
    PlannedCyclicModuleValues(members) => assert_eq(members.length, 2)
    _ => fail("expected runtime cycle")
  }
}

///|
test "module initialization steps retain test-only ownership" {
  let module_id = 945UL
  let collected = collect_program_files(module_id, [
    ProgramFile::named(
      make_program_file_id(module_id, 0),
      "values.dew",
      b"let production = 1\n",
    ),
    ProgramFile::named(
      make_program_file_id(module_id, 1),
      "values_test.dew",
      b"let fixture = production + 1\ntest \"uses fixture\" {\n  assert(fixture == 2, \"wrong fixture\")\n}\n",
    ),
  ])
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let initialization = plan_module_initialization(
    collected,
    inferred.module_values,
  )
  assert_eq(initialization.diagnostics.length(), 0)
  assert_eq(initialization.steps.length(), 2)
  for step in initialization.steps {
    match step.kind {
      PlannedInitializeModuleValue(declaration, _, _) =>
        if declaration == collected.lets[0].declaration {
          assert_false(step.test_only)
        } else {
          assert_eq(declaration, collected.lets[1].declaration)
          assert_true(step.test_only)
        }
      _ => fail("expected initialization value")
    }
  }
}

///|
test "module initialization planning handles 1024 dependencies iteratively" {
  let (collected, _, initialization) = initialization_test_module(
    944UL,
    long_module_value_chain(1024),
  )
  assert_eq(initialization.diagnostics.length(), 0)
  assert_eq(initialization.steps.length(), 1024)
  match initialization.steps[0].kind {
    PlannedInitializeModuleValue(declaration, _, _) =>
      assert_eq(declaration, collected.lets[1023].declaration)
    _ => fail("expected first dependency")
  }
  match initialization.steps[1023].kind {
    PlannedInitializeModuleValue(declaration, _, _) =>
      assert_eq(declaration, collected.lets[0].declaration)
    _ => fail("expected final dependent")
  }
}
