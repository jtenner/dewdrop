///|
fn starshine_program_adapter_helper_arguments_equal(
  left : Array[@semantic.ResolvedTypeId],
  right : Array[@semantic.ResolvedTypeId],
) -> Bool {
  if left.length() != right.length() {
    return false
  }
  for index in 0..<left.length() {
    if left[index] != right[index] {
      return false
    }
  }
  true
}

///|
fn starshine_program_add_adapter_cycle_helper(
  helpers : Array[StarshineProgramAdapterHelper],
  adapter_function : Int,
  module_index : Int,
  declaration : @semantic.DeclId,
  actual_arguments : Array[@semantic.ResolvedTypeId],
) -> Unit {
  for direction in 0..<2 {
    let to_erased = direction == 0
    let mut exists = false
    for helper in helpers {
      if helper.adapter_function == adapter_function &&
        helper.declaration == declaration &&
        helper.to_erased == to_erased &&
        starshine_program_adapter_helper_arguments_equal(
          helper.actual_arguments,
          actual_arguments,
        ) {
        exists = true
        break
      }
    }
    if !exists {
      helpers.push({
        adapter_function,
        module_index,
        declaration,
        actual_arguments: actual_arguments.copy(),
        to_erased,
        signature_type_index: -1,
        function_index: -1,
      })
    }
  }
}

///|
fn starshine_program_collect_adapter_cycle_helpers(
  lowering : @semantic.PlannedModuleLowering,
  helpers : Array[StarshineProgramAdapterHelper],
  adapter_function : Int,
  module_index : Int,
  type_ : @semantic.ResolvedTypeId,
  owner_layout : @semantic.PlannedNominalLayout?,
  owner_arguments : Array[@semantic.ResolvedTypeId],
  active : Array[@semantic.DeclId],
) -> Unit {
  if type_ < 0 || type_ >= lowering.resolved_types.length() {
    return
  }
  let substituted = match (owner_layout, lowering.resolved_types[type_]) {
    (Some(layout), @semantic.GenericParameterType(parameter)) => {
      let parameter_index = @semantic.semantic_id_local(parameter)
      if parameter_index >= layout.generic_parameters.start &&
        parameter_index <
        layout.generic_parameters.start + layout.generic_parameters.length {
        let relative = parameter_index - layout.generic_parameters.start
        if relative < owner_arguments.length() {
          owner_arguments[relative]
        } else {
          type_
        }
      } else {
        type_
      }
    }
    _ => type_
  }
  if substituted < 0 || substituted >= lowering.resolved_types.length() {
    return
  }
  let (base, arguments) = match lowering.resolved_types[substituted] {
    @semantic.AppliedType(base, arguments) => (base, arguments)
    _ => return
  }
  if base < 0 || base >= lowering.resolved_types.length() {
    return
  }
  let declaration = match lowering.resolved_types[base] {
    @semantic.NominalType(value) => value
    _ => {
      for index in 0..<arguments.length {
        starshine_program_collect_adapter_cycle_helpers(
          lowering,
          helpers,
          adapter_function,
          module_index,
          lowering.resolved_type_arguments[arguments.start + index],
          owner_layout,
          owner_arguments,
          active,
        )
      }
      return
    }
  }
  let layout = match lowering.type_layouts.layout_of(declaration) {
    Some(value) if value.generic_parameters.length > 0 => value
    _ => return
  }
  let actual_arguments : Array[@semantic.ResolvedTypeId] = []
  for index in 0..<arguments.length {
    let argument = lowering.resolved_type_arguments[arguments.start + index]
    actual_arguments.push(
      match (owner_layout, lowering.resolved_types[argument]) {
        (Some(owner), @semantic.GenericParameterType(parameter)) => {
          let parameter_index = @semantic.semantic_id_local(parameter)
          if parameter_index >= owner.generic_parameters.start &&
            parameter_index <
            owner.generic_parameters.start + owner.generic_parameters.length {
            let relative = parameter_index - owner.generic_parameters.start
            if relative < owner_arguments.length() {
              owner_arguments[relative]
            } else {
              argument
            }
          } else {
            argument
          }
        }
        _ => argument
      },
    )
  }
  for current in active {
    if current == declaration {
      starshine_program_add_adapter_cycle_helper(
        helpers, adapter_function, module_index, declaration, actual_arguments,
      )
      return
    }
  }
  active.push(declaration)
  match layout.kind {
    @semantic.PlannedStructLayout(fields) =>
      for index in 0..<fields.length {
        starshine_program_collect_adapter_cycle_helpers(
          lowering,
          helpers,
          adapter_function,
          module_index,
          lowering.type_layouts.fields[fields.start + index].type_,
          Some(layout),
          actual_arguments,
          active,
        )
      }
    @semantic.PlannedEnumLayout(variants) =>
      for index in 0..<variants.length {
        let variant = lowering.type_layouts.variants[variants.start + index]
        match variant.payload {
          @semantic.PlannedTupleVariantLayout(types) =>
            for payload_index in 0..<types.length {
              starshine_program_collect_adapter_cycle_helpers(
                lowering,
                helpers,
                adapter_function,
                module_index,
                lowering.type_layouts.payload_types[types.start + payload_index],
                Some(layout),
                actual_arguments,
                active,
              )
            }
          @semantic.PlannedStructVariantLayout(fields) =>
            for field_index in 0..<fields.length {
              starshine_program_collect_adapter_cycle_helpers(
                lowering,
                helpers,
                adapter_function,
                module_index,
                lowering.type_layouts.fields[fields.start + field_index].type_,
                Some(layout),
                actual_arguments,
                active,
              )
            }
          @semantic.PlannedUnitVariantLayout => ()
        }
      }
    @semantic.PlannedForeignTypeLayout => ()
  }
  ignore(active.pop())
}

///|
fn starshine_program_function_specialization(
  fragments : @semantic.PlannedModuleWasmGCFragments,
  function_ : @semantic.PlannedProgramWasmFunction,
  callable : @semantic.PlannedCallable,
) -> StarshineGenericSpecialization {
  {
    generic_parameters: starshine_callable_generic_parameters(callable),
    shapes: fragments.specialization_shapes,
    specialization_shapes: function_.specialization_shapes,
    specialization_evidence: function_.specialization_evidence,
    specialization_abi_key: function_.specialization_abi_key,
  }
}

///|
fn starshine_program_adapter_context_argument(
  lowering : @semantic.PlannedModuleLowering,
  owner_layout : @semantic.PlannedNominalLayout?,
  owner_arguments : Array[@semantic.ResolvedTypeId],
  type_ : @semantic.ResolvedTypeId,
) -> @semantic.ResolvedTypeId {
  match owner_layout {
    Some(layout) =>
      starshine_program_adapter_explicit_argument(
        lowering, layout, owner_arguments, type_,
      )
    None => type_
  }
}

///|
fn starshine_program_callback_result_codes(code : Int) -> Array[Int] {
  if code >= 0 {
    [code]
  } else {
    []
  }
}

///|
fn starshine_program_resolved_type_code(
  lowering : @semantic.PlannedModuleLowering,
  type_ : @semantic.ResolvedTypeId,
) -> Int {
  if type_ < 0 || type_ >= lowering.resolved_types.length() {
    return -1
  }
  match lowering.resolved_types[type_] {
    @semantic.PrimitiveType(
      @semantic.BoolType
      | @semantic.I8Type
      | @semantic.I16Type
      | @semantic.I32Type
      | @semantic.U8Type
      | @semantic.U16Type
      | @semantic.U32Type
      | @semantic.Swar32Type
      | @semantic.I8x4Type
      | @semantic.U8x4Type
      | @semantic.I16x2Type
      | @semantic.U16x2Type
    ) => 0
    @semantic.PrimitiveType(
      @semantic.I64Type
      | @semantic.U64Type
      | @semantic.Swar64Type
      | @semantic.I8x8Type
      | @semantic.U8x8Type
      | @semantic.I16x4Type
      | @semantic.U16x4Type
      | @semantic.I32x2Type
      | @semantic.U32x2Type
    ) => 1
    @semantic.PrimitiveType(@semantic.F32Type) => 2
    @semantic.PrimitiveType(@semantic.F64Type) => 3
    @semantic.PrimitiveType(
      @semantic.V128Type
      | @semantic.I8x16Type
      | @semantic.U8x16Type
      | @semantic.I16x8Type
      | @semantic.U16x8Type
      | @semantic.I32x4Type
      | @semantic.U32x4Type
      | @semantic.I64x2Type
      | @semantic.U64x2Type
      | @semantic.F32x4Type
      | @semantic.F64x2Type
    ) => 4
    @semantic.PrimitiveType(@semantic.UnitType | @semantic.NeverType) => -1
    @semantic.ErrorType => -1
    _ => 5
  }
}

