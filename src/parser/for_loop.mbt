///|
fn for_next_call(iterator_name : String, offset : UInt64) -> Expr {
  CallExpr(
    FieldExpr(NameExpr(iterator_name, offset), "next", offset),
    [],
    offset,
  )
}

///|
fn for_option_pattern(
  constructor : String,
  payload : Pattern?,
  offset : UInt64,
) -> Pattern {
  let target = QualifiedPattern(
    BindingPattern("Option", offset),
    constructor,
    offset,
  )
  match payload {
    Some(pattern) => TuplePattern(target, [pattern], offset)
    None => target
  }
}

///|
fn desugar_for_expression(
  pattern : Pattern,
  iterable : Expr,
  body : Block,
  for_offset : UInt64,
) -> Expr {
  let iterator_name = "$for_iter_\{for_offset}"
  let iterator_value = CallExpr(
    FieldExpr(iterable, "iter", for_offset),
    [],
    for_offset,
  )
  let some_items : Array[BlockItem] = []
  for item in body.items {
    some_items.push(item)
  }
  some_items.push(
    ExpressionItem(
      ContinueExpr(for_next_call(iterator_name, for_offset), for_offset),
      for_offset,
    ),
  )
  let unit = BlockExpr({ items: [], offset: for_offset, })
  let loop_expression = WhileExpr(
    for_next_call(iterator_name, for_offset),
    [
      {
        pattern: for_option_pattern("Some", Some(pattern), for_offset),
        guard_condition: None,
        body: BlockExpr({ items: some_items, offset: body.offset, }),
        offset: pattern.offset(),
      },
      {
        pattern: for_option_pattern("None", None, for_offset),
        guard_condition: None,
        body: BreakExpr(unit, for_offset),
        offset: for_offset,
      },
    ],
    for_offset,
  )
  BlockExpr({
    items: [
      LetItem(false, iterator_name, for_offset, iterator_value, for_offset),
      ExpressionItem(loop_expression, for_offset),
    ],
    offset: for_offset,
  })
}

///|
fn Parser::parse_for_expression(
  self : Parser,
  for_offset : UInt64,
) -> Result[Expr, RecoveryFailure] {
  let pattern = match self.parse_pattern_context(false) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.In) => self.consume_lookahead()
        @tokenizer.Error(error) => {
          let offset = token.offset()
          self.consume_lookahead()
          return Err(expression_failure(LexicalError(error, offset)))
        }
        _ =>
          return Err(expression_failure(ExpectedForIn(Some(token), for_offset)))
      }
    None => return Err(expression_failure(ExpectedForIn(None, for_offset)))
  }
  let iterable = match self.parse_expression_before_block() {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let open_offset = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftBrace) => {
          self.consume_lookahead()
          token.offset()
        }
        @tokenizer.Error(error) => {
          let offset = token.offset()
          self.consume_lookahead()
          return Err(expression_failure(LexicalError(error, offset)))
        }
        _ =>
          return Err(
            expression_failure(ExpectedForBody(Some(token), for_offset)),
          )
      }
    None => return Err(expression_failure(ExpectedForBody(None, for_offset)))
  }
  let body = match self.parse_block_after_left_brace(open_offset) {
    Ok(value) => value
    Err(error) => return Err(error.inside_brace())
  }
  Ok(desugar_for_expression(pattern, iterable, body, for_offset))
}
