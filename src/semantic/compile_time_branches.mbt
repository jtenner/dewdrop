///|
enum CompileTimeReachTask {
  CtReachExpression(ExprId)
  CtReachBlock(BlockId)
  CtFinishExpression(ExprId)
}

///|
fn compile_time_push_children(
  module_ : PlannedModuleLowering,
  children : HirSpan,
  work : Array[CompileTimeReachTask],
) -> Unit {
  guard program_specialization_span_is_valid(
    children,
    module_.expression_children.length(),
  ) else {
    abort("ARN-101 compile-time expression children are outside their arena")
  }
  for index in 0..<children.length {
    work.push(
      CtReachExpression(module_.expression_children[children.start + index]),
    )
  }
}

///|
// This exhaustive match describes the evaluation edges of planned IR, not HIR.
// It therefore also handles nodes introduced by optional optimization.
fn compile_time_push_expression(
  module_ : PlannedModuleLowering,
  kind : PlannedExpressionKind,
  work : Array[CompileTimeReachTask],
) -> Unit {
  match kind {
    PlannedBlockExpression(block) => work.push(CtReachBlock(block))
    PlannedIfExpression(condition, block, alternative) => {
      work.push(CtReachExpression(condition))
      match module_.expressions[condition].kind {
        PlannedBoolConst(true) => work.push(CtReachBlock(block))
        PlannedBoolConst(false) => work.push(CtReachExpression(alternative))
        _ => {
          work.push(CtReachBlock(block))
          work.push(CtReachExpression(alternative))
        }
      }
    }
    PlannedMatchExpression(value, arms)
    | PlannedWhileExpression(_, value, arms) => {
      work.push(CtReachExpression(value))
      guard program_specialization_span_is_valid(
        arms,
        module_.arm_children.length(),
      ) else {
        abort("ARN-101 compile-time arms are outside their arena")
      }
      for index in 0..<arms.length {
        let arm_id = module_.arm_children[arms.start + index]
        guard arm_id >= 0 && arm_id < module_.pattern_arms.length() else {
          abort("ARN-104 compile-time arm is outside its arena")
        }
        let arm = module_.pattern_arms[arm_id]
        work.push(CtReachExpression(arm.guard_condition))
        work.push(CtReachExpression(arm.body))
      }
    }
    PlannedLambdaClosure(lambda, _) | PlannedDirectLambdaCall(lambda, _, _) => {
      guard lambda >= 0 && lambda < module_.lambdas.length() else {
        abort("ARN-104 compile-time lambda is outside its arena")
      }
      match module_.lambdas[lambda].root {
        ExpressionBodyRoot(value) => work.push(CtReachExpression(value))
        BlockBodyRoot(block) => work.push(CtReachBlock(block))
      }
      if kind is PlannedDirectLambdaCall(_, _, arguments) {
        compile_time_push_children(module_, arguments, work)
      }
    }
    PlannedStructNew(_, fields, _) | PlannedVariantStructNew(_, fields, _) => {
      guard program_specialization_span_is_valid(
        fields,
        module_.object_fields.length(),
      ) else {
        abort("ARN-101 compile-time fields are outside their arena")
      }
      for index in 0..<fields.length {
        work.push(
          CtReachExpression(module_.object_fields[fields.start + index].value),
        )
      }
    }
    PlannedPoisonExpression
    | PlannedConsumedExpression
    | PlannedI8Const(_)
    | PlannedI16Const(_)
    | PlannedI32Const(_)
    | PlannedI64Const(_)
    | PlannedU8Const(_)
    | PlannedU16Const(_)
    | PlannedU32Const(_)
    | PlannedU64Const(_)
    | PlannedF32Const(_)
    | PlannedF64Const(_)
    | PlannedBoolConst(_)
    | PlannedStringConst(_)
    | PlannedStringArrayConst(_)
    | PlannedBytesConst(_)
    | PlannedLocalGet(_)
    | PlannedCaptureGet(_)
    | PlannedModuleValueGet(_, _)
    | PlannedFunctionReference(_, _)
    | PlannedUnitVariant(_, _)
    | PlannedWasmRefNull
    | PlannedArrayNew(_, _)
    | PlannedCircularBufferNewZero(_)
    | PlannedMapEmpty(_, _, _, _)
    | PlannedSetEmpty(_, _, _) => ()
    PlannedLocalSet(_, value0)
    | PlannedCaptureSet(_, value0)
    | PlannedPackedEnumPayload(_, value0)
    | PlannedReturnExpression(value0)
    | PlannedBreakExpression(_, value0)
    | PlannedContinueExpression(_, value0)
    | PlannedPrefixExpression(_, value0)
    | PlannedWasmRefIsNull(value0)
    | PlannedWasmRefAsNonNull(value0)
    | PlannedFixedArrayLength(value0, _)
    | PlannedArrayWithCapacity(value0, _, _)
    | PlannedArrayLength(value0)
    | PlannedArrayCapacity(value0)
    | PlannedArrayPop(value0, _, _)
    | PlannedArrayClear(value0, _, _)
    | PlannedArrayIter(value0, _, _)
    | PlannedArrayIterHasNext(value0)
    | PlannedArrayIterNext(value0, _)
    | PlannedArrayIterNextOption(value0, _, _)
    | PlannedArrayShrinkToFit(value0, _, _)
    | PlannedArrayCopy(value0, _, _)
    | PlannedStackIsEmpty(value0)
    | PlannedStackPeek(value0, _)
    | PlannedQueueDequeue(value0, _)
    | PlannedQueuePeek(value0, _)
    | PlannedCircularBufferNew(value0, _, _)
    | PlannedCircularBufferCapacity(value0, _)
    | PlannedCircularBufferIsFull(value0, _)
    | PlannedCircularBufferPopFront(value0, _)
    | PlannedCircularBufferPeekFront(value0, _)
    | PlannedCircularBufferClear(value0, _)
    | PlannedCircularBufferIter(value0, _)
    | PlannedCircularBufferIterHasNext(value0)
    | PlannedCircularBufferIterNext(value0, _)
    | PlannedCircularBufferPopBack(value0, _)
    | PlannedCircularBufferPeekBack(value0, _)
    | PlannedMapLength(value0)
    | PlannedMapClear(value0)
    | PlannedMapKeys(value0, _, _)
    | PlannedMapValues(value0, _, _)
    | PlannedMapEntries(value0, _, _)
    | PlannedMapIterHasNext(value0, _, _, _)
    | PlannedMapKeyIterNext(value0, _, _)
    | PlannedMapKeyIterNextOption(value0, _, _)
    | PlannedMapValueIterNext(value0, _, _)
    | PlannedMapValueIterNextOption(value0, _, _)
    | PlannedMapEntryIterNext(value0, _, _)
    | PlannedMapEntryIterNextOption(value0, _, _)
    | PlannedMapEntryKey(value0, _, _)
    | PlannedMapEntryValue(value0, _, _)
    | PlannedSetSingleton(value0, _, _, _)
    | PlannedSetLength(value0)
    | PlannedSetIsEmpty(value0)
    | PlannedSetClear(value0)
    | PlannedSetIter(value0, _)
    | PlannedSetIterHasNext(value0, _)
    | PlannedSetIterNext(value0, _)
    | PlannedSetIterNextOption(value0, _)
    | PlannedFieldGet(_, value0, _)
    | PlannedProductField(value0, _, _) => work.push(CtReachExpression(value0))
    PlannedProductNew(arguments)
    | PlannedArrayLiteral(arguments, _, _)
    | PlannedVariantTupleNew(_, arguments, _)
    | PlannedParameterSelect(arguments, _) =>
      compile_time_push_children(module_, arguments, work)
    PlannedBinaryExpression(_, value0, value1)
    | PlannedOperatorCall(_, _, value0, value1, _)
    | PlannedBoundOperatorCall(_, _, _, value0, value1, _)
    | PlannedIndexCall(_, value0, value1, _)
    | PlannedFixedArrayMake(value0, value1, _)
    | PlannedFixedArrayGet(value0, value1, _)
    | PlannedFixedArrayGetUnchecked(value0, value1, _)
    | PlannedArrayGet(value0, value1, _, _)
    | PlannedArrayGetUnchecked(value0, value1, _)
    | PlannedArrayPush(value0, value1, _)
    | PlannedArrayMake(value0, value1, _, _)
    | PlannedArrayReserve(value0, value1, _, _)
    | PlannedArrayTruncate(value0, value1, _, _)
    | PlannedArrayExtend(value0, value1, _, _)
    | PlannedQueueRingEnqueue(value0, value1, _)
    | PlannedDequeRingPushFront(value0, value1, _)
    | PlannedCircularBufferPushBack(value0, value1, _)
    | PlannedCircularBufferPushFront(value0, value1, _)
    | PlannedMapSingleton(value0, value1, _, _, _, _)
    | PlannedMapGet(value0, value1, _, _, _, _)
    | PlannedMapGetUnchecked(value0, value1, _, _, _, _)
    | PlannedMapContainsKey(value0, value1, _, _, _)
    | PlannedMapRemove(value0, value1, _, _, _)
    | PlannedSetContains(value0, value1, _, _, _)
    | PlannedSetInsert(value0, value1, _, _, _)
    | PlannedSetRemove(value0, value1, _, _, _)
    | PlannedFieldSet(_, value0, value1) => {
      work.push(CtReachExpression(value0))
      work.push(CtReachExpression(value1))
    }
    PlannedIndexSetCall(_, value0, value1, value2, _)
    | PlannedFixedArraySetUnchecked(value0, value1, value2, _)
    | PlannedArraySet(value0, value1, value2, _)
    | PlannedArraySetUnchecked(value0, value1, value2, _)
    | PlannedArraySlice(value0, value1, value2, _, _)
    | PlannedMapInsert(value0, value1, value2, _, _, _, _)
    | PlannedMapSet(value0, value1, value2, _, _, _, _) => {
      work.push(CtReachExpression(value0))
      work.push(CtReachExpression(value1))
      work.push(CtReachExpression(value2))
    }
    PlannedArrayCopyWithin(value0, value1, value2, value3, _, _)
    | PlannedArrayFill(value0, value1, value2, value3, _, _) => {
      work.push(CtReachExpression(value0))
      work.push(CtReachExpression(value1))
      work.push(CtReachExpression(value2))
      work.push(CtReachExpression(value3))
    }
    PlannedDirectCall(_, value0, arguments, _)
    | PlannedTailCall(_, value0, arguments, _)
    | PlannedBoundDirectCall(_, _, value0, arguments, _)
    | PlannedFunctionValueCall(value0, arguments, _)
    | PlannedDynamicTraitCall(_, _, _, value0, arguments, _) => {
      work.push(CtReachExpression(value0))
      compile_time_push_children(module_, arguments, work)
    }
  }
}

