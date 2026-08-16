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
  assert_eq(semantic_id_local(collected.callables[30].declaration), 36)
  assert_eq(
    semantic_id_local(collected.lookup_value("array_make_raw").unwrap()),
    37,
  )
  assert_eq(
    semantic_id_local(collected.lookup_value("array_reserve_raw").unwrap()),
    38,
  )
  assert_eq(
    semantic_id_local(
      collected.lookup_value("array_shrink_to_fit_raw").unwrap(),
    ),
    39,
  )
  assert_eq(
    semantic_id_local(collected.lookup_value("array_truncate_raw").unwrap()),
    40,
  )
  assert_eq(
    semantic_id_local(collected.lookup_value("array_copy_raw").unwrap()),
    41,
  )
  assert_eq(
    semantic_id_local(collected.lookup_value("array_copy_within_raw").unwrap()),
    42,
  )
  assert_eq(
    semantic_id_local(collected.lookup_value("array_fill_raw").unwrap()),
    43,
  )
  assert_eq(
    semantic_id_local(collected.lookup_value("array_slice_raw").unwrap()),
    44,
  )
  assert_eq(
    semantic_id_local(collected.lookup_value("array_extend_raw").unwrap()),
    45,
  )
}

///|
test "array operations infer and lower through generic implementations" {
  let program = collect_program_manifest(
    2623UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.array\nfn values() -> Array<I32> {\n  Array::new()\n}\npub fn run() -> I32 {\n  let items = values()\n  items.push(1)\n  items.push(2)\n  items[1u32] = 3\n  let iter = items.iter()\n  let popped = match items.pop() {\n    Option::Some(value) => value\n    Option::None => 0\n  }\n  iter.next() + popped\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics.length(), 0)
  let mut saw_new = false
  let mut saw_push = false
  let mut saw_set = false
  let mut saw_iter = false
  let mut saw_next = false
  let mut saw_pop = false
  for expression in lowering.modules[0].expressions {
    match expression.kind {
      PlannedArrayNew(_, _) => saw_new = true
      PlannedArrayPush(_, _, _) => saw_push = true
      PlannedArraySetUnchecked(_, _, _, _) => saw_set = true
      PlannedArrayIter(_, _, _) => saw_iter = true
      PlannedArrayIterNext(_, _) => saw_next = true
      PlannedArrayPop(_, _, _) => saw_pop = true
      _ => ()
    }
  }
  assert_true(saw_new)
  assert_true(saw_push)
  assert_true(saw_set)
  assert_true(saw_iter)
  assert_true(saw_next)
  assert_true(saw_pop)
}
