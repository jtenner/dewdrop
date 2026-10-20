///|
struct FieldNames {
  values : Array[String]
  index : Map[String, Int32]?
}

///|
fn field_names(values : Array[String]) -> FieldNames {
  let index = if values.length() > 8 {
    let index : Map[String, Int32] = {}
    for position, name in values {
      if !index.contains(name) {
        index[name] = position
      }
    }
    Some(index)
  } else {
    None
  }
  { values, index, }
}

///|
fn FieldNames::position(self : FieldNames, name : String) -> Int32? {
  if self.index is Some(index) {
    return index.get(name)
  }
  for position, value in self.values {
    if value == name {
      return Some(position)
    }
  }
  None
}

///|
struct RawLayout {
  fields : Array[String]
  storage : Array[String]
}

///|
pub fn Plan::add_raw_layout(
  self : Plan,
  key : String,
  identity : String,
  fields : Array[String],
  storage : Array[String],
) -> Unit {
  guard fields.length() == storage.length() else {
    abort("checked raw layout lost a field storage type")
  }
  let layout = { fields, storage, }
  self.raw_layouts[key] = layout
  self.raw_layouts[identity] = layout
}

///|
fn reference_base(value : Value) -> Value {
  match value {
    ReferenceView(base, _) | TextReference(base) => reference_base(base)
    _ => value
  }
}

///|
fn Machine::raw_storage(
  self : Machine,
  value : Value,
) -> Array[String] raise EvalError {
  match reference_base(value) {
    Text(_) | ByteText(_) => ["array:v128", "i32", "i32"]
    Record(key, _) =>
      match self.plan.raw_layouts.get(key) {
        Some(layout) => layout.storage
        None => raise Failed("reference has no checked raw layout")
      }
    _ => raise Failed("expected a checked struct reference at compile time")
  }
}

///|
fn Machine::reference_cast(
  self : Machine,
  value : Value,
  kind : String,
) -> Value raise EvalError {
  if value is NullValue || value is DefaultValue {
    return if kind == "nullable" {
      NullValue
    } else {
      eval_fail("null reference cast trap at compile time")
    }
  }
  let source = self.raw_storage(value)
  let (fields, target) = if kind == "String" ||
    kind == "Bytes" ||
    kind == "StringView" {
    ([], ["array:v128", "i32", "i32"])
  } else if kind == "StringBuilder" || kind == "BytesBuilder" {
    ([], ["mut:array:v128", "mut:i32", "mut:i32"])
  } else {
    match self.plan.raw_layouts.get(kind) {
      Some(layout) => (layout.fields, layout.storage)
      None => return eval_fail("reference cast has no checked target layout")
    }
  }
  guard source.length() == target.length() else {
    return eval_fail("reference cast heap type mismatch at compile time")
  }
  for index, storage in source {
    self.charge(0)
    guard storage == target[index] && !storage.contains("unsupported") else {
      return eval_fail("reference cast heap type mismatch at compile time")
    }
  }
  if fields.is_empty() {
    let base = reference_base(value)
    if kind == "String" && !(base is Text(_)) {
      TextReference(base)
    } else {
      base
    }
  } else {
    ReferenceView(reference_base(value), field_names(fields))
  }
}

///|
fn Machine::raw_struct_get(
  self : Machine,
  value : Value,
  index : Int32,
) -> Value raise EvalError {
  match reference_base(value) {
    ByteText(content) as original =>
      match index {
        0 => TextChunks(original, content)
        1 => Number(0UL, "U32")
        2 => Number(content.length().to_uint64(), "U32")
        _ => eval_fail("Wasm struct field out of bounds at compile time")
      }
    Text(content) as original =>
      match index {
        0 => {
          let cached = self.text_storage.get(content)
          let backing = cached.unwrap_or_else(fn() { bytes(content) })
          self.charge(backing.length() + 16)
          if cached is None {
            self.text_storage[content] = backing
          }
          TextChunks(original, backing)
        }
        1 => Number(0UL, "U32")
        2 => {
          guard self.raw_struct_get(original, 0) is TextChunks(_, backing) else {
            return eval_fail("text reference lost its byte storage")
          }
          Number(backing.length().to_uint64(), "U32")
        }
        _ => eval_fail("Wasm struct field out of bounds at compile time")
      }
    Record(key, values) => {
      guard self.plan.raw_layouts.get(key) is Some(layout) &&
        index >= 0 &&
        index < layout.fields.length() else {
        return eval_fail("Wasm struct field has no checked layout")
      }
      match values.get(layout.fields[index]) {
        Some(value) => value
        None => eval_fail("Wasm struct reference lost a checked field")
      }
    }
    _ => eval_fail("Wasm struct read requires a struct reference")
  }
}

///|
fn Machine::read_field(
  self : Machine,
  value : Value,
  name : String,
) -> Value raise EvalError {
  match value {
    ReferenceView(base, names) => {
      if names.position(name) is Some(index) {
        return self.raw_struct_get(base, index)
      }
      eval_fail("unknown checked raw reference field: " + name)
    }
    _ => field(value, name)
  }
}

///|
fn raw_immediate(opcode : String, prefix : String) -> Int32? {
  if !opcode.has_prefix(prefix) || opcode.length() == prefix.length() {
    return None
  }
  let mut result = 0
  for index in prefix.length()..<opcode.length() {
    let digit = opcode.code_unit_at(index).to_int() - 48
    if digit < 0 || digit > 9 || result > 1000 {
      return None
    }
    result = result * 10 + digit
  }
  Some(result)
}

