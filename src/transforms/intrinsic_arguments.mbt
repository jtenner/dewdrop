///|
/// Product syntax has the same flattened operand order as the backend.
/// A generic or reference parameter retains its original VM value.
fn append_intrinsic_argument(
  output : Array[Value],
  type_ : @parser.TypeExpr,
  value : Value,
) -> Unit raise EvalError {
  match type_ {
    @parser.ProductType(fields, _) => {
      guard value is Sequence(values) && values.length() == fields.length() else {
        raise Failed("Wasm intrinsic tuple operand does not match its checked shape")
      }
      for index, field in fields {
        append_intrinsic_argument(output, field, values[index])
      }
    }
    _ => output.push(value)
  }
}

///|
fn intrinsic_arguments(
  builtin : @parser.BuiltinDeclaration,
  args : Array[Value],
) -> Array[Value] raise EvalError {
  guard args.length() == builtin.parameters.length() else {
    raise Failed("Wasm intrinsic argument count mismatch")
  }
  if !builtin.parameters.any(parameter => parameter.type_ is @parser.ProductType(_, _)) {
    return args
  }
  let output = []
  for index, parameter in builtin.parameters {
    append_intrinsic_argument(output, parameter.type_, args[index])
  }
  output
}