///|
fn starshine_program_add_callback_wrappers(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  wrappers : Array[StarshineProgramCallbackWrapper],
  adapter_function : Int,
  function_type : @semantic.ResolvedTypeId,
  owner_layout : @semantic.PlannedNominalLayout?,
  owner_arguments : Array[@semantic.ResolvedTypeId],
) -> Unit {
  if function_type < 0 || function_type >= lowering.resolved_types.length() {
    return
  }
  let (parameters, result) = match lowering.resolved_types[function_type] {
    @semantic.FunctionType(parameters, result) => (parameters, result)
    _ => return
  }
  let function_ = planned.functions[adapter_function]
  let target_function_index = function_.erased_adapter_target
  let mut target_function = None
  for candidate in planned.functions {
    if candidate.function_index == target_function_index {
      target_function = Some(candidate)
      break
    }
  }
  let target_function = match target_function {
    Some(value) => value
    None => return
  }
  let callable = match lowering.functions.callable_of(function_.declaration) {
    Some(value) => value
    None => return
  }
  let source_fragments = planned.modules[function_.module_index]
  let target_fragments = planned.modules[target_function.module_index]
  let source_specialization = starshine_program_function_specialization(
    source_fragments, function_, callable,
  )
  let target_specialization = starshine_program_function_specialization(
    target_fragments, target_function, callable,
  )
  let local_signature = source_fragments.function_type_by_resolved[function_type]
  let mut fragment = None
  for candidate in source_fragments.function_types {
    if candidate.signature_type_index == local_signature {
      fragment = Some(candidate)
      break
    }
  }
  let parameter_types : Array[@semantic.ResolvedTypeId] = []
  let source_parameter_codes : Array[Int] = []
  let target_parameter_codes : Array[Int] = []
  let mut runtime_index = 0
  for index in 0..<parameters.length {
    let parameter = starshine_program_adapter_context_argument(
      lowering,
      owner_layout,
      owner_arguments,
      lowering.resolved_type_arguments[parameters.start + index],
    )
    let fallback = match fragment {
      Some(value) if runtime_index < value.parameters.length =>
        starshine_program_adapter_value_code(
          source_fragments.function_value_types[value.parameters.start +
          runtime_index],
        )
      _ => starshine_program_resolved_type_code(lowering, parameter)
    }
    let source_code = starshine_program_specialized_type_code(
      lowering, source_specialization, parameter, fallback,
    )
    let target_code = starshine_program_specialized_type_code(
      lowering, target_specialization, parameter, fallback,
    )
    if source_code >= 0 || target_code >= 0 {
      parameter_types.push(parameter)
      source_parameter_codes.push(source_code)
      target_parameter_codes.push(target_code)
      runtime_index += 1
    }
  }
  let result_type = starshine_program_adapter_context_argument(
    lowering, owner_layout, owner_arguments, result,
  )
  let fallback_result = match fragment {
    Some(value) if value.results.length == 1 =>
      starshine_program_adapter_value_code(
        source_fragments.function_value_types[value.results.start],
      )
    _ => starshine_program_resolved_type_code(lowering, result_type)
  }
  let source_result_code = starshine_program_specialized_type_code(
    lowering, source_specialization, result_type, fallback_result,
  )
  let target_result_code = starshine_program_specialized_type_code(
    lowering, target_specialization, result_type, fallback_result,
  )
  for wrapper in wrappers {
    if wrapper.adapter_function == adapter_function &&
      wrapper.function_type == function_type &&
      starshine_program_adapter_helper_arguments_equal(
        wrapper.owner_arguments,
        owner_arguments,
      ) {
      return
    }
  }
  let source_direct = starshine_program_find_signature_by_codes(
    planned,
    source_parameter_codes,
    starshine_program_callback_result_codes(source_result_code),
  )
  let source_entry_parameters : Array[Int] = [5]
  for code in source_parameter_codes {
    source_entry_parameters.push(code)
  }
  let source_entry = starshine_program_find_signature_by_codes(
    planned,
    source_entry_parameters,
    starshine_program_callback_result_codes(source_result_code),
  )
  let target_direct = starshine_program_find_signature_by_codes(
    planned,
    target_parameter_codes,
    starshine_program_callback_result_codes(target_result_code),
  )
  let target_entry_parameters : Array[Int] = [5]
  for code in target_parameter_codes {
    target_entry_parameters.push(code)
  }
  let target_entry = starshine_program_find_signature_by_codes(
    planned,
    target_entry_parameters,
    starshine_program_callback_result_codes(target_result_code),
  )
  for direction in 0..<2 {
    wrappers.push({
      adapter_function,
      module_index: function_.module_index,
      function_type,
      owner_arguments: owner_arguments.copy(),
      to_erased: direction == 0,
      parameter_types: parameter_types.copy(),
      result_type,
      source_parameter_codes: source_parameter_codes.copy(),
      source_result_code,
      target_parameter_codes: target_parameter_codes.copy(),
      target_result_code,
      source_entry_type: source_entry,
      source_direct_type: source_direct,
      target_entry_type: target_entry,
      target_direct_type: target_direct,
      wrapper_type_index: -1,
      function_index: -1,
    })
  }
}

///|
fn starshine_program_collect_callback_wrappers(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  wrappers : Array[StarshineProgramCallbackWrapper],
  adapter_function : Int,
  root : @semantic.ResolvedTypeId,
  owner_layout : @semantic.PlannedNominalLayout?,
  owner_arguments : Array[@semantic.ResolvedTypeId],
  seen : Map[@semantic.ResolvedTypeId, Bool],
) -> Unit {
  if root < 0 || root >= lowering.resolved_types.length() || seen.contains(root) {
    return
  }
  seen[root] = true
  match lowering.resolved_types[root] {
    @semantic.FunctionType(parameters, result) => {
      starshine_program_add_callback_wrappers(
        lowering, planned, wrappers, adapter_function, root, owner_layout, owner_arguments,
      )
      for index in 0..<parameters.length {
        starshine_program_collect_callback_wrappers(
          lowering,
          planned,
          wrappers,
          adapter_function,
          lowering.resolved_type_arguments[parameters.start + index],
          owner_layout,
          owner_arguments,
          seen,
        )
      }
      starshine_program_collect_callback_wrappers(
        lowering, planned, wrappers, adapter_function, result, owner_layout, owner_arguments,
        seen,
      )
    }
    @semantic.AppliedType(base, arguments) => {
      let mut declaration = 0UL
      if base >= 0 && base < lowering.resolved_types.length() {
        match lowering.resolved_types[base] {
          @semantic.NominalType(value) => declaration = value
          _ => ()
        }
      }
      let actual_arguments : Array[@semantic.ResolvedTypeId] = []
      for index in 0..<arguments.length {
        actual_arguments.push(
          starshine_program_adapter_context_argument(
            lowering,
            owner_layout,
            owner_arguments,
            lowering.resolved_type_arguments[arguments.start + index],
          ),
        )
      }
      match lowering.type_layouts.layout_of(declaration) {
        Some(layout) if layout.generic_parameters.length > 0 =>
          match layout.kind {
            @semantic.PlannedStructLayout(fields) =>
              for index in 0..<fields.length {
                starshine_program_collect_callback_wrappers(
                  lowering,
                  planned,
                  wrappers,
                  adapter_function,
                  lowering.type_layouts.fields[fields.start + index].type_,
                  Some(layout),
                  actual_arguments,
                  seen,
                )
              }
            @semantic.PlannedEnumLayout(variants) =>
              for index in 0..<variants.length {
                let variant = lowering.type_layouts.variants[variants.start +
                  index]
                match variant.payload {
                  @semantic.PlannedTupleVariantLayout(types) =>
                    for payload_index in 0..<types.length {
                      starshine_program_collect_callback_wrappers(
                        lowering,
                        planned,
                        wrappers,
                        adapter_function,
                        lowering.type_layouts.payload_types[types.start +
                        payload_index],
                        Some(layout),
                        actual_arguments,
                        seen,
                      )
                    }
                  @semantic.PlannedStructVariantLayout(fields) =>
                    for field_index in 0..<fields.length {
                      starshine_program_collect_callback_wrappers(
                        lowering,
                        planned,
                        wrappers,
                        adapter_function,
                        lowering.type_layouts.fields[fields.start + field_index].type_,
                        Some(layout),
                        actual_arguments,
                        seen,
                      )
                    }
                  @semantic.PlannedUnitVariantLayout => ()
                }
              }
            @semantic.PlannedForeignTypeLayout => ()
          }
        _ =>
          for index in 0..<arguments.length {
            starshine_program_collect_callback_wrappers(
              lowering,
              planned,
              wrappers,
              adapter_function,
              lowering.resolved_type_arguments[arguments.start + index],
              owner_layout,
              owner_arguments,
              seen,
            )
          }
      }
    }
    _ => ()
  }
}

