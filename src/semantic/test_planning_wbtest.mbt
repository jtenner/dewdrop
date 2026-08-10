///|
fn collect_program_test_bytes(
  module_id : ModuleId,
  source : Bytes,
) -> CollectedModule {
  collect_program_files(module_id, [
    ProgramFile::named(
      make_program_file_id(module_id, 0),
      "input_test.dew",
      source,
    ),
  ])
}

///|
test "test exports use manifest ordinals instead of source offsets" {
  let module_id = 970UL
  let collected = collect_program_files(module_id, [
    ProgramFile::named(
      make_program_file_id(module_id, 0),
      "first_test.dew",
      b"// shifting this prefix does not enter the export name\ntest \"first\" {\n}\n",
    ),
    ProgramFile::named(
      make_program_file_id(module_id, 1),
      "second_test.dew",
      b"test \"second\" {\n}\n",
    ),
  ])
  assert_eq(collected.tests.length(), 2)
  for index, test_ in collected.tests {
    match collected.declaration(test_.declaration) {
      Some(TopLevelReference(declaration)) =>
        assert_eq(
          collected.name(declaration.name),
          "__dew_test_" + index.to_string(),
        )
      _ => fail("expected collected test declaration")
    }
  }
  assert_true(collected.tests[0].offset > 0UL)
  assert_eq(collected.diagnostics.length(), 0)
}

///|
test "test identities reject duplicate file and display name pairs" {
  let module_id = 968UL
  let duplicate = collect_program_files(module_id, [
    ProgramFile::named(
      make_program_file_id(module_id, 0),
      "same_test.dew",
      b"test \"same\" {\n}\ntest \"same\" {\n}\n",
    ),
  ])
  assert_eq(duplicate.tests.length(), 2)
  assert_eq(duplicate.diagnostics.length(), 1)
  match duplicate.diagnostics[0] {
    DuplicateTestIdentity(diagnostic) => {
      assert_eq(diagnostic.file, make_program_file_id(module_id, 0))
      assert_eq(diagnostic.display_name, b"same")
      assert_true(diagnostic.first_offset < diagnostic.duplicate_offset)
    }
    _ => fail("expected duplicate test identity diagnostic")
  }

  let distinct_files = collect_program_files(module_id, [
    ProgramFile::named(
      make_program_file_id(module_id, 0),
      "first_test.dew",
      b"test \"same\" {\n}\n",
    ),
    ProgramFile::named(
      make_program_file_id(module_id, 1),
      "second_test.dew",
      b"test \"same\" {\n}\n",
    ),
  ])
  assert_eq(distinct_files.tests.length(), 2)
  assert_eq(distinct_files.diagnostics.length(), 0)
}

///|
test "expected test traps are frozen and unsupported categories are diagnosed" {
  let valid = collect_program_test_bytes(
    967UL, b"test \"expected\" expect_trap \"unreachable\" {\n  unreachable()\n}\n",
  )
  assert_eq(valid.diagnostics.length(), 0)
  assert_eq(valid.tests.length(), 1)
  assert_eq(valid.tests[0].expected_trap, Some(b"unreachable"))

  let invalid = collect_program_test_bytes(
    966UL, b"test \"invalid\" expect_trap \"host-exception\" {\n}\n",
  )
  assert_eq(invalid.diagnostics.length(), 1)
  match invalid.diagnostics[0] {
    InvalidExpectedTestTrap(_, name, _) => assert_eq(name, b"host-exception")
    _ => fail("expected invalid test trap diagnostic")
  }
}

