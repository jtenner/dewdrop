///|
pub struct PatternArm {
  pattern : Pattern
  guard_condition : Expr?
  body : Expr
  offset : UInt64
} derive(Eq, Debug, ToJson, FromJson)

///|
fn Parser::consume_match_left_brace(
  self : Parser,
  match_offset : UInt64,
) -> Result[UInt64, RecoveryFailure] {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftBrace) => {
          let offset = token.offset()
          self.consume_lookahead()
          Ok(offset)
        }
        @tokenizer.Error(error) => {
          let offset = token.offset()
          self.consume_lookahead()
          Err(expression_failure(LexicalError(error, offset)))
        }
        _ =>
          Err(expression_failure(ExpectedMatchBody(Some(token), match_offset)))
      }
    None => Err(expression_failure(ExpectedMatchBody(None, match_offset)))
  }
}

///|
fn Parser::finish_match_arm_line(
  self : Parser,
  match_offset : UInt64,
) -> Result[Unit, RecoveryFailure] {
  match self.peek_token() {
    None => Err(expression_failure(UnclosedMatch(match_offset)))
    Some(token) =>
      match token.kind() {
        @tokenizer.Newline => {
          self.consume_lookahead()
          Ok(())
        }
        @tokenizer.Error(error) => {
          let offset = token.offset()
          self.consume_lookahead()
          Err(expression_failure(LexicalError(error, offset)))
        }
        _ =>
          Err(
            expression_failure(
              ExpectedMatchArmNewline(Some(token), match_offset),
            ),
          )
      }
  }
}

///|
fn Parser::parse_match_arm_body(
  self : Parser,
  match_offset : UInt64,
) -> Result[Expr, RecoveryFailure] {
  self.skip_newlines()
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftBrace) => {
          let open_offset = token.offset()
          self.consume_lookahead()
          match self.parse_block_after_left_brace(open_offset) {
            Ok(block) => Ok(BlockExpr(block))
            Err(error) => Err(error.inside_brace())
          }
        }
        @tokenizer.Error(error) => {
          let offset = token.offset()
          self.consume_lookahead()
          Err(expression_failure(LexicalError(error, offset)))
        }
        _ => self.parse_expression_recoverable()
      }
    None => Err(expression_failure(UnclosedMatch(match_offset)))
  }
}

///|
fn Parser::parse_pattern_arm(self : Parser) -> Result[Pattern, RecoveryFailure] {
  let first = match self.parse_pattern_context(false) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Comma) => ()
        _ => return Ok(first)
      }
    None => return Ok(first)
  }
  let alternatives : Array[Pattern] = []
  while true {
    self.consume_lookahead()
    self.skip_newlines()
    let alternative = match self.parse_pattern_context(false) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    alternatives.push(alternative)
    match self.peek_token() {
      Some(token) =>
        match token.kind() {
          @tokenizer.Symbol(@tokenizer.Comma) => continue
          _ =>
            return Ok(AlternativePattern(first, alternatives, first.offset()))
        }
      None => return Ok(AlternativePattern(first, alternatives, first.offset()))
    }
  } nobreak {
    abort("unreachable match alternative parser termination")
  }
}

///|
fn Parser::parse_pattern_arm_guard(
  self : Parser,
) -> Result[Expr?, RecoveryFailure] {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.If) => {
          self.consume_lookahead()
          match self.parse_expression_recoverable() {
            Ok(value) => Ok(Some(value))
            Err(error) => Err(error)
          }
        }
        _ => Ok(None)
      }
    None => Ok(None)
  }
}

///|
fn Parser::parse_match_body(
  self : Parser,
  match_offset : UInt64,
  open_offset : UInt64,
) -> Result[Array[PatternArm], RecoveryFailure] {
  let arms : Array[PatternArm] = []
  if self.consume_right_brace() {
    return Ok(arms)
  }
  guard self.consume_newline_token() else {
    return Err(
      expression_failure(
        ExpectedMatchBodyNewline(self.peek_token(), open_offset),
      ),
    )
  }
  self.skip_newlines()
  while true {
    if self.consume_right_brace() {
      return Ok(arms)
    }
    if self.peek_token() is None {
      return Err(expression_failure(UnclosedMatch(match_offset)))
    }
    let pattern = match self.parse_pattern_arm() {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    let arm_offset = pattern.offset()
    let guard_condition = match self.parse_pattern_arm_guard() {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    match self.peek_token() {
      None => return Err(expression_failure(UnclosedMatch(match_offset)))
      Some(token) =>
        match token.kind() {
          @tokenizer.Symbol(@tokenizer.FatArrow) => self.consume_lookahead()
          @tokenizer.Error(error) => {
            let offset = token.offset()
            self.consume_lookahead()
            return Err(expression_failure(LexicalError(error, offset)))
          }
          _ =>
            return Err(
              expression_failure(ExpectedMatchArmArrow(Some(token), arm_offset)),
            )
        }
    }
    let body = match self.parse_match_arm_body(match_offset) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    match self.finish_match_arm_line(match_offset) {
      Ok(_) => ()
      Err(error) => return Err(error)
    }
    arms.push({ pattern, guard_condition, body, offset: arm_offset, })
    self.skip_newlines()
  } nobreak {
    abort("unreachable match body parser termination")
  }
}

///|
fn Parser::parse_match_expression(
  self : Parser,
  match_offset : UInt64,
) -> Result[Expr, RecoveryFailure] {
  let scrutinee = match self.parse_expression_before_block() {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let open_offset = match self.consume_match_left_brace(match_offset) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let arms = match self.parse_match_body(match_offset, open_offset) {
    Ok(value) => value
    Err(error) => return Err(error.inside_brace())
  }
  Ok(MatchExpr(scrutinee, arms, match_offset))
}
