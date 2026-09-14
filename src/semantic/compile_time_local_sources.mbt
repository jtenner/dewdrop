///|
// Local and capture IDs are relative to their owner, in both compilers.
priv struct CompileTimeLocalScope {
  expressions : HirSpan
  locals : HirSpan
  captures : HirSpan
}

///|
fn compile_time_scope_owners(
  scopes : Array[CompileTimeLocalScope],
  count : Int,
) -> Array[Int] {
  let owners = Array::make(count, -1)
  for index, scope in scopes {
    guard program_specialization_span_is_valid(scope.expressions, count) else {
      abort("ARN-101 query local scope")
    }
    for offset in 0..<scope.expressions.length {
      let expression = scope.expressions.start + offset
      let old = owners[expression]
      if old < 0 || scope.expressions.length <= scopes[old].expressions.length {
        owners[expression] = index
      }
    }
  }
  owners
}

///|
fn compile_time_local_slot(span : HirSpan, relative : Int, count : Int) -> Int {
  guard program_specialization_span_is_valid(span, count) &&
    relative >= 0 &&
    relative < span.length else {
    abort("ARN-102 query local reference")
  }
  span.start + relative
}

///|
fn compile_time_source_local_scopes(
  collected : CollectedModule,
  names : ResolvedModuleNames,
  body : HirBody,
) -> Array[CompileTimeLocalScope] {
  // A lambda inferencer carries a synthetic body with the root body's ID.
  // Read the root span so enclosing guards and captured initializers remain visible.
  let body = collected.bodies[semantic_id_local(body.id)]
  let scopes : Array[CompileTimeLocalScope] = []
  scopes.push({
    expressions: body.expressions,
    locals: names.body(body.id).unwrap().locals,
    captures: { start: 0, length: 0, },
  })
  for index, lambda in collected.lambdas {
    if lambda.root_body == body.id {
      scopes.push({
        expressions: lambda.body.expressions,
        locals: names.lambdas[index].locals,
        captures: names.lambdas[index].captures,
      })
    }
  }
  scopes
}

///|
fn compile_time_source_local_initializers(
  collected : CollectedModule,
  names : ResolvedModuleNames,
  body : HirBody,
) -> Map[ExprId, ExprId] {
  let scopes = compile_time_source_local_scopes(collected, names, body)
  // Each inference job owns only these spans. A module-sized table here made
  // guards in ordinary functions repeatedly scan every other function.
  let owners : Map[ExprId, Int] = {}
  for index, scope in scopes {
    guard program_specialization_span_is_valid(
      scope.expressions,
      collected.expressions.length(),
    ) else {
      abort("ARN-101 query local scope")
    }
    for offset in 0..<scope.expressions.length {
      let expression = scope.expressions.start + offset
      match names.expression_references[expression] {
        LocalNameReference(_) | LambdaCaptureNameReference(_) => ()
        _ => continue
      }
      match owners.get(expression) {
        Some(old) =>
          if scope.expressions.length <= scopes[old].expressions.length {
            owners[expression] = index
          }
        None => owners[expression] = index
      }
    }
  }
  let result = {}
  for expression, owner in owners {
    let scope = scopes[owner]
    let slot = match names.expression_references[expression] {
      LocalNameReference(local) =>
        compile_time_local_slot(scope.locals, local, names.locals.length())
      LambdaCaptureNameReference(relative) => {
        let capture = names.captures[compile_time_local_slot(
            scope.captures,
            relative,
            names.captures.length(),
          )]
        if capture.mutable_ {
          continue
        }
        let (locals, local) = match capture.source {
          BodyLocalCapture(body, local) =>
            (names.body(body).unwrap().locals, local)
          LambdaLocalCapture(lambda, local) =>
            (names.lambda(lambda).unwrap().locals, local)
        }
        compile_time_local_slot(locals, local, names.locals.length())
      }
      _ => continue
    }
    let local = names.locals[slot]
    if local.kind == LetLocal && !local.mutable_ {
      guard local.source >= 0 && local.source < collected.block_items.length() else {
        abort("ARN-104 query local initializer")
      }
      match collected.block_items[local.source] {
        HirLetItem(_, _, _, value, _) => result[expression] = value
        _ => abort("ARN-106 query local source")
      }
    }
  }
  result
}

///|
fn compile_time_planned_local_initializers(
  module_ : PlannedModuleLowering,
) -> Map[ExprId, ExprId] {
  let scopes : Array[CompileTimeLocalScope] = []
  let initializers = Array::make(module_.locals.length(), -1)
  fn add_scope(
    expressions : HirSpan,
    locals : HirSpan,
    captures : HirSpan,
    blocks : HirSpan,
  ) -> Unit {
    scopes.push({ expressions, locals, captures, })
    guard program_specialization_span_is_valid(blocks, module_.blocks.length()) else {
      abort("ARN-101 query local blocks")
    }
    for offset in 0..<blocks.length {
      let items = module_.blocks[blocks.start + offset].items
      guard program_specialization_span_is_valid(
        items,
        module_.block_items.length(),
      ) else {
        abort("ARN-101 query local items")
      }
      for item in 0..<items.length {
        if module_.block_items[items.start + item].kind
          is PlannedLetItem(local, false, value) {
          initializers[compile_time_local_slot(
            locals,
            local,
            initializers.length(),
          )] = value
        }
      }
    }
  }
  // The body's block span is stored by its root job; lambdas have separate spans.
  for body in module_.bodies {
    add_scope(
      body.expressions,
      body.locals,
      { start: 0, length: 0, },
      body.blocks,
    )
  }
  for lambda in module_.lambdas {
    add_scope(lambda.expressions, lambda.locals, lambda.captures, lambda.blocks)
  }
  let owners = compile_time_scope_owners(scopes, module_.expressions.length())
  let result = {}
  for expression, owner in owners {
    if owner < 0 {
      continue
    }
    let scope = scopes[owner]
    let slot = match module_.expressions[expression].kind {
      PlannedLocalGet(local) =>
        compile_time_local_slot(scope.locals, local, initializers.length())
      PlannedCaptureGet(relative) => {
        let capture = module_.captures[compile_time_local_slot(
            scope.captures,
            relative,
            module_.captures.length(),
          )]
        if capture.mutable_ {
          continue
        }
        let (locals, local) = match capture.source {
          BodyLocalCapture(body, local) =>
            (module_.bodies[semantic_id_local(body)].locals, local)
          LambdaLocalCapture(lambda, local) =>
            (module_.lambdas[lambda].locals, local)
        }
        compile_time_local_slot(locals, local, initializers.length())
      }
      _ => continue
    }
    if initializers[slot] >= 0 {
      result[expression] = initializers[slot]
    }
  }
  result
}
