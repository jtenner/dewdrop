///|
fn capture_cell_type_test_link() -> PlannedProgramWasmGCLink raise {
  let mut source = "pub struct Boxed {\n  value: I64\n}\n"
  for index, type_ in ["I32", "I64", "F32", "F64", "V128", "Boxed"] {
    source += "pub fn f\{index}(value: \{type_}) -> fn() -> \{type_} {\n  let mut held = value\n  fn() -> \{type_} {\n    held = value\n    held\n  }\n}\n"
  }
  let stages = compiler_test_stages(28150UL, [
    CompilerTestModule::new("app.cells", [
      CompilerTestSource::new("main.dew", @utf8.encode(source)),
    ]),
  ])
  assert_eq(stages.diagnostics(), [])
  assert_eq(verify_program_physical_type_fragments(stages.link), Ok(()))
  for slot in 0..<6 {
    assert_true(stages.link.modules[0].capture_cell_type_indices[slot] >= 0)
  }
  stages.link
}

///|
fn capture_cell_type_test_failure(
  code : Int32,
  expected : UInt64,
  actual : UInt64,
  role : UInt64,
  slot : Int32,
) -> ProgramPhysicalTypeFailure {
  {
    code,
    phase: 5,
    module_id: 28150UL,
    declaration: 0UL,
    body: 0UL,
    expression: 0xffffffffU,
    expected,
    actual,
    detail: (role << 32) | slot.to_uint64(),
  }
}

///|
fn capture_cell_type_test_reject(
  link : PlannedProgramWasmGCLink,
  failure : ProgramPhysicalTypeFailure,
) -> Unit raise {
  assert_eq(verify_module_capture_cell_types(link.modules[0]), Err(failure))
  assert_eq(verify_program_physical_type_fragments(link), Err(failure))
}

///|
test "capture cell families and absent erased cells have valid contracts" {
  let _ = capture_cell_type_test_link()
  for
    source in [
      b"pub fn run() -> I64 {\n  1i64\n}\n", b"pub fn make() -> fn() -> Unit {\n  let mut value = ()\n  fn() -> Unit {\n    value = ()\n    value\n  }\n}\n",
    ] {
    let stages = compiler_test_stages(28150UL, [
      CompilerTestModule::new("app.cells", [
        CompilerTestSource::new("main.dew", source),
      ]),
    ])
    assert_eq(stages.diagnostics(), [])
    assert_eq(stages.link.modules[0].capture_cell_type_indices, [
      -1, -1, -1, -1, -1, -1,
    ])
    assert_eq(verify_program_physical_type_fragments(stages.link), Ok(()))
  }
}

///|
test "capture cell lookup dimensions and bounds are checked before reads" {
  let link = capture_cell_type_test_link()
  let module_ = link.modules[0]
  for count in [0, 5, 7] {
    link.modules[0] = {
      ..module_,
      capture_cell_type_indices: Array::make(count, -1),
    }
    capture_cell_type_test_reject(
      link,
      capture_cell_type_test_failure(103, 6UL, count.to_uint64(), 80UL, 0),
    )
  }
  link.modules[0] = module_
  for index in [-2, module_.physical_types.length()] {
    module_.capture_cell_type_indices[1] = index
    capture_cell_type_test_reject(
      link,
      capture_cell_type_test_failure(
        101,
        module_.physical_types.length().to_uint64(),
        index.reinterpret_as_uint().to_uint64(),
        81UL,
        1,
      ),
    )
  }
}

///|
test "capture cell lookup requires the exact cell kind and carrier" {
  let link = capture_cell_type_test_link()
  let module_ = link.modules[0]
  let index = module_.capture_cell_type_indices[1]
  module_.capture_cell_type_indices[1] = module_.capture_cell_type_indices[0]
  capture_cell_type_test_reject(
    link,
    capture_cell_type_test_failure(504, 1UL, 0UL, 82UL, 1),
  )
  module_.capture_cell_type_indices[1] = index
  let original = module_.physical_types[index]
  for
    (kind, actual) in [
      (PlannedWasmClosureType, 0xffffffffUL),
      (PlannedWasmCaptureCellType(0), 0UL),
      (PlannedWasmCaptureCellType(6), 6UL),
    ] {
    module_.physical_types[index] = { ..original, kind, }
    capture_cell_type_test_reject(
      link,
      capture_cell_type_test_failure(504, 1UL, actual, 82UL, 1),
    )
  }
  module_.physical_types[index] = { ..original, type_index: index + 1, }
  capture_cell_type_test_reject(
    link,
    capture_cell_type_test_failure(
      502,
      index.to_uint64(),
      (index + 1).to_uint64(),
      4UL,
      index,
    ),
  )
}

