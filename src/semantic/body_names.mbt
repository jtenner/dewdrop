///|
pub type LocalId = Int

///|
pub type ControlId = Int

///|
pub enum BodyLocalKind {
  ParameterLocal
  LetLocal
  PatternLocal
} derive(Eq, Debug)

///|
pub struct BodyLocal {
  id : LocalId
  name : NameId
  kind : BodyLocalKind
  mutable_ : Bool
  source : Int
  offset : UInt64
} derive(Eq, Debug)

///|
pub enum BodyNameReference {
  NoNameReference
  ErrorNameReference
  LocalNameReference(LocalId)
  LambdaCaptureNameReference(Int)
  ModuleValueNameReference(NameId)
  ImportedValueNameReference(Int)
  ImportedModuleValueNameReference(DeclId)
  ImportedModuleNameReference(Int)
  PrimitiveTypeNameReference(PrimitiveType)
  ModuleTypeNameReference(DeclId)
  ModuleTraitNameReference(DeclId)
  VariantNameReference(NameId)
} derive(Eq, Debug)

///|
pub enum BodyPatternReference {
  NoPatternReference
  ErrorPatternReference
  PatternBindingReference(LocalId)
  PatternImportedModuleReference(Int)
  PatternTypeReference(DeclId)
  PatternTraitReference(DeclId)
  PatternVariantReference(NameId)
  PatternQualifiedReference(NameId)
} derive(Eq, Debug)

///|
pub enum BodyControlKind {
  FunctionalWhileControl
} derive(Eq, Debug)

///|
pub struct BodyControl {
  id : ControlId
  kind : BodyControlKind
  expression : ExprId
  offset : UInt64
} derive(Eq, Debug)

///|
pub enum BodyResolutionDiagnostic {
  UnknownValueName(NameId, ExprId, UInt64)
  AmbiguousImportedValueName(NameId, ExprId, UInt64)
  AmbiguousImportedQualifiedRoot(NameId, ExprId, UInt64)
  UnknownQualifiedRoot(NameId, ExprId, UInt64)
  UnknownImportAlias(NameId, ExprId, UInt64)
  UnknownPatternImportAlias(NameId, PatternId, UInt64)
  UnknownPatternConstructor(NameId, PatternId, UInt64)
  DuplicatePatternBinding(NameId, UInt64, UInt64)
  AlternativeMissingBinding(NameId, PatternId, UInt64)
  AlternativeExtraBinding(NameId, PatternId, UInt64)
  BreakOutsideLoop(ExprId, UInt64)
  ContinueOutsideLoop(ExprId, UInt64)
} derive(Eq, Debug)

///|
pub fn BodyResolutionDiagnostic::offset(
  self : BodyResolutionDiagnostic,
) -> UInt64 {
  match self {
    UnknownValueName(_, _, offset)
    | AmbiguousImportedValueName(_, _, offset)
    | AmbiguousImportedQualifiedRoot(_, _, offset)
    | UnknownQualifiedRoot(_, _, offset)
    | UnknownImportAlias(_, _, offset)
    | UnknownPatternImportAlias(_, _, offset)
    | UnknownPatternConstructor(_, _, offset)
    | AlternativeMissingBinding(_, _, offset)
    | AlternativeExtraBinding(_, _, offset)
    | BreakOutsideLoop(_, offset)
    | ContinueOutsideLoop(_, offset) => offset
    DuplicatePatternBinding(_, _, duplicate_offset) => duplicate_offset
  }
}

///|
pub struct ResolvedBodyNames {
  body : BodyId
  locals : HirSpan
  controls : HirSpan
  diagnostics : HirSpan
} derive(Eq, Debug)

///|
pub enum LambdaCaptureSource {
  BodyLocalCapture(BodyId, LocalId)
  LambdaLocalCapture(LambdaId, LocalId)
} derive(Eq, Debug)

///|
pub struct LambdaCapture {
  id : Int
  lambda : LambdaId
  name : NameId
  source : LambdaCaptureSource
  mutable_ : Bool
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct ResolvedLambdaNames {
  lambda : LambdaId
  locals : HirSpan
  controls : HirSpan
  captures : HirSpan
  diagnostics : HirSpan
} derive(Eq, Debug)

///|
pub struct ResolvedModuleNames {
  module_id : ModuleId
  bodies : Array[ResolvedBodyNames]
  lambdas : Array[ResolvedLambdaNames]
  locals : Array[BodyLocal]
  controls : Array[BodyControl]
  captures : Array[LambdaCapture]
  expression_references : Array[BodyNameReference]
  pattern_references : Array[BodyPatternReference]
  parameter_locals : Array[LocalId]
  lambda_parameter_locals : Array[LocalId]
  block_item_locals : Array[LocalId]
  transfer_targets : Array[ControlId]
  expression_controls : Array[ControlId]
  diagnostics : Array[BodyResolutionDiagnostic]
} derive(Eq, Debug)

///|
pub fn ResolvedModuleNames::body(
  self : ResolvedModuleNames,
  body : BodyId,
) -> ResolvedBodyNames? {
  guard semantic_id_module(body) == self.module_id else { return None }
  let index = semantic_id_local(body)
  if index < 0 || index >= self.bodies.length() {
    None
  } else {
    Some(self.bodies[index])
  }
}

///|
pub fn ResolvedModuleNames::lambda(
  self : ResolvedModuleNames,
  lambda : LambdaId,
) -> ResolvedLambdaNames? {
  if lambda < 0 || lambda >= self.lambdas.length() {
    None
  } else {
    Some(self.lambdas[lambda])
  }
}

///|
pub fn ResolvedModuleNames::local_info(
  self : ResolvedModuleNames,
  body : BodyId,
  local_id : LocalId,
) -> BodyLocal? {
  match self.body(body) {
    Some(info) =>
      if local_id < 0 || local_id >= info.locals.length {
        None
      } else {
        Some(self.locals[info.locals.start + local_id])
      }
    None => None
  }
}

///|
pub fn ResolvedModuleNames::lambda_local_info(
  self : ResolvedModuleNames,
  lambda : LambdaId,
  local_id : LocalId,
) -> BodyLocal? {
  match self.lambda(lambda) {
    Some(info) =>
      if local_id < 0 || local_id >= info.locals.length {
        None
      } else {
        Some(self.locals[info.locals.start + local_id])
      }
    None => None
  }
}

///|
pub fn ResolvedModuleNames::lambda_capture(
  self : ResolvedModuleNames,
  lambda : LambdaId,
  capture : Int,
) -> LambdaCapture? {
  match self.lambda(lambda) {
    Some(info) =>
      if capture < 0 || capture >= info.captures.length {
        None
      } else {
        Some(self.captures[info.captures.start + capture])
      }
    None => None
  }
}

///|
pub fn ResolvedModuleNames::control(
  self : ResolvedModuleNames,
  body : BodyId,
  control : ControlId,
) -> BodyControl? {
  match self.body(body) {
    Some(info) =>
      if control < 0 || control >= info.controls.length {
        None
      } else {
        Some(self.controls[info.controls.start + control])
      }
    None => None
  }
}
