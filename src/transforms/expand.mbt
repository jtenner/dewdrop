///|
fn record(key : String, entries : Array[(String, Value)]) -> Value {
  Record(key, Map::from_array(entries))
}

///|
fn quote(value : String) -> String {
  let out = StringBuilder::new()
  out.write_string("\"")
  for c in value.iter() {
    match c {
      '\n' => out.write_string("\\n")
      '\r' => out.write_string("\\r")
      '\t' => out.write_string("\\t")
      '\\' => out.write_string("\\\\")
      '"' => out.write_string("\\\"")
      _ => out.write_char(c)
    }
  }
  out.write_string("\"")
  out.to_string()
}

///|
fn identifier(name : String) -> Bool {
  let tokens = @tokenizer.tokens(bytes(name)).collect()
  guard tokens.length() == 1 else { return false }
  match tokens[0].kind() {
    @tokenizer.Identifier(value) => value == name
    _ => false
  }
}

///|
fn Machine::render(
  self : Machine,
  value : Value,
  depth : Int32,
) -> String raise EvalError {
  self.charge(32)
  guard depth < 128 else {
    raise Failed("generated syntax depth limit exceeded")
  }
  guard value is Variant(key, args) && key.has_prefix("dewdrop.ast::ExprNode::") else {
    raise Failed("transform returned an invalid ExprNode")
  }
  let rendered = match (key, args[:]) {
    ("dewdrop.ast::ExprNode::Source", [Text(source)]) => source
    ("dewdrop.ast::ExprNode::Unit", []) => "()"
    ("dewdrop.ast::ExprNode::Integer", [DefaultValue]) => "0i32"
    ("dewdrop.ast::ExprNode::Integer64", [DefaultValue]) => "0i64"
    ("dewdrop.ast::ExprNode::Unsigned64", [DefaultValue]) => "0u64"
    ("dewdrop.ast::ExprNode::Boolean", [DefaultValue]) => "false"
    ("dewdrop.ast::ExprNode::Integer64", [Number(n, "I64")]) =>
      signed(n, "I64").to_string() + "i64"
    ("dewdrop.ast::ExprNode::Unsigned64", [Number(n, "U64")]) =>
      n.to_string() + "u64"
    ("dewdrop.ast::ExprNode::Path", [Text(path)]) => {
      guard qualified_identifier(path) else {
        raise Failed("invalid generated qualified path")
      }
      path
    }
    ("dewdrop.ast::ExprNode::Field", [owner, Text(name)]) => {
      guard identifier(name) else {
        raise Failed("invalid generated field name")
      }
      "(" + self.render(owner, depth + 1) + ")." + name
    }
    ("dewdrop.ast::ExprNode::Index", [owner, index]) =>
      "(" +
      self.render(owner, depth + 1) +
      ")[" +
      self.render(index, depth + 1) +
      "]"
    ("dewdrop.ast::ExprNode::MethodCall", [owner, Text(name), arguments]) => {
      guard identifier(name) else {
        raise Failed("invalid generated method name")
      }
      "(" +
      self.render(owner, depth + 1) +
      ")." +
      name +
      "(" +
      self
      .sequence_values(arguments)
      .map(fn(v) { self.render(v, depth + 1) })
      .join(", ") +
      ")"
    }
    ("dewdrop.ast::ExprNode::Prefix", [Text(op), value]) => {
      guard ["!", "-", "+"].contains(op) else {
        raise Failed("invalid generated prefix operator")
      }
      op + "(" + self.render(value, depth + 1) + ")"
    }
    ("dewdrop.ast::ExprNode::Array", [array]) =>
      "[" +
      self
      .sequence_values(array)
      .map(fn(v) { self.render(v, depth + 1) })
      .join(", ") +
      "]"
    ("dewdrop.ast::ExprNode::Tuple", [array]) => {
      let values = self.sequence_values(array)
      guard values.length() != 1 else {
        raise Failed("Dew has no one-element tuple syntax")
      }
      "(" + values.map(fn(v) { self.render(v, depth + 1) }).join(", ") + ")"
    }
    ("dewdrop.ast::ExprNode::MutableBind", [Text(name), value]) => {
      guard identifier(name) else {
        raise Failed("invalid generated binding name")
      }
      "let mut " + name + " = " + self.render(value, depth + 1)
    }
    ("dewdrop.ast::ExprNode::Assign", [target, value]) =>
      self.render(target, depth + 1) + " = " + self.render(value, depth + 1)
    ("dewdrop.ast::ExprNode::Integer", [Number(n, "I32")]) =>
      signed(n, "I32").to_string() + "i32"
    ("dewdrop.ast::ExprNode::Boolean", [Boolean(value)]) =>
      if value {
        "true"
      } else {
        "false"
      }
    ("dewdrop.ast::ExprNode::Text", [Text(value)]) => quote(value)
    ("dewdrop.ast::ExprNode::Name", [Text(name)]) => {
      guard identifier(name) else {
        raise Failed("invalid generated identifier")
      }
      name
    }
    ("dewdrop.ast::ExprNode::Call", [callee, arguments]) => {
      let callee = self.render(callee, depth + 1)
      let arguments = self
        .sequence_values(arguments)
        .map(fn(v) { self.render(v, depth + 1) })
        .join(", ")
      "(" + callee + ")(" + arguments + ")"
    }
    ("dewdrop.ast::ExprNode::Binary", [Text(op), left, right]) => {
      guard [
        "+", "-", "*", "/", "%", "==", "!=", "<", "<=", ">", ">=", "&&", "||", "&",
        "|", "^", "<<", ">>",
      ].contains(op) else {
        raise Failed("invalid generated binary operator")
      }
      "(" +
      self.render(left, depth + 1) +
      ") " +
      op +
      " (" +
      self.render(right, depth + 1) +
      ")"
    }
    ("dewdrop.ast::ExprNode::Block", [array]) =>
      "match () {\n_ => {\n" +
      self
      .sequence_values(array)
      .map(fn(v) { self.render(v, depth + 1) })
      .join("\n") +
      "\n}\n}"
    ("dewdrop.ast::ExprNode::Bind", [Text(name), value]) => {
      guard identifier(name) else {
        raise Failed("invalid generated binding name")
      }
      "let " + name + " = " + self.render(value, depth + 1)
    }
    ("dewdrop.ast::ExprNode::Return", [value]) =>
      "return " + self.render(value, depth + 1)
    ("dewdrop.ast::ExprNode::If", [condition, yes, no]) =>
      "if " +
      self.render(condition, depth + 1) +
      " {\n" +
      self.render(yes, depth + 1) +
      "\n} else {\n" +
      self.render(no, depth + 1) +
      "\n}"
    _ => raise Failed("invalid generated syntax node payload")
  }
  let rendered_bytes = bytes(rendered).length()
  self.charge(rendered_bytes)
  guard rendered_bytes <= 1_048_576 else {
    raise Failed("generated source size limit exceeded")
  }
  rendered
}

