///|
test "erased adapter kinds emit valid Wasm with exact linked targets" {
  let stages = backend_test_single_module_stages(
    28203UL, b"struct Item {\n  value: I32\n}\npub fn identity<t>(value: t) -> t {\n  value\n}\nfn return_identity() -> fn(Item) -> Item {\n  identity\n}\npub fn main() -> Unit {}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
  let mut checked = 0
  for function_ in stages.link.functions {
    if function_.kind is @semantic.PlannedWasmErasedAdapterFunction {
      assert_true(function_.erased_adapter_target >= 0)
      let target = stages.link.erased_adapter_target_function(function_).unwrap()
      assert_eq(target.function_index, function_.erased_adapter_target)
      assert_eq(target.declaration, function_.declaration)
      checked += 1
    }
  }
  assert_eq(checked, 1)
}
