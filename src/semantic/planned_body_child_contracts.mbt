///|
priv struct PlannedBodyChildChecker {
  lowering : PlannedModuleLowering
  body : PlannedBodyLowering
  phase : Int
  local_span : HirSpan
  mut capture_span : HirSpan
  mut failure : BodyArenaFailure?
}

///|
fn PlannedBodyChildChecker::fail(
  self : PlannedBodyChildChecker,
  code : Int,
  parent : Int,
  expected : UInt64,
  actual : UInt64,
  detail : UInt64,
) -> Unit {
  if self.failure is None {
    self.failure = Some(
      planned_body_arena_failure(
        self.lowering,
        self.body,
        self.phase,
        code,
        parent,
        expected,
        actual,
        detail,
      ),
    )
  }
}

///|
fn PlannedBodyChildChecker::span(
  self : PlannedBodyChildChecker,
  parent : Int,
  span : HirSpan,
  length : Int,
  tag : Int,
) -> Bool {
  if self.failure is Some(_) {
    return false
  }
  if span.start < 0 ||
    span.length < 0 ||
    span.start > length ||
    span.length > length - span.start {
    self.fail(
      101,
      parent,
      length.to_uint64(),
      span.length.reinterpret_as_uint().to_uint64(),
      (tag.to_uint64() << 32) | span.start.reinterpret_as_uint().to_uint64(),
    )
    return false
  }
  true
}

///|
fn PlannedBodyChildChecker::owned(
  self : PlannedBodyChildChecker,
  parent : Int,
  span : HirSpan,
  child : Int,
  tag : Int,
) -> Bool {
  if self.failure is Some(_) {
    return false
  }
  // The containing span has already passed its arena check.
  if child < span.start || child - span.start >= span.length {
    self.fail(
      104,
      parent,
      span.start.to_uint64(),
      child.reinterpret_as_uint().to_uint64(),
      (tag.to_uint64() << 32) | span.length.to_uint64(),
    )
    return false
  }
  true
}

///|
fn PlannedBodyChildChecker::expression(
  self : PlannedBodyChildChecker,
  parent : Int,
  child : Int,
) -> Unit {
  ignore(self.owned(parent, self.body.expressions, child, 1))
}

///|
fn PlannedBodyChildChecker::optional_expression(
  self : PlannedBodyChildChecker,
  parent : Int,
  child : Int,
) -> Unit {
  if child != -1 {
    self.expression(parent, child)
  }
}

///|
fn PlannedBodyChildChecker::local(
  self : PlannedBodyChildChecker,
  parent : Int,
  child : Int,
) -> Unit {
  ignore(self.owned(parent, self.local_span, child, 2))
}

///|
fn PlannedBodyChildChecker::arguments(
  self : PlannedBodyChildChecker,
  parent : Int,
  span : HirSpan,
) -> Unit {
  if self.span(parent, span, self.lowering.expression_children.length(), 10) {
    for offset in 0..<span.length {
      self.expression(
        parent,
        self.lowering.expression_children[span.start + offset],
      )
      if self.failure is Some(_) {
        break
      }
    }
  }
}

///|
fn PlannedBodyChildChecker::fields(
  self : PlannedBodyChildChecker,
  parent : Int,
  span : HirSpan,
) -> Unit {
  if self.span(parent, span, self.lowering.object_fields.length(), 12) {
    for offset in 0..<span.length {
      self.expression(
        parent,
        self.lowering.object_fields[span.start + offset].value,
      )
      if self.failure is Some(_) {
        break
      }
    }
  }
}

///|
fn PlannedBodyChildChecker::arms(
  self : PlannedBodyChildChecker,
  parent : Int,
  span : HirSpan,
) -> Unit {
  if self.span(parent, span, self.lowering.arm_children.length(), 13) {
    for offset in 0..<span.length {
      if !self.owned(
          parent,
          self.body.pattern_arms,
          self.lowering.arm_children[span.start + offset],
          5,
        ) {
        break
      }
    }
  }
}

///|
fn PlannedBodyChildChecker::pattern(
  self : PlannedBodyChildChecker,
  child : Int,
) -> Unit {
  ignore(self.owned(-1, self.body.patterns, child, 4))
}

