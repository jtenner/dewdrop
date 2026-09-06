///|
fn program_mark_resolved_nominal_roots(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
  reachable : Map[DeclId, Bool],
  discovered? : Array[DeclId] = [],
) -> Bool {
  let mut changed = false
  let work : Array[ResolvedTypeId] = [root]
  let visited : Map[ResolvedTypeId, Bool] = {}
  while work.length() > 0 {
    let type_ = work.pop().unwrap()
    if type_ < 0 || type_ >= resolved.types.length() {
      continue
    }
    if visited.contains(type_) {
      continue
    }
    visited[type_] = true
    match resolved.types[type_] {
      NominalType(declaration) =>
        if !reachable.contains(declaration) {
          reachable[declaration] = true
          discovered.push(declaration)
          changed = true
        }
      ProductType(arguments) => {
        guard program_specialization_span_is_valid(
          arguments,
          resolved.type_arguments.length(),
        ) else {
          abort("ARN-101 nominal demand tuple fields")
        }
        for offset in 0..<arguments.length {
          work.push(resolved.type_arguments[arguments.start + offset])
        }
      }
      AppliedType(base, arguments) => {
        work.push(base)
        for index in 0..<arguments.length {
          work.push(resolved.type_arguments[arguments.start + index])
        }
      }
      FunctionType(parameters, result) => {
        work.push(result)
        for index in 0..<parameters.length {
          work.push(resolved.type_arguments[parameters.start + index])
        }
      }
      _ => ()
    }
  }
  changed
}

///|
fn program_variant_declaration(
  lowering : PlannedProgramLowering,
  module_lookup : Map[ModuleId, Int],
  variant : VariantId,
) -> DeclId? {
  let owner = match module_lookup.get(semantic_id_module(variant)) {
    Some(value) => value
    None => return None
  }
  for candidate in lowering.modules[owner].type_layouts.variants {
    if candidate.variant == variant {
      return Some(candidate.declaration)
    }
  }
  None
}

///|
fn program_add_named_callable_root(
  lowering : PlannedProgramLowering,
  name : Bytes,
  reachable : Map[DeclId, Bool],
) -> Bool {
  for module_ in lowering.modules {
    for callable in module_.functions.callables {
      match callable.kind {
        PlannedBuiltinCallable(candidate) =>
          if candidate == name {
            if reachable.contains(callable.declaration) {
              return false
            }
            reachable[callable.declaration] = true
            return true
          }
        _ => ()
      }
    }
  }
  false
}

///|
fn program_body_uses_string_literal_pattern(
  module_ : PlannedModuleLowering,
  body : PlannedBodyLowering,
) -> Bool {
  for
    pattern in body.patterns.start..<(body.patterns.start + body.patterns.length) {
    if module_.patterns[pattern].elided {
      continue
    }
    match module_.patterns[pattern].source {
      HirLiteralPattern(expression, _) =>
        match module_.expressions[expression].kind {
          PlannedStringConst(_) => return true
          _ => ()
        }
      _ => ()
    }
  }
  false
}

///|
fn program_reachable_callable_roots(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  emit_tests : Bool,
  selected : Map[DeclId, Array[PlannedModuleLowering]],
) -> Map[DeclId, Bool] {
  let module_lookup = lowering.index.module_lookup
  let reachable : Map[DeclId, Bool] = Map::default()
  let work : Array[DeclId] = []
  let mut needs_string_pattern_equals = false
  for module_ in lowering.modules {
    for callable in module_.functions.callables {
      let elided_trait_wrapper = lowering.elided_trait_wrappers.contains(
        callable.declaration,
      )
      if (callable.visibility == Public || !callable.compiler_owned) &&
        !elided_trait_wrapper &&
        (!callable.is_test || emit_tests) {
        reachable[callable.declaration] = true
        work.push(callable.declaration)
      }
    }
  }
  for module_ in lowering.modules {
    for evidence in module_.trait_evidence {
      let implementation = match evidence.kind {
        ConcreteInferredTraitEvidence(implementation, _) => implementation
        BoundInferredTraitEvidence(_) | GuardedInferredTraitEvidence(_, _) =>
          continue
      }
      let owner_index = match
        module_lookup.get(semantic_id_module(implementation)) {
        Some(value) => value
        None => continue
      }
      for callable in lowering.modules[owner_index].functions.callables {
        match callable.kind {
          PlannedImplMethodCallable(owner, _) if owner == implementation =>
            if !reachable.contains(callable.declaration) {
              reachable[callable.declaration] = true
              work.push(callable.declaration)
            }
          _ => ()
        }
      }
    }
  }
  for module_ in lowering.modules {
    for step in module_.initialization.steps {
      if step.test_only && !emit_tests {
        continue
      }
      let body_id = match step.kind {
        PlannedInitializeModuleValue(_, body, _) => body
        PlannedCyclicModuleValues(_) => continue
      }
      let body_index = semantic_id_local(body_id)
      if body_index < 0 || body_index >= module_.bodies.length() {
        continue
      }
      let body = module_.bodies[body_index]
      if program_body_uses_string_literal_pattern(module_, body) {
        needs_string_pattern_equals = true
      }
      for
        expression in body.expressions.start..<(body.expressions.start +
        body.expressions.length) {
        let target = match module_.expressions[expression].kind {
          PlannedDirectCall(target, _, _, _)
          | PlannedTailCall(target, _, _, _)
          | PlannedOperatorCall(target, _, _, _, _)
          | PlannedIndexCall(target, _, _, _)
          | PlannedIndexSetCall(target, _, _, _, _) => target
          _ => continue
        }
        if target != 0UL && !reachable.contains(target) {
          reachable[target] = true
          work.push(target)
        }
      }
    }
  }
  while work.length() > 0 {
    let declaration = work.pop().unwrap()
    let module_index = match
      module_lookup.get(semantic_id_module(declaration)) {
      Some(value) => value
      None => continue
    }
    let module_ = lowering.modules[module_index]
    for
      module_ in compile_time_demand_modules(
        lowering, module_, declaration, selected,
      ) {
      let callable = match module_.functions.callable_of(declaration) {
        Some(value) => value
        None => continue
      }
      let body_id = match callable.kind {
        PlannedFunctionCallable(body)
        | PlannedImplMethodCallable(_, Some(body)) => body
        _ => continue
      }
      let body_index = semantic_id_local(body_id)
      if body_index < 0 || body_index >= module_.bodies.length() {
        continue
      }
      let body = module_.bodies[body_index]
      if program_body_uses_string_literal_pattern(module_, body) {
        needs_string_pattern_equals = true
      }
      for
        expression in body.expressions.start..<(body.expressions.start +
        body.expressions.length) {
        let (first_target, second_target) = match
          module_.expressions[expression].kind {
          PlannedDirectCall(target, _, _, _)
          | PlannedTailCall(target, _, _, _)
          | PlannedOperatorCall(target, _, _, _, _)
          | PlannedIndexCall(target, _, _, _)
          | PlannedIndexSetCall(target, _, _, _, _) => (target, 0UL)
          PlannedMapSingleton(_, _, _, _, hash, eq)
          | PlannedMapEmpty(_, _, hash, eq)
          | PlannedMapGet(_, _, _, _, hash, eq)
          | PlannedMapGetUnchecked(_, _, _, _, hash, eq) => (hash, eq)
          PlannedMapInsert(_, _, _, _, _, hash, eq)
          | PlannedMapSet(_, _, _, _, _, hash, eq) => (hash, eq)
          PlannedMapContainsKey(_, _, _, hash, eq)
          | PlannedMapRemove(_, _, _, hash, eq) => (hash, eq)
          PlannedSetEmpty(_, hash, eq)
          | PlannedSetSingleton(_, _, hash, eq)
          | PlannedSetContains(_, _, _, hash, eq)
          | PlannedSetInsert(_, _, _, hash, eq)
          | PlannedSetRemove(_, _, _, hash, eq) => (hash, eq)
          _ => continue
        }
        for target in [first_target, second_target] {
          if target == 0UL || reachable.contains(target) {
            continue
          }
          let owner = match module_lookup.get(semantic_id_module(target)) {
            Some(value) => value
            None => continue
          }
          let target_callable = match
            lowering.modules[owner].functions.callable_of(target) {
            Some(value) => value
            None => continue
          }
          if target_callable.is_test && !emit_tests {
            continue
          }
          reachable[target] = true
          work.push(target)
        }
      }
    }
  }
  if needs_string_pattern_equals {
    ignore(
      program_add_named_callable_root(lowering, b"dew_string_equals", reachable),
    )
  }
  let mut runtime_changed = true
  while runtime_changed {
    runtime_changed = false
    for module_ in lowering.modules {
      for callable in module_.functions.callables {
        if !reachable.contains(callable.declaration) {
          continue
        }
        match callable.kind {
          PlannedBuiltinCallable(name) =>
            if name == b"dew_bytes_to_string" {
              runtime_changed = program_add_named_callable_root(
                  lowering, b"dew_bytes_is_valid_utf8", reachable,
                ) ||
                runtime_changed
            } else if name == b"dew_test_assert" {
              runtime_changed = program_add_named_callable_root(
                  lowering, b"dew_string_as_bytes", reachable,
                ) ||
                runtime_changed
              runtime_changed = program_add_named_callable_root(
                  lowering, b"dew_wasi_fd_write", reachable,
                ) ||
                runtime_changed
            } else if wasmgc_builtin_is_debug_runtime(name) {
              runtime_changed = program_add_named_callable_root(
                  lowering, b"wasi_snapshot_preview1.fd_write", reachable,
                ) ||
                runtime_changed
            } else if name == b"dew_wasi_fd_write" {
              runtime_changed = program_add_named_callable_root(
                  lowering, b"wasi_snapshot_preview1.fd_write", reachable,
                ) ||
                runtime_changed
            } else if name == b"dew_wasi_fd_read" {
              runtime_changed = program_add_named_callable_root(
                  lowering, b"wasi_snapshot_preview1.fd_read", reachable,
                ) ||
                runtime_changed
            }
          _ => ()
        }
      }
    }
  }
  for module_index, module_ in lowering.modules {
    for callable in module_.functions.callables {
      if !reachable.contains(callable.declaration) {
        continue
      }
      for
        module_ in compile_time_demand_modules(
          lowering,
          module_,
          callable.declaration,
          selected,
        ) {
        let callable = module_.functions
          .callable_of(callable.declaration)
          .unwrap()
        let resolved = {
          ..analyzed.frozen.interfaces[module_index].resolved_types,
          types: module_.resolved_types,
          type_arguments: module_.resolved_type_arguments,
        }
        for index in 0..<callable.parameters.length {
          let parameter = module_.functions.parameters[callable.parameters.start +
            index]
          if compile_time_shape_has_reference(parameter.shape) {
            ignore(
              program_mark_resolved_nominal_roots(
                resolved,
                parameter.type_,
                reachable,
              ),
            )
          }
        }
        if compile_time_shape_has_reference(callable.result_shape) {
          ignore(
            program_mark_resolved_nominal_roots(
              resolved,
              callable.result_type,
              reachable,
            ),
          )
        }
        if callable.has_receiver {
          ignore(
            program_mark_resolved_nominal_roots(
              resolved,
              callable.self_type,
              reachable,
            ),
          )
        }
        let body_id = match callable.kind {
          PlannedFunctionCallable(body)
          | PlannedImplMethodCallable(_, Some(body)) => body
          _ => continue
        }
        let body_index = semantic_id_local(body_id)
        if body_index < 0 || body_index >= module_.bodies.length() {
          continue
        }
        let body = module_.bodies[body_index]
        for expression in compile_time_owned_expressions(module_, body) {
          let value = module_.expressions[expression]
          if !(value.kind is PlannedPoisonExpression ||
            value.kind is PlannedConsumedExpression) &&
            compile_time_shape_has_reference(value.shape) {
            let root = program_body_resolved_type(module_, value.type_)
            if root >= 0 {
              ignore(
                program_mark_resolved_nominal_roots(resolved, root, reachable),
              )
            }
          }
          match module_.expressions[expression].kind {
            PlannedStructNew(declaration, _, _) => reachable[declaration] = true
            PlannedArrayLiteral(_, _, _) =>
              reachable[standard_array_type_declaration()] = true
            PlannedFixedArrayMake(_, _, _)
            | PlannedFixedArrayLength(_, _)
            | PlannedFixedArrayGet(_, _, _)
            | PlannedFixedArrayGetUnchecked(_, _, _)
            | PlannedFixedArraySetUnchecked(_, _, _, _) =>
              reachable[standard_fixed_array_type_declaration()] = true
            PlannedMapSingleton(_, _, _, _, _, _)
            | PlannedMapEmpty(_, _, _, _)
            | PlannedMapLength(_)
            | PlannedMapGet(_, _, _, _, _, _)
            | PlannedMapGetUnchecked(_, _, _, _, _, _)
            | PlannedMapInsert(_, _, _, _, _, _, _)
            | PlannedMapSet(_, _, _, _, _, _, _)
            | PlannedMapContainsKey(_, _, _, _, _)
            | PlannedMapRemove(_, _, _, _, _)
            | PlannedMapClear(_) =>
              reachable[standard_map_type_declaration()] = true
            PlannedSetEmpty(_, _, _)
            | PlannedSetSingleton(_, _, _, _)
            | PlannedSetLength(_)
            | PlannedSetIsEmpty(_)
            | PlannedSetContains(_, _, _, _, _)
            | PlannedSetInsert(_, _, _, _, _)
            | PlannedSetRemove(_, _, _, _, _)
            | PlannedSetClear(_) =>
              reachable[standard_set_type_declaration()] = true
            PlannedUnitVariant(variant, _)
            | PlannedVariantTupleNew(variant, _, _)
            | PlannedVariantStructNew(variant, _, _) => {
              if module_.expressions[expression].shape is I32PlannedValueShape ||
                module_.expressions[expression].shape is I64PlannedValueShape {
                continue
              }
              match
                program_variant_declaration(lowering, module_lookup, variant) {
                Some(declaration) => reachable[declaration] = true
                None => ()
              }
            }
            _ => ()
          }
        }
        for
          pattern in body.patterns.start..<(body.patterns.start +
          body.patterns.length) {
          if module_.patterns[pattern].elided {
            continue
          }
          match module_.patterns[pattern].selected_constructor {
            StructInferredPatternConstructor(declaration, _) =>
              reachable[declaration] = true
            VariantInferredPatternConstructor(variant, _) => {
              if module_.patterns[pattern].shape is I32PlannedValueShape ||
                module_.patterns[pattern].shape is I64PlannedValueShape {
                continue
              }
              match
                program_variant_declaration(lowering, module_lookup, variant) {
                Some(declaration) => reachable[declaration] = true
                None => ()
              }
            }
            _ => ()
          }
        }
      }
    }
  }
  let nominal_work : Array[DeclId] = []
  let nominal_seen : Map[DeclId, Bool] = {}
  for module_ in lowering.modules {
    for layout in module_.type_layouts.layouts {
      if reachable.contains(layout.declaration) {
        nominal_work.push(layout.declaration)
      }
    }
  }
  while nominal_work.length() > 0 {
    let declaration = nominal_work.pop().unwrap()
    if nominal_seen.contains(declaration) {
      continue
    }
    nominal_seen[declaration] = true
    let owner = lowering.index.declaration_owner(declaration).unwrap()
    let module_ = lowering.modules[owner]
    let resolved = analyzed.frozen.interfaces[owner].resolved_types
    let layout = module_.type_layouts.layout_of(declaration).unwrap()
    let roots : Array[ResolvedTypeId] = []
    match layout.kind {
      PlannedStructLayout(fields) =>
        for offset in 0..<fields.length {
          roots.push(module_.type_layouts.fields[fields.start + offset].type_)
        }
      PlannedEnumLayout(variants) =>
        for offset in 0..<variants.length {
          match module_.type_layouts.variants[variants.start + offset].payload {
            PlannedUnitVariantLayout => ()
            PlannedTupleVariantLayout(types) =>
              for offset in 0..<types.length {
                roots.push(
                  module_.type_layouts.payload_types[types.start + offset],
                )
              }
            PlannedStructVariantLayout(fields) =>
              for offset in 0..<fields.length {
                roots.push(
                  module_.type_layouts.fields[fields.start + offset].type_,
                )
              }
          }
        }
      PlannedForeignTypeLayout => ()
    }
    for root in roots {
      ignore(
        program_mark_resolved_nominal_roots(
          resolved,
          root,
          reachable,
          discovered=nominal_work,
        ),
      )
    }
  }
  reachable
}

