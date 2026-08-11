///|
/// Prefix operators applied while the expression parser is seeking a value.
pub enum PrefixOperator {
  Positive
  Negative
  LogicalNot
} derive(Eq, Debug)

///|
/// Binary operators recognized by the initial Dew precedence table.
pub enum BinaryOperator {
  LogicalOr
  LogicalAnd
  BitOr
  BitXor
  BitAnd
  Equal
  NotEqual
  Less
  LessEqual
  Greater
  GreaterEqual
  ShiftLeft
  ShiftRight
  Add
  Subtract
  Multiply
  Divide
  Remainder
  Exponentiate
} derive(Eq, Debug)

///|
pub struct ObjectField {
  name : String
  value : Expr
  offset : UInt64
} derive(Eq, Debug)

///|
/// Expression nodes are one enum allocation each. Offsets identify the token
/// that introduced the node or operator.
pub enum Expr {
  I8Expr(UInt64, UInt64)
  I16Expr(UInt64, UInt64)
  I32Expr(UInt64, UInt64)
  I64Expr(UInt64, UInt64)
  U8Expr(UInt64, UInt64)
  U16Expr(UInt64, UInt64)
  U32Expr(UInt64, UInt64)
  U64Expr(UInt64, UInt64)
  F32Expr(Float, UInt64)
  F64Expr(Double, UInt64)
  BoolExpr(Bool, UInt64)
  StringExpr(Bytes, UInt64)
  BytesExpr(Bytes, UInt64)
  NameExpr(String, UInt64)
  ImportAliasExpr(String, UInt64)
  LambdaExpr(Array[FnParameter], TypeExpr, Block, UInt64)
  ObjectExpr(Array[ObjectField], UInt64)
  ConstructExpr(Expr, Array[ObjectField], UInt64)
  BlockExpr(Block)
  IfExpr(Expr, Block, Expr?, UInt64)
  MatchExpr(Expr, Array[PatternArm], UInt64)
  IsExpr(Expr, Pattern, UInt64)
  WhileExpr(Expr, Array[PatternArm], UInt64)
  BreakExpr(Expr, UInt64)
  ContinueExpr(Expr, UInt64)
  PrefixExpr(PrefixOperator, Expr, UInt64)
  BinaryExpr(BinaryOperator, Expr, Expr, UInt64)
  CallExpr(Expr, Array[Expr], UInt64)
  FieldExpr(Expr, String, UInt64)
  QualifiedExpr(Expr, String, UInt64)
  IndexExpr(Expr, Expr, UInt64)
} derive(Eq, Debug)

///|
pub fn Expr::desugar_is(self : Expr) -> Expr {
  match self {
    IsExpr(scrutinee, pattern, offset) =>
      MatchExpr(
        scrutinee,
        [
          {
            pattern,
            guard_condition: None,
            body: BoolExpr(true, offset),
            offset: pattern.offset(),
          },
          {
            pattern: WildcardPattern(offset),
            guard_condition: None,
            body: BoolExpr(false, offset),
            offset,
          },
        ],
        offset,
      )
    _ => self
  }
}

///|
pub fn Expr::offset(self : Expr) -> UInt64 {
  match self {
    I8Expr(_, offset)
    | I16Expr(_, offset)
    | I32Expr(_, offset)
    | I64Expr(_, offset)
    | U8Expr(_, offset)
    | U16Expr(_, offset)
    | U32Expr(_, offset)
    | U64Expr(_, offset)
    | F32Expr(_, offset)
    | F64Expr(_, offset)
    | BoolExpr(_, offset)
    | StringExpr(_, offset)
    | BytesExpr(_, offset)
    | NameExpr(_, offset)
    | ImportAliasExpr(_, offset)
    | LambdaExpr(_, _, _, offset)
    | ObjectExpr(_, offset)
    | ConstructExpr(_, _, offset)
    | IfExpr(_, _, _, offset)
    | MatchExpr(_, _, offset)
    | IsExpr(_, _, offset)
    | WhileExpr(_, _, offset)
    | BreakExpr(_, offset)
    | ContinueExpr(_, offset)
    | PrefixExpr(_, _, offset)
    | BinaryExpr(_, _, _, offset)
    | CallExpr(_, _, offset)
    | FieldExpr(_, _, offset)
    | QualifiedExpr(_, _, offset)
    | IndexExpr(_, _, offset) => offset
    BlockExpr(block) => block.offset
  }
}

