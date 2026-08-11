///|
/// Reserved Dew words recognized directly by the tokenizer.
pub enum Keyword {
  Fn
  Test
  Pub
  Builtin
  Foreign
  Impl
  Trait
  For
  Enum
  Struct
  Type
  Let
  Using
  Mut
  If
  Else
  Match
  Is
  While
  Loop
  Return
  Defer
  Break
  Continue
  True
  False
  As
  In
  Where
  Open
  Import
  Export
  Package
} derive(Eq, Debug)

///|
/// Punctuation and operators with fixed spellings.
pub enum Symbol {
  LeftParen
  RightParen
  LeftBrace
  RightBrace
  LeftBracket
  RightBracket
  Caret
  Plus
  Minus
  Star
  Slash
  Exponent
  Percent
  Colon
  DoubleColon
  Equal
  EqualEqual
  FatArrow
  BangEqual
  LessEqual
  GreaterEqual
  ShiftLeft
  ShiftRight
  LogicalAnd
  LogicalOr
  Comma
  Semicolon
  Dot
  Ellipsis
  Less
  Greater
  Arrow
  Bang
  Ampersand
  Pipe
} derive(Eq, Debug)

///|
/// Recoverable lexical failures.
pub enum LexError {
  UnexpectedUnit(UtfCodepoint)
  InvalidAtIdentifier
  InvalidInteger(String)
  InvalidFloat(String)
  InvalidEscape(UtfCodepoint)
  UnterminatedString
  SourceIo(Int)
} derive(Eq, Debug)

///|
/// A decoded token payload.
///
/// String literal payloads are `Bytes` rather than MoonBit `String` values so
/// WTF-8 surrogates and malformed-byte sentinels can be preserved losslessly.
pub enum TokenKind {
  Newline
  Symbol(Symbol)
  Keyword(Keyword)
  Identifier(String)
  AtIdentifier(String)
  I8(UInt64)
  I16(UInt64)
  I32(UInt64)
  I64(UInt64)
  U8(UInt64)
  U16(UInt64)
  U32(UInt64)
  U64(UInt64)
  F32(Float)
  F64(Double)
  StringLiteral(Bytes)
  BytesLiteral(Bytes)
  MultilineString(Bytes)
  Error(LexError)
} derive(Eq, Debug)

///|
/// A token, its absolute UTF-8 byte offset, and its sequential token index.
pub struct Token(TokenKind, ByteOffset, Int) derive(Eq, Debug)

///|
pub fn Token::new(kind : TokenKind, offset : ByteOffset, index : Int) -> Token {
  Token(kind, offset, index)
}

///|
pub fn Token::kind(self : Token) -> TokenKind {
  let Token(kind, _, _) = self
  kind
}

///|
pub fn Token::offset(self : Token) -> ByteOffset {
  let Token(_, offset, _) = self
  offset
}

///|
pub fn Token::index(self : Token) -> Int {
  let Token(_, _, index) = self
  index
}

///|
fn keyword_from_identifier(identifier : String) -> Keyword? {
  match identifier {
    "fn" => Some(Fn)
    "test" => Some(Test)
    "pub" => Some(Pub)
    "builtin" => Some(Builtin)
    "foreign" => Some(Foreign)
    "impl" => Some(Impl)
    "trait" => Some(Trait)
    "for" => Some(For)
    "enum" => Some(Enum)
    "struct" => Some(Struct)
    "type" => Some(Type)
    "let" => Some(Let)
    "using" => Some(Using)
    "mut" => Some(Mut)
    "if" => Some(If)
    "else" => Some(Else)
    "match" => Some(Match)
    "is" => Some(Is)
    "while" => Some(While)
    "loop" => Some(Loop)
    "return" => Some(Return)
    "defer" => Some(Defer)
    "break" => Some(Break)
    "continue" => Some(Continue)
    "true" => Some(True)
    "false" => Some(False)
    "as" => Some(As)
    "in" => Some(In)
    "where" => Some(Where)
    "open" => Some(Open)
    "import" => Some(Import)
    "export" => Some(Export)
    "package" => Some(Package)
    _ => None
  }
}
