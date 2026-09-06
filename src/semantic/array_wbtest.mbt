///|
test "array module type layouts use declared fields rather than an ordinal recipe" {
  let (resolved, lowering) = wasmgc_test_inputs(
    standard_library_module_id(13),
    b"struct DeclaredStorage {\n  first: I64\n  mut second: I32\n}\n",
  )
  let planned = plan_module_wasmgc_fragments(resolved, lowering)
  assert_eq(planned.physical_types.length(), 1)
  let span = planned.physical_types[0].fields
  assert_eq(span.length, 2)
  assert_eq(planned.fields[span.start].storage, WasmI64Storage)
  assert_eq(planned.fields[span.start].mutable_, false)
  assert_eq(planned.fields[span.start + 1].storage, WasmI32Storage)
  assert_eq(planned.fields[span.start + 1].mutable_, true)
  for index in 0..<span.length {
    assert_eq(
      planned.fields[span.start + index].role,
      WasmStructField(lowering.type_layouts.fields[index].field),
    )
  }
}

///|
test "array size accessors lower to ordinary library calls" {
  let program = collect_program_manifest(
    2631UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.array\npub fn run(value: Array<I64>) -> U32 {\n  array_length(value) + array_capacity(value) + value.length() + value.capacity()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  let mut calls = 0
  for expression in lowering.modules[0].expressions {
    match expression.kind {
      PlannedDirectCall(_, _, _, _) => calls += 1
      _ => ()
    }
  }
  assert_eq(calls, 4)
}

///|
test "array standard source has stable compiler-owned identities" {
  let module_id = standard_library_module_id(13)
  let collected = collect_program_files_with_frozen_standard_imports(
    module_id,
    standard_library_program_files(
      module_id,
      "std/array.dew",
      StandardLibrarySources::new([
        ManifestFile::new(
          "std/array.dew",
          @standard_sources.standard_array_source(),
        ),
      ]),
      false,
      false,
    ),
  )
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(semantic_id_local(collected.lookup_type("Array").unwrap()), 0)
  assert_eq(semantic_id_local(collected.lookup_type("ArrayIter").unwrap()), 1)
  assert_eq(semantic_id_local(collected.lookup_value("array_new").unwrap()), 2)
  assert_eq(collected.callables.length(), 146)
  assert_eq(semantic_id_local(collected.callables[0].declaration), 2)
  assert_eq(semantic_id_local(collected.callables[13].declaration), 15)
  assert_eq(semantic_id_local(collected.callables[14].declaration), 17)
  assert_eq(semantic_id_local(collected.callables[28].declaration), 33)
  assert_eq(semantic_id_local(collected.callables[29].declaration), 35)
  assert_eq(
    semantic_id_local(collected.lookup_value("array_make_raw").unwrap()),
    36,
  )
  assert_eq(
    semantic_id_local(collected.lookup_value("array_reserve_raw").unwrap()),
    37,
  )
  assert_eq(
    semantic_id_local(
      collected.lookup_value("array_shrink_to_fit_raw").unwrap(),
    ),
    38,
  )
  assert_eq(
    semantic_id_local(collected.lookup_value("array_truncate_raw").unwrap()),
    39,
  )
  assert_eq(
    semantic_id_local(collected.lookup_value("array_copy_raw").unwrap()),
    40,
  )
  assert_eq(
    semantic_id_local(collected.lookup_value("array_copy_within_raw").unwrap()),
    41,
  )
  assert_eq(
    semantic_id_local(collected.lookup_value("array_fill_raw").unwrap()),
    42,
  )
  assert_eq(
    semantic_id_local(collected.lookup_value("array_slice_raw").unwrap()),
    43,
  )
  assert_eq(
    semantic_id_local(collected.lookup_value("array_extend_raw").unwrap()),
    44,
  )
}

///|
test "array operations infer and lower through generic implementations" {
  let program = collect_program_manifest(
    2623UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.array\nfn values() -> Array<I32> {\n  Array::new()\n}\npub fn run() -> I32 {\n  let items = values()\n  items.push(1)\n  items.push(2)\n  items[1u32] = 3\n  let iter = items.iter()\n  let popped = match items.pop() {\n    Option::Some(value) => value\n    Option::None => 0\n  }\n  let current = match iter.next() {\n    Option::Some(value) => value\n    Option::None => 0\n  }\n  current + popped\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics.length(), 0)
  let mut calls = 0
  let mut indexed_writes = 0
  for module in lowering.modules {
    for expression in module.expressions {
      match expression.kind {
        PlannedDirectCall(_, _, _, _) => calls += 1
        PlannedIndexSetCall(_, _, _, _, _) => indexed_writes += 1
        _ => ()
      }
    }
  }
  assert_true(calls >= 6)
  assert_true(indexed_writes >= 1)
}
