///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "B-tree standard plans use normal imported module semantics" {
  let source = b"open dew.std.collections.btree\nopen dew.std.ordering\npub fn capacities() -> U32 {\n  let plan = btree_plan::<U64, U64, NaturalComparator>(natural_comparator(), btree_default_config())\n  plan.leaf_capacity() + plan.branch_capacity()\n}\n"
  let stages = backend_test_single_module_stages(28602UL, source)
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.imported_function_count, 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "B-tree custom provider evidence uses normal imported trait semantics" {
  let source = b"open dew.std.collections.btree\nopen dew.std.ordering\nstruct Custom {}\nimpl Comparator<U64> for Custom {\n  fn compare(self, left: U64, right: U64) -> Ordering {\n    natural_comparator().compare(left, right)\n  }\n}\nimpl InlineKey<U64> for Custom {\n  fn inline_key_at(self, key: U64, offset: U32) -> U64 {\n    0u64\n  }\n  fn inline_width(self) -> BTreeInlineWidth {\n    BTreeInlineWidth::Eight\n  }\n}\npub fn capacities() -> U32 {\n  let plan = btree_plan::<U64, Unit, Custom>(Custom::{}, btree_default_config())\n  plan.leaf_capacity() + plan.branch_capacity()\n}\n"
  let stages = backend_test_single_module_stages(28603UL, source)
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.imported_function_count, 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}
