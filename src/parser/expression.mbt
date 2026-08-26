///|
let pending_group_code = 0

///|
let pending_positive_code = 1

///|
let pending_negative_code = 2

///|
let pending_not_code = 3

///|
let pending_binary_base = 16

///|
let expression_stop_left_brace = 1

///|
fn expression_stops_at(stop_bits : Int, flag : Int) -> Bool {
  (stop_bits & flag) != 0
}

///|
priv enum ExpressionMode {
  SeekingUnaryValue
  SeekingBinaryOperator
}

///|
/// One-token-lookahead parser state. `take_token` is the only operation that
/// advances the underlying token iterator.
pub struct Parser {
  tokens : Iter[@tokenizer.Token]
  mut lookahead_loaded : Bool
  mut lookahead : @tokenizer.Token?
}

///|
pub fn Parser::new(tokens : Iter[@tokenizer.Token]) -> Parser {
  { tokens, lookahead_loaded: false, lookahead: None }
}

///|
pub fn Parser::from_tokenizer(tokenizer : @tokenizer.Tokenizer) -> Parser {
  Parser::new(tokenizer.iter())
}

///|
pub fn Parser::from_bytes(bytes : Bytes) -> Parser {
  Parser::from_tokenizer(@tokenizer.Tokenizer::from_bytes(bytes))
}

///|
/// Returns the current lookahead without consuming it.
pub fn Parser::peek_token(self : Parser) -> @tokenizer.Token? {
  if !self.lookahead_loaded {
    self.lookahead = self.tokens.next()
    self.lookahead_loaded = true
  }
  self.lookahead
}

///|
/// Consumes and returns exactly one token.
pub fn Parser::take_token(self : Parser) -> @tokenizer.Token? {
  let token = self.peek_token()
  self.consume_lookahead()
  token
}

///|
fn Parser::consume_lookahead(self : Parser) -> Unit {
  self.lookahead = None
  self.lookahead_loaded = false
}

///|
fn Parser::consume_newline_token(self : Parser) -> Bool {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Newline => {
          self.consume_lookahead()
          true
        }
        _ => false
      }
    None => false
  }
}

///|
fn Parser::skip_newlines(self : Parser) -> Unit {
  while self.consume_newline_token() {

  }
}

///|
fn binary_operator(symbol : @tokenizer.Symbol) -> BinaryOperator? {
  match symbol {
    @tokenizer.LogicalOr => Some(LogicalOr)
    @tokenizer.LogicalAnd => Some(LogicalAnd)
    @tokenizer.Pipe => Some(BitOr)
    @tokenizer.Caret => Some(BitXor)
    @tokenizer.Ampersand => Some(BitAnd)
    @tokenizer.EqualEqual => Some(Equal)
    @tokenizer.BangEqual => Some(NotEqual)
    @tokenizer.Less => Some(Less)
    @tokenizer.LessEqual => Some(LessEqual)
    @tokenizer.Greater => Some(Greater)
    @tokenizer.GreaterEqual => Some(GreaterEqual)
    @tokenizer.ShiftLeft => Some(ShiftLeft)
    @tokenizer.ShiftRight => Some(ShiftRight)
    @tokenizer.Plus => Some(Add)
    @tokenizer.Minus => Some(Subtract)
    @tokenizer.Star => Some(Multiply)
    @tokenizer.Slash => Some(Divide)
    @tokenizer.Percent => Some(Remainder)
    @tokenizer.Exponent => Some(Exponentiate)
    _ => None
  }
}

///|
fn binary_precedence(operator : BinaryOperator) -> Int {
  match operator {
    LogicalOr => 3
    LogicalAnd => 4
    BitOr => 5
    BitXor => 6
    BitAnd => 7
    Equal | NotEqual => 8
    Less | LessEqual | Greater | GreaterEqual => 9
    ShiftLeft | ShiftRight => 10
    Add | Subtract => 11
    Multiply | Divide | Remainder => 12
    Exponentiate => 13
  }
}

///|
fn is_left_associative(operator : BinaryOperator) -> Bool {
  operator != Exponentiate
}

///|
fn binary_operator_code(operator : BinaryOperator) -> Int {
  pending_binary_base +
  (match operator {
    LogicalOr => 0
    LogicalAnd => 1
    BitOr => 2
    BitXor => 3
    BitAnd => 4
    Equal => 5
    NotEqual => 6
    Less => 7
    LessEqual => 8
    Greater => 9
    GreaterEqual => 10
    ShiftLeft => 11
    ShiftRight => 12
    Add => 13
    Subtract => 14
    Multiply => 15
    Divide => 16
    Remainder => 17
    Exponentiate => 18
  })
}

///|
fn binary_operator_from_code(code : Int) -> BinaryOperator {
  match code - pending_binary_base {
    0 => LogicalOr
    1 => LogicalAnd
    2 => BitOr
    3 => BitXor
    4 => BitAnd
    5 => Equal
    6 => NotEqual
    7 => Less
    8 => LessEqual
    9 => Greater
    10 => GreaterEqual
    11 => ShiftLeft
    12 => ShiftRight
    13 => Add
    14 => Subtract
    15 => Multiply
    16 => Divide
    17 => Remainder
    18 => Exponentiate
    _ => abort("invalid pending binary operator code")
  }
}

