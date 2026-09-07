///|
/// Validate source IDs before decoding or indexing a type arena.
fn LocalTypeSolver::check_type_term(
  self : LocalTypeSolver,
  type_ : BodyTypeId,
) -> Result[BodyTypeTerm, SolverInvariantFailure] {
  let term = if type_ < -1 {
    BodyResolvedType(-(type_ + 2))
  } else if type_ >= 0 && type_ < self.types.length() {
    self.types[type_]
  } else {
    return Err(self.solver_failure(104, self.types.length(), type_, 0))
  }
  match term {
    BodyResolvedType(resolved) =>
      if resolved < 0 || resolved >= self.resolved.types.length() {
        return Err(
          self.solver_failure(
            104,
            self.resolved.types.length(),
            resolved,
            type_,
          ),
        )
      }
    BodyVariableType(variable) =>
      if variable < 0 || variable >= self.variable_parents.length() {
        return Err(
          self.solver_failure(
            201,
            self.variable_parents.length(),
            variable,
            type_,
          ),
        )
      }
    _ => ()
  }
  Ok(term)
}

///|
/// Nominal declarations are leaves. Structural type edges must form a DAG.
// Check all siblings before a later consumer can use Error or identity recovery.
fn LocalTypeSolver::check_type_graph(
  self : LocalTypeSolver,
  root : BodyTypeId,
) -> Result[Unit, SolverInvariantFailure] {
  let states : Map[BodyTypeId, Int] = {}
  let work = [(root, false)]
  while !work.is_empty() {
    let (source, finish) = work.pop().unwrap()
    let id = match self.check_representative_type(source) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    let term = match self.check_type_term(id) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    if finish {
      states[id] = 2
      continue
    }
    match states.get(id) {
      Some(1) => return Err(self.solver_failure(206, 0, id, root))
      Some(2) => continue
      _ => ()
    }
    states[id] = 1
    work.push((id, true))
    let (span, extra, resolved) = match term {
      BodyProductType(span) => (span, None, false)
      BodyAppliedType(base, span) => (span, Some(base), false)
      BodyFunctionType(span, result) => (span, Some(result), false)
      BodyMemberTypeProjection(owner, _, _) =>
        ({ start: 0, length: 0, }, Some(owner), false)
      BodyResolvedType(type_) =>
        match self.resolved.types[type_] {
          ProductType(span) => (span, None, true)
          AppliedType(base, span) => (span, Some(base), true)
          FunctionType(span, result) => (span, Some(result), true)
          MemberTypeProjection(owner, _, _) =>
            ({ start: 0, length: 0, }, Some(owner), true)
          _ => ({ start: 0, length: 0, }, None, true)
        }
      _ => ({ start: 0, length: 0, }, None, false)
    }
    let arena = if resolved {
      self.resolved.type_arguments
    } else {
      self.type_arguments
    }
    if !program_specialization_span_is_valid(span, arena.length()) {
      return Err(
        self.solver_failure(101, arena.length(), span.start, span.length),
      )
    }
    fn child_id(child : Int) -> Result[Int, SolverInvariantFailure] {
      if resolved {
        self.check_resolved_type_encoding(child)
      } else {
        Ok(child)
      }
    }
    if extra is Some(child) {
      match child_id(child) {
        Ok(value) => work.push((value, false))
        Err(error) => return Err(error)
      }
    }
    let mut offset = span.length
    while offset > 0 {
      offset -= 1
      match child_id(arena[span.start + offset]) {
        Ok(value) => work.push((value, false))
        Err(error) => return Err(error)
      }
    }
  }
  Ok(())
}

///|
fn LocalTypeSolver::assert_type_graph(
  self : LocalTypeSolver,
  root : BodyTypeId,
) -> Unit {
  match self.check_type_graph(root) {
    Ok(_) => ()
    Err(error) =>
      abort("solver type graph invariant: " + @debug.to_string(error))
  }
}
