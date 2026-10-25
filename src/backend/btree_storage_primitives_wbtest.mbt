///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "B-tree storage primitive carriers emit without erased scalar boxes" {
  for type_ in ["I32", "I64", "F32", "F64", "V128", "String", "Option<I64>", "Option<Option<I64>>"] {
    let source = "open dew.std.wasm.intrinsics\npub fn keep(value: \{type_}) -> \{type_} {\n  let slots = wasm_array_new_default::<\{type_}>(3u32)\n  wasm_array_set(slots, 0u32, value)\n  wasm_array_copy(slots, 1u32, slots, 0u32, 1u32)\n  wasm_array_copy(slots, 0u32, slots, 2u32, 1u32)\n  wasm_array_get(slots, 1u32)\n}\n"
    let stages = backend_test_single_module_stages(28601UL, @utf8.encode(source))
    assert_eq(stages.diagnostic_count(), 0, msg=type_)
    assert_eq(stages.link.imported_function_count, 0, msg=type_)
    for index in stages.link.erased_box_type_indices {
      assert_true(index < 0, msg=type_)
    }
    assert_eq(@validate.validate_module(stages.emit_module()), Ok(()), msg=type_)
  }
}
