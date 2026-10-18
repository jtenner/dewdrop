///|
fn capture_cell_bad_shapes() -> Array[(@semantic.PlannedValueShape, UInt64)] raise {
  let collected = @semantic.collect_bytes(
    28132UL, b"fn generic<t>(value: t) -> Unit {\n}\nfn error(value: Missing) -> Unit {\n}\nfn generic_product<t>(value: (I64, t)) -> Unit {\n}\n",
  )
  assert_eq(collected.diagnostics, [])
  let resolved = @semantic.resolve_module_types(collected)
  assert_eq(resolved.diagnostics.length(), 1)
  let functions = @semantic.plan_module_functions(collected, resolved)
  assert_eq(functions.callables.length(), 3)
  let shapes = functions.callables.map(fn(callable) {
    functions.parameters[callable.parameters.start].shape
  })
  assert_true(shapes[0] is @semantic.GenericPlannedValueShape)
  assert_true(shapes[1] is @semantic.ErrorPlannedValueShape)
  assert_true(shapes[2] is @semantic.ProductPlannedValueShape(_))
  let type_ = functions.parameters[functions.callables[2].parameters.start].type_
  let fields = match resolved.types[type_] {
    @semantic.ProductType(fields) => fields
    _ => fail("expected a resolved product")
  }
  let generic_field = resolved.type_arguments[fields.start + 1]
  resolved.type_arguments[fields.start + 1] = resolved.error_type
  let error_product = @semantic.planned_value_shape_from_resolved_types(
    resolved.types,
    resolved.type_arguments,
    type_,
  )
  assert_true(error_product is @semantic.ProductPlannedValueShape(_))
  resolved.type_arguments[fields.start] = resolved.error_type
  resolved.type_arguments[fields.start + 1] = generic_field
  let mixed_product = @semantic.planned_value_shape_from_resolved_types(
    resolved.types,
    resolved.type_arguments,
    type_,
  )
  [
    (shapes[0], 1UL),
    (shapes[1], 2UL),
    (shapes[2], 1UL),
    (error_product, 2UL),
    (mixed_product, 2UL),
  ]
}

///|
test "mutable capture sources reject invalid shapes before cell storage" {
  for
    source in [
      b"pub fn run() -> I64 {\n  let mut seed = 1i64\n  let callback = fn() -> I64 {\n    seed = seed + 1i64\n    seed\n  }\n  callback()\n}\n",
      b"struct Marker {\n  value: I32\n}\npub fn make() -> fn() -> I64 {\n  let prefix = 1i32\n  let mut seed = 1i64\n  fn() -> I64 {\n    seed = seed + 1i64\n    seed\n  }\n}\n",
      b"pub fn make() -> fn() -> I64 {\n  fn() -> I64 {\n    let mut seed = 1i64\n    let callback = fn() -> I64 {\n      seed = seed + 1i64\n      seed\n    }\n    callback()\n  }\n}\n",
      b"let callback = if true {\n  let mut seed = 1i64\n  fn() -> I64 {\n    seed = seed + 1i64\n    seed\n  }\n} else {\n  fn() -> I64 {\n    0i64\n  }\n}\npub fn run() -> I64 {\n  callback()\n}\n",
      b"fn select<t>(first: t, second: t) -> t {\n  let mut seed = first\n  let callback = fn() -> t {\n    seed = second\n    seed\n  }\n  callback()\n}\npub fn run() -> I64 {\n  select(1i64, 42i64)\n}\n",
    ] {
    let stages = backend_test_single_module_stages(28131UL, source)
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
        ) +
        @utf8.decode_lossy(source),
    )
    assert_eq(
      @validate.validate_module(stages.emit_module()),
      Ok(()),
      msg=@utf8.decode_lossy(source),
    )
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
    let captures = module_.captures.filter(fn(capture) { capture.mutable_ })
    assert_eq(captures.length(), 1)
    let capture = captures[0]
    assert_true(capture.shape is @semantic.I64PlannedValueShape)
    let (body, local_id) = match capture.source {
      @semantic.BodyLocalCapture(owner, source_local) =>
        (module_.bodies[@semantic.semantic_id_local(owner)], source_local)
      @semantic.LambdaLocalCapture(owner, source_local) =>
        (module_.lambda_body(owner).unwrap(), source_local)
    }
    let index = body.locals.start + local_id
    let local_ = module_.locals[index]
    assert_true(local_.mutable_)
    assert_true(local_.shape is @semantic.I64PlannedValueShape)
    for (shape, reason) in capture_cell_bad_shapes() {
      module_.locals[index] = local_.with_shape(shape)
      assert_eq(
        emit_starshine_program_module(stages.lowering, stages.link),
        Err(
          CompilerInvariantFailure({
            code: 301U,
            phase: 7U,
            module_id: 28131UL,
            declaration: body.declaration,
            body: body.body,
            expression: 0xffffffffU,
            expected: 0UL,
            actual: reason,
            detail: index.to_uint64(),
          }),
        ),
      )
    }
  }
}

