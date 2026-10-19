///|
struct IntrinsicContract {
  inputs : Array[String]
  result : String
}

///|
pub fn Plan::add_intrinsic_contract(
  self : Plan,
  opcode : Bytes,
  inputs : Array[String],
  result : String,
) -> Unit {
  self.intrinsic_contracts[text(opcode)] = { inputs, result, }
}

///|
fn intrinsic_kind_carrier(kind : String) -> String {
  match kind {
    "Bool" | "I8" | "U8" | "I16" | "U16" | "I32" | "U32" => "i32"
    "I64" | "U64" => "i64"
    "F32" => "f32"
    "F64" => "f64"
    "V128" => "v128"
    "Unit" | "Never" => "unit"
    "nullable" | "String" | "Bytes" | "StringView" | "StringBuilder" | "BytesBuilder" => "ref"
    _ => if kind.has_prefix("record:") || kind.has_prefix("array:") { "ref" } else { "" }
  }
}

///|
fn intrinsic_value_carrier(value : Value) -> String {
  match value {
    Unit => "unit"
    DefaultValue => ""
    Number(_, kind) | Floating(_, kind) => intrinsic_kind_carrier(kind)
    Boolean(_) => "i32"
    Vector(_, _) => "v128"
    _ => "ref"
  }
}

///|
fn intrinsic_kind_storage(kind : String) -> String {
  if kind == "I8" || kind == "U8" { "i8"
  } else if kind == "I16" || kind == "U16" { "i16"
  } else if kind.has_prefix("array:") {
    let element = intrinsic_kind_storage(kind.substring(start=6).to_string())
    if element == "" { "" } else { "array:" + element }
  } else if kind.has_prefix("record:") { kind
  } else if kind == "String" || kind == "Bytes" || kind == "StringView" { "text"
  } else {
    let carrier = intrinsic_kind_carrier(kind)
    if carrier == "ref" { "" } else { carrier }
  }
}

///|
fn check_intrinsic_result_carrier(value : Value, kind : String) -> Unit raise EvalError {
  let actual = intrinsic_value_carrier(value)
  let expected = intrinsic_kind_carrier(kind)
  guard actual == "" || expected == "" || actual == expected else {
    raise Failed("checked value has an incompatible Wasm carrier")
  }
}

///|
fn Machine::check_intrinsic_contract(
  self : Machine,
  opcode : String,
  args : Array[Value],
  result_kind : String,
) -> Unit raise EvalError {
  let result = intrinsic_kind_carrier(result_kind)
  if self.plan.intrinsic_contracts.get(opcode) is Some(contract) {
    guard result != "" || contract.result == "unit" else {
      raise Failed("generic intrinsic result needs a concrete checked carrier: " + opcode)
    }
    guard args.length() == contract.inputs.length() else {
      raise Failed("Wasm intrinsic operand carrier count mismatch: " + opcode)
    }
    for index, argument in args {
      let actual = intrinsic_value_carrier(argument)
      guard actual == "" || actual == contract.inputs[index] else {
        raise Failed("Wasm intrinsic operand carrier mismatch: " + opcode)
      }
    }
    guard result == "" || result == contract.result else {
      raise Failed("Wasm intrinsic result carrier mismatch: " + opcode)
    }
  }
  if opcode == "unsafe.bitcast" && args.length() == 1 {
    let input = intrinsic_value_carrier(args[0])
    guard (input == "" || result == "" || input == result) &&
      input != "ref" && result != "ref" else {
      raise Failed("Wasm unsafe cast requires the same scalar carrier")
    }
  }
  if raw_immediate(opcode, "struct.get ") is Some(index) && args.length() == 1 {
    let storage = self.raw_storage(args[0])
    guard index >= 0 && index < storage.length() else {
      raise Failed("Wasm struct field has no checked layout")
    }
    let field = storage[index]
    let field = if field.has_prefix("mut:") {
      field.substring(start=4).to_string()
    } else { field }
    let scalar = match field { "i32" | "i64" | "f32" | "f64" | "v128" => true; _ => false }
    let reference = field == "text" || field.has_prefix("array:") || field.has_prefix("record:")
    let expected_storage = intrinsic_kind_storage(result_kind)
    guard (scalar || reference) &&
      (result == "" || result == (if reference { "ref" } else { field })) &&
      (!reference || expected_storage == "" || expected_storage == field) else {
      raise Failed("Wasm struct.get result carrier does not match its checked field")
    }
  }
}
