///|
test "specialization normalization preserves missing and erroneous evidence" {
  assert_eq(
    program_canonical_specialization_shape(GenericPlannedValueShape),
    GenericPlannedValueShape,
  )
  assert_eq(
    program_canonical_specialization_shape(ErrorPlannedValueShape),
    ErrorPlannedValueShape,
  )
  assert_false(
    program_specialization_shapes_equal(
      [GenericPlannedValueShape],
      { start: 0, length: 1, },
      [RefPlannedValueShape],
      { start: 0, length: 1, },
    ),
  )
  assert_false(
    program_specialization_shapes_equal(
      [ErrorPlannedValueShape],
      { start: 0, length: 1, },
      [RefPlannedValueShape],
      { start: 0, length: 1, },
    ),
  )
}

///|
test "specialization product normalization preserves structure and evidence" {
  let shape = ProductPlannedValueShape([
    U8PlannedValueShape,
    ProductPlannedValueShape([
      U64PlannedValueShape,
      GenericPlannedValueShape,
      ErrorPlannedValueShape,
    ]),
    ProductPlannedValueShape([]),
  ])
  let normalized = program_canonical_specialization_shape(shape)
  assert_eq(
    normalized,
    ProductPlannedValueShape([
      U8PlannedValueShape,
      ProductPlannedValueShape([
        I64PlannedValueShape,
        GenericPlannedValueShape,
        ErrorPlannedValueShape,
      ]),
      ProductPlannedValueShape([]),
    ]),
  )
  assert_eq(program_canonical_specialization_shape(normalized), normalized)
}

///|
test "specialization ABI keys distinguish nested product shapes" {
  let evidence = empty_program_trait_evidence_request()
  let span = { start: 0, length: 1, }
  let left = ProductPlannedValueShape([
    I32PlannedValueShape,
    ProductPlannedValueShape([I64PlannedValueShape]),
  ])
  let right = ProductPlannedValueShape([
    I64PlannedValueShape,
    ProductPlannedValueShape([I32PlannedValueShape]),
  ])
  let flat = ProductPlannedValueShape([
    I32PlannedValueShape,
    I64PlannedValueShape,
  ])
  let key = program_specialization_abi_key(11UL, [left], span, evidence)
  assert_eq(key, "11:product[i32,product[i64]]")
  assert_false(
    key == program_specialization_abi_key(11UL, [right], span, evidence),
  )
  assert_false(
    key == program_specialization_abi_key(11UL, [flat], span, evidence),
  )
  assert_eq(
    key,
    program_specialization_abi_key(
      11UL,
      [
        ProductPlannedValueShape([
          U32PlannedValueShape,
          ProductPlannedValueShape([U64PlannedValueShape]),
        ]),
      ],
      span,
      evidence,
    ),
  )
}

///|
test "specialization keys preserve packed storage width and signed reads" {
  let evidence = empty_program_trait_evidence_request()
  let span = { start: 0, length: 1, }
  let shapes = [
    I8PlannedValueShape,
    U8PlannedValueShape,
    I16PlannedValueShape,
    U16PlannedValueShape,
    I32PlannedValueShape,
  ]
  for index, shape in shapes {
    assert_eq(program_canonical_specialization_shape(shape), shape)
    for other in 0..<index {
      assert_false(
        program_specialization_abi_key(11UL, [shape], span, evidence) ==
        program_specialization_abi_key(11UL, [shapes[other]], span, evidence),
      )
    }
  }
}

///|
test "SPC-301 request validation rejects direct and nested invalid evidence" {
  for shape in [GenericPlannedValueShape, ErrorPlannedValueShape] {
    let kind = program_specialization_shape_name(shape)
    for
      candidate in [
        shape,
        ProductPlannedValueShape([I64PlannedValueShape, shape]),
      ] {
      assert_eq(
        validate_program_specialization_request_shapes(
          11UL,
          [RefPlannedValueShape, candidate],
          { start: 0, length: 2, },
        ),
        Err("SPC-301 declaration=11 argument=1 invalid physical shape=\{kind}"),
      )
    }
  }
  assert_eq(
    validate_program_specialization_request_shapes(
      11UL,
      [ProductPlannedValueShape([U8PlannedValueShape, RefPlannedValueShape])],
      { start: 0, length: 1, },
    ),
    Ok(()),
  )
}

///|
test "specialization span checks cannot overflow" {
  assert_true(program_specialization_span_is_valid({ start: 2, length: 0, }, 2))
  for
    span in [
      { start: -1, length: 1, },
      { start: 0, length: -1, },
      { start: 3, length: 0, },
      { start: 1, length: 2, },
      { start: 2147483647, length: 2147483647, },
    ] {
    assert_false(program_specialization_span_is_valid(span, 2))
    assert_eq(
      validate_program_specialization_request_shapes(
        11UL,
        [I32PlannedValueShape, I64PlannedValueShape],
        span,
      ),
      Err(
        "SPC-301 declaration=11 invalid shape span start=\{span.start} length=\{span.length} arena=2",
      ),
    )
  }
}

///|
test "specialization handoff rejects a poisoned stored request" {
  let stages = compiler_test_stages(22905UL, [
    CompilerTestModule::new("app.main", [
      CompilerTestSource::new(
        "main.dew", b"pub fn identity<t>(value: t) -> t {\n  value\n}\npub fn run() -> I32 {\n  identity(42)\n}\n",
      ),
    ]),
  ])
  let plan = plan_program_wasmgc_fragments(stages.analyzed, stages.lowering)
  assert_eq(validate_program_specialization_plan(plan, stages.lowering), Ok(()))
  let module_ = plan.modules[0]
  let mut checked = false
  for function_ in module_.functions {
    if function_.specialization_shapes.length == 1 {
      let index = function_.specialization_shapes.start
      let saved = module_.specialization_shapes[index]
      module_.specialization_shapes[index] = ErrorPlannedValueShape
      assert_eq(
        validate_program_specialization_plan(plan, stages.lowering),
        Err(
          "SPC-301 declaration=\{function_.declaration} argument=0 invalid physical shape=error",
        ),
      )
      module_.specialization_shapes[index] = saved
      checked = true
      break
    }
  }
  assert_true(checked)
}