///|
priv struct ProgramTraitEvidenceRequest {
  roots : Array[Int]
  evidence : Array[PlannedSpecializationTraitEvidence]
  children : Array[Int]
  arguments : Array[PlannedValueShape]
}

///|
fn empty_program_trait_evidence_request() -> ProgramTraitEvidenceRequest {
  { roots: [], evidence: [], children: [], arguments: [], }
}

///|
fn write_program_trait_evidence_key(
  output : Buffer,
  request : ProgramTraitEvidenceRequest,
  node : Int,
) -> Unit {
  guard node >= 0 && node < request.evidence.length() else {
    output.write_string_utf8("invalid")
    return
  }
  let evidence = request.evidence[node]
  match evidence.kind {
    PlannedConcreteTraitEvidence(implementation, arguments) => {
      output.write_string_utf8(implementation.to_string())
      output.write_string_utf8("<")
      for index in 0..<arguments.length {
        if index > 0 {
          output.write_string_utf8(",")
        }
        output.write_string_utf8(
          program_specialization_shape_name(
            request.arguments[arguments.start + index],
          ),
        )
      }
      output.write_string_utf8(">")
    }
    PlannedRuntimeTraitEvidence(trait_, parameter) => {
      output.write_string_utf8("runtime<")
      output.write_string_utf8(trait_.to_string())
      output.write_string_utf8(",")
      output.write_string_utf8(parameter.to_string())
      output.write_string_utf8(">")
    }
  }
  output.write_string_utf8("[")
  for index in 0..<evidence.prerequisites.length {
    if index > 0 {
      output.write_string_utf8(",")
    }
    write_program_trait_evidence_key(
      output,
      request,
      request.children[evidence.prerequisites.start + index],
    )
  }
  output.write_string_utf8("]")
}

///|
fn normalize_program_runtime_evidence_parameters(
  request : ProgramTraitEvidenceRequest,
) -> Array[Int]? {
  let parameter_slots : Map[Int, Int] = Map::default()
  let parameters : Array[Int] = []
  for index, node in request.evidence {
    match node.kind {
      PlannedRuntimeTraitEvidence(trait_, source_parameter) => {
        if source_parameter < 0 {
          return None
        }
        let slot = match parameter_slots.get(source_parameter) {
          Some(value) => value
          None => {
            let value = parameters.length()
            parameter_slots[source_parameter] = value
            parameters.push(source_parameter)
            value
          }
        }
        request.evidence[index] = {
          ..node,
          kind: PlannedRuntimeTraitEvidence(trait_, slot),
        }
      }
      PlannedConcreteTraitEvidence(_, _) => ()
    }
  }
  Some(parameters)
}

///|
fn program_specialization_abi_key(
  declaration : DeclId,
  shapes : Array[PlannedValueShape],
  span : HirSpan,
  evidence : ProgramTraitEvidenceRequest,
) -> String {
  let output = Buffer(
    size_hint=32 + span.length * 8 + evidence.evidence.length() * 24,
  )
  output.write_string_utf8(declaration.to_string())
  output.write_string_utf8(":")
  for index in 0..<span.length {
    if index > 0 {
      output.write_string_utf8(",")
    }
    output.write_string_utf8(
      program_specialization_shape_name(shapes[span.start + index]),
    )
  }
  if evidence.roots.length() > 0 {
    output.write_string_utf8("|e=")
    for index, root in evidence.roots {
      if index > 0 {
        output.write_string_utf8(";")
      }
      write_program_trait_evidence_key(output, evidence, root)
    }
  }
  @utf8.decode_lossy(output.to_bytes())
}

///|
fn program_specialization_value_type(
  shape : PlannedValueShape,
) -> PlannedWasmValueType? {
  match shape {
    UnitPlannedValueShape | NeverPlannedValueShape => None
    I8PlannedValueShape
    | U8PlannedValueShape
    | I16PlannedValueShape
    | U16PlannedValueShape
    | I32PlannedValueShape
    | U32PlannedValueShape
    | Swar32PlannedValueShape => Some(WasmI32Value)
    I64PlannedValueShape | U64PlannedValueShape | Swar64PlannedValueShape =>
      Some(WasmI64Value)
    F32PlannedValueShape => Some(WasmF32Value)
    F64PlannedValueShape => Some(WasmF64Value)
    V128PlannedValueShape => Some(WasmV128Value)
    RefPlannedValueShape | ProductPlannedValueShape(_) =>
      Some(WasmNullableEqRefValue)
    GenericPlannedValueShape | ErrorPlannedValueShape =>
      abort(
        "SPC-301 invalid physical specialization shape=\{program_specialization_shape_name(shape)}",
      )
  }
}

///|
fn program_specialization_shapes_equal(
  values : Array[PlannedValueShape],
  left : HirSpan,
  right_values : Array[PlannedValueShape],
  right : HirSpan,
) -> Bool {
  if left.length != right.length {
    return false
  }
  for index in 0..<left.length {
    if program_canonical_specialization_shape(values[left.start + index]) !=
      program_canonical_specialization_shape(right_values[right.start + index]) {
      return false
    }
  }
  true
}

///|
fn program_generic_parameter_shape(
  resolved : ResolvedModuleTypes,
  type_ : ResolvedTypeId,
  generic_parameters : HirSpan,
  shapes : Array[PlannedValueShape],
  shape_span : HirSpan,
) -> PlannedValueShape? {
  match resolved.types[type_] {
    GenericParameterType(parameter) => {
      let parameter_local = semantic_id_local(parameter)
      if parameter_local >= generic_parameters.start &&
        parameter_local < generic_parameters.start + generic_parameters.length {
        let relative = parameter_local - generic_parameters.start
        if relative < shape_span.length {
          return Some(shapes[shape_span.start + relative])
        }
      }
      None
    }
    ProductType(fields) => {
      let field_shapes : Array[PlannedValueShape] = []
      let mut specialized = false
      for index in 0..<fields.length {
        let field_type = resolved.type_arguments[fields.start + index]
        match
          program_generic_parameter_shape(
            resolved, field_type, generic_parameters, shapes, shape_span,
          ) {
          Some(shape) => {
            field_shapes.push(shape)
            specialized = true
          }
          None =>
            field_shapes.push(
              planned_value_shape_from_resolved_types(
                resolved.types,
                resolved.type_arguments,
                field_type,
              ),
            )
        }
      }
      if specialized {
        Some(ProductPlannedValueShape(field_shapes))
      } else {
        None
      }
    }
    _ => None
  }
}

///|
fn program_specialization_shape_width(shape : PlannedValueShape) -> Int {
  match shape {
    ProductPlannedValueShape(fields) => {
      let mut width = 0
      for field in fields {
        width += program_specialization_shape_width(field)
      }
      width
    }
    UnitPlannedValueShape | NeverPlannedValueShape => 0
    _ => 1
  }
}

///|
fn program_append_specialization_value_types(
  output : Array[PlannedWasmValueType],
  shape : PlannedValueShape,
) -> Unit {
  match shape {
    ProductPlannedValueShape(fields) =>
      for field in fields {
        program_append_specialization_value_types(output, field)
      }
    _ =>
      match program_specialization_value_type(shape) {
        Some(value) => output.push(value)
        None => ()
      }
  }
}

///|
fn program_fixed_array_specialization_value_type(
  resolved : ResolvedModuleTypes,
  type_ : ResolvedTypeId,
  generic_parameters : HirSpan,
  shapes : Array[PlannedValueShape],
  shape_span : HirSpan,
) -> PlannedWasmValueType? {
  guard type_ >= 0 && type_ < resolved.types.length() else { return None }
  match resolved.types[type_] {
    AppliedType(base, arguments) if arguments.length == 1 =>
      match resolved.types[base] {
        NominalType(declaration) if declaration ==
          standard_fixed_array_type_declaration() =>
          match
            program_generic_parameter_shape(
              resolved,
              resolved.type_arguments[arguments.start],
              generic_parameters,
              shapes,
              shape_span,
            ) {
            Some(shape) => {
              let carrier = wasmgc_raw_array_storage_carrier(shape)
              if carrier >= 0 {
                Some(WasmFixedArrayRefValue(carrier))
              } else {
                Some(WasmNullableEqRefValue)
              }
            }
            None => None
          }
        _ => None
      }
    _ => None
  }
}

///|
fn program_resolve_specialized_shape(
  module_ : PlannedModuleLowering,
  generic_parameters : HirSpan,
  specialization_values : Array[PlannedValueShape],
  specialization : HirSpan,
  type_ : BodyTypeId,
  fallback : PlannedValueShape,
) -> PlannedValueShape {
  let resolved_type = if type_ < -1 {
    -type_ - 2
  } else if type_ >= 0 && type_ < module_.types.length() {
    match module_.types[type_] {
      BodyResolvedType(value) => value
      _ => -1
    }
  } else {
    -1
  }
  if resolved_type >= 0 && resolved_type < module_.resolved_types.length() {
    match module_.resolved_types[resolved_type] {
      GenericParameterType(parameter) => {
        let parameter_local = semantic_id_local(parameter)
        if parameter_local >= generic_parameters.start &&
          parameter_local < generic_parameters.start + generic_parameters.length {
          let relative = parameter_local - generic_parameters.start
          if relative < specialization.length {
            return specialization_values[specialization.start + relative]
          }
        }
      }
      _ => ()
    }
  }
  fallback
}

