///|
test "mutable source and capture cell carriers must agree at emission" {
  for
    source in [
      b"pub fn run() -> I64 {\n  let mut value = 1i64\n  let next = fn() -> I64 {\n    value = 2i64\n    value\n  }\n  next()\n}\n",
      b"pub fn make() -> fn() -> I64 {\n  fn() -> I64 {\n    let mut value = 1i64\n    let next = fn() -> I64 {\n      value = 2i64\n      value\n    }\n    next()\n  }\n}\n",
      b"let next = if true {\n  let mut value = 1i64\n  fn() -> I64 {\n    value = 2i64\n    value\n  }\n} else {\n  fn() -> I64 {\n    0i64\n  }\n}\npub fn run() -> I64 {\n  next()\n}\n",
    ] {
    let stages = backend_test_single_module_stages(28140UL, source)
    assert_eq(stages.diagnostic_count(), 0)
    assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
    let module_ = stages.lowering.modules[0]
    let captures = module_.captures.filter(capture => capture.mutable_)
    assert_eq(captures.length(), 1)
    let capture = captures[0]
    let (body, local_id) = match capture.source {
      @semantic.BodyLocalCapture(owner, id) =>
        (module_.bodies[@semantic.semantic_id_local(owner)], id)
      @semantic.LambdaLocalCapture(owner, id) =>
        (module_.lambda_body(owner).unwrap(), id)
    }
    let index = body.locals.start + local_id
    let local_ = module_.locals[index]
    module_.locals[index] = local_.with_shape(@semantic.planned_i32_shape())
    assert_eq(
      emit_starshine_program_module(stages.lowering, stages.link),
      Err(
        CompilerInvariantFailure({
          code: 302U,
          phase: 7U,
          module_id: 28140UL,
          declaration: body.declaration,
          body: body.body,
          expression: 0xffffffffU,
          expected: 0UL,
          actual: 1UL,
          detail: (2UL << 32) |
          module_.lambdas[capture.lambda].captures.start.to_uint64(),
        }),
      ),
    )
  }
}

///|
fn capture_agreement_fixture(
  type_ : String,
  value : String,
) -> BackendCompilerTestStages raise {
  let stages = backend_test_single_module_stages(
    28141UL,
    @utf8.encode(
      "pub fn run() -> \{type_} {\n  let mut value = \{value}\n  let first = fn() -> \{type_} {\n    value = \{value}\n    value\n  }\n  let second = fn() -> \{type_} {\n    value = \{value}\n    value\n  }\n  let _ = first()\n  second()\n}\n",
    ),
  )
  assert_eq(
    stages.diagnostic_count(),
    0,
    msg=@debug.to_string(
      @semantic.collect_compiler_source_diagnostics(
        stages.program,
        stages.analyzed,
        stages.lowering,
        stages.link,
      ),
    ),
  )
  stages
}

///|
fn capture_agreement_failure(
  module_ : @semantic.PlannedModuleLowering,
  index : Int32,
  expected : UInt64,
  actual : UInt64,
) -> Result[@lib.Module, StarshineCodeEmissionError] {
  let capture = module_.captures[index]
  let body = match capture.source {
    @semantic.BodyLocalCapture(owner, _) =>
      module_.bodies[@semantic.semantic_id_local(owner)]
    @semantic.LambdaLocalCapture(owner, _) =>
      module_.lambda_body(owner).unwrap()
  }
  Err(
    CompilerInvariantFailure({
      code: 302U,
      phase: 7U,
      module_id: module_.module_id,
      declaration: body.declaration,
      body: body.body,
      expression: 0xffffffffU,
      expected,
      actual,
      detail: (2UL << 32) | index.to_uint64(),
    }),
  )
}

///|
test "every mutable capture checks its carrier including erased captures" {
  for
    (type_, value, slot) in [("I32", "1i32", 0UL), ("Unit", "()", 0xffffffffUL)] {
    let other = capture_agreement_fixture(type_, value)
    assert_eq(other.diagnostic_count(), 0)
    assert_eq(other.lowering.modules[0].captures.length(), 2)
    assert_eq(@validate.validate_module(other.emit_module()), Ok(()))
    let shape = other.lowering.modules[0].captures[0].shape
    let stages = capture_agreement_fixture("I64", "1i64")
    assert_eq(stages.diagnostic_count(), 0)
    assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
    let module_ = stages.lowering.modules[0]
    assert_eq(module_.captures.length(), 2)
    assert_eq(module_.captures[0].source, module_.captures[1].source)
    // Only the second alias is damaged; the first remains valid.
    module_.captures[1] = module_.captures[1].with_shape(shape)
    assert_eq(
      emit_starshine_program_module(stages.lowering, stages.link),
      capture_agreement_failure(module_, 1, 1UL, slot),
    )
    // Also check the opposite erased/physical direction.
    if type_ == "Unit" {
      let erased = other.lowering.modules[0]
      erased.captures[1] = erased.captures[1].with_shape(
        module_.captures[0].shape,
      )
      assert_eq(
        emit_starshine_program_module(other.lowering, other.link),
        capture_agreement_failure(erased, 1, slot, 1UL),
      )
    }
  }
}

