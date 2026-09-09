///|
fn initializer_source_test_module() -> PlannedModuleLowering raise {
  let stages = compiler_test_stages(24912UL, [
    CompilerTestModule::new("app.initializers", [
      CompilerTestSource::new("main.dew", b"pub let answer = 42i64\n"),
    ]),
  ])
  let module_ = stages.lowering.modules[0]
  assert_eq(module_.diagnostics, [])
  assert_eq(module_.bodies.length(), 1)
  assert_eq(module_.bodies[0].body, 24912UL << 32)
  assert_eq(module_.bodies[0].declaration, 24912UL << 32)
  module_
}

///|
fn initializer_source_test_failure(
  code : Int,
  expected : UInt64,
  actual : UInt64,
  detail : UInt64,
) -> ProgramFunctionLookupFailure {
  {
    code,
    phase: 5,
    module_id: 24912UL,
    declaration: 24912UL << 32,
    body: 24912UL << 32,
    expression: 0xffffffffU,
    expected,
    actual,
    detail,
  }
}

///|
test "initializer source bodies are checked before indexed access" {
  let module_ = initializer_source_test_module()
  let source = module_.bodies[0]
  assert_eq(
    check_program_initializer_source(module_, source.declaration, source.body),
    Ok(source),
  )
  module_.bodies.clear()
  assert_eq(
    check_program_initializer_source(module_, source.declaration, source.body),
    Err(initializer_source_test_failure(101, 0UL, 0UL, 2UL)),
  )
}

///|
test "initializer body lookups reject another module" {
  let module_ = initializer_source_test_module()
  let source = module_.bodies[0]
  let body = 24913UL << 32
  assert_eq(
    check_program_initializer_source(module_, source.declaration, body),
    Err({ ..initializer_source_test_failure(107, 24912UL, 24913UL, 1UL), body, }),
  )
}

///|
test "initializer declaration lookups reject another module" {
  let module_ = initializer_source_test_module()
  let source = module_.bodies[0]
  let declaration = 24913UL << 32
  assert_eq(
    check_program_initializer_source(module_, declaration, source.body),
    Err({
      ..initializer_source_test_failure(107, 24912UL, 24913UL, 0UL),
      declaration,
    }),
  )
}

///|
test "initializer records retain their stored body identity" {
  let module_ = initializer_source_test_module()
  let source = module_.bodies[0]
  module_.bodies[0] = { ..source, body: source.body + 1UL, }
  assert_eq(
    check_program_initializer_source(module_, source.declaration, source.body),
    Err(
      initializer_source_test_failure(106, source.body, source.body + 1UL, 3UL),
    ),
  )
}

///|
test "initializer records retain their source declaration" {
  let module_ = initializer_source_test_module()
  let source = module_.bodies[0]
  module_.bodies[0] = { ..source, declaration: source.declaration + 1UL, }
  assert_eq(
    check_program_initializer_source(module_, source.declaration, source.body),
    Err(
      initializer_source_test_failure(
        106,
        source.declaration,
        source.declaration + 1UL,
        4UL,
      ),
    ),
  )
}

///|
test "initializer shapes reject generic and error product leaves" {
  let module_ = initializer_source_test_module()
  let source = module_.bodies[0]
  for
    item in [
      (GenericPlannedValueShape, 1UL),
      (ErrorPlannedValueShape, 2UL),
      (
        ProductPlannedValueShape([
          I64PlannedValueShape,
          GenericPlannedValueShape,
        ]),
        1UL,
      ),
      (
        ProductPlannedValueShape([I64PlannedValueShape, ErrorPlannedValueShape]),
        2UL,
      ),
    ] {
    let (shape, actual) = item
    module_.bodies[0] = { ..source, root_shape: shape, }
    assert_eq(
      check_program_initializer_source(module_, source.declaration, source.body),
      Err(initializer_source_test_failure(301, 0UL, actual, 5UL)),
    )
  }
}

///|
test "initializer source records cannot select a function body" {
  let module_ = initializer_source_test_module()
  let source = module_.bodies[0]
  module_.bodies[0] = { ..source, kind: FunctionBody, }
  assert_eq(
    check_program_initializer_source(module_, source.declaration, source.body),
    Err(initializer_source_test_failure(106, 0UL, 1UL, 6UL)),
  )
}

///|
test "initializer source indices reject both arena boundaries" {
  let module_ = initializer_source_test_module()
  let declaration = module_.bodies[0].declaration
  for local in [1UL, 0xffffffffUL] {
    let body = (24912UL << 32) | local
    assert_eq(
      check_program_initializer_source(module_, declaration, body),
      Err({ ..initializer_source_test_failure(101, 1UL, local, 2UL), body, }),
    )
  }
}

///|
test "initializer roots belong to their declared expression span" {
  let module_ = initializer_source_test_module()
  let source = module_.bodies[0]
  module_.bodies[0] = { ..source, root: ExpressionBodyRoot(99), }
  assert_eq(
    check_program_initializer_source(module_, source.declaration, source.body),
    Err({
      ..initializer_source_test_failure(102, 0UL, 99UL, (1UL << 32) | 1UL),
      expression: 99U,
    }),
  )
}

///|
test "initializer expression spans are checked before constant classification" {
  let module_ = initializer_source_test_module()
  let source = module_.bodies[0]
  module_.bodies[0] = {
    ..source,
    expressions: { ..source.expressions, start: -1, },
  }
  assert_eq(
    check_program_initializer_source(module_, source.declaration, source.body),
    Err(
      initializer_source_test_failure(101, 1UL, 1UL, (1UL << 32) | 0xffffffffUL),
    ),
  )
}

///|
test "initializer source checks preserve Unit body execution without storage" {
  let stages = compiler_test_stages(24912UL, [
    CompilerTestModule::new("app.initializers", [
      CompilerTestSource::new("main.dew", b"pub let answer = ()\n"),
    ]),
  ])
  let module_ = stages.lowering.modules[0]
  let source = module_.bodies[0]
  assert_eq(source.root_shape, UnitPlannedValueShape)
  assert_eq(stages.link.initializers.length(), 1)
  assert_eq(stages.link.initializers[0].global_index, -1)
  assert_eq(
    check_program_initializer_source(module_, source.declaration, source.body),
    Ok(source),
  )
}
