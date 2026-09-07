///|
// Clone only changed source type nodes. Callable signatures remain generic;
// only source annotations and reads in the selected body use this mapping.
// In particular, a recursive call still instantiates its generic signature.
fn compile_time_inference_types(
  template : PlannedModuleLowering,
  resolved : ResolvedModuleTypes,
  bindings : Map[CompileTimeBindingKey, CompileTimeType],
) -> (ResolvedModuleTypes, Array[ResolvedTypeId]) {
  let arena = {
    ..template,
    resolved_types: template.resolved_types.copy(),
    resolved_type_arguments: template.resolved_type_arguments.copy(),
  }
  let count = template.resolved_types.length()
  let mapping = Array::make(count, -1)
  let marks = Array::make(count, 0)
  let work : Array[(ResolvedTypeId, Bool)] = []
  let nominals = {}
  let traits = {}
  for id, node in arena.resolved_types {
    match node {
      NominalType(declaration) => nominals[declaration] = id
      TraitType(declaration) => traits[declaration] = id
      _ => ()
    }
  }
  fn concrete(type_ : CompileTimeType) -> ResolvedTypeId {
    let node = match type_ {
      CtPrimitive(value) => return resolved.primitive(value)
      CtNominal(declaration) => {
        if nominals.get(declaration) is Some(id) {
          return id
        }
        nominals[declaration] = arena.resolved_types.length()
        NominalType(declaration)
      }
      CtTrait(declaration) => {
        if traits.get(declaration) is Some(id) {
          return id
        }
        traits[declaration] = arena.resolved_types.length()
        TraitType(declaration)
      }
      CtProduct(children) | CtApplied(_, children) | CtFunction(children, _) => {
        let arguments = children.map(concrete)
        let base = match type_ {
          CtApplied(base, _) => concrete(base)
          CtFunction(_, result) => concrete(result)
          _ => -1
        }
        let start = arena.resolved_type_arguments.length()
        for argument in arguments {
          arena.resolved_type_arguments.push(argument)
        }
        let span = { start, length: arguments.length(), }
        match type_ {
          CtProduct(_) => ProductType(span)
          CtApplied(_, _) => AppliedType(base, span)
          _ => FunctionType(span, base)
        }
      }
      _ => abort("SPC-301 source type substitution is not concrete")
    }
    let id = arena.resolved_types.length()
    arena.resolved_types.push(node)
    id
  }
  fn visit(id : ResolvedTypeId) -> Unit {
    guard id >= 0 && id < count else {
      abort("ARN-104 source type substitution child")
    }
    work.push((id, false))
  }
  fn arguments(span : HirSpan) -> Unit {
    guard program_specialization_span_is_valid(
      span,
      template.resolved_type_arguments.length(),
    ) else {
      abort("ARN-101 source type substitution arguments")
    }
    for offset in 0..<span.length {
      visit(template.resolved_type_arguments[span.start + offset])
    }
  }
  fn mapped_arguments(span : HirSpan) -> HirSpan {
    let mut changed = false
    for offset in 0..<span.length {
      let child = template.resolved_type_arguments[span.start + offset]
      if mapping[child] != child {
        changed = true
      }
    }
    if !changed {
      return span
    }
    let start = arena.resolved_type_arguments.length()
    for offset in 0..<span.length {
      let value = mapping[template.resolved_type_arguments[span.start + offset]]
      guard value >= 0 else {
        abort("BOD-604 source type substitution is not closed")
      }
      arena.resolved_type_arguments.push(value)
    }
    { start, length: span.length, }
  }
  for root in 0..<count {
    visit(root)
    while work.length() > 0 {
      let (id, finish) = work.pop().unwrap()
      if marks[id] == 2 {
        continue
      }
      let original = template.resolved_types[id]
      if !finish {
        guard marks[id] == 0 else {
          abort("ARN-104 source type substitution cycle")
        }
        marks[id] = 1
        work.push((id, true))
        match original {
          ProductType(span) => arguments(span)
          AppliedType(base, span) => {
            visit(base)
            arguments(span)
          }
          FunctionType(span, result) => {
            visit(result)
            arguments(span)
          }
          MemberTypeProjection(owner, _, _) => visit(owner)
          _ => ()
        }
        continue
      }
      let replacement = match original {
        GenericParameterType(parameter) | SelfType(parameter) => {
          let key = if original is SelfType(_) {
            CtSelfBinding(parameter)
          } else {
            CtGenericBinding(parameter)
          }
          if bindings.get(key) is Some(type_) {
            mapping[id] = concrete(type_)
          }
          original
        }
        ProductType(span) => ProductType(mapped_arguments(span))
        AppliedType(base, span) =>
          AppliedType(mapping[base], mapped_arguments(span))
        FunctionType(span, result) =>
          FunctionType(mapped_arguments(span), mapping[result])
        MemberTypeProjection(owner, operation, selector) =>
          MemberTypeProjection(mapping[owner], operation, selector)
        _ => original
      }
      if mapping[id] < 0 {
        if replacement == original {
          mapping[id] = id
        } else {
          mapping[id] = arena.resolved_types.length()
          arena.resolved_types.push(replacement)
        }
      }
      marks[id] = 2
    }
  }
  (
    {
      ..resolved,
      types: arena.resolved_types,
      type_arguments: arena.resolved_type_arguments,
      raw_array_declarations: template.raw_array_declarations,
      raw_array_operations: template.raw_array_operations,
    },
    mapping,
  )
}
