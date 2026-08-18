///|
test "nullable foreign references infer and lower without generic calls" {
  let program = collect_program_manifest(
    23100UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.wasm.intrinsics\nforeign type Handle\nforeign impl \"provider\" as Provider {\n  fn take(value: NullableRef<Handle>) -> Unit = \"take\"\n}\nfn null_handle() -> NullableRef<Handle> {\n  wasm_ref_null()\n}\nfn is_null_handle(value: NullableRef<Handle>) -> Bool {\n  wasm_ref_is_null(value)\n}\nfn require_handle(value: NullableRef<Handle>) -> Handle {\n  wasm_ref_as_non_null(value)\n}\nfn widen_handle(value: Handle) -> NullableRef<Handle> {\n  value\n}\nfn pass_handle(value: Handle) -> Unit {\n  Provider.take(value)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let app = program.module_index("app.main").unwrap()
  assert_eq(
    analyzed.frozen.interfaces[app].resolved_types.diagnostics.length(),
    0,
  )
  assert_eq(analyzed.modules[app].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  assert_eq(lowering.modules[app].diagnostics.length(), 0)
  let mut null_count = 0
  let mut is_null_count = 0
  let mut as_non_null_count = 0
  for expression in lowering.modules[app].expressions {
    match expression.kind {
      PlannedWasmRefNull => null_count += 1
      PlannedWasmRefIsNull(_) => is_null_count += 1
      PlannedWasmRefAsNonNull(_) => as_non_null_count += 1
      _ => ()
    }
  }
  assert_eq(null_count, 1)
  assert_eq(is_null_count, 1)
  assert_eq(as_non_null_count, 1)
  let fragments = plan_program_wasmgc_fragments(analyzed, lowering)
  let declaration = program.modules[app].foreign_functions[0].declaration
  let function_ = fragments.modules[app].function_of(declaration).unwrap()
  assert_eq(function_.parameters.length, 1)
  match
    fragments.modules[app].function_value_types[function_.parameters.start] {
    WasmNullableNominalRefValue(index) => assert_true(index >= 0)
    _ => fail("expected exact nullable foreign marker parameter")
  }
  let encoded = serialize_planned_module_wasmgc_fragments(
    fragments.modules[app],
  ).unwrap()
  let decoded = deserialize_planned_module_wasmgc_fragments(encoded).unwrap()
  assert_eq(decoded, fragments.modules[app])
}

///|
test "nullable foreign reference planning codecs preserve exact variants" {
  let writer = @cache_binary.Writer::new()
  pb_write_storage_type(
    writer,
    WasmNullableNominalRefStorage(WasmRecursiveTypeReference(3)),
  )
  pb_write_value_type(writer, WasmNullableNominalRefValue(7))
  let reader = @cache_binary.Reader::new(
    writer.to_bytes(),
    context="nullable reference planning test",
  )
  assert_eq(
    pb_read_storage_type(reader, "storage"),
    WasmNullableNominalRefStorage(WasmRecursiveTypeReference(3)),
  )
  assert_eq(pb_read_value_type(reader, "value"), WasmNullableNominalRefValue(7))
  assert_eq(reader.finish(), Ok(()))
}

///|
test "nullable foreign references survive frozen module interfaces" {
  let program = collect_program_manifest(
    23101UL,
    ProgramManifest::new([
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"open dew.std.wasm.intrinsics\npub foreign type Handle\npub fn missing() -> NullableRef<Handle> {\n  wasm_ref_null()\n}\n",
        ),
      ]),
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.wasm.intrinsics\nopen app.library\nfn run() -> Bool {\n  wasm_ref_is_null(missing())\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let library = program.module_index("app.library").unwrap()
  let app = program.module_index("app.main").unwrap()
  assert_eq(
    analyzed.frozen.interfaces[library].resolved_types.diagnostics.length(),
    0,
  )
  assert_eq(
    analyzed.frozen.interfaces[app].resolved_types.diagnostics.length(),
    0,
  )
  assert_eq(analyzed.modules[library].inferred.diagnostics.length(), 0)
  assert_eq(analyzed.modules[app].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  assert_eq(lowering.modules[library].diagnostics.length(), 0)
  assert_eq(lowering.modules[app].diagnostics.length(), 0)
}

///|
test "NullableRef rejects non-foreign arguments" {
  let program = collect_program_manifest(
    23102UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.wasm.intrinsics\nfn invalid(value: NullableRef<I32>) -> NullableRef<I32> {\n  value\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let app = program.module_index("app.main").unwrap()
  let mut invalid_count = 0
  for diagnostic in analyzed.frozen.interfaces[app].resolved_types.diagnostics {
    match diagnostic {
      NullableRefRequiresForeignType(_, _, _) => invalid_count += 1
      _ => ()
    }
  }
  assert_eq(invalid_count, 2)
}

///|
test "NullableRef rejects nested nullable references" {
  let program = collect_program_manifest(
    23103UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.wasm.intrinsics\nforeign type Handle\nfn invalid(value: NullableRef<NullableRef<Handle>>) -> Unit {\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let app = program.module_index("app.main").unwrap()
  let mut invalid_count = 0
  for diagnostic in analyzed.frozen.interfaces[app].resolved_types.diagnostics {
    match diagnostic {
      NullableRefRequiresForeignType(_, _, _) => invalid_count += 1
      _ => ()
    }
  }
  assert_eq(invalid_count, 1)
}

///|
test "NullableRef rejects source-level construction and patterns" {
  let program = collect_program_manifest(
    23104UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.wasm.intrinsics\nforeign type Handle\nfn fake() -> NullableRef<Handle> {\n  NullableRef::{}\n}\nfn inspect(value: NullableRef<Handle>) -> Bool {\n  value is NullableRef {}\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let app = program.module_index("app.main").unwrap()
  let mut construction_count = 0
  let mut pattern_count = 0
  for diagnostic in analyzed.modules[app].inferred.diagnostics {
    match diagnostic {
      InvalidConstructionTarget(_, _) => construction_count += 1
      InvalidPatternConstructor(_, _) => pattern_count += 1
      _ => ()
    }
  }
  assert_eq(construction_count, 1)
  assert_eq(pattern_count, 1)
}
