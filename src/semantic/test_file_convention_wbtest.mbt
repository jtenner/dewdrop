///|
test "test declarations outside _test.dew are diagnosed" {
  let program = collect_program_manifest(
    967UL,
    ProgramManifest::new([
      ManifestModule::new("app.invalid_tests", [
        ManifestFile::new("main.dew", b"test \"misplaced\" {\n}\n"),
      ]),
    ]),
  )
  assert_eq(program.modules[0].diagnostics.length(), 1)
  match program.modules[0].diagnostics[0] {
    TestDeclarationOutsideTestFile(_, _) => ()
    _ => fail("expected misplaced test declaration diagnostic")
  }
}

///|
test "_test.dew files are test-only like MoonBit test files" {
  let program = collect_program_manifest(
    968UL,
    ProgramManifest::new([
      ManifestModule::new("app.tests", [
        ManifestFile::new("main.dew", b"pub fn run() -> I32 {\n  1\n}\n"),
        ManifestFile::new(
          "helpers_test.dew", b"pub fn test_helper() -> I32 {\n  42\n}\ntest \"helper is available\" {\n  assert(test_helper() == 42i32, \"wrong helper result\")\n}\n",
        ),
      ]),
    ]),
  )
  let collected = program.modules[0]
  assert_eq(collected.test_files.length(), 1)
  assert_true(collected.file_is_test(make_program_file_id(968UL, 1)))
  let resolved = resolve_module_types(collected)
  let functions = plan_module_functions(collected, resolved)
  let mut helper_is_test = false
  for callable in functions.callables {
    if callable.name == b"test_helper" {
      helper_is_test = callable.is_test
    }
  }
  assert_true(helper_is_test)
  let frozen = freeze_module_interface(
    "app.tests", collected, resolved, functions,
  )
  assert_eq(frozen.callables_named("run").length(), 1)
  assert_eq(frozen.callables_named("test_helper").length(), 0)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let layouts = plan_module_type_layouts(collected, resolved)
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
  let mut normal_helper_elided = false
  let mut testing_helper_emitted = false
  for function_ in normal.functions {
    if function_.name == b"test_helper" {
      normal_helper_elided = function_.elided
    }
  }
  for function_ in testing.functions {
    if function_.name == b"test_helper" {
      testing_helper_emitted = !function_.elided
    }
  }
  assert_true(normal_helper_elided)
  assert_true(testing_helper_emitted)
}