///|
fn starshine_program_adapter_helper_plan(
  lowering : @semantic.PlannedProgramLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
) -> StarshineProgramAdapterHelperPlan {
  let helpers : Array[StarshineProgramAdapterHelper] = []
  let wrappers : Array[StarshineProgramCallbackWrapper] = []
  let evidence_closures : Array[StarshineProgramEvidenceClosure] = []
  let captured_trait_dictionaries : Array[
    StarshineProgramCapturedTraitDictionary,
  ] = []
  let mut evidence_error : StarshineCodeEmissionError? = None
  for adapter_function, function_ in planned.functions {
    if function_.erased_adapter_target < 0 ||
      function_.specialization_shapes.length == 0 {
      continue
    }
    let module_lowering = lowering.modules[function_.module_index]
    let callable = match
      module_lowering.functions.callable_of(function_.declaration) {
      Some(value) => value
      None => continue
    }
    for index in 0..<callable.parameters.length {
      let parameter = module_lowering.functions.parameters[callable.parameters.start +
        index]
      starshine_program_collect_adapter_cycle_helpers(
        module_lowering,
        helpers,
        adapter_function,
        function_.module_index,
        parameter.type_,
        None,
        [],
        [],
      )
      starshine_program_collect_callback_wrappers(
        module_lowering,
        planned,
        wrappers,
        adapter_function,
        parameter.type_,
        None,
        [],
        Map::default(),
      )
    }
    starshine_program_collect_adapter_cycle_helpers(
      module_lowering,
      helpers,
      adapter_function,
      function_.module_index,
      callable.result_type,
      None,
      [],
      [],
    )
    starshine_program_collect_callback_wrappers(
      module_lowering,
      planned,
      wrappers,
      adapter_function,
      callable.result_type,
      None,
      [],
      Map::default(),
    )
  }
  let mut next_function_index = planned.startup_function_index + 1
  if next_function_index <= 0 {
    for function_ in planned.functions {
      if function_.function_index >= next_function_index {
        next_function_index = function_.function_index + 1
      }
    }
    for initializer in planned.initializers {
      if initializer.function_index >= next_function_index {
        next_function_index = initializer.function_index + 1
      }
    }
  }
  for index in 0..<helpers.length() {
    let helper = helpers[index]
    helpers[index] = { ..helper, function_index: next_function_index }
    next_function_index += 1
  }
  for index in 0..<wrappers.length() {
    let wrapper = wrappers[index]
    wrappers[index] = { ..wrapper, function_index: next_function_index }
    next_function_index += 1
  }
  for module_index, module_ in planned.modules {
    for dictionary_index, dictionary in module_.trait_dictionaries {
      if !dictionary.runtime_materialized ||
        dictionary.runtime_evidence_parameters.length == 0 {
        continue
      }
      if dictionary.runtime_evidence_parameters.start < 0 ||
        dictionary.runtime_evidence_parameters.length < 0 ||
        dictionary.runtime_evidence_parameters.start +
        dictionary.runtime_evidence_parameters.length >
        module_.trait_dictionary_runtime_evidence_parameters.length() {
        match evidence_error {
          None =>
            evidence_error = Some(MissingFunction(dictionary.implementation))
          Some(_) => ()
        }
        continue
      }
      captured_trait_dictionaries.push({
        module_index,
        dictionary_index,
        capture_type_index: -1,
      })
    }
  }
  for reference_index, reference in planned.evidence_function_references {
    let module_index = match
      planned.module_lookup.get(
        @semantic.semantic_id_module(reference.caller_body),
      ) {
      Some(value) => value
      None => {
        match evidence_error {
          None =>
            evidence_error = Some(
              UnsupportedExpression(reference.caller_body, reference.expression),
            )
          Some(_) => ()
        }
        continue
      }
    }
    if module_index < 0 ||
      module_index >= lowering.modules.length() ||
      module_index >= planned.modules.length() ||
      reference.runtime_evidence_parameters.start < 0 ||
      reference.runtime_evidence_parameters.length < 0 ||
      reference.runtime_evidence_parameters.start +
      reference.runtime_evidence_parameters.length >
      planned.evidence_function_reference_runtime_evidence_parameters.length() {
      match evidence_error {
        None =>
          evidence_error = Some(
            UnsupportedExpression(reference.caller_body, reference.expression),
          )
        Some(_) => ()
      }
      continue
    }
    let module_lowering = lowering.modules[module_index]
    let module_fragments = planned.modules[module_index]
    if reference.expression < 0 ||
      reference.expression >= module_lowering.expressions.length() {
      match evidence_error {
        None =>
          evidence_error = Some(
            UnsupportedExpression(reference.caller_body, reference.expression),
          )
        Some(_) => ()
      }
      continue
    }
    let mut caller_function = None
    let mut target_function = None
    for function_ in planned.functions {
      match function_.kind {
        @semantic.PlannedWasmDefinedFunction(body) if body ==
          reference.caller_body &&
          function_.specialization_abi_key ==
          reference.caller_specialization_abi_key &&
          !function_.elided => caller_function = Some(function_)
        _ => ()
      }
      if function_.declaration == reference.target &&
        function_.specialization_abi_key ==
        reference.target_specialization_abi_key &&
        !function_.elided {
        target_function = Some(function_)
      }
    }
    let caller_function = match caller_function {
      Some(value) => value
      None => {
        match evidence_error {
          None =>
            evidence_error = Some(
              UnsupportedExpression(reference.caller_body, reference.expression),
            )
          Some(_) => ()
        }
        continue
      }
    }
    let target_function = match target_function {
      Some(value) => value
      None => {
        match evidence_error {
          None => evidence_error = Some(MissingFunction(reference.target))
          Some(_) => ()
        }
        continue
      }
    }
    let source_type = module_lowering.expressions[reference.expression].type_
    let resolved_type = if source_type < -1 {
      -source_type - 2
    } else if source_type >= 0 && source_type < module_lowering.types.length() {
      match module_lowering.types[source_type] {
        @semantic.BodyResolvedType(value) => value
        _ => -1
      }
    } else {
      -1
    }
    if resolved_type < 0 ||
      resolved_type >= module_fragments.closure_entry_type_by_resolved.length() {
      match evidence_error {
        None =>
          evidence_error = Some(
            UnsupportedExpression(reference.caller_body, reference.expression),
          )
        Some(_) => ()
      }
      continue
    }
    let local_entry = module_fragments.closure_entry_type_by_resolved[resolved_type]
    if local_entry < 0 {
      match evidence_error {
        None =>
          evidence_error = Some(
            UnsupportedExpression(reference.caller_body, reference.expression),
          )
        Some(_) => ()
      }
      continue
    }
    let mut entry_type_index = planned.signature_type_index(
      module_index, local_entry,
    )
    if caller_function.specialization_shapes.length > 0 {
      let callable = match
        module_lowering.functions.callable_of(caller_function.declaration) {
        Some(value) => value
        None => {
          match evidence_error {
            None =>
              evidence_error = Some(
                UnsupportedExpression(
                  reference.caller_body,
                  reference.expression,
                ),
              )
            Some(_) => ()
          }
          continue
        }
      }
      let specialization : StarshineGenericSpecialization = {
        generic_parameters: starshine_callable_generic_parameters(callable),
        shapes: module_fragments.specialization_shapes,
        specialization_shapes: caller_function.specialization_shapes,
        specialization_evidence: caller_function.specialization_evidence,
        specialization_abi_key: caller_function.specialization_abi_key,
      }
      match
        starshine_program_specialized_closure_signatures(
          module_lowering, planned, module_fragments, resolved_type, specialization,
        ) {
        Some((entry, _)) => entry_type_index = entry
        None => ()
      }
    }
    if entry_type_index < 0 || target_function.function_index < 0 {
      match evidence_error {
        None =>
          evidence_error = Some(
            UnsupportedExpression(reference.caller_body, reference.expression),
          )
        Some(_) => ()
      }
      continue
    }
    evidence_closures.push({
      reference_index,
      module_index,
      entry_type_index,
      closure_type_index: -1,
      function_index: next_function_index,
      target_function_index: target_function.function_index,
    })
    next_function_index += 1
  }
  {
    helpers,
    wrappers,
    evidence_closures,
    captured_trait_dictionaries,
    evidence_error,
  }
}

///|
fn starshine_program_callback_codes_equal(
  left : Array[Int],
  right : Array[Int],
) -> Bool {
  if left.length() != right.length() {
    return false
  }
  for index in 0..<left.length() {
    if left[index] != right[index] {
      return false
    }
  }
  true
}

///|
fn starshine_program_callback_signature_type(
  parameter_codes : Array[Int],
  result_code : Int,
  entry : Bool,
) -> @lib.RecType? {
  let parameters : Array[@lib.ValType] = []
  if entry {
    parameters.push(@lib.ValType::eqref_null())
  }
  for code in parameter_codes {
    match starshine_program_adapter_code_val_type(code) {
      Some(value) => parameters.push(value)
      None => return None
    }
  }
  let results : Array[@lib.ValType] = []
  if result_code >= 0 {
    match starshine_program_adapter_code_val_type(result_code) {
      Some(value) => results.push(value)
      None => return None
    }
  }
  Some(
    @lib.RecType::new(
      @lib.SubType::comp_type(@lib.CompType::func(parameters, results)),
    ),
  )
}

///|
fn starshine_program_callback_signature_index(
  helper_plan : StarshineProgramAdapterHelperPlan,
  wrapper_index : Int,
  parameter_codes : Array[Int],
  result_code : Int,
  entry : Bool,
  existing : Int,
  rec_types : Array[@lib.RecType],
) -> Int {
  if existing >= 0 {
    return existing
  }
  for previous in 0..<wrapper_index {
    let candidate = helper_plan.wrappers[previous]
    if starshine_program_callback_codes_equal(
        candidate.source_parameter_codes,
        parameter_codes,
      ) &&
      candidate.source_result_code == result_code {
      let index = if entry {
        candidate.source_entry_type
      } else {
        candidate.source_direct_type
      }
      if index >= 0 {
        return index
      }
    }
    if starshine_program_callback_codes_equal(
        candidate.target_parameter_codes,
        parameter_codes,
      ) &&
      candidate.target_result_code == result_code {
      let index = if entry {
        candidate.target_entry_type
      } else {
        candidate.target_direct_type
      }
      if index >= 0 {
        return index
      }
    }
  }
  match
    starshine_program_callback_signature_type(
      parameter_codes, result_code, entry,
    ) {
    Some(type_) => {
      let index = rec_types.length()
      rec_types.push(type_)
      index
    }
    None => -1
  }
}

///|
fn starshine_program_adapter_generic_shape(
  lowering : @semantic.PlannedModuleLowering,
  fragments : @semantic.PlannedModuleWasmGCFragments,
  function_ : @semantic.PlannedProgramWasmFunction,
  callable : @semantic.PlannedCallable,
  type_ : @semantic.ResolvedTypeId,
) -> @semantic.PlannedValueShape? {
  if type_ < 0 || type_ >= lowering.resolved_types.length() {
    return None
  }
  match lowering.resolved_types[type_] {
    @semantic.GenericParameterType(parameter) => {
      let parameter_index = @semantic.semantic_id_local(parameter)
      if parameter_index >= callable.generic_parameters.start &&
        parameter_index <
        callable.generic_parameters.start + callable.generic_parameters.length {
        let relative = parameter_index - callable.generic_parameters.start
        if relative < function_.specialization_shapes.length {
          return Some(
            fragments.specialization_shapes[function_.specialization_shapes.start +
            relative],
          )
        }
      }
      None
    }
    _ => None
  }
}

///|
fn starshine_program_adapter_resolved_shape(
  lowering : @semantic.PlannedModuleLowering,
  root : @semantic.ResolvedTypeId,
) -> @semantic.PlannedValueShape {
  @semantic.planned_value_shape_from_resolved_types(
    lowering.resolved_types,
    lowering.resolved_type_arguments,
    root,
  )
}

