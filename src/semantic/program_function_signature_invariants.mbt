///|
fn program_function_span_code(span : HirSpan) -> UInt64 {
  (span.start.reinterpret_as_uint().to_uint64() << 32) |
  span.length.reinterpret_as_uint().to_uint64()
}

///|
fn check_program_function_span_copy(
  declaration : DeclId,
  slot : Int,
  role : UInt64,
  arena_length : Int,
  source : HirSpan,
  linked : HirSpan,
) -> Result[Unit, ProgramFunctionLookupFailure] {
  let detail = (role << 32) | slot.to_uint64()
  guard source.start >= 0 &&
    source.length >= 0 &&
    source.start <= arena_length &&
    source.length <= arena_length - source.start else {
    return Err(
      program_function_lookup_failure(
        declaration,
        101,
        arena_length.to_uint64(),
        program_function_span_code(source),
        detail,
      ),
    )
  }
  guard linked == source else {
    return Err(
      program_function_lookup_failure(
        declaration,
        504,
        program_function_span_code(source),
        program_function_span_code(linked),
        detail,
      ),
    )
  }
  Ok(())
}

///|
fn check_program_function_signature_copy(
  link : PlannedProgramWasmGCLink,
  slot : Int,
  module_ : PlannedModuleWasmGCFragments,
  source : PlannedWasmFunctionFragment,
  linked : PlannedProgramWasmFunction,
) -> Result[Unit, ProgramFunctionLookupFailure] {
  let declaration = linked.declaration
  let failure = fn(code, expected, actual, role) {
    program_function_lookup_failure(
      declaration,
      code,
      expected,
      actual,
      (role << 32) | slot.to_uint64(),
    )
  }
  match
    check_program_function_span_copy(
      declaration,
      slot,
      9UL,
      module_.function_value_types.length(),
      source.parameters,
      linked.parameters,
    ) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  match
    check_program_function_span_copy(
      declaration,
      slot,
      10UL,
      module_.function_value_types.length(),
      source.results,
      linked.results,
    ) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  match
    check_program_function_span_copy(
      declaration,
      slot,
      11UL,
      module_.specialization_shapes.length(),
      source.specialization_shapes,
      linked.specialization_shapes,
    ) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  match
    check_program_function_span_copy(
      declaration,
      slot,
      12UL,
      module_.specialization_evidence_roots.length(),
      source.specialization_evidence,
      linked.specialization_evidence,
    ) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  guard linked.direct_builtin == source.direct_builtin else {
    return Err(failure(504, 1UL, 0UL, 13UL))
  }
  guard linked.elided == source.elided else {
    return Err(
      failure(
        504,
        if source.elided {
          1UL
        } else {
          0UL
        },
        if linked.elided {
          1UL
        } else {
          0UL
        },
        14UL,
      ),
    )
  }
  let local_index = source.signature_type_index
  let expected = if local_index == -1 {
    -1
  } else {
    guard local_index >= 0 else {
      return Err(
        failure(503, 0UL, local_index.reinterpret_as_uint().to_uint64(), 15UL),
      )
    }
    let maps = if local_index < module_.physical_types.length() {
      link.module_type_indices
    } else {
      link.module_signature_indices
    }
    let local_slot = if local_index < module_.physical_types.length() {
      local_index
    } else {
      local_index - module_.physical_types.length()
    }
    let owner = linked.module_index
    guard owner >= 0 && owner < maps.length() else {
      return Err(
        failure(
          101,
          maps.length().to_uint64(),
          owner.reinterpret_as_uint().to_uint64(),
          16UL,
        ),
      )
    }
    let indices = maps[owner]
    guard local_slot < indices.length() else {
      return Err(
        failure(101, indices.length().to_uint64(), local_slot.to_uint64(), 17UL),
      )
    }
    let relocated = indices[local_slot]
    guard relocated >= 0 && relocated < link.type_count else {
      return Err(
        failure(
          503,
          link.type_count.reinterpret_as_uint().to_uint64(),
          relocated.reinterpret_as_uint().to_uint64(),
          18UL,
        ),
      )
    }
    relocated
  }
  guard linked.signature_type_index == expected else {
    return Err(
      failure(
        504,
        expected.reinterpret_as_uint().to_uint64(),
        linked.signature_type_index.reinterpret_as_uint().to_uint64(),
        15UL,
      ),
    )
  }
  Ok(())
}
