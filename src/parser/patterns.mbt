///|
pub struct PatternField {
  name : String
  pattern : Pattern
  offset : UInt64
} derive(Eq, Debug, ToJson, FromJson)

///|
pub enum Pattern {
  WildcardPattern(UInt64)
  BindingPattern(String, UInt64)
  ImportAliasPattern(String, UInt64)
  RestPattern(UInt64)
  LiteralPattern(Expr, UInt64)
  QualifiedPattern(Pattern, String, UInt64)
  TuplePattern(Pattern, Array[Pattern], UInt64)
  ProductPattern(Array[Pattern], UInt64)
  StructPattern(Pattern, Array[PatternField], UInt64?, UInt64)
  AlternativePattern(Pattern, Array[Pattern], UInt64)
} derive(Eq, Debug, ToJson, FromJson)

///|
pub fn Pattern::offset(self : Pattern) -> UInt64 {
  match self {
    WildcardPattern(offset)
    | BindingPattern(_, offset)
    | ImportAliasPattern(_, offset)
    | RestPattern(offset)
    | LiteralPattern(_, offset)
    | QualifiedPattern(_, _, offset)
    | TuplePattern(_, _, offset)
    | ProductPattern(_, offset)
    | StructPattern(_, _, _, offset)
    | AlternativePattern(_, _, offset) => offset
  }
}

///|
fn binding_pattern(name : String, offset : UInt64) -> Pattern {
  if name.has_prefix("_") {
    WildcardPattern(offset)
  } else {
    BindingPattern(name, offset)
  }
}

///|
pub enum PatternError {
  ExpectedPattern(@tokenizer.Token?)
  ExpectedPatternProperty(@tokenizer.Token?)
  ExpectedPatternDelimiter(@tokenizer.Token?, UInt64)
  ExpectedPatternBodyNewline(@tokenizer.Token?, UInt64)
  ExpectedPatternField(@tokenizer.Token?, UInt64)
  ExpectedPatternFieldNewline(@tokenizer.Token?, UInt64)
  RestPatternNotAllowed(UInt64)
  DuplicateRestPattern(UInt64)
  UnclosedTuplePattern(UInt64)
  UnclosedStructPattern(UInt64)
  EmptyTuplePattern(UInt64)
  InvalidProductPatternArity(Int, UInt64)
  PatternLexicalError(@tokenizer.LexError, UInt64)
} derive(Eq, Debug, ToJson, FromJson)

///|
fn optional_pattern_token_offset(
  token : @tokenizer.Token?,
  fallback : UInt64,
) -> UInt64 {
  match token {
    Some(value) => value.offset()
    None => fallback
  }
}

///|
pub fn PatternError::offset(self : PatternError) -> UInt64 {
  match self {
    ExpectedPattern(token) | ExpectedPatternProperty(token) =>
      optional_pattern_token_offset(token, 0UL)
    ExpectedPatternDelimiter(token, fallback)
    | ExpectedPatternBodyNewline(token, fallback)
    | ExpectedPatternField(token, fallback)
    | ExpectedPatternFieldNewline(token, fallback) =>
      optional_pattern_token_offset(token, fallback)
    RestPatternNotAllowed(offset)
    | DuplicateRestPattern(offset)
    | UnclosedTuplePattern(offset)
    | UnclosedStructPattern(offset)
    | EmptyTuplePattern(offset)
    | InvalidProductPatternArity(_, offset)
    | PatternLexicalError(_, offset) => offset
  }
}

///|
fn Parser::consume_pattern_right_paren(self : Parser) -> Bool {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightParen) => {
          self.consume_lookahead()
          true
        }
        _ => false
      }
    None => false
  }
}