///|
fn Machine::annotation_key(
  self : Machine,
  mi : Int32,
  name : String,
) -> String raise EvalError {
  if name.has_prefix("@") {
    let pieces = name.split(".").collect()
    guard pieces.length() == 2 else {
      raise Failed("expected #@alias.transform_name")
    }
    self.resolve(
      mi,
      pieces[1].to_string(),
      Some(pieces[0].to_string().substring(start=1)),
    )
  } else {
    self.resolve(mi, name, None)
  }
}

///|
fn Machine::apply(
  self : Machine,
  function : SourceFunction,
  file : ParsedFile,
) -> String raise EvalError {
  let fn_ = function.declaration
  let generated_imports : Array[String] = []
  let generated_declarations : Array[String] = []
  let mut generated_bytes = 0
  let mut node = record("dewdrop.ast::FnNode", [
    ("name", Text(fn_.name)),
    (
      "body",
      Variant("dewdrop.ast::ExprNode::Source", [
        Text(
          "match () {\n_ => " +
          part(file.clean, fn_.body.offset.to_int(), function.end) +
          "\n}",
        ),
      ]),
    ),
  ])
  for annotation in file.annotations {
    if annotation.target < function.start ||
      annotation.target >= fn_.name_offset.to_int() {
      continue
    }
    self.steps = 100_000
    self.allocated = 0
    let key = self.annotation_key(function.module_, annotation.name)
    let mut is_transform = false
    for files in self.plan.files {
      for source in files {
        for candidate in source.functions {
          self.charge(16)
          if self.plan.modules[candidate.module_].path +
            "::" +
            candidate.declaration.name ==
            key &&
            candidate.transform {
            is_transform = true
          }
        }
      }
    }
    guard is_transform else {
      raise Failed("annotation must name a transform fn: " + key)
    }
    let mut line = 1UL
    let mut column = 1UL
    for i = 0; i < annotation.offset; i = i + 1 {
      if file.file.source[i] == b'\n' {
        line += 1UL
        column = 1UL
      } else {
        column += 1UL
      }
    }
    let mut fresh = "__dew_transform_" + annotation.offset.to_string()
    while self.plan.files[function.module_].any(fn(source) {
            text(source.file.source).contains(fresh)
          }) {
      self.charge(16)
      fresh += "_"
    }
    let parameters = parameter_source(file.clean, fn_)
    let return_type = part(
      file.clean,
      fn_.return_type.offset().to_int(),
      fn_.body.offset.to_int(),
    )
    let context = record("dewdrop.transform::TransformContext", [
      (
        "location",
        record("dewdrop.transform::SourceLocation", [
          ("file_name", Text(file.file.path)),
          ("line_no", Number(line, "U32")),
          ("col_no", Number(column, "U32")),
        ]),
      ),
      ("fn_name", Text(fn_.name)),
      ("module_name", Text(self.plan.modules[function.module_].path)),
      ("parameters", self.parameter_nodes(fn_.parameters)),
      ("type_parameters", self.type_parameter_nodes(fn_.type_parameters)),
      ("return_type", self.type_node(fn_.return_type)),
      ("parameters_source", Text(parameters)),
      ("return_type_source", Text(return_type)),
      ("fresh_name", Text(fresh)),
      ("declarations", self.syntax_values([])),
      ("imports", self.syntax_values([])),
    ])
    let value = self.call(key, [node, context])
    node = match value {
      Variant("dew.std.result::Result::Ok", [value]) => value
      Variant("dew.std.result::Result::Err", [value]) =>
        raise Failed(string(field(value, "message")))
      _ => value
    }
    guard node is Record(type_, _) &&
      (type_ == "dewdrop.ast::FnNode" || type_ == "") else {
      raise Failed(
        "transform must return FnNode or Result<FnNode, TransformError>",
      )
    }
    guard string(field(node, "name")) == fn_.name else {
      raise Failed("body transforms must preserve the function name")
    }
    for item in self.sequence_values(field(context, "imports")) {
      let rendered = self.render_import(item)
      generated_bytes += bytes(rendered).length()
      guard generated_bytes <= 1_048_576 else {
        raise Failed("generated source size limit exceeded")
      }
      generated_imports.push(rendered)
    }
    for item in self.sequence_values(field(context, "declarations")) {
      let rendered = self.render_declaration(item)
      generated_bytes += bytes(rendered).length() + 1
      guard generated_bytes <= 1_048_576 else {
        raise Failed("generated source size limit exceeded")
      }
      generated_declarations.push(rendered)
    }
  }
  let body = self.render(field(node, "body"), 0)
  let source = part(file.clean, function.start, fn_.body.offset.to_int()) +
    "{\n" +
    body +
    "\n}"
  guard bytes(source).length() <= 1_048_576 else {
    raise Failed("generated source size limit exceeded")
  }
  // Validate the entire replacement; a source fragment cannot insert a sibling declaration.
  let mut nesting = 0
  for token in @tokenizer.tokens(bytes(source)) {
    match token.kind() {
      @tokenizer.Symbol(@tokenizer.LeftBrace)
      | @tokenizer.Symbol(@tokenizer.LeftParen)
      | @tokenizer.Symbol(@tokenizer.LeftBracket) => nesting += 1
      @tokenizer.Symbol(@tokenizer.RightBrace)
      | @tokenizer.Symbol(@tokenizer.RightParen)
      | @tokenizer.Symbol(@tokenizer.RightBracket) => nesting -= 1
      _ => ()
    }
    guard nesting >= 0 && nesting <= 128 else {
      raise Failed("generated syntax nesting limit exceeded")
    }
  }
  let events = @parser.parse_bytes(bytes(source)).collect()
  guard events.length() == 1 &&
    events[0] is @parser.Declaration(@parser.Function(_)) else {
    raise Failed("transform must produce one valid function body:\n" + source)
  }
  if generated_imports.is_empty() && generated_declarations.is_empty() {
    return source
  }
  let output = generated_imports.join("") +
    source +
    "\n" +
    generated_declarations.join("\n")
  guard bytes(output).length() <= 1_048_576 else {
    raise Failed("generated source size limit exceeded")
  }
  output
}

