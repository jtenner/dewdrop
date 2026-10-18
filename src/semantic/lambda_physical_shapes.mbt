///|
priv struct LambdaPhysicalShapeFailure {
  code : Int32
  phase : Int32
  module_id : ModuleId
  declaration : DeclId
  body : BodyId
  expression : UInt32
  expected : UInt64
  actual : UInt64
  detail : UInt64
} derive(Eq, Debug)

///|
fn check_module_lambda_capture_shapes(
  lowering : PlannedModuleLowering,
) -> Result[Unit, LambdaPhysicalShapeFailure] {
  // Capture owners and spans have already passed assert_planned_capture_metadata.
  for capture in lowering.captures {
    let lambda = lowering.lambdas[capture.lambda]
    if lambda.elided {
      continue
    }
    let body = lowering.bodies[semantic_id_local(lambda.root_body)]
    match lowering.functions.callable_of(body.declaration) {
      Some(owner) if program_callable_generic_parameters(owner).length > 0 =>
        // Generic bases are logical templates. Their selected instances are
        // checked after substitution in prepare_compile_time_lambda_layouts.
        continue
      _ => ()
    }
    match
      check_lambda_physical_shape(
        lowering.module_id,
        body.declaration,
        lambda,
        capture.shape,
        (2UL << 32) | capture.capture.to_uint64(),
      ) {
      Err(failure) => return Err(failure)
      Ok(_) => ()
    }
  }
  Ok(())
}

///|
fn assert_module_lambda_capture_shapes(
  lowering : PlannedModuleLowering,
) -> Unit {
  match check_module_lambda_capture_shapes(lowering) {
    Ok(_) => ()
    Err(failure) => abort(@debug.to_string(failure))
  }
}

///|
fn check_lambda_physical_shape(
  module_id : ModuleId,
  declaration : DeclId,
  lambda : PlannedLambdaLowering,
  shape : PlannedValueShape,
  detail : UInt64,
) -> Result[Unit, LambdaPhysicalShapeFailure] {
  // Concrete scalar captures need no worklist or heap allocation.
  match shape {
    GenericPlannedValueShape
    | ErrorPlannedValueShape
    | ProductPlannedValueShape(_) => ()
    _ => return Ok(())
  }
  let reason = match program_specialization_shape_error(shape) {
    None => return Ok(())
    Some("generic") => 1UL
    Some("error") => 2UL
    Some(_) => abort("SPC-301 unknown physical shape error code")
  }
  Err({
    code: 301,
    phase: 4,
    module_id,
    declaration,
    body: lambda.root_body,
    expression: lambda.expressions.start.reinterpret_as_uint(),
    expected: 0UL,
    actual: reason,
    detail,
  })
}

///|
fn assert_lambda_physical_shape(
  module_id : ModuleId,
  declaration : DeclId,
  lambda : PlannedLambdaLowering,
  shape : PlannedValueShape,
  detail : UInt64,
) -> Unit {
  match
    check_lambda_physical_shape(module_id, declaration, lambda, shape, detail) {
    Ok(_) => ()
    Err(failure) => abort(@debug.to_string(failure))
  }
}