///|
fn prefix_operator_code(operator : PrefixOperator) -> Int {
  match operator {
    Positive => pending_positive_code
    Negative => pending_negative_code
    LogicalNot => pending_not_code
  }
}

///|
fn prefix_operator_from_code(code : Int) -> PrefixOperator {
  match code {
    1 => Positive
    2 => Negative
    3 => LogicalNot
    _ => abort("invalid pending prefix operator code")
  }
}

///|
fn prefix_operator(symbol : @tokenizer.Symbol) -> PrefixOperator? {
  match symbol {
    @tokenizer.Plus => Some(Positive)
    @tokenizer.Minus => Some(Negative)
    @tokenizer.Bang => Some(LogicalNot)
    _ => None
  }
}

///|
fn is_comparison_operator(operator : BinaryOperator) -> Bool {
  match operator {
    Equal | NotEqual | Less | LessEqual | Greater | GreaterEqual => true
    _ => false
  }
}

///|
fn token_expression(token : @tokenizer.Token) -> Expr? {
  let offset = token.offset()
  match token.kind() {
    @tokenizer.I8(value) => Some(I8Expr(value, offset))
    @tokenizer.I16(value) => Some(I16Expr(value, offset))
    @tokenizer.I32(value) => Some(I32Expr(value, offset))
    @tokenizer.I64(value) => Some(I64Expr(value, offset))
    @tokenizer.U8(value) => Some(U8Expr(value, offset))
    @tokenizer.U16(value) => Some(U16Expr(value, offset))
    @tokenizer.U32(value) => Some(U32Expr(value, offset))
    @tokenizer.U64(value) => Some(U64Expr(value, offset))
    @tokenizer.F32(value) => Some(F32Expr(value, offset))
    @tokenizer.F64(value) => Some(F64Expr(value, offset))
    @tokenizer.StringLiteral(value) | @tokenizer.MultilineString(value) =>
      Some(StringExpr(value, offset))
    @tokenizer.BytesLiteral(value) => Some(BytesExpr(value, offset))
    @tokenizer.Identifier(name) => Some(NameExpr(name, offset))
    @tokenizer.AtIdentifier(name) => Some(ImportAliasExpr(name, offset))
    @tokenizer.Keyword(@tokenizer.True) => Some(BoolExpr(true, offset))
    @tokenizer.Keyword(@tokenizer.False) => Some(BoolExpr(false, offset))
    _ => None
  }
}

///|
fn pop_expression(values : Array[Expr]) -> Expr? {
  values.pop()
}

///|
fn reduce_top(
  values : Array[Expr],
  operator_codes : Array[Int],
  operator_offsets : Array[UInt64],
) -> Result[Unit, RecoveryFailure] {
  guard operator_codes.length() > 0 else {
    return Err(expression_failure(InvalidOperatorState(0UL)))
  }
  let top_index = operator_codes.length() - 1
  let code = operator_codes[top_index]
  let offset = operator_offsets[top_index]
  ignore(operator_codes.pop())
  ignore(operator_offsets.pop())
  if code == pending_group_code {
    return Err(expression_failure(UnclosedGroup(offset)))
  }
  if code < pending_binary_base {
    let operand = match pop_expression(values) {
      Some(value) => value
      None => return Err(expression_failure(MissingOperand(offset)))
    }
    values.push(PrefixExpr(prefix_operator_from_code(code), operand, offset))
    return Ok(())
  }
  let right = match pop_expression(values) {
    Some(value) => value
    None => return Err(expression_failure(MissingOperand(offset)))
  }
  let left = match pop_expression(values) {
    Some(value) => value
    None => return Err(expression_failure(MissingOperand(offset)))
  }
  values.push(BinaryExpr(binary_operator_from_code(code), left, right, offset))
  Ok(())
}

///|
fn push_binary_operator(
  values : Array[Expr],
  operator_codes : Array[Int],
  operator_offsets : Array[UInt64],
  operator : BinaryOperator,
  offset : UInt64,
) -> Result[Unit, RecoveryFailure] {
  let precedence = binary_precedence(operator)
  while operator_codes.length() > 0 {
    let top_code = operator_codes[operator_codes.length() - 1]
    let should_reduce = if top_code == pending_group_code {
      false
    } else if top_code < pending_binary_base {
      true
    } else {
      let top_operator = binary_operator_from_code(top_code)
      if is_comparison_operator(operator) &&
        is_comparison_operator(top_operator) {
        return Err(expression_failure(ChainedComparison(offset)))
      }
      let top_precedence = binary_precedence(top_operator)
      top_precedence > precedence ||
      (top_precedence == precedence && is_left_associative(operator))
    }
    guard should_reduce else { break }
    match reduce_top(values, operator_codes, operator_offsets) {
      Ok(_) => ()
      Err(error) => return Err(error)
    }
  }
  operator_codes.push(binary_operator_code(operator))
  operator_offsets.push(offset)
  Ok(())
}

