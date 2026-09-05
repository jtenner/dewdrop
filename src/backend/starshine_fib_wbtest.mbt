///|
fn backend_fib_source() -> Bytes {
  b"pub fn fib(value: I32) -> I32 {\n  if value <= 1 {\n    value\n  } else {\n    fib(value - 1) + fib(value - 2)\n  }\n}\n"
}

///|
fn backend_fib_pipeline() -> (
  @semantic.PlannedModuleLowering,
  @semantic.PlannedModuleWasmGCFragments,
) {
  let collected = @semantic.collect_program_bytes(994UL, backend_fib_source())
  let resolved = @semantic.resolve_module_types(collected)
  let names = @semantic.resolve_module_names(collected)
  let inferred = @semantic.infer_module_bodies(collected, resolved, names)
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
  (lowering, fragments)
}

///|
test "trait based Fibonacci emits a valid complete Starshine module" {
  let (lowering, fragments) = backend_fib_pipeline()
  assert_eq(fragments.imported_function_count, 0)
  assert_eq(fragments.defined_function_count, 1)
  let mut found_add = false
  let mut found_sub = false
  let mut found_lte = false
  for function_ in fragments.functions {
    if function_.direct_builtin.length() > 0 {
      assert_true(function_.elided)
      if function_.direct_builtin == b"i32.add" {
        found_add = true
      } else if function_.direct_builtin == b"i32.sub" {
        found_sub = true
      } else if function_.direct_builtin == b"i32.le_s" {
        found_lte = true
      }
    }
  }
  assert_true(found_add)
  assert_true(found_sub)
  assert_true(found_lte)
  let module_ = match emit_starshine_module(lowering, fragments) {
    Ok(module_) => module_
    Err(_) => fail("failed to emit Fibonacci module")
  }
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_binary(lowering, fragments) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to validate and encode Fibonacci module")
  }
}
