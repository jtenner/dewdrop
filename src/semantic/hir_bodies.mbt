///|
pub type ExprId = Int

///|
pub type PatternId = Int

///|
pub type BlockId = Int

///|
pub type PatternArmId = Int

///|
pub type LambdaId = Int

///|
pub enum HirBodyKind {
  ModuleLetBody
  FunctionBody
  ImplMethodBody
} derive(Eq, Debug)

///|
pub enum HirBodyRoot {
  ExpressionBodyRoot(ExprId)
  BlockBodyRoot(BlockId)
} derive(Eq, Debug)

///|
pub struct HirBody {
  id : BodyId
  declaration : DeclId
  kind : HirBodyKind
  root : HirBodyRoot
  expressions : HirSpan
  expression_children : HirSpan
  blocks : HirSpan
  block_items : HirSpan
  patterns : HirSpan
  pattern_children : HirSpan
  pattern_arms : HirSpan
  arm_children : HirSpan
  object_fields : HirSpan
  pattern_fields : HirSpan
  offset : UInt64
} derive(Eq, Debug)

///|
pub fn CollectedModule::body_of(
  self : CollectedModule,
  declaration : DeclId,
) -> HirBody? {
  if semantic_id_module(declaration) != self.module_id {
    return None
  }
  let local_index = semantic_id_local(declaration)
  if local_index < 0 || local_index >= self.body_by_declaration.length() {
    return None
  }
  let body_index = self.body_by_declaration[local_index]
  if body_index < 0 {
    None
  } else {
    Some(self.bodies[body_index])
  }
}