///|
fn copy_program_specialization_evidence_node(
  source : PlannedModuleWasmGCFragments,
  source_node : Int,
  request : ProgramTraitEvidenceRequest,
) -> Int {
  guard source_node >= 0 &&
    source_node < source.specialization_trait_evidence.length() else {
    return -1
  }
  let source_evidence = source.specialization_trait_evidence[source_node]
  let kind = match source_evidence.kind {
    PlannedConcreteTraitEvidence(implementation, arguments) => {
      let argument_start = request.arguments.length()
      for index in 0..<arguments.length {
        request.arguments.push(
          source.specialization_evidence_arguments[arguments.start + index],
        )
      }
      PlannedConcreteTraitEvidence(implementation, {
        start: argument_start,
        length: arguments.length,
      })
    }
    PlannedRuntimeTraitEvidence(trait_, parameter) =>
      PlannedRuntimeTraitEvidence(trait_, parameter)
  }
  let direct_children : Array[Int] = []
  for index in 0..<source_evidence.prerequisites.length {
    let child = copy_program_specialization_evidence_node(
      source,
      source.specialization_evidence_children[source_evidence.prerequisites.start +
      index],
      request,
    )
    if child < 0 {
      return -1
    }
    direct_children.push(child)
  }
  let child_start = request.children.length()
  for child in direct_children {
    request.children.push(child)
  }
  let node = request.evidence.length()
  request.evidence.push({
    kind,
    prerequisites: {
      start: child_start,
      length: source_evidence.prerequisites.length,
    },
  })
  node
}

///|
fn resolve_program_lowering_evidence_node_with_specialization(
  lowering : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  specialization_shapes : HirSpan,
  specialization_evidence : HirSpan,
  has_specialization : Bool,
  source_node : Int,
  request : ProgramTraitEvidenceRequest,
) -> Int {
  guard source_node >= 0 && source_node < lowering.trait_evidence.length() else {
    return -1
  }
  let source = lowering.trait_evidence[source_node]
  match source.kind {
    GuardedInferredTraitEvidence(_, _) => {
      if has_specialization {
        abort(
          "CT-041 branch evidence reached physical specialization unresolved",
        )
      }
      -1
    }
    BoundInferredTraitEvidence(slot) => {
      if !has_specialization ||
        slot < 0 ||
        slot >= specialization_evidence.length {
        return -1
      }
      copy_program_specialization_evidence_node(
        fragments,
        fragments.specialization_evidence_roots[specialization_evidence.start +
        slot],
        request,
      )
    }
    ConcreteInferredTraitEvidence(implementation, arguments) => {
      let argument_start = request.arguments.length()
      for index in 0..<arguments.length {
        match lowering.trait_evidence_arguments[arguments.start + index] {
          ShapeInferredTraitEvidenceArgument(shape) =>
            request.arguments.push(
              program_canonical_specialization_shape(shape),
            )
          GenericInferredTraitEvidenceArgument(parameter) => {
            if !has_specialization ||
              parameter < 0 ||
              parameter >= specialization_shapes.length {
              return -1
            }
            request.arguments.push(
              program_canonical_specialization_shape(
                fragments.specialization_shapes[specialization_shapes.start +
                parameter],
              ),
            )
          }
        }
      }
      let direct_children : Array[Int] = []
      for index in 0..<source.prerequisites.length {
        let child = resolve_program_lowering_evidence_node_with_specialization(
          lowering,
          fragments,
          specialization_shapes,
          specialization_evidence,
          has_specialization,
          lowering.trait_evidence_children[source.prerequisites.start + index],
          request,
        )
        if child < 0 {
          return -1
        }
        direct_children.push(child)
      }
      let child_start = request.children.length()
      for child in direct_children {
        request.children.push(child)
      }
      let node = request.evidence.length()
      request.evidence.push({
        kind: PlannedConcreteTraitEvidence(implementation, {
          start: argument_start,
          length: arguments.length,
        }),
        prerequisites: {
          start: child_start,
          length: source.prerequisites.length,
        },
      })
      node
    }
  }
}

///|
fn resolve_program_lowering_evidence_node(
  lowering : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  caller : PlannedWasmFunctionFragment?,
  source_node : Int,
  request : ProgramTraitEvidenceRequest,
) -> Int {
  match caller {
    Some(value) =>
      resolve_program_lowering_evidence_node_with_specialization(
        lowering,
        fragments,
        value.specialization_shapes,
        value.specialization_evidence,
        true,
        source_node,
        request,
      )
    None =>
      resolve_program_lowering_evidence_node_with_specialization(
        lowering,
        fragments,
        { start: 0, length: 0, },
        { start: 0, length: 0, },
        false,
        source_node,
        request,
      )
  }
}

///|
fn append_program_trait_evidence_request_key(
  request : ProgramTraitEvidenceRequest,
  node : Int,
  depth : Int,
  output : Buffer,
) -> Unit {
  if depth >= 64 || node < 0 || node >= request.evidence.length() {
    output.write_string_utf8("!")
    return
  }
  match request.evidence[node].kind {
    PlannedConcreteTraitEvidence(implementation, arguments) => {
      output.write_string_utf8("i")
      output.write_string_utf8(implementation.to_string())
      output.write_string_utf8("[")
      for index in 0..<arguments.length {
        if index > 0 {
          output.write_string_utf8(",")
        }
        output.write_string_utf8("s")
        output.write_string_utf8(
          wasmgc_trait_evidence_shape_code(
            request.arguments[arguments.start + index],
          ).to_string(),
        )
      }
      output.write_string_utf8("]{")
      let prerequisites = request.evidence[node].prerequisites
      for index in 0..<prerequisites.length {
        if index > 0 {
          output.write_string_utf8(",")
        }
        append_program_trait_evidence_request_key(
          request,
          request.children[prerequisites.start + index],
          depth + 1,
          output,
        )
      }
      output.write_string_utf8("}")
    }
    PlannedRuntimeTraitEvidence(trait_, parameter) => {
      output.write_string_utf8("r")
      output.write_string_utf8(trait_.to_string())
      output.write_string_utf8("@")
      output.write_string_utf8(parameter.to_string())
    }
  }
}

///|
fn program_trait_evidence_request_identity(
  request : ProgramTraitEvidenceRequest,
  root : Int,
) -> (DeclId, String)? {
  guard root >= 0 && root < request.evidence.length() else { return None }
  let implementation = match request.evidence[root].kind {
    PlannedConcreteTraitEvidence(value, _) => value
    PlannedRuntimeTraitEvidence(_, _) => return None
  }
  let output = Buffer()
  append_program_trait_evidence_request_key(request, root, 0, output)
  Some((implementation, @utf8.decode_lossy(output.to_bytes())))
}

///|
pub fn program_resolved_trait_evidence_identity(
  lowering : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  specialization_shapes : HirSpan,
  specialization_evidence : HirSpan,
  source_node : Int,
) -> (DeclId, String)? {
  let request = empty_program_trait_evidence_request()
  let root = resolve_program_lowering_evidence_node_with_specialization(
    lowering, fragments, specialization_shapes, specialization_evidence, true, source_node,
    request,
  )
  program_trait_evidence_request_identity(request, root)
}

///|
pub fn program_runtime_trait_evidence_slot_parameter(
  fragments : PlannedModuleWasmGCFragments,
  specialization_evidence : HirSpan,
  slot : Int,
) -> (DeclId, Int)? {
  if slot < 0 ||
    slot >= specialization_evidence.length ||
    specialization_evidence.start < 0 ||
    specialization_evidence.start + slot >=
    fragments.specialization_evidence_roots.length() {
    return None
  }
  let root = fragments.specialization_evidence_roots[specialization_evidence.start +
    slot]
  if root < 0 || root >= fragments.specialization_trait_evidence.length() {
    return None
  }
  match fragments.specialization_trait_evidence[root].kind {
    PlannedRuntimeTraitEvidence(trait_, parameter) => Some((trait_, parameter))
    PlannedConcreteTraitEvidence(_, _) => None
  }
}

///|
pub fn program_runtime_trait_evidence_parameter(
  lowering : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  specialization_evidence : HirSpan,
  source_node : Int,
) -> (DeclId, Int)? {
  if source_node < 0 || source_node >= lowering.trait_evidence.length() {
    return None
  }
  let slot = match lowering.trait_evidence[source_node].kind {
    BoundInferredTraitEvidence(value) => value
    ConcreteInferredTraitEvidence(_, _) | GuardedInferredTraitEvidence(_, _) =>
      return None
  }
  program_runtime_trait_evidence_slot_parameter(
    fragments, specialization_evidence, slot,
  )
}

///|
fn resolve_program_expression_evidence(
  lowering : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  caller : PlannedWasmFunctionFragment?,
  expression : ExprId,
) -> ProgramTraitEvidenceRequest? {
  let request = empty_program_trait_evidence_request()
  if expression < 0 || expression >= lowering.expression_evidence.length() {
    return Some(request)
  }
  let roots = lowering.expression_evidence[expression]
  for index in 0..<roots.length {
    let root = resolve_program_lowering_evidence_node(
      lowering,
      fragments,
      caller,
      lowering.trait_evidence_roots[roots.start + index],
      request,
    )
    if root < 0 {
      return None
    }
    request.roots.push(root)
  }
  Some(request)
}

///|
fn copy_program_evidence_prerequisites(
  fragments : PlannedModuleWasmGCFragments,
  root : Int,
) -> ProgramTraitEvidenceRequest? {
  guard root >= 0 && root < fragments.specialization_trait_evidence.length() else {
    return None
  }
  let request = empty_program_trait_evidence_request()
  let evidence = fragments.specialization_trait_evidence[root]
  for index in 0..<evidence.prerequisites.length {
    let child = copy_program_specialization_evidence_node(
      fragments,
      fragments.specialization_evidence_children[evidence.prerequisites.start +
      index],
      request,
    )
    if child < 0 {
      return None
    }
    request.roots.push(child)
  }
  Some(request)
}

