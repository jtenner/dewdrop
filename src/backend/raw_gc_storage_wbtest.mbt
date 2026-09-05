///|
test "generic raw array fields erase the heap type, not the element type" {
  let stages = backend_test_single_module_stages(
    29313UL, b"open dew.std.wasm.intrinsics\nstruct Shared<t> {\n  storage: WasmArray<t>\n}\nstruct Concrete {\n  storage: WasmArray<I64>\n}\npub fn shared(value: I64) -> Shared<I64> {\n  Shared::{\n    storage: wasm_array_new(1u32, value)\n  }\n}\npub fn concrete(value: I64) -> Concrete {\n  Concrete::{\n    storage: wasm_array_new(1u32, value)\n  }\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let module_ = stages.program.modules[0]
  let fragments = stages.link.modules[stages.link.module_lookup
    .get(29313UL)
    .unwrap()]
  let shared = starshine_struct_physical_type(
    fragments,
    module_.lookup_type("Shared").unwrap(),
  ).unwrap()
  let concrete = starshine_struct_physical_type(
    fragments,
    module_.lookup_type("Concrete").unwrap(),
  ).unwrap()
  assert_eq(shared.fields.length, 1)
  assert_eq(concrete.fields.length, 1)
  assert_true(
    fragments.fields[shared.fields.start].storage
    is @semantic.WasmNullableEqRefStorage,
  )
  assert_true(
    fragments.fields[concrete.fields.start].storage
    is @semantic.WasmFixedArrayRefStorage(1),
  )
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}
