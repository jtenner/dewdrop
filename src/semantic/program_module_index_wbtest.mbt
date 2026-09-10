///|
fn program_module_index_fixture() -> ProgramIndex raise {
  let module_ = syntax_cycle_test_lowering(
    b"pub fn run() -> I32 {\n  42i32\n}\n",
  )
  assert_eq(module_.module_id, 6046UL)
  let index = build_program_index([module_])
  assert_eq(check_program_module_index(index, 6046UL), Ok(Some(0)))
  assert_eq(check_program_module_index_table(index, index.indexed_modules), Ok(()))
  index
}

///|
fn program_module_index_failure(
  code : Int,
  expected : UInt64,
  actual : UInt64,
  detail : UInt64,
) -> ProgramFunctionLookupFailure {
  {
    code,
    phase: 5,
    module_id: 6046UL,
    declaration: 0UL,
    body: 0UL,
    expression: 0xffffffffU,
    expected,
    actual,
    detail,
  }
}

///|
test "program module index preserves missing owners" {
  let index = program_module_index_fixture()
  assert_eq(check_program_module_index(index, 6047UL), Ok(None))
  assert_eq(index.module_index(6047UL), None)
  assert_eq(index.declaration_owner(6047UL << 32), None)
}

///|
test "program module index rejects every invalid selected index" {
  for bad in [-2, -1, 1, 0x7fffffff] {
    let index = program_module_index_fixture()
    index.module_lookup[6046UL] = bad
    assert_eq(
      check_program_module_index(index, 6046UL),
      Err(program_module_index_failure(
        101, 1UL, bad.reinterpret_as_uint().to_uint64(), 0UL,
      )),
    )
  }
}

///|
test "program module index checks stored module identity" {
  let program = collect_program_manifest(
    6046UL,
    ProgramManifest::new([
      ManifestModule::new("app.first", [ManifestFile::new(
        "first.dew", b"pub fn first() -> I32 {\n  1i32\n}\n",
      )]),
      ManifestModule::new("app.second", [ManifestFile::new(
        "second.dew", b"pub fn second() -> I32 {\n  2i32\n}\n",
      )]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_program_lowering(program, analyzed)
  let index = lowering.index
  assert_eq(index.module_index(6046UL), Some(0))
  assert_eq(index.module_index(6047UL), Some(1))
  index.module_lookup[6046UL] = 1
  assert_eq(
    check_program_module_index(index, 6046UL),
    Err(program_module_index_failure(106, 6046UL, 6047UL, 1UL)),
  )
}

///|
test "program module index checks its shared module arena at each read" {
  let index = program_module_index_fixture()
  // Removing the sole stored module is one mutation. A cached ID copy must
  // not let the old table entry authorize a read from the now-empty arena.
  ignore(index.indexed_modules.pop())
  assert_eq(
    check_program_module_index(index, 6046UL),
    Err(program_module_index_failure(101, 0UL, 0UL, 0UL)),
  )
}

///|
test "program module index table requires a total mapping" {
  let index = program_module_index_fixture()
  index.module_lookup[6047UL] = 0
  assert_eq(
    check_program_module_index_table(index, index.indexed_modules),
    Err({
      ..program_module_index_failure(103, 1UL, 2UL, 1UL),
      module_id: 0UL,
    }),
  )
}

///|
test "program module index table checks the current lowering modules" {
  let index = program_module_index_fixture()
  let modules = [ { ..index.indexed_modules[0], module_id: 6047UL, } ]
  assert_eq(
    check_program_module_index_table(index, modules),
    Err({
      ..program_module_index_failure(105, 1UL, 0UL, 0UL),
      module_id: 6047UL,
    }),
  )
}

///|
test "program module index table checks arena lengths" {
  let index = program_module_index_fixture()
  assert_eq(
    check_program_module_index_table(index, []),
    Err({
      ..program_module_index_failure(103, 0UL, 1UL, 0UL),
      module_id: 0UL,
    }),
  )
}
