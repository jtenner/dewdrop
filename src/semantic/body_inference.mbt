///|
pub enum BodyInferenceDiagnostic {
  BodyConstraintDiagnostic(LocalInferenceDiagnostic)
  NumericLiteralOutOfRange(ExprId, PrimitiveType, UInt64)
  UnsupportedExpressionInference(ExprId, UInt64)
  InvalidCallTarget(ExprId, UInt64)
  InvalidAssignmentTarget(ExprId, UInt64)
  ImmutableAssignmentTarget(ExprId, UInt64)
  FunctionReferenceExpectedTypeRequired(NameId, ExprId, UInt64)
  NoMatchingFunctionReference(NameId, ExprId, UInt64)
  AmbiguousFunctionReference(NameId, ExprId, DeclId, DeclId, Int, UInt64)
  FunctionCallArgumentCountMismatch(ExprId, Int, Int, UInt64)
  CallArgumentCountMismatch(ExprId, DeclId, Int, Int, UInt64)
  NoMatchingCallOverload(NameId, ExprId, UInt64)
  AmbiguousCallOverload(NameId, ExprId, DeclId, DeclId, Int, UInt64)
  UnresolvedCallTypeArgument(ExprId, Int, UInt64)
  UnresolvedModuleValue(DeclId, UInt64)
  InvalidPatternConstructor(PatternId, UInt64)
  UnknownVariantForType(NameId, DeclId, PatternId, UInt64)
  AmbiguousPatternVariant(NameId, PatternId, VariantId, VariantId, Int, UInt64)
  PatternPayloadKindMismatch(PatternId, UInt64, UInt64)
  PatternPayloadArityMismatch(PatternId, Int, Int, UInt64)
  UnknownPatternField(NameId, PatternId, UInt64)
  MissingPatternField(NameId, PatternId, UInt64)
  MissingImportedPatternField(String, PatternId, UInt64)
  UnresolvedPatternTypeArgument(PatternId, Int, UInt64)
  InvalidConstructionTarget(ExprId, UInt64)
  ObjectTypeRequired(ExprId, UInt64)
  ConstructionPayloadKindMismatch(ExprId, UInt64, UInt64)
  ConstructionPayloadArityMismatch(ExprId, VariantId, Int, Int, UInt64)
  UnknownVariantValue(NameId, ExprId, UInt64)
  AmbiguousVariantValue(NameId, ExprId, VariantId, VariantId, Int, UInt64)
  DuplicateConstructionField(NameId, UInt64, UInt64)
  UnknownConstructionField(NameId, ExprId, UInt64)
  MissingConstructionField(NameId, ExprId, UInt64)
  FieldAccessRequiresNominal(ExprId, UInt64)
  UnknownFieldForType(NameId, DeclId, ExprId, UInt64)
  UnknownQualifiedMember(NameId, DeclId, ExprId, UInt64)
  UnknownImportedModuleMember(NameId, ExprId, UInt64)
  NoMatchingMethod(NameId, ExprId, UInt64)
  AmbiguousMethod(NameId, ExprId, DeclId, DeclId, Int, UInt64)
  UnresolvedExpressionTypeArgument(ExprId, Int, UInt64)
  ReturnOutsideCallable(UInt64)
  UnresolvedExpressionType(ExprId, UInt64)
  UnresolvedLocalType(BodyId, LocalId, UInt64)
  UnresolvedLambdaLocalType(LambdaId, LocalId, UInt64)
} derive(Eq, Debug)

