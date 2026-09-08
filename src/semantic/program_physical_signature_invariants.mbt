///|
fn verify_program_physical_signatures(
  link : PlannedProgramWasmGCLink,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  let seen : Map[Int, Bool] = {}
  for slot, signature in link.program_signature_types {
    let owner = signature.module_index
    guard owner >= 0 && owner < link.modules.length() else {
      return Err(physical_type_failure(0UL, 0UL, 101, link.modules.length().to_uint64(), owner.reinterpret_as_uint().to_uint64(), 29UL, slot))
    }
    let module_ = link.modules[owner]
    let (declaration, local_index, parameters, results) = match signature.kind {
      PlannedProgramFunctionType(index) => {
        guard index >= 0 && index < module_.function_types.length() else {
          return Err(physical_type_failure(module_.module_id, 0UL, 101, module_.function_types.length().to_uint64(), index.reinterpret_as_uint().to_uint64(), 31UL, slot))
        }
        let source = module_.function_types[index]
        (0UL, source.signature_type_index, source.parameters, source.results)
      }
      PlannedProgramFunctionSignature(index) => {
        guard index >= 0 && index < module_.functions.length() else {
          return Err(physical_type_failure(module_.module_id, 0UL, 101, module_.functions.length().to_uint64(), index.reinterpret_as_uint().to_uint64(), 31UL, slot))
        }
        let source = module_.functions[index]
        (source.declaration, source.signature_type_index, source.parameters, source.results)
      }
    }
    let failure = fn(code, expected, actual, role) {
      physical_type_failure(module_.module_id, declaration, code, expected, actual, role, slot)
    }
    guard signature.type_index >= 0 && signature.type_index < link.type_count else {
      return Err(failure(503, link.type_count.reinterpret_as_uint().to_uint64(), signature.type_index.reinterpret_as_uint().to_uint64(), 30UL))
    }
    for item in [(32UL, parameters), (33UL, results)] {
      let (role, span) = item
      guard span.start >= 0 && span.length >= 0 && span.start <= module_.function_value_types.length() &&
        span.length <= module_.function_value_types.length() - span.start else {
        return Err(failure(101, module_.function_value_types.length().to_uint64(), program_function_span_code(span), role))
      }
    }
    let physical_count = module_.physical_types.length()
    let indices = link.module_signature_indices[owner]
    guard local_index >= physical_count && local_index - physical_count < indices.length() else {
      return Err(failure(101, indices.length().to_uint64(), local_index.reinterpret_as_uint().to_uint64(), 34UL))
    }
    let expected = indices[local_index - physical_count]
    guard signature.type_index == expected else {
      return Err(failure(504, expected.reinterpret_as_uint().to_uint64(), signature.type_index.to_uint64(), 34UL))
    }
    guard !seen.contains(signature.type_index) else {
      return Err(failure(502, 1UL, 2UL, 35UL))
    }
    seen[signature.type_index] = true
  }
  Ok(())
}
