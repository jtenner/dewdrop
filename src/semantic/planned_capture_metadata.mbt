///|
fn check_planned_capture_metadata(
  lowering : PlannedModuleLowering,
  phase : Int,
) -> Result[Unit, BodyArenaFailure] {
  // Check complete source metadata, including generic and elided templates.
  // No physical carrier is required to prove an arena owner.
  for index, lambda in lowering.lambdas {
    let body = match
      planned_capture_metadata_body(
        lowering,
        lambda.root_body,
        phase,
        21,
        index,
      ) {
      Ok(body) => body
      Err(error) => return Err(error)
    }
    let checker = planned_capture_metadata_checker(lowering, body, phase)
    ignore(checker.capture_table(-1, index))
    if checker.span(-1, lambda.locals, lowering.locals.length(), 2) {
      for offset in 0..<lambda.locals.length {
        checker.local_identity(-1, lambda.locals.start + offset, offset, index)
        if checker.failure is Some(_) {
          break
        }
      }
    }
    if checker.failure is Some(error) {
      return Err(error)
    }
  }
  for index, local in lowering.locals {
    let body = match
      planned_capture_metadata_body(lowering, local.body, phase, 6, index) {
      Ok(body) => body
      Err(error) => return Err(error)
    }
    let checker = planned_capture_metadata_checker(lowering, body, phase)
    let span = if local.lambda == -1 {
      body.locals
    } else if checker.lambda(-1, local.lambda) {
      lowering.lambdas[local.lambda].locals
    } else {
      return Err(checker.failure.unwrap())
    }
    if checker.span(-1, span, lowering.locals.length(), 2) &&
      checker.owned(-1, span, index, 2) {
      checker.local_identity(-1, index, index - span.start, local.lambda)
    }
    if checker.failure is Some(error) {
      return Err(error)
    }
  }
  // Span consumers alone cannot see orphan entries outside every owner span.
  for index, capture in lowering.captures {
    if capture.lambda < 0 || capture.lambda >= lowering.lambdas.length() {
      return Err(
        planned_capture_metadata_failure(
          lowering,
          0UL,
          phase,
          104,
          0UL,
          capture.lambda.reinterpret_as_uint().to_uint64(),
          (18UL << 32) | lowering.lambdas.length().to_uint64(),
        ),
      )
    }
    let lambda = lowering.lambdas[capture.lambda]
    let body = match
      planned_capture_metadata_body(
        lowering,
        lambda.root_body,
        phase,
        21,
        capture.lambda,
      ) {
      Ok(body) => body
      Err(error) => return Err(error)
    }
    let checker = planned_capture_metadata_checker(lowering, body, phase)
    ignore(checker.owned(-1, lambda.captures, index, 17))
    if checker.failure is Some(error) {
      return Err(error)
    }
  }
  Ok(())
}

///|
fn planned_capture_metadata_checker(
  lowering : PlannedModuleLowering,
  body : PlannedBodyLowering,
  phase : Int,
) -> PlannedBodyChildChecker {
  {
    lowering,
    body,
    phase,
    local_span: { start: 0, length: body.locals.length, },
    owner_lambda: -1,
    capture_span: { start: 0, length: 0, },
    failure: None,
    syntax_walk: None,
  }
}

///|
fn planned_capture_metadata_failure(
  lowering : PlannedModuleLowering,
  body : BodyId,
  phase : Int,
  code : Int,
  expected : UInt64,
  actual : UInt64,
  detail : UInt64,
) -> BodyArenaFailure {
  {
    code,
    phase,
    module_id: lowering.module_id,
    declaration: 0UL,
    body,
    expression: 0xffffffffU,
    expected,
    actual,
    detail,
  }
}

///|
fn planned_capture_metadata_body(
  lowering : PlannedModuleLowering,
  owner : BodyId,
  phase : Int,
  tag : Int,
  entity : Int,
) -> Result[PlannedBodyLowering, BodyArenaFailure] {
  let module_id = semantic_id_module(owner)
  let detail = (tag.to_uint64() << 32) | entity.to_uint64()
  if module_id != lowering.module_id {
    return Err(
      planned_capture_metadata_failure(
        lowering,
        owner,
        phase,
        106,
        lowering.module_id,
        module_id,
        detail,
      ),
    )
  }
  let index = semantic_id_local(owner)
  if index < 0 || index >= lowering.bodies.length() {
    return Err(
      planned_capture_metadata_failure(
        lowering,
        owner,
        phase,
        104,
        lowering.bodies.length().to_uint64(),
        index.reinterpret_as_uint().to_uint64(),
        detail,
      ),
    )
  }
  let body = lowering.bodies[index]
  if body.body != owner {
    return Err(
      planned_capture_metadata_failure(
        lowering,
        owner,
        phase,
        106,
        owner,
        body.body,
        detail,
      ),
    )
  }
  Ok(body)
}

///|
pub fn assert_planned_capture_metadata(
  lowering : PlannedModuleLowering,
  phase : Int,
) -> Unit {
  match check_planned_capture_metadata(lowering, phase) {
    Ok(_) => ()
    Err(error) =>
      abort("planned capture metadata invariant: " + @debug.to_string(error))
  }
}

///|
pub fn assert_program_capture_metadata(
  lowering : PlannedProgramLowering,
  phase : Int,
) -> Unit {
  for module_ in lowering.modules {
    assert_planned_capture_metadata(module_, phase)
  }
  match lowering.compile_time {
    Some(context) =>
      for _, instance in context.instances {
        assert_planned_capture_metadata(instance.module_, phase)
      }
    None => ()
  }
}
