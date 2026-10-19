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

///|
fn starshine_check_lambda_capture_cells(
  lowering : @semantic.PlannedModuleLowering,
  lambda : @semantic.LambdaId,
  specialization : StarshineGenericSpecialization?,
) -> Result[Unit, StarshineCodeEmissionError] {
  // Capture metadata has already checked source owners and arena spans. Check
  // every capture, rather than only the first alias of a mutable local.
  let captures = lowering.lambdas[lambda].captures
  for index in captures.start..<(captures.start + captures.length) {
    let capture = lowering.captures[index]
    let (body, local_index) = match capture.source {
      @semantic.BodyLocalCapture(owner, id) => {
        let body = lowering.bodies[@semantic.semantic_id_local(owner)]
        (body, body.locals.start + id)
      }
      @semantic.LambdaLocalCapture(owner, id) => {
        let source = lowering.lambdas[owner]
        let body = lowering.bodies[@semantic.semantic_id_local(source.root_body)]
        (body, source.locals.start + id)
      }
    }
    let local_ = lowering.locals[local_index]
    if !capture.mutable_ && !local_.mutable_ {
      continue
    }
    let selected = starshine_specialized_shape(
      lowering,
      specialization,
      local_.type_,
      local_.shape,
    )
    match
      starshine_check_capture_cell_shape(
        lowering,
        body,
        local_index,
        local_.shape,
        selected,
      ) {
      Ok(_) => ()
      Err(error) => return Err(error)
    }
    // Emission selects these cells from the saved shapes. Compare physical
    // slots: packed integers share I32, and products share the reference cell.
    // Include erased slots so a missing cell cannot agree with a real cell.
    let source_slot = if local_.mutable_ {
      @semantic.wasmgc_capture_cell_slot(local_.shape)
    } else {
      -1
    }
    let capture_slot = if capture.mutable_ {
      @semantic.wasmgc_capture_cell_slot(capture.shape)
    } else {
      -1
    }
    if source_slot != capture_slot {
      return Err(
        CompilerInvariantFailure({
          code: 302U,
          phase: 7U,
          module_id: lowering.module_id,
          declaration: body.declaration,
          body: body.body,
          expression: 0xffffffffU,
          expected: source_slot.reinterpret_as_uint().to_uint64(),
          actual: capture_slot.reinterpret_as_uint().to_uint64(),
          detail: (2UL << 32) | index.to_uint64(),
        }),
      )
    }
  }
  Ok(())
}
