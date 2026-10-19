///|
fn common_closure_backend_stages() -> BackendCompilerTestStages raise {
  let stages = backend_test_single_module_stages(
    28161UL, b"pub struct Boxed {\n  value: I64\n}\npub fn keep(value: Boxed) -> Boxed {\n  value\n}\npub fn make(value: I64) -> fn() -> I64 {\n  fn() -> I64 {\n    value\n  }\n}\n",
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
fn common_closure_backend_error(
  code : UInt32,
  expected : UInt64,
  actual : UInt64,
  role : UInt64,
  slot : Int32,
  module_id~ : UInt64 = 28161UL,
) -> StarshineCodeEmissionError {
  CompilerInvariantFailure({
    code,
    phase: 7U,
    module_id,
    declaration: 0UL,
    body: 0UL,
    expression: 0xffffffffU,
    expected,
    actual,
    detail: (role << 32) | slot.reinterpret_as_uint().to_uint64(),
  })
}

///|
fn common_closure_backend_reject(
  stages : BackendCompilerTestStages,
  error : StarshineCodeEmissionError,
) -> Unit raise {
  let lowering = stages.lowering.modules[0]
  let module_ = stages.link.modules[0]
  assert_eq(
    emit_starshine_program_module(stages.lowering, stages.link),
    Err(error),
  )
  assert_eq(emit_starshine_module(lowering, module_), Err(error))
  assert_eq(emit_starshine_code_section(lowering, module_), Err(error))
}

///|
test "program and module emission reject a wrong in-range common closure target" {
  let stages = common_closure_backend_stages()
  let module_ = stages.link.modules[0]
  let index = module_.closure_type_index
  let wrong = module_.type_index_of(28161UL << 32).unwrap()
  assert_true(wrong >= 0 && wrong != index)
  module_.physical_types[index] = module_.physical_types[wrong]
  common_closure_backend_reject(
    stages,
    common_closure_backend_error(504U, 1UL, 0UL, 91UL, index),
  )
}

///|
test "all emission gates check common closure bounds before physical reads" {
  let stages = common_closure_backend_stages()
  let module_ = stages.link.modules[0]
  let index = module_.closure_type_index
  while module_.physical_types.length() > index {
    let _ = module_.physical_types.pop()
  }
  common_closure_backend_reject(
    stages,
    common_closure_backend_error(
      101U,
      index.to_uint64(),
      index.to_uint64(),
      90UL,
      0,
    ),
  )
}

///|
test "all emission gates check the common closure stored type index" {
  let stages = common_closure_backend_stages()
  let module_ = stages.link.modules[0]
  let index = module_.closure_type_index
  let donor = backend_test_single_module_stages(
    28164UL, b"pub struct First {\n  value: I64\n}\npub struct Second {\n  value: I64\n}\npub fn keep(first: First, second: Second) -> I64 {\n  first.value + second.value\n}\npub fn make(value: I64) -> fn() -> I64 {\n  fn() -> I64 {\n    value\n  }\n}\n",
  )
  assert_eq(donor.diagnostic_count(), 0)
  let donor_module = donor.link.modules[0]
  let donor_index = donor_module.closure_type_index
  assert_true(donor_index >= 0 && donor_index != index)
  module_.physical_types[index] = donor_module.physical_types[donor_index]
  common_closure_backend_reject(
    stages,
    common_closure_backend_error(
      502U,
      index.to_uint64(),
      donor_index.to_uint64(),
      92UL,
      index,
    ),
  )
}

///|
test "all emission gates check common closure entry position and identity" {
  let stages = common_closure_backend_stages()
  let module_ = stages.link.modules[0]
  let index = module_.closure_type_index
  let entry_slot = module_.physical_types[index].fields.start
  let struct_type = module_.type_index_of(28161UL << 32).unwrap()
  let struct_field = module_.fields[module_.physical_types[struct_type].fields.start]
  module_.fields[entry_slot] = struct_field
  common_closure_backend_reject(
    stages,
    common_closure_backend_error(504U, 1UL, 0UL, 96UL, entry_slot),
  )
  let lambda_type = module_.physical_types[module_.lambda_closure_type_indices[0]]
  assert_true(lambda_type.fields.length > 1)
  module_.fields[entry_slot] = module_.fields[lambda_type.fields.start + 1]
  common_closure_backend_reject(
    stages,
    common_closure_backend_error(504U, 0UL, 1UL, 95UL, entry_slot),
  )
}

///|
test "all emission gates reject a duplicate common closure type" {
  let stages = common_closure_backend_stages()
  let module_ = stages.link.modules[0]
  let index = module_.closure_type_index
  let duplicate = module_.physical_types.length()
  module_.physical_types.push(module_.physical_types[index])
  common_closure_backend_reject(
    stages,
    common_closure_backend_error(
      504U,
      duplicate.to_uint64(),
      index.to_uint64(),
      99UL,
      duplicate,
    ),
  )
}

///|
test "selected generic common closure contracts validate before program emission" {
  let stages = backend_test_single_module_stages(
    28162UL, b"pub fn make<t>(value: t) -> fn() -> t {\n  fn() -> t {\n    value\n  }\n}\npub fn read() -> I64 {\n  let callback = make(42i64)\n  callback()\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let emitted = match
    emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => module_
    Err(error) => fail(@debug.to_string(error))
  }
  assert_eq(@validate.validate_module(emitted), Ok(()))
  let module_ = stages.link.modules[0]
  let index = module_.closure_type_index
  assert_true(index >= 0)
  let duplicate = module_.physical_types.length()
  module_.physical_types.push(module_.physical_types[index])
  assert_eq(
    emit_starshine_program_module(stages.lowering, stages.link),
    Err(
      common_closure_backend_error(
        504U,
        duplicate.to_uint64(),
        index.to_uint64(),
        99UL,
        duplicate,
        module_id=28162UL,
      ),
    ),
  )
}

///|
test "module and program emission accept an absent common closure type" {
  let stages = backend_test_single_module_stages(
    28163UL, b"pub fn read() -> I64 {\n  42i64\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.modules[0].closure_type_index, -1)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
  assert_eq(
    @validate.validate_module(
      emit_starshine_module(stages.lowering.modules[0], stages.link.modules[0]).unwrap(),
    ),
    Ok(()),
  )
}
