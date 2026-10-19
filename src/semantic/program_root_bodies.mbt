///|
// Callable and module-value declarations share the checked body work queue.
fn program_root_body(
  module_ : PlannedModuleLowering,
  declaration : DeclId,
) -> PlannedBodyLowering? {
  let body = match module_.functions.callable_of(declaration) {
    Some(callable) =>
      match callable.kind {
        PlannedFunctionCallable(body)
        | PlannedImplMethodCallable(_, Some(body)) => Some(body)
        _ => None
      }
    None =>
      match module_.initialization.step_of(declaration) {
        Some(index) =>
          match module_.initialization.steps[index].kind {
            PlannedInitializeModuleValue(owner, body, _) if owner == declaration =>
              Some(body)
            _ => None
          }
        None => None
      }
  }
  guard body is Some(body) else { return None }
  let index = semantic_id_local(body)
  guard index >= 0 && index < module_.bodies.length() &&
    module_.bodies[index].body == body else {
    abort("SPC-304 checked planning root lost its body")
  }
  Some(module_.bodies[index])
}
