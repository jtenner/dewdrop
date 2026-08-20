///|
pub enum PlannedValueShape {
  ErrorPlannedValueShape
  UnitPlannedValueShape
  I8PlannedValueShape
  I16PlannedValueShape
  I32PlannedValueShape
  I64PlannedValueShape
  U8PlannedValueShape
  U16PlannedValueShape
  U32PlannedValueShape
  U64PlannedValueShape
  F32PlannedValueShape
  F64PlannedValueShape
  Swar32PlannedValueShape
  Swar64PlannedValueShape
  V128PlannedValueShape
  RefPlannedValueShape
  GenericPlannedValueShape
  ProductPlannedValueShape(Array[PlannedValueShape])
  NeverPlannedValueShape
} derive(Eq, Debug, ToJson, FromJson)

///|
pub enum PlannedExpressionKind {
  PlannedPoisonExpression
  PlannedConsumedExpression
  PlannedI8Const(UInt64)
  PlannedI16Const(UInt64)
  PlannedI32Const(UInt64)
  PlannedI64Const(UInt64)
  PlannedU8Const(UInt64)
  PlannedU16Const(UInt64)
  PlannedU32Const(UInt64)
  PlannedU64Const(UInt64)
  PlannedF32Const(Float)
  PlannedF64Const(Double)
  PlannedBoolConst(Bool)
  PlannedStringConst(Bytes)
  PlannedBytesConst(Bytes)
  PlannedLocalGet(LocalId)
  PlannedLocalSet(LocalId, ExprId)
  PlannedCaptureGet(Int)
  PlannedCaptureSet(Int, ExprId)
  PlannedModuleValueGet(DeclId, DeclId)
  PlannedFunctionReference(DeclId, HirSpan)
  PlannedLambdaClosure(LambdaId, HirSpan)
  PlannedProductNew(HirSpan)
  PlannedArrayLiteral(HirSpan, BodyTypeId, PlannedValueShape)
  PlannedDirectLambdaCall(LambdaId, HirSpan, HirSpan)
  PlannedStructNew(DeclId, HirSpan, HirSpan)
  PlannedVariantTupleNew(VariantId, HirSpan, HirSpan)
  PlannedVariantStructNew(VariantId, HirSpan, HirSpan)
  PlannedUnitVariant(VariantId, HirSpan)
  PlannedPackedEnumPayload(Int, ExprId)
  PlannedBlockExpression(BlockId)
  PlannedIfExpression(ExprId, BlockId, ExprId)
  PlannedMatchExpression(ExprId, HirSpan)
  PlannedWhileExpression(ControlId, ExprId, HirSpan)
  PlannedBreakExpression(ControlId, ExprId)
  PlannedContinueExpression(ControlId, ExprId)
  PlannedPrefixExpression(HirPrefixOperator, ExprId)
  PlannedBinaryExpression(HirBinaryOperator, ExprId, ExprId)
  PlannedOperatorCall(DeclId, HirBinaryOperator, ExprId, ExprId, HirSpan)
  PlannedBoundOperatorCall(
    DeclId,
    Int,
    HirBinaryOperator,
    ExprId,
    ExprId,
    HirSpan
  )
  PlannedIndexCall(DeclId, ExprId, ExprId, HirSpan)
  PlannedIndexSetCall(DeclId, ExprId, ExprId, ExprId, HirSpan)
  PlannedWasmRefNull
  PlannedWasmRefIsNull(ExprId)
  PlannedWasmRefAsNonNull(ExprId)
  PlannedFixedArrayMake(ExprId, ExprId, PlannedValueShape)
  PlannedFixedArrayLength(ExprId, PlannedValueShape)
  PlannedFixedArrayGet(ExprId, ExprId, PlannedValueShape)
  PlannedFixedArrayGetUnchecked(ExprId, ExprId, PlannedValueShape)
  PlannedFixedArraySetUnchecked(ExprId, ExprId, ExprId, PlannedValueShape)
  PlannedArrayNew(BodyTypeId, PlannedValueShape)
  PlannedArrayWithCapacity(ExprId, BodyTypeId, PlannedValueShape)
  PlannedArrayLength(ExprId)
  PlannedArrayCapacity(ExprId)
  PlannedArrayGet(ExprId, ExprId, BodyTypeId, PlannedValueShape)
  PlannedArrayGetUnchecked(ExprId, ExprId, PlannedValueShape)
  PlannedArraySet(ExprId, ExprId, ExprId, PlannedValueShape)
  PlannedArraySetUnchecked(ExprId, ExprId, ExprId, PlannedValueShape)
  PlannedArrayPush(ExprId, ExprId, PlannedValueShape)
  PlannedArrayPop(ExprId, BodyTypeId, PlannedValueShape)
  PlannedArrayClear(ExprId, BodyTypeId, PlannedValueShape)
  PlannedArrayIter(ExprId, BodyTypeId, PlannedValueShape)
  PlannedArrayIterHasNext(ExprId)
  PlannedArrayIterNext(ExprId, PlannedValueShape)
  PlannedArrayIterNextOption(ExprId, BodyTypeId, PlannedValueShape)
  PlannedArrayMake(ExprId, ExprId, BodyTypeId, PlannedValueShape)
  PlannedArrayReserve(ExprId, ExprId, BodyTypeId, PlannedValueShape)
  PlannedArrayShrinkToFit(ExprId, BodyTypeId, PlannedValueShape)
  PlannedArrayTruncate(ExprId, ExprId, BodyTypeId, PlannedValueShape)
  PlannedArrayCopy(ExprId, BodyTypeId, PlannedValueShape)
  PlannedArrayCopyWithin(
    ExprId,
    ExprId,
    ExprId,
    ExprId,
    BodyTypeId,
    PlannedValueShape
  )
  PlannedArrayFill(
    ExprId,
    ExprId,
    ExprId,
    ExprId,
    BodyTypeId,
    PlannedValueShape
  )
  PlannedArraySlice(ExprId, ExprId, ExprId, BodyTypeId, PlannedValueShape)
  PlannedArrayExtend(ExprId, ExprId, BodyTypeId, PlannedValueShape)
  PlannedStackIsEmpty(ExprId)
  PlannedStackPeek(ExprId, PlannedValueShape)
  PlannedQueueDequeue(ExprId, PlannedValueShape)
  PlannedQueuePeek(ExprId, PlannedValueShape)
  PlannedCircularBufferNew(ExprId, PlannedValueShape, Bool)
  PlannedCircularBufferNewZero(PlannedValueShape)
  PlannedQueueRingEnqueue(ExprId, ExprId, PlannedValueShape)
  PlannedDequeRingPushFront(ExprId, ExprId, PlannedValueShape)
  PlannedCircularBufferCapacity(ExprId, PlannedValueShape)
  PlannedCircularBufferIsFull(ExprId, PlannedValueShape)
  PlannedCircularBufferPushBack(ExprId, ExprId, PlannedValueShape)
  PlannedCircularBufferPopFront(ExprId, PlannedValueShape)
  PlannedCircularBufferPeekFront(ExprId, PlannedValueShape)
  PlannedCircularBufferClear(ExprId, PlannedValueShape)
  PlannedCircularBufferIter(ExprId, PlannedValueShape)
  PlannedCircularBufferIterHasNext(ExprId)
  PlannedCircularBufferIterNext(ExprId, PlannedValueShape)
  PlannedCircularBufferPushFront(ExprId, ExprId, PlannedValueShape)
  PlannedCircularBufferPopBack(ExprId, PlannedValueShape)
  PlannedCircularBufferPeekBack(ExprId, PlannedValueShape)
  PlannedMapSingleton(
    ExprId,
    ExprId,
    PlannedValueShape,
    PlannedValueShape,
    DeclId,
    DeclId
  )
  PlannedMapEmpty(PlannedValueShape, PlannedValueShape, DeclId, DeclId)
  PlannedMapLength(ExprId)
  PlannedMapGet(
    ExprId,
    ExprId,
    PlannedValueShape,
    PlannedValueShape,
    DeclId,
    DeclId
  )
  PlannedMapGetUnchecked(
    ExprId,
    ExprId,
    PlannedValueShape,
    PlannedValueShape,
    DeclId,
    DeclId
  )
  PlannedMapInsert(
    ExprId,
    ExprId,
    ExprId,
    PlannedValueShape,
    PlannedValueShape,
    DeclId,
    DeclId
  )
  PlannedMapSet(
    ExprId,
    ExprId,
    ExprId,
    PlannedValueShape,
    PlannedValueShape,
    DeclId,
    DeclId
  )
  PlannedMapContainsKey(ExprId, ExprId, PlannedValueShape, DeclId, DeclId)
  PlannedMapRemove(ExprId, ExprId, PlannedValueShape, DeclId, DeclId)
  PlannedMapClear(ExprId)
  PlannedMapKeys(ExprId, PlannedValueShape, PlannedValueShape)
  PlannedMapValues(ExprId, PlannedValueShape, PlannedValueShape)
  PlannedMapEntries(ExprId, PlannedValueShape, PlannedValueShape)
  PlannedMapIterHasNext(ExprId, Int, PlannedValueShape, PlannedValueShape)
  PlannedMapKeyIterNext(ExprId, PlannedValueShape, PlannedValueShape)
  PlannedMapKeyIterNextOption(ExprId, PlannedValueShape, PlannedValueShape)
  PlannedMapValueIterNext(ExprId, PlannedValueShape, PlannedValueShape)
  PlannedMapValueIterNextOption(ExprId, PlannedValueShape, PlannedValueShape)
  PlannedMapEntryIterNext(ExprId, PlannedValueShape, PlannedValueShape)
  PlannedMapEntryIterNextOption(ExprId, PlannedValueShape, PlannedValueShape)
  PlannedMapEntryKey(ExprId, PlannedValueShape, PlannedValueShape)
  PlannedMapEntryValue(ExprId, PlannedValueShape, PlannedValueShape)
  PlannedSetEmpty(PlannedValueShape, DeclId, DeclId)
  PlannedSetSingleton(ExprId, PlannedValueShape, DeclId, DeclId)
  PlannedSetLength(ExprId)
  PlannedSetIsEmpty(ExprId)
  PlannedSetContains(ExprId, ExprId, PlannedValueShape, DeclId, DeclId)
  PlannedSetInsert(ExprId, ExprId, PlannedValueShape, DeclId, DeclId)
  PlannedSetRemove(ExprId, ExprId, PlannedValueShape, DeclId, DeclId)
  PlannedSetClear(ExprId)
  PlannedSetIter(ExprId, PlannedValueShape)
  PlannedSetIterHasNext(ExprId, PlannedValueShape)
  PlannedSetIterNext(ExprId, PlannedValueShape)
  PlannedSetIterNextOption(ExprId, PlannedValueShape)
  PlannedDirectCall(DeclId, ExprId, HirSpan, HirSpan)
  PlannedTailCall(DeclId, ExprId, HirSpan, HirSpan)
  PlannedBoundDirectCall(DeclId, Int, ExprId, HirSpan, HirSpan)
  PlannedParameterSelect(HirSpan, Int)
  PlannedFunctionValueCall(ExprId, HirSpan, ResolvedTypeId)
  PlannedDynamicTraitCall(DeclId, DeclId, Int, ExprId, HirSpan, HirSpan)
  PlannedFieldGet(FieldId, ExprId, Bool)
  PlannedProductField(ExprId, Int, Int)
  PlannedFieldSet(FieldId, ExprId, ExprId)
} derive(Eq, Debug)