///|
test "selected and forwarded mutable captures retain their source carrier" {
  for
    source in [
      b"fn select<t>(first: t, second: t) -> t {\n  let mut value = first\n  let next = fn() -> t {\n    value = second\n    value\n  }\n  next()\n}\npub fn run() -> I64 {\n  select(1i64, 2i64)\n}\n",
      b"pub fn make() -> fn() -> fn() -> I64 {\n  let mut value = 1i64\n  fn() -> fn() -> I64 {\n    fn() -> I64 {\n      value = 2i64\n      value\n    }\n  }\n}\n",
    ] {
    let stages = backend_test_single_module_stages(28142UL, source)
    assert_eq(stages.diagnostic_count(), 0)
    assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
    let module_ = match stages.program.modules[0].lookup_value("select") {
      Some(owner) => {
        let selected = stages.link.functions.filter(function_ => {
          function_.declaration == owner && !function_.elided
        })
        assert_eq(selected.length(), 1)
        @semantic.program_function_lowering(
          stages.lowering,
          selected[0].module_index,
          selected[0].specialization_abi_key,
        )
      }
      None => stages.lowering.modules[0]
    }
    let mutable = module_.captures.filter(capture => capture.mutable_)
    assert_true(mutable.length() > 0)
    if stages.program.modules[0].lookup_value("select") is None {
      assert_eq(mutable.length(), 2)
      let outer = module_.lambdas[mutable[0].lambda]
      let inner = mutable[1].lambda
      let mut nested = false
      for
        index in outer.expressions.start..<(outer.expressions.start +
        outer.expressions.length) {
        if module_.expressions[index].kind
          is @semantic.PlannedLambdaClosure(id, _) &&
          id == inner {
          nested = true
        }
      }
      assert_true(nested)
    }
    // For forwarding, damage the inner capture after the outer capture passes.
    let capture = mutable[mutable.length() - 1]
    let index = module_.lambdas[capture.lambda].captures.start + capture.capture
    module_.captures[index] = capture.with_shape(@semantic.planned_i32_shape())
    assert_eq(
      emit_starshine_program_module(stages.lowering, stages.link),
      capture_agreement_failure(module_, index, 1UL, 0UL),
    )
  }
}

///|
test "different shapes can share the same capture cell" {
  for
    (type_, value, shape) in [
      ("I8", "1i8", @semantic.planned_i32_shape()),
      ("(I64, I32)", "(1i64, 2i32)", @semantic.planned_reference_shape()),
    ] {
    let stages = capture_agreement_fixture(type_, value)
    assert_eq(stages.diagnostic_count(), 0)
    assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
    let module_ = stages.lowering.modules[0]
    for index, capture in module_.captures {
      module_.captures[index] = capture.with_shape(shape)
    }
    assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
  }
}

///|
test "mutable captures require a mutable physical source cell" {
  let stages = capture_agreement_fixture("I64", "1i64")
  let immutable = backend_test_single_module_stages(
    28141UL, b"pub fn run() -> I64 {\n  let value = 1i64\n  let next = fn() -> I64 {\n    value\n  }\n  next()\n}\n",
  )
  assert_eq(immutable.diagnostic_count(), 0)
  assert_eq(@validate.validate_module(immutable.emit_module()), Ok(()))
  let source = immutable.lowering.modules[0].locals[0]
  let module_ = stages.lowering.modules[0]
  let local_ = module_.locals[0]
  assert_eq(source.body, local_.body)
  assert_eq(source.lambda, local_.lambda)
  assert_eq(source.local_id, local_.local_id)
  assert_eq(source.shape, local_.shape)
  assert_true(local_.mutable_ && !source.mutable_)
  module_.locals[0] = source
  assert_eq(
    emit_starshine_program_module(stages.lowering, stages.link),
    capture_agreement_failure(module_, 0, 0xffffffffUL, 1UL),
  )
}

///|
test "a capture cannot copy the value of a source that needs a cell" {
  let stages = capture_agreement_fixture("I64", "1i64")
  let immutable = backend_test_single_module_stages(
    28141UL, b"pub fn run() -> I64 {\n  let value = 1i64\n  let next = fn() -> I64 {\n    value\n  }\n  next()\n}\n",
  )
  assert_eq(immutable.diagnostic_count(), 0)
  assert_eq(@validate.validate_module(immutable.emit_module()), Ok(()))
  let capture = immutable.lowering.modules[0].captures[0]
  let module_ = stages.lowering.modules[0]
  assert_eq(capture.lambda, module_.captures[0].lambda)
  assert_eq(capture.capture, module_.captures[0].capture)
  assert_eq(capture.source, module_.captures[0].source)
  assert_eq(capture.shape, module_.captures[0].shape)
  assert_true(!capture.mutable_ && module_.captures[1].mutable_)
  // The second capture keeps the source in a shared mutable cell.
  module_.captures[0] = capture
  assert_eq(
    emit_starshine_program_module(stages.lowering, stages.link),
    capture_agreement_failure(module_, 0, 1UL, 0xffffffffUL),
  )
}
