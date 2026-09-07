///|
fn compile_time_push_pattern(
  module_ : PlannedModuleLowering,
  pattern : PatternId,
  work : Array[CompileTimeReachTask],
) -> Unit {
  match module_.patterns[pattern].source {
    HirWildcardPattern(_)
    | HirBindingPattern(_, _)
    | HirImportAliasPattern(_, _)
    | HirRestPattern(_) => ()
    HirLiteralPattern(value, _) => work.push(CtReachExpression(value))
    HirQualifiedPattern(base, _, _) => work.push(CtReachPattern(base))
    HirTuplePattern(base, children, _)
    | HirAlternativePattern(base, children, _) => {
      work.push(CtReachPattern(base))
      guard program_specialization_span_is_valid(
        children,
        module_.pattern_children.length(),
      ) else {
        abort("ARN-101 reachable pattern children")
      }
      for offset in 0..<children.length {
        work.push(
          CtReachPattern(module_.pattern_children[children.start + offset]),
        )
      }
    }
    HirProductPattern(children, _) => {
      guard program_specialization_span_is_valid(children, module_.pattern_children.length()) else {
        abort("ARN-101 reachable product pattern children")
      }
      for offset in 0..<children.length {
        work.push(CtReachPattern(module_.pattern_children[children.start + offset]))
      }
    }
    HirStructPattern(base, fields, _, _, _) => {
      work.push(CtReachPattern(base))
      guard program_specialization_span_is_valid(
        fields,
        module_.pattern_fields.length(),
      ) else {
        abort("ARN-101 reachable pattern fields")
      }
      for offset in 0..<fields.length {
        work.push(
          CtReachPattern(module_.pattern_fields[fields.start + offset].pattern),
        )
      }
    }
  }
}

///|
fn prune_compile_time_scope_locals(
  module_ : PlannedModuleLowering,
  local_span : HirSpan,
  expression_span : HirSpan,
  block_span : HirSpan,
  pattern_span : HirSpan,
  reached : Array[Bool],
  blocks : Array[Bool],
  patterns : Array[Bool],
) -> Unit {
  guard program_specialization_span_is_valid(
      local_span,
      module_.locals.length(),
    ) &&
    program_specialization_span_is_valid(expression_span, reached.length()) &&
    program_specialization_span_is_valid(block_span, blocks.length()) &&
    program_specialization_span_is_valid(pattern_span, patterns.length()) else {
    abort("ARN-101 compile-time local scope is outside its arena")
  }
  let live = Array::make(local_span.length, false)
  for offset in 0..<expression_span.length {
    let id = expression_span.start + offset
    if !reached[id] {
      continue
    }
    match module_.expressions[id].kind {
      PlannedLocalGet(local_id) | PlannedLocalSet(local_id, _) => {
        guard local_id >= 0 && local_id < live.length() else {
          abort("ARN-104 reachable local reference")
        }
        live[local_id] = true
      }
      _ => ()
    }
  }
  for offset in 0..<block_span.length {
    let id = block_span.start + offset
    if !blocks[id] {
      continue
    }
    let items = module_.blocks[id].items
    for index in 0..<items.length {
      if module_.block_items[items.start + index].kind
        is PlannedLetItem(local_id, _, _) {
        guard local_id >= 0 && local_id < live.length() else {
          abort("ARN-104 reachable local declaration")
        }
        live[local_id] = true
      }
    }
  }
  for offset in 0..<pattern_span.length {
    let id = pattern_span.start + offset
    module_.patterns[id] = { ..module_.patterns[id], elided: !patterns[id], }
    if !patterns[id] {
      continue
    }
    if module_.patterns[id].reference is PatternBindingReference(local_id) {
      guard local_id >= 0 && local_id < live.length() else {
        abort("ARN-104 reachable pattern local")
      }
      live[local_id] = true
    }
  }
  for offset in 0..<local_span.length {
    let id = local_span.start + offset
    let local_ = module_.locals[id]
    let elided = !(local_.kind is ParameterLocal) && !live[offset]
    module_.locals[id] = { ..local_, elided, }
  }
}

///|
fn prune_compile_time_locals(
  module_ : PlannedModuleLowering,
  active : DeclId?,
  reached : Array[Bool],
  blocks : Array[Bool],
  patterns : Array[Bool],
) -> Unit {
  for body in module_.bodies {
    if active is Some(declaration) && body.declaration != declaration {
      continue
    }
    prune_compile_time_scope_locals(
      module_,
      body.locals,
      body.expressions,
      body.blocks,
      body.patterns,
      reached,
      blocks,
      patterns,
    )
  }
  for lambda in module_.lambdas {
    let owner = module_.bodies[semantic_id_local(lambda.root_body)].declaration
    if active is Some(declaration) && owner != declaration {
      continue
    }
    prune_compile_time_scope_locals(
      module_,
      lambda.locals,
      lambda.expressions,
      lambda.blocks,
      lambda.patterns,
      reached,
      blocks,
      patterns,
    )
  }
}
