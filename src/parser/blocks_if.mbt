///|
pub enum BlockItem {
  LetItem(Bool, String, UInt64, Expr, UInt64)
  ReturnItem(Expr?, UInt64)
  AssignmentItem(Expr, Expr, UInt64)
  IndexSetItem(Expr, Expr, UInt64)
  ExpressionItem(Expr, UInt64)
} derive(Eq, Debug)

///|
pub fn BlockItem::offset(self : BlockItem) -> UInt64 {
  match self {
    LetItem(_, _, _, _, offset)
    | ReturnItem(_, offset)
    | AssignmentItem(_, _, offset)
    | IndexSetItem(_, _, offset)
    | ExpressionItem(_, offset) => offset
  }
}

///|
pub struct Block {
  items : Array[BlockItem]
  offset : UInt64
} derive(Eq, Debug)

///|
pub fn Block::tail_expression(self : Block) -> Expr? {
  guard self.items.length() > 0 else { return None }
  match self.items[self.items.length() - 1] {
    ExpressionItem(expression, _) => Some(expression)
    _ => None
  }
}

///|
fn Parser::finish_block_item_line(
  self : Parser,
  open_offset : UInt64,
) -> Result[Unit, RecoveryFailure] {
  match self.peek_token() {
    None => Err(expression_failure(UnclosedBlock(open_offset)))
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
              ExpectedBlockItemNewline(Some(token), open_offset),
            ),
          )
      }
  }
}

///|
fn Parser::parse_block_let_item(
  self : Parser,
  open_offset : UInt64,
  let_offset : UInt64,
) -> Result[BlockItem, RecoveryFailure] {
  let mutable_ = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Mut) => {
          self.consume_lookahead()
          true
        }
        _ => false
      }
    None => false
  }
  let (name, name_offset) = match self.peek_token() {
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
          return Err(expression_failure(LexicalError(error, offset)))
        }
        _ =>
          return Err(expression_failure(ExpectedBlockBindingName(Some(token))))
      }
    None => return Err(expression_failure(ExpectedBlockBindingName(None)))
  }
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Equal) => self.consume_lookahead()
        @tokenizer.Error(error) => {
          let offset = token.offset()
          self.consume_lookahead()
          return Err(expression_failure(LexicalError(error, offset)))
        }
        _ => return Err(expression_failure(ExpectedBlockEqual(Some(token))))
      }
    None => return Err(expression_failure(ExpectedBlockEqual(None)))
  }
  let value = match self.parse_expression_recoverable() {
    Ok(expression) => expression
    Err(error) => return Err(error)
  }
  match self.finish_block_item_line(open_offset) {
    Ok(_) => Ok(LetItem(mutable_, name, name_offset, value, let_offset))
    Err(error) => Err(error)
  }
}

///|
fn Parser::parse_block_return_item(
  self : Parser,
  open_offset : UInt64,
  return_offset : UInt64,
) -> Result[BlockItem, RecoveryFailure] {
  if self.consume_newline_token() {
    return Ok(ReturnItem(None, return_offset))
  }
  let value = match self.parse_expression_recoverable() {
    Ok(expression) => expression
    Err(error) => return Err(error)
  }
  match self.finish_block_item_line(open_offset) {
    Ok(_) => Ok(ReturnItem(Some(value), return_offset))
    Err(error) => Err(error)
  }
}