///|
fn reduce_for_is(
  values : Array[Expr],
  operator_codes : Array[Int],
  operator_offsets : Array[UInt64],
  offset : UInt64,
) -> Result[Unit, RecoveryFailure] {
  while operator_codes.length() > 0 {
    let top_code = operator_codes[operator_codes.length() - 1]
    if top_code == pending_group_code {
      break
    }
    if top_code >= pending_binary_base {
      let top_operator = binary_operator_from_code(top_code)
      if is_comparison_operator(top_operator) {
        return Err(expression_failure(ChainedComparison(offset)))
      }
      if binary_precedence(top_operator) < 8 {
        break
      }
    }
    match reduce_top(values, operator_codes, operator_offsets) {
      Ok(_) => ()
      Err(error) => return Err(error)
    }
  }
  Ok(())
}

///|
fn finish_expression(
  values : Array[Expr],
  operator_codes : Array[Int],
  operator_offsets : Array[UInt64],
) -> Result[Expr, RecoveryFailure] {
  while operator_codes.length() > 0 {
    let top_index = operator_codes.length() - 1
    if operator_codes[top_index] == pending_group_code {
      return Err(expression_failure(UnclosedGroup(operator_offsets[top_index])))
    }
    match reduce_top(values, operator_codes, operator_offsets) {
      Ok(_) => ()
      Err(error) => return Err(error)
    }
  }
  if values.length() == 1 {
    Ok(values[0])
  } else {
    Err(expression_failure(InvalidOperatorState(0UL)))
  }
}

///|
fn Parser::consume_right_paren(self : Parser) -> Bool {
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
fn Parser::parse_call_arguments(
  self : Parser,
  open_offset : UInt64,
) -> Result[Array[Expr], RecoveryFailure] {
  let arguments : Array[Expr] = []
  self.skip_newlines()
  if self.consume_right_paren() {
    return Ok(arguments)
  }
  while true {
    let argument = match self.parse_expression_recoverable() {
      Ok(expression) => expression
      Err(error) => return Err(error)
    }
    arguments.push(argument)
    self.skip_newlines()
    match self.peek_token() {
      None => return Err(expression_failure(UnclosedCall(open_offset)))
      Some(token) =>
        match token.kind() {
          @tokenizer.Symbol(@tokenizer.Comma) => {
            self.consume_lookahead()
            self.skip_newlines()
            if self.consume_right_paren() {
              return Ok(arguments)
            }
          }
          @tokenizer.Symbol(@tokenizer.RightParen) => {
            self.consume_lookahead()
            return Ok(arguments)
          }
          _ =>
            return Err(expression_failure(ExpectedCallDelimiter(Some(token))))
        }
    }
  } nobreak {
    abort("unreachable call argument parser termination")
  }
}

///|
fn Parser::parse_field_access(
  self : Parser,
  values : Array[Expr],
  dot_offset : UInt64,
) -> Result[Unit, RecoveryFailure] {
  self.skip_newlines()
  let field = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Identifier(name) => {
          self.consume_lookahead()
          name
        }
        _ => return Err(expression_failure(ExpectedFieldName(Some(token))))
      }
    None => return Err(expression_failure(ExpectedFieldName(None)))
  }
  let target = match pop_expression(values) {
    Some(value) => value
    None => return Err(expression_failure(MissingOperand(dot_offset)))
  }
  match target {
    ImportAliasExpr(_, _) =>
      values.push(QualifiedExpr(target, field, dot_offset))
    _ => values.push(FieldExpr(target, field, dot_offset))
  }
  Ok(())
}

///|
fn Parser::parse_qualified_access(
  self : Parser,
  values : Array[Expr],
  separator_offset : UInt64,
) -> Result[Unit, RecoveryFailure] {
  self.skip_newlines()
  let property = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Identifier(name) => {
          self.consume_lookahead()
          name
        }
        _ => return Err(expression_failure(ExpectedQualifiedName(Some(token))))
      }
    None => return Err(expression_failure(ExpectedQualifiedName(None)))
  }
  let target = match pop_expression(values) {
    Some(value) => value
    None => return Err(expression_failure(MissingOperand(separator_offset)))
  }
  values.push(QualifiedExpr(target, property, separator_offset))
  Ok(())
}

///|
fn Parser::parse_index_access(
  self : Parser,
  values : Array[Expr],
  open_offset : UInt64,
) -> Result[Unit, RecoveryFailure] {
  let index = match self.parse_expression_recoverable() {
    Ok(expression) => expression
    Err(error) => return Err(error)
  }
  self.skip_newlines()
  match self.peek_token() {
    None => return Err(expression_failure(UnclosedIndex(open_offset)))
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightBracket) => self.consume_lookahead()
        _ =>
          return Err(
            expression_failure(ExpectedRightBracket(Some(token), open_offset)),
          )
      }
  }
  let target = match pop_expression(values) {
    Some(value) => value
    None => return Err(expression_failure(MissingOperand(open_offset)))
  }
  values.push(IndexExpr(target, index, open_offset))
  Ok(())
}