///|
/// A deterministic expression-parser failure. The parser never rewinds after
/// producing one of these errors.
pub enum ExpressionError {
  ExpectedValue(@tokenizer.Token?)
  ExpectedCallDelimiter(@tokenizer.Token?)
  ExpectedFieldName(@tokenizer.Token?)
  ExpectedQualifiedName(@tokenizer.Token?)
  ExpectedRightBracket(@tokenizer.Token?, UInt64)
  ExpectedObjectField(@tokenizer.Token?, UInt64)
  ExpectedObjectColon(@tokenizer.Token?, UInt64)
  ExpectedObjectFieldNewline(@tokenizer.Token?, UInt64)
  ExpectedBlockNewline(@tokenizer.Token?, UInt64)
  ExpectedBlockItemNewline(@tokenizer.Token?, UInt64)
  ExpectedAssignmentTarget(@tokenizer.Token, UInt64)
  ExpectedBlockBindingName(@tokenizer.Token?)
  ExpectedBlockEqual(@tokenizer.Token?)
  ExpectedIfBody(@tokenizer.Token?, UInt64)
  ExpectedElseBranch(@tokenizer.Token?, UInt64)
  ExpectedMatchBody(@tokenizer.Token?, UInt64)
  ExpectedMatchBodyNewline(@tokenizer.Token?, UInt64)
  ExpectedMatchArmArrow(@tokenizer.Token?, UInt64)
  ExpectedMatchArmNewline(@tokenizer.Token?, UInt64)
  ExpectedWhileBody(@tokenizer.Token?, UInt64)
  ExpectedWhileBodyNewline(@tokenizer.Token?, UInt64)
  ExpectedWhileArmArrow(@tokenizer.Token?, UInt64)
  ExpectedWhileArmNewline(@tokenizer.Token?, UInt64)
  ExpectedBreakValue(@tokenizer.Token?, UInt64)
  ExpectedContinueValue(@tokenizer.Token?, UInt64)
  ExpectedLambdaSyntax(DeclarationExpectation, @tokenizer.Token?, UInt64)
  UnexpectedLambdaTypeCloser(UInt64, UInt64)
  InvalidLambdaSyntax(UInt64)
  MatchPatternError(PatternError)
  UnclosedObject(UInt64)
  UnclosedBlock(UInt64)
  UnclosedMatch(UInt64)
  UnclosedWhile(UInt64)
  ChainedComparison(UInt64)
  UnclosedGroup(UInt64)
  UnclosedCall(UInt64)
  UnclosedIndex(UInt64)
  MissingOperand(UInt64)
  LexicalError(@tokenizer.LexError, UInt64)
  InvalidOperatorState(UInt64)
} derive(Eq, Debug)

///|
fn optional_expression_token_offset(
  token : @tokenizer.Token?,
  fallback : UInt64,
) -> UInt64 {
  match token {
    Some(value) => value.offset()
    None => fallback
  }
}

///|
pub fn ExpressionError::offset(self : ExpressionError) -> UInt64 {
  match self {
    ExpectedValue(token)
    | ExpectedCallDelimiter(token)
    | ExpectedFieldName(token)
    | ExpectedQualifiedName(token)
    | ExpectedBlockBindingName(token)
    | ExpectedBlockEqual(token) => optional_expression_token_offset(token, 0UL)
    ExpectedRightBracket(token, fallback)
    | ExpectedObjectField(token, fallback)
    | ExpectedObjectColon(token, fallback)
    | ExpectedObjectFieldNewline(token, fallback)
    | ExpectedBlockNewline(token, fallback)
    | ExpectedBlockItemNewline(token, fallback)
    | ExpectedIfBody(token, fallback)
    | ExpectedElseBranch(token, fallback)
    | ExpectedMatchBody(token, fallback)
    | ExpectedMatchBodyNewline(token, fallback)
    | ExpectedMatchArmArrow(token, fallback)
    | ExpectedMatchArmNewline(token, fallback)
    | ExpectedWhileBody(token, fallback)
    | ExpectedWhileBodyNewline(token, fallback)
    | ExpectedWhileArmArrow(token, fallback)
    | ExpectedWhileArmNewline(token, fallback)
    | ExpectedBreakValue(token, fallback)
    | ExpectedContinueValue(token, fallback)
    | ExpectedLambdaSyntax(_, token, fallback) =>
      optional_expression_token_offset(token, fallback)
    ExpectedAssignmentTarget(token, _) => token.offset()
    UnexpectedLambdaTypeCloser(offset, _)
    | InvalidLambdaSyntax(offset)
    | UnclosedObject(offset)
    | UnclosedBlock(offset)
    | UnclosedMatch(offset)
    | UnclosedWhile(offset)
    | ChainedComparison(offset)
    | UnclosedGroup(offset)
    | UnclosedCall(offset)
    | UnclosedIndex(offset)
    | MissingOperand(offset)
    | LexicalError(_, offset)
    | InvalidOperatorState(offset) => offset
    MatchPatternError(error) => error.offset()
  }
}
