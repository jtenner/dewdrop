///|
test "compile time queries preserve logical integer identity" {
  assert_eq(
    evaluate_compile_time_type_query(b"types.type_equal", [
      CtPrimitive(I8Type),
      CtPrimitive(I32Type),
    ]),
    Ok(Some(CtBool(false))),
  )
  assert_eq(
    evaluate_compile_time_type_query(b"types.bit_width", [CtPrimitive(I16Type)]),
    Ok(Some(CtU32(16))),
  )
  assert_eq(
    evaluate_compile_time_type_query(b"types.is_signed_integer", [
      CtPrimitive(U32Type),
    ]),
    Ok(Some(CtBool(false))),
  )
}

///|
test "compile time Unit Never and missing evidence stay distinct" {
  assert_eq(
    evaluate_compile_time_type_query(b"types.is_unit", [CtPrimitive(UnitType)]),
    Ok(Some(CtBool(true))),
  )
  assert_eq(
    evaluate_compile_time_type_query(b"types.is_unit", [CtPrimitive(NeverType)]),
    Ok(Some(CtBool(false))),
  )
  assert_eq(
    evaluate_compile_time_type_query(b"types.is_never", [CtPrimitive(NeverType)]),
    Ok(Some(CtBool(true))),
  )
  assert_eq(
    evaluate_compile_time_type_query(b"types.is_unit", [CtParameter(12UL)]),
    Ok(None),
  )
  assert_true(
    evaluate_compile_time_type_query(b"types.is_unit", [CtError]) is Err(_),
  )
  assert_true(
    evaluate_compile_time_type_query(b"types.type_equal", [
      CtParameter(12UL),
      CtError,
    ])
    is Err(_),
  )
}

///|
test "compile time queries compare structure not carrier or arena positions" {
  let a = CtProduct([CtPrimitive(I32Type), CtNominal(42UL)])
  let b = CtProduct([CtPrimitive(I32Type), CtNominal(43UL)])
  assert_eq(
    evaluate_compile_time_type_query(b"types.type_equal", [a, a]),
    Ok(Some(CtBool(true))),
  )
  assert_eq(
    evaluate_compile_time_type_query(b"types.type_equal", [a, b]),
    Ok(Some(CtBool(false))),
  )
  assert_eq(
    evaluate_compile_time_type_query(b"types.tuple_length", [a]),
    Ok(Some(CtU32(2))),
  )
  assert_eq(
    evaluate_compile_time_type_query(b"types.tuple_length", [CtProduct([])]),
    Ok(Some(CtU32(0))),
  )
  assert_true(
    evaluate_compile_time_type_query(b"types.tuple_length", [
      CtPrimitive(UnitType),
    ])
    is Err(_),
  )
}

///|
test "compile time bitcast query follows the checked unsafe cast contract" {
  assert_eq(
    evaluate_compile_time_type_query(b"types.can_bitcast", [
      CtPrimitive(I16x2Type),
      CtPrimitive(U32Type),
    ]),
    Ok(Some(CtBool(true))),
  )
  assert_eq(
    evaluate_compile_time_type_query(b"types.can_bitcast", [
      CtPrimitive(I32Type),
      CtPrimitive(F32Type),
    ]),
    Ok(Some(CtBool(false))),
  )
  assert_eq(
    evaluate_compile_time_type_query(b"types.can_bitcast", [
      CtNominal(42UL),
      CtNominal(42UL),
    ]),
    Ok(Some(CtBool(false))),
  )
  assert_eq(
    evaluate_compile_time_type_query(b"types.can_bitcast", [
      CtPrimitive(UnitType),
      CtPrimitive(UnitType),
    ]),
    Ok(Some(CtBool(false))),
  )
}

///|
test "compile time packed and SIMD lane queries use logical lanes" {
  for
    entry in [
      (I16x2Type, 2, 16),
      (U8x8Type, 8, 8),
      (I32x4Type, 4, 32),
      (F64x2Type, 2, 64),
    ] {
    let (primitive, lanes, width) = entry
    assert_eq(
      evaluate_compile_time_type_query(b"types.lane_count", [
        CtPrimitive(primitive),
      ]),
      Ok(Some(CtU32(lanes))),
    )
    assert_eq(
      evaluate_compile_time_type_query(b"types.lane_bit_width", [
        CtPrimitive(primitive),
      ]),
      Ok(Some(CtU32(width))),
    )
    assert_eq(
      evaluate_compile_time_type_query(b"types.bit_width", [
        CtPrimitive(primitive),
      ]),
      Ok(Some(CtU32(lanes * width))),
    )
  }
  assert_true(
    evaluate_compile_time_type_query(b"types.lane_count", [
      CtPrimitive(V128Type),
    ])
    is Err(_),
  )
  assert_true(
    evaluate_compile_time_type_query(b"types.lane_count", [CtPrimitive(I32Type)])
    is Err(_),
  )
}

///|
test "compile time type queries reject wrong arity and unknown targets" {
  assert_true(evaluate_compile_time_type_query(b"types.is_unit", []) is Err(_))
  assert_true(
    evaluate_compile_time_type_query(b"types.type_equal", [
      CtPrimitive(UnitType),
    ])
    is Err(_),
  )
  assert_true(
    evaluate_compile_time_type_query(b"user.is_unit", [CtPrimitive(UnitType)])
    is Err(_),
  )
}