///|
fn reference_equal(left : Value, right : Value) -> Bool raise EvalError {
  let left = reference_base(left)
  let right = reference_base(right)
  match (left, right) {
    (DefaultValue | NullValue, DefaultValue | NullValue) => true
    (DefaultValue | NullValue, _) | (_, DefaultValue | NullValue) => false
    (RawArray(a), RawArray(b)) => physical_equal(a, b)
    (TextChunks(a, _), TextChunks(b, _)) => physical_equal(a, b)
    (Record(_, a), Record(_, b)) => physical_equal(a, b)
    (TraitObject(a), TraitObject(b)) => physical_equal(a, b)
    (Text(_), Text(_)) | (ByteText(_), ByteText(_)) =>
      physical_equal(left, right)
    (Variant(_, a), Variant(_, b)) | (Sequence(a), Sequence(b)) =>
      physical_equal(a, b)
    (Function(_, _, a), Function(_, _, b)) =>
      physical_equal(left, right) || function_identity_equal(a, b)
    (Closure(_, _, _, _, _, _), Closure(_, _, _, _, _, _)) =>
      physical_equal(left, right)
    (Floating(_, _), _)
    | (_, Floating(_, _))
    | (Number(_, _), _)
    | (_, Number(_, _))
    | (Boolean(_), _)
    | (_, Boolean(_))
    | (Vector(_, _), _)
    | (_, Vector(_, _)) =>
      raise Failed("Wasm reference identity requires references")
    _ => false
  }
}

///|
fn Machine::raw_array_length(
  self : Machine,
  value : Value,
) -> UInt64 raise EvalError {
  match value {
    RawArray(storage) => storage.values.length().to_uint64()
    TextChunks(_, bytes) => ((bytes.length() + 15) / 16).to_uint64()
    _ => raise Failed("Wasm array instruction requires an array")
  }
}

///|
fn Machine::raw_array_get(
  self : Machine,
  value : Value,
  index : UInt64,
) -> Value raise EvalError {
  guard index < self.raw_array_length(value) else {
    return eval_fail("Wasm array index out of bounds at compile time")
  }
  match value {
    RawArray(storage) =>
      self.typed_value(storage.values[index.to_int()], storage.default_kind)
    TextChunks(_, backing) => {
      let mut result = Vector(0UL, 0UL)
      for lane in 0..<16 {
        let at = index.to_int() * 16 + lane
        if at < backing.length() {
          result = vector_replace(
            result,
            lane,
            backing[at].to_uint().to_uint64(),
          )
        }
      }
      result
    }
    _ => eval_fail("Wasm array read requires an array")
  }
}

///|
fn Machine::raw_array_copy(
  self : Machine,
  target : Value,
  target_at : UInt64,
  source : Value,
  source_at : UInt64,
  count : UInt64,
) -> Value raise EvalError {
  guard target is RawArray(storage) else {
    return eval_fail("Wasm array copy requires mutable array storage")
  }
  let target_length = self.raw_array_length(target)
  let source_length = self.raw_array_length(source)
  guard target_at <= target_length &&
    count <= target_length - target_at &&
    source_at <= source_length &&
    count <= source_length - source_at else {
    return eval_fail("Wasm array copy out of bounds at compile time")
  }
  self.charge(count.to_int() * 16)
  let copy = Array::makei(count.to_int(), fn(index) {
    self.charge(0)
    self.raw_array_get(source, source_at + index.to_uint64())
  })
  for index, value in copy {
    storage.values[target_at.to_int() + index] = value
  }
  Unit
}

///|
fn Machine::write_field(
  self : Machine,
  value : Value,
  name : String,
  replacement : Value,
) -> Unit raise EvalError {
  match value {
    ReferenceView(base, names) => {
      guard reference_base(base) is Record(key, values) &&
        self.plan.raw_layouts.get(key) is Some(layout) else {
        raise Failed("field assignment requires mutable struct storage")
      }
      if names.position(name) is Some(index) {
        guard index < layout.fields.length() &&
          layout.storage[index].has_prefix("mut:") else {
          raise Failed("field assignment requires a mutable checked field")
        }
        values[layout.fields[index]] = replacement
        return
      }
      raise Failed("unknown mutable record field")
    }
    _ => {
      let values = fields(value)
      guard values.contains(name) else {
        raise Failed("unknown mutable record field")
      }
      values[name] = replacement
    }
  }
}

///|
fn Machine::string(self : Machine, value : Value) -> String raise EvalError {
  guard value is TextReference(base) else { return string(value) }
  let backing = self.raw_struct_get(base, 0)
  let start = raw_bits(self.raw_struct_get(base, 1))
  let length = raw_bits(self.raw_struct_get(base, 2))
  let capacity = self.raw_array_length(backing) * 16UL
  guard start <= capacity && length <= capacity - start && length <= 4_194_304UL else {
    raise Failed("String reference range is out of bounds")
  }
  self.charge(length.to_int())
  let out = @buffer.new(size_hint=length.to_int())
  let mut chunk = Vector(0UL, 0UL)
  for index in 0..<length.to_int() {
    self.charge(0)
    let absolute = start + index.to_uint64()
    if index == 0 || (absolute & 15UL) == 0UL {
      chunk = self.raw_array_get(backing, absolute >> 4)
    }
    out.write_byte(vector_byte(chunk, (absolute & 15UL).to_int()).to_byte())
  }
  @utf8.decode(out.to_bytes()) catch {
    _ => raise Failed("invalid UTF-8 String at compile time")
  }
}