///|
fn PlannedBodyChildChecker::patterns(
  self : PlannedBodyChildChecker,
  span : HirSpan,
) -> Unit {
  if self.span(-1, span, self.lowering.pattern_children.length(), 14) {
    for offset in 0..<span.length {
      self.pattern(self.lowering.pattern_children[span.start + offset])
      if self.failure is Some(_) {
        break
      }
    }
  }
}

///|
fn PlannedBodyChildChecker::lambda(
  self : PlannedBodyChildChecker,
  parent : Int,
  lambda : LambdaId,
) -> Bool {
  if !self.owned(
      parent,
      { start: 0, length: self.lowering.lambdas.length(), },
      lambda,
      16,
    ) {
    return false
  }
  let source = self.lowering.lambdas[lambda]
  if source.lambda != lambda {
    self.fail(
      106,
      parent,
      lambda.to_uint64(),
      source.lambda.reinterpret_as_uint().to_uint64(),
      (16UL << 32) | lambda.to_uint64(),
    )
    return false
  }
  if source.root_body != self.body.body {
    self.fail(
      106,
      parent,
      self.body.body,
      source.root_body,
      (21UL << 32) | lambda.to_uint64(),
    )
    return false
  }
  true
}

///|
// All planned expression variants are explicit. A new IR edge must extend this
// match; there is no default that silently treats a new expression as a leaf.
fn PlannedBodyChildChecker::expression_edges(
  self : PlannedBodyChildChecker,
  parent : Int,
  kind : PlannedExpressionKind,
) -> Unit {
  match kind {
    PlannedLocalGet(local) => self.local(parent, local)
    PlannedCaptureGet(capture) => self.capture(parent, capture)
    PlannedCaptureSet(capture, value) => {
      self.capture(parent, capture)
      self.expression(parent, value)
    }
    PlannedLocalSet(local, value) => {
      self.local(parent, local)
      self.expression(parent, value)
    }
    PlannedReturnExpression(value) => self.optional_expression(parent, value)
    PlannedPackedEnumPayload(_, value)
    | PlannedBreakExpression(_, value)
    | PlannedContinueExpression(_, value)
    | PlannedPrefixExpression(_, value)
    | PlannedWasmRefIsNull(value)
    | PlannedWasmRefAsNonNull(value)
    | PlannedFixedArrayLength(value, _)
    | PlannedRawArrayNewDefault(value, _, _)
    | PlannedFieldGet(_, value, _)
    | PlannedProductField(value, _, _) => self.expression(parent, value)
    PlannedBlockExpression(block) =>
      ignore(self.owned(parent, self.body.blocks, block, 3))
    PlannedIfExpression(condition, block, alternative) => {
      self.expression(parent, condition)
      ignore(self.owned(parent, self.body.blocks, block, 3))
      self.optional_expression(parent, alternative)
    }
    PlannedMatchExpression(value, arms)
    | PlannedWhileExpression(_, value, arms) => {
      self.expression(parent, value)
      self.arms(parent, arms)
    }
    PlannedProductNew(arguments)
    | PlannedArrayLiteral(arguments, _, _)
    | PlannedVariantTupleNew(_, _, arguments)
    | PlannedParameterSelect(arguments, _) => self.arguments(parent, arguments)
    PlannedStructNew(_, _, fields) | PlannedVariantStructNew(_, _, fields) =>
      self.fields(parent, fields)
    PlannedBinaryExpression(_, left, right)
    | PlannedOperatorCall(_, _, left, right, _)
    | PlannedBoundOperatorCall(_, _, _, left, right, _)
    | PlannedIndexCall(_, left, right, _)
    | PlannedFixedArrayMake(left, right, _)
    | PlannedFixedArrayGetUnchecked(left, right, _)
    | PlannedFieldSet(_, left, right) => {
      self.expression(parent, left)
      self.expression(parent, right)
    }
    PlannedIndexSetCall(_, first, second, third, _)
    | PlannedFixedArraySetUnchecked(first, second, third, _) => {
      self.expression(parent, first)
      self.expression(parent, second)
      self.expression(parent, third)
    }
    PlannedRawArrayCopy(first, second, third, fourth, fifth, _, _) => {
      self.expression(parent, first)
      self.expression(parent, second)
      self.expression(parent, third)
      self.expression(parent, fourth)
      self.expression(parent, fifth)
    }
    PlannedDirectCall(_, receiver, arguments, _)
    | PlannedTailCall(_, receiver, arguments, _)
    | PlannedBoundDirectCall(_, _, receiver, arguments, _) => {
      self.optional_expression(parent, receiver)
      self.arguments(parent, arguments)
    }
    PlannedFunctionValueCall(receiver, arguments, _)
    | PlannedDynamicTraitCall(_, _, _, receiver, arguments, _) => {
      self.expression(parent, receiver)
      self.arguments(parent, arguments)
    }
    PlannedDirectLambdaCall(lambda, captures, arguments) => {
      self.closure_captures(parent, lambda, captures)
      self.arguments(parent, arguments)
    }
    PlannedLambdaClosure(lambda, captures) =>
      self.closure_captures(parent, lambda, captures)
    PlannedPoisonExpression
    | PlannedDeferredExpression
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
    | PlannedStringConst(_, _)
    | PlannedStringArrayConst(_)
    | PlannedBytesConst(_)
    | PlannedModuleValueGet(_, _)
    | PlannedFunctionReference(_, _)
    | PlannedUnitVariant(_, _)
    | PlannedWasmRefNull => ()
  }
}

