///|
pub enum DiagnosticSeverity {
  Error
  Warning
  Info
  Hint
} derive(Eq, Debug)

///|
pub fn DiagnosticSeverity::rank(self : DiagnosticSeverity) -> Int {
  match self {
    Error => 0
    Warning => 1
    Info => 2
    Hint => 3
  }
}

///|
pub fn DiagnosticSeverity::from_rank(rank : Int) -> DiagnosticSeverity {
  match rank {
    1 => Warning
    2 => Info
    3 => Hint
    _ => Error
  }
}

///|
pub struct ParseDiagnostic {
  severity : DiagnosticSeverity
  error : DeclarationError
} derive(Eq, Debug)

///|
pub enum ParseEvent {
  Declaration(Declaration)
  Diagnostic(ParseDiagnostic)
} derive(Eq, Debug)

///|
fn token_starts_declaration(token : @tokenizer.Token) -> Bool {
  match token.kind() {
    @tokenizer.Keyword(@tokenizer.Pub)
    | @tokenizer.Keyword(@tokenizer.Open)
    | @tokenizer.Keyword(@tokenizer.Import)
    | @tokenizer.Keyword(@tokenizer.Builtin)
    | @tokenizer.Keyword(@tokenizer.Let)
    | @tokenizer.Keyword(@tokenizer.Trait)
    | @tokenizer.Keyword(@tokenizer.Struct)
    | @tokenizer.Keyword(@tokenizer.Enum)
    | @tokenizer.Keyword(@tokenizer.Type)
    | @tokenizer.Keyword(@tokenizer.Fn)
    | @tokenizer.Keyword(@tokenizer.Test)
    | @tokenizer.Keyword(@tokenizer.Impl)
    | @tokenizer.Keyword(@tokenizer.Foreign) => true
    _ => false
  }
}

///|
fn Parser::discard_through_newline(self : Parser) -> Unit {
  while true {
    match self.peek_token() {
      None => return
      Some(token) => {
        let at_line_end = token.kind() is @tokenizer.Newline
        self.consume_lookahead()
        if at_line_end {
          return
        }
      }
    }
  }
}

///|
fn RecoveryFence::is_clear(self : RecoveryFence) -> Bool {
  self.braces == 0 &&
  self.parentheses == 0 &&
  self.brackets == 0 &&
  self.angles == 0
}

///|
fn RecoveryFence::consume_token(
  self : RecoveryFence,
  token : @tokenizer.Token,
) -> Unit {
  match token.kind() {
    @tokenizer.Symbol(@tokenizer.LeftBrace) => self.braces += 1
    @tokenizer.Symbol(@tokenizer.RightBrace) =>
      if self.braces > 0 {
        self.braces -= 1
      }
    @tokenizer.Symbol(@tokenizer.LeftParen) => self.parentheses += 1
    @tokenizer.Symbol(@tokenizer.RightParen) =>
      if self.parentheses > 0 {
        self.parentheses -= 1
      }
    @tokenizer.Symbol(@tokenizer.LeftBracket) => self.brackets += 1
    @tokenizer.Symbol(@tokenizer.RightBracket) =>
      if self.brackets > 0 {
        self.brackets -= 1
      }
    @tokenizer.Symbol(@tokenizer.Less) =>
      if self.angles > 0 {
        self.angles += 1
      }
    @tokenizer.Symbol(@tokenizer.Greater) =>
      if self.angles > 0 {
        self.angles -= 1
      }
    @tokenizer.Symbol(@tokenizer.ShiftRight) =>
      if self.angles > 1 {
        self.angles -= 2
      } else if self.angles == 1 {
        self.angles = 0
      }
    _ => ()
  }
}

///|
fn Parser::discard_through_recovery_fence(
  self : Parser,
  fence : RecoveryFence,
) -> Unit {
  if fence.is_clear() {
    self.discard_through_newline()
    return
  }
  while true {
    match self.peek_token() {
      None => return
      Some(token) => {
        let at_line_end = token.kind() is @tokenizer.Newline
        fence.consume_token(token)
        self.consume_lookahead()
        if at_line_end && fence.is_clear() {
          return
        }
      }
    }
  }
}

///|
fn Parser::recover_to_declaration_boundary(
  self : Parser,
  failure : RecoveryFailure,
) -> Unit {
  self.discard_through_recovery_fence(failure.fence())
  while true {
    self.skip_newlines()
    match self.peek_token() {
      None => return
      Some(token) =>
        if token_starts_declaration(token) {
          return
        } else {
          self.discard_through_newline()
        }
    }
  }
}

///|
priv struct ModuleEventParser {
  parser : Parser
  mut preamble_open : Bool
}

///|
fn ModuleEventParser::next_parse_event(self : ModuleEventParser) -> ParseEvent? {
  self.parser.skip_newlines()
  if self.parser.peek_token() is None {
    return None
  }
  match self.parser.parse_declaration_recoverable() {
    Ok(declaration) =>
      match declaration {
        Import(import_) =>
          if self.preamble_open {
            Some(Declaration(Import(import_)))
          } else {
            Some(
              Diagnostic({
                severity: Error,
                error: ImportAfterDeclaration(import_.offset),
              }),
            )
          }
        _ => {
          self.preamble_open = false
          Some(Declaration(declaration))
        }
      }
    Err(failure) => {
      let error = failure.declaration_error()
      self.parser.recover_to_declaration_boundary(failure)
      Some(Diagnostic({ severity: Error, error }))
    }
  }
}

///|
/// Starts a lazy, interleaved stream of declarations and diagnostics.
pub fn Parser::parse_events(self : Parser) -> Iter[ParseEvent] {
  let module_parser = { parser: self, preamble_open: true }
  Iter::new(fn() { module_parser.next_parse_event() })
}

///|
/// Parses a token stream lazily at module scope.
pub fn parse(tokens : Iter[@tokenizer.Token]) -> Iter[ParseEvent] {
  Parser::new(tokens).parse_events()
}

///|
/// Tokenizes and parses bytes lazily at module scope.
pub fn parse_bytes(bytes : Bytes) -> Iter[ParseEvent] {
  Parser::from_bytes(bytes).parse_events()
}
