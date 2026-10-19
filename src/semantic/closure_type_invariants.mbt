///|
pub fn verify_module_closure_type(
  module_ : PlannedModuleWasmGCFragments,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  let index = module_.closure_type_index
  let physical = module_.physical_types
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
  guard index >= -1 && index < physical.length() else {
    return Err(
      failure(
        101,
        physical.length().to_uint64(),
        index.reinterpret_as_uint().to_uint64(),
        90UL,
        0,
      ),
    )
  }
  if index >= 0 {
    let closure = physical[index]
    guard closure.kind is PlannedWasmClosureType else {
      return Err(failure(504, 1UL, 0UL, 91UL, index))
    }
    guard closure.type_index == index else {
      return Err(
        failure(
          502,
          index.to_uint64(),
          closure.type_index.reinterpret_as_uint().to_uint64(),
          92UL,
          index,
        ),
      )
    }
    let span = closure.fields
    guard span.start >= 0 &&
      span.length >= 0 &&
      span.start <= module_.fields.length() &&
      span.length <= module_.fields.length() - span.start else {
      return Err(
        failure(
          101,
          module_.fields.length().to_uint64(),
          program_function_span_code(span),
          93UL,
          index,
        ),
      )
    }
    guard span.length == 1 else {
      return Err(failure(504, 1UL, span.length.to_uint64(), 94UL, index))
    }
    let field = module_.fields[span.start]
    guard field.physical_index == 0 else {
      return Err(
        failure(
          504,
          0UL,
          field.physical_index.reinterpret_as_uint().to_uint64(),
          95UL,
          span.start,
        ),
      )
    }
    guard field.role is WasmClosureEntryField else {
      return Err(failure(504, 1UL, 0UL, 96UL, span.start))
    }
    guard !field.mutable_ else {
      return Err(failure(504, 0UL, 1UL, 97UL, span.start))
    }
    guard field.storage is WasmNullableFunctionRefStorage else {
      return Err(failure(504, 1UL, 0UL, 98UL, span.start))
    }
  }
  // Each declared common closure type must have the one exact lookup.
  // This also rejects orphan and duplicate common closure types.
  for slot, type_ in physical {
    if type_.kind is PlannedWasmClosureType && index != slot {
      return Err(
        failure(
          if index == -1 {
            503
          } else {
            504
          },
          slot.to_uint64(),
          index.reinterpret_as_uint().to_uint64(),
          99UL,
          slot,
        ),
      )
    }
  }
  Ok(())
}
