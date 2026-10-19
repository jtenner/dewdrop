///|
pub struct CompileTimeFunctionIdentity {
  declaration : DeclId
  generic_function : Bool
  specialization : UInt32?
}

///|
fn transform_function_identity(
  module_ : PlannedModuleLowering,
  declaration : DeclId,
) -> CompileTimeFunctionIdentity? {
  match module_.functions.callable_of(declaration) {
    Some(callable) if !callable.has_receiver => Some({
      declaration,
      specialization: None,
      generic_function: callable.generic_parameters.length != 0 ||
        callable.owner_generic_parameters.length != 0,
    })
    _ => None
  }
}

///|
// Interpreter frames retain more logical types than runtime functions need.
// Preserve the normal planner's identity, including its selected evidence.
fn transform_specialized_function_identity(
  lowering : PlannedProgramLowering,
  declaration : DeclId,
  frame : String,
  runtime_logical : Map[DeclId, Bool],
  runtime_sensitive : Map[DeclId, Bool],
  identities : Map[(DeclId, String), UInt32],
) -> CompileTimeFunctionIdentity? {
  let owner = lowering.index.declaration_owner(declaration).unwrap()
  let identity = match transform_function_identity(lowering.modules[owner], declaration) {
    Some(value) => value
    None => return None
  }
  if !identity.generic_function || frame == "" { return Some(identity) }
  let mut specialization = frame
  if !runtime_logical.contains(declaration) && !runtime_sensitive.contains(declaration) {
    let context = lowering.compile_time.unwrap()
    if context.instances.get(frame) is Some(instance) {
      let suffix = ":logical[" + compile_time_types_key(instance.types) + "]"
      guard frame.has_suffix(suffix) else {
        abort("SPC-302 checked transform frame lost its logical suffix")
      }
      specialization = frame[:frame.length() - suffix.length()].to_string()
    }
  }
  let key = identities.get_or_init((declaration, specialization), fn() {
    identities.length().to_uint()
  })
  Some({ ..identity, specialization: Some(key), })
}
