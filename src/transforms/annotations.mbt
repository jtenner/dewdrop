///|
fn scan_annotation_arguments(
  source : Bytes,
  tokens : Array[@tokenizer.Token],
  start : Int32,
) -> Result[(Array[@parser.Expr], String, Int32, Int32), String] {
  if start >= tokens.length() ||
    tokens[start].kind() != @tokenizer.Symbol(@tokenizer.LeftParen) {
    return Ok(([], "", 0, start))
  }
  let begin = tokens[start].offset().to_int() + 1
  let stack = [@tokenizer.RightParen]
  let mut index = start + 1
  while index < tokens.length() {
    let token = tokens[index]
    guard token.offset().to_int() - begin <= 65_536 else {
      return Err("transform annotation argument size limit exceeded")
    }
    match token.kind() {
      @tokenizer.Newline =>
        return Err("a transform annotation must occupy its own line")
      @tokenizer.Symbol(symbol) =>
        match symbol {
          @tokenizer.LeftParen => stack.push(@tokenizer.RightParen)
          @tokenizer.LeftBracket => stack.push(@tokenizer.RightBracket)
          @tokenizer.LeftBrace => stack.push(@tokenizer.RightBrace)
          @tokenizer.RightParen
          | @tokenizer.RightBracket
          | @tokenizer.RightBrace => {
            guard stack.pop() == Some(symbol) else {
              return Err("unbalanced transform annotation arguments")
            }
            if stack.is_empty() {
              let raw = part(source, begin, token.offset().to_int())
              match
                @parser.Parser::from_bytes(bytes("[" + raw + "]")).parse_expression() {
                Ok(@parser.ArrayExpr(values, _)) => {
                  guard values.length() <= 256 else {
                    return Err(
                      "transform annotation argument count limit exceeded",
                    )
                  }
                  return Ok((values, raw, begin, index + 1))
                }
                _ => return Err("invalid transform annotation arguments")
              }
            }
          }
          _ => ()
        }
      _ => ()
    }
    guard stack.length() < 128 else {
      return Err("transform annotation argument depth limit exceeded")
    }
    index += 1
  }
  Err("unfinished transform annotation arguments")
}

///|
fn Machine::annotation_nodes(
  self : Machine,
  annotation : Annotation,
) -> Value raise EvalError {
  let values : Array[Value] = []
  for argument in annotation.arguments {
    let node = self.syntax_expr(argument, 0)
    self.shift_annotation_node(node, annotation.arguments_offset - 1)
    values.push(node)
  }
  self.syntax_values(values)
}

///|
fn Machine::shift_annotation_node(
  self : Machine,
  node : Value,
  delta : Int32,
) -> Unit raise EvalError {
  self.charge(16)
  guard node is Record(_, fields) else {
    raise Failed("invalid annotation syntax node")
  }
  let offset = raw_bits(field(node, "offset")).to_int() + delta
  guard offset >= 0 else { raise Failed("invalid annotation syntax offset") }
  fields["offset"] = Number(offset.to_uint64(), "U32")
  for child in self.sequence_values(field(node, "children")) {
    self.shift_annotation_node(child, delta)
  }
}