///|
fn starshine_program_adapter_variant_expected_fields(
  lowering : @semantic.PlannedModuleLowering,
  fragments : @semantic.PlannedModuleWasmGCFragments,
  function_ : @semantic.PlannedProgramWasmFunction,
  callable : @semantic.PlannedCallable,
  layout : @semantic.PlannedNominalLayout,
  variant : @semantic.PlannedVariantLayout,
  actual_arguments : Array[@semantic.ResolvedTypeId],
  erased : Bool,
) -> StarshineVariantExpectedFields {
  match variant.payload {
    @semantic.PlannedUnitVariantLayout => StarshineExpectedUnitFields
    @semantic.PlannedTupleVariantLayout(types) => {
      let shapes : Array[@semantic.PlannedValueShape] = []
      for index in 0..<types.length {
        let field_type = lowering.type_layouts.payload_types[types.start + index]
        let selected_type = if erased {
          field_type
        } else {
          starshine_program_adapter_explicit_argument(
            lowering, layout, actual_arguments, field_type,
          )
        }
        let shape = if erased {
          starshine_program_adapter_resolved_shape(lowering, selected_type)
        } else {
          match
            starshine_program_adapter_generic_shape(
              lowering, fragments, function_, callable, selected_type,
            ) {
            Some(value) => value
            None =>
              starshine_program_adapter_resolved_shape(lowering, selected_type)
          }
        }
        shapes.push(shape)
      }
      StarshineExpectedTupleFields(shapes)
    }
    @semantic.PlannedStructVariantLayout(fields) => {
      let field_ids : Array[@semantic.FieldId] = []
      let shapes : Array[@semantic.PlannedValueShape] = []
      for index in 0..<fields.length {
        let field = lowering.type_layouts.fields[fields.start + index]
        let selected_type = if erased {
          field.type_
        } else {
          starshine_program_adapter_explicit_argument(
            lowering,
            layout,
            actual_arguments,
            field.type_,
          )
        }
        field_ids.push(field.field)
        shapes.push(
          if erased {
            starshine_program_adapter_resolved_shape(lowering, selected_type)
          } else {
            match
              starshine_program_adapter_generic_shape(
                lowering, fragments, function_, callable, selected_type,
              ) {
              Some(value) => value
              None =>
                starshine_program_adapter_resolved_shape(
                  lowering, selected_type,
                )
            }
          },
        )
      }
      StarshineExpectedStructFields(field_ids, shapes)
    }
  }
}

///|
fn starshine_program_adapter_field_layout(
  lowering : @semantic.PlannedModuleLowering,
  layout : @semantic.PlannedNominalLayout,
  field : @semantic.FieldId,
) -> @semantic.PlannedFieldLayout? {
  match layout.kind {
    @semantic.PlannedStructLayout(fields) =>
      for index in 0..<fields.length {
        let candidate = lowering.type_layouts.fields[fields.start + index]
        if candidate.field == field {
          return Some(candidate)
        }
      }
    @semantic.PlannedEnumLayout(_) | @semantic.PlannedForeignTypeLayout => ()
  }
  None
}

///|
fn starshine_program_adapter_source_field(
  fragments : @semantic.PlannedModuleWasmGCFragments,
  physical : @semantic.PlannedWasmPhysicalType,
  role : @semantic.PlannedWasmFieldRole,
  shape : @semantic.PlannedValueShape,
) -> @semantic.PlannedWasmField? {
  for index in 0..<physical.fields.length {
    let field = fragments.fields[physical.fields.start + index]
    if field.role == role &&
      starshine_shape_matches_storage(shape, field.storage) {
      return Some(field)
    }
  }
  None
}

///|
fn starshine_program_adapter_eq_field(
  fragments : @semantic.PlannedModuleWasmGCFragments,
  physical : @semantic.PlannedWasmPhysicalType,
  role : @semantic.PlannedWasmFieldRole,
) -> @semantic.PlannedWasmField? {
  for index in 0..<physical.fields.length {
    let field = fragments.fields[physical.fields.start + index]
    if field.role == role {
      match field.storage {
        @semantic.WasmNullableEqRefStorage => return Some(field)
        _ => ()
      }
    }
  }
  None
}

///|
fn starshine_program_erased_adapter_shape_box_slot(
  shape : @semantic.PlannedValueShape,
) -> Int {
  match shape {
    @semantic.I8PlannedValueShape
    | @semantic.U8PlannedValueShape
    | @semantic.I16PlannedValueShape
    | @semantic.U16PlannedValueShape
    | @semantic.I32PlannedValueShape
    | @semantic.U32PlannedValueShape
    | @semantic.Swar32PlannedValueShape => 0
    @semantic.I64PlannedValueShape
    | @semantic.U64PlannedValueShape
    | @semantic.Swar64PlannedValueShape => 1
    @semantic.F32PlannedValueShape => 2
    @semantic.F64PlannedValueShape => 3
    @semantic.V128PlannedValueShape => 4
    _ => -1
  }
}

///|
fn starshine_program_adapter_explicit_argument(
  lowering : @semantic.PlannedModuleLowering,
  layout : @semantic.PlannedNominalLayout,
  actual_arguments : Array[@semantic.ResolvedTypeId],
  type_ : @semantic.ResolvedTypeId,
) -> @semantic.ResolvedTypeId {
  if type_ < 0 || type_ >= lowering.resolved_types.length() {
    return type_
  }
  match lowering.resolved_types[type_] {
    @semantic.GenericParameterType(parameter) => {
      let parameter_index = @semantic.semantic_id_local(parameter)
      if parameter_index >= layout.generic_parameters.start &&
        parameter_index <
        layout.generic_parameters.start + layout.generic_parameters.length {
        let relative = parameter_index - layout.generic_parameters.start
        if relative < actual_arguments.length() {
          return actual_arguments[relative]
        }
      }
      type_
    }
    _ => type_
  }
}

///|
fn starshine_program_append_cycle_adapter_helper_call(
  planned : @semantic.PlannedProgramWasmGCLink,
  helper_plan : StarshineProgramAdapterHelperPlan,
  function_ : @semantic.PlannedProgramWasmFunction,
  declaration : @semantic.DeclId,
  actual_arguments : Array[@semantic.ResolvedTypeId],
  source_local : Int,
  to_erased : Bool,
  output : Array[@lib.Instruction],
) -> Bool {
  for helper in helper_plan.helpers {
    let adapter = planned.functions[helper.adapter_function]
    if adapter.function_index == function_.function_index &&
      helper.declaration == declaration &&
      helper.to_erased == to_erased &&
      starshine_program_adapter_helper_arguments_equal(
        helper.actual_arguments,
        actual_arguments,
      ) {
      output.push(
        @lib.Instruction::local_get(
          @lib.LocalIdx::new(source_local.reinterpret_as_uint()),
        ),
      )
      let nominal_type = match planned.type_lookup.get(declaration) {
        Some(value) => value
        None => return false
      }
      output.push(starshine_match_cast(nominal_type))
      output.push(
        @lib.Instruction::call(
          @lib.FuncIdx::new(helper.function_index.reinterpret_as_uint()),
        ),
      )
      return true
    }
  }
  false
}

