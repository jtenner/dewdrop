///|
// A saved Error must never be repaired by resolving a neighboring Generic.
// Concrete scalars and erased values require no worklist allocation.
fn lambda_capture_shape_error(shape : PlannedValueShape) -> UInt64 {
  let work = match shape {
    GenericPlannedValueShape => return 1UL
    ErrorPlannedValueShape => return 2UL
    ProductPlannedValueShape(fields) => fields.copy()
    _ => return 0UL
  }
  let mut reason = 0UL
  while !work.is_empty() {
    match work.pop().unwrap() {
      GenericPlannedValueShape => reason = 1UL
      ErrorPlannedValueShape => return 2UL
      ProductPlannedValueShape(fields) =>
        for field in fields {
          work.push(field)
        }
      _ => ()
    }
  }
  reason
}

///|
pub fn verify_module_lambda_closure_types(
  module_ : PlannedModuleWasmGCFragments,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  let failure = fn(code, expected, actual, role, slot) {
    physical_type_failure(
      module_.module_id,
      0UL,
      code,
      expected,
      actual,
      role,
      slot,
    )
  }
  let physical = module_.physical_types
  let seen = Array::make(physical.length(), false)
  let maps = [module_.lambda_closure_type_indices]
  for _, layout in module_.specialized_lambda_layouts {
    guard layout.closure_types.length() ==
      module_.lambda_closure_type_indices.length() &&
      layout.capture_fields.length() ==
      module_.lambda_capture_field_indices.length() &&
      layout.capture_parameters.length() ==
      module_.lambda_capture_parameter_indices.length() else {
      return Err(failure(103, 1UL, 0UL, 100UL, 0))
    }
    maps.push(layout.closure_types)
  }
  for map in maps {
    for lambda, index in map {
      if index == -1 {
        continue
      }
      guard index >= 0 && index < physical.length() else {
        return Err(
          failure(
            101,
            physical.length().to_uint64(),
            index.reinterpret_as_uint().to_uint64(),
            102UL,
            lambda,
          ),
        )
      }
      let actual = match physical[index].kind {
        PlannedWasmLambdaClosureType(owner) => owner
        _ => -1
      }
      guard actual == lambda else {
        return Err(
          failure(
            504,
            lambda.to_uint64(),
            actual.reinterpret_as_uint().to_uint64(),
            101UL,
            lambda,
          ),
        )
      }
      seen[index] = true
    }
  }
  for index, type_ in physical {
    let lambda = match type_.kind {
      PlannedWasmLambdaClosureType(owner) => owner
      _ => continue
    }
    guard lambda >= 0 && lambda < module_.lambda_closure_type_indices.length() else {
      return Err(
        failure(
          101,
          module_.lambda_closure_type_indices.length().to_uint64(),
          lambda.reinterpret_as_uint().to_uint64(),
          103UL,
          index,
        ),
      )
    }
    guard seen[index] else { return Err(failure(503, 1UL, 0UL, 107UL, index)) }
    guard module_.closure_type_index >= 0 else {
      return Err(failure(503, 1UL, 0UL, 108UL, index))
    }
    guard arena_span_is_valid(type_.fields, module_.fields.length()) else {
      return Err(
        failure(
          101,
          module_.fields.length().to_uint64(),
          program_function_span_code(type_.fields),
          104UL,
          index,
        ),
      )
    }
    guard type_.fields.length > 0 else {
      return Err(failure(504, 1UL, 0UL, 105UL, index))
    }
    let entry = module_.fields[type_.fields.start]
    guard entry.role == WasmClosureEntryField &&
      entry.physical_index == 0 &&
      entry.storage == WasmNullableFunctionRefStorage &&
      !entry.mutable_ else {
      return Err(failure(504, 1UL, 0UL, 105UL, index))
    }
    let mut previous = -1
    for relative in 1..<type_.fields.length {
      let slot = type_.fields.start + relative
      let field = module_.fields[slot]
      let capture = match field.role {
        WasmLambdaCaptureField(owner, capture) if owner == lambda => capture
        _ => -1
      }
      guard capture > previous &&
        capture < module_.lambda_capture_field_indices.length() &&
        field.physical_index == relative &&
        !field.mutable_ else {
        return Err(failure(504, 1UL, 0UL, 106UL, slot))
      }
      previous = capture
    }
  }
  Ok(())
}

