///|
fn Machine::render_quote(
  self : Machine,
  parts : Value,
  splices : Value,
  depth : Int32,
) -> String raise EvalError {
  let parts = self.sequence_values(parts).map(fn(value) { self.string(value) })
  let values = self.sequence_values(splices)
  guard parts.length() == values.length() + 1 else {
    raise Failed("quote needs one more text part than splice")
  }
  let mut total = 0
  for part in parts {
    total += bytes(part).length()
    guard total <= 1_048_576 else {
      raise Failed("generated source size limit exceeded")
    }
  }
  let splices : Array[String] = []
  for value in values {
    let rendered = "(" + self.render(value, depth + 1) + ")"
    total += bytes(rendered).length()
    guard total <= 1_048_576 else {
      raise Failed("generated source size limit exceeded")
    }
    splices.push(rendered)
  }
  let pool = parts.join("") + splices.join("")
  self.charge(bytes(pool).length())
  guard bytes(pool).length() <= 1_048_576 else {
    raise Failed("generated source size limit exceeded")
  }
  let names : Map[String, String] = {}
  let source = StringBuilder::new()
  let boundaries : Map[Int32, Int32] = {}
  let mut length = 0
  for i, part in parts {
    source.write_string(part)
    length += bytes(part).length()
    if i < splices.length() {
      boundaries[length] = 0
      source.write_string(splices[i])
      length += bytes(splices[i]).length()
      boundaries[length - 1] = 1
    }
  }
  let body = self.quote_part(source.to_string(), pool, names, boundaries)
  "match () {\n_ => {\n" + body + "\n}\n}"
}

///|
fn Machine::quote_part(
  self : Machine,
  part : String,
  pool : String,
  names : Map[String, String],
  boundaries : Map[Int32, Int32],
) -> String raise EvalError {
  let source = bytes(part)
  let tokens = @tokenizer.tokens(source).collect()
  let out = @buffer.new()
  let mut cursor = 0
  let mut i = 0
  let mut in_splice = false
  while i < tokens.length() {
    let token = tokens[i]
    if boundaries.get(token.offset().to_int()) is Some(expected) {
      guard (
          expected == 0 &&
          token.kind() == @tokenizer.Symbol(@tokenizer.LeftParen)
        ) ||
        (
          expected == 1 &&
          token.kind() == @tokenizer.Symbol(@tokenizer.RightParen)
        ) else {
        raise Failed("quote splices must occupy expression syntax")
      }
      in_splice = expected == 0
      boundaries.remove(token.offset().to_int())
    }
    if token.kind() == @tokenizer.Error(@tokenizer.UnexpectedUnit(36U)) {
      guard !in_splice else {
        raise Failed("quote-local names must be in quote text")
      }
      let offset = token.offset().to_int()
      guard i + 1 < tokens.length() &&
        tokens[i + 1].offset() == token.offset() + 1UL &&
        tokens[i + 1].kind() is @tokenizer.Identifier(label) else {
        raise Failed("expected a quote-local identifier after $")
      }
      let name = match names.get(label) {
        Some(name) => name
        None => {
          let mut candidate = "__dew_quote_" + names.length().to_string()
          while true {
            self.charge(bytes(pool).length() + bytes(candidate).length())
            if !pool.contains(candidate) {
              break
            }
            candidate += "_"
          }
          names[label] = candidate
          candidate
        }
      }
      self.charge(bytes(name).length())
      out.write_bytes(source[cursor:offset])
      out.write_string_utf8(name)
      cursor = offset + 1 + bytes(label).length()
      i += 1
    }
    i += 1
  }
  guard boundaries.is_empty() else {
    raise Failed("quote splices must occupy expression syntax")
  }
  out.write_bytes(source[cursor:])
  text(out.to_bytes())
}