///|
fn starshine_program_append_nominal_enum_adapter(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  function_ : @semantic.PlannedProgramWasmFunction,
  callable : @semantic.PlannedCallable,
  declaration : @semantic.DeclId,
  actual_arguments : Array[@semantic.ResolvedTypeId],
  source_local : Int,
  to_erased : Bool,
  output : Array[@lib.Instruction],
  adapter_locals : Array[@lib.ValType],
  active : Array[@semantic.DeclId],
  helper_plan : StarshineProgramAdapterHelperPlan,
  parameter_count : Int,
) -> Bool {
  for current in active {
    if current == declaration {
      return starshine_program_append_cycle_adapter_helper_call(
        planned, helper_plan, function_, declaration, actual_arguments, source_local,
        to_erased, output,
      )
    }
  }
  let layout = match lowering.type_layouts.layout_of(declaration) {
    Some(value) if value.generic_parameters.length > 0 => value
    _ => return false
  }
  let variants = match layout.kind {
    @semantic.PlannedEnumLayout(value) => value
    _ => return false
  }
  let fragments = planned.modules[function_.module_index]
  let base_type = match
    starshine_emitted_type_index(fragments, Some(planned), declaration) {
    Some(value) => value
    None => return false
  }
  active.push(declaration)
  let mut dispatch : Array[@lib.Instruction] = [
    @lib.Instruction::unreachable_(),
  ]
  let mut variant_offset = variants.length
  while variant_offset > 0 {
    variant_offset -= 1
    let variant = lowering.type_layouts.variants[variants.start + variant_offset]
    let actual_fields = starshine_program_adapter_variant_expected_fields(
      lowering, fragments, function_, callable, layout, variant, actual_arguments,
      false,
    )
    let erased_fields = starshine_program_adapter_variant_expected_fields(
      lowering, fragments, function_, callable, layout, variant, actual_arguments,
      true,
    )
    let source_physical = match
      starshine_variant_payload_physical_type_for_fields(
        fragments,
        variant.variant,
        if to_erased {
          actual_fields
        } else {
          erased_fields
        },
      ) {
      Some(value) => value
      None => {
        ignore(active.pop())
        return false
      }
    }
    let target_physical = match
      starshine_variant_payload_physical_type_for_fields(
        fragments,
        variant.variant,
        if to_erased {
          erased_fields
        } else {
          actual_fields
        },
      ) {
      Some(value) => value
      None => {
        ignore(active.pop())
        return false
      }
    }
    let source_subtype = planned.physical_type_index(
      function_.module_index,
      source_physical.type_index,
    )
    let target_subtype = planned.physical_type_index(
      function_.module_index,
      target_physical.type_index,
    )
    let branch : Array[@lib.Instruction] = [
      @lib.Instruction::i32_const(@lib.I32::new(variant.tag)),
    ]
    for target_offset in 0..<target_physical.fields.length {
      let target_field = fragments.fields[target_physical.fields.start +
        target_offset]
      let field_type = match (variant.payload, target_field.role) {
        (
          @semantic.PlannedTupleVariantLayout(types),
          @semantic.WasmTuplePayloadField(_, source_index),
        ) if source_index >= 0 && source_index < types.length =>
          lowering.type_layouts.payload_types[types.start + source_index]
        (
          @semantic.PlannedStructVariantLayout(fields),
          @semantic.WasmStructPayloadField(field),
        ) => {
          let mut found = -1
          for index in 0..<fields.length {
            let candidate = lowering.type_layouts.fields[fields.start + index]
            if candidate.field == field {
              found = candidate.type_
              break
            }
          }
          if found < 0 {
            ignore(active.pop())
            return false
          }
          found
        }
        _ => {
          ignore(active.pop())
          return false
        }
      }
      let substituted = starshine_program_adapter_explicit_argument(
        lowering, layout, actual_arguments, field_type,
      )
      match
        starshine_program_adapter_generic_shape(
          lowering, fragments, function_, callable, substituted,
        ) {
        Some(shape) =>
          if to_erased {
            let target_is_eqref = match target_field.storage {
              @semantic.WasmNullableEqRefStorage => true
              _ => false
            }
            if !target_is_eqref {
              append_starshine_instructions(
                branch,
                starshine_default_storage_instructions(target_field.storage),
              )
              continue
            }
            let source_field = match
              starshine_program_adapter_source_field(
                fragments,
                source_physical,
                target_field.role,
                shape,
              ) {
              Some(value) => value
              None => {
                ignore(active.pop())
                return false
              }
            }
            branch.push(
              @lib.Instruction::local_get(
                @lib.LocalIdx::new(source_local.reinterpret_as_uint()),
              ),
            )
            branch.push(starshine_match_cast(source_subtype))
            branch.push(
              starshine_struct_get_instruction(
                source_subtype,
                source_field.physical_index,
                source_field.storage,
              ),
            )
            let box_slot = starshine_program_erased_adapter_shape_box_slot(
              shape,
            )
            if box_slot >= 0 {
              let box_type = planned.erased_box_type_indices[box_slot]
              if box_type < 0 {
                ignore(active.pop())
                return false
              }
              branch.push(
                @lib.Instruction::struct_new(
                  @lib.TypeIdx::new(box_type.reinterpret_as_uint()),
                ),
              )
            }
          } else {
            if !starshine_shape_matches_storage(shape, target_field.storage) {
              append_starshine_instructions(
                branch,
                starshine_default_storage_instructions(target_field.storage),
              )
              continue
            }
            let source_field = match
              starshine_program_adapter_eq_field(
                fragments,
                source_physical,
                target_field.role,
              ) {
              Some(value) => value
              None => {
                ignore(active.pop())
                return false
              }
            }
            branch.push(
              @lib.Instruction::local_get(
                @lib.LocalIdx::new(source_local.reinterpret_as_uint()),
              ),
            )
            branch.push(starshine_match_cast(source_subtype))
            branch.push(
              starshine_struct_get_instruction(
                source_subtype,
                source_field.physical_index,
                source_field.storage,
              ),
            )
            let box_slot = starshine_program_erased_adapter_shape_box_slot(
              shape,
            )
            if box_slot >= 0 {
              let box_type = planned.erased_box_type_indices[box_slot]
              if box_type < 0 {
                ignore(active.pop())
                return false
              }
              branch.push(starshine_match_cast(box_type))
              branch.push(
                @lib.Instruction::struct_get(
                  @lib.TypeIdx::new(box_type.reinterpret_as_uint()),
                  0U,
                ),
              )
            }
          }
        None => {
          if field_type >= 0 && field_type < lowering.resolved_types.length() {
            match lowering.resolved_types[field_type] {
              @semantic.FunctionType(_, _) =>
                match
                  starshine_program_callback_wrapper(
                    helper_plan, planned, function_, field_type, actual_arguments,
                    to_erased,
                  ) {
                  Some(wrapper) => {
                    let callback_local = parameter_count +
                      adapter_locals.length()
                    adapter_locals.push(@lib.ValType::eqref_null())
                    branch.push(
                      @lib.Instruction::local_get(
                        @lib.LocalIdx::new(source_local.reinterpret_as_uint()),
                      ),
                    )
                    branch.push(starshine_match_cast(source_subtype))
                    branch.push(
                      starshine_struct_get_instruction(
                        source_subtype,
                        target_field.physical_index,
                        target_field.storage,
                      ),
                    )
                    branch.push(
                      @lib.Instruction::local_set(
                        @lib.LocalIdx::new(callback_local.reinterpret_as_uint()),
                      ),
                    )
                    starshine_program_append_callback_wrapper_from_local(
                      branch, wrapper, callback_local,
                    )
                    continue
                  }
                  None => ()
                }
              _ => ()
            }
          }
          let mut nested_declaration = 0UL
          let nested_arguments : Array[@semantic.ResolvedTypeId] = []
          if field_type >= 0 && field_type < lowering.resolved_types.length() {
            match lowering.resolved_types[field_type] {
              @semantic.AppliedType(nested_base, arguments) => {
                match lowering.resolved_types[nested_base] {
                  @semantic.NominalType(value) => nested_declaration = value
                  _ => ()
                }
                for index in 0..<arguments.length {
                  nested_arguments.push(
                    starshine_program_adapter_explicit_argument(
                      lowering,
                      layout,
                      actual_arguments,
                      lowering.resolved_type_arguments[arguments.start + index],
                    ),
                  )
                }
              }
              _ => ()
            }
          }
          let nested_layout = if nested_declaration != 0UL {
            lowering.type_layouts.layout_of(nested_declaration)
          } else {
            None
          }
          match nested_layout {
            Some(value) if value.generic_parameters.length > 0 => {
              let nested_output : Array[@lib.Instruction] = []
              let nested_local = parameter_count + adapter_locals.length()
              adapter_locals.push(@lib.ValType::eqref_null())
              if !starshine_program_append_nominal_aggregate_adapter(
                  lowering, planned, function_, callable, nested_declaration, nested_arguments,
                  nested_local, to_erased, nested_output, adapter_locals, active,
                  helper_plan, parameter_count,
                ) {
                ignore(adapter_locals.pop())
                ignore(active.pop())
                return false
              }
              branch.push(
                @lib.Instruction::local_get(
                  @lib.LocalIdx::new(source_local.reinterpret_as_uint()),
                ),
              )
              branch.push(starshine_match_cast(source_subtype))
              branch.push(
                starshine_struct_get_instruction(
                  source_subtype,
                  target_field.physical_index,
                  target_field.storage,
                ),
              )
              branch.push(
                @lib.Instruction::local_set(
                  @lib.LocalIdx::new(nested_local.reinterpret_as_uint()),
                ),
              )
              append_starshine_instructions(branch, nested_output)
            }
            _ => {
              branch.push(
                @lib.Instruction::local_get(
                  @lib.LocalIdx::new(source_local.reinterpret_as_uint()),
                ),
              )
              branch.push(starshine_match_cast(source_subtype))
              branch.push(
                starshine_struct_get_instruction(
                  source_subtype,
                  target_field.physical_index,
                  target_field.storage,
                ),
              )
            }
          }
        }
      }
    }
    branch.push(
      @lib.Instruction::struct_new(
        @lib.TypeIdx::new(target_subtype.reinterpret_as_uint()),
      ),
    )
    let condition : Array[@lib.Instruction] = [
      @lib.Instruction::local_get(
        @lib.LocalIdx::new(source_local.reinterpret_as_uint()),
      ),
      starshine_match_cast(base_type),
      @lib.Instruction::struct_get(
        @lib.TypeIdx::new(base_type.reinterpret_as_uint()),
        0U,
      ),
      @lib.Instruction::i32_const(@lib.I32::new(variant.tag)),
      @lib.Instruction::i32_eq(),
      @lib.Instruction::if_(
        @lib.BlockType::val_type(@lib.ValType::eqref_null()),
        branch,
        Some(dispatch),
      ),
    ]
    dispatch = condition
  }
  append_starshine_instructions(output, dispatch)
  output.push(starshine_match_cast(base_type))
  ignore(active.pop())
  true
}