///|
fn materialize_program_generic_specialization(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  modules : Array[PlannedModuleWasmGCFragments],
  module_lookup : Map[ModuleId, Int],
  declaration : DeclId,
  request_shapes : Array[PlannedValueShape],
  request : HirSpan,
  evidence : ProgramTraitEvidenceRequest,
  erased_fallback : Bool,
  logical_types? : Array[CompileTimeType] = [],
) -> String? {
  match
    validate_program_specialization_request_shapes(
      declaration, request_shapes, request,
    ) {
    Err(error) => abort(error)
    Ok(_) => ()
  }
  let owner_index = match module_lookup.get(semantic_id_module(declaration)) {
    Some(index) => index
    None => return None
  }
  let module_ = modules[owner_index]
  let specialization_abi_key = match
    compile_time_specialization_key(
      lowering,
      declaration,
      program_specialization_abi_key(
        declaration, request_shapes, request, evidence,
      ),
      logical_types,
      erased_fallback,
    ) {
    Some(key) => key
    None => return None
  }
  let mut runtime_evidence_parameter_count = 0
  for node in evidence.evidence {
    match node.kind {
      PlannedRuntimeTraitEvidence(_, parameter) if parameter >=
        runtime_evidence_parameter_count =>
        runtime_evidence_parameter_count = parameter + 1
      _ => ()
    }
  }
  for function_index, function_ in module_.functions {
    if function_.declaration == declaration &&
      function_.specialization_shapes.length > 0 &&
      function_.specialization_abi_key == specialization_abi_key {
      if !program_specialization_shapes_equal(
          module_.specialization_shapes,
          function_.specialization_shapes,
          request_shapes,
          request,
        ) {
        abort(
          "SPC-302 specialization key disagrees with structural shapes declaration=\{declaration} key=\{specialization_abi_key}",
        )
      }
      if erased_fallback && function_.visibility != Public {
        module_.functions[function_index] = { ..function_, visibility: Public, }
        modules[owner_index] = module_
      }
      return Some(specialization_abi_key)
    }
  }
  let base_index = module_.function_by_declaration[semantic_id_local(
      declaration,
    )]
  if base_index < 0 || base_index >= module_.functions.length() {
    return None
  }
  let base = module_.functions[base_index]
  match base.kind {
    PlannedWasmDefinedFunction(_) => ()
    PlannedWasmInlineBuiltinFunction(name) if name == b"unsafe.bitcast" => ()
    _ => return None
  }
  let selected = program_function_lowering(
    lowering, owner_index, specialization_abi_key,
  )
  let callable = match selected.functions.callable_of(declaration) {
    Some(callable) => callable
    None => return None
  }
  if program_callable_generic_parameters(callable).length != request.length {
    return None
  }
  let shape_start = module_.specialization_shapes.length()
  for index in 0..<request.length {
    module_.specialization_shapes.push(
      program_canonical_specialization_shape(
        request_shapes[request.start + index],
      ),
    )
  }
  let specialization_shapes = { start: shape_start, length: request.length, }
  let evidence_argument_start = module_.specialization_evidence_arguments.length()
  for argument in evidence.arguments {
    module_.specialization_evidence_arguments.push(
      program_canonical_specialization_shape(argument),
    )
  }
  let evidence_child_start = module_.specialization_evidence_children.length()
  let evidence_node_start = module_.specialization_trait_evidence.length()
  for child in evidence.children {
    module_.specialization_evidence_children.push(evidence_node_start + child)
  }
  for node in evidence.evidence {
    let kind = match node.kind {
      PlannedConcreteTraitEvidence(implementation, arguments) =>
        PlannedConcreteTraitEvidence(implementation, {
          start: evidence_argument_start + arguments.start,
          length: arguments.length,
        })
      PlannedRuntimeTraitEvidence(trait_, parameter) =>
        PlannedRuntimeTraitEvidence(trait_, parameter)
    }
    module_.specialization_trait_evidence.push({
      kind,
      prerequisites: {
        start: evidence_child_start + node.prerequisites.start,
        length: node.prerequisites.length,
      },
    })
  }
  let evidence_root_start = module_.specialization_evidence_roots.length()
  for root in evidence.roots {
    module_.specialization_evidence_roots.push(evidence_node_start + root)
  }
  let specialization_evidence = {
    start: evidence_root_start,
    length: evidence.roots.length(),
  }
  let resolved = {
    ..analyzed.frozen.interfaces[owner_index].resolved_types,
    types: selected.resolved_types,
    type_arguments: selected.resolved_type_arguments,
  }
  let base = if compile_time_projected_signature(
      lowering.modules[owner_index],
      lowering.modules[owner_index].functions.callable_of(declaration).unwrap(),
    ) {
    let job = wasmgc_plan_function_job(
      resolved,
      selected.functions,
      callable,
      module_.type_index_by_declaration,
      module_.function_type_by_resolved,
      true,
    )
    let start = module_.function_value_types.length()
    for value in job.parameters {
      module_.function_value_types.push(value)
    }
    let result_start = module_.function_value_types.length()
    for value in job.results {
      module_.function_value_types.push(value)
    }
    {
      ..base,
      parameters: { start, length: result_start - start, },
      results: {
        start: result_start,
        length: module_.function_value_types.length() - result_start,
      },
    }
  } else {
    base
  }
  let parameter_start = module_.function_value_types.length()
  let mut base_parameter_index = 0
  for index in 0..<callable.parameters.length {
    let parameter = selected.functions.parameters[callable.parameters.start +
      index]
    let generic_parameters = program_callable_generic_parameters(callable)
    let base_parameter_width = program_specialization_shape_width(
      parameter.shape,
    )
    let base_value = if base_parameter_width == 1 {
      Some(
        module_.function_value_types[base.parameters.start +
        base_parameter_index],
      )
    } else {
      None
    }
    let specialized_fixed_array = match
      program_fixed_array_specialization_value_type(
        resolved,
        parameter.type_,
        generic_parameters,
        module_.specialization_shapes,
        specialization_shapes,
      ) {
      Some(value) => Some(value)
      None =>
        match base_value {
          Some(WasmFixedArrayRefValue(_)) if specialization_shapes.length == 1 => {
            let carrier = wasmgc_raw_array_storage_carrier(
              module_.specialization_shapes[specialization_shapes.start],
            )
            if carrier >= 0 {
              Some(WasmFixedArrayRefValue(carrier))
            } else {
              Some(WasmNullableEqRefValue)
            }
          }
          _ => None
        }
    }
    let specialized = program_generic_parameter_shape(
      resolved,
      parameter.type_,
      generic_parameters,
      module_.specialization_shapes,
      specialization_shapes,
    )
    if base_parameter_width > 0 {
      match specialized_fixed_array {
        Some(value) => module_.function_value_types.push(value)
        None =>
          match specialized {
            Some(shape) =>
              program_append_specialization_value_types(
                module_.function_value_types,
                shape,
              )
            None =>
              for offset in 0..<base_parameter_width {
                module_.function_value_types.push(
                  module_.function_value_types[base.parameters.start +
                  base_parameter_index +
                  offset],
                )
              }
          }
      }
      base_parameter_index += base_parameter_width
    }
  }
  let source_parameter_count = module_.function_value_types.length() -
    parameter_start
  for index in 0..<evidence.evidence.length() {
    match
      module_.specialization_trait_evidence[evidence_node_start + index].kind {
      PlannedRuntimeTraitEvidence(trait_, parameter) => {
        let source = module_.specialization_trait_evidence[evidence_node_start +
          index]
        module_.specialization_trait_evidence[evidence_node_start + index] = {
          ..source,
          kind: PlannedRuntimeTraitEvidence(
            trait_,
            source_parameter_count + parameter,
          ),
        }
      }
      _ => ()
    }
  }
  for _ in 0..<runtime_evidence_parameter_count {
    module_.function_value_types.push(WasmNullableEqRefValue)
  }
  let result_start = module_.function_value_types.length()
  let generic_parameters = program_callable_generic_parameters(callable)
  let specialized_fixed_array_result = match
    program_fixed_array_specialization_value_type(
      resolved,
      callable.result_type,
      generic_parameters,
      module_.specialization_shapes,
      specialization_shapes,
    ) {
    Some(value) => Some(value)
    None =>
      if base.results.length == 1 && specialization_shapes.length == 1 {
        match module_.function_value_types[base.results.start] {
          WasmFixedArrayRefValue(_) => {
            let carrier = wasmgc_raw_array_storage_carrier(
              module_.specialization_shapes[specialization_shapes.start],
            )
            if carrier >= 0 {
              Some(WasmFixedArrayRefValue(carrier))
            } else {
              Some(WasmNullableEqRefValue)
            }
          }
          _ => None
        }
      } else {
        None
      }
  }
  let specialized_result = program_generic_parameter_shape(
    resolved,
    callable.result_type,
    generic_parameters,
    module_.specialization_shapes,
    specialization_shapes,
  )
  match specialized_fixed_array_result {
    Some(value) => module_.function_value_types.push(value)
    None =>
      match specialized_result {
        Some(shape) =>
          program_append_specialization_value_types(
            module_.function_value_types,
            shape,
          )
        None =>
          for index in 0..<base.results.length {
            module_.function_value_types.push(
              module_.function_value_types[base.results.start + index],
            )
          }
      }
  }
  module_.functions[base_index] = { ..base, elided: true, }
  module_.functions.push({
    ..base,
    visibility: if erased_fallback {
      Public
    } else {
      ModuleVisible
    },
    is_test: false,
    is_test_entry: false,
    test_name: b"",
    elided: false,
    signature_type_index: module_.physical_types.length() +
    module_.signature_type_count,
    function_index: -1,
    parameters: {
      start: parameter_start,
      length: result_start - parameter_start,
    },
    results: {
      start: result_start,
      length: module_.function_value_types.length() - result_start,
    },
    specialization_shapes,
    specialization_evidence,
    specialization_abi_key,
  })
  let lambda_signatures = materialize_compile_time_lambdas(
    lowering,
    owner_index,
    module_,
    module_.functions[module_.functions.length() - 1],
  )
  modules[owner_index] = {
    ..module_,
    signature_type_count: module_.signature_type_count + 1 + lambda_signatures,
  }
  Some(specialization_abi_key)
}

///|
fn record_program_specialized_call(
  calls : Array[PlannedProgramSpecializedCall],
  runtime_evidence_parameters : Array[Int],
  caller_body : BodyId,
  caller_specialization_abi_key : String,
  expression : ExprId,
  target : DeclId,
  target_specialization_abi_key : String,
  forwarded_runtime_evidence_parameters : Array[Int],
) -> Unit {
  for existing in calls {
    if existing.caller_body == caller_body &&
      existing.caller_specialization_abi_key == caller_specialization_abi_key &&
      existing.expression == expression {
      return
    }
  }
  let parameter_start = runtime_evidence_parameters.length()
  for parameter in forwarded_runtime_evidence_parameters {
    runtime_evidence_parameters.push(parameter)
  }
  calls.push({
    caller_body,
    caller_specialization_abi_key,
    expression,
    target,
    target_specialization_abi_key,
    runtime_evidence_parameters: {
      start: parameter_start,
      length: forwarded_runtime_evidence_parameters.length(),
    },
  })
}

///|
fn record_program_evidence_function_reference(
  references : Array[PlannedProgramEvidenceFunctionReference],
  runtime_evidence_parameters : Array[Int],
  caller_body : BodyId,
  caller_specialization_abi_key : String,
  expression : ExprId,
  target : DeclId,
  target_specialization_abi_key : String,
  forwarded_runtime_evidence_parameters : Array[Int],
) -> Unit {
  for existing in references {
    if existing.caller_body == caller_body &&
      existing.caller_specialization_abi_key == caller_specialization_abi_key &&
      existing.expression == expression {
      return
    }
  }
  let parameter_start = runtime_evidence_parameters.length()
  for parameter in forwarded_runtime_evidence_parameters {
    runtime_evidence_parameters.push(parameter)
  }
  references.push({
    caller_body,
    caller_specialization_abi_key,
    expression,
    target,
    target_specialization_abi_key,
    runtime_evidence_parameters: {
      start: parameter_start,
      length: forwarded_runtime_evidence_parameters.length(),
    },
  })
}

///|
fn program_impl_method_for_requirement(
  lowering : PlannedProgramLowering,
  module_lookup : Map[ModuleId, Int],
  implementation : DeclId,
  requirement : DeclId,
) -> DeclId? {
  let requirement_module = match
    module_lookup.get(semantic_id_module(requirement)) {
    Some(index) => index
    None => return None
  }
  let requirement_callable = match
    lowering.modules[requirement_module].functions.callable_of(requirement) {
    Some(value) => value
    None => return None
  }
  let implementation_module = match
    module_lookup.get(semantic_id_module(implementation)) {
    Some(index) => index
    None => return None
  }
  for callable in lowering.modules[implementation_module].functions.callables {
    match callable.kind {
      PlannedImplMethodCallable(owner, _) if owner == implementation &&
        callable.name == requirement_callable.name =>
        return Some(callable.declaration)
      _ => ()
    }
  }
  None
}

///|
fn program_call_target_and_arguments(
  expression : PlannedExpression,
) -> (DeclId, HirSpan)? {
  match expression.kind {
    PlannedDirectCall(target, _, _, arguments)
    | PlannedTailCall(target, _, _, arguments)
    | PlannedOperatorCall(target, _, _, _, arguments)
    | PlannedIndexCall(target, _, _, arguments)
    | PlannedIndexSetCall(target, _, _, _, arguments) =>
      Some((target, arguments))
    _ => None
  }
}

///|
fn program_evidence_target_and_arguments(
  expression : PlannedExpression,
) -> (DeclId, HirSpan)? {
  match program_call_target_and_arguments(expression) {
    Some(value) => Some(value)
    None =>
      match expression.kind {
        PlannedFunctionReference(target, arguments) => Some((target, arguments))
        _ => None
      }
  }
}

