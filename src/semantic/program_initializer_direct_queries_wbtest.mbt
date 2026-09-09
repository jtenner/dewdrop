///|
test "startup direct query removes a dead self dependency before initialization planning" {
  let program = compiler_test_single_module_program(
    24915UL, b"builtin is_unit<t>() -> Bool = \"types.is_unit\"\nlet answer = if is_unit::<I32>() {\n  answer\n} else {\n  42i64\n}\npub fn main() -> I64 {\n  answer\n}\n",
  )
  let analyzed = compiler_test_analyze(program)
  let source_dependencies = analyzed.modules[0].inferred.module_values.dependencies
  assert_eq(source_dependencies.dependency_declarations, [(24915UL << 32) | 1UL])
  let lowering = compiler_test_lower(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics, [])
  assert_eq(lowering.modules[0].initialization.diagnostics, [])
  assert_eq(
    lowering.modules[0].initialization.dependencies.dependency_declarations,
    [],
  )
  assert_eq(source_dependencies.dependency_declarations, [(24915UL << 32) | 1UL])
  let link = compiler_test_link(analyzed, lowering)
  assert_eq(link.diagnostics, [])
  assert_eq(link.initializers.length(), 1)
}

///|
test "startup direct query preserves a selected self dependency" {
  let program = compiler_test_single_module_program(
    24915UL, b"builtin is_unit<t>() -> Bool = \"types.is_unit\"\nlet answer = if is_unit::<Unit>() {\n  answer\n} else {\n  42i64\n}\npub fn main() -> I64 {\n  answer\n}\n",
  )
  let analyzed = compiler_test_analyze(program)
  let lowering = compiler_test_lower(program, analyzed)
  let initialization = lowering.modules[0].initialization
  assert_eq(initialization.dependencies.dependency_declarations, [
    (24915UL << 32) | 1UL,
  ])
  assert_eq(initialization.diagnostics.length(), 1)
  match initialization.diagnostics[0] {
    EagerModuleInitializationCycle(_, _) => ()
    _ => fail("selected self dependency must remain a cycle diagnostic")
  }
}
