///|
priv struct SolverInvariantFailure {
  code : Int
  module_id : ModuleId
  expected : Int
  actual : Int
  detail : Int
} derive(Eq, Debug)

///|
fn LocalTypeSolver::solver_failure(
  self : LocalTypeSolver,
  code : Int,
  expected : Int,
  actual : Int,
  detail : Int,
) -> SolverInvariantFailure {
  { code, module_id: self.resolved.module_id, expected, actual, detail }
}

///|
fn LocalTypeSolver::check_variable_root(
  self : LocalTypeSolver,
  variable : TypeVariableId,
) -> Result[TypeVariableId, SolverInvariantFailure] {
  let count = self.variable_parents.length()
  if self.variable_sizes.length() != count {
    return Err(self.solver_failure(201, count, self.variable_sizes.length(), 1))
  }
  if self.variable_bindings.length() != count {
    return Err(self.solver_failure(201, count, self.variable_bindings.length(), 2))
  }
  if self.variable_types.length() != count {
    return Err(self.solver_failure(201, count, self.variable_types.length(), 3))
  }
  let mut root = variable
  let mut hops = 0
  while true {
    if root < 0 || root >= count {
      return Err(self.solver_failure(202, count, root, variable))
    }
    if hops >= count {
      return Err(self.solver_failure(202, count, hops, variable))
    }
    let next = self.variable_parents[root]
    if next == root {
      return Ok(root)
    }
    root = next
    hops += 1
  }
  abort("SOL-202 unreachable end of root walk")
}

///|
fn LocalTypeSolver::compress_checked_variable_path(
  self : LocalTypeSolver,
  variable : TypeVariableId,
  root : TypeVariableId,
) -> Unit {
  // The complete path was checked before the first write. Preserve exact
  // transaction rollback by retaining the existing no-compression rule.
  if self.snapshots.length() == 0 {
    let mut current = variable
    while self.variable_parents[current] != current {
      let next = self.variable_parents[current]
      self.variable_parents[current] = root
      current = next
    }
  }
}

///|
fn LocalTypeSolver::check_representative_type(
  self : LocalTypeSolver,
  type_ : BodyTypeId,
) -> Result[BodyTypeId, SolverInvariantFailure] {
  let mut current = type_
  let mut hops = 0
  let count = self.variable_parents.length()
  while true {
    if current < -1 {
      let resolved = -(current + 2)
      if resolved >= self.resolved.types.length() {
        return Err(self.solver_failure(104, self.resolved.types.length(), resolved, type_))
      }
      return Ok(current)
    }
    if current < 0 || current >= self.types.length() {
      return Err(self.solver_failure(104, self.types.length(), current, type_))
    }
    match self.types[current] {
      BodyVariableType(variable) => {
        let root = match self.check_variable_root(variable) {
          Ok(root) => root
          Err(error) => return Err(error)
        }
        if hops >= count {
          return Err(self.solver_failure(202, count, hops, type_))
        }
        hops += 1
        self.compress_checked_variable_path(variable, root)
        let binding = self.variable_bindings[root]
        if binding == -1 {
          let result = self.variable_types[root]
          if result < 0 || result >= self.types.length() || self.types[result] != BodyVariableType(root) {
            return Err(self.solver_failure(201, root, result, 4))
          }
          return Ok(result)
        }
        current = binding
      }
      BodyResolvedType(resolved) => {
        if resolved < 0 || resolved >= self.resolved.types.length() {
          return Err(self.solver_failure(104, self.resolved.types.length(), resolved, type_))
        }
        return Ok(current)
      }
      _ => return Ok(current)
    }
  }
  abort("SOL-202 unreachable end of binding walk")
}
