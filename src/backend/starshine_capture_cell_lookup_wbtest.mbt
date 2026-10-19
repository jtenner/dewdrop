///|
fn capture_cell_lookup_stages() -> BackendCompilerTestStages raise {
  let stages = backend_test_single_module_stages(
    28151UL, b"pub fn left(value: I32) -> fn() -> I32 {\n  let mut held = value\n  fn() -> I32 {\n    held = value\n    held\n  }\n}\npub fn right(value: I64) -> fn() -> I64 {\n  let mut held = value\n  fn() -> I64 {\n    held = value\n    held\n  }\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
  assert_eq(
    @validate.validate_module(
      emit_starshine_module(stages.lowering.modules[0], stages.link.modules[0]).unwrap(),
    ),
    Ok(()),
  )
  stages
}

///|
fn capture_cell_lookup_error(
  module_id~ : UInt64 = 28151UL,
) -> Result[@lib.Module, StarshineCodeEmissionError] {
  Err(
    CompilerInvariantFailure({
      code: 504U,
      phase: 7U,
      module_id,
      declaration: 0UL,
      body: 0UL,
      expression: 0xffffffffU,
      expected: 1UL,
      actual: 0UL,
      detail: (82UL << 32) | 1UL,
    }),
  )
}

///|
test "program emission rejects a wrong in-range capture cell lookup" {
  let stages = capture_cell_lookup_stages()
  let cells = stages.link.modules[0].capture_cell_type_indices
  assert_true(cells[0] >= 0 && cells[1] >= 0 && cells[0] != cells[1])
  cells[1] = cells[0]
  assert_eq(
    emit_starshine_program_module(stages.lowering, stages.link),
    capture_cell_lookup_error(),
  )
}

///|
test "module emission rejects a wrong in-range capture cell lookup" {
  let stages = capture_cell_lookup_stages()
  let module_ = stages.link.modules[0]
  module_.capture_cell_type_indices[1] = module_.capture_cell_type_indices[0]
  assert_eq(
    emit_starshine_module(stages.lowering.modules[0], module_),
    capture_cell_lookup_error(),
  )
}

///|
test "all six capture cell families validate in both emission paths" {
  let mut source = "pub struct Boxed {\n  value: I64\n}\n"
  for index, type_ in ["I32", "I64", "F32", "F64", "V128", "Boxed"] {
    source += "pub fn f\{index}(value: \{type_}) -> fn() -> \{type_} {\n  let mut held = value\n  fn() -> \{type_} {\n    held = value\n    held\n  }\n}\n"
  }
  let stages = backend_test_single_module_stages(28152UL, @utf8.encode(source))
  assert_eq(stages.diagnostic_count(), 0)
  let module_ = stages.link.modules[0]
  for index in module_.capture_cell_type_indices {
    assert_true(index >= 0)
  }
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
  assert_eq(
    @validate.validate_module(
      emit_starshine_module(stages.lowering.modules[0], module_).unwrap(),
    ),
    Ok(()),
  )
}

///|
test "selected generic capture cell lookups are checked before emission" {
  let stages = backend_test_single_module_stages(
    28153UL, b"pub fn choose<t>(value: t) -> t {\n  let mut held = value\n  let read = fn() -> t {\n    held = value\n    held\n  }\n  read()\n}\npub fn left(value: I32) -> I32 {\n  choose(value)\n}\npub fn right(value: I64) -> I64 {\n  choose(value)\n}\npub fn erased() -> Unit {\n  choose(())\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
  let cells = stages.link.modules[0].capture_cell_type_indices
  assert_true(cells[0] >= 0 && cells[1] >= 0 && cells[5] >= 0)
  cells[1] = cells[0]
  assert_eq(
    emit_starshine_program_module(stages.lowering, stages.link),
    capture_cell_lookup_error(module_id=28153UL),
  )
}
