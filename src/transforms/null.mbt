///|
fn reference_is_null(value : Value) -> Bool raise EvalError {
  match value {
    NullValue | DefaultValue => true
    RawArray(_)
    | Record(_, _)
    | Variant(_, _)
    | Text(_)
    | ByteText(_)
    | TextReference(_)
    | ReferenceView(_, _)
    | TraitObject(_)
    | TextChunks(_, _)
    | Sequence(_)
    | Function(_, _, _)
    | Closure(_, _, _, _, _, _) => false
    _ => raise Failed("Wasm null test requires a reference")
  }
}

///|
fn reference_null_test(value : Value) -> Bool raise EvalError {
  guard !(value is Sequence(_)) else {
    raise Failed(
      "Wasm null test tuple operand needs a checked reference carrier",
    )
  }
  reference_is_null(value)
}
