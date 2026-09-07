///|
fn LocalTypeSolver::check_union_size(
  self : LocalTypeSolver,
  left : TypeVariableId,
  right : TypeVariableId,
) -> Result[Int, SolverInvariantFailure] {
  let left_root = match self.check_variable_root(left) {
    Ok(root) => root
    Err(error) => return Err(error)
  }
  if left_root != left {
    return Err(self.solver_failure(203, left_root, left, 0))
  }
  let right_root = match self.check_variable_root(right) {
    Ok(root) => root
    Err(error) => return Err(error)
  }
  if right_root != right {
    return Err(self.solver_failure(203, right_root, right, 0))
  }
  if left == right {
    return Err(self.solver_failure(203, 1, 0, left))
  }
  let count = self.variable_parents.length()
  let left_size = self.variable_sizes[left]
  let right_size = self.variable_sizes[right]
  if left_size <= 0 || left_size > count {
    return Err(self.solver_failure(203, count, left_size, left))
  }
  if right_size <= 0 || right_size > count {
    return Err(self.solver_failure(203, count, right_size, right))
  }
  if right_size > count - left_size {
    return Err(self.solver_failure(203, count - left_size, right_size, right))
  }
  Ok(left_size + right_size)
}

///|
fn LocalTypeSolver::check_resolved_type_encoding(
  self : LocalTypeSolver,
  type_ : ResolvedTypeId,
) -> Result[BodyTypeId, SolverInvariantFailure] {
  if type_ > 2147483646 {
    return Err(self.solver_failure(207, 2147483646, type_, 0))
  }
  if type_ < 0 || type_ >= self.resolved.types.length() {
    return Err(self.solver_failure(104, self.resolved.types.length(), type_, 0))
  }
  if type_ == self.resolved.error_type {
    Ok(self.error_type())
  } else {
    Ok(-type_ - 2)
  }
}
