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
  NeverPlannedValueShape
} derive(Eq, Debug)

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
  PlannedModuleValueGet(DeclId, DeclId)
  PlannedStructNew(DeclId, HirSpan, HirSpan)
  PlannedVariantTupleNew(VariantId, HirSpan, HirSpan)
  PlannedVariantStructNew(VariantId, HirSpan, HirSpan)
  PlannedUnitVariant(VariantId, HirSpan)
  PlannedBlockExpression(BlockId)
  PlannedIfExpression(ExprId, BlockId, ExprId)
  PlannedMatchExpression(ExprId, HirSpan)
  PlannedWhileExpression(ControlId, ExprId, HirSpan)
  PlannedBreakExpression(ControlId, ExprId)
  PlannedContinueExpression(ControlId, ExprId)
  PlannedPrefixExpression(HirPrefixOperator, ExprId)
  PlannedBinaryExpression(HirBinaryOperator, ExprId, ExprId)
  PlannedOperatorCall(DeclId, HirBinaryOperator, ExprId, ExprId, HirSpan)
  PlannedIndexCall(DeclId, ExprId, ExprId, HirSpan)
  PlannedIndexSetCall(DeclId, ExprId, ExprId, ExprId, HirSpan)
  PlannedFixedArrayMake(ExprId, ExprId, PlannedValueShape)
  PlannedFixedArrayLength(ExprId, PlannedValueShape)
  PlannedFixedArrayGet(ExprId, ExprId, PlannedValueShape)
  PlannedFixedArrayGetUnchecked(ExprId, ExprId, PlannedValueShape)
  PlannedFixedArraySet(ExprId, ExprId, ExprId, PlannedValueShape)
  PlannedFixedArraySetUnchecked(ExprId, ExprId, ExprId, PlannedValueShape)
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
  PlannedSetEmpty(PlannedValueShape, DeclId, DeclId)
  PlannedSetSingleton(ExprId, PlannedValueShape, DeclId, DeclId)
  PlannedSetLength(ExprId)
  PlannedSetIsEmpty(ExprId)
  PlannedSetContains(ExprId, ExprId, PlannedValueShape, DeclId, DeclId)
  PlannedSetInsert(ExprId, ExprId, PlannedValueShape, DeclId, DeclId)
  PlannedSetRemove(ExprId, ExprId, PlannedValueShape, DeclId, DeclId)
  PlannedSetClear(ExprId)
  PlannedDirectCall(DeclId, ExprId, HirSpan, HirSpan)
  PlannedFieldGet(FieldId, ExprId)
} derive(Eq, Debug)

///|
pub struct PlannedExpression {
  type_ : BodyTypeId
  shape : PlannedValueShape
  flow : BodyFlowSummary
  kind : PlannedExpressionKind
  offset : UInt64
} derive(Eq, Debug)

///|
pub enum PlannedBlockItemKind {
  PlannedLetItem(LocalId, Bool, ExprId)
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
  local_id : LocalId
  kind : BodyLocalKind
  mutable_ : Bool
  type_ : BodyTypeId
  shape : PlannedValueShape
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedBodyLowering {
  body : BodyId
  declaration : DeclId
  kind : HirBodyKind
  root : HirBodyRoot
  root_type : BodyTypeId
  root_shape : PlannedValueShape
  flow : BodyFlowSummary
  locals : HirSpan
  expressions : HirSpan
  blocks : HirSpan
  patterns : HirSpan
  pattern_arms : HirSpan
  diagnostics : HirSpan
} derive(Eq, Debug)

///|
pub struct PlannedModuleLowering {
  module_id : ModuleId
  type_layouts : PlannedModuleTypeLayouts
  initialization : PlannedModuleInitialization
  functions : PlannedModuleFunctions
  bodies : Array[PlannedBodyLowering]
  locals : Array[PlannedLocal]
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
  expression_type_arguments : Array[BodyTypeId]
  call_type_arguments : Array[BodyTypeId]
  pattern_type_arguments : Array[BodyTypeId]
  diagnostics : Array[LoweringPlanDiagnostic]
} derive(Eq, Debug)

///|
priv struct BodyLoweringPlanJob {
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
    flow: { outcomes: 0 },
    kind: PlannedPoisonExpression,
    offset: 0UL,
  }
}

///|
fn planned_error_block_item() -> PlannedBlockItem {
  { kind: PlannedExpressionItem(-1), offset: 0UL }
}