///|
pub fn Plan::expand(
  self : Plan,
  output_module_count~ : Int32 = -1,
) -> Result[Array[SourceModule], String] {
  if !self.active {
    return Ok(self.modules)
  }
  let machine : Machine = {
    plan: self,
    steps: 100_000,
    depth: 0,
    allocated: 0,
    file_index: 0,
  }
  let modules : Array[SourceModule] = []
  for mi, module_ in self.modules {
    if output_module_count >= 0 && mi >= output_module_count {
      break
    }
    let files : Array[SourceFile] = []
    let generated : Array[SourceFile] = []
    for file in self.files[mi] {
      let out = @buffer.new()
      let mut cursor = 0
      for function in file.functions {
        if function.transform {
          out.write_bytes(file.clean[cursor:function.start])
          let removed = file.clean[function.start:function.end]
            .to_owned()
            .to_fixedarray()
          blank(removed, 0, removed.length())
          out.write_bytes(Bytes::from_fixedarray(removed))
          cursor = function.end
        } else if file.annotations.any(fn(a) {
            a.target >= function.start &&
            a.target < function.declaration.name_offset.to_int()
          }) {
          out.write_bytes(file.clean[cursor:function.start])
          let source = machine.apply(function, file) catch {
            Failed(message) =>
              return Err(
                file.file.path +
                ": error: transform on " +
                function.declaration.name +
                ": " +
                message,
              )
            _ =>
              return Err(
                file.file.path + ": error: invalid control flow in transform",
              )
          }
          let removed = file.clean[function.start:function.end]
            .to_owned()
            .to_fixedarray()
          blank(removed, 0, removed.length())
          out.write_bytes(Bytes::from_fixedarray(removed))
          let path = file.file.path +
            "::transform[" +
            function.declaration.name +
            "@" +
            function.start.to_string() +
            "]"
          if module_.files.any(fn(original) { original.path == path }) {
            return Err("generated transform file path collision")
          }
          generated.push({ path, source: bytes(source), })
          cursor = function.end
        }
      }
      out.write_bytes(file.clean[cursor:])
      files.push({ path: file.file.path, source: out.to_bytes(), })
    }
    for file in generated {
      files.push(file)
    }
    modules.push({ path: module_.path, files, })
  }
  Ok(modules)
}