///|
pub struct PlannedExpression {
  type_ : BodyTypeId
  shape : PlannedValueShape
  nominal : DeclId
  flow : BodyFlowSummary
  trait_object_coercion : InferredTraitObjectCoercion
  kind : PlannedExpressionKind
  offset : UInt64
} derive(Eq, Debug)

///|
pub enum PlannedBlockItemKind {
  PlannedLetItem(LocalId, Bool, ExprId)
  PlannedElidedLetItem(LocalId)
  PlannedReturnItem(ExprId)
  PlannedExpressionItem(ExprId)
} derive(Eq, Debug)

///|
pub struct PlannedBlockItem {
  kind : PlannedBlockItemKind
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedBlock {
  items : HirSpan
  flow : BodyFlowSummary
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedObjectField {
  field : FieldId
  value : ExprId
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedPattern {
  type_ : BodyTypeId
  shape : PlannedValueShape
  source : HirPattern
  reference : BodyPatternReference
  selected_constructor : InferredPatternConstructor
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedPatternField {
  name : String
  pattern : PatternId
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedPatternArm {
  pattern : PatternId
  guard_condition : ExprId
  body : ExprId
  flow : BodyFlowSummary
  offset : UInt64
} derive(Eq, Debug)

///|
pub enum LoweringPlanDiagnostic {
  UnsupportedIndexLowering(ExprId, UInt64)
} derive(Eq, Debug)

///|
pub fn LoweringPlanDiagnostic::offset(self : LoweringPlanDiagnostic) -> UInt64 {
  match self {
    UnsupportedIndexLowering(_, offset) => offset
  }
}

///|
pub struct PlannedLocal {
  body : BodyId
  lambda : LambdaId
  local_id : LocalId
  kind : BodyLocalKind
  mutable_ : Bool
  type_ : BodyTypeId
  shape : PlannedValueShape
  nominal : DeclId
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedCapture {
  lambda : LambdaId
  capture : Int
  source : LambdaCaptureSource
  mutable_ : Bool
  type_ : BodyTypeId
  shape : PlannedValueShape
  nominal : DeclId
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedLambdaLowering {
  lambda : LambdaId
  root_body : BodyId
  directized : Bool
  elided : Bool
  root : HirBodyRoot
  root_type : BodyTypeId
  root_shape : PlannedValueShape
  result_shape : PlannedValueShape
  flow : BodyFlowSummary
  locals : HirSpan
  captures : HirSpan
  expressions : HirSpan
  blocks : HirSpan
  patterns : HirSpan
  pattern_arms : HirSpan
  diagnostics : HirSpan
} derive(Eq, Debug)

///|
pub struct PlannedBodyLowering {
  body : BodyId
  declaration : DeclId
  kind : HirBodyKind
  root : HirBodyRoot
  root_type : BodyTypeId
  root_shape : PlannedValueShape
  result_shape : PlannedValueShape
  flow : BodyFlowSummary
  locals : HirSpan
  expressions : HirSpan
  blocks : HirSpan
  patterns : HirSpan
  pattern_arms : HirSpan
  diagnostics : HirSpan
} derive(Eq, Debug)

///|
fn planned_fixed_array_operation(
  declaration : DeclId,
) -> StandardBuiltinOperation {
  let intrinsic = standard_wasm_intrinsics_operation(declaration)
  if intrinsic != NoStandardBuiltinOperation {
    intrinsic
  } else {
    standard_fixed_array_operation(declaration)
  }
}

///|
pub struct PlannedModuleLowering {
  module_id : ModuleId
  type_layouts : PlannedModuleTypeLayouts
  initialization : PlannedModuleInitialization
  functions : PlannedModuleFunctions
  bodies : Array[PlannedBodyLowering]
  lambdas : Array[PlannedLambdaLowering]
  locals : Array[PlannedLocal]
  captures : Array[PlannedCapture]
  expressions : Array[PlannedExpression]
  blocks : Array[PlannedBlock]
  block_items : Array[PlannedBlockItem]
  object_fields : Array[PlannedObjectField]
  patterns : Array[PlannedPattern]
  pattern_fields : Array[PlannedPatternField]
  pattern_arms : Array[PlannedPatternArm]
  expression_children : Array[ExprId]
  pattern_children : Array[PatternId]
  arm_children : Array[PatternArmId]
  resolved_types : Array[ResolvedType]
  resolved_type_arguments : Array[ResolvedTypeId]
  types : Array[BodyTypeTerm]
  type_arguments : Array[BodyTypeId]
  expression_type_arguments : Array[BodyTypeId]
  expression_type_argument_shapes : Array[PlannedValueShape]
  call_type_arguments : Array[BodyTypeId]
  call_type_argument_shapes : Array[PlannedValueShape]
  expression_evidence : Array[HirSpan]
  trait_evidence_roots : Array[Int]
  trait_evidence : Array[InferredTraitEvidence]
  trait_evidence_children : Array[Int]
  trait_evidence_arguments : Array[InferredTraitEvidenceArgument]
  pattern_type_arguments : Array[BodyTypeId]
  flow_diagnostics : Array[BodyFlowDiagnostic]
  diagnostics : Array[LoweringPlanDiagnostic]
} derive(Eq, Debug)

///|
pub fn PlannedModuleLowering::lambda_body(
  self : PlannedModuleLowering,
  lambda : LambdaId,
) -> PlannedBodyLowering? {
  if lambda < 0 || lambda >= self.lambdas.length() {
    return None
  }
  let source = self.lambdas[lambda]
  let root_index = semantic_id_local(source.root_body)
  if root_index < 0 || root_index >= self.bodies.length() {
    return None
  }
  let root = self.bodies[root_index]
  Some({
    body: source.root_body,
    declaration: root.declaration,
    kind: root.kind,
    root: source.root,
    root_type: source.root_type,
    root_shape: source.root_shape,
    result_shape: source.result_shape,
    flow: source.flow,
    locals: source.locals,
    expressions: source.expressions,
    blocks: source.blocks,
    patterns: source.patterns,
    pattern_arms: source.pattern_arms,
    diagnostics: source.diagnostics,
  })
}

///|
priv struct BodyLoweringPlanJob {
  lambda : LambdaId
  body : PlannedBodyLowering
  expressions : Array[PlannedExpression]
  blocks : Array[PlannedBlock]
  block_items : Array[PlannedBlockItem]
  object_fields : Array[PlannedObjectField]
  patterns : Array[PlannedPattern]
  pattern_arms : Array[PlannedPatternArm]
  diagnostics : Array[LoweringPlanDiagnostic]
}

///|
fn planned_error_expression() -> PlannedExpression {
  {
    type_: 0,
    shape: ErrorPlannedValueShape,
    nominal: 0UL,
    flow: { outcomes: 0 },
    trait_object_coercion: NoInferredTraitObjectCoercion,
    kind: PlannedPoisonExpression,
    offset: 0UL,
  }
}

///|
fn planned_error_block_item() -> PlannedBlockItem {
  { kind: PlannedExpressionItem(-1), offset: 0UL }
}

///|
pub fn planned_value_shape_from_resolved_types(
  types : Array[ResolvedType],
  type_arguments : Array[ResolvedTypeId],
  root : ResolvedTypeId,
) -> PlannedValueShape {
  let mut current = root
  while true {
    match types[current] {
      ErrorType => return ErrorPlannedValueShape
      PrimitiveType(UnitType) => return UnitPlannedValueShape
      PrimitiveType(BoolType | I32Type) => return I32PlannedValueShape
      PrimitiveType(I8Type) => return I8PlannedValueShape
      PrimitiveType(I16Type) => return I16PlannedValueShape
      PrimitiveType(I64Type) => return I64PlannedValueShape
      PrimitiveType(U8Type) => return U8PlannedValueShape
      PrimitiveType(U16Type) => return U16PlannedValueShape
      PrimitiveType(U32Type) => return U32PlannedValueShape
      PrimitiveType(U64Type) => return U64PlannedValueShape
      PrimitiveType(Swar32Type | I8x4Type | U8x4Type | I16x2Type | U16x2Type) =>
        return Swar32PlannedValueShape
      PrimitiveType(
        Swar64Type
        | I8x8Type
        | U8x8Type
        | I16x4Type
        | U16x4Type
        | I32x2Type
        | U32x2Type
      ) => return Swar64PlannedValueShape
      PrimitiveType(F32Type) => return F32PlannedValueShape
      PrimitiveType(F64Type) => return F64PlannedValueShape
      PrimitiveType(
        V128Type
        | I8x16Type
        | U8x16Type
        | I16x8Type
        | U16x8Type
        | I32x4Type
        | U32x4Type
        | I64x2Type
        | U64x2Type
        | F32x4Type
        | F64x2Type
      ) => return V128PlannedValueShape
      PrimitiveType(
        StringType
        | BytesType
        | StringViewType
        | StringBuilderType
        | BytesBuilderType
      ) => return RefPlannedValueShape
      PrimitiveType(NeverType) => return NeverPlannedValueShape
      ProductType(fields) => {
        let shapes : Array[PlannedValueShape] = []
        for index in 0..<fields.length {
          shapes.push(
            planned_value_shape_from_resolved_types(
              types,
              type_arguments,
              type_arguments[fields.start + index],
            ),
          )
        }
        return ProductPlannedValueShape(shapes)
      }
      NominalType(_) | TraitType(_) | FunctionType(_, _) =>
        return RefPlannedValueShape
      GenericParameterType(_) | SelfType(_) => return GenericPlannedValueShape
      AppliedType(base, _) => current = base
    }
  }
  ErrorPlannedValueShape
}

///|
fn specialized_resolved_value_shape(
  lowering : PlannedModuleLowering,
  type_ : ResolvedTypeId,
  generic_parameters : HirSpan,
  shapes : Array[PlannedValueShape],
  shape_span : HirSpan,
  fallback : PlannedValueShape,
) -> PlannedValueShape {
  if type_ < 0 || type_ >= lowering.resolved_types.length() {
    return fallback
  }
  match lowering.resolved_types[type_] {
    GenericParameterType(parameter) => {
      let parameter_local = semantic_id_local(parameter)
      if parameter_local >= generic_parameters.start &&
        parameter_local < generic_parameters.start + generic_parameters.length {
        let relative = parameter_local - generic_parameters.start
        if relative >= 0 && relative < shape_span.length {
          return shapes[shape_span.start + relative]
        }
      }
      fallback
    }
    ProductType(fields) => {
      let fallback_fields = match fallback {
        ProductPlannedValueShape(values) => Some(values)
        _ => None
      }
      let result : Array[PlannedValueShape] = []
      for index in 0..<fields.length {
        let field_type = lowering.resolved_type_arguments[fields.start + index]
        let field_fallback = match fallback_fields {
          Some(values) if index < values.length() => values[index]
          _ =>
            planned_value_shape_from_resolved_types(
              lowering.resolved_types,
              lowering.resolved_type_arguments,
              field_type,
            )
        }
        result.push(
          specialized_resolved_value_shape(
            lowering, field_type, generic_parameters, shapes, shape_span, field_fallback,
          ),
        )
      }
      ProductPlannedValueShape(result)
    }
    _ => fallback
  }
}

///|
pub fn specialize_planned_body_value_shape(
  lowering : PlannedModuleLowering,
  type_ : BodyTypeId,
  fallback : PlannedValueShape,
  generic_parameters : HirSpan,
  shapes : Array[PlannedValueShape],
  shape_span : HirSpan,
) -> PlannedValueShape {
  if type_ < -1 {
    return specialized_resolved_value_shape(
      lowering,
      -type_ - 2,
      generic_parameters,
      shapes,
      shape_span,
      fallback,
    )
  }
  if type_ < 0 || type_ >= lowering.types.length() {
    return fallback
  }
  match lowering.types[type_] {
    BodyResolvedType(resolved_type) =>
      specialized_resolved_value_shape(
        lowering, resolved_type, generic_parameters, shapes, shape_span, fallback,
      )
    BodyProductType(fields) => {
      let fallback_fields = match fallback {
        ProductPlannedValueShape(values) => Some(values)
        _ => None
      }
      let result : Array[PlannedValueShape] = []
      for index in 0..<fields.length {
        let field_type = lowering.type_arguments[fields.start + index]
        let field_fallback = match fallback_fields {
          Some(values) if index < values.length() => values[index]
          _ => fallback
        }
        result.push(
          specialize_planned_body_value_shape(
            lowering, field_type, field_fallback, generic_parameters, shapes, shape_span,
          ),
        )
      }
      ProductPlannedValueShape(result)
    }
    _ => fallback
  }
}

///|
fn planned_resolved_value_shape(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
) -> PlannedValueShape {
  planned_value_shape_from_resolved_types(
    resolved.types,
    resolved.type_arguments,
    root,
  )
}

///|
fn planned_value_shape(
  resolved : ResolvedModuleTypes,
  inferred : InferredModuleBodies,
  root : BodyTypeId,
) -> PlannedValueShape {
  let mut type_ = root
  while true {
    match inferred.type_term(type_) {
      BodyErrorType => return ErrorPlannedValueShape
      BodyVariableType(_) => return ErrorPlannedValueShape
      BodyProductType(fields) => {
        let shapes : Array[PlannedValueShape] = []
        for index in 0..<fields.length {
          shapes.push(
            planned_value_shape(
              resolved,
              inferred,
              inferred.type_arguments[fields.start + index],
            ),
          )
        }
        return ProductPlannedValueShape(shapes)
      }
      BodyFunctionType(_, _) => return RefPlannedValueShape
      BodyAppliedType(base, _) => type_ = base
      BodyResolvedType(resolved_type) =>
        return planned_resolved_value_shape(resolved, resolved_type)
    }
  }
  ErrorPlannedValueShape
}

///|
fn planned_body_type_matches_resolved(
  resolved : ResolvedModuleTypes,
  inferred : InferredModuleBodies,
  body_type : BodyTypeId,
  resolved_type : ResolvedTypeId,
) -> Bool {
  if resolved_type < 0 || resolved_type >= resolved.types.length() {
    return false
  }
  match inferred.type_term(body_type) {
    BodyResolvedType(value) => value == resolved_type
    BodyProductType(body_fields) =>
      match resolved.types[resolved_type] {
        ProductType(resolved_fields) => {
          if body_fields.length != resolved_fields.length {
            return false
          }
          for index in 0..<body_fields.length {
            if !planned_body_type_matches_resolved(
                resolved,
                inferred,
                inferred.type_arguments[body_fields.start + index],
                resolved.type_arguments[resolved_fields.start + index],
              ) {
              return false
            }
          }
          true
        }
        _ => false
      }
    BodyFunctionType(body_parameters, body_result) =>
      match resolved.types[resolved_type] {
        FunctionType(resolved_parameters, resolved_result) => {
          if body_parameters.length != resolved_parameters.length {
            return false
          }
          for index in 0..<body_parameters.length {
            if !planned_body_type_matches_resolved(
                resolved,
                inferred,
                inferred.type_arguments[body_parameters.start + index],
                resolved.type_arguments[resolved_parameters.start + index],
              ) {
              return false
            }
          }
          planned_body_type_matches_resolved(
            resolved, inferred, body_result, resolved_result,
          )
        }
        _ => false
      }
    BodyAppliedType(body_base, body_arguments) =>
      match resolved.types[resolved_type] {
        AppliedType(resolved_base, resolved_arguments) => {
          if body_arguments.length != resolved_arguments.length ||
            !planned_body_type_matches_resolved(
              resolved, inferred, body_base, resolved_base,
            ) {
            return false
          }
          for index in 0..<body_arguments.length {
            if !planned_body_type_matches_resolved(
                resolved,
                inferred,
                inferred.type_arguments[body_arguments.start + index],
                resolved.type_arguments[resolved_arguments.start + index],
              ) {
              return false
            }
          }
          true
        }
        _ => false
      }
    BodyErrorType | BodyVariableType(_) => false
  }
}

///|
fn planned_function_type(
  resolved : ResolvedModuleTypes,
  inferred : InferredModuleBodies,
  type_ : BodyTypeId,
) -> ResolvedTypeId {
  match inferred.type_term(type_) {
    BodyResolvedType(resolved_type) =>
      match resolved.types[resolved_type] {
        FunctionType(_, _) => resolved_type
        _ => -1
      }
    BodyFunctionType(_, _) => {
      for index, candidate in resolved.types {
        match candidate {
          FunctionType(_, _) =>
            if planned_body_type_matches_resolved(
                resolved, inferred, type_, index,
              ) {
              return index
            }
          _ => ()
        }
      }
      -1
    }
    _ => -1
  }
}

///|
fn planned_nominal_declaration(
  resolved : ResolvedModuleTypes,
  inferred : InferredModuleBodies,
  root : BodyTypeId,
) -> DeclId {
  let mut body_type = root
  while true {
    match inferred.type_term(body_type) {
      BodyAppliedType(base, _) => body_type = base
      BodyResolvedType(root) => {
        let mut resolved_type = root
        while true {
          match resolved.types[resolved_type] {
            NominalType(declaration) => return declaration
            AppliedType(base, _) => resolved_type = base
            _ => return 0UL
          }
        }
      }
      BodyErrorType
      | BodyVariableType(_)
      | BodyProductType(_)
      | BodyFunctionType(_, _) => return 0UL
    }
  }
  0UL
}

///|
fn planned_module_value_declaration(
  collected : CollectedModule,
  name : NameId,
) -> DeclId {
  match collected.value_bindings.get(name) {
    Some(binding) =>
      if binding.kind == LetDecl && binding.head >= 0 {
        collected.value_binding_candidates[binding.head].declaration
      } else {
        0UL
      }
    None => 0UL
  }
}

///|
fn planned_call_receiver(
  collected : CollectedModule,
  expression : ExprId,
) -> ExprId {
  let target = match collected.expressions[expression] {
    HirCallExpr(target, _, _) => target
    _ => return -1
  }
  match collected.expressions[target] {
    HirFieldExpr(receiver, _, _) => receiver
    _ => -1
  }
}

///|
fn planned_array_element_type(
  resolved : ResolvedModuleTypes,
  inferred : InferredModuleBodies,
  expression : ExprId,
) -> BodyTypeId {
  match inferred.type_term(inferred.expression_types[expression]) {
    BodyAppliedType(_, arguments) if arguments.length == 1 =>
      inferred.type_arguments[arguments.start]
    BodyResolvedType(type_) =>
      match resolved.types[type_] {
        AppliedType(_, arguments) if arguments.length == 1 =>
          -resolved.type_arguments[arguments.start] - 2
        _ => 0
      }
    _ => 0
  }
}

///|
fn plan_expression_kind(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  names : ResolvedModuleNames,
  inferred : InferredModuleBodies,
  expression : ExprId,
  consumed : Bool,
  diagnostics : Array[LoweringPlanDiagnostic],
) -> PlannedExpressionKind {
  if consumed {
    return PlannedConsumedExpression
  }
  match inferred.expression_selections[expression] {
    ErrorExpressionSelection => return PlannedPoisonExpression
    StructConstructionSelection(declaration, type_arguments) =>
      match collected.expressions[expression] {
        HirObjectExpr(fields, _) | HirConstructExpr(_, fields, _) =>
          return PlannedStructNew(declaration, type_arguments, fields)
        _ => return PlannedPoisonExpression
      }
    VariantConstructionSelection(variant, type_arguments) =>
      match collected.expressions[expression] {
        HirCallExpr(_, arguments, _) =>
          return PlannedVariantTupleNew(variant, type_arguments, arguments)
        HirObjectExpr(fields, _) | HirConstructExpr(_, fields, _) =>
          return PlannedVariantStructNew(variant, type_arguments, fields)
        _ => return PlannedPoisonExpression
      }
    UnitVariantValueSelection(variant, type_arguments) =>
      return PlannedUnitVariant(variant, type_arguments)
    FieldAccessSelection(field, mutable_) =>
      match collected.expressions[expression] {
        HirFieldExpr(base, _, _) =>
          return PlannedFieldGet(field, base, mutable_)
        _ => return PlannedPoisonExpression
      }
    ImportedModuleValueSelection(declaration) =>
      return PlannedModuleValueGet(
        declaration,
        planned_nominal_declaration(
          resolved,
          inferred,
          inferred.expression_types[expression],
        ),
      )
    FunctionReferenceSelection(declaration, arguments) =>
      return PlannedFunctionReference(declaration, arguments)
    NoExpressionSelection => ()
  }
  match collected.expressions[expression] {
    HirI8Expr(value, _) => PlannedI8Const(value)
    HirI16Expr(value, _) => PlannedI16Const(value)
    HirI32Expr(value, _) => PlannedI32Const(value)
    HirI64Expr(value, _) => PlannedI64Const(value)
    HirU8Expr(value, _) => PlannedU8Const(value)
    HirU16Expr(value, _) => PlannedU16Const(value)
    HirU32Expr(value, _) => PlannedU32Const(value)
    HirU64Expr(value, _) => PlannedU64Const(value)
    HirF32Expr(value, _) => PlannedF32Const(value)
    HirF64Expr(value, _) => PlannedF64Const(value)
    HirBoolExpr(value, _) => PlannedBoolConst(value)
    HirStringExpr(value, _) => PlannedStringConst(value)
    HirBytesExpr(value, _) => PlannedBytesConst(value)
    HirAssignmentExpr(target, value, _) =>
      match collected.expressions[target] {
        HirFieldExpr(base, _, _) =>
          match inferred.expression_selections[target] {
            FieldAccessSelection(field, _) =>
              PlannedFieldSet(field, base, value)
            _ => PlannedPoisonExpression
          }
        _ =>
          match names.expression_references[target] {
            LocalNameReference(local_id) => PlannedLocalSet(local_id, value)
            LambdaCaptureNameReference(capture) =>
              PlannedCaptureSet(capture, value)
            _ => PlannedPoisonExpression
          }
      }
    HirNameExpr(_, _) =>
      match names.expression_references[expression] {
        LocalNameReference(local_id) => PlannedLocalGet(local_id)
        LambdaCaptureNameReference(capture) => PlannedCaptureGet(capture)
        ImportedValueNameReference(_) => PlannedPoisonExpression
        ImportedModuleValueNameReference(declaration) =>
          PlannedModuleValueGet(
            declaration,
            planned_nominal_declaration(
              resolved,
              inferred,
              inferred.expression_types[expression],
            ),
          )
        ModuleValueNameReference(value_name) => {
          let declaration = planned_module_value_declaration(
            collected, value_name,
          )
          if declaration == 0UL {
            PlannedPoisonExpression
          } else {
            PlannedModuleValueGet(
              declaration,
              planned_nominal_declaration(
                resolved,
                inferred,
                inferred.expression_types[expression],
              ),
            )
          }
        }
        ErrorNameReference => PlannedPoisonExpression
        PrimitiveTypeNameReference(_)
        | ModuleTypeNameReference(_)
        | ModuleTraitNameReference(_)
        | ImportedModuleNameReference(_)
        | ForeignLibraryNameReference(_)
        | VariantNameReference(_)
        | NoNameReference => PlannedConsumedExpression
      }
    HirImportAliasExpr(_, _) => PlannedConsumedExpression
    HirProductExpr(elements, _) => PlannedProductNew(elements)
    HirProductFieldExpr(base, index, arity, _) =>
      PlannedProductField(base, index, arity)
    HirArrayExpr(elements, _) => {
      let element_type = planned_array_element_type(
        resolved, inferred, expression,
      )
      PlannedArrayLiteral(
        elements,
        element_type,
        planned_value_shape(resolved, inferred, element_type),
      )
    }
    HirLambdaExpr(lambda, _) =>
      PlannedLambdaClosure(lambda, names.lambda(lambda).unwrap().captures)
    HirObjectExpr(_, _) | HirConstructExpr(_, _, _) => PlannedPoisonExpression
    HirBlockExpr(block, _) => PlannedBlockExpression(block)
    HirIfExpr(condition, then_block, else_expression, _) =>
      PlannedIfExpression(condition, then_block, else_expression)
    HirMatchExpr(scrutinee, arms, _) => PlannedMatchExpression(scrutinee, arms)
    HirWhileExpr(initial, arms, _) =>
      PlannedWhileExpression(
        names.expression_controls[expression],
        initial,
        arms,
      )
    HirBreakExpr(value, _) =>
      PlannedBreakExpression(names.transfer_targets[expression], value)
    HirContinueExpr(value, _) =>
      PlannedContinueExpression(names.transfer_targets[expression], value)
    HirPrefixExpr(operator, operand, _) =>
      PlannedPrefixExpression(operator, operand)
    HirBinaryExpr(operator, left, right, _) =>
      match inferred.operator_targets[expression] {
        SelectedInferredCallTarget(declaration, type_arguments) =>
          PlannedOperatorCall(
            declaration, operator, left, right, type_arguments,
          )
        SelectedBoundInferredCallTarget(requirement, evidence, type_arguments) =>
          PlannedBoundOperatorCall(
            requirement, evidence, operator, left, right, type_arguments,
          )
        NoInferredCallTarget => PlannedBinaryExpression(operator, left, right)
        ErrorInferredCallTarget
        | SelectedDynamicTraitCallTarget(_, _, _, _)
        | SelectedFunctionValueCallTarget(_) => PlannedPoisonExpression
      }
    HirCallExpr(_, arguments, _) =>
      match inferred.call_targets[expression] {
        SelectedInferredCallTarget(declaration, type_arguments) => {
          let receiver = if collected.foreign_function(declaration) is Some(_) {
            -1
          } else {
            planned_call_receiver(collected, expression)
          }
          let base = if receiver >= 0 {
            receiver
          } else if arguments.length > 0 {
            collected.expression_children[arguments.start]
          } else {
            -1
          }
          let key_offset = if receiver >= 0 { 0 } else { 1 }
          let key = if arguments.length > key_offset {
            collected.expression_children[arguments.start + key_offset]
          } else {
            -1
          }
          let value_offset = if receiver >= 0 { 1 } else { 2 }
          let value = if arguments.length > value_offset {
            collected.expression_children[arguments.start + value_offset]
          } else {
            -1
          }
          let element_type = if type_arguments.length > 0 {
            inferred.call_type_arguments[type_arguments.start]
          } else {
            -1
          }
          let element_shape = if type_arguments.length > 0 {
            planned_value_shape(
              resolved,
              inferred,
              inferred.call_type_arguments[type_arguments.start],
            )
          } else {
            ErrorPlannedValueShape
          }
          let hash_declaration = match inferred.map_hash_targets[expression] {
            SelectedInferredCallTarget(selected, _) => selected
            _ => 0UL
          }
          let eq_declaration = match inferred.map_eq_targets[expression] {
            SelectedInferredCallTarget(selected, _) => selected
            _ => 0UL
          }
          let key_shape = if type_arguments.length > 0 {
            planned_value_shape(
              resolved,
              inferred,
              inferred.call_type_arguments[type_arguments.start],
            )
          } else {
            ErrorPlannedValueShape
          }
          let map_value_shape = if type_arguments.length > 1 {
            planned_value_shape(
              resolved,
              inferred,
              inferred.call_type_arguments[type_arguments.start + 1],
            )
          } else {
            ErrorPlannedValueShape
          }
          let stack_or_array_operation = match
            standard_stack_operation(declaration) {
            StackNew => ArrayNew
            StackWithCapacity => ArrayWithCapacity
            StackLength => ArrayLength
            StackIsEmpty => StackIsEmpty
            StackPush => ArrayPush
            StackPop => ArrayPop
            StackPeek => StackPeek
            StackClear => ArrayClear
            StackIter => ArrayIter
            StackIterHasNext => ArrayIterHasNext
            StackIterNext => ArrayIterNext
            _ => standard_array_operation(declaration)
          }
          let array_operation = stack_or_array_operation
          let queue_or_circular_operation = match
            standard_queue_operation(declaration) {
            QueueNew => QueueNew
            QueueWithCapacity => CircularBufferGrowable
            QueueLength => CircularBufferLength
            QueueIsEmpty => CircularBufferIsEmpty
            QueueEnqueue => QueueEnqueue
            QueueDequeue => CircularBufferPopFront
            QueuePeek => CircularBufferPeekFront
            QueueClear => CircularBufferClear
            QueueIter => CircularBufferIter
            QueueIterHasNext => CircularBufferIterHasNext
            QueueIterNext => CircularBufferIterNext
            _ => standard_circular_buffer_operation(declaration)
          }
          let ring_operation = match standard_deque_operation(declaration) {
            DequeNew => QueueNew
            DequeWithCapacity => CircularBufferGrowable
            DequeLength => CircularBufferLength
            DequeCapacity => CircularBufferCapacity
            DequeIsEmpty => CircularBufferIsEmpty
            DequePushFront => DequePushFront
            DequePushBack => QueueEnqueue
            DequePopFront => CircularBufferPopFront
            DequePopBack => CircularBufferPopBack
            DequePeekFront => CircularBufferPeekFront
            DequePeekBack => CircularBufferPeekBack
            DequeClear => CircularBufferClear
            DequeIter => CircularBufferIter
            DequeIterHasNext => CircularBufferIterHasNext
            DequeIterNext => CircularBufferIterNext
            _ => queue_or_circular_operation
          }
          match ring_operation {
            QueueNew => PlannedCircularBufferNewZero(element_shape)
            QueueEnqueue =>
              PlannedQueueRingEnqueue(
                base,
                key,
                planned_value_shape(
                  resolved,
                  inferred,
                  inferred.expression_types[key],
                ),
              )
            DequePushFront =>
              PlannedDequeRingPushFront(
                base,
                key,
                planned_value_shape(
                  resolved,
                  inferred,
                  inferred.expression_types[key],
                ),
              )
            CircularBufferBounded =>
              PlannedCircularBufferNew(base, element_shape, false)
            CircularBufferGrowable =>
              PlannedCircularBufferNew(base, element_shape, true)
            CircularBufferLength => PlannedArrayLength(base)
            CircularBufferCapacity =>
              PlannedCircularBufferCapacity(base, element_shape)
            CircularBufferIsEmpty => PlannedStackIsEmpty(base)
            CircularBufferIsFull =>
              PlannedCircularBufferIsFull(base, element_shape)
            CircularBufferPushBack =>
              PlannedCircularBufferPushBack(
                base,
                key,
                planned_value_shape(
                  resolved,
                  inferred,
                  inferred.expression_types[key],
                ),
              )
            CircularBufferPopFront =>
              PlannedCircularBufferPopFront(base, element_shape)
            CircularBufferPeekFront =>
              PlannedCircularBufferPeekFront(base, element_shape)
            CircularBufferClear =>
              PlannedCircularBufferClear(base, element_shape)
            CircularBufferIter => PlannedCircularBufferIter(base, element_shape)
            CircularBufferIterHasNext => PlannedCircularBufferIterHasNext(base)
            CircularBufferIterNext =>
              PlannedCircularBufferIterNext(
                base,
                planned_value_shape(
                  resolved,
                  inferred,
                  inferred.expression_types[expression],
                ),
              )
            CircularBufferPushFront =>
              PlannedCircularBufferPushFront(
                base,
                key,
                planned_value_shape(
                  resolved,
                  inferred,
                  inferred.expression_types[key],
                ),
              )
            CircularBufferPopBack =>
              PlannedCircularBufferPopBack(base, element_shape)
            CircularBufferPeekBack =>
              PlannedCircularBufferPeekBack(base, element_shape)
            _ =>
              match planned_fixed_array_operation(declaration) {
                WasmRefNull => PlannedWasmRefNull
                WasmRefIsNull => PlannedWasmRefIsNull(base)
                WasmRefAsNonNull => PlannedWasmRefAsNonNull(base)
                WasmArrayNew | FixedArrayMake => {
                  let item = collected.expression_children[arguments.start + 1]
                  PlannedFixedArrayMake(
                    collected.expression_children[arguments.start],
                    item,
                    planned_value_shape(
                      resolved,
                      inferred,
                      inferred.expression_types[item],
                    ),
                  )
                }
                WasmArrayLen | FixedArrayLength =>
                  PlannedFixedArrayLength(base, element_shape)
                FixedArrayGet => PlannedFixedArrayGet(base, key, element_shape)
                WasmArrayGet | FixedArrayGetUnchecked =>
                  PlannedFixedArrayGetUnchecked(
                    base,
                    key,
                    planned_value_shape(
                      resolved,
                      inferred,
                      inferred.expression_types[expression],
                    ),
                  )
                WasmArraySet | FixedArraySet =>
                  PlannedFixedArraySetUnchecked(
                    base,
                    key,
                    value,
                    planned_value_shape(
                      resolved,
                      inferred,
                      inferred.expression_types[value],
                    ),
                  )
                _ =>
                  match array_operation {
                    ArrayNew => PlannedArrayNew(element_type, element_shape)
                    ArrayWithCapacity =>
                      PlannedArrayWithCapacity(
                        base, element_type, element_shape,
                      )
                    ArrayLength => PlannedArrayLength(base)
                    StackIsEmpty => PlannedStackIsEmpty(base)
                    ArrayCapacity => PlannedArrayCapacity(base)
                    ArrayGet =>
                      PlannedArrayGet(base, key, element_type, element_shape)
                    ArrayGetUnchecked =>
                      PlannedArrayGetUnchecked(
                        base,
                        key,
                        planned_value_shape(
                          resolved,
                          inferred,
                          inferred.expression_types[expression],
                        ),
                      )
                    ArraySet =>
                      PlannedArraySet(
                        base,
                        key,
                        value,
                        planned_value_shape(
                          resolved,
                          inferred,
                          inferred.expression_types[value],
                        ),
                      )
                    ArraySetUnchecked =>
                      PlannedArraySetUnchecked(
                        base,
                        key,
                        value,
                        planned_value_shape(
                          resolved,
                          inferred,
                          inferred.expression_types[value],
                        ),
                      )
                    ArrayPush =>
                      PlannedArrayPush(
                        base,
                        key,
                        planned_value_shape(
                          resolved,
                          inferred,
                          inferred.expression_types[key],
                        ),
                      )
                    ArrayPop =>
                      PlannedArrayPop(base, element_type, element_shape)
                    StackPeek => PlannedStackPeek(base, element_shape)
                    QueueDequeue => PlannedQueueDequeue(base, element_shape)
                    QueuePeek => PlannedQueuePeek(base, element_shape)
                    ArrayClear =>
                      PlannedArrayClear(base, element_type, element_shape)
                    ArrayIter =>
                      PlannedArrayIter(base, element_type, element_shape)
                    ArrayIterHasNext => PlannedArrayIterHasNext(base)
                    ArrayIterNext =>
                      PlannedArrayIterNext(
                        base,
                        planned_value_shape(
                          resolved,
                          inferred,
                          inferred.expression_types[expression],
                        ),
                      )
                    ArrayIterNextOption =>
                      PlannedArrayIterNextOption(
                        base, element_type, element_shape,
                      )
                    ArrayMake =>
                      PlannedArrayMake(
                        base,
                        key,
                        element_type,
                        planned_value_shape(
                          resolved,
                          inferred,
                          inferred.expression_types[key],
                        ),
                      )
                    ArrayReserve =>
                      PlannedArrayReserve(
                        base, key, element_type, element_shape,
                      )
                    ArrayShrinkToFit =>
                      PlannedArrayShrinkToFit(base, element_type, element_shape)
                    ArrayTruncate =>
                      PlannedArrayTruncate(
                        base, key, element_type, element_shape,
                      )
                    ArrayCopy =>
                      PlannedArrayCopy(base, element_type, element_shape)
                    ArrayCopyWithin =>
                      PlannedArrayCopyWithin(
                        base,
                        key,
                        value,
                        collected.expression_children[arguments.start + 3],
                        element_type,
                        element_shape,
                      )
                    ArrayFill =>
                      PlannedArrayFill(
                        base,
                        key,
                        value,
                        collected.expression_children[arguments.start + 3],
                        element_type,
                        planned_value_shape(
                          resolved,
                          inferred,
                          inferred.expression_types[key],
                        ),
                      )
                    ArraySlice =>
                      PlannedArraySlice(
                        base, key, value, element_type, element_shape,
                      )
                    ArrayExtend =>
                      PlannedArrayExtend(base, key, element_type, element_shape)
                    _ =>
                      match standard_map_operation(declaration) {
                        MapSingleton => {
                          let map_key = collected.expression_children[arguments.start]
                          let map_value = collected.expression_children[arguments.start +
                            1]
                          PlannedMapSingleton(
                            map_key, map_value, key_shape, map_value_shape, hash_declaration,
                            eq_declaration,
                          )
                        }
                        MapLength => PlannedMapLength(base)
                        MapGet =>
                          PlannedMapGet(
                            base, key, key_shape, map_value_shape, hash_declaration,
                            eq_declaration,
                          )
                        MapGetUnchecked =>
                          PlannedMapGetUnchecked(
                            base, key, key_shape, map_value_shape, hash_declaration,
                            eq_declaration,
                          )
                        MapInsert =>
                          PlannedMapInsert(
                            base, key, value, key_shape, map_value_shape, hash_declaration,
                            eq_declaration,
                          )
                        MapSet =>
                          PlannedMapSet(
                            base, key, value, key_shape, map_value_shape, hash_declaration,
                            eq_declaration,
                          )
                        MapContainsKey =>
                          PlannedMapContainsKey(
                            base, key, key_shape, hash_declaration, eq_declaration,
                          )
                        MapEmpty =>
                          PlannedMapEmpty(
                            key_shape, map_value_shape, hash_declaration, eq_declaration,
                          )
                        MapRemove =>
                          PlannedMapRemove(
                            base, key, key_shape, hash_declaration, eq_declaration,
                          )
                        MapClear => PlannedMapClear(base)
                        MapKeys =>
                          PlannedMapKeys(base, key_shape, map_value_shape)
                        MapValues =>
                          PlannedMapValues(base, key_shape, map_value_shape)
                        MapEntries =>
                          PlannedMapEntries(base, key_shape, map_value_shape)
                        MapKeyIterHasNext =>
                          PlannedMapIterHasNext(
                            base, 1, key_shape, map_value_shape,
                          )
                        MapValueIterHasNext =>
                          PlannedMapIterHasNext(
                            base, 2, key_shape, map_value_shape,
                          )
                        MapEntryIterHasNext =>
                          PlannedMapIterHasNext(
                            base, 3, key_shape, map_value_shape,
                          )
                        MapKeyIterNext =>
                          PlannedMapKeyIterNext(
                            base, key_shape, map_value_shape,
                          )
                        MapKeyIterNextOption =>
                          PlannedMapKeyIterNextOption(
                            base, key_shape, map_value_shape,
                          )
                        MapValueIterNext =>
                          PlannedMapValueIterNext(
                            base, key_shape, map_value_shape,
                          )
                        MapValueIterNextOption =>
                          PlannedMapValueIterNextOption(
                            base, key_shape, map_value_shape,
                          )
                        MapEntryIterNext =>
                          PlannedMapEntryIterNext(
                            base, key_shape, map_value_shape,
                          )
                        MapEntryIterNextOption =>
                          PlannedMapEntryIterNextOption(
                            base, key_shape, map_value_shape,
                          )
                        MapEntryKey =>
                          PlannedMapEntryKey(base, key_shape, map_value_shape)
                        MapEntryValue =>
                          PlannedMapEntryValue(base, key_shape, map_value_shape)
                        _ =>
                          match standard_set_operation(declaration) {
                            SetEmpty =>
                              PlannedSetEmpty(
                                key_shape, hash_declaration, eq_declaration,
                              )
                            SetSingleton =>
                              PlannedSetSingleton(
                                collected.expression_children[arguments.start],
                                key_shape,
                                hash_declaration,
                                eq_declaration,
                              )
                            SetLength => PlannedSetLength(base)
                            SetIsEmpty => PlannedSetIsEmpty(base)
                            SetContains =>
                              PlannedSetContains(
                                base, key, key_shape, hash_declaration, eq_declaration,
                              )
                            SetInsert =>
                              PlannedSetInsert(
                                base, key, key_shape, hash_declaration, eq_declaration,
                              )
                            SetRemove =>
                              PlannedSetRemove(
                                base, key, key_shape, hash_declaration, eq_declaration,
                              )
                            SetClear => PlannedSetClear(base)
                            SetIter => PlannedSetIter(base, key_shape)
                            SetIterHasNext =>
                              PlannedSetIterHasNext(base, key_shape)
                            SetIterNext => PlannedSetIterNext(base, key_shape)
                            SetIterNextOption =>
                              PlannedSetIterNextOption(base, key_shape)
                            _ =>
                              PlannedDirectCall(
                                declaration, receiver, arguments, type_arguments,
                              )
                          }
                      }
                  }
              }
          }
        }
        SelectedBoundInferredCallTarget(requirement, evidence, type_arguments) =>
          PlannedBoundDirectCall(
            requirement,
            evidence,
            planned_call_receiver(collected, expression),
            arguments,
            type_arguments,
          )
        SelectedFunctionValueCallTarget(target) =>
          PlannedFunctionValueCall(
            target,
            arguments,
            planned_function_type(
              resolved,
              inferred,
              inferred.expression_types[target],
            ),
          )
        SelectedDynamicTraitCallTarget(
          trait_,
          requirement,
          slot,
          type_arguments
        ) =>
          PlannedDynamicTraitCall(
            trait_,
            requirement,
            slot,
            planned_call_receiver(collected, expression),
            arguments,
            type_arguments,
          )
        NoInferredCallTarget | ErrorInferredCallTarget =>
          PlannedPoisonExpression
      }
    HirFieldExpr(_, _, _) | HirQualifiedExpr(_, _, _) =>
      PlannedConsumedExpression
    HirIndexExpr(base, index, offset) =>
      match inferred.operator_targets[expression] {
        SelectedInferredCallTarget(declaration, type_arguments) =>
          if standard_fixed_array_operation(declaration) ==
            FixedArrayGetUnchecked {
            PlannedFixedArrayGetUnchecked(
              base,
              index,
              planned_value_shape(
                resolved,
                inferred,
                inferred.expression_types[expression],
              ),
            )
          } else if standard_array_operation(declaration) == ArrayGetUnchecked {
            PlannedArrayGetUnchecked(
              base,
              index,
              planned_value_shape(
                resolved,
                inferred,
                inferred.expression_types[expression],
              ),
            )
          } else if standard_map_operation(declaration) == MapGetUnchecked {
            let hash_declaration = match inferred.map_hash_targets[expression] {
              SelectedInferredCallTarget(selected, _) => selected
              _ => 0UL
            }
            let eq_declaration = match inferred.map_eq_targets[expression] {
              SelectedInferredCallTarget(selected, _) => selected
              _ => 0UL
            }
            PlannedMapGetUnchecked(
              base,
              index,
              planned_value_shape(
                resolved,
                inferred,
                inferred.call_type_arguments[type_arguments.start],
              ),
              planned_value_shape(
                resolved,
                inferred,
                inferred.call_type_arguments[type_arguments.start + 1],
              ),
              hash_declaration,
              eq_declaration,
            )
          } else {
            PlannedIndexCall(declaration, base, index, type_arguments)
          }
        NoInferredCallTarget
        | ErrorInferredCallTarget
        | SelectedBoundInferredCallTarget(_, _, _)
        | SelectedDynamicTraitCallTarget(_, _, _, _)
        | SelectedFunctionValueCallTarget(_) => {
          diagnostics.push(UnsupportedIndexLowering(expression, offset))
          PlannedPoisonExpression
        }
      }
    HirIndexSetExpr(base, index, value, offset) =>
      match inferred.operator_targets[expression] {
        SelectedInferredCallTarget(declaration, type_arguments) =>
          if standard_fixed_array_operation(declaration) == FixedArraySet {
            PlannedFixedArraySetUnchecked(
              base,
              index,
              value,
              planned_value_shape(
                resolved,
                inferred,
                inferred.expression_types[value],
              ),
            )
          } else if standard_array_operation(declaration) == ArraySetUnchecked {
            PlannedArraySetUnchecked(
              base,
              index,
              value,
              planned_value_shape(
                resolved,
                inferred,
                inferred.expression_types[value],
              ),
            )
          } else if standard_map_operation(declaration) == MapSet {
            let hash_declaration = match inferred.map_hash_targets[expression] {
              SelectedInferredCallTarget(selected, _) => selected
              _ => 0UL
            }
            let eq_declaration = match inferred.map_eq_targets[expression] {
              SelectedInferredCallTarget(selected, _) => selected
              _ => 0UL
            }
            PlannedMapSet(
              base,
              index,
              value,
              planned_value_shape(
                resolved,
                inferred,
                inferred.call_type_arguments[type_arguments.start],
              ),
              planned_value_shape(
                resolved,
                inferred,
                inferred.call_type_arguments[type_arguments.start + 1],
              ),
              hash_declaration,
              eq_declaration,
            )
          } else {
            PlannedIndexSetCall(declaration, base, index, value, type_arguments)
          }
        NoInferredCallTarget
        | ErrorInferredCallTarget
        | SelectedBoundInferredCallTarget(_, _, _)
        | SelectedDynamicTraitCallTarget(_, _, _, _)
        | SelectedFunctionValueCallTarget(_) => {
          diagnostics.push(UnsupportedIndexLowering(expression, offset))
          PlannedPoisonExpression
        }
      }
  }
}

///|
fn plan_body_lowering_job(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  functions : PlannedModuleFunctions,
  names : ResolvedModuleNames,
  inferred : InferredModuleBodies,
  flows : AnalyzedModuleFlows,
  body : HirBody,
  lambda : LambdaId,
) -> BodyLoweringPlanJob {
  let diagnostics : Array[LoweringPlanDiagnostic] = []
  let consumed = Array::make(body.expressions.length, false)
  let expressions = Array::make(
    body.expressions.length,
    planned_error_expression(),
  )
  let mut expression = body.expressions.start + body.expressions.length
  while expression > body.expressions.start {
    expression -= 1
    let local_index = expression - body.expressions.start
    expressions[local_index] = {
      type_: inferred.expression_types[expression],
      shape: planned_value_shape(
        resolved,
        inferred,
        inferred.expression_types[expression],
      ),
      nominal: planned_nominal_declaration(
        resolved,
        inferred,
        inferred.expression_types[expression],
      ),
      flow: flows.expression_flows[expression],
      trait_object_coercion: inferred.trait_object_coercions[expression],
      kind: plan_expression_kind(
        collected,
        resolved,
        names,
        inferred,
        expression,
        consumed[local_index],
        diagnostics,
      ),
      offset: collected.expressions[expression].offset(),
    }
    match collected.expressions[expression] {
      HirCallExpr(target, _, _) =>
        match inferred.call_targets[expression] {
          SelectedFunctionValueCallTarget(_) => ()
          _ => consumed[target - body.expressions.start] = true
        }
      HirConstructExpr(target, _, _) =>
        consumed[target - body.expressions.start] = true
      HirQualifiedExpr(base, _, _) =>
        consumed[base - body.expressions.start] = true
      _ => ()
    }
  }
  let block_items : Array[PlannedBlockItem] = []
  for
    item in body.block_items.start..<(body.block_items.start +
    body.block_items.length) {
    let source = collected.block_items[item]
    block_items.push({
      kind: match source {
        HirLetItem(mutable_, _, _, value, _) =>
          PlannedLetItem(names.block_item_locals[item], mutable_, value)
        HirReturnItem(value, _) => PlannedReturnItem(value)
        HirExpressionItem(value, _) => PlannedExpressionItem(value)
      },
      offset: match source {
        HirLetItem(_, _, _, _, offset)
        | HirReturnItem(_, offset)
        | HirExpressionItem(_, offset) => offset
      },
    })
  }
  let blocks : Array[PlannedBlock] = []
  for block in body.blocks.start..<(body.blocks.start + body.blocks.length) {
    let source = collected.blocks[block]
    blocks.push({
      items: source.items,
      flow: flows.block_flows[block],
      offset: source.offset,
    })
  }
  let object_fields : Array[PlannedObjectField] = []
  for
    field in body.object_fields.start..<(body.object_fields.start +
    body.object_fields.length) {
    let source = collected.object_fields[field]
    let selected = match inferred.object_field_targets[field] {
      SelectedObjectFieldTarget(field) => field
      NoObjectFieldTarget | ErrorObjectFieldTarget => 0UL
    }
    object_fields.push({
      field: selected,
      value: source.value,
      offset: source.offset,
    })
  }
  let patterns : Array[PlannedPattern] = []
  for
    pattern in body.patterns.start..<(body.patterns.start + body.patterns.length) {
    patterns.push({
      type_: inferred.pattern_types[pattern],
      shape: planned_value_shape(
        resolved,
        inferred,
        inferred.pattern_types[pattern],
      ),
      source: collected.patterns[pattern],
      reference: names.pattern_references[pattern],
      selected_constructor: inferred.pattern_constructors[pattern],
      offset: collected.patterns[pattern].offset(),
    })
  }
  let pattern_arms : Array[PlannedPatternArm] = []
  for
    arm in body.pattern_arms.start..<(body.pattern_arms.start +
    body.pattern_arms.length) {
    let source = collected.pattern_arms[arm]
    pattern_arms.push({
      pattern: source.pattern,
      guard_condition: source.guard_condition,
      body: source.body,
      flow: flows.arm_flows[arm],
      offset: source.offset,
    })
  }
  let (root_type, root_flow, local_span) = if lambda >= 0 {
    (
      inferred.lambda(lambda).unwrap().root_type,
      flows.lambda(lambda).unwrap().flow,
      names.lambda(lambda).unwrap().locals,
    )
  } else {
    (
      inferred.bodies[semantic_id_local(body.id)].root_type,
      flows.bodies[semantic_id_local(body.id)].flow,
      names.body(body.id).unwrap().locals,
    )
  }
  let root_shape = planned_value_shape(resolved, inferred, root_type)
  let result_shape = if lambda >= 0 {
    planned_resolved_value_shape(resolved, resolved.lambda_return_types[lambda])
  } else {
    match functions.callable_of(body.declaration) {
      Some(callable) => callable.result_shape
      None => root_shape
    }
  }
  {
    lambda,
    body: {
      body: body.id,
      declaration: body.declaration,
      kind: body.kind,
      root: body.root,
      root_type,
      root_shape,
      result_shape,
      flow: root_flow,
      locals: local_span,
      expressions: body.expressions,
      blocks: body.blocks,
      patterns: body.patterns,
      pattern_arms: body.pattern_arms,
      diagnostics: { start: 0, length: diagnostics.length() },
    },
    expressions,
    blocks,
    block_items,
    object_fields,
    patterns,
    pattern_arms,
    diagnostics,
  }
}

///|
fn lowering_lambda_body(
  collected : CollectedModule,
  lambda : HirLambda,
) -> HirBody {
  let root = collected.bodies[semantic_id_local(lambda.root_body)]
  {
    id: lambda.root_body,
    declaration: root.declaration,
    kind: root.kind,
    root: BlockBodyRoot(lambda.body.root),
    expressions: lambda.body.expressions,
    expression_children: lambda.body.expression_children,
    blocks: lambda.body.blocks,
    block_items: lambda.body.block_items,
    patterns: lambda.body.patterns,
    pattern_children: lambda.body.pattern_children,
    pattern_arms: lambda.body.pattern_arms,
    arm_children: lambda.body.arm_children,
    object_fields: lambda.body.object_fields,
    pattern_fields: lambda.body.pattern_fields,
    offset: lambda.offset,
  }
}

///|
fn copy_body_lowering_job(
  target : PlannedModuleLowering,
  body : HirBody,
  job : BodyLoweringPlanJob,
  diagnostic_start : Int,
) -> Unit {
  for index, expression in job.expressions {
    target.expressions[body.expressions.start + index] = expression
  }
  for index, block in job.blocks {
    target.blocks[body.blocks.start + index] = block
  }
  for index, item in job.block_items {
    target.block_items[body.block_items.start + index] = item
  }
  for index, field in job.object_fields {
    target.object_fields[body.object_fields.start + index] = field
  }
  for index, pattern in job.patterns {
    target.patterns[body.patterns.start + index] = pattern
  }
  for index, arm in job.pattern_arms {
    target.pattern_arms[body.pattern_arms.start + index] = arm
  }
  if job.lambda >= 0 {
    let capture_span = target.lambdas[job.lambda].captures
    target.lambdas[job.lambda] = {
      lambda: job.lambda,
      root_body: target.lambdas[job.lambda].root_body,
      directized: target.lambdas[job.lambda].directized,
      elided: target.lambdas[job.lambda].elided,
      root: job.body.root,
      root_type: job.body.root_type,
      root_shape: job.body.root_shape,
      result_shape: job.body.result_shape,
      flow: job.body.flow,
      locals: job.body.locals,
      captures: capture_span,
      expressions: job.body.expressions,
      blocks: job.body.blocks,
      patterns: job.body.patterns,
      pattern_arms: job.body.pattern_arms,
      diagnostics: { start: diagnostic_start, length: job.diagnostics.length() },
    }
  } else {
    target.bodies[semantic_id_local(body.id)] = {
      body: job.body.body,
      declaration: job.body.declaration,
      kind: job.body.kind,
      root: job.body.root,
      root_type: job.body.root_type,
      root_shape: job.body.root_shape,
      result_shape: job.body.result_shape,
      flow: job.body.flow,
      locals: job.body.locals,
      expressions: job.body.expressions,
      blocks: job.body.blocks,
      patterns: job.body.patterns,
      pattern_arms: job.body.pattern_arms,
      diagnostics: { start: diagnostic_start, length: job.diagnostics.length() },
    }
  }
  for diagnostic in job.diagnostics {
    target.diagnostics.push(diagnostic)
  }
}

///|
fn directize_body_function_values(
  target : PlannedModuleLowering,
  body : PlannedBodyLowering,
  owner_lambda : LambdaId,
) -> Unit {
  let local_initializers = Array::make(body.locals.length, -1)
  let local_let_items = Array::make(body.locals.length, -1)
  for block in body.blocks.start..<(body.blocks.start + body.blocks.length) {
    let items = target.blocks[block].items
    for item in items.start..<(items.start + items.length) {
      match target.block_items[item].kind {
        PlannedLetItem(local_id, _, initializer) =>
          if local_id >= 0 && local_id < body.locals.length {
            local_initializers[local_id] = initializer
            local_let_items[local_id] = item
          }
        _ => ()
      }
    }
  }
  let captured_locals = Array::make(body.locals.length, false)
  for capture in target.captures {
    let captured_local = match capture.source {
      BodyLocalCapture(source_body, local_id) if owner_lambda < 0 &&
        source_body == body.body => local_id
      LambdaLocalCapture(source_lambda, local_id) if source_lambda ==
        owner_lambda => local_id
      _ => -1
    }
    if captured_local >= 0 && captured_local < captured_locals.length() {
      captured_locals[captured_local] = true
    }
  }
  let call_by_target = Array::make(target.expressions.length(), -1)
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match target.expressions[expression].kind {
      PlannedFunctionValueCall(call_target, _, _) =>
        if call_target >= 0 && call_target < call_by_target.length() {
          call_by_target[call_target] = expression
        }
      _ => ()
    }
  }
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match target.expressions[expression].kind {
      PlannedFunctionValueCall(call_target, arguments, _) if call_target >= 0 &&
        call_target < target.expressions.length() =>
        match target.expressions[call_target].kind {
          PlannedLambdaClosure(lambda, captures) => {
            let source = target.expressions[expression]
            target.expressions[expression] = {
              ..source,
              kind: PlannedDirectLambdaCall(lambda, captures, arguments),
            }
            let target_source = target.expressions[call_target]
            target.expressions[call_target] = {
              ..target_source,
              kind: PlannedConsumedExpression,
            }
            let lambda_source = target.lambdas[lambda]
            target.lambdas[lambda] = { ..lambda_source, directized: true }
          }
          _ => ()
        }
      _ => ()
    }
  }
  for local_id in 0..<body.locals.length {
    let initializer = local_initializers[local_id]
    let let_item = local_let_items[local_id]
    if initializer < 0 || let_item < 0 || captured_locals[local_id] {
      continue
    }
    let mut use_count = 0
    let mut all_uses_are_calls = true
    for
      expression in body.expressions.start..<(body.expressions.start +
      body.expressions.length) {
      match target.expressions[expression].kind {
        PlannedLocalGet(source_local) if source_local == local_id => {
          use_count += 1
          let call = call_by_target[expression]
          if call < 0 {
            all_uses_are_calls = false
          }
        }
        _ => ()
      }
    }
    let initializer_kind = target.expressions[initializer].kind
    if use_count == 0 {
      match initializer_kind {
        PlannedLambdaClosure(lambda, _) => {
          let lambda_source = target.lambdas[lambda]
          target.lambdas[lambda] = { ..lambda_source, elided: true }
        }
        PlannedFunctionReference(_, _) => ()
        _ => continue
      }
      let initializer_source = target.expressions[initializer]
      target.expressions[initializer] = {
        ..initializer_source,
        kind: PlannedConsumedExpression,
      }
      let item_source = target.block_items[let_item]
      target.block_items[let_item] = {
        ..item_source,
        kind: PlannedElidedLetItem(local_id),
      }
      continue
    }
    if !all_uses_are_calls {
      continue
    }
    match initializer_kind {
      PlannedLambdaClosure(lambda, captures) => {
        for
          expression in body.expressions.start..<(body.expressions.start +
          body.expressions.length) {
          match target.expressions[expression].kind {
            PlannedLocalGet(source_local) if source_local == local_id => {
              let call = call_by_target[expression]
              match target.expressions[call].kind {
                PlannedFunctionValueCall(_, arguments, _) => {
                  let call_source = target.expressions[call]
                  target.expressions[call] = {
                    ..call_source,
                    kind: PlannedDirectLambdaCall(lambda, captures, arguments),
                  }
                  let get_source = target.expressions[expression]
                  target.expressions[expression] = {
                    ..get_source,
                    kind: PlannedConsumedExpression,
                  }
                }
                _ => ()
              }
            }
            _ => ()
          }
        }
        let lambda_source = target.lambdas[lambda]
        target.lambdas[lambda] = { ..lambda_source, directized: true }
      }
      PlannedFunctionReference(declaration, type_arguments) =>
        for
          expression in body.expressions.start..<(body.expressions.start +
          body.expressions.length) {
          match target.expressions[expression].kind {
            PlannedLocalGet(source_local) if source_local == local_id => {
              let call = call_by_target[expression]
              match target.expressions[call].kind {
                PlannedFunctionValueCall(_, arguments, _) => {
                  let call_source = target.expressions[call]
                  target.expressions[call] = {
                    ..call_source,
                    kind: PlannedDirectCall(
                      declaration, -1, arguments, type_arguments,
                    ),
                  }
                  let get_source = target.expressions[expression]
                  target.expressions[expression] = {
                    ..get_source,
                    kind: PlannedConsumedExpression,
                  }
                }
                _ => ()
              }
            }
            _ => ()
          }
        }
      _ => continue
    }
    let initializer_source = target.expressions[initializer]
    target.expressions[initializer] = {
      ..initializer_source,
      kind: PlannedConsumedExpression,
    }
    let item_source = target.block_items[let_item]
    target.block_items[let_item] = {
      ..item_source,
      kind: PlannedElidedLetItem(local_id),
    }
  }
}

///|
fn directize_module_function_values(target : PlannedModuleLowering) -> Unit {
  for body in target.bodies {
    directize_body_function_values(target, body, -1)
  }
  for lambda in target.lambdas {
    match target.lambda_body(lambda.lambda) {
      Some(body) => directize_body_function_values(target, body, lambda.lambda)
      None => ()
    }
  }
}

///|
fn plan_module_lowering_in_order(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  type_layouts : PlannedModuleTypeLayouts,
  initialization : PlannedModuleInitialization,
  functions : PlannedModuleFunctions,
  names : ResolvedModuleNames,
  inferred : InferredModuleBodies,
  flows : AnalyzedModuleFlows,
  order : Array[Int],
) -> PlannedModuleLowering {
  if collected.module_id != resolved.module_id ||
    collected.module_id != type_layouts.module_id ||
    collected.module_id != initialization.module_id ||
    collected.module_id != functions.module_id ||
    collected.module_id != names.module_id ||
    collected.module_id != inferred.module_id ||
    collected.module_id != flows.module_id {
    abort("lowering plan inputs belong to different modules")
  }
  if order.length() != collected.bodies.length() {
    abort("lowering plan order does not cover every body")
  }
  let jobs : Array[BodyLoweringPlanJob?] = Array::make(
    collected.bodies.length(),
    None,
  )
  let seen = Array::make(collected.bodies.length(), false)
  for body_index in order {
    if body_index < 0 ||
      body_index >= collected.bodies.length() ||
      seen[body_index] {
      abort("invalid lowering plan body order")
    }
    seen[body_index] = true
    jobs[body_index] = Some(
      plan_body_lowering_job(
        collected,
        resolved,
        functions,
        names,
        inferred,
        flows,
        collected.bodies[body_index],
        -1,
      ),
    )
  }
  let lambda_jobs : Array[BodyLoweringPlanJob?] = Array::make(
    collected.lambdas.length(),
    None,
  )
  for index, lambda in collected.lambdas {
    lambda_jobs[index] = Some(
      plan_body_lowering_job(
        collected,
        resolved,
        functions,
        names,
        inferred,
        flows,
        lowering_lambda_body(collected, lambda),
        lambda.id,
      ),
    )
  }
  let planned_locals = Array::make(names.locals.length(), {
    body: 0UL,
    lambda: -1,
    local_id: -1,
    kind: ParameterLocal,
    mutable_: false,
    type_: 0,
    shape: ErrorPlannedValueShape,
    nominal: 0UL,
    offset: 0UL,
  })
  for body_info in names.bodies {
    for local_id in 0..<body_info.locals.length {
      let index = body_info.locals.start + local_id
      let source = names.locals[index]
      let type_ = inferred.local_types[index]
      planned_locals[index] = {
        body: body_info.body,
        lambda: -1,
        local_id: source.id,
        kind: source.kind,
        mutable_: source.mutable_,
        type_,
        shape: planned_value_shape(resolved, inferred, type_),
        nominal: planned_nominal_declaration(resolved, inferred, type_),
        offset: source.offset,
      }
    }
  }
  for lambda_info in names.lambdas {
    for local_id in 0..<lambda_info.locals.length {
      let index = lambda_info.locals.start + local_id
      let source = names.locals[index]
      let type_ = inferred.local_types[index]
      planned_locals[index] = {
        body: collected.lambdas[lambda_info.lambda].root_body,
        lambda: lambda_info.lambda,
        local_id: source.id,
        kind: source.kind,
        mutable_: source.mutable_,
        type_,
        shape: planned_value_shape(resolved, inferred, type_),
        nominal: planned_nominal_declaration(resolved, inferred, type_),
        offset: source.offset,
      }
    }
  }
  let planned_captures : Array[PlannedCapture] = []
  for lambda_info in names.lambdas {
    for capture in 0..<lambda_info.captures.length {
      let index = lambda_info.captures.start + capture
      let source = names.captures[index]
      let type_ = inferred.capture_types[index]
      planned_captures.push({
        lambda: lambda_info.lambda,
        capture,
        source: source.source,
        mutable_: source.mutable_,
        type_,
        shape: planned_value_shape(resolved, inferred, type_),
        nominal: planned_nominal_declaration(resolved, inferred, type_),
        offset: source.offset,
      })
    }
  }
  let target : PlannedModuleLowering = {
    module_id: collected.module_id,
    type_layouts,
    initialization,
    functions,
    bodies: Array::make(collected.bodies.length(), {
      body: 0UL,
      declaration: 0UL,
      kind: ModuleLetBody,
      root: ExpressionBodyRoot(-1),
      root_type: 0,
      root_shape: ErrorPlannedValueShape,
      result_shape: ErrorPlannedValueShape,
      flow: { outcomes: 0 },
      locals: { start: 0, length: 0 },
      expressions: { start: 0, length: 0 },
      blocks: { start: 0, length: 0 },
      patterns: { start: 0, length: 0 },
      pattern_arms: { start: 0, length: 0 },
      diagnostics: { start: 0, length: 0 },
    }),
    lambdas: names.lambdas.map(fn(info) {
      {
        lambda: info.lambda,
        root_body: collected.lambdas[info.lambda].root_body,
        directized: false,
        elided: false,
        root: BlockBodyRoot(collected.lambdas[info.lambda].body.root),
        root_type: 0,
        root_shape: ErrorPlannedValueShape,
        result_shape: ErrorPlannedValueShape,
        flow: { outcomes: 0 },
        locals: info.locals,
        captures: info.captures,
        expressions: collected.lambdas[info.lambda].body.expressions,
        blocks: collected.lambdas[info.lambda].body.blocks,
        patterns: collected.lambdas[info.lambda].body.patterns,
        pattern_arms: collected.lambdas[info.lambda].body.pattern_arms,
        diagnostics: { start: 0, length: 0 },
      }
    }),
    locals: planned_locals,
    captures: planned_captures,
    expressions: Array::make(
      collected.expressions.length(),
      planned_error_expression(),
    ),
    blocks: Array::make(collected.blocks.length(), {
      items: { start: 0, length: 0 },
      flow: { outcomes: 0 },
      offset: 0UL,
    }),
    block_items: Array::make(
      collected.block_items.length(),
      planned_error_block_item(),
    ),
    object_fields: Array::make(collected.object_fields.length(), {
      field: 0UL,
      value: -1,
      offset: 0UL,
    }),
    patterns: Array::make(collected.patterns.length(), {
      type_: 0,
      shape: ErrorPlannedValueShape,
      source: HirWildcardPattern(0UL),
      reference: NoPatternReference,
      selected_constructor: NoInferredPatternConstructor,
      offset: 0UL,
    }),
    pattern_fields: collected.pattern_fields.map(fn(field) {
      {
        name: collected.name(field.name),
        pattern: field.pattern,
        offset: field.offset,
      }
    }),
    pattern_arms: Array::make(collected.pattern_arms.length(), {
      pattern: -1,
      guard_condition: -1,
      body: -1,
      flow: { outcomes: 0 },
      offset: 0UL,
    }),
    expression_children: collected.expression_children,
    pattern_children: collected.pattern_children,
    arm_children: collected.arm_children,
    resolved_types: resolved.types,
    resolved_type_arguments: resolved.type_arguments,
    types: inferred.types,
    type_arguments: inferred.type_arguments,
    expression_type_arguments: inferred.expression_type_arguments,
    expression_type_argument_shapes: inferred.expression_type_arguments.map(fn(
      type_,
    ) {
      planned_value_shape(resolved, inferred, type_)
    }),
    call_type_arguments: inferred.call_type_arguments,
    call_type_argument_shapes: inferred.call_type_arguments.map(fn(type_) {
      planned_value_shape(resolved, inferred, type_)
    }),
    expression_evidence: inferred.expression_evidence,
    trait_evidence_roots: inferred.trait_evidence_roots,
    trait_evidence: inferred.trait_evidence,
    trait_evidence_children: inferred.trait_evidence_children,
    trait_evidence_arguments: inferred.trait_evidence_arguments,
    pattern_type_arguments: inferred.pattern_type_arguments,
    flow_diagnostics: flows.diagnostics,
    diagnostics: [],
  }
  for body_index in 0..<collected.bodies.length() {
    let job = jobs[body_index].unwrap()
    copy_body_lowering_job(
      target,
      collected.bodies[body_index],
      job,
      target.diagnostics.length(),
    )
  }
  for lambda_index, lambda in collected.lambdas {
    copy_body_lowering_job(
      target,
      lowering_lambda_body(collected, lambda),
      lambda_jobs[lambda_index].unwrap(),
      target.diagnostics.length(),
    )
  }
  directize_module_function_values(target)
  target
}

///|
pub fn plan_module_lowering(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  type_layouts : PlannedModuleTypeLayouts,
  initialization : PlannedModuleInitialization,
  functions : PlannedModuleFunctions,
  names : ResolvedModuleNames,
  inferred : InferredModuleBodies,
  flows : AnalyzedModuleFlows,
) -> PlannedModuleLowering {
  let order : Array[Int] = []
  for index in 0..<collected.bodies.length() {
    order.push(index)
  }
  plan_module_lowering_in_order(
    collected, resolved, type_layouts, initialization, functions, names, inferred,
    flows, order,
  )
}
