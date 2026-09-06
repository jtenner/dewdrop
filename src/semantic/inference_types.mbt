///|
pub type BodyTypeId = Int

///|
pub type TypeVariableId = Int

///|
pub enum BodyTypeTerm {
  BodyErrorType
  BodyResolvedType(ResolvedTypeId)
  BodyVariableType(TypeVariableId)
  BodyProductType(HirSpan)
  BodyAppliedType(BodyTypeId, HirSpan)
  BodyFunctionType(HirSpan, BodyTypeId)
  BodyMemberTypeProjection(BodyTypeId, Bytes, String)
} derive(Eq, Debug, ToJson, FromJson)

///|
pub enum TypeConstraintOriginKind {
  ExpressionTypeConstraint
  PatternTypeConstraint
  LocalTypeConstraint
  ReturnTypeConstraint
  CallTypeConstraint
  OperatorTypeConstraint
  SyntheticTypeConstraint
} derive(Eq, Debug, ToJson, FromJson)

///|
pub struct TypeConstraintOrigin {
  kind : TypeConstraintOriginKind
  source : Int
  offset : UInt64
} derive(Eq, Debug, ToJson, FromJson)

///|
pub enum LocalInferenceDiagnostic {
  LocalTypeMismatch(BodyTypeId, BodyTypeId, TypeConstraintOrigin)
  InfiniteLocalType(TypeVariableId, BodyTypeId, TypeConstraintOrigin)
  InvalidLocalMemberProjection(BodyTypeId, String, TypeConstraintOrigin)
} derive(Eq, Debug, ToJson, FromJson)

///|
pub fn LocalInferenceDiagnostic::offset(
  self : LocalInferenceDiagnostic,
) -> UInt64 {
  match self {
    LocalTypeMismatch(_, _, origin)
    | InfiniteLocalType(_, _, origin)
    | InvalidLocalMemberProjection(_, _, origin) => origin.offset
  }
}

///|
fn expression_type_origin(
  source : Int,
  offset : UInt64,
) -> TypeConstraintOrigin {
  { kind: ExpressionTypeConstraint, source, offset, }
}

///|
fn pattern_type_origin(source : Int, offset : UInt64) -> TypeConstraintOrigin {
  { kind: PatternTypeConstraint, source, offset, }
}

///|
fn local_type_origin(source : Int, offset : UInt64) -> TypeConstraintOrigin {
  { kind: LocalTypeConstraint, source, offset, }
}

///|
fn return_type_origin(source : Int, offset : UInt64) -> TypeConstraintOrigin {
  { kind: ReturnTypeConstraint, source, offset, }
}

///|
fn call_type_origin(source : Int, offset : UInt64) -> TypeConstraintOrigin {
  { kind: CallTypeConstraint, source, offset, }
}

///|
fn operator_type_origin(source : Int, offset : UInt64) -> TypeConstraintOrigin {
  { kind: OperatorTypeConstraint, source, offset, }
}

///|
pub fn synthetic_type_origin(
  source : Int,
  offset : UInt64,
) -> TypeConstraintOrigin {
  { kind: SyntheticTypeConstraint, source, offset, }
}
