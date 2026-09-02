///|
fn Parser::parse_control_value(
  self : Parser,
  control_offset : UInt64,
  is_break : Bool,
) -> Result[Expr, RecoveryFailure] {
  match self.peek_token() {
    None =>
      if is_break {
        Err(expression_failure(ExpectedBreakValue(None, control_offset)))
      } else {
        Err(expression_failure(ExpectedContinueValue(None, control_offset)))
      }
    Some(token) =>
      match token.kind() {
        @tokenizer.Newline | @tokenizer.Symbol(@tokenizer.RightBrace) =>
          if is_break {
            Err(
              expression_failure(
                ExpectedBreakValue(Some(token), control_offset),
              ),
            )
          } else {
            Err(
              expression_failure(
                ExpectedContinueValue(Some(token), control_offset),
              ),
            )
          }
        @tokenizer.Error(error) => {
          let offset = token.offset()
          self.consume_lookahead()
          Err(expression_failure(LexicalError(error, offset)))
        }
        _ => self.parse_expression_recoverable()
      }
  }
}

///|
fn Parser::parse_break_expression(
  self : Parser,
  break_offset : UInt64,
) -> Result[Expr, RecoveryFailure] {
  match self.parse_control_value(break_offset, true) {
    Ok(value) => Ok(BreakExpr(value, break_offset))
    Err(error) => Err(error)
  }
}

///|
fn Parser::parse_continue_expression(
  self : Parser,
  continue_offset : UInt64,
) -> Result[Expr, RecoveryFailure] {
  match self.parse_control_value(continue_offset, false) {
    Ok(value) => Ok(ContinueExpr(value, continue_offset))
    Err(error) => Err(error)
  }
}

///|
fn Parser::consume_while_left_brace(
  self : Parser,
  while_offset : UInt64,
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
          Err(expression_failure(ExpectedWhileBody(Some(token), while_offset)))
      }
    None => Err(expression_failure(ExpectedWhileBody(None, while_offset)))
  }
}

///|
fn Parser::finish_while_arm_line(
  self : Parser,
  while_offset : UInt64,
) -> Result[Unit, RecoveryFailure] {
  match self.peek_token() {
    None => Err(expression_failure(UnclosedWhile(while_offset)))
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
              ExpectedWhileArmNewline(Some(token), while_offset),
            ),
          )
      }
  }
}

///|
fn Parser::parse_while_arm_body(
  self : Parser,
  while_offset : UInt64,
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
    None => Err(expression_failure(UnclosedWhile(while_offset)))
  }
}

///|
fn Parser::parse_while_body(
  self : Parser,
  while_offset : UInt64,
  open_offset : UInt64,
) -> Result[Array[PatternArm], RecoveryFailure] {
  let arms : Array[PatternArm] = []
  if self.consume_right_brace() {
    return Ok(arms)
  }
  guard self.consume_newline_token() else {
    return Err(
      expression_failure(
        ExpectedWhileBodyNewline(self.peek_token(), open_offset),
      ),
    )
  }
  self.skip_newlines()
  while true {
    if self.consume_right_brace() {
      return Ok(arms)
    }
    if self.peek_token() is None {
      return Err(expression_failure(UnclosedWhile(while_offset)))
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
      None => return Err(expression_failure(UnclosedWhile(while_offset)))
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
              expression_failure(ExpectedWhileArmArrow(Some(token), arm_offset)),
            )
        }
    }
    let body = match self.parse_while_arm_body(while_offset) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    match self.finish_while_arm_line(while_offset) {
      Ok(_) => ()
      Err(error) => return Err(error)
    }
    arms.push({ pattern, guard_condition, body, offset: arm_offset, })
    self.skip_newlines()
  } nobreak {
    abort("unreachable functional while body parser termination")
  }
}

///|
fn Parser::parse_while_expression(
  self : Parser,
  while_offset : UInt64,
) -> Result[Expr, RecoveryFailure] {
  let initial = match self.parse_expression_before_block() {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let open_offset = match self.consume_while_left_brace(while_offset) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let arms = match self.parse_while_body(while_offset, open_offset) {
    Ok(value) => value
    Err(error) => return Err(error.inside_brace())
  }
  Ok(WhileExpr(initial, arms, while_offset))
}
