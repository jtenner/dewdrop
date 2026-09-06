///|
test "compile time raw product layout has explicit padding and offsets" {
  let type_ = CtProduct([
    CtPrimitive(U8Type),
    CtPrimitive(UnitType),
    CtPrimitive(I64Type),
    CtProduct([CtPrimitive(U16Type), CtPrimitive(U8Type)]),
  ])
  assert_eq(compile_time_raw_layout(type_, 0), Ok((24U, 8U, [0U, 1U, 8U, 16U])))
  assert_eq(compile_time_raw_layout(CtProduct([]), 0), Ok((0U, 1U, [])))
  assert_eq(evaluate_compile_time_field_offset([type_], 2U), Ok(Some(CtU32(8))))
  assert_eq(
    evaluate_compile_time_type_query(b"types.size_of", [type_]),
    Ok(Some(CtU32(24))),
  )
  assert_eq(
    evaluate_compile_time_type_query(b"types.align_of", [type_]),
    Ok(Some(CtU32(8))),
  )
}

///|
test "compile time raw layout rejects GC fields and invalid offsets" {
  let scalar = CtPrimitive(U8Type)
  assert_eq(
    evaluate_compile_time_field_offset([CtProduct([scalar])], 1U),
    Err(CtWrongTypeCategory(b"types.field_offset")),
  )
  assert_eq(
    evaluate_compile_time_field_offset([scalar], 0U),
    Err(CtWrongTypeCategory(b"types.field_offset")),
  )
  assert_eq(
    evaluate_compile_time_field_offset([CtParameter(12UL)], 0U),
    Ok(None),
  )
  assert_eq(
    evaluate_compile_time_field_offset(
      [CtProduct([CtPrimitive(StringType)])],
      0U,
    ),
    Err(CtWrongTypeCategory(b"types.field_offset")),
  )
  assert_eq(compile_time_raw_align(4294967295U, 8U), None)
}

///|
test "compile time raw layout folds source calls and diagnoses runtime indices" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\npub fn offset() -> U32 {\n  field_offset::<(U8, Unit, I64)>(2u32)\n}\n",
  )
  let module_ = lowering.modules[0]
  assert_eq(module_.diagnostics, [])
  assert_true(
    module_.expressions.any(fn(source) { source.kind is PlannedU32Const(8UL) }),
  )
  let (_, invalid) = compile_time_evidence_test(
    b"open dew.std.types\npub fn offset(index: U32) -> U32 {\n  field_offset::<(U8, I64)>(index)\n}\n",
  )
  assert_true(
    invalid.modules[0].diagnostics.any(fn(diagnostic) {
      diagnostic is CompileTimeQueryDiagnostic(_, message, _) &&
      message.has_prefix("CT-020")
    }),
  )
}