///|
fn starshine_program_append_nominal_aggregate_adapter(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  function_ : @semantic.PlannedProgramWasmFunction,
  callable : @semantic.PlannedCallable,
  declaration : @semantic.DeclId,
  actual_arguments : Array[@semantic.ResolvedTypeId],
  source_local : Int,
  to_erased : Bool,
  output : Array[@lib.Instruction],
  adapter_locals : Array[@lib.ValType],
  active : Array[@semantic.DeclId],
  helper_plan : StarshineProgramAdapterHelperPlan,
  parameter_count : Int,
) -> Bool {
  for current in active {
    if current == declaration {
      return starshine_program_append_cycle_adapter_helper_call(
        planned, helper_plan, function_, declaration, actual_arguments, source_local,
        to_erased, output,
      )
    }
  }
  let layout = match lowering.type_layouts.layout_of(declaration) {
    Some(value) if value.generic_parameters.length > 0 => value
    _ => return false
  }
  match layout.kind {
    @semantic.PlannedEnumLayout(_) =>
      return starshine_program_append_nominal_enum_adapter(
        lowering, planned, function_, callable, declaration, actual_arguments, source_local,
        to_erased, output, adapter_locals, active, helper_plan, parameter_count,
      )
    @semantic.PlannedStructLayout(_) => ()
    @semantic.PlannedForeignTypeLayout => return false
  }
  let fragments = planned.modules[function_.module_index]
  let physical = match starshine_struct_physical_type(fragments, declaration) {
    Some(value) => value
    None => return false
  }
  active.push(declaration)
  let type_index = planned.physical_type_index(
    function_.module_index,
    physical.type_index,
  )
  for physical_offset in 0..<physical.fields.length {
    let target_field = fragments.fields[physical.fields.start + physical_offset]
    let field_id = match target_field.role {
      @semantic.WasmStructField(field) => field
      _ => {
        ignore(active.pop())
        return false
      }
    }
    let field_layout = match
      starshine_program_adapter_field_layout(lowering, layout, field_id) {
      Some(value) => value
      None => {
        ignore(active.pop())
        return false
      }
    }
    let substituted = starshine_program_adapter_explicit_argument(
      lowering,
      layout,
      actual_arguments,
      field_layout.type_,
    )
    let concrete_shape = starshine_program_adapter_generic_shape(
      lowering, fragments, function_, callable, substituted,
    )
    match concrete_shape {
      Some(shape) =>
        if to_erased {
          let target_is_eqref = match target_field.storage {
            @semantic.WasmNullableEqRefStorage => true
            _ => false
          }
          if !target_is_eqref {
            append_starshine_instructions(
              output,
              starshine_default_storage_instructions(target_field.storage),
            )
            continue
          }
          let source_field = match
            starshine_program_adapter_source_field(
              fragments,
              physical,
              target_field.role,
              shape,
            ) {
            Some(value) => value
            None => {
              ignore(active.pop())
              return false
            }
          }
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(source_local.reinterpret_as_uint()),
            ),
          )
          output.push(starshine_match_cast(type_index))
          output.push(
            starshine_struct_get_instruction(
              type_index,
              source_field.physical_index,
              source_field.storage,
            ),
          )
          let box_slot = starshine_program_erased_adapter_shape_box_slot(shape)
          if box_slot >= 0 {
            let box_type = planned.erased_box_type_indices[box_slot]
            if box_type < 0 {
              ignore(active.pop())
              return false
            }
            output.push(
              @lib.Instruction::struct_new(
                @lib.TypeIdx::new(box_type.reinterpret_as_uint()),
              ),
            )
          }
        } else {
          if !starshine_shape_matches_storage(shape, target_field.storage) {
            append_starshine_instructions(
              output,
              starshine_default_storage_instructions(target_field.storage),
            )
            continue
          }
          let source_field = match
            starshine_program_adapter_eq_field(
              fragments,
              physical,
              target_field.role,
            ) {
            Some(value) => value
            None => {
              ignore(active.pop())
              return false
            }
          }
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(source_local.reinterpret_as_uint()),
            ),
          )
          output.push(starshine_match_cast(type_index))
          output.push(
            starshine_struct_get_instruction(
              type_index,
              source_field.physical_index,
              source_field.storage,
            ),
          )
          let box_slot = starshine_program_erased_adapter_shape_box_slot(shape)
          if box_slot >= 0 {
            let box_type = planned.erased_box_type_indices[box_slot]
            if box_type < 0 {
              ignore(active.pop())
              return false
            }
            output.push(starshine_match_cast(box_type))
            output.push(
              @lib.Instruction::struct_get(
                @lib.TypeIdx::new(box_type.reinterpret_as_uint()),
                0U,
              ),
            )
          }
        }
      None => {
        if field_layout.type_ >= 0 &&
          field_layout.type_ < lowering.resolved_types.length() {
          match lowering.resolved_types[field_layout.type_] {
            @semantic.FunctionType(_, _) =>
              match
                starshine_program_callback_wrapper(
                  helper_plan,
                  planned,
                  function_,
                  field_layout.type_,
                  actual_arguments,
                  to_erased,
                ) {
                Some(wrapper) => {
                  let callback_local = parameter_count + adapter_locals.length()
                  adapter_locals.push(@lib.ValType::eqref_null())
                  output.push(
                    @lib.Instruction::local_get(
                      @lib.LocalIdx::new(source_local.reinterpret_as_uint()),
                    ),
                  )
                  output.push(starshine_match_cast(type_index))
                  output.push(
                    starshine_struct_get_instruction(
                      type_index,
                      target_field.physical_index,
                      target_field.storage,
                    ),
                  )
                  output.push(
                    @lib.Instruction::local_set(
                      @lib.LocalIdx::new(callback_local.reinterpret_as_uint()),
                    ),
                  )
                  starshine_program_append_callback_wrapper_from_local(
                    output, wrapper, callback_local,
                  )
                  continue
                }
                None => ()
              }
            _ => ()
          }
        }
        let mut nested_declaration = 0UL
        let nested_arguments : Array[@semantic.ResolvedTypeId] = []
        if field_layout.type_ >= 0 &&
          field_layout.type_ < lowering.resolved_types.length() {
          match lowering.resolved_types[field_layout.type_] {
            @semantic.AppliedType(nested_base, arguments) => {
              match lowering.resolved_types[nested_base] {
                @semantic.NominalType(value) => nested_declaration = value
                _ => ()
              }
              for index in 0..<arguments.length {
                nested_arguments.push(
                  starshine_program_adapter_explicit_argument(
                    lowering,
                    layout,
                    actual_arguments,
                    lowering.resolved_type_arguments[arguments.start + index],
                  ),
                )
              }
            }
            _ => ()
          }
        }
        let nested_layout = if nested_declaration != 0UL {
          lowering.type_layouts.layout_of(nested_declaration)
        } else {
          None
        }
        match nested_layout {
          Some(value) if value.generic_parameters.length > 0 => {
            let nested_output : Array[@lib.Instruction] = []
            let nested_local = parameter_count + adapter_locals.length()
            adapter_locals.push(@lib.ValType::eqref_null())
            if !starshine_program_append_nominal_aggregate_adapter(
                lowering, planned, function_, callable, nested_declaration, nested_arguments,
                nested_local, to_erased, nested_output, adapter_locals, active, helper_plan,
                parameter_count,
              ) {
              ignore(adapter_locals.pop())
              ignore(active.pop())
              return false
            }
            output.push(
              @lib.Instruction::local_get(
                @lib.LocalIdx::new(source_local.reinterpret_as_uint()),
              ),
            )
            output.push(starshine_match_cast(type_index))
            output.push(
              starshine_struct_get_instruction(
                type_index,
                target_field.physical_index,
                target_field.storage,
              ),
            )
            output.push(
              @lib.Instruction::local_set(
                @lib.LocalIdx::new(nested_local.reinterpret_as_uint()),
              ),
            )
            append_starshine_instructions(output, nested_output)
          }
          _ => {
            output.push(
              @lib.Instruction::local_get(
                @lib.LocalIdx::new(source_local.reinterpret_as_uint()),
              ),
            )
            output.push(starshine_match_cast(type_index))
            output.push(
              starshine_struct_get_instruction(
                type_index,
                target_field.physical_index,
                target_field.storage,
              ),
            )
          }
        }
      }
    }
  }
  output.push(
    @lib.Instruction::struct_new(
      @lib.TypeIdx::new(type_index.reinterpret_as_uint()),
    ),
  )
  ignore(active.pop())
  true
}

///|
fn starshine_program_append_recursive_aggregate_adapter(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  function_ : @semantic.PlannedProgramWasmFunction,
  callable : @semantic.PlannedCallable,
  type_ : @semantic.ResolvedTypeId,
  source_local : Int,
  to_erased : Bool,
  output : Array[@lib.Instruction],
  adapter_locals : Array[@lib.ValType],
  helper_plan : StarshineProgramAdapterHelperPlan,
  parameter_count : Int,
) -> Bool {
  if type_ < 0 || type_ >= lowering.resolved_types.length() {
    return false
  }
  let (base, arguments) = match lowering.resolved_types[type_] {
    @semantic.AppliedType(base, arguments) => (base, arguments)
    _ => return false
  }
  let declaration = match lowering.resolved_types[base] {
    @semantic.NominalType(value) => value
    _ => return false
  }
  let actual_arguments : Array[@semantic.ResolvedTypeId] = []
  for index in 0..<arguments.length {
    actual_arguments.push(
      lowering.resolved_type_arguments[arguments.start + index],
    )
  }
  starshine_program_append_nominal_aggregate_adapter(
    lowering,
    planned,
    function_,
    callable,
    declaration,
    actual_arguments,
    source_local,
    to_erased,
    output,
    adapter_locals,
    [],
    helper_plan,
    parameter_count,
  )
}

///|
fn starshine_program_erased_adapter_cast_index(
  planned : @semantic.PlannedProgramWasmGCLink,
  module_index : Int,
  type_ : @semantic.PlannedWasmValueType,
) -> Int {
  match type_ {
    @semantic.WasmFunctionRefValue(local_type) =>
      planned.signature_type_index(module_index, local_type)
    @semantic.WasmNominalRefValue(local_type)
    | @semantic.WasmNullableNominalRefValue(local_type) =>
      planned.physical_type_index(module_index, local_type)
    @semantic.WasmExternalNominalRefValue(declaration)
    | @semantic.WasmNullableExternalNominalRefValue(declaration) =>
      match planned.type_lookup.get(declaration) {
        Some(type_index) => type_index
        None => -1
      }
    _ => -1
  }
}

///|
fn starshine_program_erased_adapter_box_slot(
  type_ : @semantic.PlannedWasmValueType,
) -> Int {
  match type_ {
    @semantic.WasmI32Value => 0
    @semantic.WasmI64Value => 1
    @semantic.WasmF32Value => 2
    @semantic.WasmF64Value => 3
    @semantic.WasmV128Value => 4
    _ => -1
  }
}

///|
fn starshine_program_erased_adapter_is_eqref(
  type_ : @semantic.PlannedWasmValueType,
) -> Bool {
  match type_ {
    @semantic.WasmNullableEqRefValue => true
    _ => false
  }
}

///|
fn starshine_program_callback_wrapper(
  helper_plan : StarshineProgramAdapterHelperPlan,
  planned : @semantic.PlannedProgramWasmGCLink,
  function_ : @semantic.PlannedProgramWasmFunction,
  function_type : @semantic.ResolvedTypeId,
  owner_arguments : Array[@semantic.ResolvedTypeId],
  to_erased : Bool,
) -> StarshineProgramCallbackWrapper? {
  for wrapper in helper_plan.wrappers {
    let adapter = planned.functions[wrapper.adapter_function]
    if adapter.function_index == function_.function_index &&
      wrapper.function_type == function_type &&
      starshine_program_adapter_helper_arguments_equal(
        wrapper.owner_arguments,
        owner_arguments,
      ) &&
      wrapper.to_erased == to_erased {
      return Some(wrapper)
    }
  }
  None
}

///|
fn starshine_program_append_callback_wrapper_from_local(
  output : Array[@lib.Instruction],
  wrapper : StarshineProgramCallbackWrapper,
  source_local : Int,
) -> Unit {
  output.push(
    @lib.Instruction::ref_func(
      @lib.FuncIdx::new(wrapper.function_index.reinterpret_as_uint()),
    ),
  )
  output.push(
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(source_local.reinterpret_as_uint()),
    ),
  )
  output.push(
    @lib.Instruction::struct_new(
      @lib.TypeIdx::new(wrapper.wrapper_type_index.reinterpret_as_uint()),
    ),
  )
}

