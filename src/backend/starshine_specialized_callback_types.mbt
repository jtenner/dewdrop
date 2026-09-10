///|
// Substitute generic carriers while retaining each fixed part of the original
// function ABI. A nominal reference cannot be replaced by eqref in a call_ref
// signature: Wasm function types require the exact declared heap type.
fn starshine_append_specialized_callback_types(
  lowering : @semantic.PlannedModuleLowering,
  specialization : StarshineGenericSpecialization,
  type_ : @semantic.ResolvedTypeId,
  original : Array[@lib.ValType],
  position : Int,
  output : Array[@lib.ValType],
) -> Int {
  guard type_ >= 0 && type_ < lowering.resolved_types.length() else {
    abort("callback type is outside the resolved type arena: \{type_}")
  }
  match lowering.resolved_types[type_] {
    @semantic.GenericParameterType(parameter) => {
      let index = @semantic.semantic_id_local(parameter)
      if specialization.generic_parameters.relative_index(index)
        is Some(relative) {
        guard position < original.length() &&
          relative < specialization.specialization_shapes.length else {
          abort("callback generic parameter has no physical carrier")
        }
        starshine_append_shape_value_types(
          output,
          specialization.shapes[specialization.specialization_shapes.start +
          relative],
        )
        return position + 1
      }
    }
    @semantic.ProductType(fields) => {
      let mut next = position
      for index in 0..<fields.length {
        next = starshine_append_specialized_callback_types(
          lowering,
          specialization,
          lowering.resolved_type_arguments[fields.start + index],
          original,
          next,
          output,
        )
      }
      return next
    }
    _ => ()
  }
  let shape = @semantic.planned_value_shape_from_resolved_types(
    lowering.resolved_types,
    lowering.resolved_type_arguments,
    type_,
  )
  let width = starshine_shape_leaf_count(shape)
  guard position <= original.length() && width <= original.length() - position else {
    abort("callback logical type and physical signature have different widths")
  }
  for index in 0..<width {
    output.push(original[position + index])
  }
  position + width
}

///|
fn starshine_program_find_signature_by_types(
  planned : @semantic.PlannedProgramWasmGCLink,
  parameters : Array[@lib.ValType],
  results : Array[@lib.ValType],
) -> Int {
  for candidate in planned.program_signature_types {
    let module_ = planned.modules[candidate.module_index]
    let (source_parameters, source_results) = match candidate.kind {
      @semantic.PlannedProgramFunctionType(index) => {
        let source = module_.function_types[index]
        (source.parameters, source.results)
      }
      @semantic.PlannedProgramFunctionSignature(index) => {
        let source = module_.functions[index]
        (source.parameters, source.results)
      }
    }
    if source_parameters.length != parameters.length() ||
      source_results.length != results.length() {
      continue
    }
    let mut matches = true
    for index, expected in parameters {
      if starshine_program_value_type(
          planned,
          candidate.module_index,
          module_.function_value_types[source_parameters.start + index],
        ) !=
        expected {
        matches = false
        break
      }
    }
    if !matches {
      continue
    }
    for index, expected in results {
      if starshine_program_value_type(
          planned,
          candidate.module_index,
          module_.function_value_types[source_results.start + index],
        ) !=
        expected {
        matches = false
        break
      }
    }
    if matches {
      return candidate.type_index
    }
  }
  -1
}

///|
fn starshine_specialize_callback_signature(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  module_ : @semantic.PlannedModuleWasmGCFragments,
  function_type : @semantic.ResolvedTypeId,
  template : Int,
  specialization : StarshineGenericSpecialization,
) -> (Int, Int)? {
  if function_type < 0 || function_type >= lowering.resolved_types.length() {
    return None
  }
  let (resolved_parameters, resolved_result) = match
    lowering.resolved_types[function_type] {
    @semantic.FunctionType(parameters, result) => (parameters, result)
    _ => return None
  }
  let mut original = None
  for source in module_.function_types {
    if source.signature_type_index == template {
      original = Some(source)
      break
    }
  }
  let original = match original {
    Some(value) => value
    None => return None
  }
  let owner = planned.module_lookup.get(lowering.module_id).unwrap()
  let parameters = []
  let results = []
  let source_parameters = []
  let source_results = []
  for index in 0..<original.parameters.length {
    source_parameters.push(
      starshine_program_value_type(
        planned,
        owner,
        module_.function_value_types[original.parameters.start + index],
      ),
    )
  }
  for index in 0..<original.results.length {
    source_results.push(
      starshine_program_value_type(
        planned,
        owner,
        module_.function_value_types[original.results.start + index],
      ),
    )
  }
  let mut position = 0
  for index in 0..<resolved_parameters.length {
    position = starshine_append_specialized_callback_types(
      lowering,
      specialization,
      lowering.resolved_type_arguments[resolved_parameters.start + index],
      source_parameters,
      position,
      parameters,
    )
  }
  guard position == source_parameters.length() else {
    abort("callback parameters leave unused physical carriers")
  }
  let result_end = starshine_append_specialized_callback_types(
    lowering, specialization, resolved_result, source_results, 0, results,
  )
  guard result_end == source_results.length() else {
    abort("callback result leaves unused physical carriers")
  }
  let direct = starshine_program_find_signature_by_types(
    planned, parameters, results,
  )
  let entry_parameters = [@lib.ValType::eqref_null()]
  for parameter in parameters {
    entry_parameters.push(parameter)
  }
  let entry = starshine_program_find_signature_by_types(
    planned, entry_parameters, results,
  )
  if direct < 0 || entry < 0 {
    None
  } else {
    Some((entry, direct))
  }
}
