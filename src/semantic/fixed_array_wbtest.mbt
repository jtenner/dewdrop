///|
test "fixed array methods and indexing use ordinary calls after declaration reordering" {
  let source = Buffer()
  let original = @standard_sources.standard_fixed_array_source()
  let mut inserted = false
  for index in 0..<original.length() {
    source.write_byte(original[index])
    if !inserted && original[index] == b'\n' {
      source.write_string_utf8("fn declaration_padding() -> Unit {\n  ()\n}\n")
      inserted = true
    }
  }
  let program = collect_program_manifest_with_standard_sources(
    2612UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.fixed_array\npub fn run() -> I32 {\n  let values = FixedArray::make(3u32, 7i32)\n  values[1u32] = 9i32\n  values[1u32]\n}\npub fn safe(index: U32) -> Option<I32> {\n  let values = FixedArray::make(2u32, 5i32)\n  values.get(index)\n}\n",
        ),
      ]),
    ]),
    StandardLibrarySources::new([
      ManifestFile::new("std/fixed_array.dew", source.to_bytes()),
    ]),
    true,
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(program.diagnostics, [])
  for module_ in program.modules {
    assert_eq(module_.diagnostics, [])
  }
  assert_eq(analyzed.frozen.import_diagnostics, [])
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  let mut calls = 0
  let mut indices = 0
  let mut writes = 0
  for expression in lowering.modules[0].expressions {
    match expression.kind {
      PlannedDirectCall(_, _, _, _) => calls += 1
      PlannedIndexCall(_, _, _, _) => indices += 1
      PlannedIndexSetCall(_, _, _, _, _) => writes += 1
      PlannedFixedArrayMake(_, _, _)
      | PlannedFixedArrayGetUnchecked(_, _, _)
      | PlannedFixedArraySetUnchecked(_, _, _, _) =>
        abort(
          "FixedArray library calls must not become compiler array algorithms",
        )
      _ => ()
    }
  }
  assert_eq(calls, 3)
  assert_eq(indices, 1)
  assert_eq(writes, 1)
}

///|
test "fixed array standard source declares ordinary library methods" {
  let module_id = standard_library_module_id(10)
  let collected = collect_program_files_with_frozen_standard_imports(
    module_id,
    standard_library_program_files(
      module_id,
      "std/fixed_array.dew",
      StandardLibrarySources::new([
        ManifestFile::new(
          "std/fixed_array.dew",
          @standard_sources.standard_fixed_array_source(),
        ),
      ]),
      false,
      true,
    ),
  )
  assert_eq(collected.diagnostics.length(), 0)
  assert_true(collected.lookup_type("FixedArray") is Some(_))
  assert_eq(collected.callables.length(), 11)
}

///|
test "fixed array source calls infer through generic implementations" {
  let program = collect_program_manifest(
    2611UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.fixed_array\npub fn run() -> I32 {\n  let values = FixedArray::make(3u32, 7)\n  values[1u32] = 9\n  values[1u32]\n}\npub fn safe(index: U32) -> Option<I32> {\n  let values = FixedArray::make(2u32, 5)\n  values.get(index)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
}
