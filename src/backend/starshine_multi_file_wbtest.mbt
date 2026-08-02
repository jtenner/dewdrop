///|
test "cross file functions emit one valid module" {
  let module_id = 999UL
  let collected = @semantic.collect_program_files(module_id, [
    @semantic.ProgramFile::new(
      @semantic.make_program_file_id(module_id, 0),
      b"fn double(value: I32) -> I32 {\n  value + value\n}\n",
    ),
    @semantic.ProgramFile::new(
      @semantic.make_program_file_id(module_id, 1),
      b"pub fn run(value: I32) -> I32 {\n  double(value)\n}\n",
    ),
  ])
  let resolved = @semantic.resolve_module_types(collected)
  let names = @semantic.resolve_module_names(collected)
  let inferred = @semantic.infer_module_bodies(collected, resolved, names)
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let layouts = @semantic.plan_module_type_layouts(collected, resolved)
  let functions = @semantic.plan_module_functions(collected, resolved)
  let initialization = @semantic.plan_module_initialization(
    collected,
    inferred.module_values,
  )
  let flows = @semantic.analyze_module_flows(collected, resolved, inferred)
  let lowering = @semantic.plan_module_lowering(
    collected, resolved, layouts, initialization, functions, names, inferred, flows,
  )
  let fragments = @semantic.plan_module_wasmgc_fragments(resolved, lowering)
  assert_eq(fragments.defined_function_count, 2)
  match emit_starshine_binary(lowering, fragments) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to emit cross-file module")
  }
}
