///|
pub struct CompileTimeFunctionIdentity {
  declaration : DeclId
  generic_function : Bool
}

///|
fn transform_function_identity(
  module_ : PlannedModuleLowering,
  declaration : DeclId,
) -> CompileTimeFunctionIdentity? {
  match module_.functions.callable_of(declaration) {
    Some(callable) if !callable.has_receiver => Some({
      declaration,
      generic_function: callable.generic_parameters.length != 0 ||
        callable.owner_generic_parameters.length != 0,
    })
    _ => None
  }
}
