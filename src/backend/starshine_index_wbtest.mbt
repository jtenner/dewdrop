///|
test "trait selected index get and set emit valid WasmGC" {
  let module_id = 2601UL
  let collected = @semantic.collect_program_bytes(
    module_id, b"struct Box {\n  value: I32\n}\nimpl IndexedGet<U32, I32> for Box {\n  fn indexed_get(self, key: U32) -> I32 {\n    self.value\n  }\n}\nimpl IndexedSet<U32, I32> for Box {\n  fn indexed_set(self, key: U32, value: I32) -> Unit {}\n}\npub fn read(box: Box, key: U32) -> I32 {\n  box[key]\n}\npub fn write(box: Box, key: U32, value: I32) -> Unit {\n  box[key] = value\n}\n",
  )
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
  assert_eq(lowering.diagnostics.length(), 0)
  let fragments = @semantic.plan_module_wasmgc_fragments(resolved, lowering)
  match emit_starshine_binary(lowering, fragments) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to emit trait-selected index syntax")
  }
}