///|
fn materialize_program_expression_call(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  modules : Array[PlannedModuleWasmGCFragments],
  module_lookup : Map[ModuleId, Int],
  caller_module_index : Int,
  caller : PlannedWasmFunctionFragment?,
  caller_callable : PlannedCallable?,
  body : BodyId,
  expression : ExprId,
  specialized_calls : Array[PlannedProgramSpecializedCall],
  specialized_call_runtime_evidence_parameters : Array[Int],
  evidence_function_references : Array[PlannedProgramEvidenceFunctionReference],
  evidence_function_reference_runtime_evidence_parameters : Array[Int],
) -> Unit {
  let caller_key = match caller {
    Some(function_) => function_.specialization_abi_key
    None => ""
  }
  let owner = program_function_lowering(
    lowering, caller_module_index, caller_key,
  )
  let source = owner.expressions[expression]
  match source.kind {
    PlannedFunctionReference(target, arguments) if arguments.length > 0 => {
      // Function references need the caller's generic substitution even when
      // there are no trait prerequisites. Visit them with their owning body.
      let request_evidence = match
        resolve_program_expression_evidence(
          owner,
          modules[caller_module_index],
          caller,
          expression,
        ) {
        Some(value) => value
        None => return
      }
      let forwarded_runtime_evidence_parameters = match
        normalize_program_runtime_evidence_parameters(request_evidence) {
        Some(value) => value
        None => return
      }
      match caller {
        Some(function_) =>
          for parameter in forwarded_runtime_evidence_parameters {
            if parameter < 0 || parameter >= function_.parameters.length {
              return
            }
          }
        None => if forwarded_runtime_evidence_parameters.length() > 0 { return }
      }
      let request_shapes : Array[PlannedValueShape] = []
      for argument_index in 0..<arguments.length {
        let source_index = arguments.start + argument_index
        let shape = match (caller, caller_callable) {
          (Some(function_), Some(callable)) =>
            program_resolve_specialized_shape(
              owner,
              program_callable_generic_parameters(callable),
              modules[caller_module_index].specialization_shapes,
              function_.specialization_shapes,
              owner.expression_type_arguments[source_index],
              owner.expression_type_argument_shapes[source_index],
            )
          _ => owner.expression_type_argument_shapes[source_index]
        }
        request_shapes.push(shape)
      }
      let target_key = match
        materialize_program_generic_specialization(
          analyzed,
          lowering,
          modules,
          module_lookup,
          target,
          request_shapes,
          { start: 0, length: request_shapes.length(), },
          request_evidence,
          false,
          logical_types=compile_time_call_arguments(
            lowering, owner, caller_key, arguments, true,
          ),
        ) {
        Some(value) => value
        None => return
      }
      record_program_specialized_call(
        specialized_calls,
        specialized_call_runtime_evidence_parameters,
        body,
        match caller {
          Some(function_) => function_.specialization_abi_key
          None => ""
        },
        expression,
        target,
        target_key,
        forwarded_runtime_evidence_parameters,
      )
      match caller {
        Some(caller) if request_evidence.roots.length() > 0 &&
          (
            forwarded_runtime_evidence_parameters.length() > 0 ||
            caller.specialization_abi_key != ""
          ) =>
          record_program_evidence_function_reference(
            evidence_function_references,
            evidence_function_reference_runtime_evidence_parameters,
            body,
            caller.specialization_abi_key,
            expression,
            target,
            target_key,
            forwarded_runtime_evidence_parameters,
          )
        None if forwarded_runtime_evidence_parameters.length() > 0 => return
        _ => ()
      }
      return
    }
    _ => ()
  }
  match program_call_target_and_arguments(source) {
    Some((target, arguments)) if arguments.length > 0 => {
      let request_evidence = match
        resolve_program_expression_evidence(
          owner,
          modules[caller_module_index],
          caller,
          expression,
        ) {
        Some(value) => value
        None => return
      }
      let forwarded_runtime_evidence_parameters = match
        normalize_program_runtime_evidence_parameters(request_evidence) {
        Some(value) => value
        None => return
      }
      match caller {
        Some(function_) =>
          for parameter in forwarded_runtime_evidence_parameters {
            if parameter < 0 || parameter >= function_.parameters.length {
              return
            }
          }
        None => if forwarded_runtime_evidence_parameters.length() > 0 { return }
      }
      let request_shapes : Array[PlannedValueShape] = []
      for argument_index in 0..<arguments.length {
        let source_index = arguments.start + argument_index
        let shape = match (caller, caller_callable) {
          (Some(function_), Some(callable)) =>
            program_resolve_specialized_shape(
              owner,
              program_callable_generic_parameters(callable),
              modules[caller_module_index].specialization_shapes,
              function_.specialization_shapes,
              owner.call_type_arguments[source_index],
              owner.call_type_argument_shapes[source_index],
            )
          _ => owner.call_type_argument_shapes[source_index]
        }
        request_shapes.push(shape)
      }
      match
        materialize_program_generic_specialization(
          analyzed,
          lowering,
          modules,
          module_lookup,
          target,
          request_shapes,
          { start: 0, length: request_shapes.length(), },
          request_evidence,
          false,
          logical_types=compile_time_call_arguments(
            lowering, owner, caller_key, arguments, false,
          ),
        ) {
        Some(target_key) =>
          record_program_specialized_call(
            specialized_calls,
            specialized_call_runtime_evidence_parameters,
            body,
            match caller {
              Some(value) => value.specialization_abi_key
              None => ""
            },
            expression,
            target,
            target_key,
            forwarded_runtime_evidence_parameters,
          )
        None => ()
      }
    }
    _ =>
      match source.kind {
        PlannedBoundDirectCall(requirement, slot, _, _, _)
        | PlannedBoundOperatorCall(requirement, slot, _, _, _, _) => {
          let caller = match caller {
            Some(value) => value
            None => return
          }
          if slot < 0 || slot >= caller.specialization_evidence.length {
            return
          }
          let fragments = modules[caller_module_index]
          let root = fragments.specialization_evidence_roots[caller.specialization_evidence.start +
            slot]
          if root < 0 ||
            root >= fragments.specialization_trait_evidence.length() {
            return
          }
          let root_evidence = fragments.specialization_trait_evidence[root]
          let (implementation, arguments) = match root_evidence.kind {
            PlannedConcreteTraitEvidence(implementation, arguments) =>
              (implementation, arguments)
            PlannedRuntimeTraitEvidence(_, _) => return
          }
          let target = match
            program_impl_method_for_requirement(
              lowering, module_lookup, implementation, requirement,
            ) {
            Some(value) => value
            None => return
          }
          let target_module_index = match
            module_lookup.get(semantic_id_module(target)) {
            Some(value) => value
            None => return
          }
          let target_callable = match
            lowering.modules[target_module_index].functions.callable_of(target) {
            Some(value) => value
            None => return
          }
          let target_generic_count = program_callable_generic_parameters(
              target_callable,
            ).length
          if arguments.length < target_generic_count {
            return
          }
          let request_evidence = match
            copy_program_evidence_prerequisites(fragments, root) {
            Some(value) => value
            None => return
          }
          let forwarded_runtime_evidence_parameters = match
            normalize_program_runtime_evidence_parameters(request_evidence) {
            Some(value) => value
            None => return
          }
          for parameter in forwarded_runtime_evidence_parameters {
            if parameter < 0 || parameter >= caller.parameters.length {
              return
            }
          }
          let request_shapes : Array[PlannedValueShape] = []
          for index in 0..<target_generic_count {
            request_shapes.push(
              fragments.specialization_evidence_arguments[arguments.start +
              index],
            )
          }
          if target_generic_count == 0 &&
            forwarded_runtime_evidence_parameters.length() > 0 {
            return
          }
          let target_key = if target_generic_count > 0 {
            match
              materialize_program_generic_specialization(
                analyzed,
                lowering,
                modules,
                module_lookup,
                target,
                request_shapes,
                { start: 0, length: request_shapes.length(), },
                request_evidence,
                false,
              ) {
              Some(value) => value
              None => return
            }
          } else {
            ""
          }
          record_program_specialized_call(
            specialized_calls,
            specialized_call_runtime_evidence_parameters,
            body,
            caller.specialization_abi_key,
            expression,
            target,
            target_key,
            forwarded_runtime_evidence_parameters,
          )
        }
        _ => ()
      }
  }
}

///|
fn program_trait_dictionary_evidence_request(
  lowering : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  root : Int,
) -> ProgramTraitEvidenceRequest? {
  guard root >= 0 && root < lowering.trait_evidence.length() else {
    return None
  }
  let request = empty_program_trait_evidence_request()
  let prerequisites = lowering.trait_evidence[root].prerequisites
  for index in 0..<prerequisites.length {
    let node = resolve_program_lowering_evidence_node(
      lowering,
      fragments,
      None,
      lowering.trait_evidence_children[prerequisites.start + index],
      request,
    )
    if node < 0 {
      return None
    }
    request.roots.push(node)
  }
  Some(request)
}

///|
fn materialize_program_trait_dictionary_methods(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  modules : Array[PlannedModuleWasmGCFragments],
  module_lookup : Map[ModuleId, Int],
) -> Unit {
  for module_index, module_ in modules {
    let owner = lowering.modules[module_index]
    for dictionary in module_.trait_dictionaries {
      if dictionary.evidence < 0 ||
        dictionary.evidence >= owner.trait_evidence.length() {
        continue
      }
      let arguments = match owner.trait_evidence[dictionary.evidence].kind {
        ConcreteInferredTraitEvidence(_, arguments) => arguments
        BoundInferredTraitEvidence(_) | GuardedInferredTraitEvidence(_, _) =>
          continue
      }
      if arguments.length == 0 {
        continue
      }
      let shapes : Array[PlannedValueShape] = []
      let mut concrete = true
      for index in 0..<arguments.length {
        match owner.trait_evidence_arguments[arguments.start + index] {
          ShapeInferredTraitEvidenceArgument(shape) =>
            shapes.push(program_canonical_specialization_shape(shape))
          GenericInferredTraitEvidenceArgument(_) => {
            concrete = false
            break
          }
        }
      }
      if !concrete {
        continue
      }
      let evidence = match
        program_trait_dictionary_evidence_request(
          owner,
          module_,
          dictionary.evidence,
        ) {
        Some(value) => value
        None => continue
      }
      for index in 0..<dictionary.methods.length {
        let method_index = dictionary.methods.start + index
        let method_info = module_.trait_methods[method_index]
        let key = match
          materialize_program_generic_specialization(
            analyzed,
            lowering,
            modules,
            module_lookup,
            method_info.implementation_method,
            shapes,
            { start: 0, length: shapes.length(), },
            evidence,
            false,
          ) {
          Some(value) => value
          None => continue
        }
        module_.trait_methods[method_index] = {
          ..method_info,
          implementation_specialization_abi_key: key,
        }
      }
    }
  }
}

///|
fn copy_program_trait_evidence_request_node(
  source : ProgramTraitEvidenceRequest,
  source_node : Int,
  target : ProgramTraitEvidenceRequest,
) -> Int {
  guard source_node >= 0 && source_node < source.evidence.length() else {
    return -1
  }
  let source_evidence = source.evidence[source_node]
  let kind = match source_evidence.kind {
    PlannedConcreteTraitEvidence(implementation, arguments) => {
      let argument_start = target.arguments.length()
      for index in 0..<arguments.length {
        target.arguments.push(source.arguments[arguments.start + index])
      }
      PlannedConcreteTraitEvidence(implementation, {
        start: argument_start,
        length: arguments.length,
      })
    }
    PlannedRuntimeTraitEvidence(trait_, parameter) =>
      PlannedRuntimeTraitEvidence(trait_, parameter)
  }
  let child_start = target.children.length()
  for index in 0..<source_evidence.prerequisites.length {
    let child = copy_program_trait_evidence_request_node(
      source,
      source.children[source_evidence.prerequisites.start + index],
      target,
    )
    if child < 0 {
      return -1
    }
    target.children.push(child)
  }
  let node = target.evidence.length()
  target.evidence.push({
    kind,
    prerequisites: {
      start: child_start,
      length: source_evidence.prerequisites.length,
    },
  })
  node
}

///|
fn program_trait_evidence_prerequisite_request(
  source : ProgramTraitEvidenceRequest,
  root : Int,
) -> ProgramTraitEvidenceRequest? {
  guard root >= 0 && root < source.evidence.length() else { return None }
  let target = empty_program_trait_evidence_request()
  let prerequisites = source.evidence[root].prerequisites
  for index in 0..<prerequisites.length {
    let child = copy_program_trait_evidence_request_node(
      source,
      source.children[prerequisites.start + index],
      target,
    )
    if child < 0 {
      return None
    }
    target.roots.push(child)
  }
  Some(target)
}

///|
fn materialize_program_specialization_trait_dictionaries(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  modules : Array[PlannedModuleWasmGCFragments],
  module_lookup : Map[ModuleId, Int],
  owner_index : Int,
  caller : PlannedWasmFunctionFragment,
  body : PlannedBodyLowering,
) -> Unit {
  let owner = lowering.modules[owner_index]
  let module_ = modules[owner_index]
  let mut added_defined_function_count = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    let (trait_declaration, source_evidence) = match
      owner.expressions[expression].trait_object_coercion {
      SelectedInferredTraitObjectCoercion(trait_, evidence) =>
        (trait_, evidence)
      _ => continue
    }
    let evidence = empty_program_trait_evidence_request()
    let root = resolve_program_lowering_evidence_node_with_specialization(
      owner,
      module_,
      caller.specialization_shapes,
      caller.specialization_evidence,
      true,
      source_evidence,
      evidence,
    )
    let (implementation, evidence_key) = match
      program_trait_evidence_request_identity(evidence, root) {
      Some(value) => value
      None => continue
    }
    let mut present = false
    for dictionary in module_.trait_dictionaries {
      if dictionary.trait_declaration == trait_declaration &&
        dictionary.implementation == implementation &&
        dictionary.evidence_key == evidence_key {
        present = true
        break
      }
    }
    if present {
      continue
    }
    let mut selected_layout = None
    for layout in module_.trait_layouts {
      if layout.trait_declaration == trait_declaration {
        selected_layout = Some(layout)
        break
      }
    }
    let layout = match selected_layout {
      Some(value) => value
      None => continue
    }
    let implementation_module_index = match
      module_lookup.get(semantic_id_module(implementation)) {
      Some(value) => value
      None => continue
    }
    let implementation_owner = lowering.modules[implementation_module_index]
    let implementation_imports = analyzed.modules[implementation_module_index].imports
    let implementation_resolved = analyzed.frozen.interfaces[implementation_module_index].resolved_types
    let root_evidence = evidence.evidence[root]
    let owner_arguments = match root_evidence.kind {
      PlannedConcreteTraitEvidence(_, arguments) => arguments
      PlannedRuntimeTraitEvidence(_, _) => continue
    }
    let method_evidence = match
      program_trait_evidence_prerequisite_request(evidence, root) {
      Some(value) => value
      None => continue
    }
    let runtime_evidence_parameters = match
      normalize_program_runtime_evidence_parameters(method_evidence) {
      Some(value) => value
      None => continue
    }
    let mut runtime_parameters_valid = true
    for parameter in runtime_evidence_parameters {
      if parameter < 0 || parameter >= caller.parameters.length {
        runtime_parameters_valid = false
        break
      }
    }
    if !runtime_parameters_valid {
      continue
    }
    let function_start = module_.functions.length()
    let method_start = module_.trait_methods.length()
    let defined_start = added_defined_function_count
    let mut complete = true
    for slot in 0..<layout.methods.length {
      let requirement = module_.trait_layout_methods[layout.methods.start + slot]
      let implementation_method = match
        program_impl_method_for_requirement(
          lowering, module_lookup, implementation, requirement,
        ) {
        Some(value) => value
        None => {
          complete = false
          break
        }
      }
      let mut requirement_index = -1
      for index, function_ in module_.functions {
        if function_.declaration == requirement &&
          function_.specialization_shapes.length == 0 {
          requirement_index = index
          break
        }
      }
      if requirement_index < 0 {
        complete = false
        break
      }
      let requirement_fragment = module_.functions[requirement_index]
      let request_shapes : Array[PlannedValueShape] = []
      for index in 0..<owner_arguments.length {
        request_shapes.push(evidence.arguments[owner_arguments.start + index])
      }
      let implementation_specialization_abi_key = if request_shapes.length() > 0 {
        match
          materialize_program_generic_specialization(
            analyzed,
            lowering,
            modules,
            module_lookup,
            implementation_method,
            request_shapes,
            { start: 0, length: request_shapes.length(), },
            method_evidence,
            false,
          ) {
          Some(value) => value
          None => {
            complete = false
            break
          }
        }
      } else {
        ""
      }
      let (receiver_shape, receiver_nominal) = wasmgc_trait_implementation_receiver(
        implementation_resolved,
        implementation_owner.functions,
        Some(implementation_imports),
        implementation,
        implementation_method,
      )
      if (receiver_shape == RefPlannedValueShape && receiver_nominal == 0UL) ||
        (
          receiver_shape != RefPlannedValueShape &&
          wasmgc_trait_receiver_box_slot(receiver_shape) < 0
        ) {
        complete = false
        break
      }
      let adapter_fragment = module_.functions.length()
      module_.functions.push({
        declaration: wasmgc_trait_adapter_declaration(
          module_.module_id,
          module_.trait_methods.length(),
        ),
        lambda: -1,
        name: b"",
        visibility: ModuleVisible,
        is_test: false,
        is_test_entry: false,
        test_name: b"",
        kind: PlannedWasmTraitAdapterFunction(
          implementation_method, requirement,
        ),
        direct_builtin: b"",
        elided: false,
        signature_type_index: requirement_fragment.signature_type_index,
        function_index: -1,
        parameters: requirement_fragment.parameters,
        results: requirement_fragment.results,
        specialization_shapes: { start: 0, length: 0, },
        specialization_evidence: { start: 0, length: 0, },
        specialization_abi_key: "",
        offset: owner.expressions[expression].offset,
      })
      added_defined_function_count += 1
      module_.trait_methods.push({
        trait_declaration,
        requirement,
        implementation_method,
        receiver_shape,
        receiver_nominal,
        implementation_specialization_abi_key,
        slot,
        signature_type_index: requirement_fragment.signature_type_index,
        adapter_function: adapter_fragment,
      })
    }
    if complete {
      let runtime_parameter_start = module_.trait_dictionary_runtime_evidence_parameters.length()
      for parameter in runtime_evidence_parameters {
        module_.trait_dictionary_runtime_evidence_parameters.push(parameter)
      }
      module_.trait_dictionaries.push({
        trait_declaration,
        implementation,
        evidence: source_evidence,
        evidence_key,
        vtable_type_index: layout.vtable_type_index,
        object_type_index: layout.object_type_index,
        methods: {
          start: method_start,
          length: module_.trait_methods.length() - method_start,
        },
        runtime_evidence_parameters: {
          start: runtime_parameter_start,
          length: runtime_evidence_parameters.length(),
        },
        runtime_materialized: true,
      })
    } else {
      module_.functions.truncate(function_start)
      module_.trait_methods.truncate(method_start)
      added_defined_function_count = defined_start
    }
  }
  let latest = modules[owner_index]
  modules[owner_index] = {
    ..latest,
    defined_function_count: latest.defined_function_count +
    added_defined_function_count,
  }
}

