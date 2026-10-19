///|
// Only these exact storage types are valid in the six shared cell families.
// Packed integers and string storage must not stand in for full cell values.
fn capture_cell_storage_slot(storage : PlannedWasmStorageType) -> Int32 {
  match storage {
    WasmI32Storage => 0
    WasmI64Storage => 1
    WasmF32Storage => 2
    WasmF64Storage => 3
    WasmV128Storage => 4
    WasmNullableEqRefStorage => 5
    _ => -1
  }
}

///|
pub fn verify_module_capture_cell_types(
  module_ : PlannedModuleWasmGCFragments,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  let cells = module_.capture_cell_type_indices
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
  guard cells.length() == 6 else {
    return Err(failure(103, 6UL, cells.length().to_uint64(), 80UL, 0))
  }
  for slot, index in cells {
    if index == -1 {
      continue
    }
    guard index >= 0 && index < physical.length() else {
      return Err(
        failure(
          101,
          physical.length().to_uint64(),
          index.reinterpret_as_uint().to_uint64(),
          81UL,
          slot,
        ),
      )
    }
    let cell = physical[index]
    let actual_slot = match cell.kind {
      PlannedWasmCaptureCellType(actual) => actual
      _ => -1
    }
    guard actual_slot == slot else {
      return Err(
        failure(
          504,
          slot.to_uint64(),
          actual_slot.reinterpret_as_uint().to_uint64(),
          82UL,
          slot,
        ),
      )
    }
    guard cell.type_index == index else {
      return Err(
        failure(
          502,
          index.to_uint64(),
          cell.type_index.reinterpret_as_uint().to_uint64(),
          4UL,
          index,
        ),
      )
    }
    let span = cell.fields
    guard span.start >= 0 &&
      span.length >= 0 &&
      span.start <= module_.fields.length() &&
      span.length <= module_.fields.length() - span.start else {
      return Err(
        failure(
          101,
          module_.fields.length().to_uint64(),
          program_function_span_code(span),
          6UL,
          index,
        ),
      )
    }
    guard span.length == 1 else {
      return Err(failure(504, 1UL, span.length.to_uint64(), 84UL, slot))
    }
    let field = module_.fields[span.start]
    guard field.physical_index == 0 else {
      return Err(
        failure(
          504,
          0UL,
          field.physical_index.reinterpret_as_uint().to_uint64(),
          7UL,
          span.start,
        ),
      )
    }
    let actual_role = match field.role {
      WasmCaptureCellValueField(actual) => actual
      _ => -1
    }
    guard actual_role == slot else {
      return Err(
        failure(
          504,
          slot.to_uint64(),
          actual_role.reinterpret_as_uint().to_uint64(),
          85UL,
          slot,
        ),
      )
    }
    guard field.mutable_ else { return Err(failure(504, 1UL, 0UL, 86UL, slot)) }
    let storage_slot = capture_cell_storage_slot(field.storage)
    guard storage_slot == slot else {
      return Err(
        failure(
          504,
          slot.to_uint64(),
          storage_slot.reinterpret_as_uint().to_uint64(),
          87UL,
          slot,
        ),
      )
    }
  }
  // Check the reverse relation too. A missing lookup, an orphan cell, or two
  // physical cells for one family must not silently lose a required mapping.
  for index, cell in physical {
    match cell.kind {
      PlannedWasmCaptureCellType(slot) => {
        guard slot >= 0 && slot < cells.length() else {
          return Err(
            failure(
              101,
              6UL,
              slot.reinterpret_as_uint().to_uint64(),
              88UL,
              index,
            ),
          )
        }
        let stored = cells[slot]
        guard stored == index else {
          return Err(
            failure(
              if stored == -1 {
                503
              } else {
                504
              },
              index.to_uint64(),
              stored.reinterpret_as_uint().to_uint64(),
              83UL,
              slot,
            ),
          )
        }
      }
      _ => ()
    }
  }
  Ok(())
}
