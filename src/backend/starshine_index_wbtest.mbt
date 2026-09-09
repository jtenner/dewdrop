///|
test "trait selected index get and set emit valid WasmGC" {
  let module_id = 2601UL
  let stages = backend_test_single_module_stages(
    module_id, b"struct Box {\n  value: I32\n}\nimpl IndexedGet<U32, I32> for Box {\n  fn indexed_get(self, key: U32) -> I32 {\n    self.value\n  }\n}\nimpl IndexedSet<U32, I32> for Box {\n  fn indexed_set(self, key: U32, value: I32) -> Unit {}\n}\npub fn read(box: Box, key: U32) -> I32 {\n  box[key]\n}\npub fn write(box: Box, key: U32, value: I32) -> Unit {\n  box[key] = value\n}\n",
  )
  let collected = stages.program.modules[0]
  let resolved = stages.analyzed.frozen.interfaces[0].resolved_types
  let names = stages.analyzed.modules[0].names
  let inferred = stages.analyzed.modules[0].inferred
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  assert_eq(stages.diagnostic_count(), 0)
  assert_true(stages.emit_binary().length() > 8)
}
