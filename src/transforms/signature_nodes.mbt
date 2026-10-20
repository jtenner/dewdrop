///|
fn Machine::signature_node(
  self : Machine,
  fn_ : @parser.FunctionDeclaration,
) -> Value raise EvalError {
  record("dewdrop.ast::SignatureNode", [
    ("parameters", self.parameter_nodes(fn_.parameters)),
    ("return_type", self.type_node(fn_.return_type)),
  ])
}

///|
fn Machine::render_type(
  self : Machine,
  node : Value,
  depth : Int32,
) -> String raise EvalError {
  self.charge(64)
  guard depth < 128 else { raise Failed("generated type depth limit exceeded") }
  guard node is Record("dewdrop.ast::TypeNode", _) else {
    raise Failed("invalid generated TypeNode")
  }
  let kind = self.string(field(node, "kind"))
  let name = self.string(field(node, "name"))
  let arguments = self.sequence_values(field(node, "arguments"))
  let children = arguments.map(fn(value) { self.render_type(value, depth + 1) })
  let result = match kind {
    "named" => {
      guard identifier(name) && children.is_empty() else {
        raise Failed("invalid generated named type")
      }
      name
    }
    "qualified" => {
      guard qualified_identifier(name) && children.is_empty() else {
        raise Failed("invalid generated qualified type")
      }
      name
    }
    "tuple" => {
      guard name == "" && children.length() >= 2 && children.length() <= 32 else {
        raise Failed("invalid generated tuple type")
      }
      "(" + children.join(", ") + ")"
    }
    "applied" => {
      guard name == "" && children.length() > 1 else {
        raise Failed("invalid generated applied type")
      }
      children[0] + "<" + children[1:].to_array().join(", ") + ">"
    }
    "function" => {
      guard name == "" && !children.is_empty() else {
        raise Failed("invalid generated function type")
      }
      "fn(" +
      children[:children.length() - 1].to_array().join(", ") +
      ") -> " +
      children[children.length() - 1]
    }
    "computed" => {
      guard children.length() == 1 else {
        raise Failed("invalid generated computed type")
      }
      children[0] + "(" + quote(name) + ")"
    }
    _ => raise Failed("invalid generated type kind")
  }
  self.charge(bytes(result).length())
  guard bytes(result).length() <= 1048576 else {
    raise Failed("generated source size limit exceeded")
  }
  result
}

///|
fn Machine::render_signature(
  self : Machine,
  node : Value,
) -> String raise EvalError {
  guard node is Record("dewdrop.ast::SignatureNode", _) else {
    raise Failed("invalid generated SignatureNode")
  }
  let names : Map[String, Bool] = {}
  let parameters = []
  for value in self.sequence_values(field(node, "parameters")) {
    self.charge(32)
    guard value is Record("dewdrop.ast::ParameterNode", _) else {
      raise Failed("invalid generated ParameterNode")
    }
    let name = self.string(field(value, "name"))
    guard identifier(name) && !names.contains(name) else {
      raise Failed("invalid or duplicate generated parameter name")
    }
    names[name] = true
    parameters.push(name + ": " + self.render_type(field(value, "type_"), 0))
  }
  let result = "(" +
    parameters.join(", ") +
    ") -> " +
    self.render_type(field(node, "return_type"), 0)
  self.charge(bytes(result).length())
  guard bytes(result).length() <= 1048576 else {
    raise Failed("generated source size limit exceeded")
  }
  result
}

///|
fn signature_parameters_start(
  source : Bytes,
  fn_ : @parser.FunctionDeclaration,
) -> Int32 raise EvalError {
  let start = fn_.name_offset.to_int() + bytes(fn_.name).length()
  let end = fn_.body.offset.to_int()
  let mut angles = 0
  for token in @tokenizer.tokens(source[start:end].to_owned()) {
    match token.kind() {
      @tokenizer.Symbol(@tokenizer.Less) => angles += 1
      @tokenizer.Symbol(@tokenizer.Greater) => angles -= 1
      @tokenizer.Symbol(@tokenizer.ShiftRight) => angles -= 2
      @tokenizer.Symbol(@tokenizer.LeftParen) if angles == 0 =>
        return start + token.offset().to_int()
      _ => ()
    }
  }
  raise Failed("original function has no parameter list")
}
