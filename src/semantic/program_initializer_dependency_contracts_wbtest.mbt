///|
fn startup_dependency_fixture() -> (
  PlannedProgramLowering,
  Array[PlannedProgramModuleInitializer],
  Map[DeclId, Int],
) raise {
  let stages = compiler_test_stages(24913UL, [
    CompilerTestModule::new("app.initializers", [
      CompilerTestSource::new(
        "main.dew", b"let base = 40i64\nfn read() -> I64 {\n  base + 2i64\n}\npub let answer = read()\n",
      ),
    ]),
  ])
  assert_eq(stages.link.diagnostics, [])
  assert_eq(stages.link.initializers.length(), 2)
  assert_eq(stages.lowering.modules[0].bodies.length(), 3)
  let candidates = stages.link.initializers
  assert_eq(candidates[0].declaration, 24913UL << 32)
  assert_eq(candidates[1].declaration, (24913UL << 32) | 2UL)
  let lookup : Map[DeclId, Int] = {}
  for index, candidate in candidates {
    lookup[candidate.declaration] = index
  }
  (stages.lowering, candidates, lookup)
}

///|
test "startup dependencies follow a called body to a source global" {
  let (lowering, candidates, lookup) = startup_dependency_fixture()
  assert_eq(
    check_program_initializer_dependencies(
      lowering,
      candidates[1],
      lookup,
      candidates,
    ),
    Ok([0]),
  )
}

///|
test "startup dependencies reject a missing called body instead of losing its edges" {
  let (lowering, candidates, lookup) = startup_dependency_fixture()
  let functions = lowering.modules[0].functions
  let callable_index = functions.callable_by_declaration[1]
  let original = functions.callables[callable_index]
  let missing = (24913UL << 32) | 99UL
  functions.callables[callable_index] = {
    ..original,
    kind: PlannedFunctionCallable(missing),
  }
  assert_eq(
    check_program_initializer_dependencies(
      lowering,
      candidates[1],
      lookup,
      candidates,
    ),
    Err({
      code: 101,
      phase: 5,
      module_id: 24913UL,
      declaration: (24913UL << 32) | 1UL,
      body: missing,
      expression: 0xffffffffU,
      expected: 3UL,
      actual: 99UL,
      detail: 2UL,
    }),
  )
}

///|
fn startup_call_failure(
  code : Int,
  expected : UInt64,
  actual : UInt64,
) -> ProgramFunctionLookupFailure {
  {
    code,
    phase: 5,
    module_id: 24913UL,
    declaration: (24913UL << 32) | 2UL,
    body: (24913UL << 32) | 2UL,
    expression: 5U,
    expected,
    actual,
    detail: (24913UL << 32) | 1UL,
  }
}

///|
fn startup_global_failure(
  code : Int,
  expected : UInt64,
  actual : UInt64,
) -> ProgramFunctionLookupFailure {
  {
    code,
    phase: 5,
    module_id: 24913UL,
    declaration: (24913UL << 32) | 1UL,
    body: (24913UL << 32) | 1UL,
    expression: 1U,
    expected,
    actual,
    detail: 24913UL << 32,
  }
}

///|
test "startup dependencies check the initial module index" {
  let (lowering, candidates, lookup) = startup_dependency_fixture()
  let changed = { ..candidates[1], module_index: -1, }
  assert_eq(
    check_program_initializer_dependencies(
      lowering, changed, lookup, candidates,
    ),
    Err({
      ..startup_call_failure(
        101,
        lowering.modules.length().to_uint64(),
        0xffffffffUL,
      ),
      expression: 0xffffffffU,
      detail: 20UL,
    }),
  )
}

///|
test "startup dependencies reject a missing callee module" {
  let (lowering, candidates, lookup) = startup_dependency_fixture()
  let _ = lowering.index.module_lookup.remove(24913UL)
  assert_eq(
    check_program_initializer_dependencies(
      lowering,
      candidates[1],
      lookup,
      candidates,
    ),
    Err(startup_call_failure(607, 1UL, 0UL)),
  )
}

///|
test "startup dependencies check the callee module map before access" {
  let (lowering, candidates, lookup) = startup_dependency_fixture()
  lowering.index.module_lookup[24913UL] = 99
  assert_eq(
    check_program_initializer_dependencies(
      lowering,
      candidates[1],
      lookup,
      candidates,
    ),
    Err(startup_call_failure(101, lowering.modules.length().to_uint64(), 99UL)),
  )
}

///|
test "startup dependencies check callable table bounds and absence" {
  for index in [-1, -2, 99] {
    let (lowering, candidates, lookup) = startup_dependency_fixture()
    lowering.modules[0].functions.callable_by_declaration[1] = index
    let expected = if index == -1 {
      startup_call_failure(607, 1UL, 0UL)
    } else {
      startup_call_failure(101, 1UL, index.reinterpret_as_uint().to_uint64())
    }
    assert_eq(
      check_program_initializer_dependencies(
        lowering,
        candidates[1],
        lookup,
        candidates,
      ),
      Err(expected),
    )
  }
}

///|
test "startup dependencies verify the selected callable identity" {
  let (lowering, candidates, lookup) = startup_dependency_fixture()
  let functions = lowering.modules[0].functions
  let index = functions.callable_by_declaration[1]
  let original = functions.callables[index]
  functions.callables[index] = {
    ..original,
    declaration: original.declaration + 1UL,
  }
  assert_eq(
    check_program_initializer_dependencies(
      lowering,
      candidates[1],
      lookup,
      candidates,
    ),
    Err(
      startup_call_failure(
        106,
        original.declaration,
        original.declaration + 1UL,
      ),
    ),
  )
}

