///|
fn PlannedBodyChildChecker::capture_source_local(
  self : PlannedBodyChildChecker,
  parent : Int,
  index : Int,
  source : LambdaCaptureSource,
) -> Unit {
  let (span, local, lambda) = match source {
    BodyLocalCapture(owner, local) => {
      if owner != self.body.body {
        self.fail(
          106,
          parent,
          self.body.body,
          owner,
          (22UL << 32) | index.to_uint64(),
        )
        return
      }
      let body_index = semantic_id_local(owner)
      if !self.owned(
          parent,
          { start: 0, length: self.lowering.bodies.length(), },
          body_index,
          22,
        ) {
        return
      }
      let body = self.lowering.bodies[body_index]
      if body.body != owner {
        self.fail(
          106,
          parent,
          owner,
          body.body,
          (22UL << 32) | body_index.to_uint64(),
        )
        return
      }
      (body.locals, local, -1)
    }
    LambdaLocalCapture(owner, local) => {
      // Validate only the source lambda identity here, not its captures.
      // A bad self-reference must not turn validation into recursion.
      if !self.lambda(parent, owner) {
        return
      }
      (self.lowering.lambdas[owner].locals, local, owner)
    }
  }
  if !self.span(parent, span, self.lowering.locals.length(), 2) ||
    !self.owned(parent, { start: 0, length: span.length, }, local, 2) {
    return
  }
  self.local_identity(parent, span.start + local, local, lambda)
}

///|
fn PlannedBodyChildChecker::capture_source_available(
  self : PlannedBodyChildChecker,
  parent : Int,
  index : Int,
  source : LambdaCaptureSource,
) -> Unit {
  if self.failure is Some(_) {
    return
  }
  let direct = match source {
    BodyLocalCapture(owner, _) =>
      self.owner_lambda == -1 && owner == self.body.body
    LambdaLocalCapture(owner, _) => owner == self.owner_lambda
  }
  if direct {
    return
  }
  if self.owner_lambda != -1 {
    // Entry validation already checked the enclosing capture table.
    let enclosing = self.lowering.lambdas[self.owner_lambda].captures
    for offset in 0..<enclosing.length {
      if self.lowering.captures[enclosing.start + offset].source == source {
        return
      }
    }
  }
  self.fail(104, parent, 1UL, 0UL, (23UL << 32) | index.to_uint64())
}
