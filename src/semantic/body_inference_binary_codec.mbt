///|
/// Direct binary schemas for complete and declaration-family inference artifacts.
let inferred_module_payload_version = 2U

///|
let inferred_family_payload_version = 2U

///|
let inferred_family_bundle_payload_version = 2U

///|
let inference_binary_maximum_items = 0x01000000

///|
let inference_binary_maximum_text = 0x01000000

///|
let inference_binary_maximum_section = 0x10000000

///|
fn ib_write_int(writer : @cache_binary.Writer, value : Int) -> Unit {
  writer.write_zigzag_int(value)
}

///|
fn ib_read_int(reader : @cache_binary.Reader, field : String) -> Int {
  reader.read_zigzag_int(field)
}

///|
fn ib_write_id(writer : @cache_binary.Writer, value : UInt64) -> Unit {
  writer.write_u64_le(value)
}

///|
fn ib_read_id(reader : @cache_binary.Reader, field : String) -> UInt64 {
  reader.read_u64_le(field)
}

///|
fn ib_write_span(writer : @cache_binary.Writer, value : HirSpan) -> Unit {
  ib_write_int(writer, value.start)
  ib_write_int(writer, value.length)
}

///|
fn ib_read_span(reader : @cache_binary.Reader, field : String) -> HirSpan {
  { start: ib_read_int(reader, field), length: ib_read_int(reader, field) }
}

///|
fn ib_write_int_array(
  writer : @cache_binary.Writer,
  values : Array[Int],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_int(writer, value)
  }
}

///|
fn ib_read_int_array(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[Int] {
  let count = reader.read_count(inference_binary_maximum_items, field)
  let values : Array[Int] = []
  for _ in 0..<count {
    values.push(ib_read_int(reader, field))
  }
  values
}

///|
fn ib_write_id_array(
  writer : @cache_binary.Writer,
  values : Array[UInt64],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_id(writer, value)
  }
}

///|
fn ib_read_id_array(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[UInt64] {
  let count = reader.read_count(inference_binary_maximum_items, field)
  let values : Array[UInt64] = []
  for _ in 0..<count {
    values.push(ib_read_id(reader, field))
  }
  values
}

///|
fn ib_write_span_array(
  writer : @cache_binary.Writer,
  values : Array[HirSpan],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_span(writer, value)
  }
}

///|
fn ib_read_span_array(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[HirSpan] {
  let count = reader.read_count(inference_binary_maximum_items, field)
  let values : Array[HirSpan] = []
  for _ in 0..<count {
    values.push(ib_read_span(reader, field))
  }
  values
}

///|
fn ib_write_primitive(
  writer : @cache_binary.Writer,
  value : PrimitiveType,
) -> Unit {
  writer.write_byte(value.rank().to_byte())
}

///|
fn ib_read_primitive(
  reader : @cache_binary.Reader,
  field : String,
) -> PrimitiveType {
  match cache_primitive_from_rank(reader.read_byte(field).to_int()) {
    Some(value) => value
    None => {
      reader.fail(field, "unknown primitive discriminant")
      UnitType
    }
  }
}

///|
fn ib_write_shape(
  writer : @cache_binary.Writer,
  value : PlannedValueShape,
) -> Unit {
  writer.write_byte(
    match value {
      ErrorPlannedValueShape => 0
      UnitPlannedValueShape => 1
      I8PlannedValueShape => 2
      I16PlannedValueShape => 3
      I32PlannedValueShape => 4
      I64PlannedValueShape => 5
      U8PlannedValueShape => 6
      U16PlannedValueShape => 7
      U32PlannedValueShape => 8
      U64PlannedValueShape => 9
      F32PlannedValueShape => 10
      F64PlannedValueShape => 11
      Swar32PlannedValueShape => 12
      Swar64PlannedValueShape => 13
      V128PlannedValueShape => 14
      RefPlannedValueShape => 15
      GenericPlannedValueShape => 16
      NeverPlannedValueShape => 17
    },
  )
}

///|
fn ib_read_shape(
  reader : @cache_binary.Reader,
  field : String,
) -> PlannedValueShape {
  match reader.read_byte(field) {
    0 => ErrorPlannedValueShape
    1 => UnitPlannedValueShape
    2 => I8PlannedValueShape
    3 => I16PlannedValueShape
    4 => I32PlannedValueShape
    5 => I64PlannedValueShape
    6 => U8PlannedValueShape
    7 => U16PlannedValueShape
    8 => U32PlannedValueShape
    9 => U64PlannedValueShape
    10 => F32PlannedValueShape
    11 => F64PlannedValueShape
    12 => Swar32PlannedValueShape
    13 => Swar64PlannedValueShape
    14 => V128PlannedValueShape
    15 => RefPlannedValueShape
    16 => GenericPlannedValueShape
    17 => NeverPlannedValueShape
    _ => {
      reader.fail(field, "unknown value-shape discriminant")
      ErrorPlannedValueShape
    }
  }
}

///|
fn ib_write_body_type(
  writer : @cache_binary.Writer,
  value : BodyTypeTerm,
) -> Unit {
  match value {
    BodyErrorType => writer.write_byte(0)
    BodyResolvedType(type_) => {
      writer.write_byte(1)
      ib_write_int(writer, type_)
    }
    BodyVariableType(variable) => {
      writer.write_byte(2)
      ib_write_int(writer, variable)
    }
    BodyAppliedType(base, arguments) => {
      writer.write_byte(3)
      ib_write_int(writer, base)
      ib_write_span(writer, arguments)
    }
    BodyFunctionType(parameters, result) => {
      writer.write_byte(4)
      ib_write_span(writer, parameters)
      ib_write_int(writer, result)
    }
  }
}

///|
fn ib_read_body_type(
  reader : @cache_binary.Reader,
  field : String,
) -> BodyTypeTerm {
  match reader.read_byte(field) {
    0 => BodyErrorType
    1 => BodyResolvedType(ib_read_int(reader, field))
    2 => BodyVariableType(ib_read_int(reader, field))
    3 =>
      BodyAppliedType(ib_read_int(reader, field), ib_read_span(reader, field))
    4 =>
      BodyFunctionType(ib_read_span(reader, field), ib_read_int(reader, field))
    _ => {
      reader.fail(field, "unknown body-type discriminant")
      BodyErrorType
    }
  }
}

///|
fn ib_write_body_types(
  writer : @cache_binary.Writer,
  values : Array[BodyTypeTerm],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_body_type(writer, value)
  }
}

