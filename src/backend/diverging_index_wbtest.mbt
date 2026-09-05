///|
test "non-returning index operands do not become call operands" {
  let stages = backend_test_single_module_stages(
    29312UL, b"builtin stop() -> Never = \"unreachable\"\ntrait IndexedGet<k, v> {\n  fn indexed_get(self, key: k) -> v\n}\ntrait IndexedSet<k, v> {\n  fn indexed_set(self, key: k, value: v) -> Unit\n}\nstruct Slot {\n  mut value: I32\n}\nimpl IndexedGet<U32, I32> for Slot {\n  fn indexed_get(self, key: U32) -> I32 {\n    self.value\n  }\n}\nimpl IndexedSet<U32, I32> for Slot {\n  fn indexed_set(self, key: U32, value: I32) -> Unit {\n    self.value = value\n  }\n}\npub fn read(slot: Slot) -> I32 {\n  slot[stop()]\n}\npub fn write(slot: Slot) -> Unit {\n  slot[0u32] = stop()\n}\npub fn write_key(slot: Slot) -> Unit {\n  slot[stop()] = 42i32\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}
