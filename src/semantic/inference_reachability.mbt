///|
// Private selected-body input. Source arenas and their IDs stay unchanged;
// dead slots are excluded from checking, not replaced with Unit values.
struct InferenceReachability {
  declaration : DeclId
  expressions : Array[Bool]
  blocks : Array[Bool]
  patterns : Array[Bool]
  locals : Array[Bool]
  type_substitutions : Array[ResolvedTypeId]
}

///|
priv enum InferenceReachTask {
  InferenceExpression(ExprId)
  InferenceBlock(BlockId)
  InferencePattern(PatternId)
}

///|
fn selected_inference_source(
  collected : CollectedModule,
  names : ResolvedModuleNames,
  declaration : DeclId,
  conditions : Map[ExprId, Bool],
  selected_plan? : PlannedModuleLowering? = None,
) -> (CollectedModule, InferenceReachability) {
  let source = {
    ..collected,
    expressions: collected.expressions.copy(),
    blocks: collected.blocks.copy(),
  }
  let live : InferenceReachability = {
    declaration,
    expressions: Array::make(collected.expressions.length(), true),
    blocks: Array::make(collected.blocks.length(), true),
    patterns: Array::make(collected.patterns.length(), true),
    locals: Array::make(names.locals.length(), true),
    type_substitutions: [],
  }
  let root = collected.body_of(declaration).unwrap()
  fn clear(span : HirSpan, arena : Array[Bool]) -> Unit {
    guard program_specialization_span_is_valid(span, arena.length()) else {
      abort("ARN-101 selected inference owner span is invalid")
    }
    for offset in 0..<span.length {
      arena[span.start + offset] = false
    }
  }
  clear(root.expressions, live.expressions)
  clear(root.blocks, live.blocks)
  clear(root.patterns, live.patterns)
  clear(names.body(root.id).unwrap().locals, live.locals)
  for lambda in collected.lambdas {
    if lambda.root_body == root.id {
      clear(lambda.body.expressions, live.expressions)
      clear(lambda.body.blocks, live.blocks)
      clear(lambda.body.patterns, live.patterns)
      clear(names.lambda(lambda.id).unwrap().locals, live.locals)
    }
  }
  let work = match root.root {
    ExpressionBodyRoot(expression) => [InferenceExpression(expression)]
    BlockBodyRoot(block) => [InferenceBlock(block)]
  }
  fn children(span : HirSpan) -> Unit {
    guard program_specialization_span_is_valid(
      span,
      collected.expression_children.length(),
    ) else {
      abort("ARN-101 selected inference expression children")
    }
    for offset in 0..<span.length {
      work.push(
        InferenceExpression(collected.expression_children[span.start + offset]),
      )
    }
  }
  fn fields(span : HirSpan) -> Unit {
    guard program_specialization_span_is_valid(
      span,
      collected.object_fields.length(),
    ) else {
      abort("ARN-101 selected inference object fields")
    }
    for offset in 0..<span.length {
      work.push(
        InferenceExpression(collected.object_fields[span.start + offset].value),
      )
    }
  }
  while work.length() > 0 {
    match work.pop().unwrap() {
      InferenceExpression(expression) => {
        if expression < 0 {
          continue
        }
        guard expression < live.expressions.length() else {
          abort("ARN-104 selected inference expression")
        }
        if live.expressions[expression] {
          continue
        }
        live.expressions[expression] = true
        let mut original = expression
        let mut hops = 0
        while collected.expressions[original]
              is HirIfExpr(_, block, alternative, offset) &&
              conditions.get(original) is Some(selected) {
          hops += 1
          guard hops <= collected.expressions.length() else {
            abort("ARN-104 selected inference alternative cycle")
          }
          if selected {
            source.expressions[expression] = HirBlockExpr(block, offset)
            break
          }
          if alternative < 0 {
            // The language gives an if without else a logical Unit result.
            source.expressions[expression] = HirProductExpr(
              { start: 0, length: 0, }, offset,
            )
            break
          }
          guard alternative >= 0 && alternative < source.expressions.length() else {
            abort("ARN-104 selected inference alternative")
          }
          original = alternative
          source.expressions[expression] = collected.expressions[original]
        }
        if selected_plan is Some(plan) {
          match (source.expressions[expression], plan.expressions[expression].kind) {
            (HirBinaryExpr(HirLogicalAnd, _, _, offset), PlannedBoolConst(value))
            | (HirBinaryExpr(HirLogicalOr, _, _, offset), PlannedBoolConst(value)) =>
              source.expressions[expression] = HirBoolExpr(value, offset)
            _ => ()
          }
          if plan.expressions[expression].kind is PlannedParameterSelect(prefix, _) &&
            !plan.expressions[expression].flow.may_fall_through() {
            guard program_specialization_span_is_valid(prefix, plan.expression_children.length()) else {
              abort("ARN-101 selected inference operand prefix")
            }
            for offset in 0..<prefix.length {
              work.push(InferenceExpression(plan.expression_children[prefix.start + offset]))
            }
            // Static callee syntax still participates in source checking.
            if source.expressions[expression] is HirCallExpr(target, _, _) {
              work.push(InferenceExpression(target))
            }
            continue
          }
        }
        match source.expressions[expression] {
          HirBlockExpr(block, _) => work.push(InferenceBlock(block))
          HirIfExpr(condition, block, alternative, _) => {
            work.push(InferenceExpression(condition))
            work.push(InferenceBlock(block))
            work.push(InferenceExpression(alternative))
          }
          HirProductExpr(span, _) | HirArrayExpr(span, _) => children(span)
          HirObjectExpr(span, _) => fields(span)
          HirConstructExpr(target, span, _) => {
            work.push(InferenceExpression(target))
            fields(span)
          }
          HirCallExpr(target, span, _) => {
            work.push(InferenceExpression(target))
            children(span)
          }
          HirLambdaExpr(lambda, _) =>
            work.push(InferenceBlock(collected.lambdas[lambda].body.root))
          HirReturnExpr(value, _)
          | HirBreakExpr(value, _)
          | HirContinueExpr(value, _)
          | HirPrefixExpr(_, value, _)
          | HirFieldExpr(value, _, _)
          | HirQualifiedExpr(value, _, _)
          | HirProductFieldExpr(value, _, _, _) =>
            work.push(InferenceExpression(value))
          HirBinaryExpr(_, left, right, _)
          | HirAssignmentExpr(left, right, _)
          | HirIndexExpr(left, right, _) => {
            work.push(InferenceExpression(left))
            work.push(InferenceExpression(right))
          }
          HirIndexSetExpr(target, index, value, _) => {
            work.push(InferenceExpression(target))
            work.push(InferenceExpression(index))
            work.push(InferenceExpression(value))
          }
          HirMatchExpr(value, arms, _) | HirWhileExpr(value, arms, _) => {
            work.push(InferenceExpression(value))
            for offset in 0..<arms.length {
              let arm = collected.pattern_arms[collected.arm_children[arms.start +
                offset]]
              work.push(InferencePattern(arm.pattern))
              work.push(InferenceExpression(arm.guard_condition))
              work.push(InferenceExpression(arm.body))
            }
          }
          _ => ()
        }
      }
      InferenceBlock(block) => {
        guard block >= 0 && block < live.blocks.length() else {
          abort("ARN-104 selected inference block")
        }
        if live.blocks[block] {
          continue
        }
        live.blocks[block] = true
        let original = collected.blocks[block]
        let items = match selected_plan {
          Some(plan) => {
            let length = plan.blocks[block].items.length
            guard length <= original.items.length else {
              abort("ARN-101 selected inference block prefix")
            }
            { ..original.items, length, }
          }
          None => original.items
        }
        source.blocks[block] = { ..original, items, }
        guard program_specialization_span_is_valid(items, collected.block_items.length()) else {
          abort("ARN-101 selected inference block items")
        }
        for offset in 0..<items.length {
          match collected.block_items[items.start + offset] {
            HirExpressionItem(value, _) => work.push(InferenceExpression(value))
            HirLetItem(_, _, _, value, _) =>
              work.push(InferenceExpression(value))
          }
        }
      }
      InferencePattern(pattern) => {
        if pattern < 0 {
          continue
        }
        guard pattern < live.patterns.length() else {
          abort("ARN-104 selected inference pattern")
        }
        if live.patterns[pattern] {
          continue
        }
        live.patterns[pattern] = true
        match collected.patterns[pattern] {
          HirLiteralPattern(value, _) => work.push(InferenceExpression(value))
          HirQualifiedPattern(root, _, _) => work.push(InferencePattern(root))
          HirTuplePattern(root, span, _)
          | HirAlternativePattern(root, span, _) => {
            work.push(InferencePattern(root))
            for offset in 0..<span.length {
              work.push(
                InferencePattern(
                  collected.pattern_children[span.start + offset],
                ),
              )
            }
          }
          HirStructPattern(root, span, _, _, _) => {
            work.push(InferencePattern(root))
            for offset in 0..<span.length {
              work.push(
                InferencePattern(
                  collected.pattern_fields[span.start + offset].pattern,
                ),
              )
            }
          }
          _ => ()
        }
      }
    }
  }
  for index, local in names.locals {
    if !live.locals[index] {
      live.locals[index] = match local.kind {
        ParameterLocal => true
        LetLocal => {
          let value = match collected.block_items[local.source] {
            HirLetItem(_, _, _, value, _) => value
            _ => abort("ARN-106 selected inference let local")
          }
          live.expressions[value]
        }
        PatternLocal => live.patterns[local.source]
      }
    }
  }
  (source, live)
}

