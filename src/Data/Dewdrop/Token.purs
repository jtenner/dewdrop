module Data.Dewdrop.Token where

import Prelude

type Index = Int
type Length = Int

data Token = Token TokenKind Index Length

data TokenKind
  = TokenKindPubKeyword
  | TokenKindFnKeyword
  | TokenKindWhenKeyword
  | TokenKindElseKeyword
  | TokenKindNameIdentifier String
  | TokenKindTypeIdentifier String
  | TokenKindInt Int String
  | TokenKindLParen
  | TokenKindRParen
  | TokenKindLBrace
  | TokenKindRBrace
  | TokenKindEqualsEquals
  | TokenKindAsterisk
  | TokenKindFSlash
  | TokenKindPlus
  | TokenKindMinus
  | TokenKindComma
  | TokenKindColon
  | TokenKindRArrow
  | TokenKindGreaterThan
  | TokenKindGreaterThanOrEqual
  | TokenKindLessThan
  | TokenKindLessThanOrEqual
  | TokenKindWhiteSpace String
  | TokenKindNewLine
  | TokenKindUnknown String
  | TokenKindEOF

instance show_token_kind :: Show TokenKind where
  show TokenKindPubKeyword = "TokenKindPubKeyword"
  show TokenKindFnKeyword = "TokenKindFnKeyword"
  show TokenKindWhenKeyword = "TokenKindWhenKeyword"
  show TokenKindElseKeyword = "TokenKindElseKeyword"
  show (TokenKindNameIdentifier name) = "(TokenKindNameIdentifier " <> name <> ")"
  show (TokenKindTypeIdentifier name) = "(TokenKindTypeIdentifier " <> name <> ")"
  show (TokenKindInt value _) = "(TokenKindInt " <> show value <> ")"
  show TokenKindLParen = "TokenKindLParen"
  show TokenKindRParen = "TokenKindRParen"
  show TokenKindLBrace = "TokenKindLBrace"
  show TokenKindRBrace = "TokenKindRBrace"
  show TokenKindEqualsEquals = "TokenKindEqualsEquals"
  show TokenKindPlus = "TokenKindPlus"
  show TokenKindMinus = "TokenKindMinus"
  show TokenKindAsterisk = "TokenKindAsterisk"
  show TokenKindFSlash = "TokenKindFSlash"
  show TokenKindComma = "TokenKindComma"
  show TokenKindColon = "TokenKindColon"
  show TokenKindRArrow = "TokenKindRArrow"
  show TokenKindGreaterThan = "TokenKindGreaterThan"
  show TokenKindGreaterThanOrEqual = "TokenKindGreaterThanOrEqual"
  show TokenKindLessThan = "TokenKindLessThan"
  show TokenKindLessThanOrEqual = "TokenKindLessThanOrEqual"
  show TokenKindEOF = "TokenKindEOF"
  show (TokenKindWhiteSpace _) = "TokenKindWhiteSpace"
  show TokenKindNewLine = "TokenKindNewLine"
  show (TokenKindUnknown value) = "(TokenKindUnknown " <> value <> ")"

derive instance equals :: Eq TokenKind

instance show :: Show Token where
  show (Token kind pos len) = "(Token " <> show kind <> " " <> show pos <> " " <> show len <> ")"

derive instance eq :: Eq Token