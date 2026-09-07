///|
test "foreign host imports cannot use the static-link namespace prefix" {
  let collected = collect_bytes(9752UL, b"foreign import \"link:provider\" as Host {\n  fn call() -> Unit = \"call\"\n}\n")
  assert_eq(collected.diagnostics.length(), 1)
  assert_true(collected.diagnostics[0] is ReservedForeignHostNamespace(_, _))
}

///|
test "foreign namespace calls infer without a receiver value" {
  let collected = collect_bytes(
    9751UL, b"foreign type StarshineModule\nforeign impl \"starshine\" as Starshine {\n  fn module_new() -> StarshineModule = \"module_new\"\n}\npub fn make() -> StarshineModule {\n  Starshine.module_new()\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)
  match inferred.call_targets[2] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, collected.foreign_functions[0].declaration)
      assert_eq(arguments.length, 0)
    }
    _ => fail("expected direct foreign-library call")
  }
  let layouts = plan_module_type_layouts(collected, resolved)
  let functions = plan_module_functions(collected, resolved)
  let initialization = plan_module_initialization(
    collected,
    inferred.module_values,
  )
  let flows = analyze_module_flows(collected, resolved, inferred)
  let lowering = plan_module_lowering(
    collected, resolved, layouts, initialization, functions, names, inferred, flows,
  )
  match lowering.expressions[2].kind {
    PlannedDirectCall(declaration, -1, arguments, _) => {
      assert_eq(declaration, collected.foreign_functions[0].declaration)
      assert_eq(arguments.length, 0)
    }
    _ => fail("expected receiver-free lowering")
  }
}
