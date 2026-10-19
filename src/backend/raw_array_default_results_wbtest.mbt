///|
test "raw default product reads demand only their scalar unbox heaps" {
  for (type_, slots) in [
    ("(I32, I64)", [0, 1]),
    ("(F32, (F64, V128))", [2, 3, 4]),
    ("(Unit, Unit)", []),
  ] {
    let stages = backend_test_single_module_stages(
      28125UL,
      @utf8.encode(
        "open dew.std.wasm.intrinsics\npub fn main() -> I32 {\n let _ = wasm_array_get(wasm_array_new_default::<\{type_}>(1u32), 0u32)\n 42i32\n}\n",
      ),
    )
    assert_eq(stages.diagnostic_count(), 0, msg=type_)
    for slot in 0..<5 {
      assert_eq(
        stages.link.erased_box_type_indices[slot] >= 0,
        slots.contains(slot),
        msg=type_,
      )
    }
    assert_eq(@validate.validate_module(stages.emit_module()), Ok(()), msg=type_)
  }
}

///|
test "raw nullable default reads retain an exact nullable local heap" {
  let stages = backend_test_single_module_stages(
    28126UL, b"open dew.std.wasm.intrinsics\nforeign type Handle\npub fn main() -> I32 {\n let value = wasm_array_get(wasm_array_new_default::<NullableRef<Handle>>(1u32), 0u32)\n if wasm_ref_is_null(value) {\n 42i32\n } else {\n 0i32\n }\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let module_ = stages.emit_module()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "raw nullable default reads keep exact imported foreign heaps" {
  let program = @semantic.collect_program_manifest(
    28127UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.wasm.intrinsics\nopen handles\npub fn main() -> I32 {\n let value = wasm_array_get(wasm_array_new_default::<NullableRef<Handle>>(1u32), 0u32)\n if wasm_ref_is_null(value) {\n 42i32\n } else {\n 0i32\n }\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("handles", [
        @semantic.ManifestFile::new("handles.dew", b"pub foreign type Handle\n"),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(
    @semantic.collect_compiler_source_diagnostics(program, analyzed, lowering, link),
    [],
  )
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}
