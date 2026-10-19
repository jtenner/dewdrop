///|
// Unit-only products have no Wasm leaves. Rebuild their source shape rather
// than treating the raw storage's null sentinel as a tuple reference.
fn unit_product_default(shape : String) -> Value raise EvalError {
  guard shape.length() <= 65536 else {
    raise Failed("transform default product shape limit exceeded")
  }
  let stack : Array[Array[Value]] = []
  let mut result : Value? = None
  for index in 0..<shape.length() {
    match shape[index] {
      '(' => {
        guard stack.length() < 128 && result is None else {
          raise Failed("invalid checked default product shape")
        }
        stack.push([])
      }
      'u' => {
        guard stack.length() > 0 else {
          raise Failed("invalid checked default product shape")
        }
        stack[stack.length() - 1].push(Unit)
      }
      ')' => {
        guard stack.pop() is Some(values) else {
          raise Failed("invalid checked default product shape")
        }
        let value = Sequence(values)
        if stack.length() == 0 {
          result = Some(value)
        } else {
          stack[stack.length() - 1].push(value)
        }
      }
      _ => raise Failed("invalid checked default product shape")
    }
  }
  guard stack.is_empty() && result is Some(value) else {
    raise Failed("invalid checked default product shape")
  }
  value
}

///|
fn Machine::typed_value(self : Machine, value : Value, kind : String) -> Value raise EvalError {
  if value is DefaultValue && kind.has_prefix("unit-product:") {
    let size = kind.length() - 13
    guard size <= 65536 else {
      raise Failed("transform default product shape limit exceeded")
    }
    self.charge(size * 16)
  }
  intrinsic_kind(value, kind)
}