///|
test "every declared cell retains one exact reverse lookup" {
  let link = capture_cell_type_test_link()
  let module_ = link.modules[0]
  let index = module_.capture_cell_type_indices[1]
  module_.capture_cell_type_indices[1] = -1
  capture_cell_type_test_reject(
    link,
    capture_cell_type_test_failure(
      503,
      index.to_uint64(),
      0xffffffffUL,
      83UL,
      1,
    ),
  )
  let original = module_.physical_types[index]
  module_.physical_types[index] = {
    ..original,
    kind: PlannedWasmCaptureCellType(6),
  }
  capture_cell_type_test_reject(
    link,
    capture_cell_type_test_failure(101, 6UL, 6UL, 88UL, index),
  )
  module_.physical_types[index] = original
  module_.capture_cell_type_indices[1] = index
  let duplicate = module_.physical_types.length()
  module_.physical_types.push({
    ..original,
    type_index: duplicate,
    group_index: module_.type_groups.length(),
  })
  module_.type_groups.push({
    types: { start: duplicate, length: 1, },
    first_type_index: duplicate,
  })
  capture_cell_type_test_reject(
    link,
    capture_cell_type_test_failure(
      504,
      duplicate.to_uint64(),
      index.to_uint64(),
      83UL,
      1,
    ),
  )
}

///|
test "capture cell field spans and counts are checked before field reads" {
  let link = capture_cell_type_test_link()
  let module_ = link.modules[0]
  let index = module_.capture_cell_type_indices[0]
  let original = module_.physical_types[index]
  for start in [-1, module_.fields.length()] {
    let fields = { start, length: 1, }
    module_.physical_types[index] = { ..original, fields, }
    capture_cell_type_test_reject(
      link,
      capture_cell_type_test_failure(
        101,
        module_.fields.length().to_uint64(),
        program_function_span_code(fields),
        6UL,
        index,
      ),
    )
  }
  assert_true(original.fields.start + 2 <= module_.fields.length())
  for length in [0, 2] {
    module_.physical_types[index] = {
      ..original,
      fields: { ..original.fields, length, },
    }
    capture_cell_type_test_reject(
      link,
      capture_cell_type_test_failure(504, 1UL, length.to_uint64(), 84UL, 0),
    )
  }
}

///|
test "capture cell fields keep their position role and mutable flag" {
  let link = capture_cell_type_test_link()
  let module_ = link.modules[0]
  let field_index = module_.physical_types[module_.capture_cell_type_indices[1]].fields.start
  let original = module_.fields[field_index]
  module_.fields[field_index] = { ..original, physical_index: 1, }
  capture_cell_type_test_reject(
    link,
    capture_cell_type_test_failure(504, 0UL, 1UL, 7UL, field_index),
  )
  for
    (role, actual) in [
      (WasmClosureEntryField, 0xffffffffUL),
      (WasmCaptureCellValueField(0), 0UL),
    ] {
    module_.fields[field_index] = { ..original, role, }
    capture_cell_type_test_reject(
      link,
      capture_cell_type_test_failure(504, 1UL, actual, 85UL, 1),
    )
  }
  module_.fields[field_index] = { ..original, mutable_: false, }
  capture_cell_type_test_reject(
    link,
    capture_cell_type_test_failure(504, 1UL, 0UL, 86UL, 1),
  )
}

///|
test "capture cells require exact full-width storage in every family" {
  let link = capture_cell_type_test_link()
  let module_ = link.modules[0]
  for slot in 0..<6 {
    let field_index = module_.physical_types[module_.capture_cell_type_indices[slot]].fields.start
    let original = module_.fields[field_index]
    let other = (slot + 1) % 6
    module_.fields[field_index] = {
      ..original,
      storage: wasmgc_capture_cell_storage(other),
    }
    capture_cell_type_test_reject(
      link,
      capture_cell_type_test_failure(
        504,
        slot.to_uint64(),
        other.to_uint64(),
        87UL,
        slot,
      ),
    )
    module_.fields[field_index] = original
  }
  for
    (slot, storages) in [
      (
        0,
        [
          WasmI8SignedStorage,
          WasmI8UnsignedStorage,
          WasmI16SignedStorage,
          WasmI16UnsignedStorage,
        ],
      ),
      (5, [WasmStringRefStorage, WasmNullableFunctionRefStorage]),
    ] {
    let field_index = module_.physical_types[module_.capture_cell_type_indices[slot]].fields.start
    let original = module_.fields[field_index]
    for storage in storages {
      module_.fields[field_index] = { ..original, storage, }
      capture_cell_type_test_reject(
        link,
        capture_cell_type_test_failure(
          504,
          slot.to_uint64(),
          0xffffffffUL,
          87UL,
          slot,
        ),
      )
    }
    module_.fields[field_index] = original
  }
}

///|
test "selected generic cells and erased exports use the same checked table" {
  let stages = compiler_test_stages(28150UL, [
    CompilerTestModule::new("app.cells", [
      CompilerTestSource::new(
        "main.dew", b"pub fn make<t>(value: t) -> fn() -> t {\n  let mut held = value\n  fn() -> t {\n    held = value\n    held\n  }\n}\npub fn left(value: I32) -> fn() -> I32 {\n  make(value)\n}\npub fn right(value: I64) -> fn() -> I64 {\n  make(value)\n}\npub fn erased() -> fn() -> Unit {\n  make(())\n}\n",
      ),
    ]),
  ])
  assert_eq(stages.diagnostics(), [])
  assert_eq(verify_program_physical_type_fragments(stages.link), Ok(()))
  let cells = stages.link.modules[0].capture_cell_type_indices
  assert_true(cells[0] >= 0 && cells[1] >= 0 && cells[5] >= 0)
  cells[1] = cells[0]
  capture_cell_type_test_reject(
    stages.link,
    capture_cell_type_test_failure(504, 1UL, 0UL, 82UL, 1),
  )
}
