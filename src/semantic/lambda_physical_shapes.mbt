///|
priv struct LambdaPhysicalShapeFailure {
  code : Int
  phase : Int
  module_id : ModuleId
  declaration : DeclId
  body : BodyId
  expression : UInt
  expected : UInt64
  actual : UInt64
  detail : UInt64
} derive(Eq, Debug)

///|
fn check_lambda_physical_shape(
  module_id : ModuleId,
  declaration : DeclId,
  lambda : PlannedLambdaLowering,
  shape : PlannedValueShape,
  detail : UInt64,
) -> Result[Unit, LambdaPhysicalShapeFailure] {
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
