///|
// Scalar replacement grows a body's relative local namespace by copying its
// span to the end of the arena. Remove superseded copies once, after all such
// rewrites. Local and capture operands stay relative to their owning callable.
fn compact_program_optimization_locals(
  modules : Array[PlannedModuleLowering],
) -> Unit {
  for module_index, module_ in modules {
    let mut owned = 0
    for body in module_.bodies {
      owned += body.locals.length
    }
    for lambda in module_.lambdas {
      owned += lambda.locals.length
    }
    if owned == module_.locals.length() {
      continue
    }
    let locals : Array[PlannedLocal] = Array::new(capacity=owned)
    for index, body in module_.bodies {
      let start = locals.length()
      for offset in 0..<body.locals.length {
        locals.push(module_.locals[body.locals.start + offset])
      }
      module_.bodies[index] = {
        ..body,
        locals: { start, length: body.locals.length, },
      }
    }
    for index, lambda in module_.lambdas {
      let start = locals.length()
      for offset in 0..<lambda.locals.length {
        locals.push(module_.locals[lambda.locals.start + offset])
      }
      module_.lambdas[index] = {
        ..lambda,
        locals: { start, length: lambda.locals.length, },
      }
    }
    modules[module_index] = { ..module_, locals, }
  }
}

///|
fn record_program_control_nodes(
  insertions : Map[Int, Array[Int]],
  owner : HirSpan,
  start : Int,
  end : Int,
) -> Unit {
  if start == end {
    return
  }
  let boundary = owner.start + owner.length
  let values = insertions.get_or_init(boundary, fn() { [] })
  for index in start..<end {
    values.push(index)
  }
}

///|
fn program_control_arena_order(
  original_length : Int,
  length : Int,
  insertions : Map[Int, Array[Int]],
) -> (Array[Int], Array[Int]) {
  let order : Array[Int] = Array::new(capacity=length)
  let mapping = Array::make(length, -1)
  for boundary in 0..<(original_length + 1) {
    if insertions.get(boundary) is Some(values) {
      for value in values {
        order.push(value)
      }
    }
    if boundary < original_length {
      order.push(boundary)
    }
  }
  guard order.length() == length else {
    abort("optimized control arena has an unowned generated node")
  }
  for index, old in order {
    mapping[old] = index
  }
  (order, mapping)
}

///|
fn program_control_span(
  span : HirSpan,
  original_length : Int,
  mapping : Array[Int],
  insertions : Map[Int, Array[Int]],
) -> HirSpan {
  let start = if span.start == original_length {
    mapping.length()
  } else {
    mapping[span.start]
  }
  let extra = if span.length == 0 {
    0
  } else {
    match insertions.get(span.start + span.length) {
      Some(values) => values.length()
      None => 0
    }
  }
  { start, length: span.length + extra, }
}

///|
fn program_control_reference(mapping : Array[Int], value : Int) -> Int {
  if value < 0 {
    return value
  }
  guard value < mapping.length() && mapping[value] >= 0 else {
    abort("optimized control arena has an invalid operand: \{value}")
  }
  mapping[value]
}