///|
test "ordinary declarations cannot resolve test-only nominal types" {
  let module_id = 962UL
  let denied = collect_program_files(module_id, [
    ProgramFile::new(
      make_program_file_id(module_id, 0),
      b"pub fn production(value: TestOnly) -> TestOnly {\n  value\n}\n",
    ),
    ProgramFile::named(
      make_program_file_id(module_id, 1),
      "type_test.dew",
      b"struct TestOnly {\n  value: I32\n}\n",
    ),
  ])
  let denied_types = resolve_module_types(denied)
  assert_eq(denied_types.diagnostics.length(), 2)
  for diagnostic in denied_types.diagnostics {
    match diagnostic {
      UnknownType(_, _, _) => ()
      _ => fail("expected test-only nominal type to be hidden")
    }
  }

  let allowed = collect_program_files(module_id, [
    ProgramFile::new(
      make_program_file_id(module_id, 0),
      b"pub fn production() -> I32 {\n  0\n}\n",
    ),
    ProgramFile::named(
      make_program_file_id(module_id, 1),
      "type_test.dew",
      b"struct TestOnly {\n  value: I32\n}\nfn identity(value: TestOnly) -> TestOnly {\n  value\n}\n",
    ),
  ])
  let allowed_types = resolve_module_types(allowed)
  assert_eq(allowed_types.diagnostics.length(), 0)
}

///|
test "ordinary bodies cannot resolve test-only values" {
  let module_id = 963UL
  let denied = collect_program_files(module_id, [
    ProgramFile::new(
      make_program_file_id(module_id, 0),
      b"pub fn production() -> I32 {\n  helper()\n}\n",
    ),
    ProgramFile::named(
      make_program_file_id(module_id, 1),
      "value_test.dew",
      b"fn helper() -> I32 {\n  7\n}\n",
    ),
  ])
  let denied_names = resolve_module_names(denied)
  assert_eq(denied_names.diagnostics.length(), 1)
  match denied_names.diagnostics[0] {
    UnknownValueName(_, _, _) => ()
    _ => fail("expected test-only value to be hidden")
  }

  let allowed = collect_program_files(module_id, [
    ProgramFile::new(
      make_program_file_id(module_id, 0),
      b"pub fn production() -> I32 {\n  0\n}\n",
    ),
    ProgramFile::named(
      make_program_file_id(module_id, 1),
      "value_test.dew",
      b"fn helper() -> I32 {\n  7\n}\ntest \"test helper remains visible\" {\n  assert(helper() == 7, \"wrong helper value\")\n}\n",
    ),
  ])
  let allowed_names = resolve_module_names(allowed)
  assert_eq(allowed_names.diagnostics.length(), 0)
}

///|
test "ordinary bodies cannot select test-only impl evidence" {
  let module_id = 964UL
  let denied = collect_program_files(module_id, [
    ProgramFile::new(
      make_program_file_id(module_id, 0),
      b"struct Value {\n  raw: I32\n}\npub fn production(value: Value) -> I32 {\n  value.answer()\n}\n",
    ),
    ProgramFile::named(
      make_program_file_id(module_id, 1),
      "evidence_test.dew",
      b"impl Value {\n  fn answer(self) -> I32 {\n    self.raw\n  }\n}\n",
    ),
  ])
  let denied_types = resolve_module_types(denied)
  let denied_names = resolve_module_names(denied)
  let denied_inference = infer_module_bodies(denied, denied_types, denied_names)
  assert_eq(denied_inference.diagnostics.length(), 1)
  match denied_inference.diagnostics[0] {
    NoMatchingMethod(_, _, _) => ()
    _ => fail("expected test-only impl evidence to be hidden")
  }

  let allowed = collect_program_files(module_id, [
    ProgramFile::new(
      make_program_file_id(module_id, 0),
      b"struct Value {\n  raw: I32\n}\n",
    ),
    ProgramFile::named(
      make_program_file_id(module_id, 1),
      "evidence_test.dew",
      b"impl Value {\n  fn answer(self) -> I32 {\n    self.raw\n  }\n}\ntest \"test impl remains visible in test mode\" {\n  assert(Value {\n    raw: 7\n  }.answer() == 7, \"wrong value\")\n}\n",
    ),
  ])
  let allowed_types = resolve_module_types(allowed)
  let allowed_names = resolve_module_names(allowed)
  let allowed_inference = infer_module_bodies(
    allowed, allowed_types, allowed_names,
  )
  assert_eq(allowed.diagnostics.length(), 0)
  assert_eq(allowed_types.diagnostics.length(), 0)
  assert_eq(allowed_names.diagnostics.length(), 0)
  assert_eq(allowed_inference.diagnostics.length(), 0)
}