///|
fn program_resolved_trait_declaration(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
) -> DeclId? {
  let mut type_ = root
  let mut remaining = resolved.types.length() + 1
  while remaining > 0 {
    remaining -= 1
    if type_ < 0 || type_ >= resolved.types.length() {
      return None
    }
    match resolved.types[type_] {
      TraitType(declaration) => return Some(declaration)
      AppliedType(base, _) => type_ = base
      _ => return None
    }
  }
  None
}

///|
fn program_append_external_runtime_trait(
  traits_by_module : Array[Array[DeclId]],
  seen : Map[String, Bool],
  module_index : Int,
  trait_ : DeclId,
) -> Unit {
  if module_index < 0 ||
    module_index >= traits_by_module.length() ||
    trait_ == 0UL {
    return
  }
  let key = module_index.to_string() + ":" + trait_.to_string()
  if seen.contains(key) {
    return
  }
  seen[key] = true
  traits_by_module[module_index].push(trait_)
}

///|
fn program_collect_external_runtime_trait_uses(
  lowering : PlannedProgramLowering,
  module_lookup : Map[ModuleId, Int],
  declaration : DeclId,
  visited : Map[DeclId, Bool],
  traits_by_module : Array[Array[DeclId]],
  seen_traits : Map[String, Bool],
) -> Unit {
  if visited.contains(declaration) {
    return
  }
  visited[declaration] = true
  let module_index = match module_lookup.get(semantic_id_module(declaration)) {
    Some(value) => value
    None => return
  }
  if module_index < 0 || module_index >= lowering.modules.length() {
    return
  }
  let module_ = lowering.modules[module_index]
  let callable = match module_.functions.callable_of(declaration) {
    Some(value) => value
    None => return
  }
  let body_id = match callable.kind {
    PlannedFunctionCallable(body) | PlannedImplMethodCallable(_, Some(body)) =>
      body
    _ => return
  }
  let body_index = semantic_id_local(body_id)
  if body_index < 0 || body_index >= module_.bodies.length() {
    return
  }
  let body = module_.bodies[body_index]
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match module_.expressions[expression].trait_object_coercion {
      SelectedInferredTraitObjectCoercion(trait_, evidence) =>
        if evidence >= 0 && evidence < module_.trait_evidence.length() {
          match module_.trait_evidence[evidence].kind {
            GuardedInferredTraitEvidence(_, _) => ()
            BoundInferredTraitEvidence(_) =>
              program_append_external_runtime_trait(
                traits_by_module, seen_traits, module_index, trait_,
              )
            ConcreteInferredTraitEvidence(_, _) =>
              if !runtime_trait_evidence_is_concrete(module_, evidence, 0) &&
                program_runtime_trait_evidence_is_forwardable(
                  module_, evidence, 0,
                ) {
                program_append_external_runtime_trait(
                  traits_by_module, seen_traits, module_index, trait_,
                )
                program_collect_external_runtime_evidence_implementation_uses(
                  lowering, module_lookup, module_, evidence, 0, visited, traits_by_module,
                  seen_traits,
                )
              }
          }
        }
      _ => ()
    }
    match module_.expressions[expression].kind {
      PlannedBoundDirectCall(requirement, _, _, _, _)
      | PlannedBoundOperatorCall(requirement, _, _, _, _, _) => {
        let requirement_module = match
          module_lookup.get(semantic_id_module(requirement)) {
          Some(value) => value
          None => continue
        }
        match
          lowering.modules[requirement_module].functions.callable_of(
            requirement,
          ) {
          Some({ kind: PlannedTraitMethodCallable(trait_), .. }) =>
            program_append_external_runtime_trait(
              traits_by_module, seen_traits, module_index, trait_,
            )
          _ => ()
        }
      }
      _ => ()
    }
    let call = program_evidence_target_and_arguments(
      module_.expressions[expression],
    )
    let target = match call {
      Some((target, arguments)) if arguments.length > 0 => target
      _ => continue
    }
    if expression < 0 || expression >= module_.expression_evidence.length() {
      continue
    }
    let roots = module_.expression_evidence[expression]
    let mut forwards_bound = false
    if roots.start >= 0 &&
      roots.start + roots.length <= module_.trait_evidence_roots.length() {
      for index in 0..<roots.length {
        let root = module_.trait_evidence_roots[roots.start + index]
        if !runtime_trait_evidence_is_concrete(module_, root, 0) &&
          program_runtime_trait_evidence_is_forwardable(module_, root, 0) {
          program_collect_external_runtime_evidence_implementation_uses(
            lowering, module_lookup, module_, root, 0, visited, traits_by_module,
            seen_traits,
          )
          forwards_bound = true
        }
      }
    }
    if forwards_bound {
      program_collect_external_runtime_trait_uses(
        lowering, module_lookup, target, visited, traits_by_module, seen_traits,
      )
    }
  }
}

///|
priv enum ProgramExternalRuntimeEvidenceClass {
  ProgramExternalConcreteEvidence
  ProgramExternalDirectRuntimeEvidence
  ProgramExternalCapturedRuntimeEvidence
}

///|
fn program_external_runtime_evidence_class(
  lowering : PlannedModuleLowering,
  evidence : Int,
  parameter_classes : Array[ProgramExternalRuntimeEvidenceClass],
  depth : Int,
) -> ProgramExternalRuntimeEvidenceClass? {
  if evidence < 0 ||
    evidence >= lowering.trait_evidence.length() ||
    depth > lowering.trait_evidence.length() {
    return None
  }
  let node = lowering.trait_evidence[evidence]
  match node.kind {
    GuardedInferredTraitEvidence(_, _) => None
    BoundInferredTraitEvidence(slot) => {
      if slot < 0 ||
        slot >= parameter_classes.length() ||
        node.prerequisites.length > 0 {
        return None
      }
      Some(parameter_classes[slot])
    }
    ConcreteInferredTraitEvidence(_, _) => {
      if node.prerequisites.start < 0 ||
        node.prerequisites.start + node.prerequisites.length >
        lowering.trait_evidence_children.length() {
        return None
      }
      let mut captured = false
      for index in 0..<node.prerequisites.length {
        let child = lowering.trait_evidence_children[node.prerequisites.start +
          index]
        match
          program_external_runtime_evidence_class(
            lowering,
            child,
            parameter_classes,
            depth + 1,
          ) {
          Some(ProgramExternalConcreteEvidence) => ()
          Some(ProgramExternalDirectRuntimeEvidence)
          | Some(ProgramExternalCapturedRuntimeEvidence) => captured = true
          None => return None
        }
      }
      Some(
        if captured {
          ProgramExternalCapturedRuntimeEvidence
        } else {
          ProgramExternalConcreteEvidence
        },
      )
    }
  }
}

///|
fn program_external_runtime_evidence_state_key(
  declaration : DeclId,
  parameter_classes : Array[ProgramExternalRuntimeEvidenceClass],
) -> String {
  let output = Buffer()
  output.write_string_utf8(declaration.to_string())
  output.write_byte(58)
  for class_ in parameter_classes {
    output.write_byte(
      match class_ {
        ProgramExternalConcreteEvidence => 99
        ProgramExternalDirectRuntimeEvidence => 114
        ProgramExternalCapturedRuntimeEvidence => 112
      },
    )
  }
  @utf8.decode_lossy(output.to_bytes())
}

///|
fn program_collect_external_runtime_evidence_implementation_uses(
  lowering : PlannedProgramLowering,
  module_lookup : Map[ModuleId, Int],
  evidence_owner : PlannedModuleLowering,
  evidence : Int,
  depth : Int,
  visited : Map[DeclId, Bool],
  traits_by_module : Array[Array[DeclId]],
  seen_traits : Map[String, Bool],
) -> Unit {
  if evidence < 0 ||
    evidence >= evidence_owner.trait_evidence.length() ||
    depth > evidence_owner.trait_evidence.length() {
    return
  }
  let node = evidence_owner.trait_evidence[evidence]
  match node.kind {
    ConcreteInferredTraitEvidence(implementation, _) =>
      if !runtime_trait_evidence_is_concrete(evidence_owner, evidence, 0) {
        let implementation_module = match
          module_lookup.get(semantic_id_module(implementation)) {
          Some(value) => value
          None => -1
        }
        if implementation_module >= 0 &&
          implementation_module < lowering.modules.length() {
          for
            callable in lowering.modules[implementation_module].functions.callables {
            match callable.kind {
              PlannedImplMethodCallable(owner, Some(_)) if owner ==
                implementation =>
                program_collect_external_runtime_trait_uses(
                  lowering,
                  module_lookup,
                  callable.declaration,
                  visited,
                  traits_by_module,
                  seen_traits,
                )
              _ => ()
            }
          }
        }
      }
    BoundInferredTraitEvidence(_) | GuardedInferredTraitEvidence(_, _) => ()
  }
  if node.prerequisites.start < 0 ||
    node.prerequisites.start + node.prerequisites.length >
    evidence_owner.trait_evidence_children.length() {
    return
  }
  for index in 0..<node.prerequisites.length {
    program_collect_external_runtime_evidence_implementation_uses(
      lowering,
      module_lookup,
      evidence_owner,
      evidence_owner.trait_evidence_children[node.prerequisites.start + index],
      depth + 1,
      visited,
      traits_by_module,
      seen_traits,
    )
  }
}

///|
fn program_runtime_trait_callable_supports_external_evidence_for_classes(
  lowering : PlannedProgramLowering,
  module_lookup : Map[ModuleId, Int],
  declaration : DeclId,
  parameter_classes : Array[ProgramExternalRuntimeEvidenceClass],
  states : Map[String, Int],
) -> Bool {
  let key = program_external_runtime_evidence_state_key(
    declaration, parameter_classes,
  )
  match states.get(key) {
    Some(2) => return true
    Some(3) => return false
    Some(1) => return true
    _ => ()
  }
  states[key] = 1
  let supported = program_runtime_trait_callable_body_supports_external_evidence_for_classes(
    lowering, module_lookup, declaration, parameter_classes, states,
  )
  states[key] = if supported { 2 } else { 3 }
  supported
}

