///|
fn PlannedBodyChildChecker::local_identity(
  self : PlannedBodyChildChecker,
  parent : Int,
  index : Int,
  relative : Int,
  lambda : LambdaId,
) -> Unit {
  if !self.owned(
      parent,
      { start: 0, length: self.lowering.locals.length(), },
      index,
      2,
    ) {
    return
  }
  let local = self.lowering.locals[index]
  if local.body != self.body.body {
    self.fail(
      106,
      parent,
      self.body.body,
      local.body,
      (6UL << 32) | index.to_uint64(),
    )
  } else if local.local_id != relative {
    self.fail(
      106,
      parent,
      relative.to_uint64(),
      local.local_id.reinterpret_as_uint().to_uint64(),
      (2UL << 32) | index.to_uint64(),
    )
  } else if local.lambda != lambda {
    self.fail(
      106,
      parent,
      lambda.reinterpret_as_uint().to_uint64(),
      local.lambda.reinterpret_as_uint().to_uint64(),
      (7UL << 32) | index.to_uint64(),
    )
  }
}
