///|
test "raw array fields retain their heap without an allocation or call" {
  let stages = backend_test_single_module_stages(
    29315UL, b"open dew.std.wasm.intrinsics\npub struct Buffer {\n  chunks: WasmArray<V128>\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.fixed_array_type_base, 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "raw array heaps precede cross-module recursive struct fields" {
  let program = @semantic.collect_program_manifest(
    29314UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.a", [
        @semantic.ManifestFile::new("a.dew", b"open app.b\nopen dew.std.wasm.intrinsics\npub struct A {\n  peer: B\n  chunks: WasmArray<V128>\n}\npub fn count(value: A) -> U32 {\n  wasm_array_len(value.chunks)\n}\n"),
      ]),
      @semantic.ManifestModule::new("app.b", [
        @semantic.ManifestFile::new("b.dew", b"open app.a\npub struct B {\n  peer: A\n}\n"),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(@semantic.collect_compiler_source_diagnostics(program, analyzed, lowering, link), [])
  assert_true(!link.program_type_groups.is_empty())
  assert_eq(link.fixed_array_type_base, 0)
  assert_true(link.program_type_groups[0].first_type_index >= 8)
  assert_eq(@validate.validate_module(emit_starshine_program_module(lowering, link).unwrap()), Ok(()))
}

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
