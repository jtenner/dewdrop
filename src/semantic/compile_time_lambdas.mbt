///|
// A lambda belongs to its root function's logical instance. A carrier-only
// function key cannot distinguish two closures with different query results.
fn materialize_compile_time_lambdas(
  lowering : PlannedProgramLowering,
  module_index : Int,
  fragments : PlannedModuleWasmGCFragments,
  owner : PlannedWasmFunctionFragment,
) -> Int {
  let context = match lowering.compile_time {
    Some(value) => value
    None => return 0
  }
  let instance = match context.instances.get(owner.specialization_abi_key) {
    Some(value) => value.module_
    None => return 0
  }
  let root = match owner.kind {
    PlannedWasmDefinedFunction(body) => body
    _ => return 0
  }
  let mut added_signatures = 0
  prepare_compile_time_lambda_layouts(
    lowering.modules[module_index],
    instance,
    fragments,
    owner,
    root,
  )
  for index, lambda in instance.lambdas {
    if lambda.root_body != root {
      continue
    }
    let base_index = fragments.lambda_function_indices[index]
    if base_index < 0 {
      continue
    }
    let base = fragments.functions[base_index]
    fragments.functions[base_index] = { ..base, elided: true, }
    if lambda.elided {
      continue
    }
    let callable = instance.functions.callable_of(owner.declaration).unwrap()
    let generics = program_callable_generic_parameters(callable)
    let parameter_start = fragments.function_value_types.length()
    // Directized captures are parameters; escaping closures have one env
    // parameter. Neither is a logical source parameter.
    if lambda.directized {
      for offset in 0..<lambda.captures.length {
        let capture = instance.captures[lambda.captures.start + offset]
        match wasmgc_capture_storage(capture.shape, capture.mutable_) {
          Some(storage) =>
            fragments.function_value_types.push(
              wasmgc_capture_value_type(storage),
            )
          None => ()
        }
      }
    } else {
      fragments.function_value_types.push(WasmNullableEqRefValue)
    }
    for offset in 0..<lambda.locals.length {
      let local = instance.locals[lambda.locals.start + offset]
      if local.kind == ParameterLocal {
        program_append_specialization_value_types(
          fragments.function_value_types,
          program_resolve_specialized_shape(
            instance,
            generics,
            fragments.specialization_shapes,
            owner.specialization_shapes,
            local.type_,
            local.shape,
          ),
        )
      }
    }
    let result_start = fragments.function_value_types.length()
    program_append_specialization_value_types(
      fragments.function_value_types,
      program_resolve_specialized_shape(
        instance,
        generics,
        fragments.specialization_shapes,
        owner.specialization_shapes,
        lambda.root_type,
        lambda.result_shape,
      ),
    )
    let parameters = {
      start: parameter_start,
      length: result_start - parameter_start,
    }
    let results = {
      start: result_start,
      length: fragments.function_value_types.length() - result_start,
    }
    let signature_type_index = fragments.physical_types.length() +
      fragments.signature_type_count +
      1 +
      added_signatures
    added_signatures += 1
    fragments.function_types.push({
      resolved_type: -1,
      signature_type_index,
      parameters,
      results,
    })
    fragments.functions.push({
      ..base,
      elided: false,
      signature_type_index,
      parameters,
      results,
      function_index: -1,
      specialization_shapes: owner.specialization_shapes,
      specialization_evidence: owner.specialization_evidence,
      specialization_abi_key: owner.specialization_abi_key,
    })
  }
  guard instance.module_id == lowering.modules[module_index].module_id else {
    abort("LNK-504 query lambda module identity mismatch")
  }
  added_signatures
}

///|
// Select once for the emitting function. Lambda lookups below this boundary
// use this exact table, never the first linked lambda for a declaration.
pub fn program_function_fragments(
  module_ : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  key : String,
) -> PlannedModuleWasmGCFragments {
  if key == "" {
    return fragments
  }
  let indices = fragments.lambda_function_indices.copy()
  let entries = fragments.lambda_entry_signature_indices.copy()
  let closure_entries = fragments.closure_entry_type_by_resolved.copy()
  let selected = Array::make(indices.length(), false)
  for index, function_ in fragments.functions {
    if function_.lambda >= 0 &&
      !function_.elided &&
      function_.specialization_abi_key == key {
      guard !selected[function_.lambda] else {
        abort("SPC-303 duplicate lambda target for a logical instance")
      }
      selected[function_.lambda] = true
      indices[function_.lambda] = index
      entries[function_.lambda] = function_.signature_type_index
      if !module_.lambdas[function_.lambda].directized {
        let original = fragments.lambda_entry_signature_indices[function_.lambda]
        for resolved, signature in fragments.closure_entry_type_by_resolved {
          if signature == original {
            closure_entries[resolved] = function_.signature_type_index
          }
        }
      }
    }
  }
  let layout = fragments.specialized_lambda_layouts.get(key)
  {
    ..fragments,
    lambda_function_indices: indices,
    lambda_entry_signature_indices: entries,
    closure_entry_type_by_resolved: closure_entries,
    lambda_closure_type_indices: match layout {
      Some(value) => value.closure_types
      None => fragments.lambda_closure_type_indices
    },
    lambda_capture_field_indices: match layout {
      Some(value) => value.capture_fields
      None => fragments.lambda_capture_field_indices
    },
    lambda_capture_parameter_indices: match layout {
      Some(value) => value.capture_parameters
      None => fragments.lambda_capture_parameter_indices
    },
  }
}
