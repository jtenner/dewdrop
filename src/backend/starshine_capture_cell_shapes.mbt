///|
fn starshine_capture_cell_shape_error(
  shape : @semantic.PlannedValueShape,
) -> UInt64 {
  let work = match shape {
    @semantic.GenericPlannedValueShape => return 1UL
    @semantic.ErrorPlannedValueShape => return 2UL
    @semantic.ProductPlannedValueShape(fields) => fields.copy()
    // Concrete scalars and erased values need no worklist.
    _ => return 0UL
  }
  let mut reason = 0UL
  while !work.is_empty() {
    match work.pop().unwrap() {
      @semantic.GenericPlannedValueShape => reason = 1UL
      @semantic.ErrorPlannedValueShape => return 2UL
      @semantic.ProductPlannedValueShape(fields) =>
        for field in fields {
          work.push(field)
        }
      _ => ()
    }
  }
  reason
}

///|
fn starshine_check_capture_cell_shape(
  lowering : @semantic.PlannedModuleLowering,
  body : @semantic.PlannedBodyLowering,
  index : Int32,
  shape : @semantic.PlannedValueShape,
  selected : @semantic.PlannedValueShape,
) -> Result[Unit, StarshineCodeEmissionError] {
  let saved_error = starshine_capture_cell_shape_error(shape)
  // An exported generic body can use its explicit erased reference ABI. It
  // must prove a concrete selected shape with the same cell carrier. Errors
  // in saved facts are never repaired through type substitution.
  let reason = if saved_error == 2UL {
    saved_error
  } else {
    starshine_capture_cell_shape_error(selected)
  }
  let (code, expected, actual) = if reason != 0UL {
    (301U, 0UL, reason)
  } else {
    let saved_slot = @semantic.wasmgc_capture_cell_slot(shape)
    let selected_slot = @semantic.wasmgc_capture_cell_slot(selected)
    if saved_slot == selected_slot {
      return Ok(())
    }
    if saved_error == 1UL {
      (301U, 0UL, saved_error)
    } else {
      (
        302U,
        saved_slot.reinterpret_as_uint().to_uint64(),
        selected_slot.reinterpret_as_uint().to_uint64(),
      )
    }
  }
  Err(
    CompilerInvariantFailure({
      code,
      phase: 7U,
      module_id: lowering.module_id,
      declaration: body.declaration,
      body: body.body,
      expression: 0xffffffffU,
      expected,
      actual,
      detail: index.to_uint64(),
    }),
  )
}