///|
// Rebase every direct operand. List-backed operands are rebased in their shared
// arenas below. Keep leaves explicit so new IR edges require a compiler update.
fn rebase_program_control_expression(
  kind : PlannedExpressionKind,
  expressions : Array[Int],
  blocks : Array[Int],
) -> PlannedExpressionKind {
  let e = fn(value) { program_control_reference(expressions, value) }
  let b = fn(value) { program_control_reference(blocks, value) }
  match kind {
    PlannedLocalSet(local, value) => PlannedLocalSet(local, e(value))
    PlannedCaptureSet(capture, value) => PlannedCaptureSet(capture, e(value))
    PlannedPackedEnumPayload(lane, value) =>
      PlannedPackedEnumPayload(lane, e(value))
    PlannedBlockExpression(block) => PlannedBlockExpression(b(block))
    PlannedIfExpression(condition, block, alternative) =>
      PlannedIfExpression(e(condition), b(block), e(alternative))
    PlannedMatchExpression(value, arms) =>
      PlannedMatchExpression(e(value), arms)
    PlannedWhileExpression(control, value, arms) =>
      PlannedWhileExpression(control, e(value), arms)
    PlannedReturnExpression(value) => PlannedReturnExpression(e(value))
    PlannedBreakExpression(control, value) =>
      PlannedBreakExpression(control, e(value))
    PlannedContinueExpression(control, value) =>
      PlannedContinueExpression(control, e(value))
    PlannedPrefixExpression(op, value) => PlannedPrefixExpression(op, e(value))
    PlannedBinaryExpression(op, left, right) =>
      PlannedBinaryExpression(op, e(left), e(right))
    PlannedOperatorCall(decl, op, left, right, types) =>
      PlannedOperatorCall(decl, op, e(left), e(right), types)
    PlannedBoundOperatorCall(decl, bound, op, left, right, types) =>
      PlannedBoundOperatorCall(decl, bound, op, e(left), e(right), types)
    PlannedIndexCall(decl, left, right, types) =>
      PlannedIndexCall(decl, e(left), e(right), types)
    PlannedIndexSetCall(decl, first, second, third, types) =>
      PlannedIndexSetCall(decl, e(first), e(second), e(third), types)
    PlannedWasmRefIsNull(value) => PlannedWasmRefIsNull(e(value))
    PlannedWasmRefAsNonNull(value) => PlannedWasmRefAsNonNull(e(value))
    PlannedFixedArrayMake(left, right, shape) =>
      PlannedFixedArrayMake(e(left), e(right), shape)
    PlannedRawArrayNewDefault(value, type_, shape) =>
      PlannedRawArrayNewDefault(e(value), type_, shape)
    PlannedRawArrayCopy(a, c, d, f, g, type_, shape) =>
      PlannedRawArrayCopy(e(a), e(c), e(d), e(f), e(g), type_, shape)
    PlannedFixedArrayLength(value, shape) =>
      PlannedFixedArrayLength(e(value), shape)
    PlannedFixedArrayGetUnchecked(left, right, shape) =>
      PlannedFixedArrayGetUnchecked(e(left), e(right), shape)
    PlannedFixedArraySetUnchecked(a, c, d, shape) =>
      PlannedFixedArraySetUnchecked(e(a), e(c), e(d), shape)
    PlannedDirectCall(decl, receiver, args, types) =>
      PlannedDirectCall(decl, e(receiver), args, types)
    PlannedTailCall(decl, receiver, args, types) =>
      PlannedTailCall(decl, e(receiver), args, types)
    PlannedBoundDirectCall(decl, bound, receiver, args, types) =>
      PlannedBoundDirectCall(decl, bound, e(receiver), args, types)
    PlannedFunctionValueCall(receiver, args, signature) =>
      PlannedFunctionValueCall(e(receiver), args, signature)
    PlannedDynamicTraitCall(trait_, method, slot, receiver, args, types) =>
      PlannedDynamicTraitCall(trait_, method, slot, e(receiver), args, types)
    PlannedFieldGet(field, value, mutable_) =>
      PlannedFieldGet(field, e(value), mutable_)
    PlannedProductField(value, slot, width) =>
      PlannedProductField(e(value), slot, width)
    PlannedFieldSet(field, left, right) =>
      PlannedFieldSet(field, e(left), e(right))
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
    | PlannedLocalGet(_)
    | PlannedCaptureGet(_)
    | PlannedModuleValueGet(_, _)
    | PlannedFunctionReference(_, _)
    | PlannedLambdaClosure(_, _)
    | PlannedProductNew(_)
    | PlannedArrayLiteral(_, _, _)
    | PlannedDirectLambdaCall(_, _, _)
    | PlannedStructNew(_, _, _)
    | PlannedVariantTupleNew(_, _, _)
    | PlannedVariantStructNew(_, _, _)
    | PlannedUnitVariant(_, _)
    | PlannedWasmRefNull
    | PlannedParameterSelect(_, _) => kind
  }
}

