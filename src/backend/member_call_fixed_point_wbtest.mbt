///|
test "member and operator inference reaches a shared fixed point" {
  let stages = backend_test_single_module_stages(
    29310UL, b"struct Slot<t> {\n  item: t\n}\nimpl<t> IndexedGet<U32, t> for Slot<t> {\n  fn indexed_get(self, index: U32) -> t {\n    self.item\n  }\n}\nstruct Cell {\n  value: I32\n}\nimpl Cell {\n  fn read(self) -> I32 {\n    self.value\n  }\n}\nstruct Wrapper {\n  inner: Cell\n}\npub fn check(value: Slot<Cell>) -> Bool {\n  value[0u32].value == 3i32\n}\npub fn read(value: Slot<Wrapper>) -> I32 {\n  value[0u32].inner.read()\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}
