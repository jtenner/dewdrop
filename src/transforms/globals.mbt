///|
fn Machine::global_value(
  self : Machine,
  mi : Int32,
  fi : Int32,
  declaration : @parser.LetDeclaration,
) -> Value raise EvalError {
  guard !declaration.mutable_ else {
    return eval_fail("mutable module bindings cannot execute at compile time")
  }
  let key = self.plan.modules[mi].path + "::" + declaration.name
  self.charge(32 + bytes(key).length())
  if self.globals.get(key) is Some(value) {
    return value
  }
  guard self.initializing.get(key) != Some(true) else {
    return eval_fail("cyclic compile-time constant initialization: " + key)
  }
  self.initializing[key] = true
  let previous = self.file_index
  self.file_index = fi
  let value = self.eval(mi, declaration.value, {}) catch {
    Returned(_) | Broken(_) | Continued(_) => {
      self.file_index = previous
      self.initializing[key] = false
      return eval_fail(
        "control flow escaped a compile-time constant initializer",
      )
    }
    error => {
      self.file_index = previous
      self.initializing[key] = false
      raise error
    }
  }
  self.file_index = previous
  self.initializing[key] = false
  self.globals[key] = value
  value
}
