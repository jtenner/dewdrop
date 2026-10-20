///|
pub fn Plan::add_body_error(
  self : Plan,
  mi : Int32,
  path : String,
  offset : UInt64,
  message : String,
) -> Bool {
  if mi < 0 || mi >= self.files.length() {
    return false
  }
  for fi, file in self.files[mi] {
    if file.file.path == path {
      let _ = self.body_errors.get_or_init((mi, fi, offset.to_int()), fn() {
        message
      })
      return true
    }
  }
  false
}

///|
fn Machine::check_body(
  self : Machine,
  mi : Int32,
  fi : Int32,
  offset : UInt64,
) -> Unit raise EvalError {
  if self.plan.body_errors.get((mi, fi, offset.to_int())) is Some(message) {
    raise Failed("compile-time helper failed source checking:\n" + message)
  }
}