///|
fn Parser::consume_right_bracket(self : Parser) -> Bool {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightBracket) => {
          self.consume_lookahead()
          true
        }
        _ => false
      }
    None => false
  }
}

///|
fn Parser::parse_array_literal(
  self : Parser,
  open_offset : UInt64,
) -> Result[Expr, RecoveryFailure] {
  let elements : Array[Expr] = []
  self.skip_newlines()
  if self.consume_right_bracket() {
    return Ok(ArrayExpr(elements, open_offset))
  }
  while true {
    let element = match self.parse_expression_recoverable() {
      Ok(value) => value
      Err(error) => return Err(error.inside_bracket())
    }
    elements.push(element)
    self.skip_newlines()
    match self.peek_token() {
      None => return Err(expression_failure(UnclosedArray(open_offset)))
      Some(token) =>
        match token.kind() {
          @tokenizer.Symbol(@tokenizer.Comma) => {
            self.consume_lookahead()
            self.skip_newlines()
            if self.consume_right_bracket() {
              return Ok(ArrayExpr(elements, open_offset))
            }
            if self.peek_token() is None {
              return Err(expression_failure(UnclosedArray(open_offset)))
            }
          }
          @tokenizer.Symbol(@tokenizer.RightBracket) => {
            self.consume_lookahead()
            return Ok(ArrayExpr(elements, open_offset))
          }
          _ =>
            return Err(
              expression_failure(
                ExpectedArrayDelimiter(Some(token), open_offset),
              ),
            )
        }
    }
  } nobreak {
    abort("unreachable array literal parser termination")
  }
}

///|
fn Parser::consume_right_brace(self : Parser) -> Bool {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightBrace) => {
          self.consume_lookahead()
          true
        }
        _ => false
      }
    None => false
  }
}

///|
fn Parser::parse_object_fields(
  self : Parser,
  open_offset : UInt64,
) -> Result[Array[ObjectField], RecoveryFailure] {
  let fields : Array[ObjectField] = []
  self.skip_newlines()
  if self.consume_right_brace() {
    return Ok(fields)
  }
  while true {
    let (name, field_offset) = match self.peek_token() {
      None => return Err(expression_failure(UnclosedObject(open_offset)))
      Some(token) =>
        match token.kind() {
          @tokenizer.Error(error) => {
            let offset = token.offset()
            self.consume_lookahead()
            return Err(expression_failure(LexicalError(error, offset)))
          }
          @tokenizer.Identifier(name) => {
            let offset = token.offset()
            self.consume_lookahead()
            (name, offset)
          }
          _ =>
            return Err(
              expression_failure(ExpectedObjectField(Some(token), open_offset)),
            )
        }
    }
    match self.peek_token() {
      None => return Err(expression_failure(UnclosedObject(open_offset)))
      Some(token) =>
        match token.kind() {
          @tokenizer.Error(error) => {
            let offset = token.offset()
            self.consume_lookahead()
            return Err(expression_failure(LexicalError(error, offset)))
          }
          @tokenizer.Symbol(@tokenizer.Colon) => self.consume_lookahead()
          _ =>
            return Err(
              expression_failure(ExpectedObjectColon(Some(token), field_offset)),
            )
        }
    }
    let value = match self.parse_expression_recoverable() {
      Ok(expression) => expression
      Err(error) => return Err(error)
    }
    fields.push({ name, value, offset: field_offset })
    match self.peek_token() {
      None => return Err(expression_failure(UnclosedObject(open_offset)))
      Some(token) =>
        match token.kind() {
          @tokenizer.Newline => self.skip_newlines()
          @tokenizer.Error(error) => {
            let offset = token.offset()
            self.consume_lookahead()
            return Err(expression_failure(LexicalError(error, offset)))
          }
          _ =>
            return Err(
              expression_failure(
                ExpectedObjectFieldNewline(Some(token), field_offset),
              ),
            )
        }
    }
    if self.consume_right_brace() {
      return Ok(fields)
    }
  } nobreak {
    abort("unreachable object parser termination")
  }
}

///|
fn Parser::parse_object_literal(
  self : Parser,
  open_offset : UInt64,
) -> Result[Expr, RecoveryFailure] {
  match self.parse_object_fields(open_offset) {
    Ok(fields) => Ok(ObjectExpr(fields, open_offset))
    Err(error) => Err(error.inside_brace())
  }
}

///|
fn lambda_header_failure(
  failure : RecoveryFailure,
  lambda_offset : UInt64,
) -> RecoveryFailure {
  let fence = failure.fence()
  let error = match failure.declaration_error() {
    ExpectedDeclarationSyntax(expectation, token) =>
      ExpectedLambdaSyntax(expectation, token, lambda_offset)
    DeclarationLexicalError(error, offset) => LexicalError(error, offset)
    UnexpectedTypeCloser(offset) =>
      UnexpectedLambdaTypeCloser(offset, lambda_offset)
    _ => InvalidLambdaSyntax(lambda_offset)
  }
  expression_failure_with_fence(error, fence)
}