///|
fn parameter_source(
  source : Bytes,
  fn_ : @parser.FunctionDeclaration,
) -> String {
  let start = fn_.name_offset.to_int() + bytes(fn_.name).length()
  let end = fn_.return_type.offset().to_int()
  let mut angles = 0
  let mut parentheses = 0
  let mut begin = -1
  for token in @tokenizer.tokens(source[start:end].to_owned()) {
    match token.kind() {
      @tokenizer.Symbol(@tokenizer.Less) if begin < 0 => angles += 1
      @tokenizer.Symbol(@tokenizer.Greater) if begin < 0 => angles -= 1
      @tokenizer.Symbol(@tokenizer.ShiftRight) if begin < 0 => angles -= 2
      @tokenizer.Symbol(@tokenizer.LeftParen) if angles == 0 => {
        if begin < 0 {
          begin = start + token.offset().to_int()
        }
        parentheses += 1
      }
      @tokenizer.Symbol(@tokenizer.RightParen) if begin >= 0 => {
        parentheses -= 1
        if parentheses == 0 {
          return part(source, begin, start + token.offset().to_int() + 1)
        }
      }
      _ => ()
    }
  }
  ""
}

///|
fn qualified_identifier(name : String) -> Bool {
  let tokens = @tokenizer.tokens(bytes(name)).collect()
  if tokens.is_empty() {
    return false
  }
  let mut i = 0
  if tokens[0].kind() is @tokenizer.AtIdentifier(_) {
    if tokens.length() < 3 ||
      tokens[1].kind() != @tokenizer.Symbol(@tokenizer.Dot) ||
      !(tokens[2].kind() is @tokenizer.Identifier(_)) {
      return false
    }
    i = 3
  } else if tokens[0].kind() is @tokenizer.Identifier(_) {
    i = 1
  } else {
    return false
  }
  while i < tokens.length() {
    if i + 1 >= tokens.length() ||
      tokens[i].kind() != @tokenizer.Symbol(@tokenizer.DoubleColon) ||
      !(tokens[i + 1].kind() is @tokenizer.Identifier(_)) {
      return false
    }
    i += 2
  }
  true
}
