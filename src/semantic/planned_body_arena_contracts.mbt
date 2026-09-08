///|
fn planned_body_arena_failure(
  lowering : PlannedModuleLowering,
  body : PlannedBodyLowering,
  phase : Int,
  code : Int,
  index : Int,
  expected : UInt64,
  actual : UInt64,
  detail : UInt64,
) -> BodyArenaFailure {
  {
    code,
    phase,
    module_id: lowering.module_id,
    declaration: body.declaration,
    body: body.body,
    expression: index.reinterpret_as_uint(),
    expected,
    actual,
    detail,
  }
}

///|
/// This boundary uses lowered arenas, not the original HIR: specialization and
/// lambda extraction can select different spans. Check before any allocation,
/// addition, subtraction, or lookup based on those spans.
fn check_planned_body_arenas(
  lowering : PlannedModuleLowering,
  body : PlannedBodyLowering,
  phase : Int,
  lambda? : LambdaId = -1,
) -> Result[Unit, BodyArenaFailure] {
  let arenas = [
    (1, body.expressions, lowering.expressions.length()),
    (2, body.locals, lowering.locals.length()),
    (3, body.blocks, lowering.blocks.length()),
    (4, body.patterns, lowering.patterns.length()),
    (5, body.pattern_arms, lowering.pattern_arms.length()),
  ]
  for entry in arenas {
    let (tag, span, length) = entry
    if span.start < 0 ||
      span.length < 0 ||
      span.start > length ||
      span.length > length - span.start {
      return Err(
        planned_body_arena_failure(
          lowering,
          body,
          phase,
          101,
          -1,
          length.to_uint64(),
          span.length.reinterpret_as_uint().to_uint64(),
          (tag.to_uint64() << 32) | span.start.reinterpret_as_uint().to_uint64(),
        ),
      )
    }
  }
  let (root, span, tag) = match body.root {
    ExpressionBodyRoot(expression) => (expression, body.expressions, 1)
    BlockBodyRoot(block) => (block, body.blocks, 3)
  }
  if root < span.start || root - span.start >= span.length {
    return Err(
      planned_body_arena_failure(
        lowering,
        body,
        phase,
        102,
        root,
        span.start.to_uint64(),
        root.reinterpret_as_uint().to_uint64(),
        (tag.to_uint64() << 32) | span.length.to_uint64(),
      ),
    )
  }
  for relative in 0..<body.locals.length {
    let index = body.locals.start + relative
    let local = lowering.locals[index]
    if local.body != body.body {
      return Err(
        planned_body_arena_failure(
          lowering,
          body,
          phase,
          106,
          -1,
          body.body,
          local.body,
          (6UL << 32) | index.to_uint64(),
        ),
      )
    }
    if local.local_id != relative {
      return Err(
        planned_body_arena_failure(
          lowering,
          body,
          phase,
          106,
          -1,
          relative.to_uint64(),
          local.local_id.reinterpret_as_uint().to_uint64(),
          (2UL << 32) | index.to_uint64(),
        ),
      )
    }
    if local.lambda != lambda {
      return Err(
        planned_body_arena_failure(
          lowering,
          body,
          phase,
          106,
          -1,
          lambda.reinterpret_as_uint().to_uint64(),
          local.lambda.reinterpret_as_uint().to_uint64(),
          (7UL << 32) | index.to_uint64(),
        ),
      )
    }
  }
  check_planned_body_children(lowering, body, phase)
}

///|
/// Reject a malformed lowered body before backend local planning. The complete
/// numeric record is retained in the native diagnostic, including source IDs.
pub fn assert_planned_body_arenas(
  lowering : PlannedModuleLowering,
  body : PlannedBodyLowering,
  phase : Int,
  lambda? : LambdaId = -1,
) -> Unit {
  match check_planned_body_arenas(lowering, body, phase, lambda~) {
    Ok(_) => ()
    Err(error) =>
      abort("planned body arena invariant: " + @debug.to_string(error))
  }
}