///|
fn Parser::parse_tuple_pattern_arguments(
  self : Parser,
  open_offset : UInt64,
  allow_empty? : Bool = false,
) -> Result[(Array[Pattern], Bool), RecoveryFailure] {
  let arguments : Array[Pattern] = []
  let mut has_rest = false
  let mut has_comma = false
  self.skip_newlines()
  if self.consume_pattern_right_paren() {
    if allow_empty {
      return Ok((arguments, false))
    }
    return Err(pattern_failure(EmptyTuplePattern(open_offset)))
  }
  while true {
    let pattern = match self.parse_pattern_context(true) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    match pattern {
      RestPattern(offset) => {
        if has_rest {
          return Err(pattern_failure(DuplicateRestPattern(offset)))
        }
        has_rest = true
      }
      _ => ()
    }
    arguments.push(pattern)
    self.skip_newlines()
    match self.peek_token() {
      None => return Err(pattern_failure(UnclosedTuplePattern(open_offset)))
      Some(token) =>
        match token.kind() {
          @tokenizer.Symbol(@tokenizer.RightParen) => {
            self.consume_lookahead()
            return Ok((arguments, has_comma))
          }
          @tokenizer.Symbol(@tokenizer.Comma) => {
            has_comma = true
            self.consume_lookahead()
            self.skip_newlines()
            if self.consume_pattern_right_paren() {
              return Ok((arguments, has_comma))
            }
          }
          @tokenizer.Symbol(@tokenizer.RightBrace) =>
            return Err(pattern_failure(UnclosedTuplePattern(open_offset)))
          @tokenizer.Error(error) => {
            let offset = token.offset()
            self.consume_lookahead()
            return Err(pattern_failure(PatternLexicalError(error, offset)))
          }
          _ =>
            return Err(
              pattern_failure(
                ExpectedPatternDelimiter(Some(token), open_offset),
              ),
            )
        }
    }
  } nobreak {
    abort("unreachable tuple pattern parser termination")
  }
}

///|
fn Parser::finish_pattern_field_line(
  self : Parser,
  open_offset : UInt64,
) -> Result[Unit, RecoveryFailure] {
  match self.peek_token() {
    None => Err(pattern_failure(UnclosedStructPattern(open_offset)))
    Some(token) =>
      match token.kind() {
        @tokenizer.Newline => {
          self.consume_lookahead()
          Ok(())
        }
        @tokenizer.Error(error) => {
          let offset = token.offset()
          self.consume_lookahead()
          Err(pattern_failure(PatternLexicalError(error, offset)))
        }
        _ =>
          Err(
            pattern_failure(
              ExpectedPatternFieldNewline(Some(token), open_offset),
            ),
          )
      }
  }
}

///|
fn Parser::parse_struct_pattern(
  self : Parser,
  target : Pattern,
  open_offset : UInt64,
) -> Result[Pattern, RecoveryFailure] {
  let fields : Array[PatternField] = []
  let mut rest_offset : UInt64? = None
  if self.consume_right_brace() {
    return Ok(StructPattern(target, fields, rest_offset, open_offset))
  }
  guard self.consume_newline_token() else {
    return Err(
      pattern_failure(
        ExpectedPatternBodyNewline(self.peek_token(), open_offset),
      ),
    )
  }
  self.skip_newlines()
  while true {
    if self.consume_right_brace() {
      return Ok(StructPattern(target, fields, rest_offset, open_offset))
    }
    match self.peek_token() {
      Some(token) =>
        match token.kind() {
          @tokenizer.Symbol(@tokenizer.Ellipsis) => {
            let offset = token.offset()
            self.consume_lookahead()
            if rest_offset is Some(_) {
              return Err(pattern_failure(DuplicateRestPattern(offset)))
            }
            rest_offset = Some(offset)
            match self.finish_pattern_field_line(open_offset) {
              Ok(_) => ()
              Err(error) => return Err(error)
            }
            self.skip_newlines()
            continue
          }
          _ => ()
        }
      None => return Err(pattern_failure(UnclosedStructPattern(open_offset)))
    }
    let (name, field_offset) = match self.peek_token() {
      None => return Err(pattern_failure(UnclosedStructPattern(open_offset)))
      Some(token) =>
        match token.kind() {
          @tokenizer.Identifier(name) => {
            let offset = token.offset()
            self.consume_lookahead()
            (name, offset)
          }
          @tokenizer.Error(error) => {
            let offset = token.offset()
            self.consume_lookahead()
            return Err(pattern_failure(PatternLexicalError(error, offset)))
          }
          _ =>
            return Err(
              pattern_failure(ExpectedPatternField(Some(token), open_offset)),
            )
        }
    }
    let pattern = match self.peek_token() {
      Some(token) =>
        match token.kind() {
          @tokenizer.Symbol(@tokenizer.Colon) => {
            self.consume_lookahead()
            match self.parse_pattern_context(false) {
              Ok(value) => value
              Err(error) => return Err(error)
            }
          }
          _ => binding_pattern(name, field_offset)
        }
      None => return Err(pattern_failure(UnclosedStructPattern(open_offset)))
    }
    match self.finish_pattern_field_line(open_offset) {
      Ok(_) => ()
      Err(error) => return Err(error)
    }
    fields.push({ name, pattern, offset: field_offset, })
    self.skip_newlines()
  } nobreak {
    abort("unreachable struct pattern parser termination")
  }
}