///|
fn planned_resolved_value_shape(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
) -> PlannedValueShape {
  let mut current = root
  while true {
    match resolved.types[current] {
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
      NominalType(_) | TraitType(_) => return RefPlannedValueShape
      GenericParameterType(_) | SelfType(_) => return GenericPlannedValueShape
      AppliedType(base, _) => current = base
    }
  }
  ErrorPlannedValueShape
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
      BodyAppliedType(base, _) => type_ = base
      BodyResolvedType(resolved_type) =>
        return planned_resolved_value_shape(resolved, resolved_type)
    }
  }
  ErrorPlannedValueShape
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
      BodyErrorType | BodyVariableType(_) => return 0UL
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
    FieldAccessSelection(field) =>
      match collected.expressions[expression] {
        HirFieldExpr(base, _, _) => return PlannedFieldGet(field, base)
        _ => return PlannedPoisonExpression
      }
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
    HirNameExpr(_, _) =>
      match names.expression_references[expression] {
        LocalNameReference(local_id) => PlannedLocalGet(local_id)
        ImportedValueNameReference(_) => PlannedPoisonExpression
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
        | VariantNameReference(_)
        | NoNameReference => PlannedConsumedExpression
      }
    HirImportAliasExpr(_, _) => PlannedConsumedExpression
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
        NoInferredCallTarget => PlannedBinaryExpression(operator, left, right)
        ErrorInferredCallTarget => PlannedPoisonExpression
      }
    HirCallExpr(_, arguments, _) =>
      match inferred.call_targets[expression] {
        SelectedInferredCallTarget(declaration, type_arguments) => {
          let receiver = planned_call_receiver(collected, expression)
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
          match standard_fixed_array_operation(declaration) {
            1 => {
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
            2 => PlannedFixedArrayLength(base, element_shape)
            3 => PlannedFixedArrayGet(base, key, element_shape)
            4 =>
              PlannedFixedArrayGetUnchecked(
                base,
                key,
                planned_value_shape(
                  resolved,
                  inferred,
                  inferred.expression_types[expression],
                ),
              )
            5 =>
              PlannedFixedArraySet(
                base,
                key,
                value,
                planned_value_shape(
                  resolved,
                  inferred,
                  inferred.expression_types[value],
                ),
              )
            6 =>
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
              match standard_map_operation(declaration) {
                1 => {
                  let map_key = collected.expression_children[arguments.start]
                  let map_value = collected.expression_children[arguments.start +
                    1]
                  PlannedMapSingleton(
                    map_key, map_value, key_shape, map_value_shape, hash_declaration,
                    eq_declaration,
                  )
                }
                2 => PlannedMapLength(base)
                3 =>
                  PlannedMapGet(
                    base, key, key_shape, map_value_shape, hash_declaration, eq_declaration,
                  )
                4 =>
                  PlannedMapGetUnchecked(
                    base, key, key_shape, map_value_shape, hash_declaration, eq_declaration,
                  )
                5 =>
                  PlannedMapInsert(
                    base, key, value, key_shape, map_value_shape, hash_declaration,
                    eq_declaration,
                  )
                6 =>
                  PlannedMapSet(
                    base, key, value, key_shape, map_value_shape, hash_declaration,
                    eq_declaration,
                  )
                7 =>
                  PlannedMapContainsKey(
                    base, key, key_shape, hash_declaration, eq_declaration,
                  )
                8 =>
                  PlannedMapEmpty(
                    key_shape, map_value_shape, hash_declaration, eq_declaration,
                  )
                9 =>
                  PlannedMapRemove(
                    base, key, key_shape, hash_declaration, eq_declaration,
                  )
                10 => PlannedMapClear(base)
                _ =>
                  match standard_set_operation(declaration) {
                    1 =>
                      PlannedSetEmpty(
                        key_shape, hash_declaration, eq_declaration,
                      )
                    2 =>
                      PlannedSetSingleton(
                        collected.expression_children[arguments.start],
                        key_shape,
                        hash_declaration,
                        eq_declaration,
                      )
                    3 => PlannedSetLength(base)
                    4 => PlannedSetIsEmpty(base)
                    5 =>
                      PlannedSetContains(
                        base, key, key_shape, hash_declaration, eq_declaration,
                      )
                    6 =>
                      PlannedSetInsert(
                        base, key, key_shape, hash_declaration, eq_declaration,
                      )
                    7 =>
                      PlannedSetRemove(
                        base, key, key_shape, hash_declaration, eq_declaration,
                      )
                    8 => PlannedSetClear(base)
                    _ =>
                      PlannedDirectCall(
                        declaration, receiver, arguments, type_arguments,
                      )
                  }
              }
          }
        }
        NoInferredCallTarget | ErrorInferredCallTarget =>
          PlannedPoisonExpression
      }
    HirFieldExpr(_, _, _) | HirQualifiedExpr(_, _, _) =>
      PlannedConsumedExpression
    HirIndexExpr(base, index, offset) =>
      match inferred.operator_targets[expression] {
        SelectedInferredCallTarget(declaration, type_arguments) =>
          if standard_fixed_array_operation(declaration) == 4 {
            PlannedFixedArrayGetUnchecked(
              base,
              index,
              planned_value_shape(
                resolved,
                inferred,
                inferred.expression_types[expression],
              ),
            )
          } else if standard_map_operation(declaration) == 4 {
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
        NoInferredCallTarget | ErrorInferredCallTarget => {
          diagnostics.push(UnsupportedIndexLowering(expression, offset))
          PlannedPoisonExpression
        }
      }
    HirIndexSetExpr(base, index, value, offset) =>
      match inferred.operator_targets[expression] {
        SelectedInferredCallTarget(declaration, type_arguments) =>
          if standard_fixed_array_operation(declaration) == 6 {
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
          } else if standard_map_operation(declaration) == 6 {
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
        NoInferredCallTarget | ErrorInferredCallTarget => {
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
  names : ResolvedModuleNames,
  inferred : InferredModuleBodies,
  flows : AnalyzedModuleFlows,
  body : HirBody,
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
      flow: flows.expression_flows[expression],
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
      HirCallExpr(target, _, _) | HirConstructExpr(target, _, _) =>
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
  let inferred_body = inferred.bodies[semantic_id_local(body.id)]
  let analyzed_body = flows.bodies[semantic_id_local(body.id)]
  {
    body: {
      body: body.id,
      declaration: body.declaration,
      kind: body.kind,
      root: body.root,
      root_type: inferred_body.root_type,
      root_shape: planned_value_shape(
        resolved,
        inferred,
        inferred_body.root_type,
      ),
      flow: analyzed_body.flow,
      locals: names.body(body.id).unwrap().locals,
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
  target.bodies[semantic_id_local(body.id)] = {
    body: job.body.body,
    declaration: job.body.declaration,
    kind: job.body.kind,
    root: job.body.root,
    root_type: job.body.root_type,
    root_shape: job.body.root_shape,
    flow: job.body.flow,
    locals: job.body.locals,
    expressions: job.body.expressions,
    blocks: job.body.blocks,
    patterns: job.body.patterns,
    pattern_arms: job.body.pattern_arms,
    diagnostics: { start: diagnostic_start, length: job.diagnostics.length() },
  }
  for diagnostic in job.diagnostics {
    target.diagnostics.push(diagnostic)
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
        names,
        inferred,
        flows,
        collected.bodies[body_index],
      ),
    )
  }
  let planned_locals = Array::make(names.locals.length(), {
    body: 0UL,
    local_id: -1,
    kind: ParameterLocal,
    mutable_: false,
    type_: 0,
    shape: ErrorPlannedValueShape,
    offset: 0UL,
  })
  for body_info in names.bodies {
    for local_id in 0..<body_info.locals.length {
      let index = body_info.locals.start + local_id
      let source = names.locals[index]
      let type_ = inferred.local_types[index]
      planned_locals[index] = {
        body: body_info.body,
        local_id: source.id,
        kind: source.kind,
        mutable_: source.mutable_,
        type_,
        shape: planned_value_shape(resolved, inferred, type_),
        offset: source.offset,
      }
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
      flow: { outcomes: 0 },
      locals: { start: 0, length: 0 },
      expressions: { start: 0, length: 0 },
      blocks: { start: 0, length: 0 },
      patterns: { start: 0, length: 0 },
      pattern_arms: { start: 0, length: 0 },
      diagnostics: { start: 0, length: 0 },
    }),
    locals: planned_locals,
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
    expression_type_arguments: inferred.expression_type_arguments,
    call_type_arguments: inferred.call_type_arguments,
    pattern_type_arguments: inferred.pattern_type_arguments,
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
