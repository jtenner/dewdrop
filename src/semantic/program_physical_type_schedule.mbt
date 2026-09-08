///|
// Reconstruct the exact type-section prefix consumed by emission. Canonical
// signatures may be shared by source maps, but each emitted slot occurs once.
fn verify_program_physical_type_schedule(
  link : PlannedProgramWasmGCLink,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  guard link.graph.module_ids.length() == link.modules.length() else {
    return Err(physical_type_failure(0UL, 0UL, 103, link.modules.length().to_uint64(), link.graph.module_ids.length().to_uint64(), 36UL, 0))
  }
  match verify_module_dependency_graph(link.graph) {
    Ok(_) => ()
    Err(error) => return Err(physical_type_failure(0UL, 0UL, 501,
      error.expected.reinterpret_as_uint().to_uint64(), error.actual.reinterpret_as_uint().to_uint64(), 38UL, error.detail))
  }
  for index, module_ in link.modules {
    guard link.graph.module_ids[index] == module_.module_id else {
      return Err(physical_type_failure(module_.module_id, 0UL, 504, module_.module_id, link.graph.module_ids[index], 37UL, index))
    }
  }
  guard link.type_count >= 0 else {
    return Err(physical_type_failure(0UL, 0UL, 503, 0UL, link.type_count.reinterpret_as_uint().to_uint64(), 39UL, 0))
  }
  let mut next = 0
  let append = fn(width, actual, module_id, role, slot) -> Result[Unit, ProgramPhysicalTypeFailure] {
    guard actual == next else {
      return Err(physical_type_failure(module_id, 0UL, 502, next.to_uint64(), actual.reinterpret_as_uint().to_uint64(), role, slot))
    }
    guard width >= 0 && next <= link.type_count && width <= link.type_count - next else {
      return Err(physical_type_failure(module_id, 0UL, 502, link.type_count.to_uint64(), next.to_uint64() + width.reinterpret_as_uint().to_uint64(), role, slot))
    }
    next += width
    Ok(())
  }
  guard link.fixed_array_type_base >= -1 else {
    return Err(physical_type_failure(0UL, 0UL, 503, 0xffffffffUL, link.fixed_array_type_base.reinterpret_as_uint().to_uint64(), 40UL, 0))
  }
  if !link.program_type_groups.is_empty() {
    match append(link.program_physical_types.length(), 0, 0UL, 41UL, 0) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
  }
  if link.fixed_array_type_base >= 0 {
    match append(8, link.fixed_array_type_base, 0UL, 40UL, 0) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
  }
  if !link.program_type_groups.is_empty() {
    for slot, signature in link.program_signature_types {
      match append(1, signature.type_index, link.modules[signature.module_index].module_id, 42UL, slot) {
        Err(error) => return Err(error)
        Ok(_) => ()
      }
    }
  } else {
    let signatures_by_module : Array[Array[Int]] = link.modules.map(fn(_) { [] })
    for slot, signature in link.program_signature_types {
      signatures_by_module[signature.module_index].push(slot)
    }
    for scc in link.graph.sccs {
      for offset in 0..<scc.length {
        let module_index = link.graph.scc_modules[scc.start + offset]
        let module_ = link.modules[module_index]
        match append(module_.physical_types.length(), link.module_type_bases[module_index], module_.module_id, 41UL, module_index) {
          Err(error) => return Err(error)
          Ok(_) => ()
        }
        for slot in signatures_by_module[module_index] {
          let signature = link.program_signature_types[slot]
          match append(1, signature.type_index, module_.module_id, 42UL, slot) {
            Err(error) => return Err(error)
            Ok(_) => ()
          }
        }
      }
    }
  }
  guard link.erased_box_type_indices.length() == 5 else {
    return Err(physical_type_failure(0UL, 0UL, 103, 5UL, link.erased_box_type_indices.length().to_uint64(), 43UL, 0))
  }
  for slot, index in link.erased_box_type_indices {
    guard index >= -1 else {
      return Err(physical_type_failure(0UL, 0UL, 503, 0xffffffffUL, index.reinterpret_as_uint().to_uint64(), 43UL, slot))
    }
    if index >= 0 {
      match append(1, index, 0UL, 43UL, slot) {
        Err(error) => return Err(error)
        Ok(_) => ()
      }
    }
  }
  guard link.initializer_type_index >= -1 else {
    return Err(physical_type_failure(0UL, 0UL, 503, 0xffffffffUL, link.initializer_type_index.reinterpret_as_uint().to_uint64(), 44UL, 0))
  }
  if link.initializer_type_index >= 0 {
    match append(1, link.initializer_type_index, 0UL, 44UL, 0) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
  }
  guard next == link.type_count else {
    return Err(physical_type_failure(0UL, 0UL, 502, link.type_count.to_uint64(), next.to_uint64(), 45UL, 0))
  }
  Ok(())
}
