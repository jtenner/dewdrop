///|
/// Empty keys are proven local bindings. Nonempty keys identify selected enum
/// variants. Owner nodes can share a tuple pattern's offset; the selected
/// constructor takes priority over an owner node's empty proof.
pub fn Plan::add_pattern_proof(
  self : Plan,
  module_index : Int32,
  file_path : String,
  offset : UInt64,
  constructor : String,
) -> Unit {
  if module_index < 0 || module_index >= self.files.length() {
    return
  }
  for fi, file in self.files[module_index] {
    if file.file.path != file_path {
      continue
    }
    let at = offset.to_int()
    if at < 0 || at >= file.clean.length() {
      return
    }
    let site = (module_index, fi, at)
    if constructor.is_empty() &&
      self.pattern_proofs.get(site) is Some(prior) &&
      !prior.is_empty() {
      return
    }
    self.pattern_proofs[site] = constructor
    return
  }
}

///|
fn Machine::pattern_key(
  self : Machine,
  mi : Int32,
  offset : UInt64,
) -> String raise EvalError {
  match self.plan.pattern_proofs.get((mi, self.file_index, offset.to_int())) {
    Some(key) => key
    None =>
      raise Failed(
        "pattern has no checked compile-time constructor or binding proof",
      )
  }
}
