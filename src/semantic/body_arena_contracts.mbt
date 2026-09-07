///|
priv enum BodyArenaKind {
  BodyExpressions
  BodyExpressionChildren
  BodyBlocks
  BodyBlockItems
  BodyPatterns
  BodyPatternChildren
  BodyPatternArms
  BodyArmChildren
  BodyObjectFields
  BodyPatternFields
}

///|
priv struct BodyArenaFailure {
  code : Int
  phase : Int
  module_id : ModuleId
  declaration : DeclId
  body : BodyId
  expression : UInt
  expected : UInt64
  actual : UInt64
  detail : UInt64
} derive(Eq, Debug)

///|
/// Tags are stable. The high half of detail names the owned arena.
fn body_arena_info(
  collected : CollectedModule,
  body : HirBody,
  kind : BodyArenaKind,
) -> (HirSpan, Int, Int) {
  match kind {
    BodyExpressions => (body.expressions, collected.expressions.length(), 0)
    BodyExpressionChildren =>
      (body.expression_children, collected.expression_children.length(), 1)
    BodyBlocks => (body.blocks, collected.blocks.length(), 2)
    BodyBlockItems => (body.block_items, collected.block_items.length(), 3)
    BodyPatterns => (body.patterns, collected.patterns.length(), 4)
    BodyPatternChildren =>
      (body.pattern_children, collected.pattern_children.length(), 5)
    BodyPatternArms => (body.pattern_arms, collected.pattern_arms.length(), 6)
    BodyArmChildren => (body.arm_children, collected.arm_children.length(), 7)
    BodyObjectFields =>
      (body.object_fields, collected.object_fields.length(), 8)
    BodyPatternFields =>
      (body.pattern_fields, collected.pattern_fields.length(), 9)
  }
}

///|
fn body_arena_failure(
  collected : CollectedModule,
  body : HirBody,
  phase : Int,
  code : Int,
  index : Int,
  expected : Int,
  actual : Int,
  tag : Int,
  detail : Int,
) -> BodyArenaFailure {
  {
    code,
    phase,
    module_id: collected.module_id,
    declaration: body.declaration,
    body: body.id,
    expression: if tag == 0 {
      index.reinterpret_as_uint()
    } else {
      0xffffffffU
    },
    expected: expected.reinterpret_as_uint().to_uint64(),
    actual: actual.reinterpret_as_uint().to_uint64(),
    detail: (tag.to_uint64() << 32) | detail.reinterpret_as_uint().to_uint64(),
  }
}

///|
fn check_body_relative_index(
  collected : CollectedModule,
  body : HirBody,
  kind : BodyArenaKind,
  index : Int,
  phase : Int,
) -> Result[Int, BodyArenaFailure] {
  let (span, count, tag) = body_arena_info(collected, body, kind)
  if !program_specialization_span_is_valid(span, count) {
    return Err(
      body_arena_failure(
        collected,
        body,
        phase,
        101,
        index,
        count,
        span.start,
        tag,
        span.length,
      ),
    )
  }
  if index < span.start || index - span.start >= span.length {
    return Err(
      body_arena_failure(
        collected,
        body,
        phase,
        102,
        index,
        span.length,
        index,
        tag,
        span.start,
      ),
    )
  }
  Ok(index - span.start)
}

///|
fn body_relative_index(
  collected : CollectedModule,
  body : HirBody,
  kind : BodyArenaKind,
  index : Int,
  phase : Int,
) -> Int {
  match check_body_relative_index(collected, body, kind, index, phase) {
    Ok(relative) => relative
    Err(error) => abort("body arena invariant: " + @debug.to_string(error))
  }
}

///|
/// Check every owned span before allocating body-local parallel arrays.
fn check_body_owned_spans(
  collected : CollectedModule,
  body : HirBody,
  phase : Int,
) -> Result[Unit, BodyArenaFailure] {
  for
    kind in [
      BodyExpressions,
      BodyExpressionChildren,
      BodyBlocks,
      BodyBlockItems,
      BodyPatterns,
      BodyPatternChildren,
      BodyPatternArms,
      BodyArmChildren,
      BodyObjectFields,
      BodyPatternFields,
    ] {
    let (span, count, tag) = body_arena_info(collected, body, kind)
    if !program_specialization_span_is_valid(span, count) {
      return Err(
        body_arena_failure(
          collected,
          body,
          phase,
          101,
          -1,
          count,
          span.start,
          tag,
          span.length,
        ),
      )
    }
  }
  Ok(())
}

///|
fn assert_body_owned_spans(
  collected : CollectedModule,
  body : HirBody,
  phase : Int,
) -> Unit {
  match check_body_owned_spans(collected, body, phase) {
    Ok(_) => ()
    Err(error) => abort("body arena invariant: " + @debug.to_string(error))
  }
}