///|
pub struct HirLambdaParameter {
  name : NameId
  type_ : HirTypeId
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct HirLambdaBody {
  root : BlockId
  expressions : HirSpan
  expression_children : HirSpan
  blocks : HirSpan
  block_items : HirSpan
  patterns : HirSpan
  pattern_children : HirSpan
  pattern_arms : HirSpan
  arm_children : HirSpan
  object_fields : HirSpan
  pattern_fields : HirSpan
} derive(Eq, Debug)

///|
pub struct HirLambda {
  id : LambdaId
  parent : LambdaId
  root_body : BodyId
  parameters : HirSpan
  return_type : HirTypeId
  body : HirLambdaBody
  file : FileId
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct HirObjectField {
  name : NameId
  value : ExprId
  offset : UInt64
} derive(Eq, Debug)

///|
pub enum HirBlockItem {
  HirLetItem(Bool, NameId, UInt64, ExprId, UInt64)
  HirReturnItem(ExprId, UInt64)
  HirExpressionItem(ExprId, UInt64)
} derive(Eq, Debug)

///|
pub struct HirBlock {
  items : HirSpan
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct HirPatternField {
  name : NameId
  pattern : PatternId
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct HirPatternArm {
  pattern : PatternId
  guard_condition : ExprId
  body : ExprId
  offset : UInt64
} derive(Eq, Debug)

///|
pub enum HirPrefixOperator {
  HirPositive
  HirNegative
  HirLogicalNot
} derive(Eq, Debug)

///|
pub enum HirBinaryOperator {
  HirLogicalOr
  HirLogicalAnd
  HirBitOr
  HirBitXor
  HirBitAnd
  HirEqual
  HirNotEqual
  HirLess
  HirLessEqual
  HirGreater
  HirGreaterEqual
  HirShiftLeft
  HirShiftRight
  HirAdd
  HirSubtract
  HirMultiply
  HirDivide
  HirRemainder
  HirExponentiate
} derive(Eq, Debug)

///|
fn hir_prefix_operator(operator : @parser.PrefixOperator) -> HirPrefixOperator {
  match operator {
    @parser.Positive => HirPositive
    @parser.Negative => HirNegative
    @parser.LogicalNot => HirLogicalNot
  }
}

///|
fn hir_binary_operator(operator : @parser.BinaryOperator) -> HirBinaryOperator {
  match operator {
    @parser.LogicalOr => HirLogicalOr
    @parser.LogicalAnd => HirLogicalAnd
    @parser.BitOr => HirBitOr
    @parser.BitXor => HirBitXor
    @parser.BitAnd => HirBitAnd
    @parser.Equal => HirEqual
    @parser.NotEqual => HirNotEqual
    @parser.Less => HirLess
    @parser.LessEqual => HirLessEqual
    @parser.Greater => HirGreater
    @parser.GreaterEqual => HirGreaterEqual
    @parser.ShiftLeft => HirShiftLeft
    @parser.ShiftRight => HirShiftRight
    @parser.Add => HirAdd
    @parser.Subtract => HirSubtract
    @parser.Multiply => HirMultiply
    @parser.Divide => HirDivide
    @parser.Remainder => HirRemainder
    @parser.Exponentiate => HirExponentiate
  }
}

///|
pub enum HirExpr {
  HirI8Expr(UInt64, UInt64)
  HirI16Expr(UInt64, UInt64)
  HirI32Expr(UInt64, UInt64)
  HirI64Expr(UInt64, UInt64)
  HirU8Expr(UInt64, UInt64)
  HirU16Expr(UInt64, UInt64)
  HirU32Expr(UInt64, UInt64)
  HirU64Expr(UInt64, UInt64)
  HirF32Expr(Float, UInt64)
  HirF64Expr(Double, UInt64)
  HirBoolExpr(Bool, UInt64)
  HirStringExpr(Bytes, UInt64)
  HirBytesExpr(Bytes, UInt64)
  HirNameExpr(NameId, UInt64)
  HirImportAliasExpr(NameId, UInt64)
  HirProductExpr(HirSpan, UInt64)
  HirArrayExpr(HirSpan, UInt64)
  HirLambdaExpr(LambdaId, UInt64)
  HirObjectExpr(HirSpan, UInt64)
  HirConstructExpr(ExprId, HirSpan, UInt64)
  HirBlockExpr(BlockId, UInt64)
  HirIfExpr(ExprId, BlockId, ExprId, UInt64)
  HirMatchExpr(ExprId, HirSpan, UInt64)
  HirWhileExpr(ExprId, HirSpan, UInt64)
  HirBreakExpr(ExprId, UInt64)
  HirContinueExpr(ExprId, UInt64)
  HirPrefixExpr(HirPrefixOperator, ExprId, UInt64)
  HirBinaryExpr(HirBinaryOperator, ExprId, ExprId, UInt64)
  HirCallExpr(ExprId, HirSpan, UInt64)
  HirFieldExpr(ExprId, NameId, UInt64)
  HirQualifiedExpr(ExprId, NameId, UInt64)
  HirProductFieldExpr(ExprId, Int, Int, UInt64)
  HirIndexExpr(ExprId, ExprId, UInt64)
  HirAssignmentExpr(ExprId, ExprId, UInt64)
  HirIndexSetExpr(ExprId, ExprId, ExprId, UInt64)
} derive(Eq, Debug)

///|
pub fn HirExpr::offset(self : HirExpr) -> UInt64 {
  match self {
    HirI8Expr(_, offset)
    | HirI16Expr(_, offset)
    | HirI32Expr(_, offset)
    | HirI64Expr(_, offset)
    | HirU8Expr(_, offset)
    | HirU16Expr(_, offset)
    | HirU32Expr(_, offset)
    | HirU64Expr(_, offset)
    | HirF32Expr(_, offset)
    | HirF64Expr(_, offset)
    | HirBoolExpr(_, offset)
    | HirStringExpr(_, offset)
    | HirBytesExpr(_, offset)
    | HirNameExpr(_, offset)
    | HirImportAliasExpr(_, offset)
    | HirProductExpr(_, offset)
    | HirArrayExpr(_, offset)
    | HirLambdaExpr(_, offset)
    | HirObjectExpr(_, offset)
    | HirConstructExpr(_, _, offset)
    | HirIfExpr(_, _, _, offset)
    | HirMatchExpr(_, _, offset)
    | HirWhileExpr(_, _, offset)
    | HirBreakExpr(_, offset)
    | HirContinueExpr(_, offset)
    | HirPrefixExpr(_, _, offset)
    | HirBinaryExpr(_, _, _, offset)
    | HirCallExpr(_, _, offset)
    | HirFieldExpr(_, _, offset)
    | HirQualifiedExpr(_, _, offset)
    | HirProductFieldExpr(_, _, _, offset)
    | HirIndexExpr(_, _, offset)
    | HirAssignmentExpr(_, _, offset)
    | HirIndexSetExpr(_, _, _, offset)
    | HirBlockExpr(_, offset) => offset
  }
}

///|
pub enum HirPattern {
  HirWildcardPattern(UInt64)
  HirBindingPattern(NameId, UInt64)
  HirImportAliasPattern(NameId, UInt64)
  HirRestPattern(UInt64)
  HirLiteralPattern(ExprId, UInt64)
  HirQualifiedPattern(PatternId, NameId, UInt64)
  HirTuplePattern(PatternId, HirSpan, UInt64)
  HirStructPattern(PatternId, HirSpan, Bool, UInt64, UInt64)
  HirAlternativePattern(PatternId, HirSpan, UInt64)
} derive(Eq, Debug)

///|
pub fn HirPattern::offset(self : HirPattern) -> UInt64 {
  match self {
    HirWildcardPattern(offset)
    | HirBindingPattern(_, offset)
    | HirImportAliasPattern(_, offset)
    | HirRestPattern(offset)
    | HirLiteralPattern(_, offset)
    | HirQualifiedPattern(_, _, offset)
    | HirTuplePattern(_, _, offset)
    | HirStructPattern(_, _, _, _, offset)
    | HirAlternativePattern(_, _, offset) => offset
  }
}
