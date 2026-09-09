///|
fn index_trait_test_source() -> Bytes {
  b"struct Box {\n  value: I32\n}\nimpl IndexedGet<U32, I32> for Box {\n  fn indexed_get(self, key: U32) -> I32 {\n    self.value\n  }\n}\nimpl IndexedSet<U32, I32> for Box {\n  fn indexed_set(self, key: U32, value: I32) -> Unit {}\n}\npub fn read(box: Box, key: U32) -> I32 {\n  box[key]\n}\npub fn write(box: Box, key: U32, value: I32) -> Unit {\n  box[key] = value\n}\n"
}

///|
test "index get and set syntax select canonical traits" {
  let program = compiler_test_single_module_program(
    2600UL,
    index_trait_test_source(),
  )
  let collected = program.modules[0]
  let analyzed = analyze_program_semantics(program)
  let resolved = analyzed.frozen.interfaces[0].resolved_types
  let names = analyzed.modules[0].names
  let inferred = analyzed.modules[0].inferred
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let lowering = plan_unoptimized_program_lowering(program, analyzed).modules[0]
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