///|
fn ib_read_body_types(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[BodyTypeTerm] {
  let count = reader.read_count(inference_binary_maximum_items, field)
  let values : Array[BodyTypeTerm] = []
  for _ in 0..<count {
    values.push(ib_read_body_type(reader, field))
  }
  values
}

///|
fn ib_write_origin(
  writer : @cache_binary.Writer,
  value : TypeConstraintOrigin,
) -> Unit {
  writer.write_byte(
    match value.kind {
      ExpressionTypeConstraint => 0
      PatternTypeConstraint => 1
      LocalTypeConstraint => 2
      ReturnTypeConstraint => 3
      CallTypeConstraint => 4
      OperatorTypeConstraint => 5
      SyntheticTypeConstraint => 6
    },
  )
  ib_write_int(writer, value.source)
  writer.write_var_u64(value.offset)
}

///|
fn ib_read_origin(
  reader : @cache_binary.Reader,
  field : String,
) -> TypeConstraintOrigin {
  let kind = match reader.read_byte(field) {
    0 => ExpressionTypeConstraint
    1 => PatternTypeConstraint
    2 => LocalTypeConstraint
    3 => ReturnTypeConstraint
    4 => CallTypeConstraint
    5 => OperatorTypeConstraint
    6 => SyntheticTypeConstraint
    _ => {
      reader.fail(field, "unknown constraint-origin discriminant")
      SyntheticTypeConstraint
    }
  }
  {
    kind,
    source: ib_read_int(reader, field),
    offset: reader.read_var_u64(field),
  }
}

///|
fn ib_write_local_diagnostic(
  writer : @cache_binary.Writer,
  value : LocalInferenceDiagnostic,
) -> Unit {
  match value {
    LocalTypeMismatch(left, right, origin) => {
      writer.write_byte(0)
      ib_write_int(writer, left)
      ib_write_int(writer, right)
      ib_write_origin(writer, origin)
    }
    InfiniteLocalType(variable, type_, origin) => {
      writer.write_byte(1)
      ib_write_int(writer, variable)
      ib_write_int(writer, type_)
      ib_write_origin(writer, origin)
    }
  }
}

///|
fn ib_read_local_diagnostic(
  reader : @cache_binary.Reader,
  field : String,
) -> LocalInferenceDiagnostic {
  match reader.read_byte(field) {
    0 =>
      LocalTypeMismatch(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        ib_read_origin(reader, field),
      )
    1 =>
      InfiniteLocalType(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        ib_read_origin(reader, field),
      )
    _ => {
      reader.fail(field, "unknown local-diagnostic discriminant")
      LocalTypeMismatch(0, 0, ib_read_origin(reader, field))
    }
  }
}

///|
fn ib_write_inference_diagnostic(
  writer : @cache_binary.Writer,
  value : BodyInferenceDiagnostic,
) -> Unit {
  match value {
    BodyConstraintDiagnostic(d) => {
      writer.write_byte(0)
      ib_write_local_diagnostic(writer, d)
    }
    NumericLiteralOutOfRange(a, b, c) => {
      writer.write_byte(1)
      ib_write_int(writer, a)
      ib_write_primitive(writer, b)
      writer.write_var_u64(c)
    }
    UnsupportedExpressionInference(a, b) => {
      writer.write_byte(2)
      ib_write_int(writer, a)
      writer.write_var_u64(b)
    }
    InvalidCallTarget(a, b) => {
      writer.write_byte(3)
      ib_write_int(writer, a)
      writer.write_var_u64(b)
    }
    InvalidAssignmentTarget(a, b) => {
      writer.write_byte(4)
      ib_write_int(writer, a)
      writer.write_var_u64(b)
    }
    ImmutableAssignmentTarget(a, b) => {
      writer.write_byte(5)
      ib_write_int(writer, a)
      writer.write_var_u64(b)
    }
    FunctionReferenceExpectedTypeRequired(a, b, c) => {
      writer.write_byte(6)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
    NoMatchingFunctionReference(a, b, c) => {
      writer.write_byte(7)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
    AmbiguousFunctionReference(a, b, c, d, e, f) => {
      writer.write_byte(8)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      ib_write_id(writer, c)
      ib_write_id(writer, d)
      ib_write_int(writer, e)
      writer.write_var_u64(f)
    }
    FunctionCallArgumentCountMismatch(a, b, c, d) => {
      writer.write_byte(9)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      ib_write_int(writer, c)
      writer.write_var_u64(d)
    }
    CallArgumentCountMismatch(a, b, c, d, e) => {
      writer.write_byte(10)
      ib_write_int(writer, a)
      ib_write_id(writer, b)
      ib_write_int(writer, c)
      ib_write_int(writer, d)
      writer.write_var_u64(e)
    }
    CallTypeArgumentCountMismatch(a, b, c, d, e) => {
      writer.write_byte(11)
      ib_write_int(writer, a)
      ib_write_id(writer, b)
      ib_write_int(writer, c)
      ib_write_int(writer, d)
      writer.write_var_u64(e)
    }
    NoMatchingCallOverload(a, b, c) => {
      writer.write_byte(12)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
    AmbiguousCallOverload(a, b, c, d, e, f) => {
      writer.write_byte(13)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      ib_write_id(writer, c)
      ib_write_id(writer, d)
      ib_write_int(writer, e)
      writer.write_var_u64(f)
    }
    UnresolvedCallTypeArgument(a, b, c) => {
      writer.write_byte(14)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
    UnresolvedModuleValue(a, b) => {
      writer.write_byte(15)
      ib_write_id(writer, a)
      writer.write_var_u64(b)
    }
    InvalidPatternConstructor(a, b) => {
      writer.write_byte(16)
      ib_write_int(writer, a)
      writer.write_var_u64(b)
    }
    UnknownVariantForType(a, b, c, d) => {
      writer.write_byte(17)
      ib_write_int(writer, a)
      ib_write_id(writer, b)
      ib_write_int(writer, c)
      writer.write_var_u64(d)
    }
    AmbiguousPatternVariant(a, b, c, d, e, f) => {
      writer.write_byte(18)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      ib_write_id(writer, c)
      ib_write_id(writer, d)
      ib_write_int(writer, e)
      writer.write_var_u64(f)
    }
    PatternPayloadKindMismatch(a, b, c) => {
      writer.write_byte(19)
      ib_write_int(writer, a)
      writer.write_var_u64(b)
      writer.write_var_u64(c)
    }
    PatternPayloadArityMismatch(a, b, c, d) => {
      writer.write_byte(20)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      ib_write_int(writer, c)
      writer.write_var_u64(d)
    }
    UnknownPatternField(a, b, c) => {
      writer.write_byte(21)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
    MissingPatternField(a, b, c) => {
      writer.write_byte(22)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
    MissingImportedPatternField(a, b, c) => {
      writer.write_byte(23)
      writer.write_string(a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
    UnresolvedPatternTypeArgument(a, b, c) => {
      writer.write_byte(24)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
    InvalidConstructionTarget(a, b) => {
      writer.write_byte(25)
      ib_write_int(writer, a)
      writer.write_var_u64(b)
    }
    ObjectTypeRequired(a, b) => {
      writer.write_byte(26)
      ib_write_int(writer, a)
      writer.write_var_u64(b)
    }
    ConstructionPayloadKindMismatch(a, b, c) => {
      writer.write_byte(27)
      ib_write_int(writer, a)
      writer.write_var_u64(b)
      writer.write_var_u64(c)
    }
    ConstructionPayloadArityMismatch(a, b, c, d, e) => {
      writer.write_byte(28)
      ib_write_int(writer, a)
      ib_write_id(writer, b)
      ib_write_int(writer, c)
      ib_write_int(writer, d)
      writer.write_var_u64(e)
    }
    UnknownVariantValue(a, b, c) => {
      writer.write_byte(29)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
    AmbiguousVariantValue(a, b, c, d, e, f) => {
      writer.write_byte(30)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      ib_write_id(writer, c)
      ib_write_id(writer, d)
      ib_write_int(writer, e)
      writer.write_var_u64(f)
    }
    DuplicateConstructionField(a, b, c) => {
      writer.write_byte(31)
      ib_write_int(writer, a)
      writer.write_var_u64(b)
      writer.write_var_u64(c)
    }
    UnknownConstructionField(a, b, c) => {
      writer.write_byte(32)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
    MissingConstructionField(a, b, c) => {
      writer.write_byte(33)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
    FieldAccessRequiresNominal(a, b) => {
      writer.write_byte(34)
      ib_write_int(writer, a)
      writer.write_var_u64(b)
    }
    UnknownFieldForType(a, b, c, d) => {
      writer.write_byte(35)
      ib_write_int(writer, a)
      ib_write_id(writer, b)
      ib_write_int(writer, c)
      writer.write_var_u64(d)
    }
    UnknownQualifiedMember(a, b, c, d) => {
      writer.write_byte(36)
      ib_write_int(writer, a)
      ib_write_id(writer, b)
      ib_write_int(writer, c)
      writer.write_var_u64(d)
    }
    UnknownImportedModuleMember(a, b, c) => {
      writer.write_byte(37)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
    NoMatchingMethod(a, b, c) => {
      writer.write_byte(38)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
    AmbiguousMethod(a, b, c, d, e, f) => {
      writer.write_byte(39)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      ib_write_id(writer, c)
      ib_write_id(writer, d)
      ib_write_int(writer, e)
      writer.write_var_u64(f)
    }
    UnsatisfiedTraitObligation(a, b, c, d, e) => {
      writer.write_byte(40)
      ib_write_id(writer, a)
      ib_write_id(writer, b)
      ib_write_id(writer, c)
      ib_write_int(writer, d)
      writer.write_var_u64(e)
    }
    UnresolvedExpressionTypeArgument(a, b, c) => {
      writer.write_byte(41)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
    ReturnOutsideCallable(a) => {
      writer.write_byte(42)
      writer.write_var_u64(a)
    }
    UnresolvedExpressionType(a, b) => {
      writer.write_byte(43)
      ib_write_int(writer, a)
      writer.write_var_u64(b)
    }
    UnresolvedLocalType(a, b, c) => {
      writer.write_byte(44)
      ib_write_id(writer, a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
    UnresolvedLambdaLocalType(a, b, c) => {
      writer.write_byte(45)
      ib_write_int(writer, a)
      ib_write_int(writer, b)
      writer.write_var_u64(c)
    }
  }
}

///|
fn ib_read_inference_diagnostic(
  reader : @cache_binary.Reader,
  field : String,
) -> BodyInferenceDiagnostic {
  match reader.read_byte(field) {
    0 => BodyConstraintDiagnostic(ib_read_local_diagnostic(reader, field))
    1 =>
      NumericLiteralOutOfRange(
        ib_read_int(reader, field),
        ib_read_primitive(reader, field),
        reader.read_var_u64(field),
      )
    2 =>
      UnsupportedExpressionInference(
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    3 =>
      InvalidCallTarget(ib_read_int(reader, field), reader.read_var_u64(field))
    4 =>
      InvalidAssignmentTarget(
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    5 =>
      ImmutableAssignmentTarget(
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    6 =>
      FunctionReferenceExpectedTypeRequired(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    7 =>
      NoMatchingFunctionReference(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    8 =>
      AmbiguousFunctionReference(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    9 =>
      FunctionCallArgumentCountMismatch(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    10 =>
      CallArgumentCountMismatch(
        ib_read_int(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    11 =>
      CallTypeArgumentCountMismatch(
        ib_read_int(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    12 =>
      NoMatchingCallOverload(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    13 =>
      AmbiguousCallOverload(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    14 =>
      UnresolvedCallTypeArgument(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    15 =>
      UnresolvedModuleValue(
        ib_read_id(reader, field),
        reader.read_var_u64(field),
      )
    16 =>
      InvalidPatternConstructor(
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    17 =>
      UnknownVariantForType(
        ib_read_int(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    18 =>
      AmbiguousPatternVariant(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    19 =>
      PatternPayloadKindMismatch(
        ib_read_int(reader, field),
        reader.read_var_u64(field),
        reader.read_var_u64(field),
      )
    20 =>
      PatternPayloadArityMismatch(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    21 =>
      UnknownPatternField(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    22 =>
      MissingPatternField(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    23 =>
      MissingImportedPatternField(
        reader.read_string(inference_binary_maximum_text, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    24 =>
      UnresolvedPatternTypeArgument(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    25 =>
      InvalidConstructionTarget(
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    26 =>
      ObjectTypeRequired(ib_read_int(reader, field), reader.read_var_u64(field))
    27 =>
      ConstructionPayloadKindMismatch(
        ib_read_int(reader, field),
        reader.read_var_u64(field),
        reader.read_var_u64(field),
      )
    28 =>
      ConstructionPayloadArityMismatch(
        ib_read_int(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    29 =>
      UnknownVariantValue(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    30 =>
      AmbiguousVariantValue(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    31 =>
      DuplicateConstructionField(
        ib_read_int(reader, field),
        reader.read_var_u64(field),
        reader.read_var_u64(field),
      )
    32 =>
      UnknownConstructionField(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    33 =>
      MissingConstructionField(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    34 =>
      FieldAccessRequiresNominal(
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    35 =>
      UnknownFieldForType(
        ib_read_int(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    36 =>
      UnknownQualifiedMember(
        ib_read_int(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    37 =>
      UnknownImportedModuleMember(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    38 =>
      NoMatchingMethod(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    39 =>
      AmbiguousMethod(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    40 =>
      UnsatisfiedTraitObligation(
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    41 =>
      UnresolvedExpressionTypeArgument(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    42 => ReturnOutsideCallable(reader.read_var_u64(field))
    43 =>
      UnresolvedExpressionType(
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    44 =>
      UnresolvedLocalType(
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    45 =>
      UnresolvedLambdaLocalType(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    _ => {
      reader.fail(field, "unknown body-diagnostic discriminant")
      ReturnOutsideCallable(0UL)
    }
  }
}

///|
fn ib_write_diagnostics(
  writer : @cache_binary.Writer,
  values : Array[BodyInferenceDiagnostic],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_inference_diagnostic(writer, value)
  }
}

///|
fn ib_read_diagnostics(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[BodyInferenceDiagnostic] {
  let count = reader.read_count(inference_binary_maximum_items, field)
  let values : Array[BodyInferenceDiagnostic] = []
  for _ in 0..<count {
    values.push(ib_read_inference_diagnostic(reader, field))
  }
  values
}

///|
fn ib_write_dependencies(
  writer : @cache_binary.Writer,
  value : ModuleValueDependencies,
) -> Unit {
  ib_write_id(writer, value.module_id)
  ib_write_span_array(writer, value.let_dependencies)
  ib_write_id_array(writer, value.dependency_declarations)
  ib_write_span_array(writer, value.sccs)
  ib_write_id_array(writer, value.scc_declarations)
}

///|
fn ib_read_dependencies(
  reader : @cache_binary.Reader,
  field : String,
) -> ModuleValueDependencies {
  {
    module_id: ib_read_id(reader, field),
    let_dependencies: ib_read_span_array(reader, field),
    dependency_declarations: ib_read_id_array(reader, field),
    sccs: ib_read_span_array(reader, field),
    scc_declarations: ib_read_id_array(reader, field),
  }
}

///|
fn ib_write_module_values(
  writer : @cache_binary.Writer,
  value : InferredModuleValues,
) -> Unit {
  ib_write_id(writer, value.module_id)
  ib_write_dependencies(writer, value.dependencies)
  ib_write_id_array(writer, value.let_declarations)
  ib_write_int_array(writer, value.let_types)
  ib_write_body_types(writer, value.types)
  ib_write_int_array(writer, value.type_arguments)
  ib_write_diagnostics(writer, value.diagnostics)
}

///|
fn ib_read_module_values(
  reader : @cache_binary.Reader,
  field : String,
) -> InferredModuleValues {
  {
    module_id: ib_read_id(reader, field),
    dependencies: ib_read_dependencies(reader, field),
    let_declarations: ib_read_id_array(reader, field),
    let_types: ib_read_int_array(reader, field),
    types: ib_read_body_types(reader, field),
    type_arguments: ib_read_int_array(reader, field),
    diagnostics: ib_read_diagnostics(reader, field),
  }
}

///|
fn ib_write_impl_head(
  writer : @cache_binary.Writer,
  value : ImplTargetHead,
) -> Unit {
  match value {
    ErrorImplTargetHead => writer.write_byte(0)
    PrimitiveImplTargetHead(p) => {
      writer.write_byte(1)
      ib_write_primitive(writer, p)
    }
    NominalImplTargetHead(d) => {
      writer.write_byte(2)
      ib_write_id(writer, d)
    }
  }
}

///|
fn ib_read_impl_head(
  reader : @cache_binary.Reader,
  field : String,
) -> ImplTargetHead {
  match reader.read_byte(field) {
    0 => ErrorImplTargetHead
    1 => PrimitiveImplTargetHead(ib_read_primitive(reader, field))
    2 => NominalImplTargetHead(ib_read_id(reader, field))
    _ => {
      reader.fail(field, "unknown implementation-head discriminant")
      ErrorImplTargetHead
    }
  }
}

///|
fn ib_write_impl_diagnostic(
  writer : @cache_binary.Writer,
  value : ImplIndexDiagnostic,
) -> Unit {
  match value {
    InvalidImplTraitHead(a, b) => {
      writer.write_byte(0)
      ib_write_id(writer, a)
      writer.write_var_u64(b)
    }
    InvalidImplTargetHead(a, b) => {
      writer.write_byte(1)
      ib_write_id(writer, a)
      writer.write_var_u64(b)
    }
    OrphanTraitImpl(a, b, c, d) => {
      writer.write_byte(2)
      ib_write_id(writer, a)
      ib_write_id(writer, b)
      ib_write_impl_head(writer, c)
      writer.write_var_u64(d)
    }
    OverlappingTraitImpl(a, b, c, d, e) => {
      writer.write_byte(3)
      ib_write_id(writer, a)
      ib_write_id(writer, b)
      ib_write_id(writer, c)
      ib_write_impl_head(writer, d)
      writer.write_var_u64(e)
    }
    UnknownTraitImplMethod(a, b, c) => {
      writer.write_byte(4)
      ib_write_id(writer, a)
      ib_write_id(writer, b)
      writer.write_var_u64(c)
    }
    MissingTraitMethod(a, b, c) => {
      writer.write_byte(5)
      ib_write_id(writer, a)
      ib_write_id(writer, b)
      writer.write_var_u64(c)
    }
    DuplicateTraitImplMethod(a, b, c, d) => {
      writer.write_byte(6)
      ib_write_id(writer, a)
      ib_write_id(writer, b)
      ib_write_id(writer, c)
      writer.write_var_u64(d)
    }
    TraitMethodReceiverMismatch(a, b, c) => {
      writer.write_byte(7)
      ib_write_id(writer, a)
      ib_write_id(writer, b)
      writer.write_var_u64(c)
    }
    TraitMethodParameterCountMismatch(a, b, c, d, e) => {
      writer.write_byte(8)
      ib_write_id(writer, a)
      ib_write_id(writer, b)
      ib_write_int(writer, c)
      ib_write_int(writer, d)
      writer.write_var_u64(e)
    }
    TraitMethodGenericParameterCountMismatch(a, b, c, d, e) => {
      writer.write_byte(9)
      ib_write_id(writer, a)
      ib_write_id(writer, b)
      ib_write_int(writer, c)
      ib_write_int(writer, d)
      writer.write_var_u64(e)
    }
    TraitMethodParameterTypeMismatch(a, b, c, d) => {
      writer.write_byte(10)
      ib_write_id(writer, a)
      ib_write_id(writer, b)
      ib_write_int(writer, c)
      writer.write_var_u64(d)
    }
    TraitMethodReturnTypeMismatch(a, b, c) => {
      writer.write_byte(11)
      ib_write_id(writer, a)
      ib_write_id(writer, b)
      writer.write_var_u64(c)
    }
    DuplicateInherentMethod(a, b, c, d) => {
      writer.write_byte(12)
      ib_write_int(writer, a)
      ib_write_id(writer, b)
      ib_write_id(writer, c)
      writer.write_var_u64(d)
    }
  }
}

///|
fn ib_read_impl_diagnostic(
  reader : @cache_binary.Reader,
  field : String,
) -> ImplIndexDiagnostic {
  match reader.read_byte(field) {
    0 =>
      InvalidImplTraitHead(
        ib_read_id(reader, field),
        reader.read_var_u64(field),
      )
    1 =>
      InvalidImplTargetHead(
        ib_read_id(reader, field),
        reader.read_var_u64(field),
      )
    2 =>
      OrphanTraitImpl(
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_impl_head(reader, field),
        reader.read_var_u64(field),
      )
    3 =>
      OverlappingTraitImpl(
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_impl_head(reader, field),
        reader.read_var_u64(field),
      )
    4 =>
      UnknownTraitImplMethod(
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        reader.read_var_u64(field),
      )
    5 =>
      MissingTraitMethod(
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        reader.read_var_u64(field),
      )
    6 =>
      DuplicateTraitImplMethod(
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        reader.read_var_u64(field),
      )
    7 =>
      TraitMethodReceiverMismatch(
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        reader.read_var_u64(field),
      )
    8 =>
      TraitMethodParameterCountMismatch(
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    9 =>
      TraitMethodGenericParameterCountMismatch(
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    10 =>
      TraitMethodParameterTypeMismatch(
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        reader.read_var_u64(field),
      )
    11 =>
      TraitMethodReturnTypeMismatch(
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        reader.read_var_u64(field),
      )
    12 =>
      DuplicateInherentMethod(
        ib_read_int(reader, field),
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        reader.read_var_u64(field),
      )
    _ => {
      reader.fail(field, "unknown implementation-diagnostic discriminant")
      InvalidImplTargetHead(0UL, 0UL)
    }
  }
}

///|
fn ib_write_impl_index(
  writer : @cache_binary.Writer,
  value : ModuleImplIndex,
) -> Unit {
  ib_write_id(writer, value.module_id)
  writer.write_var_u64(value.implementations.length().to_uint64())
  for item in value.implementations {
    ib_write_id(writer, item.declaration)
    match item.kind {
      InherentIndexedImpl => writer.write_byte(0)
      TraitIndexedImpl(d) => {
        writer.write_byte(1)
        ib_write_id(writer, d)
      }
    }
    ib_write_impl_head(writer, item.target_head)
    ib_write_int(writer, item.trait_type)
    ib_write_int(writer, item.target_type)
    ib_write_span(writer, item.methods)
    ib_write_int(writer, item.bucket)
    writer.write_bool(item.valid)
    writer.write_bool(item.coherent)
    ib_write_int(writer, item.specificity)
  }
  writer.write_var_u64(value.methods.length().to_uint64())
  for item in value.methods {
    ib_write_id(writer, item.declaration)
    match item.requirement {
      Some(d) => {
        writer.write_option_tag(true)
        ib_write_id(writer, d)
      }
      None => writer.write_option_tag(false)
    }
    writer.write_bool(item.instance)
  }
  writer.write_var_u64(value.buckets.length().to_uint64())
  for item in value.buckets {
    match item.kind {
      InherentImplBucket => writer.write_byte(0)
      TraitImplBucket(d) => {
        writer.write_byte(1)
        ib_write_id(writer, d)
      }
    }
    ib_write_impl_head(writer, item.target_head)
    ib_write_span(writer, item.implementations)
  }
  ib_write_int_array(writer, value.bucket_implementations)
  writer.write_var_u64(value.method_dispatch.length().to_uint64())
  for item in value.method_dispatch {
    ib_write_impl_head(writer, item.target_head)
    ib_write_int(writer, item.name)
    writer.write_bool(item.inherent)
    writer.write_bool(item.instance)
    ib_write_int(writer, item.implementation)
    ib_write_int(writer, item.method_index)
  }
  writer.write_var_u64(value.trait_method_dispatch.length().to_uint64())
  for item in value.trait_method_dispatch {
    ib_write_id(writer, item.trait_declaration)
    ib_write_int(writer, item.name)
    writer.write_bool(item.instance)
    ib_write_int(writer, item.implementation)
    ib_write_int(writer, item.method_index)
  }
  writer.write_var_u64(value.diagnostics.length().to_uint64())
  for item in value.diagnostics {
    ib_write_impl_diagnostic(writer, item)
  }
}

///|
fn ib_read_impl_index(
  reader : @cache_binary.Reader,
  field : String,
) -> ModuleImplIndex {
  let module_id = ib_read_id(reader, field)
  let implementation_count = reader.read_count(
    inference_binary_maximum_items, field,
  )
  let implementations : Array[IndexedImpl] = []
  for _ in 0..<implementation_count {
    let item = field
    let declaration = ib_read_id(reader, item + ".declaration")
    let kind = match reader.read_byte(item + ".kind") {
      0 => InherentIndexedImpl
      1 => TraitIndexedImpl(ib_read_id(reader, item + ".trait"))
      _ => {
        reader.fail(item, "unknown implementation-kind discriminant")
        InherentIndexedImpl
      }
    }
    implementations.push({
      declaration,
      kind,
      target_head: ib_read_impl_head(reader, item + ".target_head"),
      trait_type: ib_read_int(reader, item + ".trait_type"),
      target_type: ib_read_int(reader, item + ".target_type"),
      methods: ib_read_span(reader, item + ".methods"),
      bucket: ib_read_int(reader, item + ".bucket"),
      valid: reader.read_bool(item + ".valid"),
      coherent: reader.read_bool(item + ".coherent"),
      specificity: ib_read_int(reader, item + ".specificity"),
    })
  }
  let method_count = reader.read_count(inference_binary_maximum_items, field)
  let methods : Array[IndexedImplMethod] = []
  for _ in 0..<method_count {
    let item = field
    let declaration = ib_read_id(reader, item + ".declaration")
    let requirement = if reader.read_option_tag(item + ".requirement_tag") {
      Some(ib_read_id(reader, item + ".requirement"))
    } else {
      None
    }
    methods.push({
      declaration,
      requirement,
      instance: reader.read_bool(item + ".instance"),
    })
  }
  let bucket_count = reader.read_count(inference_binary_maximum_items, field)
  let buckets : Array[ImplBucket] = []
  for _ in 0..<bucket_count {
    let item = field
    let kind = match reader.read_byte(item + ".kind") {
      0 => InherentImplBucket
      1 => TraitImplBucket(ib_read_id(reader, item + ".trait"))
      _ => {
        reader.fail(item, "unknown bucket-kind discriminant")
        InherentImplBucket
      }
    }
    buckets.push({
      kind,
      target_head: ib_read_impl_head(reader, item + ".target_head"),
      implementations: ib_read_span(reader, item + ".implementations"),
    })
  }
  let bucket_implementations = ib_read_int_array(reader, field)
  let dispatch_count = reader.read_count(inference_binary_maximum_items, field)
  let method_dispatch : Array[IndexedMethodDispatch] = []
  for _ in 0..<dispatch_count {
    let item = field
    method_dispatch.push({
      target_head: ib_read_impl_head(reader, item + ".target_head"),
      name: ib_read_int(reader, item + ".name"),
      inherent: reader.read_bool(item + ".inherent"),
      instance: reader.read_bool(item + ".instance"),
      implementation: ib_read_int(reader, item + ".implementation"),
      method_index: ib_read_int(reader, item + ".method_index"),
    })
  }
  let trait_dispatch_count = reader.read_count(
    inference_binary_maximum_items, field,
  )
  let trait_method_dispatch : Array[IndexedTraitMethodDispatch] = []
  for _ in 0..<trait_dispatch_count {
    let item = field
    trait_method_dispatch.push({
      trait_declaration: ib_read_id(reader, item + ".trait"),
      name: ib_read_int(reader, item + ".name"),
      instance: reader.read_bool(item + ".instance"),
      implementation: ib_read_int(reader, item + ".implementation"),
      method_index: ib_read_int(reader, item + ".method_index"),
    })
  }
  let diagnostic_count = reader.read_count(
    inference_binary_maximum_items, field,
  )
  let diagnostics : Array[ImplIndexDiagnostic] = []
  for _ in 0..<diagnostic_count {
    diagnostics.push(ib_read_impl_diagnostic(reader, field))
  }
  {
    module_id,
    implementations,
    methods,
    buckets,
    bucket_implementations,
    method_dispatch,
    trait_method_dispatch,
    diagnostics,
  }
}

///|
fn ib_write_pattern_constructor(
  writer : @cache_binary.Writer,
  value : InferredPatternConstructor,
) -> Unit {
  match value {
    NoInferredPatternConstructor => writer.write_byte(0)
    ErrorInferredPatternConstructor => writer.write_byte(1)
    StructInferredPatternConstructor(d, s) => {
      writer.write_byte(2)
      ib_write_id(writer, d)
      ib_write_span(writer, s)
    }
    VariantInferredPatternConstructor(d, s) => {
      writer.write_byte(3)
      ib_write_id(writer, d)
      ib_write_span(writer, s)
    }
  }
}

///|
fn ib_read_pattern_constructor(
  reader : @cache_binary.Reader,
  field : String,
) -> InferredPatternConstructor {
  match reader.read_byte(field) {
    0 => NoInferredPatternConstructor
    1 => ErrorInferredPatternConstructor
    2 =>
      StructInferredPatternConstructor(
        ib_read_id(reader, field),
        ib_read_span(reader, field),
      )
    3 =>
      VariantInferredPatternConstructor(
        ib_read_id(reader, field),
        ib_read_span(reader, field),
      )
    _ => {
      reader.fail(field, "unknown pattern-constructor discriminant")
      NoInferredPatternConstructor
    }
  }
}

///|
fn ib_write_pattern_constructors(
  writer : @cache_binary.Writer,
  values : Array[InferredPatternConstructor],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_pattern_constructor(writer, value)
  }
}

///|
fn ib_read_pattern_constructors(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[InferredPatternConstructor] {
  let count = reader.read_count(inference_binary_maximum_items, field)
  let values : Array[InferredPatternConstructor] = []
  for _ in 0..<count {
    values.push(ib_read_pattern_constructor(reader, field))
  }
  values
}

///|
fn ib_write_selection(
  writer : @cache_binary.Writer,
  value : InferredExpressionSelection,
) -> Unit {
  match value {
    NoExpressionSelection => writer.write_byte(0)
    ErrorExpressionSelection => writer.write_byte(1)
    StructConstructionSelection(d, s) => {
      writer.write_byte(2)
      ib_write_id(writer, d)
      ib_write_span(writer, s)
    }
    VariantConstructionSelection(d, s) => {
      writer.write_byte(3)
      ib_write_id(writer, d)
      ib_write_span(writer, s)
    }
    UnitVariantValueSelection(d, s) => {
      writer.write_byte(4)
      ib_write_id(writer, d)
      ib_write_span(writer, s)
    }
    FieldAccessSelection(d) => {
      writer.write_byte(5)
      ib_write_id(writer, d)
    }
    ImportedModuleValueSelection(d) => {
      writer.write_byte(6)
      ib_write_id(writer, d)
    }
    FunctionReferenceSelection(d, s) => {
      writer.write_byte(7)
      ib_write_id(writer, d)
      ib_write_span(writer, s)
    }
  }
}

///|
fn ib_read_selection(
  reader : @cache_binary.Reader,
  field : String,
) -> InferredExpressionSelection {
  match reader.read_byte(field) {
    0 => NoExpressionSelection
    1 => ErrorExpressionSelection
    2 =>
      StructConstructionSelection(
        ib_read_id(reader, field),
        ib_read_span(reader, field),
      )
    3 =>
      VariantConstructionSelection(
        ib_read_id(reader, field),
        ib_read_span(reader, field),
      )
    4 =>
      UnitVariantValueSelection(
        ib_read_id(reader, field),
        ib_read_span(reader, field),
      )
    5 => FieldAccessSelection(ib_read_id(reader, field))
    6 => ImportedModuleValueSelection(ib_read_id(reader, field))
    7 =>
      FunctionReferenceSelection(
        ib_read_id(reader, field),
        ib_read_span(reader, field),
      )
    _ => {
      reader.fail(field, "unknown expression-selection discriminant")
      NoExpressionSelection
    }
  }
}

///|
fn ib_write_selections(
  writer : @cache_binary.Writer,
  values : Array[InferredExpressionSelection],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_selection(writer, value)
  }
}

///|
fn ib_read_selections(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[InferredExpressionSelection] {
  let count = reader.read_count(inference_binary_maximum_items, field)
  let values : Array[InferredExpressionSelection] = []
  for _ in 0..<count {
    values.push(ib_read_selection(reader, field))
  }
  values
}

///|
fn ib_write_field_target(
  writer : @cache_binary.Writer,
  value : InferredObjectFieldTarget,
) -> Unit {
  match value {
    NoObjectFieldTarget => writer.write_byte(0)
    ErrorObjectFieldTarget => writer.write_byte(1)
    SelectedObjectFieldTarget(d) => {
      writer.write_byte(2)
      ib_write_id(writer, d)
    }
  }
}

///|
fn ib_read_field_target(
  reader : @cache_binary.Reader,
  field : String,
) -> InferredObjectFieldTarget {
  match reader.read_byte(field) {
    0 => NoObjectFieldTarget
    1 => ErrorObjectFieldTarget
    2 => SelectedObjectFieldTarget(ib_read_id(reader, field))
    _ => {
      reader.fail(field, "unknown field-target discriminant")
      NoObjectFieldTarget
    }
  }
}

///|
fn ib_write_field_targets(
  writer : @cache_binary.Writer,
  values : Array[InferredObjectFieldTarget],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_field_target(writer, value)
  }
}

///|
fn ib_read_field_targets(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[InferredObjectFieldTarget] {
  let count = reader.read_count(inference_binary_maximum_items, field)
  let values : Array[InferredObjectFieldTarget] = []
  for _ in 0..<count {
    values.push(ib_read_field_target(reader, field))
  }
  values
}

///|
fn ib_write_coercion(
  writer : @cache_binary.Writer,
  value : InferredTraitObjectCoercion,
) -> Unit {
  match value {
    NoInferredTraitObjectCoercion => writer.write_byte(0)
    ErrorInferredTraitObjectCoercion => writer.write_byte(1)
    SelectedInferredTraitObjectCoercion(d, e) => {
      writer.write_byte(2)
      ib_write_id(writer, d)
      ib_write_int(writer, e)
    }
  }
}

///|
fn ib_read_coercion(
  reader : @cache_binary.Reader,
  field : String,
) -> InferredTraitObjectCoercion {
  match reader.read_byte(field) {
    0 => NoInferredTraitObjectCoercion
    1 => ErrorInferredTraitObjectCoercion
    2 =>
      SelectedInferredTraitObjectCoercion(
        ib_read_id(reader, field),
        ib_read_int(reader, field),
      )
    _ => {
      reader.fail(field, "unknown trait-coercion discriminant")
      NoInferredTraitObjectCoercion
    }
  }
}

///|
fn ib_write_coercions(
  writer : @cache_binary.Writer,
  values : Array[InferredTraitObjectCoercion],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_coercion(writer, value)
  }
}

///|
fn ib_read_coercions(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[InferredTraitObjectCoercion] {
  let count = reader.read_count(inference_binary_maximum_items, field)
  let values : Array[InferredTraitObjectCoercion] = []
  for _ in 0..<count {
    values.push(ib_read_coercion(reader, field))
  }
  values
}

///|
fn ib_write_call_target(
  writer : @cache_binary.Writer,
  value : InferredCallTarget,
) -> Unit {
  match value {
    NoInferredCallTarget => writer.write_byte(0)
    ErrorInferredCallTarget => writer.write_byte(1)
    SelectedInferredCallTarget(d, s) => {
      writer.write_byte(2)
      ib_write_id(writer, d)
      ib_write_span(writer, s)
    }
    SelectedBoundInferredCallTarget(d, e, s) => {
      writer.write_byte(3)
      ib_write_id(writer, d)
      ib_write_int(writer, e)
      ib_write_span(writer, s)
    }
    SelectedDynamicTraitCallTarget(a, b, c, d) => {
      writer.write_byte(4)
      ib_write_id(writer, a)
      ib_write_id(writer, b)
      ib_write_int(writer, c)
      ib_write_span(writer, d)
    }
    SelectedFunctionValueCallTarget(e) => {
      writer.write_byte(5)
      ib_write_int(writer, e)
    }
  }
}

///|
fn ib_read_call_target(
  reader : @cache_binary.Reader,
  field : String,
) -> InferredCallTarget {
  match reader.read_byte(field) {
    0 => NoInferredCallTarget
    1 => ErrorInferredCallTarget
    2 =>
      SelectedInferredCallTarget(
        ib_read_id(reader, field),
        ib_read_span(reader, field),
      )
    3 =>
      SelectedBoundInferredCallTarget(
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        ib_read_span(reader, field),
      )
    4 =>
      SelectedDynamicTraitCallTarget(
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
        ib_read_span(reader, field),
      )
    5 => SelectedFunctionValueCallTarget(ib_read_int(reader, field))
    _ => {
      reader.fail(field, "unknown call-target discriminant")
      NoInferredCallTarget
    }
  }
}

///|
fn ib_write_call_targets(
  writer : @cache_binary.Writer,
  values : Array[InferredCallTarget],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_call_target(writer, value)
  }
}

///|
fn ib_read_call_targets(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[InferredCallTarget] {
  let count = reader.read_count(inference_binary_maximum_items, field)
  let values : Array[InferredCallTarget] = []
  for _ in 0..<count {
    values.push(ib_read_call_target(reader, field))
  }
  values
}

///|
fn ib_write_evidence(
  writer : @cache_binary.Writer,
  value : InferredTraitEvidence,
) -> Unit {
  match value.kind {
    ConcreteInferredTraitEvidence(d, s) => {
      writer.write_byte(0)
      ib_write_id(writer, d)
      ib_write_span(writer, s)
    }
    BoundInferredTraitEvidence(i) => {
      writer.write_byte(1)
      ib_write_int(writer, i)
    }
  }
  ib_write_span(writer, value.prerequisites)
}

///|
fn ib_read_evidence(
  reader : @cache_binary.Reader,
  field : String,
) -> InferredTraitEvidence {
  let kind = match reader.read_byte(field) {
    0 =>
      ConcreteInferredTraitEvidence(
        ib_read_id(reader, field),
        ib_read_span(reader, field),
      )
    1 => BoundInferredTraitEvidence(ib_read_int(reader, field))
    _ => {
      reader.fail(field, "unknown evidence-kind discriminant")
      BoundInferredTraitEvidence(0)
    }
  }
  { kind, prerequisites: ib_read_span(reader, field) }
}

///|
fn ib_write_evidence_array(
  writer : @cache_binary.Writer,
  values : Array[InferredTraitEvidence],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_evidence(writer, value)
  }
}

///|
fn ib_read_evidence_array(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[InferredTraitEvidence] {
  let count = reader.read_count(inference_binary_maximum_items, field)
  let values : Array[InferredTraitEvidence] = []
  for _ in 0..<count {
    values.push(ib_read_evidence(reader, field))
  }
  values
}

///|
fn ib_write_evidence_argument(
  writer : @cache_binary.Writer,
  value : InferredTraitEvidenceArgument,
) -> Unit {
  match value {
    ShapeInferredTraitEvidenceArgument(s) => {
      writer.write_byte(0)
      ib_write_shape(writer, s)
    }
    GenericInferredTraitEvidenceArgument(i) => {
      writer.write_byte(1)
      ib_write_int(writer, i)
    }
  }
}

///|
fn ib_read_evidence_argument(
  reader : @cache_binary.Reader,
  field : String,
) -> InferredTraitEvidenceArgument {
  match reader.read_byte(field) {
    0 => ShapeInferredTraitEvidenceArgument(ib_read_shape(reader, field))
    1 => GenericInferredTraitEvidenceArgument(ib_read_int(reader, field))
    _ => {
      reader.fail(field, "unknown evidence-argument discriminant")
      GenericInferredTraitEvidenceArgument(0)
    }
  }
}

///|
fn ib_write_evidence_arguments(
  writer : @cache_binary.Writer,
  values : Array[InferredTraitEvidenceArgument],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_evidence_argument(writer, value)
  }
}

///|
fn ib_read_evidence_arguments(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[InferredTraitEvidenceArgument] {
  let count = reader.read_count(inference_binary_maximum_items, field)
  let values : Array[InferredTraitEvidenceArgument] = []
  for _ in 0..<count {
    values.push(ib_read_evidence_argument(reader, field))
  }
  values
}

///|
fn ib_write_inferred_body(
  writer : @cache_binary.Writer,
  value : InferredBody,
) -> Unit {
  ib_write_id(writer, value.body)
  ib_write_int(writer, value.root_type)
  ib_write_span(writer, value.types)
  ib_write_span(writer, value.type_arguments)
  ib_write_span(writer, value.diagnostics)
}

///|
fn ib_read_inferred_body(
  reader : @cache_binary.Reader,
  field : String,
) -> InferredBody {
  {
    body: ib_read_id(reader, field),
    root_type: ib_read_int(reader, field),
    types: ib_read_span(reader, field),
    type_arguments: ib_read_span(reader, field),
    diagnostics: ib_read_span(reader, field),
  }
}

///|
fn ib_write_inferred_bodies(
  writer : @cache_binary.Writer,
  values : Array[InferredBody],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_inferred_body(writer, value)
  }
}

///|
fn ib_read_inferred_bodies(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[InferredBody] {
  let count = reader.read_count(inference_binary_maximum_items, field)
  let values : Array[InferredBody] = []
  for _ in 0..<count {
    values.push(ib_read_inferred_body(reader, field))
  }
  values
}

///|
fn ib_write_inferred_lambda(
  writer : @cache_binary.Writer,
  value : InferredLambda,
) -> Unit {
  ib_write_int(writer, value.lambda)
  ib_write_int(writer, value.root_type)
  ib_write_span(writer, value.types)
  ib_write_span(writer, value.type_arguments)
  ib_write_span(writer, value.diagnostics)
}

///|
fn ib_read_inferred_lambda(
  reader : @cache_binary.Reader,
  field : String,
) -> InferredLambda {
  {
    lambda: ib_read_int(reader, field),
    root_type: ib_read_int(reader, field),
    types: ib_read_span(reader, field),
    type_arguments: ib_read_span(reader, field),
    diagnostics: ib_read_span(reader, field),
  }
}

///|
fn ib_write_inferred_lambdas(
  writer : @cache_binary.Writer,
  values : Array[InferredLambda],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_inferred_lambda(writer, value)
  }
}

///|
fn ib_read_inferred_lambdas(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[InferredLambda] {
  let count = reader.read_count(inference_binary_maximum_items, field)
  let values : Array[InferredLambda] = []
  for _ in 0..<count {
    values.push(ib_read_inferred_lambda(reader, field))
  }
  values
}

///|
fn ib_write_module_bodies(
  writer : @cache_binary.Writer,
  value : InferredModuleBodies,
) -> Unit {
  ib_write_id(writer, value.module_id)
  ib_write_module_values(writer, value.module_values)
  ib_write_impl_index(writer, value.impl_index)
  ib_write_inferred_bodies(writer, value.bodies)
  ib_write_inferred_lambdas(writer, value.lambdas)
  ib_write_body_types(writer, value.types)
  ib_write_int_array(writer, value.type_arguments)
  ib_write_int_array(writer, value.expression_types)
  ib_write_int_array(writer, value.local_types)
  ib_write_int_array(writer, value.capture_types)
  ib_write_int_array(writer, value.block_types)
  ib_write_int_array(writer, value.pattern_types)
  ib_write_pattern_constructors(writer, value.pattern_constructors)
  ib_write_int_array(writer, value.pattern_type_arguments)
  ib_write_int_array(writer, value.control_state_types)
  ib_write_int_array(writer, value.control_result_types)
  ib_write_selections(writer, value.expression_selections)
  ib_write_int_array(writer, value.expression_type_arguments)
  ib_write_field_targets(writer, value.object_field_targets)
  ib_write_coercions(writer, value.trait_object_coercions)
  ib_write_call_targets(writer, value.call_targets)
  ib_write_call_targets(writer, value.operator_targets)
  ib_write_call_targets(writer, value.map_hash_targets)
  ib_write_call_targets(writer, value.map_eq_targets)
  ib_write_span_array(writer, value.expression_evidence)
  ib_write_int_array(writer, value.trait_evidence_roots)
  ib_write_evidence_array(writer, value.trait_evidence)
  ib_write_int_array(writer, value.trait_evidence_children)
  ib_write_evidence_arguments(writer, value.trait_evidence_arguments)
  ib_write_int_array(writer, value.call_type_arguments)
  ib_write_diagnostics(writer, value.diagnostics)
}

///|
fn ib_read_module_bodies(
  reader : @cache_binary.Reader,
  field : String,
) -> InferredModuleBodies {
  {
    module_id: ib_read_id(reader, field),
    module_values: ib_read_module_values(reader, field),
    impl_index: ib_read_impl_index(reader, field),
    bodies: ib_read_inferred_bodies(reader, field),
    lambdas: ib_read_inferred_lambdas(reader, field),
    types: ib_read_body_types(reader, field),
    type_arguments: ib_read_int_array(reader, field),
    expression_types: ib_read_int_array(reader, field),
    local_types: ib_read_int_array(reader, field),
    capture_types: ib_read_int_array(reader, field),
    block_types: ib_read_int_array(reader, field),
    pattern_types: ib_read_int_array(reader, field),
    pattern_constructors: ib_read_pattern_constructors(reader, field),
    pattern_type_arguments: ib_read_int_array(reader, field),
    control_state_types: ib_read_int_array(reader, field),
    control_result_types: ib_read_int_array(reader, field),
    expression_selections: ib_read_selections(reader, field),
    expression_type_arguments: ib_read_int_array(reader, field),
    object_field_targets: ib_read_field_targets(reader, field),
    trait_object_coercions: ib_read_coercions(reader, field),
    call_targets: ib_read_call_targets(reader, field),
    operator_targets: ib_read_call_targets(reader, field),
    map_hash_targets: ib_read_call_targets(reader, field),
    map_eq_targets: ib_read_call_targets(reader, field),
    expression_evidence: ib_read_span_array(reader, field),
    trait_evidence_roots: ib_read_int_array(reader, field),
    trait_evidence: ib_read_evidence_array(reader, field),
    trait_evidence_children: ib_read_int_array(reader, field),
    trait_evidence_arguments: ib_read_evidence_arguments(reader, field),
    call_type_arguments: ib_read_int_array(reader, field),
    diagnostics: ib_read_diagnostics(reader, field),
  }
}

///|
fn ib_span_valid(span : HirSpan, length : Int) -> Bool {
  span.start >= 0 &&
  span.length >= 0 &&
  span.start <= length &&
  span.length <= length - span.start
}

///|
fn ib_type_valid(type_ : BodyTypeId, length : Int) -> Bool {
  type_ <= 0 || type_ < length
}

///|
fn ib_types_valid(values : Array[BodyTypeId], length : Int) -> Bool {
  for value in values {
    if !ib_type_valid(value, length) {
      return false
    }
  }
  true
}

///|
fn ib_validate_type_graph(
  types : Array[BodyTypeTerm],
  arguments : Array[BodyTypeId],
) -> Bool {
  if types.length() == 0 || !(types[0] is BodyErrorType) {
    return false
  }
  for index, type_ in types {
    match type_ {
      BodyAppliedType(base, span) =>
        if !ib_type_valid(base, types.length()) ||
          !ib_span_valid(span, arguments.length()) {
          return false
        }
      BodyFunctionType(span, result) =>
        if !ib_type_valid(result, types.length()) ||
          !ib_span_valid(span, arguments.length()) {
          return false
        }
      BodyVariableType(_) if index == 0 => return false
      _ => ()
    }
  }
  ib_types_valid(arguments, types.length())
}

///|
fn ib_validate_module_bodies(value : InferredModuleBodies) -> Bool {
  if value.module_id != value.module_values.module_id ||
    value.module_id != value.impl_index.module_id ||
    value.module_id != value.module_values.dependencies.module_id {
    return false
  }
  if !ib_validate_type_graph(value.types, value.type_arguments) ||
    !ib_validate_type_graph(
      value.module_values.types,
      value.module_values.type_arguments,
    ) {
    return false
  }
  let type_length = value.types.length()
  for
    values in [
      value.expression_types,
      value.local_types,
      value.capture_types,
      value.block_types,
      value.pattern_types,
      value.pattern_type_arguments,
      value.control_state_types,
      value.control_result_types,
      value.expression_type_arguments,
      value.call_type_arguments,
    ] {
    if !ib_types_valid(values, type_length) {
      return false
    }
  }
  for body in value.bodies {
    if !ib_type_valid(body.root_type, type_length) ||
      !ib_span_valid(body.types, type_length) ||
      !ib_span_valid(body.type_arguments, value.type_arguments.length()) ||
      !ib_span_valid(body.diagnostics, value.diagnostics.length()) {
      return false
    }
  }
  for lambda in value.lambdas {
    if !ib_type_valid(lambda.root_type, type_length) ||
      !ib_span_valid(lambda.types, type_length) ||
      !ib_span_valid(lambda.type_arguments, value.type_arguments.length()) ||
      !ib_span_valid(lambda.diagnostics, value.diagnostics.length()) {
      return false
    }
  }
  for span in value.expression_evidence {
    if !ib_span_valid(span, value.trait_evidence_roots.length()) {
      return false
    }
  }
  for root in value.trait_evidence_roots {
    if root < 0 || root >= value.trait_evidence.length() {
      return false
    }
  }
  for child in value.trait_evidence_children {
    if child < 0 || child >= value.trait_evidence.length() {
      return false
    }
  }
  for evidence in value.trait_evidence {
    if !ib_span_valid(
        evidence.prerequisites,
        value.trait_evidence_children.length(),
      ) {
      return false
    }
    match evidence.kind {
      ConcreteInferredTraitEvidence(_, span) =>
        if !ib_span_valid(span, value.trait_evidence_arguments.length()) {
          return false
        }
      _ => ()
    }
  }
  true
}

///|
/// Serializes one complete inferred module directly as canonical V2 binary.
pub fn serialize_inferred_module_bodies(
  inferred : InferredModuleBodies,
) -> Result[Bytes, String] {
  let writer = @cache_binary.Writer::new(
    size_hint=inferred.expression_types.length() * 3 + 256,
  )
  writer.write_u32_le(inferred_module_payload_version)
  ib_write_module_bodies(writer, inferred)
  Ok(writer.to_bytes())
}

///|
pub fn deserialize_inferred_module_bodies(
  payload : Bytes,
) -> Result[InferredModuleBodies, String] {
  let reader = @cache_binary.Reader::new(
    payload,
    context="inferred_module_payload",
  )
  if reader.read_u32_le("version") != inferred_module_payload_version {
    return Err(
      "inferred_module_payload.version: unsupported inferred-module payload version",
    )
  }
  let value = ib_read_module_bodies(reader, "module")
  match reader.finish() {
    Err(error) => Err(error)
    Ok(_) if !ib_validate_module_bodies(value) =>
      Err(
        "inferred_module_payload.module: invalid inferred-module graph or span",
      )
    Ok(_) => Ok(value)
  }
}

///|
fn ib_write_job(
  writer : @cache_binary.Writer,
  value : BodyInferenceJobResult,
) -> Unit {
  ib_write_int(writer, value.result_type)
  ib_write_body_types(writer, value.types)
  ib_write_int_array(writer, value.type_arguments)
  ib_write_int_array(writer, value.expression_types)
  ib_write_int_array(writer, value.local_types)
  ib_write_int_array(writer, value.capture_types)
  ib_write_int_array(writer, value.block_types)
  ib_write_int_array(writer, value.pattern_types)
  ib_write_pattern_constructors(writer, value.pattern_constructors)
  ib_write_int_array(writer, value.pattern_type_arguments)
  ib_write_int_array(writer, value.control_state_types)
  ib_write_int_array(writer, value.control_result_types)
  ib_write_selections(writer, value.expression_selections)
  ib_write_int_array(writer, value.expression_type_arguments)
  ib_write_field_targets(writer, value.object_field_targets)
  ib_write_coercions(writer, value.trait_object_coercions)
  ib_write_int_array(writer, value.call_expressions)
  ib_write_call_targets(writer, value.call_targets)
  ib_write_call_targets(writer, value.operator_targets)
  ib_write_call_targets(writer, value.map_hash_targets)
  ib_write_call_targets(writer, value.map_eq_targets)
  ib_write_span_array(writer, value.expression_evidence)
  ib_write_int_array(writer, value.trait_evidence_roots)
  ib_write_evidence_array(writer, value.trait_evidence)
  ib_write_int_array(writer, value.trait_evidence_children)
  ib_write_evidence_arguments(writer, value.trait_evidence_arguments)
  ib_write_int_array(writer, value.call_type_arguments)
  ib_write_diagnostics(writer, value.diagnostics)
}

///|
fn ib_read_job(
  reader : @cache_binary.Reader,
  field : String,
) -> BodyInferenceJobResult {
  {
    result_type: ib_read_int(reader, field),
    types: ib_read_body_types(reader, field),
    type_arguments: ib_read_int_array(reader, field),
    expression_types: ib_read_int_array(reader, field),
    local_types: ib_read_int_array(reader, field),
    capture_types: ib_read_int_array(reader, field),
    block_types: ib_read_int_array(reader, field),
    pattern_types: ib_read_int_array(reader, field),
    pattern_constructors: ib_read_pattern_constructors(reader, field),
    pattern_type_arguments: ib_read_int_array(reader, field),
    control_state_types: ib_read_int_array(reader, field),
    control_result_types: ib_read_int_array(reader, field),
    expression_selections: ib_read_selections(reader, field),
    expression_type_arguments: ib_read_int_array(reader, field),
    object_field_targets: ib_read_field_targets(reader, field),
    trait_object_coercions: ib_read_coercions(reader, field),
    call_expressions: ib_read_int_array(reader, field),
    call_targets: ib_read_call_targets(reader, field),
    operator_targets: ib_read_call_targets(reader, field),
    map_hash_targets: ib_read_call_targets(reader, field),
    map_eq_targets: ib_read_call_targets(reader, field),
    expression_evidence: ib_read_span_array(reader, field),
    trait_evidence_roots: ib_read_int_array(reader, field),
    trait_evidence: ib_read_evidence_array(reader, field),
    trait_evidence_children: ib_read_int_array(reader, field),
    trait_evidence_arguments: ib_read_evidence_arguments(reader, field),
    call_type_arguments: ib_read_int_array(reader, field),
    diagnostics: ib_read_diagnostics(reader, field),
  }
}

///|
fn ib_write_family(
  writer : @cache_binary.Writer,
  value : BodyInferenceFamilyArtifact,
) -> Unit {
  ib_write_id(writer, value.module_id)
  ib_write_id(writer, value.body)
  ib_write_id(writer, value.declaration)
  ib_write_job(writer, value.root)
  writer.write_var_u64(value.lambdas.length().to_uint64())
  for lambda in value.lambdas {
    ib_write_int(writer, lambda.lambda)
    ib_write_job(writer, lambda.job)
  }
}

///|
fn ib_read_family(
  reader : @cache_binary.Reader,
  field : String,
) -> BodyInferenceFamilyArtifact {
  let module_id = ib_read_id(reader, field)
  let body = ib_read_id(reader, field)
  let declaration = ib_read_id(reader, field)
  let root = ib_read_job(reader, field)
  let count = reader.read_count(inference_binary_maximum_items, field)
  let lambdas : Array[BodyInferenceLambdaArtifact] = []
  for _ in 0..<count {
    let item = field
    lambdas.push({
      lambda: ib_read_int(reader, item + ".id"),
      job: ib_read_job(reader, item + ".job"),
    })
  }
  { module_id, body, declaration, root, lambdas }
}

///|
pub fn serialize_body_inference_family_artifact(
  artifact : BodyInferenceFamilyArtifact,
) -> Result[Bytes, String] {
  let writer = @cache_binary.Writer::new(size_hint=1024)
  writer.write_u32_le(inferred_family_payload_version)
  ib_write_family(writer, artifact)
  Ok(writer.to_bytes())
}

///|
pub fn deserialize_body_inference_family_artifact(
  payload : Bytes,
) -> Result[BodyInferenceFamilyArtifact, String] {
  let reader = @cache_binary.Reader::new(payload, context="body_family_payload")
  if reader.read_u32_le("version") != inferred_family_payload_version {
    return Err(
      "body_family_payload.version: unsupported family payload version",
    )
  }
  let value = ib_read_family(reader, "family")
  match reader.finish() {
    Err(error) => Err(error)
    Ok(_) => Ok(value)
  }
}

///|
fn ib_hex_nibble(value : Byte) -> Int {
  if value >= b'0' && value <= b'9' {
    value.to_int() - b'0'.to_int()
  } else if value >= b'a' && value <= b'f' {
    value.to_int() - b'a'.to_int() + 10
  } else {
    -1
  }
}

///|
fn ib_fingerprint_bytes(value : String) -> Bytes? {
  let source = @utf8.encode(value)
  if source.length() != 64 {
    return None
  }
  let output = Buffer(size_hint=32)
  for index in 0..<32 {
    let high = ib_hex_nibble(source[index * 2])
    let low = ib_hex_nibble(source[index * 2 + 1])
    if high < 0 || low < 0 {
      return None
    }
    output.write_byte((high * 16 + low).to_byte())
  }
  Some(output.to_bytes())
}

///|
fn ib_compare_digest_bytes(left : Bytes, right : Bytes) -> Int {
  for index in 0..<32 {
    let order = left[index].to_int() - right[index].to_int()
    if order != 0 {
      return order
    }
  }
  0
}

///|
/// Validated index over one family bundle. Family sections remain undecoded.
pub struct BodyInferenceFamilyBundleIndex {
  module_id : ModuleId
  fingerprints : Array[Bytes]
  offsets : Array[Int]
  lengths : Array[Int]
  payload : Bytes
  data_start : Int
}

///|
pub fn BodyInferenceFamilyBundleIndex::owner(
  self : BodyInferenceFamilyBundleIndex,
) -> ModuleId {
  self.module_id
}

///|
pub fn BodyInferenceFamilyBundleIndex::entry_count(
  self : BodyInferenceFamilyBundleIndex,
) -> Int {
  self.fingerprints.length()
}

///|
pub fn BodyInferenceFamilyBundleIndex::lookup(
  self : BodyInferenceFamilyBundleIndex,
  fingerprint : FixedArray[Byte],
) -> Result[BodyInferenceFamilyArtifact?, String] {
  if fingerprint.length() != 32 {
    return Err("family lookup fingerprint must be SHA-256")
  }
  let wanted_buffer = Buffer(size_hint=32)
  for byte in fingerprint {
    wanted_buffer.write_byte(byte)
  }
  let wanted = wanted_buffer.to_bytes()
  let mut lower = 0
  let mut upper = self.fingerprints.length()
  while lower < upper {
    let middle = lower + (upper - lower) / 2
    if ib_compare_digest_bytes(self.fingerprints[middle], wanted) < 0 {
      lower = middle + 1
    } else {
      upper = middle
    }
  }
  if lower >= self.fingerprints.length() ||
    ib_compare_digest_bytes(self.fingerprints[lower], wanted) != 0 {
    return Ok(None)
  }
  let start = self.data_start + self.offsets[lower]
  let length = self.lengths[lower]
  if start < self.data_start ||
    length < 0 ||
    start > self.payload.length() ||
    length > self.payload.length() - start {
    return Err("family bundle section range is invalid")
  }
  let section = Buffer(size_hint=length)
  for index in 0..<length {
    section.write_byte(self.payload[start + index])
  }
  match deserialize_body_inference_family_artifact(section.to_bytes()) {
    Ok(value) =>
      if value.module_id != self.module_id {
        Err("family bundle section ownership mismatch")
      } else {
        Ok(Some(value))
      }
    Err(error) => Err(error)
  }
}

///|
pub fn serialize_body_inference_family_bundle(
  bundle : BodyInferenceFamilyBundle,
) -> Result[Bytes, String] {
  match validate_body_inference_family_bundle(bundle) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let fingerprints : Array[Bytes] = []
  let sections : Array[Bytes] = []
  let offsets : Array[Int] = []
  let mut offset = 0
  for entry in bundle.entries {
    let fingerprint = match ib_fingerprint_bytes(entry.fingerprint) {
      Some(value) => value
      None => return Err("body-family bundle contains an invalid fingerprint")
    }
    let section = match
      serialize_body_inference_family_artifact(entry.artifact) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    fingerprints.push(fingerprint)
    sections.push(section)
    offsets.push(offset)
    if section.length() > inference_binary_maximum_section - offset {
      return Err("body-family bundle sections exceed size limit")
    }
    offset += section.length()
  }
  let writer = @cache_binary.Writer::new(
    size_hint=32 + fingerprints.length() * 48 + offset,
  )
  writer.write_u32_le(inferred_family_bundle_payload_version)
  ib_write_id(writer, bundle.module_id)
  writer.write_var_u64(fingerprints.length().to_uint64())
  for index, fingerprint in fingerprints {
    writer.write_raw(fingerprint)
    writer.write_u64_le(offsets[index].to_uint64())
    writer.write_u64_le(sections[index].length().to_uint64())
  }
  for section in sections {
    writer.write_raw(section)
  }
  Ok(writer.to_bytes())
}

///|
pub fn open_body_inference_family_bundle(
  payload : Bytes,
) -> Result[BodyInferenceFamilyBundleIndex, String] {
  let reader = @cache_binary.Reader::new(payload, context="body_family_bundle")
  if reader.read_u32_le("version") != inferred_family_bundle_payload_version {
    return Err("body_family_bundle.version: unsupported family bundle version")
  }
  let module_id = ib_read_id(reader, "module_id")
  let count = reader.read_count(inference_binary_maximum_items, "entry_count")
  let fingerprints : Array[Bytes] = []
  let raw_offsets : Array[UInt64] = []
  let raw_lengths : Array[UInt64] = []
  for index in 0..<count {
    let field = "entry[\{index}]"
    let fingerprint = reader.read_raw_bytes(32, 32, field)
    if index > 0 &&
      ib_compare_digest_bytes(fingerprints[index - 1], fingerprint) >= 0 {
      return Err(
        "body_family_bundle.entry: unordered or duplicate fingerprint index",
      )
    }
    fingerprints.push(fingerprint)
    raw_offsets.push(reader.read_u64_le(field))
    raw_lengths.push(reader.read_u64_le(field))
  }
  if reader.failed() {
    return Err("body_family_bundle.entry: truncated bundle index")
  }
  let data_start = reader.position()
  let data_length = payload.length() - data_start
  let offsets : Array[Int] = []
  let lengths : Array[Int] = []
  let mut expected_offset = 0UL
  for index in 0..<count {
    let offset = raw_offsets[index]
    let length = raw_lengths[index]
    if offset != expected_offset ||
      offset > data_length.to_uint64() ||
      length > data_length.to_uint64() - offset {
      return Err(
        "body_family_bundle.entry: invalid, overlapping, or backward section range",
      )
    }
    if offset > 0x7fffffffUL ||
      length > inference_binary_maximum_section.to_uint64() {
      return Err("body_family_bundle.entry: section range exceeds limit")
    }
    offsets.push(offset.to_int())
    lengths.push(length.to_int())
    expected_offset = offset + length
  }
  if expected_offset != data_length.to_uint64() {
    return Err("body_family_bundle: trailing or unindexed section bytes")
  }
  Ok({ module_id, fingerprints, offsets, lengths, payload, data_start })
}

///|
pub fn deserialize_body_inference_family_bundle(
  payload : Bytes,
) -> Result[BodyInferenceFamilyBundle, String] {
  let index = match open_body_inference_family_bundle(payload) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let entries : Array[BodyInferenceFamilyBundleEntry] = []
  for _, fingerprint in index.fingerprints {
    let digest : FixedArray[Byte] = FixedArray::make(32, 0)
    for byte_index in 0..<32 {
      digest[byte_index] = fingerprint[byte_index]
    }
    let artifact = match index.lookup(digest) {
      Ok(Some(value)) => value
      Ok(None) => return Err("body-family bundle index lookup failed")
      Err(error) => return Err(error)
    }
    entries.push({ fingerprint: @crypto.bytes_to_hex_string(digest), artifact })
  }
  Ok({ module_id: index.module_id, entries })
}