///|
// Place appended control nodes next to their owning body's original nodes in
// one linear rebuild. Source offsets and relative local identities stay intact.
fn relocate_program_control_nodes(
  module_ : PlannedModuleLowering,
  expression_limit : Int,
  block_limit : Int,
  arm_limit : Int,
  expression_insertions : Map[Int, Array[Int]],
  block_insertions : Map[Int, Array[Int]],
  arm_insertions : Map[Int, Array[Int]],
) -> PlannedModuleLowering {
  if expression_insertions.is_empty() {
    return module_
  }
  let (expression_order, expressions) = program_control_arena_order(
    expression_limit,
    module_.expressions.length(),
    expression_insertions,
  )
  let (block_order, blocks) = program_control_arena_order(
    block_limit,
    module_.blocks.length(),
    block_insertions,
  )
  let (arm_order, arms) = program_control_arena_order(
    arm_limit,
    module_.pattern_arms.length(),
    arm_insertions,
  )
  let e = fn(value) { program_control_reference(expressions, value) }
  let root = fn(value : HirBodyRoot) {
    match value {
      ExpressionBodyRoot(value) => ExpressionBodyRoot(e(value))
      BlockBodyRoot(value) =>
        BlockBodyRoot(program_control_reference(blocks, value))
    }
  }
  for index, body in module_.bodies {
    module_.bodies[index] = {
      ..body,
      root: root(body.root),
      expressions: program_control_span(
        body.expressions,
        expression_limit,
        expressions,
        expression_insertions,
      ),
      blocks: program_control_span(
        body.blocks,
        block_limit,
        blocks,
        block_insertions,
      ),
      pattern_arms: program_control_span(
        body.pattern_arms,
        arm_limit,
        arms,
        arm_insertions,
      ),
    }
  }
  for index, lambda in module_.lambdas {
    module_.lambdas[index] = {
      ..lambda,
      root: root(lambda.root),
      expressions: program_control_span(
        lambda.expressions,
        expression_limit,
        expressions,
        expression_insertions,
      ),
      blocks: program_control_span(
        lambda.blocks,
        block_limit,
        blocks,
        block_insertions,
      ),
      pattern_arms: program_control_span(
        lambda.pattern_arms,
        arm_limit,
        arms,
        arm_insertions,
      ),
    }
  }
  for index, value in module_.expression_children {
    module_.expression_children[index] = e(value)
  }
  for index, value in module_.arm_children {
    module_.arm_children[index] = program_control_reference(arms, value)
  }
  for index, item in module_.block_items {
    module_.block_items[index] = {
      ..item,
      kind: match item.kind {
        PlannedLetItem(local, mutable_, value) =>
          PlannedLetItem(local, mutable_, e(value))
        PlannedExpressionItem(value) => PlannedExpressionItem(e(value))
        PlannedElidedLetItem(_) => item.kind
      },
    }
  }
  for index, pattern in module_.patterns {
    if pattern.source is HirLiteralPattern(value, offset) {
      module_.patterns[index] = {
        ..pattern,
        source: HirLiteralPattern(e(value), offset),
      }
    }
  }
  {
    ..module_,
    expressions: expression_order.map(fn(old) {
      let source = module_.expressions[old]
      {
        ..source,
        kind: rebase_program_control_expression(
          source.kind,
          expressions,
          blocks,
        ),
      }
    }),
    expression_evidence: expression_order.map(fn(old) {
      if old < module_.expression_evidence.length() {
        module_.expression_evidence[old]
      } else {
        { start: 0, length: 0, }
      }
    }),
    blocks: block_order.map(fn(old) { module_.blocks[old] }),
    pattern_arms: arm_order.map(fn(old) {
      let arm = module_.pattern_arms[old]
      { ..arm, guard_condition: e(arm.guard_condition), body: e(arm.body), }
    }),
    object_fields: module_.object_fields.map(fn(field) {
      { ..field, value: e(field.value), }
    }),
  }
}

///|
fn scalar_replace_program_variant_payload_match_recorded(
  module_ : PlannedModuleLowering,
  expression : ExprId,
  variant_expression : ExprId,
  expression_insertions : Map[Int, Array[Int]],
  block_insertions : Map[Int, Array[Int]],
) -> Bool {
  let expressions = module_.expressions.length()
  let blocks = module_.blocks.length()
  let changed = scalar_replace_program_variant_payload_match(
    module_, expression, variant_expression,
  )
  if module_.expressions.length() > expressions ||
    module_.blocks.length() > blocks {
    let body = program_body_containing_expression(module_, expression).unwrap()
    record_program_control_nodes(
      expression_insertions,
      body.expressions,
      expressions,
      module_.expressions.length(),
    )
    record_program_control_nodes(
      block_insertions,
      body.blocks,
      blocks,
      module_.blocks.length(),
    )
  }
  changed
}