///|
fn Parser::parse_pattern_base(
  self : Parser,
  allow_rest : Bool,
) -> Result[Pattern, RecoveryFailure] {
  match self.peek_token() {
    None => Err(pattern_failure(ExpectedPattern(None)))
    Some(token) => {
      let offset = token.offset()
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftBrace) => {
          self.consume_lookahead()
          // A wildcard target asks inference to use the subject's struct type.
          // Reuse the existing struct-pattern artifact and field/rest rules.
          self.parse_struct_pattern(WildcardPattern(offset), offset)
        }
        @tokenizer.Symbol(@tokenizer.LeftParen) => {
          self.consume_lookahead()
          let (arguments, has_comma) = match
            self.parse_tuple_pattern_arguments(offset, allow_empty=true) {
            Ok(value) => value
            Err(error) => return Err(error.inside_parenthesis())
          }
          if arguments.length() == 1 && !has_comma {
            if !allow_rest && arguments[0] is RestPattern(rest_offset) {
              return Err(pattern_failure(RestPatternNotAllowed(rest_offset)))
            }
            Ok(arguments[0])
          } else {
            let explicit_count = arguments
              .filter(fn(p) { !(p is RestPattern(_)) })
              .length()
            let has_rest = explicit_count != arguments.length()
            if (!has_rest && explicit_count == 1) || explicit_count > 32 {
              return Err(
                pattern_failure(
                  InvalidProductPatternArity(explicit_count, offset),
                ),
              )
            }
            Ok(ProductPattern(arguments, offset))
          }
        }
        @tokenizer.Identifier(name) => {
          self.consume_lookahead()
          Ok(binding_pattern(name, offset))
        }
        @tokenizer.AtIdentifier(name) => {
          self.consume_lookahead()
          Ok(ImportAliasPattern(name, offset))
        }
        @tokenizer.Symbol(@tokenizer.Ellipsis) => {
          self.consume_lookahead()
          if allow_rest {
            Ok(RestPattern(offset))
          } else {
            Err(pattern_failure(RestPatternNotAllowed(offset)))
          }
        }
        @tokenizer.Error(error) => {
          self.consume_lookahead()
          Err(pattern_failure(PatternLexicalError(error, offset)))
        }
        @tokenizer.Symbol(@tokenizer.Plus)
        | @tokenizer.Symbol(@tokenizer.Minus) => {
          let operator = match token.kind() {
            @tokenizer.Symbol(@tokenizer.Minus) => Negative
            _ => Positive
          }
          self.consume_lookahead()
          match self.peek_token() {
            Some(value_token) =>
              match value_token.kind() {
                @tokenizer.I8(_)
                | @tokenizer.I16(_)
                | @tokenizer.I32(_)
                | @tokenizer.I64(_)
                | @tokenizer.U8(_)
                | @tokenizer.U16(_)
                | @tokenizer.U32(_)
                | @tokenizer.U64(_)
                | @tokenizer.F32(_)
                | @tokenizer.F64(_) => {
                  let value = token_expression(value_token).unwrap()
                  self.consume_lookahead()
                  Ok(
                    LiteralPattern(PrefixExpr(operator, value, offset), offset),
                  )
                }
                @tokenizer.Error(error) => {
                  let error_offset = value_token.offset()
                  self.consume_lookahead()
                  Err(pattern_failure(PatternLexicalError(error, error_offset)))
                }
                _ => Err(pattern_failure(ExpectedPattern(Some(value_token))))
              }
            None => Err(pattern_failure(ExpectedPattern(None)))
          }
        }
        @tokenizer.I8(_)
        | @tokenizer.I16(_)
        | @tokenizer.I32(_)
        | @tokenizer.I64(_)
        | @tokenizer.U8(_)
        | @tokenizer.U16(_)
        | @tokenizer.U32(_)
        | @tokenizer.U64(_)
        | @tokenizer.F32(_)
        | @tokenizer.F64(_)
        | @tokenizer.StringLiteral(_)
        | @tokenizer.MultilineString(_)
        | @tokenizer.Keyword(@tokenizer.True)
        | @tokenizer.Keyword(@tokenizer.False) => {
          let expression = token_expression(token).unwrap()
          self.consume_lookahead()
          Ok(LiteralPattern(expression, offset))
        }
        _ => Err(pattern_failure(ExpectedPattern(Some(token))))
      }
    }
  }
}

