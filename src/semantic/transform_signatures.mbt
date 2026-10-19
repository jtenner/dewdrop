///|
fn transform_api_declaration(
  program : CollectedProgram,
  path : String,
  name : String,
) -> DeclId? {
  match program.module_index(path) {
    Some(index) => program.modules[index].lookup_type(name)
    None => None
  }
}

///|
fn transform_signature_nominal(
  module_ : PlannedModuleLowering,
  type_ : ResolvedTypeId,
  declaration : DeclId,
) -> Bool {
  type_ >= 0 &&
  type_ < module_.resolved_types.length() &&
  module_.resolved_types[type_] is NominalType(found) &&
  found == declaration
}

///|
pub fn compile_time_transform_signature_is_valid(
  program : CollectedProgram,
  lowering : PlannedProgramLowering,
  module_index : Int32,
  name : String,
) -> Bool {
  guard module_index >= 0 &&
    module_index < program.modules.length() &&
    module_index < lowering.modules.length() else {
    return false
  }
  guard transform_api_declaration(program, "dewdrop.ast", "FnNode")
    is Some(node) &&
    transform_api_declaration(program, "dewdrop.transform", "TransformContext")
    is Some(context) &&
    transform_api_declaration(program, "dewdrop.transform", "TransformError")
    is Some(error) else {
    return false
  }
  let module_ = lowering.modules[module_index]
  let mut selected : PlannedCallable? = None
  for declaration in program.modules[module_index].value_declarations(name) {
    if module_.functions.callable_of(declaration) is Some(callable) {
      guard selected is None else { return false }
      selected = Some(callable)
    }
  }
  guard selected is Some(callable) &&
    callable.kind is PlannedFunctionCallable(_) &&
    !callable.has_receiver &&
    callable.owner_generic_parameters.length == 0 &&
    callable.generic_parameters.length == 0 &&
    callable.parameters.length == 2 &&
    callable.parameters.start >= 0 &&
    callable.parameters.start + 2 <= module_.functions.parameters.length() else {
    return false
  }
  guard transform_signature_nominal(
      module_,
      module_.functions.parameters[callable.parameters.start].type_,
      node,
    ) &&
    transform_signature_nominal(
      module_,
      module_.functions.parameters[callable.parameters.start + 1].type_,
      context,
    ) else {
    return false
  }
  if transform_signature_nominal(module_, callable.result_type, node) {
    return true
  }
  guard callable.result_type >= 0 &&
    callable.result_type < module_.resolved_types.length() &&
    module_.resolved_types[callable.result_type] is AppliedType(base, arguments) &&
    arguments.length == 2 &&
    arguments.start >= 0 &&
    arguments.start + 2 <= module_.resolved_type_arguments.length() &&
    transform_api_declaration(program, "dew.std.result", "Result")
    is Some(result) &&
    transform_signature_nominal(module_, base, result) else {
    return false
  }
  transform_signature_nominal(
    module_,
    module_.resolved_type_arguments[arguments.start],
    node,
  ) &&
  transform_signature_nominal(
    module_,
    module_.resolved_type_arguments[arguments.start + 1],
    error,
  )
}