///|
test "production physical layouts exclude test-only nominal declarations" {
  let module_id = 965UL
  let collected = collect_program_files(module_id, [
    ProgramFile::new(
      make_program_file_id(module_id, 0),
      b"pub fn run() -> I32 {\n  0\n}\n",
    ),
    ProgramFile::named(
      make_program_file_id(module_id, 1),
      "layout_test.dew",
      b"struct TestOnly {\n  value: I32\n}\ntest \"construct test-only layout\" {\n  let value = TestOnly {\n    value: 1\n  }\n}\n",
    ),
  ])
  let resolved = resolve_module_types(collected)
  let layouts = plan_module_type_layouts(collected, resolved)
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(layouts.layouts.length(), 1)
  assert_true(layouts.layouts[0].test_only)
  assert_eq(
    wasmgc_physical_type_count_with_options(
      layouts,
      WasmGCPlanningOptions::optimized_subtype_families(),
    ),
    0,
  )
  assert_eq(
    wasmgc_physical_type_count_with_options(
      layouts,
      WasmGCPlanningOptions::test_mode(),
    ),
    1,
  )
}

///|
test "test-only helpers are distinct from explicit test entries" {
  let collected = collect_program_test_bytes(
    961UL, b"fn helper() -> Bool {\n  true\n}\ntest \"entry\" {\n  assert(helper(), \"helper failed\")\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let functions = plan_module_functions(collected, resolved)
  let helper = functions
    .callable_of(collected.lookup_value("helper").unwrap())
    .unwrap()
  let entry = functions.callable_of(collected.tests[0].declaration).unwrap()
  assert_true(helper.is_test)
  assert_false(helper.is_test_entry)
  assert_true(entry.is_test)
  assert_true(entry.is_test_entry)
}

///|
test "tests are first-class metadata and emit only in test mode" {
  let collected = collect_program_test_bytes(
    969UL, b"test \"hidden outside test mode\" {\n}\npub fn run() -> Unit {\n}\n",
  )
  assert_eq(collected.tests.length(), 1)
  assert_eq(collected.tests[0].display_name, b"hidden outside test mode")
  match collected.declaration(collected.tests[0].declaration) {
    Some(TopLevelReference(declaration)) =>
      assert_eq(collected.name(declaration.name), "__dew_test_0")
    _ => fail("expected collected test declaration")
  }
  let resolved = resolve_module_types(collected)
  let layouts = plan_module_type_layouts(collected, resolved)
  let functions = plan_module_functions(collected, resolved)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let initialization = plan_module_initialization(
    collected,
    inferred.module_values,
  )
  let flows = analyze_module_flows(collected, resolved, inferred)
  let lowering = plan_module_lowering(
    collected, resolved, layouts, initialization, functions, names, inferred, flows,
  )
  let normal = plan_module_wasmgc_fragments(resolved, lowering)
  let testing = plan_module_wasmgc_fragments_with_options(
    resolved,
    lowering,
    WasmGCPlanningOptions::test_mode(),
  )
  let mut normal_test_elided = false
  let mut testing_test_reachable = false
  for function_ in normal.functions {
    if function_.test_name.length() > 0 {
      normal_test_elided = function_.elided && function_.function_index < 0
      assert_eq(function_.test_name, b"hidden outside test mode")
    }
  }
  for function_ in testing.functions {
    if function_.test_name.length() > 0 {
      testing_test_reachable = !function_.elided &&
        function_.function_index >= 0
      assert_eq(function_.test_name, b"hidden outside test mode")
    }
  }
  assert_true(normal_test_elided)
  assert_true(testing_test_reachable)
}