///|
fn program_runtime_trait_callable_body_supports_external_evidence_for_classes(
  lowering : PlannedProgramLowering,
  module_lookup : Map[ModuleId, Int],
  declaration : DeclId,
  parameter_classes : Array[ProgramExternalRuntimeEvidenceClass],
  states : Map[String, Int],
) -> Bool {
  let module_index = match module_lookup.get(semantic_id_module(declaration)) {
    Some(value) => value
    None => return false
  }
  if module_index < 0 || module_index >= lowering.modules.length() {
    return false
  }
  let module_ = lowering.modules[module_index]
  let callable = match module_.functions.callable_of(declaration) {
    Some(value) => value
    None => return false
  }
  let body_id = match callable.kind {
    PlannedFunctionCallable(body) | PlannedImplMethodCallable(_, Some(body)) =>
      body
    _ => return false
  }
  let body_index = semantic_id_local(body_id)
  if body_index < 0 || body_index >= module_.bodies.length() {
    return false
  }
  let body = module_.bodies[body_index]
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match module_.expressions[expression].kind {
      PlannedBoundDirectCall(_, slot, receiver, _, _) =>
        if receiver < 0 || slot < 0 || slot >= parameter_classes.length() {
          return false
        }
      PlannedBoundOperatorCall(_, slot, _, _, _, _) =>
        if slot < 0 || slot >= parameter_classes.length() {
          return false
        }
      _ => ()
    }
    if expression < 0 || expression >= module_.expression_evidence.length() {
      return false
    }
    let call = program_evidence_target_and_arguments(
      module_.expressions[expression],
    )
    let roots = module_.expression_evidence[expression]
    if roots.start < 0 ||
      roots.start + roots.length > module_.trait_evidence_roots.length() {
      return false
    }
    let target_classes : Array[ProgramExternalRuntimeEvidenceClass] = []
    for index in 0..<roots.length {
      let root = module_.trait_evidence_roots[roots.start + index]
      let class_ = match
        program_external_runtime_evidence_class(
          module_, root, parameter_classes, 0,
        ) {
        Some(value) => value
        None => return false
      }
      target_classes.push(class_)
    }
    if target_classes.length() > 0 {
      match call {
        Some((target, arguments)) if arguments.length > 0 => {
          let mut has_runtime = false
          for class_ in target_classes {
            match class_ {
              ProgramExternalConcreteEvidence => ()
              ProgramExternalDirectRuntimeEvidence
              | ProgramExternalCapturedRuntimeEvidence => has_runtime = true
            }
          }
          if has_runtime &&
            !program_runtime_trait_callable_supports_external_evidence_for_classes(
              lowering, module_lookup, target, target_classes, states,
            ) {
            return false
          }
        }
        None =>
          match module_.expressions[expression].kind {
            PlannedParameterSelect(_, _) => ()
            _ => return false
          }
        _ => return false
      }
    }
    match module_.expressions[expression].trait_object_coercion {
      SelectedInferredTraitObjectCoercion(_, evidence) =>
        match
          program_external_runtime_evidence_class(
            module_, evidence, parameter_classes, 0,
          ) {
          Some(ProgramExternalConcreteEvidence)
          | Some(ProgramExternalDirectRuntimeEvidence)
          | Some(ProgramExternalCapturedRuntimeEvidence) => ()
          None => return false
        }
      ErrorInferredTraitObjectCoercion => return false
      NoInferredTraitObjectCoercion => ()
    }
  }
  true
}

///|
fn program_runtime_trait_evidence_is_forwardable(
  lowering : PlannedModuleLowering,
  evidence : Int,
  depth : Int,
) -> Bool {
  if evidence < 0 ||
    evidence >= lowering.trait_evidence.length() ||
    depth > lowering.trait_evidence.length() {
    return false
  }
  let node = lowering.trait_evidence[evidence]
  if node.prerequisites.start < 0 ||
    node.prerequisites.start + node.prerequisites.length >
    lowering.trait_evidence_children.length() {
    return false
  }
  match node.kind {
    GuardedInferredTraitEvidence(_, _) => false
    BoundInferredTraitEvidence(_) => node.prerequisites.length == 0
    ConcreteInferredTraitEvidence(_, _) => {
      for index in 0..<node.prerequisites.length {
        if !program_runtime_trait_evidence_is_forwardable(
            lowering,
            lowering.trait_evidence_children[node.prerequisites.start + index],
            depth + 1,
          ) {
          return false
        }
      }
      true
    }
  }
}

///|
fn program_runtime_trait_fallback_evidence(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  module_lookup : Map[ModuleId, Int],
  support_states : Map[String, Int],
  module_index : Int,
  module_ : PlannedModuleLowering,
  callable : PlannedCallable,
) -> ProgramTraitEvidenceRequest? {
  let body_id = match callable.kind {
    PlannedFunctionCallable(body) | PlannedImplMethodCallable(_, Some(body)) =>
      body
    _ => return None
  }
  let body_index = semantic_id_local(body_id)
  if body_index < 0 || body_index >= module_.bodies.length() {
    return None
  }
  let body = module_.bodies[body_index]
  let used_traits : Map[Int, DeclId] = Map::default()
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    let forwards_runtime_evidence = match
      program_evidence_target_and_arguments(module_.expressions[expression]) {
      Some((_, arguments)) => arguments.length > 0
      None => false
    }
    match module_.expressions[expression].kind {
      PlannedBoundDirectCall(_, _, receiver, _, _) if receiver < 0 =>
        return None
      PlannedBoundDirectCall(_, _, _, _, _)
      | PlannedBoundOperatorCall(_, _, _, _, _, _) => ()
      _ => ()
    }
    if expression >= 0 && expression < module_.expression_evidence.length() {
      let roots = module_.expression_evidence[expression]
      if roots.start < 0 ||
        roots.start + roots.length > module_.trait_evidence_roots.length() {
        return None
      }
      for index in 0..<roots.length {
        let root = module_.trait_evidence_roots[roots.start + index]
        if runtime_trait_evidence_is_concrete(module_, root, 0) {
          continue
        }
        if !forwards_runtime_evidence ||
          !program_runtime_trait_evidence_is_forwardable(module_, root, 0) {
          return None
        }
      }
    }
    match module_.expressions[expression].trait_object_coercion {
      SelectedInferredTraitObjectCoercion(trait_, evidence) => {
        if evidence < 0 || evidence >= module_.trait_evidence.length() {
          return None
        }
        match module_.trait_evidence[evidence].kind {
          GuardedInferredTraitEvidence(_, _) => return None
          BoundInferredTraitEvidence(slot) =>
            match used_traits.get(slot) {
              Some(existing) if existing != trait_ => return None
              Some(_) => ()
              None => used_traits[slot] = trait_
            }
          ConcreteInferredTraitEvidence(_, _) =>
            if !program_runtime_trait_evidence_is_forwardable(
                module_, evidence, 0,
              ) {
              return None
            }
        }
      }
      ErrorInferredTraitObjectCoercion => return None
      NoInferredTraitObjectCoercion => ()
    }
  }
  if module_index < 0 || module_index >= analyzed.frozen.interfaces.length() {
    return None
  }
  let interface_ = analyzed.frozen.interfaces[module_index]
  let mut frozen_callable = None
  for candidate in interface_.callables {
    if candidate.declaration == callable.declaration {
      frozen_callable = Some(candidate)
      break
    }
  }
  let frozen_callable = match frozen_callable {
    Some(value) => value
    None => return None
  }
  let request = empty_program_trait_evidence_request()
  let mut slot = 0
  for generic_offset in 0..<frozen_callable.generic_parameters.length {
    let parameter = frozen_callable.generic_parameters.start + generic_offset
    if parameter < 0 ||
      parameter >= interface_.generic_parameter_bounds.length() {
      return None
    }
    let bounds = interface_.generic_parameter_bounds[parameter]
    if bounds.start < 0 ||
      bounds.start + bounds.length >
      interface_.resolved_types.generic_bound_types.length() {
      return None
    }
    for bound_offset in 0..<bounds.length {
      let trait_ = match
        program_resolved_trait_declaration(
          interface_.resolved_types,
          interface_.resolved_types.generic_bound_types[bounds.start +
          bound_offset],
        ) {
        Some(value) => value
        None => return None
      }
      match used_traits.get(slot) {
        Some(expected) if expected != trait_ => return None
        _ => ()
      }
      let node = request.evidence.length()
      request.evidence.push({
        kind: PlannedRuntimeTraitEvidence(trait_, slot),
        prerequisites: { start: 0, length: 0, },
      })
      request.roots.push(node)
      slot += 1
    }
  }
  for used, _ in used_traits {
    if used < 0 || used >= slot {
      return None
    }
  }
  let parameter_classes = Array::make(
    slot,
    ProgramExternalDirectRuntimeEvidence,
  )
  if !program_runtime_trait_callable_supports_external_evidence_for_classes(
      lowering,
      module_lookup,
      callable.declaration,
      parameter_classes,
      support_states,
    ) {
    return None
  }
  Some(request)
}

///|
/// Runs module-local WasmGC fragment jobs in dependency-SCC order while
/// retaining manifest-indexed outputs.
fn program_generic_enum_instantiations(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
) -> Map[DeclId, Array[Array[Int]]] {
  let counts : Map[DeclId, Int] = Map::default()
  for module_ in lowering.modules {
    for layout in module_.type_layouts.layouts {
      match layout.kind {
        PlannedEnumLayout(_) if layout.generic_parameters.length > 0 =>
          counts[layout.declaration] = layout.generic_parameters.length
        _ => ()
      }
    }
  }
  let output : Map[DeclId, Array[Array[Int]]] = Map::default()
  for module_index, interface_ in analyzed.frozen.interfaces {
    wasmgc_collect_generic_enum_instantiations_into(
      interface_.resolved_types,
      counts,
      output,
    )
    wasmgc_collect_inferred_enum_instantiations(
      interface_.resolved_types,
      analyzed.modules[module_index].inferred,
      counts,
      output,
    )
  }
  output
}

///|
fn program_module_has_specialized_generic_enum(
  module_ : PlannedModuleLowering,
  instantiations : Map[DeclId, Array[Array[Int]]],
) -> Bool {
  for layout in module_.type_layouts.layouts {
    if layout.generic_parameters.length > 0 &&
      instantiations.contains(layout.declaration) {
      match layout.kind {
        PlannedEnumLayout(_) => return true
        _ => ()
      }
    }
  }
  false
}

