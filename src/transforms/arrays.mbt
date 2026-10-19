///|
pub fn Plan::add_array_layout(
  self : Plan,
  mi : Int32,
  path : String,
  offset : UInt64,
  key : String,
  names : Array[String],
) -> Unit {
  if mi < 0 || mi >= self.files.length() || names.length() != 3 {
    return
  }
  for fi, file in self.files[mi] {
    if file.file.path == path && offset < file.clean.length().to_uint64() {
      self.array_literals[(mi, fi, offset.to_int())] = (key, names)
      self.array_layouts[key] = names
    }
  }
}

///|
fn Machine::array_value(
  self : Machine,
  mi : Int32,
  offset : UInt64,
  values : Array[Value],
) -> Value raise EvalError {
  self.charge(values.length() * 16)
  match self.plan.array_literals.get((mi, self.file_index, offset.to_int())) {
    Some((key, names)) =>
      record(key, [
        (names[0], RawArray({ values, default_kind: "", })),
        (names[1], Number(values.length().to_uint64(), "U32")),
        (names[2], Number(values.length().to_uint64(), "U32")),
      ])
    None => Sequence(values)
  }
}

///|
fn Machine::sequence_values(
  self : Machine,
  value : Value,
) -> Array[Value] raise EvalError {
  match value {
    Sequence(values) => values
    Record(key, fields) => {
      guard self.plan.array_layouts.get(key) is Some(names) &&
        fields.get(names[0]) is Some(RawArray(storage)) &&
        fields.get(names[1]) is Some(Number(count, "U32")) &&
        count <= storage.values.length().to_uint64() else {
        raise Failed("invalid interpreted array layout")
      }
      self.charge(count.to_int() * 16)
      Array::makei(count.to_int(), fn(i) { storage.values[i] })
    }
    _ => raise Failed("expected an interpreted array")
  }
}