///|
fn Parser::parse_block_after_left_brace(
  self : Parser,
  open_offset : UInt64,
) -> Result[Block, RecoveryFailure] {
  let items : Array[BlockItem] = []
  let cleanups : Array[DeferredCleanup] = []
  if self.consume_right_brace() {
    return Ok({ items, offset: open_offset })
  }
  guard self.consume_newline_token() else {
    return Err(
      expression_failure(ExpectedBlockNewline(self.peek_token(), open_offset)),
    )
  }
  self.skip_newlines()
  while true {
    if self.consume_right_brace() {
      return Ok(finalize_deferred_block(items, cleanups, open_offset))
    }
    let token = match self.peek_token() {
      Some(value) => value
      None => return Err(expression_failure(UnclosedBlock(open_offset)))
    }
    let offset = token.offset()
    match token.kind() {
      @tokenizer.Keyword(@tokenizer.Using) => {
        self.consume_lookahead()
        match self.parse_block_using_items(open_offset, offset) {
          Ok((binding, registration, cleanup)) => {
            items.push(binding)
            items.push(registration)
            cleanups.push(cleanup)
            self.skip_newlines()
            continue
          }
          Err(error) => return Err(error)
        }
      }
      @tokenizer.Keyword(@tokenizer.Defer) => {
        self.consume_lookahead()
        match self.parse_block_defer_item(open_offset, offset) {
          Ok((item, cleanup)) => {
            items.push(item)
            cleanups.push(cleanup)
            self.skip_newlines()
            continue
          }
          Err(error) => return Err(error)
        }
      }
      _ => ()
    }
    let item = match token.kind() {
      @tokenizer.Error(error) => {
        self.consume_lookahead()
        return Err(expression_failure(LexicalError(error, offset)))
      }
      @tokenizer.Keyword(@tokenizer.Let) => {
        self.consume_lookahead()
        match self.parse_block_let_item(open_offset, offset) {
          Ok(value) => value
          Err(error) => return Err(error)
        }
      }
      @tokenizer.Keyword(@tokenizer.Return) => {
        self.consume_lookahead()
        match self.parse_block_return_item(open_offset, offset) {
          Ok(value) => value
          Err(error) => return Err(error)
        }
      }
      _ => {
        let expression = match self.parse_expression_recoverable() {
          Ok(value) => value
          Err(error) => return Err(error)
        }
        let item = match self.peek_token() {
          Some(equal) =>
            match equal.kind() {
              @tokenizer.Symbol(@tokenizer.Equal) => {
                let assignable = match expression {
                  NameExpr(_, _) | IndexExpr(_, _, _) => true
                  _ => false
                }
                if !assignable {
                  return Err(
                    expression_failure(ExpectedAssignmentTarget(equal, offset)),
                  )
                }
                let equal_offset = equal.offset()
                self.consume_lookahead()
                let value = match self.parse_expression_recoverable() {
                  Ok(value) => value
                  Err(error) => return Err(error)
                }
                match expression {
                  NameExpr(_, _) =>
                    AssignmentItem(expression, value, equal_offset)
                  IndexExpr(_, _, _) =>
                    IndexSetItem(expression, value, equal_offset)
                  _ => abort("validated assignment target changed shape")
                }
              }
              _ => ExpressionItem(expression, offset)
            }
          None => ExpressionItem(expression, offset)
        }
        match self.finish_block_item_line(open_offset) {
          Ok(_) => item
          Err(error) => return Err(error)
        }
      }
    }
    defer_transform_block_item(items, item, cleanups, 0)
    self.skip_newlines()
  } nobreak {
    abort("unreachable block parser termination")
  }
}

///|
fn Parser::consume_expression_left_brace(
  self : Parser,
  if_offset : UInt64,
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
        _ => Err(expression_failure(ExpectedIfBody(Some(token), if_offset)))
      }
    None => Err(expression_failure(ExpectedIfBody(None, if_offset)))
  }
}

///|
priv struct IsConditionParts {
  scrutinee : Expr
  pattern : Pattern
  guard_condition : Expr?
  offset : UInt64
}

///|
fn split_is_condition(condition : Expr) -> IsConditionParts? {
  match condition {
    IsExpr(scrutinee, pattern, offset) =>
      Some({ scrutinee, pattern, guard_condition: None, offset })
    BinaryExpr(LogicalAnd, left, right, operator_offset) =>
      match split_is_condition(left) {
        Some(parts) => {
          let guard_condition = match parts.guard_condition {
            Some(existing) =>
              Some(BinaryExpr(LogicalAnd, existing, right, operator_offset))
            None => Some(right)
          }
          Some({
            scrutinee: parts.scrutinee,
            pattern: parts.pattern,
            guard_condition,
            offset: parts.offset,
          })
        }
        None => None
      }
    _ => None
  }
}