///|
pub fn BodyInferenceDiagnostic::offset(
  self : BodyInferenceDiagnostic,
) -> UInt64 {
  match self {
    BodyConstraintDiagnostic(diagnostic) => diagnostic.offset()
    NumericLiteralOutOfRange(_, _, offset)
    | UnsupportedExpressionInference(_, offset)
    | InvalidCallTarget(_, offset)
    | InvalidAssignmentTarget(_, offset)
    | ImmutableAssignmentTarget(_, offset)
    | FunctionReferenceExpectedTypeRequired(_, _, offset)
    | NoMatchingFunctionReference(_, _, offset)
    | AmbiguousFunctionReference(_, _, _, _, _, offset)
    | FunctionCallArgumentCountMismatch(_, _, _, offset)
    | CallArgumentCountMismatch(_, _, _, _, offset)
    | NoMatchingCallOverload(_, _, offset)
    | AmbiguousCallOverload(_, _, _, _, _, offset)
    | UnresolvedCallTypeArgument(_, _, offset)
    | UnresolvedModuleValue(_, offset)
    | InvalidPatternConstructor(_, offset)
    | UnknownVariantForType(_, _, _, offset)
    | AmbiguousPatternVariant(_, _, _, _, _, offset)
    | PatternPayloadKindMismatch(_, _, offset)
    | PatternPayloadArityMismatch(_, _, _, offset)
    | UnknownPatternField(_, _, offset)
    | MissingPatternField(_, _, offset)
    | MissingImportedPatternField(_, _, offset)
    | UnresolvedPatternTypeArgument(_, _, offset)
    | InvalidConstructionTarget(_, offset)
    | ObjectTypeRequired(_, offset)
    | ConstructionPayloadKindMismatch(_, _, offset)
    | ConstructionPayloadArityMismatch(_, _, _, _, offset)
    | UnknownVariantValue(_, _, offset)
    | AmbiguousVariantValue(_, _, _, _, _, offset)
    | DuplicateConstructionField(_, _, offset)
    | UnknownConstructionField(_, _, offset)
    | MissingConstructionField(_, _, offset)
    | FieldAccessRequiresNominal(_, offset)
    | UnknownFieldForType(_, _, _, offset)
    | UnknownQualifiedMember(_, _, _, offset)
    | UnknownImportedModuleMember(_, _, offset)
    | NoMatchingMethod(_, _, offset)
    | AmbiguousMethod(_, _, _, _, _, offset)
    | UnresolvedExpressionTypeArgument(_, _, offset)
    | ReturnOutsideCallable(offset)
    | UnresolvedExpressionType(_, offset)
    | UnresolvedLocalType(_, _, offset)
    | UnresolvedLambdaLocalType(_, _, offset) => offset
  }
}

///|
pub struct InferredModuleValues {
  module_id : ModuleId
  dependencies : ModuleValueDependencies
  let_declarations : Array[DeclId]
  let_types : Array[BodyTypeId]
  types : Array[BodyTypeTerm]
  type_arguments : Array[BodyTypeId]
  diagnostics : Array[BodyInferenceDiagnostic]
} derive(Eq, Debug)

///|
pub fn InferredModuleValues::type_term(
  self : InferredModuleValues,
  type_ : BodyTypeId,
) -> BodyTypeTerm {
  if type_ < -1 {
    BodyResolvedType(-type_ - 2)
  } else if type_ >= 0 && type_ < self.types.length() {
    self.types[type_]
  } else {
    abort("invalid inferred module value type")
  }
}

///|
pub fn InferredModuleValues::arguments(
  self : InferredModuleValues,
  type_ : BodyTypeId,
) -> ArrayView[BodyTypeId] {
  match self.type_term(type_) {
    BodyAppliedType(_, span) =>
      self.type_arguments[span.start:span.start + span.length]
    _ => self.type_arguments[0:0]
  }
}

///|
pub enum InferredPatternConstructor {
  NoInferredPatternConstructor
  ErrorInferredPatternConstructor
  StructInferredPatternConstructor(DeclId, HirSpan)
  VariantInferredPatternConstructor(VariantId, HirSpan)
} derive(Eq, Debug)

///|
pub enum InferredObjectFieldTarget {
  NoObjectFieldTarget
  ErrorObjectFieldTarget
  SelectedObjectFieldTarget(FieldId)
} derive(Eq, Debug)

