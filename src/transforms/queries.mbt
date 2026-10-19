///|
pub(all) enum CheckedConstant {
  CheckedBool(Bool)
  CheckedU32(UInt64)
  CheckedStrings(Array[Bytes])
  CheckedUnit
}

///|
pub fn Plan::add_constant(self : Plan, mi : Int, path : String, offset : UInt64, value : CheckedConstant) -> Unit {
  guard mi >= 0 && mi < self.files.length() else { abort("checked constant lost its source module") }
  for fi, file in self.files[mi] {
    if file.file.path == path && offset < file.clean.length().to_uint64() {
      self.calls[(mi, fi, offset.to_int())] = Constant(value)
      return
    }
  }
}

///|
fn Machine::checked_constant(self : Machine, value : CheckedConstant) -> Value raise EvalError {
  self.charge(16)
  match value {
    CheckedBool(value) => Boolean(value)
    CheckedU32(value) => normalized(value, "U32")
    CheckedUnit => Unit
    CheckedStrings(values) => {
      let result : Array[Value] = []
      for value in values {
        self.charge(value.length() + 16)
        let decoded = @utf8.decode(value) catch { _ => raise Failed("checked type-query name is not UTF-8") }
        result.push(Text(decoded))
      }
      self.syntax_values(result)
    }
  }
}