///|
fn Parser::parse_pattern_context_with_stop(
  self : Parser,
  allow_rest : Bool,
  stop_left_brace : Bool,
) -> Result[Pattern, RecoveryFailure] {
  let mut pattern = match self.parse_pattern_base(allow_rest) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  if pattern is RestPattern(_) {
    return Ok(pattern)
  }
  while true {
    match self.peek_token() {
      Some(token) =>
        match token.kind() {
          @tokenizer.Symbol(@tokenizer.Dot) if pattern
            is ImportAliasPattern(_, _) => {
            let separator_offset = token.offset()
            self.consume_lookahead()
            self.skip_newlines()
            let property = match self.peek_token() {
              Some(next) =>
                match next.kind() {
                  @tokenizer.Identifier(name) => {
                    self.consume_lookahead()
                    name
                  }
                  @tokenizer.Error(error) => {
                    let offset = next.offset()
                    self.consume_lookahead()
                    return Err(
                      pattern_failure(PatternLexicalError(error, offset)),
                    )
                  }
                  _ =>
                    return Err(
                      pattern_failure(ExpectedPatternProperty(Some(next))),
                    )
                }
              None => return Err(pattern_failure(ExpectedPatternProperty(None)))
            }
            pattern = QualifiedPattern(pattern, property, separator_offset)
          }
          @tokenizer.Symbol(@tokenizer.DoubleColon) => {
            let separator_offset = token.offset()
            self.consume_lookahead()
            self.skip_newlines()
            let property = match self.peek_token() {
              Some(next) =>
                match next.kind() {
                  @tokenizer.Identifier(name) => {
                    self.consume_lookahead()
                    name
                  }
                  @tokenizer.Error(error) => {
                    let offset = next.offset()
                    self.consume_lookahead()
                    return Err(
                      pattern_failure(PatternLexicalError(error, offset)),
                    )
                  }
                  _ =>
                    return Err(
                      pattern_failure(ExpectedPatternProperty(Some(next))),
                    )
                }
              None => return Err(pattern_failure(ExpectedPatternProperty(None)))
            }
            pattern = QualifiedPattern(pattern, property, separator_offset)
          }
          @tokenizer.Symbol(@tokenizer.LeftParen) => {
            let open_offset = token.offset()
            self.consume_lookahead()
            let (arguments, _) = match
              self.parse_tuple_pattern_arguments(open_offset) {
              Ok(value) => value
              Err(error) => return Err(error.inside_parenthesis())
            }
            pattern = TuplePattern(pattern, arguments, open_offset)
          }
          @tokenizer.Symbol(@tokenizer.LeftBrace) if stop_left_brace =>
            return Ok(pattern)
          @tokenizer.Symbol(@tokenizer.LeftBrace) => {
            let open_offset = token.offset()
            self.consume_lookahead()
            pattern = match self.parse_struct_pattern(pattern, open_offset) {
              Ok(value) => value
              Err(error) => return Err(error.inside_brace())
            }
          }
          _ => return Ok(pattern)
        }
      None => return Ok(pattern)
    }
  } nobreak {
    abort("unreachable pattern parser termination")
  }
}

///|
fn Parser::parse_pattern_context(
  self : Parser,
  allow_rest : Bool,
) -> Result[Pattern, RecoveryFailure] {
  self.parse_pattern_context_with_stop(allow_rest, false)
}

///|
/// Parses one pattern without invoking the expression parser.
pub fn Parser::parse_pattern(self : Parser) -> Result[Pattern, PatternError] {
  match self.parse_pattern_context(false) {
    Ok(value) => Ok(value)
    Err(failure) => Err(failure.pattern_error())
  }
}
