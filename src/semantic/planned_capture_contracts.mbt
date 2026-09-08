///|
fn PlannedBodyChildChecker::capture(
  self : PlannedBodyChildChecker,
  parent : Int,
  capture : Int,
) -> Unit {
  ignore(self.owned(parent, self.capture_span, capture, 17))
}

///|
fn PlannedBodyChildChecker::capture_table(
  self : PlannedBodyChildChecker,
  parent : Int,
  lambda : LambdaId,
) -> HirSpan? {
  if !self.lambda(parent, lambda) {
    return None
  }
  let span = self.lowering.lambdas[lambda].captures
  if !self.span(parent, span, self.lowering.captures.length(), 17) {
    return None
  }
  for offset in 0..<span.length {
    let index = span.start + offset
    let capture = self.lowering.captures[index]
    if capture.lambda != lambda {
      self.fail(
        106,
        parent,
        lambda.to_uint64(),
        capture.lambda.reinterpret_as_uint().to_uint64(),
        (18UL << 32) | index.to_uint64(),
      )
      return None
    }
    if capture.capture != offset {
      self.fail(
        106,
        parent,
        offset.to_uint64(),
        capture.capture.reinterpret_as_uint().to_uint64(),
        (17UL << 32) | index.to_uint64(),
      )
      return None
    }
    self.capture_source_local(parent, index, capture.source)
    if self.failure is Some(_) {
      return None
    }
  }
  Some(span)
}

///|
fn PlannedBodyChildChecker::closure_captures(
  self : PlannedBodyChildChecker,
  parent : Int,
  lambda : LambdaId,
  captures : HirSpan,
) -> Unit {
  let expected = match self.capture_table(parent, lambda) {
    Some(span) => span
    None => return
  }
  if !self.span(parent, captures, self.lowering.captures.length(), 17) {
    return
  }
  if captures.start != expected.start {
    self.fail(
      106,
      parent,
      expected.start.to_uint64(),
      captures.start.to_uint64(),
      (19UL << 32) | lambda.to_uint64(),
    )
  } else if captures.length != expected.length {
    self.fail(
      106,
      parent,
      expected.length.to_uint64(),
      captures.length.to_uint64(),
      (20UL << 32) | lambda.to_uint64(),
    )
  }
  if self.failure is Some(_) {
    return
  }
  for offset in 0..<expected.length {
    let index = expected.start + offset
    self.capture_source_available(
      parent,
      index,
      self.lowering.captures[index].source,
    )
  }
}