///|
fn starshine_program_erased_adapter_body(
  lowering : @semantic.PlannedProgramLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  function_ : @semantic.PlannedProgramWasmFunction,
  helper_plan : StarshineProgramAdapterHelperPlan,
) -> Result[@lib.Func, StarshineCodeEmissionError] {
  let target = function_.erased_adapter_target
  if target < 0 {
    return Err(MissingFunction(function_.declaration))
  }
  let mut target_function = None
  for candidate in planned.functions {
    if candidate.function_index == target {
      target_function = Some(candidate)
      break
    }
  }
  let target_function = match target_function {
    Some(value) => value
    None => return Err(MissingFunction(function_.declaration))
  }
  let source_module = planned.modules[function_.module_index]
  let target_module = planned.modules[target_function.module_index]
  let source_lowering = lowering.modules[function_.module_index]
  let callable = match
    source_lowering.functions.callable_of(function_.declaration) {
    Some(value) => value
    None => return Err(MissingFunction(function_.declaration))
  }
  let runtime_parameter_types : Array[@semantic.ResolvedTypeId] = []
  for index in 0..<callable.parameters.length {
    let parameter = source_lowering.functions.parameters[callable.parameters.start +
      index]
    match parameter.shape {
      @semantic.UnitPlannedValueShape | @semantic.NeverPlannedValueShape => ()
      _ => runtime_parameter_types.push(parameter.type_)
    }
  }
  let instructions : Array[@lib.Instruction] = []
  let adapter_locals : Array[@lib.ValType] = []
  for index in 0..<function_.parameters.length {
    if function_.specialization_shapes.length > 0 &&
      index < runtime_parameter_types.length() {
      let runtime_type = runtime_parameter_types[index]
      match
        starshine_program_callback_wrapper(
          helper_plan,
          planned,
          function_,
          runtime_type,
          [],
          true,
        ) {
        Some(wrapper) => {
          starshine_program_append_callback_wrapper_from_local(
            instructions, wrapper, index,
          )
          continue
        }
        None => ()
      }
      let converted : Array[@lib.Instruction] = []
      if starshine_program_append_recursive_aggregate_adapter(
          source_lowering,
          planned,
          function_,
          callable,
          runtime_type,
          index,
          true,
          converted,
          adapter_locals,
          helper_plan,
          function_.parameters.length,
        ) {
        append_starshine_instructions(instructions, converted)
        continue
      }
    }
    instructions.push(
      @lib.Instruction::local_get(
        @lib.LocalIdx::new(index.reinterpret_as_uint()),
      ),
    )
    let source_type = source_module.function_value_types[function_.parameters.start +
      index]
    let target_type = target_module.function_value_types[target_function.parameters.start +
      index]
    if source_type != target_type {
      if !starshine_program_erased_adapter_is_eqref(target_type) {
        return Err(MissingFunction(function_.declaration))
      }
      let box_slot = starshine_program_erased_adapter_box_slot(source_type)
      if box_slot >= 0 {
        let box_type = planned.erased_box_type_indices[box_slot]
        if box_type < 0 {
          return Err(MissingFunction(function_.declaration))
        }
        instructions.push(
          @lib.Instruction::struct_new(
            @lib.TypeIdx::new(box_type.reinterpret_as_uint()),
          ),
        )
      }
    }
  }
  instructions.push(
    @lib.Instruction::call(@lib.FuncIdx::new(target.reinterpret_as_uint())),
  )
  if function_.results.length == 1 {
    if function_.specialization_shapes.length > 0 {
      match
        starshine_program_callback_wrapper(
          helper_plan,
          planned,
          function_,
          callable.result_type,
          [],
          false,
        ) {
        Some(wrapper) => {
          let scratch = function_.parameters.length + adapter_locals.length()
          adapter_locals.push(@lib.ValType::eqref_null())
          instructions.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
            ),
          )
          starshine_program_append_callback_wrapper_from_local(
            instructions, wrapper, scratch,
          )
          return Ok(
            @lib.Func::new(
              @lib.Locals::from_types(adapter_locals),
              @lib.Expr::new(instructions),
            ),
          )
        }
        None => ()
      }
      let converted : Array[@lib.Instruction] = []
      let scratch = function_.parameters.length + adapter_locals.length()
      adapter_locals.push(@lib.ValType::eqref_null())
      if starshine_program_append_recursive_aggregate_adapter(
          source_lowering,
          planned,
          function_,
          callable,
          callable.result_type,
          scratch,
          false,
          converted,
          adapter_locals,
          helper_plan,
          function_.parameters.length,
        ) {
        instructions.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
          ),
        )
        append_starshine_instructions(instructions, converted)
        return Ok(
          @lib.Func::new(
            @lib.Locals::from_types(adapter_locals),
            @lib.Expr::new(instructions),
          ),
        )
      } else {
        ignore(adapter_locals.pop())
      }
    }
    let source_type = source_module.function_value_types[function_.results.start]
    let target_type = target_module.function_value_types[target_function.results.start]
    if source_type != target_type {
      if !starshine_program_erased_adapter_is_eqref(target_type) {
        return Err(MissingFunction(function_.declaration))
      }
      let box_slot = starshine_program_erased_adapter_box_slot(source_type)
      if box_slot >= 0 {
        let box_type = planned.erased_box_type_indices[box_slot]
        if box_type < 0 {
          return Err(MissingFunction(function_.declaration))
        }
        instructions.push(starshine_match_cast(box_type))
        instructions.push(
          @lib.Instruction::struct_get(
            @lib.TypeIdx::new(box_type.reinterpret_as_uint()),
            0U,
          ),
        )
      } else {
        let cast_index = starshine_program_erased_adapter_cast_index(
          planned,
          function_.module_index,
          source_type,
        )
        if cast_index < 0 {
          return Err(MissingFunction(function_.declaration))
        }
        instructions.push(starshine_match_cast(cast_index))
      }
    }
  }
  Ok(
    @lib.Func::new(
      @lib.Locals::from_types(adapter_locals),
      @lib.Expr::new(instructions),
    ),
  )
}

///|
fn starshine_program_adapter_code_val_type(code : Int) -> @lib.ValType? {
  match code {
    0 => Some(@lib.ValType::i32())
    1 => Some(@lib.ValType::i64())
    2 => Some(@lib.ValType::f32())
    3 => Some(@lib.ValType::f64())
    4 => Some(@lib.ValType::v128())
    5 => Some(@lib.ValType::eqref_null())
    _ => None
  }
}

///|
fn starshine_program_append_adapter_code_local_conversion(
  planned : @semantic.PlannedProgramWasmGCLink,
  output : Array[@lib.Instruction],
  local_index : Int,
  source_code : Int,
  target_code : Int,
) -> Bool {
  output.push(
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(local_index.reinterpret_as_uint()),
    ),
  )
  if source_code == target_code {
    return true
  }
  if source_code == 5 && target_code >= 0 && target_code < 5 {
    let box_type = planned.erased_box_type_indices[target_code]
    if box_type < 0 {
      return false
    }
    output.push(starshine_match_cast(box_type))
    output.push(
      @lib.Instruction::struct_get(
        @lib.TypeIdx::new(box_type.reinterpret_as_uint()),
        0U,
      ),
    )
    return true
  }
  if target_code == 5 && source_code >= 0 && source_code < 5 {
    let box_type = planned.erased_box_type_indices[source_code]
    if box_type < 0 {
      return false
    }
    output.push(
      @lib.Instruction::struct_new(
        @lib.TypeIdx::new(box_type.reinterpret_as_uint()),
      ),
    )
    return true
  }
  false
}

///|
fn starshine_program_append_adapter_code_result_conversion(
  planned : @semantic.PlannedProgramWasmGCLink,
  output : Array[@lib.Instruction],
  source_code : Int,
  target_code : Int,
) -> Bool {
  if source_code == target_code || source_code < 0 || target_code < 0 {
    return source_code == target_code
  }
  if source_code == 5 && target_code >= 0 && target_code < 5 {
    let box_type = planned.erased_box_type_indices[target_code]
    if box_type < 0 {
      return false
    }
    output.push(starshine_match_cast(box_type))
    output.push(
      @lib.Instruction::struct_get(
        @lib.TypeIdx::new(box_type.reinterpret_as_uint()),
        0U,
      ),
    )
    return true
  }
  if target_code == 5 && source_code >= 0 && source_code < 5 {
    let box_type = planned.erased_box_type_indices[source_code]
    if box_type < 0 {
      return false
    }
    output.push(
      @lib.Instruction::struct_new(
        @lib.TypeIdx::new(box_type.reinterpret_as_uint()),
      ),
    )
    return true
  }
  false
}

