///| Checked undo records share the solver's numeric failure context.
fn LocalTypeSolver::check_undo_arrays(
  self : LocalTypeSolver,
) -> Result[Unit, SolverInvariantFailure] {
  let count = self.undo_kinds.length()
  if self.undo_indices.length() != count {
    return Err(self.solver_failure(205, count, self.undo_indices.length(), 1))
  }
  if self.undo_values.length() != count {
    return Err(self.solver_failure(205, count, self.undo_values.length(), 2))
  }
  Ok(())
}

///|
fn LocalTypeSolver::check_undo_record(
  self : LocalTypeSolver,
  slot : Int,
) -> Result[Unit, SolverInvariantFailure] {
  match self.check_undo_arrays() {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let count = self.undo_kinds.length()
  if slot < 0 || slot >= count {
    return Err(self.solver_failure(205, count, slot, 0))
  }
  let kind = self.undo_kinds[slot]
  if kind < 0 || kind > 2 {
    return Err(self.solver_failure(205, 2, kind, slot))
  }
  let index = self.undo_indices[slot]
  let variables = self.variable_parents.length()
  if index < 0 || index >= variables {
    return Err(self.solver_failure(205, variables, index, kind))
  }
  let value = self.undo_values[slot]
  match kind {
    0 =>
      if value < 0 || value >= variables {
        return Err(self.solver_failure(205, variables, value, index))
      }
    1 =>
      if value <= 0 || value > variables {
        return Err(self.solver_failure(205, variables, value, index))
      }
    _ =>
      if value >= 0 {
        if value >= self.types.length() {
          return Err(self.solver_failure(205, self.types.length(), value, index))
        }
      } else if value < -1 {
        let resolved = -(value + 2)
        if resolved >= self.resolved.types.length() {
          return Err(self.solver_failure(205, self.resolved.types.length(), resolved, index))
        }
      }
  }
  Ok(())
}

///|
fn LocalTypeSolver::check_undo_restore(
  self : LocalTypeSolver,
  start : Int,
) -> Result[Unit, SolverInvariantFailure] {
  match self.check_undo_arrays() {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let count = self.undo_kinds.length()
  if start < 0 || start > count {
    return Err(self.solver_failure(205, count, start, 0))
  }
  let variables = self.variable_parents.length()
  if self.variable_sizes.length() != variables {
    return Err(self.solver_failure(201, variables, self.variable_sizes.length(), 1))
  }
  if self.variable_bindings.length() != variables {
    return Err(self.solver_failure(201, variables, self.variable_bindings.length(), 2))
  }
  if self.variable_types.length() != variables {
    return Err(self.solver_failure(201, variables, self.variable_types.length(), 3))
  }
  // Validate the whole range before the first restoration write. An invalid
  // older record cannot leave a partially restored solver or consume evidence.
  for slot in start..<count {
    match self.check_undo_record(slot) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
  }
  Ok(())
}

///|
fn LocalTypeSolver::assert_undo_arrays(self : LocalTypeSolver) -> Unit {
  match self.check_undo_arrays() {
    Ok(_) => ()
    Err(error) => abort("solver undo invariant: " + @debug.to_string(error))
  }
}
