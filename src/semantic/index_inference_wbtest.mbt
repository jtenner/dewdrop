///|
fn index_trait_test_source() -> Bytes {
  b"struct Box {\n  value: I32\n}\nimpl Index<U32, I32> for Box {\n  fn index(self, key: U32) -> I32 {\n    self.value\n  }\n}\nimpl IndexSet<U32, I32> for Box {\n  fn index_set(self, key: U32, value: I32) -> Unit {}\n}\npub fn read(box: Box, key: U32) -> I32 {\n  box[key]\n}\npub fn write(box: Box, key: U32, value: I32) -> Unit {\n  box[key] = value\n}\n"
}

///|
test "index get and set syntax select canonical traits" {
  let collected = collect_program_bytes(2600UL, index_trait_test_source())
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
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
  assert_eq(lowering.diagnostics.length(), 0)
  let mut gets = 0
  let mut sets = 0
  for expression in lowering.expressions {
    match expression.kind {
      PlannedIndexCall(_, _, _, _) => gets += 1
      PlannedIndexSetCall(_, _, _, _, _) => sets += 1
      _ => ()
    }
  }
  assert_eq(gets, 1)
  assert_eq(sets, 1)
}