///|
fn Parser::parse_lambda_expression(
  self : Parser,
  lambda_offset : UInt64,
) -> Result[Expr, RecoveryFailure] {
  guard self.consume_left_paren() else {
    return Err(
      lambda_header_failure(self.declaration_error(LeftParen), lambda_offset),
    )
  }
  let parameters = match self.parse_parameters() {
    Ok(value) => value
    Err(error) => return Err(lambda_header_failure(error, lambda_offset))
  }
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Arrow) => self.consume_lookahead()
        _ =>
          return Err(
            lambda_header_failure(self.declaration_error(Arrow), lambda_offset),
          )
      }
    None =>
      return Err(
        lambda_header_failure(self.declaration_error(Arrow), lambda_offset),
      )
  }
  let return_type = match self.parse_type() {
    Ok(value) => value
    Err(error) => return Err(lambda_header_failure(error, lambda_offset))
  }
  let open_offset = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftBrace) => {
          self.consume_lookahead()
          token.offset()
        }
        _ =>
          return Err(
            lambda_header_failure(
              self.declaration_error(LeftBrace),
              lambda_offset,
            ),
          )
      }
    None =>
      return Err(
        lambda_header_failure(self.declaration_error(LeftBrace), lambda_offset),
      )
  }
  let body = match self.parse_block_after_left_brace(open_offset) {
    Ok(value) => value
    Err(error) => return Err(error.inside_brace())
  }
  Ok(LambdaExpr(parameters, return_type, body, lambda_offset))
}

///|
/// Parses one expression in a single forward pass. The state alternates
/// between value-seeking and binary-operator-seeking modes. A token that does
/// not continue the expression remains in the parser's one-token lookahead.
fn finish_expression_with_groups(
  nested_groups : Int,
  values : Array[Expr],
  operator_codes : Array[Int],
  operator_offsets : Array[UInt64],
) -> Result[Expr, RecoveryFailure] {
  match finish_expression(values, operator_codes, operator_offsets) {
    Ok(value) => Ok(value)
    Err(error) => Err(error.inside_parentheses_count(nested_groups))
  }
}