///|
fn plan_program_wasmgc_fragments_for_root(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  options : WasmGCPlanningOptions,
  erased_fallback_module_index : Int,
  cached_modules : Array[PlannedModuleWasmGCFragments?],
  store_fresh : (Int, PlannedModuleWasmGCFragments) -> Unit,
) -> PlannedProgramSpecializationPlan {
  guard lowering.modules.length() == analyzed.modules.length() &&
    lowering.modules.length() == cached_modules.length() else {
    abort("program fragment inputs have different module counts")
  }
  let slots : Array[PlannedModuleWasmGCFragments?] = Array::make(
    lowering.modules.length(),
    None,
  )
  let specialization_module_lookup = lowering.index.module_lookup
  let external_evidence_support_states : Map[String, Int] = Map::default()
  let fallback_evidence_by_declaration : Map[
    DeclId,
    ProgramTraitEvidenceRequest,
  ] = Map::default()
  let extra_runtime_traits_by_module : Array[Array[DeclId]] = []
  for _ in lowering.modules {
    extra_runtime_traits_by_module.push([])
  }
  let collected_external_evidence_callables : Map[DeclId, Bool] = Map::default()
  let collected_external_evidence_traits : Map[String, Bool] = Map::default()
  if erased_fallback_module_index >= 0 &&
    erased_fallback_module_index < lowering.modules.length() {
    let module_ = lowering.modules[erased_fallback_module_index]
    for callable in module_.functions.callables {
      if callable.visibility != Public ||
        program_callable_generic_parameters(callable).length == 0 {
        continue
      }
      let evidence = match
        program_runtime_trait_fallback_evidence(
          analyzed, lowering, specialization_module_lookup, external_evidence_support_states,
          erased_fallback_module_index, module_, callable,
        ) {
        Some(value) => value
        None => continue
      }
      fallback_evidence_by_declaration[callable.declaration] = evidence
      program_collect_external_runtime_trait_uses(
        lowering,
        specialization_module_lookup,
        callable.declaration,
        collected_external_evidence_callables,
        extra_runtime_traits_by_module,
        collected_external_evidence_traits,
      )
      for root in evidence.roots {
        if root < 0 || root >= evidence.evidence.length() {
          continue
        }
        match evidence.evidence[root].kind {
          PlannedRuntimeTraitEvidence(trait_, _) =>
            program_append_external_runtime_trait(
              extra_runtime_traits_by_module, collected_external_evidence_traits,
              erased_fallback_module_index, trait_,
            )
          PlannedConcreteTraitEvidence(_, _) => ()
        }
      }
    }
  }
  let selected_demand = compile_time_demand_instances(lowering)
  let program_roots = program_reachable_callable_roots(
    analyzed,
    lowering,
    options.emit_tests,
    selected_demand,
  )
  for module_ in lowering.modules {
    for
      expression in compile_time_demand_expressions(
        lowering, module_, selected_demand,
      ) {
      match expression.kind {
        PlannedArrayIter(_, _, _)
        | PlannedArrayIterHasNext(_)
        | PlannedArrayIterNext(_, _)
        | PlannedArrayIterNextOption(_, _, _) => {
          program_roots[standard_array_type_declaration()] = true
          program_roots[standard_array_iterator_type_declaration()] = true
        }
        PlannedMapKeys(_, _, _)
        | PlannedMapKeyIterNext(_, _, _)
        | PlannedMapKeyIterNextOption(_, _, _) => {
          program_roots[standard_map_type_declaration()] = true
          program_roots[standard_map_key_iterator_type_declaration()] = true
        }
        PlannedMapValues(_, _, _)
        | PlannedMapValueIterNext(_, _, _)
        | PlannedMapValueIterNextOption(_, _, _) => {
          program_roots[standard_map_type_declaration()] = true
          program_roots[standard_map_value_iterator_type_declaration()] = true
        }
        PlannedMapEntries(_, _, _)
        | PlannedMapEntryIterNext(_, _, _)
        | PlannedMapEntryIterNextOption(_, _, _) => {
          program_roots[standard_map_type_declaration()] = true
          program_roots[standard_map_entry_iterator_type_declaration()] = true
          program_roots[standard_map_entry_type_declaration()] = true
        }
        PlannedMapIterHasNext(_, iterator, _, _) => {
          program_roots[standard_map_type_declaration()] = true
          let declaration = match iterator {
            0 => standard_map_key_iterator_type_declaration()
            1 => standard_map_value_iterator_type_declaration()
            _ => standard_map_entry_iterator_type_declaration()
          }
          program_roots[declaration] = true
        }
        PlannedSetIter(_, _)
        | PlannedSetIterHasNext(_, _)
        | PlannedSetIterNext(_, _)
        | PlannedSetIterNextOption(_, _) => {
          program_roots[standard_set_type_declaration()] = true
          program_roots[standard_set_iterator_type_declaration()] = true
        }
        _ => ()
      }
    }
  }
  let generic_enum_instantiations = program_generic_enum_instantiations(
    analyzed, lowering,
  )
  let program_function_value_roots : Map[DeclId, Bool] = Map::default()
  for module_ in lowering.modules {
    for
      expression in compile_time_demand_expressions(
        lowering, module_, selected_demand,
      ) {
      match expression.kind {
        PlannedFunctionReference(declaration, _) =>
          program_function_value_roots[declaration] = true
        _ => ()
      }
    }
  }
  for scc in lowering.graph.sccs {
    for index in 0..<scc.length {
      let module_index = lowering.graph.scc_modules[scc.start + index]
      let specialized_generic_enums = program_module_has_specialized_generic_enum(
        lowering.modules[module_index],
        generic_enum_instantiations,
      )
      let cached = if specialized_generic_enums {
        None
      } else {
        cached_modules[module_index]
      }
      match cached {
        Some(cached) => slots[module_index] = Some(cached)
        None => {
          let fresh = plan_module_wasmgc_fragments_with_options_and_roots(
            analyzed.frozen.interfaces[module_index].resolved_types,
            compile_time_fragment_template(
              lowering,
              lowering.modules[module_index],
            ),
            Some(analyzed.modules[module_index].imports),
            options,
            program_roots,
            program_function_value_roots,
            extra_runtime_traits_by_module[module_index],
            generic_enum_instantiations,
            deferred_callables=compile_time_deferred_declarations(
              lowering,
              lowering.modules[module_index],
            ),
          )
          if !specialized_generic_enums {
            store_fresh(module_index, fresh)
          }
          slots[module_index] = Some(fresh)
        }
      }
    }
  }
  let modules : Array[PlannedModuleWasmGCFragments] = []
  for slot in slots {
    modules.push(slot.unwrap())
  }
  let specialized_calls : Array[PlannedProgramSpecializedCall] = []
  let specialized_call_runtime_evidence_parameters : Array[Int] = []
  let evidence_function_references : Array[
    PlannedProgramEvidenceFunctionReference,
  ] = []
  let evidence_function_reference_runtime_evidence_parameters : Array[Int] = []
  for module_index, module_ in lowering.modules {
    if module_index != erased_fallback_module_index {
      continue
    }
    for callable in module_.functions.callables {
      if callable.visibility != Public ||
        program_callable_generic_parameters(callable).length == 0 {
        continue
      }
      let evidence = match
        fallback_evidence_by_declaration.get(callable.declaration) {
        Some(value) => value
        None => continue
      }
      let erased_shapes = Array::make(
        program_callable_generic_parameters(callable).length,
        RefPlannedValueShape,
      )
      ignore(
        materialize_program_generic_specialization(
          analyzed,
          lowering,
          modules,
          specialization_module_lookup,
          callable.declaration,
          erased_shapes,
          { start: 0, length: erased_shapes.length(), },
          evidence,
          true,
        ),
      )
    }
  }
  for module_index, module_ in lowering.modules {
    let generic_bodies : Map[BodyId, Bool] = Map::default()
    for callable in module_.functions.callables {
      if program_callable_generic_parameters(callable).length == 0 {
        continue
      }
      match callable.kind {
        PlannedFunctionCallable(body)
        | PlannedImplMethodCallable(_, Some(body)) =>
          generic_bodies[body] = true
        _ => ()
      }
    }
    for body in module_.bodies {
      if generic_bodies.contains(body.body) {
        continue
      }
      for expression in compile_time_owned_expressions(module_, body) {
        materialize_program_expression_call(
          analyzed,
          lowering,
          modules,
          specialization_module_lookup,
          module_index,
          None,
          None,
          body.body,
          expression,
          specialized_calls,
          specialized_call_runtime_evidence_parameters,
          evidence_function_references,
          evidence_function_reference_runtime_evidence_parameters,
        )
      }
    }
  }
  materialize_program_trait_dictionary_methods(
    analyzed, lowering, modules, specialization_module_lookup,
  )
  let mut specialization_changed = true
  while specialization_changed {
    let mut before = 0
    for module_ in modules {
      before += module_.functions.length()
    }
    for owner_index, fragments_ in modules {
      let function_count = fragments_.functions.length()
      for function_index in 0..<function_count {
        let function_ = fragments_.functions[function_index]
        if function_.specialization_shapes.length == 0 {
          continue
        }
        let body_id = match function_.kind {
          PlannedWasmDefinedFunction(body) => body
          _ => continue
        }
        let owner = program_function_lowering(
          lowering,
          owner_index,
          function_.specialization_abi_key,
        )
        let callable = match
          owner.functions.callable_of(function_.declaration) {
          Some(value) => value
          None => continue
        }
        let body_index = semantic_id_local(body_id)
        if body_index < 0 || body_index >= owner.bodies.length() {
          continue
        }
        let body = owner.bodies[body_index]
        materialize_program_specialization_trait_dictionaries(
          analyzed, lowering, modules, specialization_module_lookup, owner_index,
          function_, body,
        )
        for expression in compile_time_owned_expressions(owner, body) {
          materialize_program_expression_call(
            analyzed,
            lowering,
            modules,
            specialization_module_lookup,
            owner_index,
            Some(function_),
            Some(callable),
            body_id,
            expression,
            specialized_calls,
            specialized_call_runtime_evidence_parameters,
            evidence_function_references,
            evidence_function_reference_runtime_evidence_parameters,
          )
        }
      }
    }
    let mut after = 0
    for module_ in modules {
      after += module_.functions.length()
    }
    specialization_changed = after > before
  }
  for module_index, fragments_ in modules {
    for function_index in 0..<fragments_.functions.length() {
      let function_ = fragments_.functions[function_index]
      if function_.specialization_shapes.length > 0 {
        continue
      }
      match
        lowering.modules[module_index].functions.callable_of(
          function_.declaration,
        ) {
        Some(callable) if program_callable_generic_parameters(callable).length >
          0 =>
          fragments_.functions[function_index] = { ..function_, elided: true, }
        _ => ()
      }
    }
  }
  let external_type_references : Array[PlannedProgramExternalTypeReference] = []
  for module_index, module_ in modules {
    for field in module_.fields {
      match field.storage {
        WasmExternalNominalRefStorage(declaration) =>
          external_type_references.push({ module_index, declaration, })
        _ => ()
      }
    }
    for function_ in module_.functions {
      if function_.signature_type_index < 0 {
        continue
      }
      for index in 0..<function_.parameters.length {
        match module_.function_value_types[function_.parameters.start + index] {
          WasmExternalNominalRefValue(declaration) =>
            external_type_references.push({ module_index, declaration, })
          _ => ()
        }
      }
      for index in 0..<function_.results.length {
        match module_.function_value_types[function_.results.start + index] {
          WasmExternalNominalRefValue(declaration) =>
            external_type_references.push({ module_index, declaration, })
          _ => ()
        }
      }
    }
  }
  {
    graph: lowering.graph,
    modules,
    external_type_references,
    specialized_calls,
    specialized_call_runtime_evidence_parameters,
    evidence_function_references,
    evidence_function_reference_runtime_evidence_parameters,
  }
}

///|
fn program_specialization_span_is_valid(span : HirSpan, length : Int) -> Bool {
  span.start >= 0 &&
  span.length >= 0 &&
  span.start <= length &&
  span.length <= length - span.start
}

///|
/// Validates the compact specialization-to-linker handoff once, before the
/// physical linker enters its index-assignment loops.
fn validate_program_specialization_plan(
  plan : PlannedProgramSpecializationPlan,
  lowering : PlannedProgramLowering,
) -> Result[Unit, String] {
  if plan.modules.length() != lowering.modules.length() {
    return Err("specialization plan module count does not match lowering")
  }
  for module_index, module_ in plan.modules {
    if module_.module_id != lowering.modules[module_index].module_id {
      return Err("specialization plan module order does not match lowering")
    }
    match validate_module_wasmgc_arenas(module_) {
      Ok(_) => ()
      Err(error) => return Err(error)
    }
    for function_ in module_.functions {
      match
        validate_program_specialization_request_shapes(
          function_.declaration,
          module_.specialization_shapes,
          function_.specialization_shapes,
        ) {
        Err(error) => return Err(error)
        Ok(_) => ()
      }
    }
  }
  for reference in plan.external_type_references {
    if reference.module_index < 0 ||
      reference.module_index >= plan.modules.length() {
      return Err("specialization plan external type has invalid module index")
    }
    if lowering.index.type_owner(reference.declaration) is None {
      return Err(
        "specialization plan external type has unknown declaration owner",
      )
    }
  }
  for call in plan.specialized_calls {
    let caller_index = match lowering.index.body_owner(call.caller_body) {
      Some(value) => value
      None => return Err("specialization call has unknown caller body owner")
    }
    if call.expression < 0 ||
      call.expression >= lowering.modules[caller_index].expressions.length() {
      return Err("specialization call expression is outside its module arena")
    }
    if lowering.index.declaration_owner(call.target) is None {
      return Err("specialization call target has unknown declaration owner")
    }
    if !program_specialization_span_is_valid(
        call.runtime_evidence_parameters,
        plan.specialized_call_runtime_evidence_parameters.length(),
      ) {
      return Err("specialization call evidence span is outside its arena")
    }
  }
  for reference in plan.evidence_function_references {
    let caller_index = match lowering.index.body_owner(reference.caller_body) {
      Some(value) => value
      None => return Err("evidence reference has unknown caller body owner")
    }
    if reference.expression < 0 ||
      reference.expression >=
      lowering.modules[caller_index].expressions.length() {
      return Err("evidence reference expression is outside its module arena")
    }
    if lowering.index.declaration_owner(reference.target) is None {
      return Err("evidence reference target has unknown declaration owner")
    }
    if !program_specialization_span_is_valid(
        reference.runtime_evidence_parameters,
        plan.evidence_function_reference_runtime_evidence_parameters.length(),
      ) {
      return Err("evidence reference span is outside its arena")
    }
  }
  Ok(())
}

///|
pub fn plan_program_wasmgc_fragments_with_options_and_cache_hooks(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  options : WasmGCPlanningOptions,
  erased_fallback_module_index : Int,
  cached_modules : Array[PlannedModuleWasmGCFragments?],
  store_fresh : (Int, PlannedModuleWasmGCFragments) -> Unit,
) -> PlannedProgramSpecializationPlan {
  plan_program_wasmgc_fragments_for_root(
    analyzed, lowering, options, erased_fallback_module_index, cached_modules, store_fresh,
  )
}

///|
pub fn plan_program_wasmgc_fragments_with_options(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  options : WasmGCPlanningOptions,
) -> PlannedProgramSpecializationPlan {
  plan_program_wasmgc_fragments_for_root(
    analyzed,
    lowering,
    options,
    0,
    Array::make(lowering.modules.length(), None),
    fn(_, _) { () },
  )
}

///|
pub fn plan_program_wasmgc_fragments(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
) -> PlannedProgramSpecializationPlan {
  plan_program_wasmgc_fragments_with_options(
    analyzed,
    lowering,
    WasmGCPlanningOptions::optimized_subtype_families(),
  )
}
