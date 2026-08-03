///|
pub type BodyTypeId = Int

///|
pub type TypeVariableId = Int

///|
pub enum BodyTypeTerm {
  BodyErrorType
  BodyResolvedType(ResolvedTypeId)
  BodyVariableType(TypeVariableId)
  BodyAppliedType(BodyTypeId, HirSpan)
  BodyFunctionType(HirSpan, BodyTypeId)
} derive(Eq, Debug)

///|
pub enum TypeConstraintOriginKind {
  ExpressionTypeConstraint
  PatternTypeConstraint
  LocalTypeConstraint
  ReturnTypeConstraint
  CallTypeConstraint
  OperatorTypeConstraint
  SyntheticTypeConstraint
} derive(Eq, Debug)

///|
pub struct TypeConstraintOrigin {
  kind : TypeConstraintOriginKind
  source : Int
  offset : UInt64
} derive(Eq, Debug)

///|
pub enum LocalInferenceDiagnostic {
  LocalTypeMismatch(BodyTypeId, BodyTypeId, TypeConstraintOrigin)
  InfiniteLocalType(TypeVariableId, BodyTypeId, TypeConstraintOrigin)
} derive(Eq, Debug)

///|
pub fn LocalInferenceDiagnostic::offset(
  self : LocalInferenceDiagnostic,
) -> UInt64 {
  match self {
    LocalTypeMismatch(_, _, origin) | InfiniteLocalType(_, _, origin) =>
      origin.offset
  }
}

///|
pub fn expression_type_origin(
  source : Int,
  offset : UInt64,
) -> TypeConstraintOrigin {
  { kind: ExpressionTypeConstraint, source, offset }
}

///|
pub fn pattern_type_origin(
  source : Int,
  offset : UInt64,
) -> TypeConstraintOrigin {
  { kind: PatternTypeConstraint, source, offset }
}

///|
pub fn local_type_origin(source : Int, offset : UInt64) -> TypeConstraintOrigin {
  { kind: LocalTypeConstraint, source, offset }
}

///|
pub fn return_type_origin(
  source : Int,
  offset : UInt64,
) -> TypeConstraintOrigin {
  { kind: ReturnTypeConstraint, source, offset }
}

///|
pub fn call_type_origin(source : Int, offset : UInt64) -> TypeConstraintOrigin {
  { kind: CallTypeConstraint, source, offset }
}

///|
pub fn operator_type_origin(
  source : Int,
  offset : UInt64,
) -> TypeConstraintOrigin {
  { kind: OperatorTypeConstraint, source, offset }
}

///|
pub fn synthetic_type_origin(
  source : Int,
  offset : UInt64,
) -> TypeConstraintOrigin {
  { kind: SyntheticTypeConstraint, source, offset }
}
