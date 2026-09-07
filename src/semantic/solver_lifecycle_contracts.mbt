///|
/// Check parallel state before any operation can clear or truncate it.
fn LocalTypeSolver::check_solver_arrays(
  self : LocalTypeSolver,
) -> Result[Unit, SolverInvariantFailure] {
  let variables = self.variable_parents.length()
  for
    entry in [
      (self.variable_sizes.length(), 1),
      (self.variable_bindings.length(), 2),
      (self.variable_types.length(), 3),
    ] {
    let (actual, detail) = entry
    if actual != variables {
      return Err(self.solver_failure(201, variables, actual, detail))
    }
  }
  match self.check_undo_arrays() {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let count = self.types.length()
  for
    entry in [
      (self.occurs_local_marks.length(), 10),
      (self.zonk_marks.length(), 11),
      (self.zonk_values.length(), 12),
    ] {
    let (actual, detail) = entry
    if actual != count {
      return Err(self.solver_failure(206, count, actual, detail))
    }
  }
  if self.unify_left.length() != self.unify_right.length() {
    return Err(
      self.solver_failure(
        206,
        self.unify_left.length(),
        self.unify_right.length(),
        20,
      ),
    )
  }
  let tasks = self.zonk_task_types.length()
  if self.zonk_task_states.length() != tasks {
    return Err(
      self.solver_failure(206, tasks, self.zonk_task_states.length(), 21),
    )
  }
  if self.zonk_result_starts.length() != tasks {
    return Err(
      self.solver_failure(206, tasks, self.zonk_result_starts.length(), 22),
    )
  }
  Ok(())
}

///|
fn LocalTypeSolver::check_solver_boundary(
  self : LocalTypeSolver,
  closed : Bool,
  detail : Int,
) -> Result[Unit, SolverInvariantFailure] {
  if closed && self.snapshots.length() != 0 {
    return Err(self.solver_failure(206, 0, self.snapshots.length(), detail))
  }
  match self.check_solver_arrays() {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  for
    entry in [
      (self.unify_left.length(), 40),
      (self.occurs_stack.length(), 41),
      (self.zonk_task_types.length(), 42),
      (self.zonk_results.length(), 45),
      (self.zonk_application_scratch.length(), 46),
    ] {
    let (actual, work) = entry
    if actual != 0 {
      return Err(self.solver_failure(206, 0, actual, work))
    }
  }
  if self.snapshots.is_empty() && !self.undo_kinds.is_empty() {
    return Err(self.solver_failure(205, 0, self.undo_kinds.length(), 3))
  }
  Ok(())
}

///|
fn LocalTypeSolver::assert_solver_boundary(
  self : LocalTypeSolver,
  closed : Bool,
  detail : Int,
) -> Unit {
  match self.check_solver_boundary(closed, detail) {
    Ok(_) => ()
    Err(error) =>
      abort("solver lifecycle invariant: " + @debug.to_string(error))
  }
}

///|
/// A search owns its work list. Check it on entry and drain it on normal exit,
// including an ordinary negative result. Never clear another operation's work.
fn LocalTypeSolver::assert_occurs_idle(self : LocalTypeSolver) -> Unit {
  match self.check_solver_arrays() {
    Ok(_) => ()
    Err(error) => abort("solver work invariant: " + @debug.to_string(error))
  }
  if !self.occurs_stack.is_empty() {
    abort(
      "solver work invariant: " +
      @debug.to_string(
        self.solver_failure(206, 0, self.occurs_stack.length(), 41),
      ),
    )
  }
}

///|
fn LocalTypeSolver::check_snapshot_state(
  self : LocalTypeSolver,
  snapshot : InferenceSnapshot,
) -> Result[Unit, SolverInvariantFailure] {
  match self.check_solver_boundary(false, 0) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let depth = self.snapshots.length()
  if depth == 0 {
    return Err(self.solver_failure(204, 1, 0, 0))
  }
  if self.snapshots[depth - 1] != snapshot {
    return Err(self.solver_failure(204, 1, 0, depth))
  }
  for
    entry in [
      (snapshot.variable_count, self.variable_parents.length(), 10),
      (snapshot.type_count, self.types.length(), 11),
      (snapshot.argument_count, self.type_arguments.length(), 12),
      (snapshot.diagnostic_count, self.diagnostics.length(), 13),
    ] {
    let (expected, actual, detail) = entry
    if expected < 0 || expected > actual {
      return Err(self.solver_failure(204, expected, actual, detail))
    }
  }
  self.check_undo_restore(snapshot.undo_start)
}

///|
fn LocalTypeSolver::assert_snapshot_state(
  self : LocalTypeSolver,
  snapshot : InferenceSnapshot,
) -> Unit {
  match self.check_snapshot_state(snapshot) {
    Ok(_) => ()
    Err(error) =>
      abort(
        "solver snapshot invariant: " +
        @debug.to_string(error) +
        "; supplied snapshot: " +
        @debug.to_string(snapshot),
      )
  }
}