///|
test "mutable capture storage preserves concrete and selected generic values" {
  for
    source in [
      b"pub fn select<t>(first: t, second: t) -> t {\n  let mut item = first\n  let update = fn() -> t {\n    item = second\n    item\n  }\n  update()\n}\npub fn run() -> I64 {\n  select(1i64, 42i64)\n}\n",
      b"pub fn run() -> Unit {\n  let mut seed = ()\n  let callback = fn() -> Unit {\n    seed = ()\n    seed\n  }\n  callback()\n}\n",
      b"pub fn run() -> (I64, I32) {\n  let mut seed = (1i64, 2i32)\n  let callback = fn() -> (I64, I32) {\n    seed = (3i64, 4i32)\n    seed\n  }\n  callback()\n}\n",
      b"fn select<t>(first: t, second: t) -> t {\n  let mut item = first\n  let update = fn() -> t {\n    item = second\n    item\n  }\n  update()\n}\npub fn run() -> I64 {\n  select(1i64, 42i64)\n}\n",
    ] {
    let stages = backend_test_single_module_stages(28133UL, source)
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
        ) +
        @utf8.decode_lossy(source),
    )
    assert_eq(
      @validate.validate_module(stages.emit_module()),
      Ok(()),
      msg=@utf8.decode_lossy(source),
    )
  }
}

///|
test "capture cells check selected shapes and carrier agreement" {
  let stages = backend_test_single_module_stages(
    28135UL, b"pub fn run() -> I64 {\n  let mut seed = 1i64\n  let callback = fn() -> I64 {\n    seed = 2i64\n    seed\n  }\n  callback()\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let module_ = stages.lowering.modules[0]
  let body = module_.bodies[0]
  let local_id = match module_.captures[0].source {
    @semantic.BodyLocalCapture(_, local_id) => local_id
    _ => fail("expected a body local")
  }
  let index = body.locals.start + local_id
  let shape = module_.locals[index].shape
  let failure = fn(
    code : UInt32,
    expected : UInt64,
    actual : UInt64,
  ) -> Result[Unit, StarshineCodeEmissionError] {
    Err(
      CompilerInvariantFailure({
        code,
        phase: 7U,
        module_id: 28135UL,
        declaration: body.declaration,
        body: body.body,
        expression: 0xffffffffU,
        expected,
        actual,
        detail: index.to_uint64(),
      }),
    )
  }
  for (selected, reason) in capture_cell_bad_shapes() {
    assert_eq(
      starshine_check_capture_cell_shape(module_, body, index, shape, selected),
      failure(301U, 0UL, reason),
    )
  }
  assert_eq(
    starshine_check_capture_cell_shape(
      module_,
      body,
      index,
      shape,
      @semantic.planned_i32_shape(),
    ),
    failure(302U, 1UL, 0UL),
  )
  let generic = capture_cell_bad_shapes()[0].0
  assert_eq(
    starshine_check_capture_cell_shape(module_, body, index, generic, shape),
    failure(301U, 0UL, 1UL),
  )
  assert_eq(
    starshine_check_capture_cell_shape(
      module_,
      body,
      index,
      generic,
      @semantic.planned_reference_shape(),
    ),
    Ok(()),
  )
}
