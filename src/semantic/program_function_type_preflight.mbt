///|
fn verify_module_signature_values(
  module_ : PlannedModuleWasmGCFragments,
  declaration : DeclId,
  parameters : HirSpan,
  results : HirSpan,
  source_slot : Int,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  for item in [(77UL, parameters), (78UL, results)] {
    let (role, span) = item
    guard arena_span_is_valid(span, module_.function_value_types.length()) else {
      return Err(physical_type_failure(module_.module_id, declaration, 101,
        module_.function_value_types.length().to_uint64(), program_function_span_code(span), role, source_slot))
    }
    for relative in 0..<span.length {
      let slot = span.start + relative
      let checked = match module_.function_value_types[slot] {
        WasmNominalRefValue(index) | WasmNullableNominalRefValue(index) =>
          verify_physical_local_reference(module_, declaration, index, false, slot)
        WasmFunctionRefValue(index) =>
          verify_physical_local_reference(module_, declaration, index, true, slot)
        WasmFixedArrayRefValue(carrier) => {
          guard carrier >= 0 && carrier < 8 else {
            return Err(physical_type_failure(module_.module_id, declaration, 101,
              8UL, carrier.reinterpret_as_uint().to_uint64(), 52UL, slot))
          }
          Ok(())
        }
        _ => Ok(())
      }
      match checked {
        Err(error) => return Err(error)
        Ok(_) => ()
      }
    }
  }
  Ok(())
}

///|
// These structural function signatures are expanded by the interning equality
// walk. Nominal heap references are leaves, including recursive struct types.
// A cycle between structural signatures is not a nominal recursive group.
fn verify_module_function_type_expansion(
  module_ : PlannedModuleWasmGCFragments,
  by_signature : Map[Int, Int],
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  let colors = Array::make(module_.function_types.length(), 0)
  let work : Array[(Int, Bool)] = []
  for root in 0..<colors.length() {
    if colors[root] == 2 { continue }
    work.push((root, false))
    while !work.is_empty() {
      let (slot, leaving) = work.pop().unwrap()
      if leaving {
        colors[slot] = 2
        continue
      }
      if colors[slot] == 2 { continue }
      guard colors[slot] == 0 else {
        return Err(physical_type_failure(module_.module_id, 0UL, 108, 0UL, 1UL, 86UL, slot))
      }
      colors[slot] = 1
      work.push((slot, true))
      let source = module_.function_types[slot]
      for span in [source.parameters, source.results] {
        for relative in 0..<span.length {
          match module_.function_value_types[span.start + relative] {
            WasmFunctionRefValue(signature) => match by_signature.get(signature) {
              Some(child) => work.push((child, false))
              None => ()
            }
            _ => ()
          }
        }
      }
    }
  }
  Ok(())
}

///|
fn verify_module_function_type_fragments(
  module_ : PlannedModuleWasmGCFragments,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  let physical_count = module_.physical_types.length()
  let limit = physical_count.to_uint64() + module_.signature_type_count.to_uint64()
  let by_signature : Map[Int, Int] = {}
  let by_resolved : Map[Int, Int] = {}
  let resolved_count = module_.function_type_by_resolved.length()
  let callback_maps = [module_.closure_entry_type_by_resolved,
    module_.erased_closure_direct_type_by_resolved, module_.erased_closure_entry_type_by_resolved]
  for slot, indices in callback_maps {
    guard indices.length() == resolved_count else {
      return Err(physical_type_failure(module_.module_id, 0UL, 103,
        resolved_count.to_uint64(), indices.length().to_uint64(), 84UL, slot))
    }
  }
  for slot, source in module_.function_types {
    match verify_module_signature_values(module_, 0UL, source.parameters, source.results, slot) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
    let signature = source.signature_type_index
    guard signature >= physical_count && signature.to_uint64() < limit else {
      return Err(physical_type_failure(module_.module_id, 0UL, 101,
        limit, signature.reinterpret_as_uint().to_uint64(), 79UL, slot))
    }
    guard !by_signature.contains(signature) else {
      return Err(physical_type_failure(module_.module_id, 0UL, 404, 1UL, 2UL, 82UL, slot))
    }
    by_signature[signature] = slot
    let resolved = source.resolved_type
    // Closure entry and erased callback signatures have no logical type ID.
    if resolved == -1 { continue }
    guard resolved >= 0 && resolved < resolved_count else {
      return Err(physical_type_failure(module_.module_id, 0UL, 101,
        resolved_count.to_uint64(), resolved.reinterpret_as_uint().to_uint64(), 80UL, slot))
    }
    let actual = module_.function_type_by_resolved[resolved]
    guard actual == signature else {
      return Err(physical_type_failure(module_.module_id, 0UL, 106,
        signature.to_uint64(), actual.reinterpret_as_uint().to_uint64(), 81UL, slot))
    }
    guard !by_resolved.contains(resolved) else {
      return Err(physical_type_failure(module_.module_id, 0UL, 404, 1UL, 2UL, 82UL, slot))
    }
    by_resolved[resolved] = slot
  }
  for resolved, signature in module_.function_type_by_resolved {
    if signature == -1 { continue }
    guard by_resolved.contains(resolved) else {
      return Err(physical_type_failure(module_.module_id, 0UL, 404, 1UL, 0UL, 83UL, resolved))
    }
  }
  for indices in callback_maps {
    for resolved, signature in indices {
      if signature == -1 { continue }
      guard by_signature.contains(signature) else {
        return Err(physical_type_failure(module_.module_id, 0UL, 503,
          1UL, signature.reinterpret_as_uint().to_uint64(), 85UL, resolved))
      }
    }
  }
  for slot, source in module_.functions {
    if source.signature_type_index == -1 { continue }
    match verify_physical_local_reference(module_, source.declaration, source.signature_type_index, true, slot) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
    match verify_module_signature_values(module_, source.declaration, source.parameters, source.results, slot) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
  }
  verify_module_function_type_expansion(module_, by_signature)
}