///|
fn Parser::parse_expression_context(
  self : Parser,
  stop_bits : Int,
) -> Result[Expr, RecoveryFailure] {
  let values : Array[Expr] = []
  let operator_codes : Array[Int] = []
  let operator_offsets : Array[UInt64] = []
  let group_value_starts : Array[Int] = []
  let group_element_counts : Array[Int] = []
  let group_offsets : Array[UInt64] = []
  let mut mode = SeekingUnaryValue
  let mut nested_groups = 0
  while true {
    match mode {
      SeekingUnaryValue =>
        match self.peek_token() {
          None =>
            return Err(
              expression_failure(ExpectedValue(None)).inside_parentheses_count(
                nested_groups,
              ),
            )
          Some(token) => {
            let offset = token.offset()
            match token.kind() {
              @tokenizer.Newline => self.consume_lookahead()
              @tokenizer.Error(error) => {
                self.consume_lookahead()
                return Err(
                  expression_failure(LexicalError(error, offset)).inside_parentheses_count(
                    nested_groups,
                  ),
                )
              }
              @tokenizer.Keyword(@tokenizer.Fn) => {
                self.consume_lookahead()
                let expression = match self.parse_lambda_expression(offset) {
                  Ok(value) => value
                  Err(error) =>
                    return Err(error.inside_parentheses_count(nested_groups))
                }
                values.push(expression)
                mode = SeekingBinaryOperator
              }
              @tokenizer.Keyword(@tokenizer.If) => {
                self.consume_lookahead()
                let expression = match self.parse_if_expression(offset) {
                  Ok(value) => value
                  Err(error) =>
                    return Err(error.inside_parentheses_count(nested_groups))
                }
                values.push(expression)
                mode = SeekingBinaryOperator
              }
              @tokenizer.Keyword(@tokenizer.Match) => {
                self.consume_lookahead()
                let expression = match self.parse_match_expression(offset) {
                  Ok(value) => value
                  Err(error) =>
                    return Err(error.inside_parentheses_count(nested_groups))
                }
                values.push(expression)
                mode = SeekingBinaryOperator
              }
              @tokenizer.Keyword(@tokenizer.While) => {
                self.consume_lookahead()
                let expression = match self.parse_while_expression(offset) {
                  Ok(value) => value
                  Err(error) =>
                    return Err(error.inside_parentheses_count(nested_groups))
                }
                values.push(expression)
                mode = SeekingBinaryOperator
              }
              @tokenizer.Keyword(@tokenizer.For) => {
                self.consume_lookahead()
                let expression = match self.parse_for_expression(offset) {
                  Ok(value) => value
                  Err(error) =>
                    return Err(error.inside_parentheses_count(nested_groups))
                }
                values.push(expression)
                mode = SeekingBinaryOperator
              }
              @tokenizer.Keyword(@tokenizer.Return) => {
                self.consume_lookahead()
                let value = match self.peek_token() {
                  None => None
                  Some(next) =>
                    match next.kind() {
                      @tokenizer.Newline
                      | @tokenizer.Symbol(@tokenizer.RightBrace) => None
                      _ =>
                        match self.parse_expression_recoverable() {
                          Ok(expression) => Some(expression)
                          Err(error) =>
                            return Err(
                              error.inside_parentheses_count(nested_groups),
                            )
                        }
                    }
                }
                values.push(ReturnExpr(value, offset))
                mode = SeekingBinaryOperator
              }
              @tokenizer.Keyword(@tokenizer.Break) => {
                self.consume_lookahead()
                let expression = match self.parse_break_expression(offset) {
                  Ok(value) => value
                  Err(error) =>
                    return Err(error.inside_parentheses_count(nested_groups))
                }
                values.push(expression)
                mode = SeekingBinaryOperator
              }
              @tokenizer.Keyword(@tokenizer.Continue) => {
                self.consume_lookahead()
                let expression = match self.parse_continue_expression(offset) {
                  Ok(value) => value
                  Err(error) =>
                    return Err(error.inside_parentheses_count(nested_groups))
                }
                values.push(expression)
                mode = SeekingBinaryOperator
              }
              @tokenizer.Symbol(@tokenizer.RightParen) if nested_groups > 0 &&
                group_element_counts[group_element_counts.length() - 1] == 0 &&
                values.length() == group_value_starts[group_value_starts.length() - 1] => {
                let start = group_value_starts.pop().unwrap()
                ignore(group_element_counts.pop())
                let open_offset = group_offsets.pop().unwrap()
                if values.length() != start ||
                  operator_codes.length() == 0 ||
                  operator_codes[operator_codes.length() - 1] != pending_group_code {
                  return Err(
                    expression_failure(InvalidOperatorState(offset)).inside_parentheses_count(
                      nested_groups,
                    ),
                  )
                }
                ignore(operator_codes.pop())
                ignore(operator_offsets.pop())
                values.push(BlockExpr({ items: [], offset: open_offset }))
                self.consume_lookahead()
                nested_groups -= 1
                mode = SeekingBinaryOperator
              }
              @tokenizer.Symbol(@tokenizer.RightParen) if nested_groups > 0 &&
                group_element_counts[group_element_counts.length() - 1] > 0 => {
                let frame = group_value_starts.length() - 1
                let start = group_value_starts.pop().unwrap()
                let arity = group_element_counts.pop().unwrap()
                let open_offset = group_offsets.pop().unwrap()
                if arity < 2 || arity > 32 {
                  return Err(
                    expression_failure(InvalidProductArity(arity, open_offset)).inside_parentheses_count(
                      nested_groups,
                    ),
                  )
                }
                if values.length() != start + arity ||
                  operator_codes.length() == 0 ||
                  operator_codes[operator_codes.length() - 1] !=
                  pending_group_code {
                  return Err(
                    expression_failure(InvalidOperatorState(offset)).inside_parentheses_count(
                      nested_groups,
                    ),
                  )
                }
                ignore(operator_codes.pop())
                ignore(operator_offsets.pop())
                let elements : Array[Expr] = []
                for index in start..<values.length() {
                  elements.push(values[index])
                }
                values.truncate(start)
                values.push(ProductExpr(elements, open_offset))
                ignore(frame)
                self.consume_lookahead()
                nested_groups -= 1
                mode = SeekingBinaryOperator
              }
              @tokenizer.Symbol(symbol) =>
                match prefix_operator(symbol) {
                  Some(operator) => {
                    self.consume_lookahead()
                    operator_codes.push(prefix_operator_code(operator))
                    operator_offsets.push(offset)
                  }
                  None =>
                    match symbol {
                      @tokenizer.LeftParen => {
                        self.consume_lookahead()
                        operator_codes.push(pending_group_code)
                        operator_offsets.push(offset)
                        group_value_starts.push(values.length())
                        group_element_counts.push(0)
                        group_offsets.push(offset)
                        nested_groups += 1
                      }
                      @tokenizer.LeftBracket => {
                        self.consume_lookahead()
                        let array = match self.parse_array_literal(offset) {
                          Ok(value) => value
                          Err(error) =>
                            return Err(
                              error.inside_parentheses_count(nested_groups),
                            )
                        }
                        values.push(array)
                        mode = SeekingBinaryOperator
                      }
                      @tokenizer.LeftBrace => {
                        if expression_stops_at(
                            stop_bits, expression_stop_left_brace,
                          ) &&
                          nested_groups == 0 {
                          return Err(
                            expression_failure(ExpectedValue(Some(token))).inside_parentheses_count(
                              nested_groups,
                            ),
                          )
                        }
                        self.consume_lookahead()
                        let object = match self.parse_object_literal(offset) {
                          Ok(value) => value
                          Err(error) =>
                            return Err(
                              error.inside_parentheses_count(nested_groups),
                            )
                        }
                        values.push(object)
                        mode = SeekingBinaryOperator
                      }
                      _ =>
                        return Err(
                          expression_failure(ExpectedValue(Some(token))).inside_parentheses_count(
                            nested_groups,
                          ),
                        )
                    }
                }
              _ =>
                match token_expression(token) {
                  Some(expression) => {
                    self.consume_lookahead()
                    values.push(expression)
                    mode = SeekingBinaryOperator
                  }
                  None =>
                    return Err(
                      expression_failure(ExpectedValue(Some(token))).inside_parentheses_count(
                        nested_groups,
                      ),
                    )
                }
            }
          }
        }
      SeekingBinaryOperator =>
        match self.peek_token() {
          None =>
            return finish_expression_with_groups(
              nested_groups, values, operator_codes, operator_offsets,
            )
          Some(token) => {
            let offset = token.offset()
            match token.kind() {
              @tokenizer.Newline =>
                if nested_groups > 0 {
                  self.consume_lookahead()
                } else {
                  return finish_expression_with_groups(
                    nested_groups, values, operator_codes, operator_offsets,
                  )
                }
              @tokenizer.Error(error) => {
                self.consume_lookahead()
                return Err(
                  expression_failure(LexicalError(error, offset)).inside_parentheses_count(
                    nested_groups,
                  ),
                )
              }
              @tokenizer.Keyword(@tokenizer.Is) => {
                self.consume_lookahead()
                match
                  reduce_for_is(
                    values, operator_codes, operator_offsets, offset,
                  ) {
                  Ok(_) => ()
                  Err(error) =>
                    return Err(error.inside_parentheses_count(nested_groups))
                }
                let scrutinee = match pop_expression(values) {
                  Some(value) => value
                  None =>
                    return Err(
                      expression_failure(MissingOperand(offset)).inside_parentheses_count(
                        nested_groups,
                      ),
                    )
                }
                let pattern = match
                  self.parse_pattern_context_with_stop(
                    false,
                    expression_stops_at(stop_bits, expression_stop_left_brace) &&
                    nested_groups == 0,
                  ) {
                  Ok(value) => value
                  Err(error) =>
                    return Err(error.inside_parentheses_count(nested_groups))
                }
                values.push(IsExpr(scrutinee, pattern, offset))
              }
              @tokenizer.Symbol(@tokenizer.LeftBrace) if expression_stops_at(
                  stop_bits, expression_stop_left_brace,
                ) &&
                nested_groups == 0 =>
                return finish_expression_with_groups(
                  nested_groups, values, operator_codes, operator_offsets,
                )
              @tokenizer.Symbol(@tokenizer.LeftParen) => {
                self.consume_lookahead()
                let arguments = match self.parse_call_arguments(offset) {
                  Ok(value) => value
                  Err(error) => return Err(error.inside_parenthesis())
                }
                let callee = match pop_expression(values) {
                  Some(value) => value
                  None =>
                    return Err(
                      expression_failure(MissingOperand(offset)).inside_parentheses_count(
                        nested_groups,
                      ),
                    )
                }
                values.push(CallExpr(callee, arguments, offset))
              }
              @tokenizer.Symbol(@tokenizer.Dot) => {
                self.consume_lookahead()
                match self.parse_field_access(values, offset) {
                  Ok(_) => ()
                  Err(error) =>
                    return Err(error.inside_parentheses_count(nested_groups))
                }
              }
              @tokenizer.Symbol(@tokenizer.DoubleColon) => {
                self.consume_lookahead()
                self.skip_newlines()
                match self.peek_token() {
                  Some(next) =>
                    match next.kind() {
                      @tokenizer.Symbol(@tokenizer.LeftBrace) => {
                        self.consume_lookahead()
                        let fields = match
                          self.parse_object_fields(next.offset()) {
                          Ok(value) => value
                          Err(error) => return Err(error.inside_brace())
                        }
                        let target = match pop_expression(values) {
                          Some(value) => value
                          None =>
                            return Err(
                              expression_failure(MissingOperand(offset)).inside_parentheses_count(
                                nested_groups,
                              ),
                            )
                        }
                        values.push(
                          ConstructExpr(target, fields, next.offset()),
                        )
                      }
                      @tokenizer.Symbol(@tokenizer.Less) => {
                        self.consume_lookahead()
                        let type_arguments = match
                          self.parse_explicit_type_arguments_after_less() {
                          Ok(value) => value
                          Err(error) => return Err(error.inside_angle())
                        }
                        self.skip_newlines()
                        let call_offset = match self.peek_token() {
                          Some(call) =>
                            match call.kind() {
                              @tokenizer.Symbol(@tokenizer.LeftParen) => {
                                self.consume_lookahead()
                                call.offset()
                              }
                              _ =>
                                return Err(
                                  expression_failure(
                                    ExpectedCallDelimiter(Some(call)),
                                  ).inside_parentheses_count(nested_groups),
                                )
                            }
                          None =>
                            return Err(
                              expression_failure(ExpectedCallDelimiter(None)).inside_parentheses_count(
                                nested_groups,
                              ),
                            )
                        }
                        let arguments = match
                          self.parse_call_arguments(call_offset) {
                          Ok(value) => value
                          Err(error) => return Err(error.inside_parenthesis())
                        }
                        let callee = match pop_expression(values) {
                          Some(value) => value
                          None =>
                            return Err(
                              expression_failure(MissingOperand(offset)).inside_parentheses_count(
                                nested_groups,
                              ),
                            )
                        }
                        values.push(
                          ExplicitTypeCallExpr(
                            callee, type_arguments, arguments, call_offset,
                          ),
                        )
                      }
                      _ =>
                        match self.parse_qualified_access(values, offset) {
                          Ok(_) => ()
                          Err(error) =>
                            return Err(
                              error.inside_parentheses_count(nested_groups),
                            )
                        }
                    }
                  None =>
                    return Err(
                      expression_failure(ExpectedQualifiedName(None)).inside_parentheses_count(
                        nested_groups,
                      ),
                    )
                }
              }
              @tokenizer.Symbol(@tokenizer.LeftBracket) => {
                self.consume_lookahead()
                match self.parse_index_access(values, offset) {
                  Ok(_) => ()
                  Err(error) => return Err(error.inside_bracket())
                }
              }
              @tokenizer.Symbol(@tokenizer.Comma) if nested_groups > 0 => {
                while operator_codes.length() > 0 &&
                      operator_codes[operator_codes.length() - 1] !=
                      pending_group_code {
                  match reduce_top(values, operator_codes, operator_offsets) {
                    Ok(_) => ()
                    Err(error) =>
                      return Err(error.inside_parentheses_count(nested_groups))
                  }
                }
                let frame = group_value_starts.length() - 1
                let completed = group_element_counts[frame] + 1
                if values.length() != group_value_starts[frame] + completed {
                  return Err(
                    expression_failure(InvalidOperatorState(offset)).inside_parentheses_count(
                      nested_groups,
                    ),
                  )
                }
                group_element_counts[frame] = completed
                self.consume_lookahead()
                self.skip_newlines()
                mode = SeekingUnaryValue
              }
              @tokenizer.Symbol(@tokenizer.RightParen) if nested_groups > 0 => {
                self.consume_lookahead()
                while operator_codes.length() > 0 &&
                      operator_codes[operator_codes.length() - 1] !=
                      pending_group_code {
                  match reduce_top(values, operator_codes, operator_offsets) {
                    Ok(_) => ()
                    Err(error) =>
                      return Err(error.inside_parentheses_count(nested_groups))
                  }
                }
                if operator_codes.length() == 0 {
                  return Err(
                    expression_failure(InvalidOperatorState(offset)).inside_parentheses_count(
                      nested_groups,
                    ),
                  )
                }
                ignore(operator_codes.pop())
                ignore(operator_offsets.pop())
                let frame = group_value_starts.length() - 1
                let start = group_value_starts.pop().unwrap()
                let prior = group_element_counts.pop().unwrap()
                let open_offset = group_offsets.pop().unwrap()
                if prior > 0 {
                  let arity = prior + 1
                  if arity < 2 || arity > 32 {
                    return Err(
                      expression_failure(
                        InvalidProductArity(arity, open_offset),
                      ).inside_parentheses_count(nested_groups),
                    )
                  }
                  if values.length() != start + arity {
                    return Err(
                      expression_failure(InvalidOperatorState(offset)).inside_parentheses_count(
                        nested_groups,
                      ),
                    )
                  }
                  let elements : Array[Expr] = []
                  for index in start..<values.length() {
                    elements.push(values[index])
                  }
                  values.truncate(start)
                  values.push(ProductExpr(elements, open_offset))
                } else if values.length() != start + 1 {
                  return Err(
                    expression_failure(InvalidOperatorState(offset)).inside_parentheses_count(
                      nested_groups,
                    ),
                  )
                }
                ignore(frame)
                nested_groups -= 1
              }
              @tokenizer.Symbol(symbol) =>
                match binary_operator(symbol) {
                  Some(operator) => {
                    self.consume_lookahead()
                    match
                      push_binary_operator(
                        values, operator_codes, operator_offsets, operator, offset,
                      ) {
                      Ok(_) => mode = SeekingUnaryValue
                      Err(error) =>
                        return Err(
                          error.inside_parentheses_count(nested_groups),
                        )
                    }
                  }
                  None =>
                    return finish_expression_with_groups(
                      nested_groups, values, operator_codes, operator_offsets,
                    )
                }
              _ =>
                return finish_expression_with_groups(
                  nested_groups, values, operator_codes, operator_offsets,
                )
            }
          }
        }
    }
  } nobreak {
    abort("unreachable expression parser termination")
  }
}

///|
fn Parser::parse_expression_before_block(
  self : Parser,
) -> Result[Expr, RecoveryFailure] {
  self.parse_expression_context(expression_stop_left_brace)
}

///|
pub fn Parser::parse_expression(self : Parser) -> Result[Expr, ExpressionError] {
  match self.parse_expression_recoverable() {
    Ok(value) => Ok(value)
    Err(failure) => Err(failure.expression_error())
  }
}

///|
fn Parser::parse_expression_recoverable(
  self : Parser,
) -> Result[Expr, RecoveryFailure] {
  self.parse_expression_context(0)
}
