///|
fn Machine::render_declaration(
  self : Machine,
  value : Value,
) -> String raise EvalError {
  self.charge(64)
  guard value is Variant(key, [Text(source)]) else {
    raise Failed("invalid generated declaration node")
  }
  self.charge(bytes(source).length())
  guard bytes(source).length() <= 1_048_576 else {
    raise Failed("generated source size limit exceeded")
  }
  let mut depth = 0
  for token in @tokenizer.tokens(bytes(source)) {
    match token.kind() {
      @tokenizer.Symbol(@tokenizer.LeftBrace)
      | @tokenizer.Symbol(@tokenizer.LeftParen)
      | @tokenizer.Symbol(@tokenizer.LeftBracket) => depth += 1
      @tokenizer.Symbol(@tokenizer.RightBrace)
      | @tokenizer.Symbol(@tokenizer.RightParen)
      | @tokenizer.Symbol(@tokenizer.RightBracket) => depth -= 1
      _ => ()
    }
    guard depth >= 0 && depth <= 128 else {
      raise Failed("generated syntax nesting limit exceeded")
    }
  }
  let events = @parser.parse_bytes(bytes(source)).collect()
  let valid = events.length() == 1 &&
    (match events[0] {
      @parser.Declaration(@parser.Function(_)) =>
        key == "dewdrop.ast::DeclarationNode::Function"
      @parser.Declaration(@parser.Struct(_))
      | @parser.Declaration(@parser.Enum(_))
      | @parser.Declaration(@parser.TypeAlias(_)) =>
        key == "dewdrop.ast::DeclarationNode::Type"
      @parser.Declaration(@parser.Impl(_)) =>
        key == "dewdrop.ast::DeclarationNode::Implementation"
      _ => false
    })
  guard valid else {
    raise Failed(
      "expected one valid generated declaration of the requested kind",
    )
  }
  source
}

///|
fn Machine::render_import(
  self : Machine,
  value : Value,
) -> String raise EvalError {
  let path = string(field(value, "module_path"))
  let alias = string(field(value, "alias"))
  self.charge(bytes(path).length() + bytes(alias).length())
  guard path != "" &&
    identifier(alias) &&
    path.split(".").all(fn(piece) { identifier(piece.to_string()) }) else {
    raise Failed("invalid generated import path or alias")
  }
  "import " + path + " as @" + alias + "\n"
}
