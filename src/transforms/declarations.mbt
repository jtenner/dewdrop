///|
fn Machine::render_declaration(
  self : Machine,
  value : Value,
) -> String raise EvalError {
  self.charge(64)
  guard value is Variant(key, [source]) else {
    raise Failed("invalid generated declaration node")
  }
  let source = self.string(source)
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
  let path = self.string(field(value, "module_path"))
  let alias = self.string(field(value, "alias"))
  self.charge(bytes(path).length() + bytes(alias).length())
  guard path != "" &&
    identifier(alias) &&
    path.split(".").all(fn(piece) { identifier(piece.to_string()) }) else {
    raise Failed("invalid generated import path or alias")
  }
  "import " + path + " as @" + alias + "\n"
}

///|
fn Machine::seed_imports(self : Machine, mi : Int32) -> Unit {
  for file in self.plan.files[mi] {
    for declaration in file.declarations {
      if declaration is @parser.Import(import_) &&
        !import_.open_ &&
        !import_.path.is_empty() {
        let alias = import_.import_alias.unwrap_or(
          import_.path[import_.path.length() - 1],
        )
        self.imports[(mi, alias)] = import_.path.join(".")
      }
    }
  }
}

///|
fn Machine::register_import(
  self : Machine,
  mi : Int32,
  value : Value,
) -> String? raise EvalError {
  let rendered = self.render_import(value)
  let path = self.string(field(value, "module_path"))
  let alias = self.string(field(value, "alias"))
  match self.imports.get((mi, alias)) {
    Some(existing) => {
      guard existing == path else {
        raise Failed(
          "generated import alias already names a different module: " + alias,
        )
      }
      None
    }
    None => {
      self.imports[(mi, alias)] = path
      Some(rendered)
    }
  }
}