///|
fn compile_time_in_body(
  module_ : PlannedModuleLowering,
  expression : ExprId,
  active : DeclId?,
) -> Bool {
  active is None || compile_time_expression_owner(module_, expression) == active
}

///|
// Replace branches in postorder, independent of expression arena order. Remove
// unreachable calls before specialization scans the flat expression arena.
fn prune_compile_time_branches(
  module_ : PlannedModuleLowering,
  active : DeclId?,
) -> Unit {
  let reached = Array::make(module_.expressions.length(), false)
  let blocks = Array::make(module_.blocks.length(), false)
  let work : Array[CompileTimeReachTask] = []
  for body in module_.bodies {
    if active is Some(declaration) && body.declaration != declaration {
      continue
    }
    match body.root {
      ExpressionBodyRoot(value) => work.push(CtReachExpression(value))
      BlockBodyRoot(block) => work.push(CtReachBlock(block))
    }
  }
  while work.length() > 0 {
    match work.pop().unwrap() {
      CtReachBlock(block) => {
        guard block >= 0 && block < blocks.length() else {
          abort("ARN-104 compile-time block is outside its arena")
        }
        if blocks[block] {
          continue
        }
        blocks[block] = true
        let items = module_.blocks[block].items
        guard program_specialization_span_is_valid(
          items,
          module_.block_items.length(),
        ) else {
          abort("ARN-101 compile-time block items are outside their arena")
        }
        for index in 0..<items.length {
          match module_.block_items[items.start + index].kind {
            PlannedLetItem(_, _, value) | PlannedExpressionItem(value) =>
              work.push(CtReachExpression(value))
            PlannedElidedLetItem(_) => ()
          }
        }
      }
      CtReachExpression(expression) => {
        if expression < 0 {
          continue
        }
        guard expression < reached.length() else {
          abort("ARN-104 compile-time expression is outside its arena")
        }
        if reached[expression] {
          continue
        }
        reached[expression] = true
        work.push(CtFinishExpression(expression))
        compile_time_push_expression(
          module_,
          module_.expressions[expression].kind,
          work,
        )
      }
      CtFinishExpression(expression) => {
        let source = module_.expressions[expression]
        match source.kind {
          PlannedIfExpression(condition, block, alternative) =>
            match module_.expressions[condition].kind {
              PlannedBoolConst(true) =>
                module_.expressions[expression] = {
                  ..source,
                  kind: PlannedBlockExpression(block),
                  flow: module_.blocks[block].flow,
                }
              PlannedBoolConst(false) if alternative >= 0 => {
                // Keep the selected expression's identity and coercion, and
                // the outer expression's type/coercion. Copying its kind would
                // silently lose one of those conversion boundaries.
                let start = module_.expression_children.length()
                module_.expression_children.push(alternative)
                module_.expressions[expression] = {
                  ..source,
                  kind: PlannedParameterSelect({ start, length: 1, }, 0),
                  flow: module_.expressions[alternative].flow,
                }
              }
              PlannedBoolConst(false) =>
                module_.expressions[expression] = {
                  ..source,
                  kind: PlannedProductNew({ start: 0, length: 0, }),
                  flow: { outcomes: flow_falls_through, },
                }
              _ => ()
            }
          _ => ()
        }
      }
    }
  }
  for index, source in module_.expressions {
    if !reached[index] && compile_time_in_body(module_, index, active) {
      module_.expressions[index] = { ..source, kind: PlannedPoisonExpression, }
    }
  }
  for index, lambda in module_.lambdas {
    let owner = module_.bodies[semantic_id_local(lambda.root_body)].declaration
    if active is Some(declaration) && owner != declaration {
      continue
    }
    let live = match lambda.root {
      ExpressionBodyRoot(expression) => reached[expression]
      BlockBodyRoot(block) => blocks[block]
    }
    if !live {
      module_.lambdas[index] = { ..lambda, elided: true, }
    }
  }
}
