///|
// Projection nodes keep their source identity. Only an instance's private
// arenas receive the concrete member types; frozen interfaces remain logical.
fn compile_time_has_projection(
  module_ : PlannedModuleLowering,
  root : BodyTypeId,
) -> Bool {
  let work = [root]
  let seen : Map[BodyTypeId, Bool] = {}
  while work.length() > 0 {
    let id = work.pop().unwrap()
    if seen.contains(id) {
      continue
    }
    seen[id] = true
    if id < -1 {
      match module_.resolved_types[-(id + 2)] {
        MemberTypeProjection(_, _, _) => return true
        ProductType(args)
        | AppliedType(_, args)
        | FunctionType(args, _) as type_ => {
          for offset in 0..<args.length {
            work.push(-module_.resolved_type_arguments[args.start + offset] - 2)
          }
          match type_ {
            AppliedType(base, _) => work.push(-base - 2)
            FunctionType(_, result) => work.push(-result - 2)
            _ => ()
          }
        }
        _ => ()
      }
    } else if id >= 0 {
      match module_.types[id] {
        BodyMemberTypeProjection(_, _, _) => return true
        BodyResolvedType(type_) => work.push(-type_ - 2)
        BodyProductType(args)
        | BodyAppliedType(_, args)
        | BodyFunctionType(args, _) as type_ => {
          for offset in 0..<args.length {
            work.push(module_.type_arguments[args.start + offset])
          }
          match type_ {
            BodyAppliedType(base, _) => work.push(base)
            BodyFunctionType(_, result) => work.push(result)
            _ => ()
          }
        }
        _ => ()
      }
    }
  }
  false
}

///|
fn compile_time_projected_signature(
  module_ : PlannedModuleLowering,
  callable : PlannedCallable,
) -> Bool {
  if program_callable_generic_parameters(callable).length == 0 {
    return false
  }
  if compile_time_has_projection(module_, -callable.result_type - 2) {
    return true
  }
  for offset in 0..<callable.parameters.length {
    if compile_time_has_projection(
        module_,
        -module_.functions.parameters[callable.parameters.start + offset].type_ -
        2,
      ) {
      return true
    }
  }
  false
}

///|
fn compile_time_append_resolved(
  module_ : PlannedModuleLowering,
  type_ : CompileTimeType,
) -> ResolvedTypeId {
  let node = match type_ {
    CtPrimitive(value) => PrimitiveType(value)
    CtNominal(value) => NominalType(value)
    CtTrait(value) => TraitType(value)
    CtProduct(fields) | CtApplied(_, fields) | CtFunction(fields, _) => {
      let children = fields.map(value => {
        compile_time_append_resolved(module_, value)
      })
      let base = match type_ {
        CtApplied(base, _) => compile_time_append_resolved(module_, base)
        CtFunction(_, result) => compile_time_append_resolved(module_, result)
        _ => -1
      }
      let start = module_.resolved_type_arguments.length()
      for child in children {
        module_.resolved_type_arguments.push(child)
      }
      let span = { start, length: children.length(), }
      match type_ {
        CtProduct(_) => ProductType(span)
        CtApplied(_, _) => AppliedType(base, span)
        _ => FunctionType(span, base)
      }
    }
    _ => abort("SPC-301 instance member type is not concrete")
  }
  let id = module_.resolved_types.length()
  module_.resolved_types.push(node)
  id
}

///|
fn compile_time_instance_type(
  context : CompileTimeProgramContext,
  source : PlannedModuleLowering,
  instance : PlannedModuleLowering,
  bindings : Map[GenericParameterId, CompileTimeType],
  root : BodyTypeId,
  cache : Map[BodyTypeId, ResolvedTypeId],
  offset : UInt64,
) -> ResolvedTypeId? {
  if !compile_time_has_projection(source, root) {
    return None
  }
  if cache.get(root) is Some(id) {
    return Some(id)
  }
  let logical = match compile_time_read_type(source, root, bindings) {
    Ok(value) => value
    Err(_) => {
      instance.diagnostics.push(
        CompileTimeQueryDiagnostic(
          -1, "CT-033 invalid instance member type", offset,
        ),
      )
      return None
    }
  }
  let concrete = match
    reduce_compile_time_projections(context, source, logical, 0) {
    Ok(value) => value
    Err(message) => {
      instance.diagnostics.push(CompileTimeQueryDiagnostic(-1, message, offset))
      return None
    }
  }
  if compile_time_types_are_concrete([concrete]) != Ok(true) {
    instance.diagnostics.push(
      CompileTimeQueryDiagnostic(
        -1, "CT-033 unresolved instance member type", offset,
      ),
    )
    return None
  }
  let id = compile_time_append_resolved(instance, concrete)
  cache[root] = id
  Some(id)
}