///|
fn BasicBodyInferencer::live_expression(
  self : BasicBodyInferencer,
  expression : ExprId,
) -> Bool {
  match self.reachability {
    None => true
    Some(live) => {
      guard expression >= 0 && expression < live.expressions.length() else {
        abort("ARN-104 selected inference expression is outside its arena")
      }
      live.expressions[expression]
    }
  }
}

///|
fn BasicBodyInferencer::source_resolved_type(
  self : BasicBodyInferencer,
  type_ : ResolvedTypeId,
) -> ResolvedTypeId {
  match self.reachability {
    Some(live) if live.declaration == self.body.declaration &&
      live.type_substitutions.length() > 0 => {
      guard type_ >= 0 && type_ < live.type_substitutions.length() else {
        abort("ARN-104 selected inference source type")
      }
      live.type_substitutions[type_]
    }
    _ => type_
  }
}

///|
fn BasicBodyInferencer::live_block(
  self : BasicBodyInferencer,
  block : BlockId,
) -> Bool {
  match self.reachability {
    None => true
    Some(live) => {
      guard block >= 0 && block < live.blocks.length() else {
        abort("ARN-104 selected inference block is outside its arena")
      }
      live.blocks[block]
    }
  }
}

///|
fn BasicBodyInferencer::live_pattern(
  self : BasicBodyInferencer,
  pattern : PatternId,
) -> Bool {
  match self.reachability {
    None => true
    Some(live) => {
      guard pattern >= 0 && pattern < live.patterns.length() else {
        abort("ARN-104 selected inference pattern is outside its arena")
      }
      live.patterns[pattern]
    }
  }
}

///|
fn BasicBodyInferencer::live_local(
  self : BasicBodyInferencer,
  local : Int,
) -> Bool {
  match self.reachability {
    None => true
    Some(live) => {
      guard local >= 0 && local < self.local_span.length else {
        abort("ARN-102 selected inference local is outside its body")
      }
      let global = self.local_span.start + local
      guard global < live.locals.length() else {
        abort("ARN-104 selected inference local is outside its arena")
      }
      live.locals[global]
    }
  }
}