///|
// The selected lowering supplies capture ownership and shapes that the fragment
// record alone cannot retain. Call this after selecting its lambda layout.
pub fn verify_lambda_capture_layout(
  lowering : PlannedModuleLowering,
  module_ : PlannedModuleWasmGCFragments,
  lambda : LambdaId,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  let failure = fn(code, expected, actual, role, slot) {
    physical_type_failure(
      module_.module_id,
      0UL,
      code,
      expected,
      actual,
      role,
      slot,
    )
  }
  guard module_.module_id == lowering.module_id else {
    return Err(failure(106, lowering.module_id, module_.module_id, 109UL, 0))
  }
  guard module_.lambda_closure_type_indices.length() ==
    lowering.lambdas.length() &&
    module_.lambda_capture_field_indices.length() == lowering.captures.length() &&
    module_.lambda_capture_parameter_indices.length() ==
    lowering.captures.length() else {
    return Err(failure(103, 1UL, 0UL, 110UL, 0))
  }
  guard lambda >= 0 && lambda < lowering.lambdas.length() else {
    return Err(
      failure(
        101,
        lowering.lambdas.length().to_uint64(),
        lambda.reinterpret_as_uint().to_uint64(),
        111UL,
        lambda,
      ),
    )
  }
  let source = lowering.lambdas[lambda]
  if source.elided {
    return Ok(())
  }
  guard arena_span_is_valid(source.captures, lowering.captures.length()) else {
    return Err(
      failure(
        101,
        lowering.captures.length().to_uint64(),
        program_function_span_code(source.captures),
        111UL,
        lambda,
      ),
    )
  }
  let type_index = module_.lambda_closure_type_indices[lambda]
  if !source.directized {
    guard type_index >= 0 && type_index < module_.physical_types.length() else {
      return Err(
        failure(
          101,
          module_.physical_types.length().to_uint64(),
          type_index.reinterpret_as_uint().to_uint64(),
          112UL,
          lambda,
        ),
      )
    }
    let type_ = module_.physical_types[type_index]
    guard type_.kind == PlannedWasmLambdaClosureType(lambda) else {
      return Err(failure(504, 1UL, 0UL, 101UL, lambda))
    }
    guard arena_span_is_valid(type_.fields, module_.fields.length()) &&
      type_.fields.length > 0 else {
      return Err(
        failure(
          101,
          module_.fields.length().to_uint64(),
          program_function_span_code(type_.fields),
          104UL,
          type_index,
        ),
      )
    }
  }
  let mut next = if source.directized { 0 } else { 1 }
  for relative in 0..<source.captures.length {
    let global = source.captures.start + relative
    let capture = lowering.captures[global]
    guard capture.lambda == lambda && capture.capture == relative else {
      return Err(
        failure(
          106,
          relative.to_uint64(),
          capture.capture.reinterpret_as_uint().to_uint64(),
          113UL,
          global,
        ),
      )
    }
    let saved_reason = lambda_capture_shape_error(capture.shape)
    let shape = if saved_reason == 1UL {
      guard lambda < module_.lambda_function_indices.length() else {
        return Err(
          failure(
            101,
            module_.lambda_function_indices.length().to_uint64(),
            lambda.to_uint64(),
            119UL,
            lambda,
          ),
        )
      }
      let function_index = module_.lambda_function_indices[lambda]
      guard function_index >= 0 && function_index < module_.functions.length() else {
        return Err(
          failure(
            101,
            module_.functions.length().to_uint64(),
            function_index.reinterpret_as_uint().to_uint64(),
            119UL,
            lambda,
          ),
        )
      }
      let fragment = module_.functions[function_index]
      let body_index = semantic_id_local(source.root_body)
      guard body_index >= 0 && body_index < lowering.bodies.length() else {
        return Err(
          failure(
            101,
            lowering.bodies.length().to_uint64(),
            body_index.reinterpret_as_uint().to_uint64(),
            119UL,
            lambda,
          ),
        )
      }
      let owner = match
        lowering.functions.callable_of(lowering.bodies[body_index].declaration) {
        Some(owner) => owner
        None => return Err(failure(503, 1UL, 0UL, 119UL, lambda))
      }
      let generics = program_callable_generic_parameters(owner)
      guard fragment.lambda == lambda &&
        fragment.kind == PlannedWasmDefinedLambdaFunction(lambda) &&
        fragment.specialization_abi_key != "" &&
        fragment.specialization_shapes.length == generics.length &&
        arena_span_is_valid(
          fragment.specialization_shapes,
          module_.specialization_shapes.length(),
        ) else {
        return Err(failure(504, 1UL, 0UL, 119UL, lambda))
      }
      program_resolve_specialized_shape(
        lowering,
        generics,
        module_.specialization_shapes,
        fragment.specialization_shapes,
        capture.type_,
        capture.shape,
      )
    } else {
      capture.shape
    }
    let reason = if saved_reason == 1UL {
      lambda_capture_shape_error(shape)
    } else {
      saved_reason
    }
    guard reason == 0UL else {
      return Err(failure(301, 0UL, reason, 117UL, global))
    }
    let storage = wasmgc_capture_storage(shape, capture.mutable_)
    let table = if source.directized {
      module_.lambda_capture_parameter_indices
    } else {
      module_.lambda_capture_field_indices
    }
    let expected = if storage is Some(_) { next } else { -1 }
    guard table[global] == expected else {
      return Err(
        failure(
          504,
          expected.reinterpret_as_uint().to_uint64(),
          table[global].reinterpret_as_uint().to_uint64(),
          114UL,
          global,
        ),
      )
    }
    match storage {
      Some(storage) => {
        if source.directized {
          guard lambda < module_.lambda_function_indices.length() else {
            return Err(
              failure(
                101,
                module_.lambda_function_indices.length().to_uint64(),
                lambda.to_uint64(),
                119UL,
                lambda,
              ),
            )
          }
          let function_index = module_.lambda_function_indices[lambda]
          guard function_index >= 0 &&
            function_index < module_.functions.length() else {
            return Err(
              failure(
                101,
                module_.functions.length().to_uint64(),
                function_index.reinterpret_as_uint().to_uint64(),
                119UL,
                lambda,
              ),
            )
          }
          let function_ = module_.functions[function_index]
          guard arena_span_is_valid(
              function_.parameters,
              module_.function_value_types.length(),
            ) &&
            next < function_.parameters.length else {
            return Err(
              failure(
                101,
                function_.parameters.length.to_uint64(),
                next.to_uint64(),
                119UL,
                global,
              ),
            )
          }
          guard module_.function_value_types[function_.parameters.start + next] ==
            wasmgc_capture_value_type(storage) else {
            return Err(failure(504, 1UL, 0UL, 117UL, global))
          }
        } else {
          let type_ = module_.physical_types[type_index]
          guard next < type_.fields.length else {
            return Err(
              failure(
                101,
                type_.fields.length.to_uint64(),
                next.to_uint64(),
                115UL,
                global,
              ),
            )
          }
          let field = module_.fields[type_.fields.start + next]
          guard field.role == WasmLambdaCaptureField(lambda, relative) else {
            return Err(failure(106, 1UL, 0UL, 116UL, global))
          }
          guard field.storage == storage else {
            return Err(failure(504, 1UL, 0UL, 117UL, global))
          }
        }
        next += 1
      }
      None => ()
    }
  }
  if !source.directized {
    let count = module_.physical_types[type_index].fields.length
    guard count == next else {
      return Err(
        failure(504, next.to_uint64(), count.to_uint64(), 118UL, lambda),
      )
    }
  }
  Ok(())
}
