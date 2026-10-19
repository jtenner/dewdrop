///|
/// Validation keeps original files and offsets. Target stubs live in separate
/// check files, whose source locations must never authorize an original body.
pub fn Plan::add_scalar_proof(
  self : Plan,
  module_index : Int32,
  file_path : String,
  validation_offset : UInt64,
  opcode : Bytes,
) -> Unit {
  if module_index < 0 || module_index >= self.files.length() {
    return
  }
  for fi, file in self.files[module_index] {
    if file.file.path != file_path {
      continue
    }
    let offset = validation_offset.to_int()
    // Appended validation-only declarations must not authorize source code.
    if offset >= 0 && offset < file.clean.length() {
      self.scalar_proofs[(module_index, fi, offset)] = opcode
    }
    return
  }
}

///|
fn scalar_opcode(op : @parser.BinaryOperator, value : Value) -> Bytes {
  let (wide, signed_) = match value {
    Boolean(_) => (false, false)
    Number(_, kind) => (kind == "I64" || kind == "U64", kind.has_prefix("I"))
    _ => return b""
  }
  let prefix = if wide { "i64." } else { "i32." }
  let suffix = if signed_ { "_s" } else { "_u" }
  let name = match op {
    @parser.Add => "add"
    @parser.Subtract => "sub"
    @parser.Multiply => "mul"
    @parser.BitAnd => "and"
    @parser.BitOr => "or"
    @parser.BitXor => "xor"
    @parser.Equal => "eq"
    @parser.NotEqual => "ne"
    @parser.Less => "lt" + suffix
    @parser.LessEqual => "le" + suffix
    @parser.Greater => "gt" + suffix
    @parser.GreaterEqual => "ge" + suffix
    @parser.Divide => "div" + suffix
    @parser.Remainder => "rem" + suffix
    _ => return b""
  }
  bytes(prefix + name)
}

///|
fn Machine::scalar_binary(
  self : Machine,
  mi : Int32,
  offset : UInt64,
  op : @parser.BinaryOperator,
  left : Value,
  right : Value,
) -> Value raise EvalError {
  let proof = self.plan.scalar_proofs.get(
    (mi, self.file_index, offset.to_int()),
  )
  guard proof is Some(opcode) &&
    (opcode == b"primitive" || opcode == scalar_opcode(op, left)) else {
    return eval_fail(
      "selected operator has no supported compile-time primitive proof",
    )
  }
  binary(op, left, right)
}