///|
fn make_if_expression(
  condition : Expr,
  then_block : Block,
  alternative : Expr?,
  if_offset : UInt64,
) -> Expr {
  match split_is_condition(condition) {
    Some(parts) => {
      let fallback = match alternative {
        Some(value) => value
        None => BlockExpr({ items: [], offset: if_offset })
      }
      MatchExpr(
        parts.scrutinee,
        [
          {
            pattern: parts.pattern,
            guard_condition: parts.guard_condition,
            body: BlockExpr(then_block),
            offset: parts.pattern.offset(),
          },
          {
            pattern: WildcardPattern(parts.offset),
            guard_condition: None,
            body: fallback,
            offset: parts.offset,
          },
        ],
        parts.offset,
      )
    }
    None => IfExpr(condition, then_block, alternative, if_offset)
  }
}

///|
fn Parser::parse_if_expression(
  self : Parser,
  if_offset : UInt64,
) -> Result[Expr, RecoveryFailure] {
  let condition = match self.parse_expression_before_block() {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let then_open = match self.consume_expression_left_brace(if_offset) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let then_block = match self.parse_block_after_left_brace(then_open) {
    Ok(value) => value
    Err(error) => return Err(error.inside_brace())
  }
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Else) => self.consume_lookahead()
        _ =>
          return Ok(make_if_expression(condition, then_block, None, if_offset))
      }
    None =>
      return Ok(make_if_expression(condition, then_block, None, if_offset))
  }
  let next_if_offset = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftBrace) => {
          let open_offset = token.offset()
          self.consume_lookahead()
          let else_block = match
            self.parse_block_after_left_brace(open_offset) {
            Ok(value) => value
            Err(error) => return Err(error.inside_brace())
          }
          return Ok(
            make_if_expression(
              condition,
              then_block,
              Some(BlockExpr(else_block)),
              if_offset,
            ),
          )
        }
        @tokenizer.Keyword(@tokenizer.If) => {
          let offset = token.offset()
          self.consume_lookahead()
          offset
        }
        @tokenizer.Error(error) => {
          let offset = token.offset()
          self.consume_lookahead()
          return Err(expression_failure(LexicalError(error, offset)))
        }
        _ =>
          return Err(
            expression_failure(ExpectedElseBranch(Some(token), if_offset)),
          )
      }
    None => return Err(expression_failure(ExpectedElseBranch(None, if_offset)))
  }
  let conditions : Array[Expr] = [condition]
  let blocks : Array[Block] = [then_block]
  let offsets : Array[UInt64] = [if_offset]
  let mut current_if_offset = next_if_offset
  let mut final_else : Expr? = None
  while true {
    let current_condition = match self.parse_expression_before_block() {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    let current_open = match
      self.consume_expression_left_brace(current_if_offset) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    let current_block = match self.parse_block_after_left_brace(current_open) {
      Ok(value) => value
      Err(error) => return Err(error.inside_brace())
    }
    conditions.push(current_condition)
    blocks.push(current_block)
    offsets.push(current_if_offset)
    match self.peek_token() {
      Some(token) =>
        match token.kind() {
          @tokenizer.Keyword(@tokenizer.Else) => {
            self.consume_lookahead()
            match self.peek_token() {
              Some(next) =>
                match next.kind() {
                  @tokenizer.Keyword(@tokenizer.If) => {
                    current_if_offset = next.offset()
                    self.consume_lookahead()
                  }
                  @tokenizer.Symbol(@tokenizer.LeftBrace) => {
                    let open_offset = next.offset()
                    self.consume_lookahead()
                    let else_block = match
                      self.parse_block_after_left_brace(open_offset) {
                      Ok(value) => value
                      Err(error) => return Err(error.inside_brace())
                    }
                    final_else = Some(BlockExpr(else_block))
                    break
                  }
                  @tokenizer.Error(error) => {
                    let offset = next.offset()
                    self.consume_lookahead()
                    return Err(expression_failure(LexicalError(error, offset)))
                  }
                  _ =>
                    return Err(
                      expression_failure(
                        ExpectedElseBranch(Some(next), current_if_offset),
                      ),
                    )
                }
              None =>
                return Err(
                  expression_failure(
                    ExpectedElseBranch(None, current_if_offset),
                  ),
                )
            }
          }
          _ => break
        }
      None => break
    }
  }
  let mut branch = final_else
  let mut index = conditions.length()
  while index > 0 {
    index -= 1
    branch = Some(
      make_if_expression(
        conditions[index],
        blocks[index],
        branch,
        offsets[index],
      ),
    )
  }
  Ok(branch.unwrap())
}