///|
pub enum InferredExpressionSelection {
  NoExpressionSelection
  ErrorExpressionSelection
  StructConstructionSelection(DeclId, HirSpan)
  VariantConstructionSelection(VariantId, HirSpan)
  UnitVariantValueSelection(VariantId, HirSpan)
  FieldAccessSelection(FieldId)
  ImportedModuleValueSelection(DeclId)
  FunctionReferenceSelection(DeclId, HirSpan)
} derive(Eq, Debug)

///|
pub enum InferredCallTarget {
  NoInferredCallTarget
  ErrorInferredCallTarget
  SelectedInferredCallTarget(DeclId, HirSpan)
  SelectedFunctionValueCallTarget(ExprId)
} derive(Eq, Debug)

///|
pub struct InferredBody {
  body : BodyId
  root_type : BodyTypeId
  types : HirSpan
  type_arguments : HirSpan
  diagnostics : HirSpan
} derive(Eq, Debug)

///|
pub struct InferredLambda {
  lambda : LambdaId
  root_type : BodyTypeId
  types : HirSpan
  type_arguments : HirSpan
  diagnostics : HirSpan
} derive(Eq, Debug)

///|
pub struct InferredModuleBodies {
  module_id : ModuleId
  module_values : InferredModuleValues
  impl_index : ModuleImplIndex
  bodies : Array[InferredBody]
  lambdas : Array[InferredLambda]
  types : Array[BodyTypeTerm]
  type_arguments : Array[BodyTypeId]
  expression_types : Array[BodyTypeId]
  local_types : Array[BodyTypeId]
  capture_types : Array[BodyTypeId]
  block_types : Array[BodyTypeId]
  pattern_types : Array[BodyTypeId]
  pattern_constructors : Array[InferredPatternConstructor]
  pattern_type_arguments : Array[BodyTypeId]
  control_state_types : Array[BodyTypeId]
  control_result_types : Array[BodyTypeId]
  expression_selections : Array[InferredExpressionSelection]
  expression_type_arguments : Array[BodyTypeId]
  object_field_targets : Array[InferredObjectFieldTarget]
  call_targets : Array[InferredCallTarget]
  operator_targets : Array[InferredCallTarget]
  map_hash_targets : Array[InferredCallTarget]
  map_eq_targets : Array[InferredCallTarget]
  call_type_arguments : Array[BodyTypeId]
  diagnostics : Array[BodyInferenceDiagnostic]
} derive(Eq, Debug)

///|
pub fn InferredModuleBodies::body(
  self : InferredModuleBodies,
  body : BodyId,
) -> InferredBody? {
  guard semantic_id_module(body) == self.module_id else { return None }
  let index = semantic_id_local(body)
  if index < 0 || index >= self.bodies.length() {
    None
  } else {
    Some(self.bodies[index])
  }
}

///|
pub fn InferredModuleBodies::lambda(
  self : InferredModuleBodies,
  lambda : LambdaId,
) -> InferredLambda? {
  if lambda < 0 || lambda >= self.lambdas.length() {
    None
  } else {
    Some(self.lambdas[lambda])
  }
}

///|
pub fn InferredModuleBodies::type_term(
  self : InferredModuleBodies,
  type_ : BodyTypeId,
) -> BodyTypeTerm {
  if type_ < -1 {
    BodyResolvedType(-type_ - 2)
  } else if type_ >= 0 && type_ < self.types.length() {
    self.types[type_]
  } else {
    abort("invalid inferred module body type")
  }
}

///|
pub fn InferredModuleBodies::arguments(
  self : InferredModuleBodies,
  type_ : BodyTypeId,
) -> ArrayView[BodyTypeId] {
  match self.type_term(type_) {
    BodyAppliedType(_, span) =>
      self.type_arguments[span.start:span.start + span.length]
    _ => self.type_arguments[0:0]
  }
}