///|
fn materialize_compile_time_instance_types(
  context : CompileTimeProgramContext,
  source : PlannedModuleLowering,
  instance : PlannedModuleLowering,
  bindings : Map[GenericParameterId, CompileTimeType],
  declaration : DeclId,
) -> Unit {
  let cache : Map[BodyTypeId, ResolvedTypeId] = {}
  let offset = source.functions.callable_of(declaration).unwrap().offset
  fn materialize(root : BodyTypeId) -> BodyTypeId {
    match
      compile_time_instance_type(
        context, source, instance, bindings, root, cache, offset,
      ) {
      Some(id) => -id - 2
      None => root
    }
  }
  fn nominal(root : BodyTypeId, original : DeclId) -> DeclId {
    if root >= -1 || -(root + 2) < source.resolved_types.length() {
      return original
    }
    let mut id = -(root + 2)
    while true {
      match instance.resolved_types[id] {
        NominalType(declaration) | TraitType(declaration) => return declaration
        AppliedType(base, _) => id = base
        _ => return 0UL
      }
    }
    0UL
  }
  fn shape(
    root : BodyTypeId,
    original : PlannedValueShape,
  ) -> PlannedValueShape {
    if root < -1 && -(root + 2) >= source.resolved_types.length() {
      planned_value_shape_from_resolved_types(
        instance.resolved_types,
        instance.resolved_type_arguments,
        -(root + 2),
      )
    } else {
      original
    }
  }
  for index, callable in source.functions.callables {
    if callable.declaration != declaration {
      continue
    }
    for offset in 0..<callable.parameters.length {
      let index = callable.parameters.start + offset
      let parameter = source.functions.parameters[index]
      let type_ = materialize(-parameter.type_ - 2)
      instance.functions.parameters[index] = {
        ..parameter,
        type_: -(type_ + 2),
        shape: shape(type_, parameter.shape),
      }
    }
    let type_ = materialize(-callable.result_type - 2)
    instance.functions.callables[index] = {
      ..callable,
      result_type: -(type_ + 2),
      result_shape: shape(type_, callable.result_shape),
    }
  }
  for index, body in instance.bodies {
    if body.declaration != declaration {
      continue
    }
    for id in compile_time_owned_expressions(instance, body) {
      let expression = instance.expressions[id]
      if expression.kind is PlannedPoisonExpression ||
        expression.kind is PlannedConsumedExpression {
        continue
      }
      let type_ = materialize(expression.type_)
      instance.expressions[id] = {
        ..expression,
        type_,
        shape: shape(type_, expression.shape),
        nominal: nominal(type_, expression.nominal),
      }
    }
    for offset in 0..<body.locals.length {
      let id = body.locals.start + offset
      let local = instance.locals[id]
      if local.elided {
        continue
      }
      let type_ = materialize(local.type_)
      instance.locals[id] = {
        ..local,
        type_,
        shape: shape(type_, local.shape),
        nominal: nominal(type_, local.nominal),
      }
    }
    for offset in 0..<body.patterns.length {
      let id = body.patterns.start + offset
      let pattern = instance.patterns[id]
      if pattern.elided {
        continue
      }
      let type_ = materialize(pattern.type_)
      instance.patterns[id] = {
        ..pattern,
        type_,
        shape: shape(type_, pattern.shape),
      }
    }
    let root_type = materialize(body.root_type)
    instance.bodies[index] = {
      ..body,
      root_type,
      root_shape: shape(root_type, body.root_shape),
      result_shape: shape(root_type, body.result_shape),
    }
  }
  for id, lambda in instance.lambdas {
    if lambda.elided {
      continue
    }
    let mut owned = false
    for body in instance.bodies {
      if body.body == lambda.root_body && body.declaration == declaration {
        owned = true
        break
      }
    }
    if !owned {
      continue
    }
    let type_ = materialize(lambda.root_type)
    instance.lambdas[id] = {
      ..lambda,
      root_type: type_,
      root_shape: shape(type_, lambda.root_shape),
      result_shape: shape(type_, lambda.result_shape),
    }
    for offset in 0..<lambda.locals.length {
      let id = lambda.locals.start + offset
      let local = instance.locals[id]
      if local.elided {
        continue
      }
      let type_ = materialize(local.type_)
      instance.locals[id] = {
        ..local,
        type_,
        shape: shape(type_, local.shape),
        nominal: nominal(type_, local.nominal),
      }
    }
    for offset in 0..<lambda.captures.length {
      let id = lambda.captures.start + offset
      let capture = instance.captures[id]
      let type_ = materialize(capture.type_)
      instance.captures[id] = {
        ..capture,
        type_,
        shape: shape(type_, capture.shape),
        nominal: nominal(type_, capture.nominal),
      }
    }
  }
}