///|
fn check_planned_body_children(
  lowering : PlannedModuleLowering,
  body : PlannedBodyLowering,
  phase : Int,
  lambda : LambdaId,
) -> Result[Unit, BodyArenaFailure] {
  let checker : PlannedBodyChildChecker = {
    lowering,
    body,
    phase,
    local_span: { start: 0, length: body.locals.length, },
    capture_span: { start: 0, length: 0, },
    failure: None,
  }
  if lambda != -1 {
    match checker.capture_table(-1, lambda) {
      Some(span) => checker.capture_span = { start: 0, length: span.length, }
      None => ()
    }
    if checker.failure is Some(failure) {
      return Err(failure)
    }
  }
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    checker.expression_edges(expression, lowering.expressions[expression].kind)
    if checker.failure is Some(failure) {
      return Err(failure)
    }
  }
  for block in body.blocks.start..<(body.blocks.start + body.blocks.length) {
    let items = lowering.blocks[block].items
    if checker.span(-1, items, lowering.block_items.length(), 11) {
      for offset in 0..<items.length {
        match lowering.block_items[items.start + offset].kind {
          PlannedLetItem(local, _, value) => {
            checker.local(-1, local)
            checker.expression(-1, value)
          }
          PlannedElidedLetItem(local) => checker.local(-1, local)
          PlannedExpressionItem(value) => checker.expression(-1, value)
        }
        if checker.failure is Some(failure) {
          return Err(failure)
        }
      }
    }
    if checker.failure is Some(failure) {
      return Err(failure)
    }
  }
  for
    pattern in body.patterns.start..<(body.patterns.start + body.patterns.length) {
    let source = lowering.patterns[pattern]
    if source.reference is PatternBindingReference(local) {
      checker.local(-1, local)
    }
    match source.source {
      HirLiteralPattern(expression, _) => checker.expression(-1, expression)
      HirQualifiedPattern(base, _, _) => checker.pattern(base)
      HirTuplePattern(base, children, _) => {
        if base != -1 {
          checker.pattern(base)
        }
        checker.patterns(children)
      }
      HirProductPattern(children, _) => checker.patterns(children)
      HirAlternativePattern(base, alternatives, _) => {
        checker.pattern(base)
        checker.patterns(alternatives)
      }
      HirStructPattern(base, fields, _, _, _) => {
        if base != -1 {
          checker.pattern(base)
        }
        if checker.span(-1, fields, lowering.pattern_fields.length(), 15) {
          for offset in 0..<fields.length {
            checker.pattern(
              lowering.pattern_fields[fields.start + offset].pattern,
            )
            if checker.failure is Some(_) {
              break
            }
          }
        }
      }
      HirWildcardPattern(_)
      | HirBindingPattern(_, _)
      | HirImportAliasPattern(_, _)
      | HirRestPattern(_) => ()
    }
    if checker.failure is Some(failure) {
      return Err(failure)
    }
  }
  for
    arm in body.pattern_arms.start..<(body.pattern_arms.start +
    body.pattern_arms.length) {
    let source = lowering.pattern_arms[arm]
    checker.pattern(source.pattern)
    checker.optional_expression(-1, source.guard_condition)
    checker.expression(-1, source.body)
    if checker.failure is Some(failure) {
      return Err(failure)
    }
  }
  Ok(())
}
