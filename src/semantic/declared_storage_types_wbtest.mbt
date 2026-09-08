///|
fn declared_storage_fixture() -> PlannedModuleLowering raise {
  syntax_cycle_test_lowering(
    b"struct Box<t> {\n  value: t\n}\nstruct Cell {\n  scalar: I32\n  nested: Box<I64>\n  callback: fn(I32) -> I64\n  pair: (I32, I64)\n}\npub fn run() -> I32 {\n  42\n}\n",
  )
}

///|
fn declared_storage_check(
  module_ : PlannedModuleLowering,
  field : PlannedFieldLayout,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  check_declared_storage_type(
    module_.module_id,
    module_.resolved_types,
    module_.resolved_type_arguments,
    field.field,
    field.type_,
  )
}

///|
fn declared_storage_expected(
  module_ : PlannedModuleLowering,
  field : PlannedFieldLayout,
  code : Int,
  expected : UInt64,
  actual : UInt64,
  bad : Int,
) -> ProgramPhysicalTypeFailure {
  {
    code,
    phase: 4,
    module_id: module_.module_id,
    declaration: field.field,
    body: 0UL,
    expression: 0xffffffffU,
    expected,
    actual,
    detail: (field.type_.to_uint64() << 32) |
    bad.reinterpret_as_uint().to_uint64(),
  }
}

///|
test "declared storage checks the complete field type graph" {
  let module_ = declared_storage_fixture()
  for field in module_.type_layouts.fields {
    assert_eq(declared_storage_check(module_, field), Ok(()))
  }
}

///|
test "declared storage rejects errors before erasing reference graphs" {
  for index in [1, 2, 3, 4] {
    let module_ = declared_storage_fixture()
    let field = module_.type_layouts.fields[index]
    assert_eq(declared_storage_check(module_, field), Ok(()))
    let bad = match module_.resolved_types[field.type_] {
      AppliedType(_, arguments) =>
        module_.resolved_type_arguments[arguments.start]
      ProductType(arguments) =>
        module_.resolved_type_arguments[arguments.start + 1]
      FunctionType(_, result) => result
      _ => field.type_
    }
    module_.resolved_types[bad] = ErrorType
    assert_eq(
      declared_storage_check(module_, field),
      Err(declared_storage_expected(module_, field, 301, 0UL, 1UL, bad)),
    )
  }
}

///|
test "declared storage rejects unresolved projections and runtime type values" {
  for kind in [0, 1] {
    let module_ = declared_storage_fixture()
    let field = module_.type_layouts.fields[1]
    assert_eq(declared_storage_check(module_, field), Ok(()))
    module_.resolved_types[field.type_] = if kind == 0 {
      MemberTypeProjection(field.type_, b"types.field_type", "value")
    } else {
      PrimitiveType(CompileTimeTypeType)
    }
    assert_eq(
      declared_storage_check(module_, field),
      Err(
        declared_storage_expected(
          module_,
          field,
          301,
          0UL,
          (kind + 2).to_uint64(),
          field.type_,
        ),
      ),
    )
  }
}

///|
test "declared storage distinguishes type cycles from errors" {
  let module_ = declared_storage_fixture()
  let field = module_.type_layouts.fields[1]
  assert_eq(declared_storage_check(module_, field), Ok(()))
  module_.resolved_types[field.type_] = AppliedType(field.type_, {
    start: 0,
    length: 0,
  })
  assert_eq(
    declared_storage_check(module_, field),
    Err(declared_storage_expected(module_, field, 108, 0UL, 1UL, field.type_)),
  )
}

///|
test "declared storage checks type and child arenas before lookup" {
  let module_ = declared_storage_fixture()
  let field = module_.type_layouts.fields[1]
  assert_eq(declared_storage_check(module_, field), Ok(()))
  let missing = module_.resolved_types.length()
  module_.resolved_types[field.type_] = AppliedType(missing, {
    start: 0,
    length: 0,
  })
  assert_eq(
    declared_storage_check(module_, field),
    Err(
      declared_storage_expected(
        module_,
        field,
        101,
        missing.to_uint64(),
        missing.to_uint64(),
        missing,
      ),
    ),
  )
  let length = module_.resolved_type_arguments.length() + 1
  module_.resolved_types[field.type_] = ProductType({ start: 0, length, })
  assert_eq(
    declared_storage_check(module_, field),
    Err(
      declared_storage_expected(
        module_,
        field,
        101,
        (length - 1).to_uint64(),
        length.to_uint64(),
        field.type_,
      ),
    ),
  )
}