///|
fn emit_starshine_program_callback_wrapper_body(
  planned : @semantic.PlannedProgramWasmGCLink,
  helper_plan : StarshineProgramAdapterHelperPlan,
  wrapper : StarshineProgramCallbackWrapper,
) -> Result[@lib.Func, StarshineCodeEmissionError] {
  let visible_parameter_codes = if wrapper.to_erased {
    wrapper.target_parameter_codes
  } else {
    wrapper.source_parameter_codes
  }
  let captured_parameter_codes = if wrapper.to_erased {
    wrapper.source_parameter_codes
  } else {
    wrapper.target_parameter_codes
  }
  let captured_result_code = if wrapper.to_erased {
    wrapper.source_result_code
  } else {
    wrapper.target_result_code
  }
  let visible_result_code = if wrapper.to_erased {
    wrapper.target_result_code
  } else {
    wrapper.source_result_code
  }
  if visible_parameter_codes.length() != captured_parameter_codes.length() {
    return Err(MissingFunction(0UL))
  }
  let captured_entry_type = if wrapper.to_erased {
    wrapper.source_entry_type
  } else {
    wrapper.target_entry_type
  }
  let captured_direct_type = if wrapper.to_erased {
    wrapper.source_direct_type
  } else {
    wrapper.target_direct_type
  }
  let module_ = planned.modules[wrapper.module_index]
  let closure_type = planned.physical_type_index(
    wrapper.module_index,
    module_.closure_type_index,
  )
  if closure_type < 0 {
    return Err(MissingFunction(0UL))
  }
  let scratch = visible_parameter_codes.length() + 1
  let output : Array[@lib.Instruction] = [
    @lib.Instruction::local_get(@lib.LocalIdx::new(0U)),
    starshine_match_cast(wrapper.wrapper_type_index),
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(wrapper.wrapper_type_index.reinterpret_as_uint()),
      1U,
    ),
    @lib.Instruction::local_set(
      @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
    ),
  ]
  let direct : Array[@lib.Instruction] = []
  let captured : Array[@lib.Instruction] = [
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
    ),
  ]
  let adapter_function = planned.functions[wrapper.adapter_function]
  for index in 0..<captured_parameter_codes.length() {
    let nested = if index < wrapper.parameter_types.length() {
      starshine_program_callback_wrapper(
        helper_plan,
        planned,
        adapter_function,
        wrapper.parameter_types[index],
        wrapper.owner_arguments,
        !wrapper.to_erased,
      )
    } else {
      None
    }
    match nested {
      Some(nested_wrapper) => {
        starshine_program_append_callback_wrapper_from_local(
          direct,
          nested_wrapper,
          index + 1,
        )
        starshine_program_append_callback_wrapper_from_local(
          captured,
          nested_wrapper,
          index + 1,
        )
      }
      None =>
        if !starshine_program_append_adapter_code_local_conversion(
            planned,
            direct,
            index + 1,
            visible_parameter_codes[index],
            captured_parameter_codes[index],
          ) ||
          !starshine_program_append_adapter_code_local_conversion(
            planned,
            captured,
            index + 1,
            visible_parameter_codes[index],
            captured_parameter_codes[index],
          ) {
          return Err(MissingFunction(0UL))
        }
    }
  }
  for branch in [direct, captured] {
    branch.push(
      @lib.Instruction::local_get(
        @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
      ),
    )
    branch.push(starshine_match_cast(closure_type))
    branch.push(
      @lib.Instruction::struct_get(
        @lib.TypeIdx::new(closure_type.reinterpret_as_uint()),
        0U,
      ),
    )
  }
  direct.push(starshine_match_cast(captured_direct_type))
  direct.push(
    @lib.Instruction::call_ref(
      @lib.TypeIdx::new(captured_direct_type.reinterpret_as_uint()),
    ),
  )
  captured.push(starshine_match_cast(captured_entry_type))
  captured.push(
    @lib.Instruction::call_ref(
      @lib.TypeIdx::new(captured_entry_type.reinterpret_as_uint()),
    ),
  )
  output.push(
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
    ),
  )
  output.push(starshine_match_cast(closure_type))
  output.push(
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(closure_type.reinterpret_as_uint()),
      0U,
    ),
  )
  output.push(
    @lib.Instruction::ref_test(
      false,
      @lib.HeapType::new(
        @lib.TypeIdx::new(captured_direct_type.reinterpret_as_uint()),
      ),
    ),
  )
  let block_type = match
    starshine_program_adapter_code_val_type(captured_result_code) {
    Some(value) => @lib.BlockType::val_type(value)
    None => @lib.BlockType::void_()
  }
  output.push(@lib.Instruction::if_(block_type, direct, Some(captured)))
  let nested_result = starshine_program_callback_wrapper(
    helper_plan,
    planned,
    adapter_function,
    wrapper.result_type,
    wrapper.owner_arguments,
    wrapper.to_erased,
  )
  let wrapper_locals : Array[@lib.ValType] = [@lib.ValType::eqref_null()]
  match nested_result {
    Some(nested_wrapper) => {
      let result_scratch = scratch + 1
      wrapper_locals.push(@lib.ValType::eqref_null())
      output.push(
        @lib.Instruction::local_set(
          @lib.LocalIdx::new(result_scratch.reinterpret_as_uint()),
        ),
      )
      starshine_program_append_callback_wrapper_from_local(
        output, nested_wrapper, result_scratch,
      )
    }
    None =>
      if !starshine_program_append_adapter_code_result_conversion(
          planned, output, captured_result_code, visible_result_code,
        ) {
        return Err(MissingFunction(0UL))
      }
  }
  Ok(
    @lib.Func::new(
      @lib.Locals::from_types(wrapper_locals),
      @lib.Expr::new(output),
    ),
  )
}

///|
fn emit_starshine_program_adapter_helper_body(
  lowering : @semantic.PlannedProgramLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  helper_plan : StarshineProgramAdapterHelperPlan,
  helper : StarshineProgramAdapterHelper,
) -> Result[@lib.Func, StarshineCodeEmissionError] {
  let function_ = planned.functions[helper.adapter_function]
  let module_lowering = lowering.modules[helper.module_index]
  let callable = match
    module_lowering.functions.callable_of(function_.declaration) {
    Some(value) => value
    None => return Err(MissingFunction(function_.declaration))
  }
  let instructions : Array[@lib.Instruction] = []
  let adapter_locals : Array[@lib.ValType] = []
  if !starshine_program_append_nominal_aggregate_adapter(
      module_lowering,
      planned,
      function_,
      callable,
      helper.declaration,
      helper.actual_arguments,
      0,
      helper.to_erased,
      instructions,
      adapter_locals,
      [],
      helper_plan,
      1,
    ) {
    return Err(MissingFunction(function_.declaration))
  }
  Ok(
    @lib.Func::new(
      @lib.Locals::from_types(adapter_locals),
      @lib.Expr::new(instructions),
    ),
  )
}

///|
fn emit_starshine_program_trait_adapter_body(
  planned : @semantic.PlannedProgramWasmGCLink,
  adapter : @semantic.PlannedProgramWasmFunction,
  implementation_method : @semantic.DeclId,
  helper_plan : StarshineProgramAdapterHelperPlan,
) -> Result[@lib.Func, StarshineCodeEmissionError] {
  let module_fragments = planned.modules[adapter.module_index]
  let method_info = match
    starshine_trait_adapter_method(module_fragments, adapter.declaration) {
    Some(value) => value
    None => return Err(UnsupportedExpression(0UL, 0))
  }
  let mut implementation = None
  for function_ in planned.functions {
    if function_.declaration == implementation_method &&
      function_.specialization_abi_key ==
      method_info.implementation_specialization_abi_key &&
      function_.function_index >= 0 {
      implementation = Some(function_)
      break
    }
  }
  let implementation = match implementation {
    Some(value) => value
    None => return Err(MissingFunction(implementation_method))
  }
  let captured = starshine_program_captured_trait_dictionary_for_adapter(
    planned,
    helper_plan,
    adapter.module_index,
    adapter.declaration,
  )
  let instructions : Array[@lib.Instruction] = [
    @lib.Instruction::local_get(@lib.LocalIdx::new(0U)),
  ]
  match captured {
    Some(value) => {
      if value.capture_type_index < 0 {
        return Err(UnsupportedExpression(0UL, 0))
      }
      instructions.push(starshine_match_cast(value.capture_type_index))
      instructions.push(
        @lib.Instruction::struct_get(
          @lib.TypeIdx::new(value.capture_type_index.reinterpret_as_uint()),
          @lib.U32::new(0U),
        ),
      )
    }
    None => ()
  }
  match method_info.receiver_shape {
    @semantic.RefPlannedValueShape => {
      let type_index = match
        planned.type_lookup.get(method_info.receiver_nominal) {
        Some(value) => value
        None => return Err(UnsupportedExpression(0UL, 0))
      }
      instructions.push(starshine_match_cast(type_index))
    }
    _ => {
      let box_slot = starshine_program_erased_adapter_shape_box_slot(
        method_info.receiver_shape,
      )
      if box_slot < 0 || box_slot >= planned.erased_box_type_indices.length() {
        return Err(UnsupportedExpression(0UL, 0))
      }
      let box_type = planned.erased_box_type_indices[box_slot]
      if box_type < 0 {
        return Err(UnsupportedExpression(0UL, 0))
      }
      instructions.push(starshine_match_cast(box_type))
      instructions.push(
        @lib.Instruction::struct_get(
          @lib.TypeIdx::new(box_type.reinterpret_as_uint()),
          @lib.U32::new(0U),
        ),
      )
    }
  }
  for index in 1..<adapter.parameters.length {
    instructions.push(
      @lib.Instruction::local_get(
        @lib.LocalIdx::new(index.reinterpret_as_uint()),
      ),
    )
  }
  match captured {
    Some(value) => {
      let dictionary = planned.modules[value.module_index].trait_dictionaries[value.dictionary_index]
      for index in 0..<dictionary.runtime_evidence_parameters.length {
        instructions.push(@lib.Instruction::local_get(@lib.LocalIdx::new(0U)))
        instructions.push(starshine_match_cast(value.capture_type_index))
        instructions.push(
          @lib.Instruction::struct_get(
            @lib.TypeIdx::new(value.capture_type_index.reinterpret_as_uint()),
            @lib.U32::new((index + 1).reinterpret_as_uint()),
          ),
        )
      }
    }
    None => ()
  }
  instructions.push(
    @lib.Instruction::call(
      @lib.FuncIdx::new(implementation.function_index.reinterpret_as_uint()),
    ),
  )
  Ok(@lib.Func::new(@lib.Locals::from_types([]), @lib.Expr::new(instructions)))
}

///|
fn emit_starshine_program_evidence_closure_body(
  planned : @semantic.PlannedProgramWasmGCLink,
  closure : StarshineProgramEvidenceClosure,
) -> Result[@lib.Func, StarshineCodeEmissionError] {
  if closure.reference_index < 0 ||
    closure.reference_index >= planned.evidence_function_references.length() ||
    closure.closure_type_index < 0 {
    return Err(MissingFunction(0UL))
  }
  let reference = planned.evidence_function_references[closure.reference_index]
  let mut target = None
  for function_ in planned.functions {
    if function_.function_index == closure.target_function_index {
      target = Some(function_)
      break
    }
  }
  let target = match target {
    Some(value) => value
    None => return Err(MissingFunction(reference.target))
  }
  let evidence_count = reference.runtime_evidence_parameters.length
  if evidence_count > target.parameters.length {
    return Err(MissingFunction(reference.target))
  }
  let visible_count = target.parameters.length - evidence_count
  let instructions : Array[@lib.Instruction] = []
  for index in 0..<visible_count {
    instructions.push(
      @lib.Instruction::local_get(
        @lib.LocalIdx::new((index + 1).reinterpret_as_uint()),
      ),
    )
  }
  for index in 0..<evidence_count {
    instructions.push(@lib.Instruction::local_get(@lib.LocalIdx::new(0U)))
    instructions.push(
      @lib.Instruction::ref_cast(
        false,
        @lib.HeapType::new(
          @lib.TypeIdx::new(closure.closure_type_index.reinterpret_as_uint()),
        ),
      ),
    )
    instructions.push(
      @lib.Instruction::struct_get(
        @lib.TypeIdx::new(closure.closure_type_index.reinterpret_as_uint()),
        @lib.U32::new((index + 1).reinterpret_as_uint()),
      ),
    )
  }
  instructions.push(
    @lib.Instruction::call(
      @lib.FuncIdx::new(closure.target_function_index.reinterpret_as_uint()),
    ),
  )
  Ok(@lib.Func::new(@lib.Locals::from_types([]), @lib.Expr::new(instructions)))
}
