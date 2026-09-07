///|
test "manifest ordered files share one module namespace" {
  let module_id = 997UL
  let first_file = make_program_file_id(module_id, 0)
  let second_file = make_program_file_id(module_id, 1)
  let collected = collect_program_files(module_id, [
    ProgramFile::new(
      first_file, b"fn double(value: I32) -> I32 {\n  value + value\n}\n",
    ),
    ProgramFile::new(
      second_file, b"pub fn run(value: I32) -> I32 {\n  double(value)\n}\n",
    ),
  ])
  let preamble_file_count = collected.files.length() - 2
  assert_eq(preamble_file_count, 12)
  for index in 0..<preamble_file_count {
    assert_eq(collected.files[index], make_file_id(module_id, index))
  }
  assert_eq(collected.files[preamble_file_count], first_file)
  assert_eq(collected.files[preamble_file_count + 1], second_file)
  assert_eq(collected.preamble_declaration_count, 1334)
  assert_eq(collected.diagnostics.length(), 0)
  let double = collected.lookup_value("double").unwrap()
  let run = collected.lookup_value("run").unwrap()
  assert_eq(semantic_id_local(double), collected.preamble_declaration_count)
  assert_eq(semantic_id_local(run), collected.preamble_declaration_count + 1)
  assert_eq(
    collected.declaration_location(double),
    Some({ file: first_file, offset: 0UL, }),
  )
  assert_eq(
    collected.declaration_location(run),
    Some({ file: second_file, offset: 0UL, }),
  )
  let double_body = collected.body_of(double).unwrap()
  let run_body = collected.body_of(run).unwrap()
  assert_eq(
    collected.body_location(double_body.id),
    Some({ file: first_file, offset: 0UL, }),
  )
  assert_eq(
    collected.body_location(run_body.id),
    Some({ file: second_file, offset: 0UL, }),
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
}

///|
test "cross file duplicate diagnostics retain both FileIds" {
  let module_id = 998UL
  let first_file = make_program_file_id(module_id, 0)
  let second_file = make_program_file_id(module_id, 1)
  let collected = collect_program_files(module_id, [
    ProgramFile::new(first_file, b"fn same() -> I32 {\n  1\n}\n"),
    ProgramFile::new(second_file, b"fn same() -> I32 {\n  2\n}\n"),
  ])
  assert_eq(collected.diagnostics.length(), 1)
  match collected.diagnostics[0] {
    DuplicateName(diagnostic) => {
      assert_eq(diagnostic.first_file, first_file)
      assert_eq(diagnostic.duplicate_file, second_file)
      assert_eq(diagnostic.first_offset, 3UL)
      assert_eq(diagnostic.duplicate_offset, 3UL)
    }
    _ => fail("expected duplicate-name diagnostic")
  }
}
