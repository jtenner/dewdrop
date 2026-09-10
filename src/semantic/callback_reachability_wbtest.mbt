///|
test "callback bodies keep private function targets reachable" {
  let program = compiler_test_single_module_program(
    6048UL, b"fn leaf(value: I32) -> I32 {\n  value + 1\n}\npub fn maker(value: I32) -> fn() -> I32 {\n  fn() -> I32 {\n    leaf(value)\n  }\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  let module_ = lowering.modules[0]
  // Model a library whose private helpers are retained only by actual uses.
  for index, callable in module_.functions.callables {
    module_.functions.callables[index] = { ..callable, compiler_owned: true, }
  }
  let leaf = 6048UL << 32
  let roots = program_reachable_callable_roots(analyzed, lowering, false, {})
  assert_true(roots.contains(leaf))
  let local = wasmgc_reachable_defined_functions(
    module_,
    module_.functions,
    false,
    {},
  )
  assert_true(local[module_.functions.callable_by_declaration[0]])
}