///|
test "startup dependencies retain missing global lookup failures" {
  let (lowering, candidates, lookup) = startup_dependency_fixture()
  let _ = lookup.remove(candidates[0].declaration)
  assert_eq(
    check_program_initializer_dependencies(
      lowering,
      candidates[1],
      lookup,
      candidates,
    ),
    Err(startup_global_failure(504, 1UL, 0UL)),
  )
}

///|
test "startup dependencies check global lookup bounds" {
  let (lowering, candidates, lookup) = startup_dependency_fixture()
  lookup[candidates[0].declaration] = 99
  assert_eq(
    check_program_initializer_dependencies(
      lowering,
      candidates[1],
      lookup,
      candidates,
    ),
    Err(startup_global_failure(101, 2UL, 99UL)),
  )
}

///|
test "startup dependencies cannot select another global candidate" {
  let (lowering, candidates, lookup) = startup_dependency_fixture()
  lookup[candidates[0].declaration] = 1
  assert_eq(
    check_program_initializer_dependencies(
      lowering,
      candidates[1],
      lookup,
      candidates,
    ),
    Err(
      startup_global_failure(
        106,
        candidates[0].declaration,
        candidates[1].declaration,
      ),
    ),
  )
}

///|
test "startup dependencies check called body expression spans" {
  let (lowering, candidates, lookup) = startup_dependency_fixture()
  let module_ = lowering.modules[0]
  let source = module_.bodies[1]
  assert_eq(module_.expressions.length(), 6)
  assert_eq(source.expressions.length, 3)
  module_.bodies[1] = {
    ..source,
    expressions: { ..source.expressions, start: -1, },
  }
  assert_eq(
    check_program_initializer_dependencies(
      lowering,
      candidates[1],
      lookup,
      candidates,
    ),
    Err({
      ..startup_global_failure(101, 6UL, 3UL),
      expression: 0xffffffffU,
      detail: (1UL << 32) | 0xffffffffUL,
    }),
  )
}

///|
test "startup dependencies retain the expected called body kind" {
  let (lowering, candidates, lookup) = startup_dependency_fixture()
  let source = lowering.modules[0].bodies[1]
  lowering.modules[0].bodies[1] = { ..source, kind: ModuleLetBody, }
  assert_eq(
    check_program_initializer_dependencies(
      lowering,
      candidates[1],
      lookup,
      candidates,
    ),
    Err({
      ..startup_global_failure(106, 1UL, 0UL),
      expression: 0xffffffffU,
      detail: 22UL,
    }),
  )
}

///|
test "startup dependencies terminate recursive calls and keep unique global edges" {
  let stages = compiler_test_stages(24913UL, [
    CompilerTestModule::new("app.initializers", [
      CompilerTestSource::new(
        "main.dew", b"let base = 40i64\nfn read(flag: Bool) -> I64 {\n  if flag {\n    read(false)\n  } else {\n    base + base - 38i64\n  }\n}\npub let answer = read(true)\n",
      ),
    ]),
  ])
  assert_eq(stages.link.diagnostics, [])
  let candidates = stages.link.initializers
  let lookup : Map[DeclId, Int] = {}
  for index, candidate in candidates {
    lookup[candidate.declaration] = index
  }
  assert_eq(
    check_program_initializer_dependencies(
      stages.lowering,
      candidates[1],
      lookup,
      candidates,
    ),
    Ok([0]),
  )
}

///|
test "startup dependencies cannot overwrite duplicate initializer keys" {
  let (_, candidates, _) = startup_dependency_fixture()
  candidates.push(candidates[0])
  match check_program_initializer_candidate_lookup(candidates) {
    Ok(_) => fail("duplicate initializer key was accepted")
    Err(error) =>
      assert_eq(error, {
        code: 504,
        phase: 5,
        module_id: 24913UL,
        declaration: 24913UL << 32,
        body: 24913UL << 32,
        expression: 0xffffffffU,
        expected: 1UL,
        actual: 2UL,
        detail: (16UL << 32) | 2UL,
      })
  }
}

///|
test "startup dependencies follow exact bodies across modules" {
  let stages = compiler_test_stages(24913UL, [
    CompilerTestModule::new("app.main", [
      CompilerTestSource::new(
        "main.dew", b"open app.library\npub let answer = read()\n",
      ),
    ]),
    CompilerTestModule::new("app.library", [
      CompilerTestSource::new(
        "library.dew", b"let base = 40i64\npub fn read() -> I64 {\n  base + 2i64\n}\n",
      ),
    ]),
  ])
  assert_eq(stages.link.diagnostics, [])
  let candidates = stages.link.initializers
  assert_eq(candidates.length(), 2)
  assert_eq(candidates[0].declaration, 24914UL << 32)
  assert_eq(candidates[1].declaration, 24913UL << 32)
  let lookup : Map[DeclId, Int] = {}
  for index, candidate in candidates {
    lookup[candidate.declaration] = index
  }
  assert_eq(
    check_program_initializer_dependencies(
      stages.lowering,
      candidates[1],
      lookup,
      candidates,
    ),
    Ok([0]),
  )
}
