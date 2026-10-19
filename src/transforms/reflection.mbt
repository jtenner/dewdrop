///|
fn Machine::syntax_values(
  self : Machine,
  values : Array[Value],
) -> Value raise EvalError {
  self.charge(values.length() * 16)
  // Unchecked interpreter fixtures use the same sequence fallback as literals.
  if self.plan.array_layouts.is_empty() {
    return Sequence(values)
  }
  self.call("dewdrop.ast::syntax_array", [
    RawArray({ values, default_kind: "", }),
    Number(values.length().to_uint64(), "U32"),
  ])
}

///|
fn Machine::type_node(
  self : Machine,
  type_ : @parser.TypeExpr,
  depth~ : Int32 = 0,
) -> Value raise EvalError {
  guard depth < 128 else { raise Failed("syntax type depth limit exceeded") }
  self.charge(64)
  let (kind, name, arguments) : (String, String, Array[@parser.TypeExpr]) = match
    type_ {
    @parser.NamedType(name, _) => ("named", name, [])
    @parser.QualifiedType(alias, name, _, _) =>
      ("qualified", "@" + alias + "." + name, [])
    @parser.ProductType(values, _) => ("tuple", "", values)
    @parser.AppliedType(base, values, _) => ("applied", "", [base] + values)
    @parser.FunctionType(values, result, _) =>
      ("function", "", values + [result])
    @parser.ComputedType(base, code, _) => ("computed", text(code), [base])
  }
  record("dewdrop.ast::TypeNode", [
    ("kind", Text(kind)),
    ("name", Text(name)),
    (
      "arguments",
      self.syntax_values(
        arguments.map(fn(value) { self.type_node(value, depth=depth + 1) }),
      ),
    ),
  ])
}

///|
fn Machine::parameter_nodes(
  self : Machine,
  parameters : Array[@parser.FnParameter],
) -> Value raise EvalError {
  self.syntax_values(
    parameters.map(fn(parameter) {
      record("dewdrop.ast::ParameterNode", [
        ("name", Text(parameter.name)),
        ("type_", self.type_node(parameter.type_)),
      ])
    }),
  )
}

///|
fn Machine::type_parameter_nodes(
  self : Machine,
  parameters : Array[@parser.TypeParameter],
) -> Value raise EvalError {
  self.syntax_values(
    parameters.map(fn(parameter) {
      record("dewdrop.ast::TypeParameterNode", [
        ("name", Text(parameter.name)),
        (
          "bounds",
          self.syntax_values(
            parameter.bounds.map(fn(bound) { self.type_node(bound) }),
          ),
        ),
      ])
    }),
  )
}
