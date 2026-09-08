///|
fn check_program_specialized_function_lookup(
  link : PlannedProgramWasmGCLink,
  declaration : DeclId,
  shapes : Array[PlannedValueShape],
  span : HirSpan,
) -> Result[PlannedProgramWasmFunction?, ProgramFunctionLookupFailure] {
  match check_program_lookup_shape_span(declaration, shapes, span, 1UL, 2UL) {
    Err(failure) => return Err(failure)
    Ok(_) => ()
  }
  let mut selected : PlannedProgramWasmFunction? = None
  let mut count = 0
  for slot, function_ in link.functions {
    // Export adapters are not source specializations. Their duplicate shape
    // metadata describes an adapter signature, not a second source instance.
    if function_.declaration != declaration ||
      function_.elided ||
      function_.erased_adapter_target >= 0 ||
      function_.specialization_shapes.length == 0 {
      continue
    }
    guard function_.module_index >= 0 &&
      function_.module_index < link.modules.length() else {
      return Err(
        program_function_lookup_failure(
          declaration,
          101,
          link.modules.length().to_uint64(),
          function_.module_index.reinterpret_as_uint().to_uint64(),
          (3UL << 32) | slot.to_uint64(),
        ),
      )
    }
    let values = link.modules[function_.module_index].specialization_shapes
    match
      check_program_lookup_shape_span(
        declaration,
        values,
        function_.specialization_shapes,
        4UL,
        5UL,
      ) {
      Err(failure) => return Err(failure)
      Ok(_) => ()
    }
    if program_specialization_shapes_equal(
        values,
        function_.specialization_shapes,
        shapes,
        span,
      ) {
      selected = Some(function_)
      count += 1
    }
  }
  guard count <= 1 else {
    return Err(
      program_function_lookup_failure(
        declaration,
        304,
        1UL,
        count.to_uint64(),
        0UL,
      ),
    )
  }
  Ok(selected)
}

///|
fn check_program_lookup_shape_span(
  declaration : DeclId,
  values : Array[PlannedValueShape],
  span : HirSpan,
  span_role : UInt64,
  shape_role : UInt64,
) -> Result[Unit, ProgramFunctionLookupFailure] {
  guard program_specialization_span_is_valid(span, values.length()) else {
    return Err(
      program_function_lookup_failure(
        declaration,
        101,
        values.length().to_uint64(),
        (span.start.reinterpret_as_uint().to_uint64() << 32) |
        span.length.reinterpret_as_uint().to_uint64(),
        span_role << 32,
      ),
    )
  }
  for index in 0..<span.length {
    let actual = match
      program_specialization_shape_error(values[span.start + index]) {
      None => continue
      Some("generic") => 1UL
      Some("error") => 2UL
      Some(_) => abort("SPC-301 unknown specialization shape failure")
    }
    return Err(
      program_function_lookup_failure(
        declaration,
        301,
        0UL,
        actual,
        (shape_role << 32) | (span.start + index).to_uint64(),
      ),
    )
  }
  Ok(())
}
