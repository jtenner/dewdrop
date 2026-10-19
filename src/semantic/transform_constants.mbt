///|
/// Values already proved and folded before physical planning.
pub enum CompileTimeTransformConstant {
  TransformBoolConstant(Bool)
  TransformU32Constant(UInt64)
  TransformStringsConstant(Array[Bytes])
  TransformUnitConstant
}

///|
fn transform_folded_constant(kind : PlannedExpressionKind) -> CompileTimeTransformConstant? {
  match kind {
    PlannedBoolConst(value) => Some(TransformBoolConstant(value))
    PlannedU32Const(value) => Some(TransformU32Constant(value))
    PlannedStringArrayConst(values) => Some(TransformStringsConstant(values))
    PlannedProductNew(span) if span.length == 0 => Some(TransformUnitConstant)
    _ => None
  }
}
