module Lexer
  ( (+&)
  , (+>)
  , Lexer
  , Token(..)
  , TokenKind(..)
  , combine_accumulator
  , lex_eof
  , lex_equals_equals
  , lex_int
  , lex_l_brace
  , lex_l_paren
  , lex_minus
  , lex_name_identifier
  , lex_of
  , lex_or
  , lex_plus
  , lex_r_arrow
  , lex_r_brace
  , lex_r_paren
  , lex_token
  , lex_whitespace
  )
  where

import Prelude

import Data.Array ((!!))
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Util (Consumer, is_digit, is_equals, is_lbrace, is_lparen, is_minus, is_newline, is_plus, is_rbrace, is_rcaret, is_rparen, is_whitespace, take, take_identifier, take_many, (++))

data Token = Token TokenKind Int

-- pub fn fib(n) {
--   when n == 0 -> 0
--     n == 1 -> 1
--     else -> fib(n - 1) + fib(n - 2)
-- }

data TokenKind = TokenKindPubKeyword
               | TokenKindFnKeyword
               | TokenKindWhenKeyword
               | TokenKindElseKeyword
               | TokenKindNameIdentifier String
               | TokenKindInt Int
               | TokenKindLParen
               | TokenKindRParen
               | TokenKindLBrace
               | TokenKindRBrace
               | TokenKindEqualsEquals
               | TokenKindPlus
               | TokenKindMinus
               | TokenKindRArrow
               | TokenKindWhiteSpace
               | TokenKindNewLine
               | TokenKindEOF

type Lexer = Array Char -> Int -> Maybe (Tuple TokenKind Int)
type LexerAccumulator = Array Char -> Int -> Maybe (Tuple String Int)

combine_accumulator :: LexerAccumulator -> LexerAccumulator -> LexerAccumulator
combine_accumulator f1 f2 chars index = do
  Tuple s1 index1 <- f1 chars index -- Maybe (Tuple String Int) Some(Just) t | None(Nothing)
  Tuple s2 index2 <- f2 chars index1
  Just (Tuple (s1 <> s2) index2)

infix 4 combine_accumulator as +>

lex_or :: Lexer -> Lexer -> Lexer
lex_or lexer1 lexer2 chars index = case lexer1 chars index of
  Nothing -> lexer2 chars index
  token -> token

infixl 4 lex_or as +&

lex_of :: Consumer -> (String -> TokenKind) -> Lexer
lex_of consumer callback = \chars index -> do 
  Tuple s next_index <- consumer chars index
  Just (Tuple (callback s) next_index)

lex_whitespace :: Lexer
lex_whitespace = lex_of (take_many is_whitespace) \_ -> TokenKindWhiteSpace

lex_newline :: Lexer
lex_newline = lex_of (take_many is_newline) \_ -> TokenKindNewLine

lex_name_identifier :: Lexer
lex_name_identifier = lex_of take_identifier \name -> case name of
  "pub" -> TokenKindPubKeyword
  "fn" -> TokenKindFnKeyword
  "when" -> TokenKindWhenKeyword
  "else" -> TokenKindElseKeyword
  id -> TokenKindNameIdentifier id

lex_int :: Lexer
lex_int = lex_of (take_many is_digit) \value -> case (Int.fromString value) of
  Just i -> TokenKindInt i
  _ -> TokenKindInt (-1)

lex_l_paren :: Lexer
lex_l_paren = lex_of (take is_lparen) \_ -> TokenKindLParen

lex_r_paren :: Lexer
lex_r_paren = lex_of (take is_rparen) \_ -> TokenKindRParen

lex_l_brace :: Lexer
lex_l_brace = lex_of (take is_lbrace) \_ -> TokenKindLBrace

lex_r_brace :: Lexer
lex_r_brace = lex_of (take is_rbrace) \_ -> TokenKindRBrace

lex_equals_equals :: Lexer
lex_equals_equals = lex_of (take is_equals ++ take is_equals) \_ -> TokenKindEqualsEquals

lex_plus :: Lexer
lex_plus = lex_of (take is_plus) \_ -> TokenKindPlus

lex_r_arrow :: Lexer
lex_r_arrow = lex_of (take is_minus ++ take is_rcaret) \_ -> TokenKindRArrow

lex_minus :: Lexer
lex_minus = lex_of (take is_minus) \_ -> TokenKindMinus

lex_eof :: Lexer
lex_eof chars index = case chars !! index of
  Nothing -> Just (Tuple TokenKindEOF index)
  _ -> Nothing

lex_token :: Lexer
lex_token  = lex_whitespace
          +& lex_name_identifier
          +& lex_int
          +& lex_l_paren
          +& lex_r_paren
          +& lex_l_brace
          +& lex_r_brace
          +& lex_equals_equals
          +& lex_plus
          +& lex_r_arrow
          +& lex_minus
          +& lex_eof

instance showTokenKind :: Show TokenKind where
  show TokenKindPubKeyword = "TokenKindPubKeyword"
  show TokenKindFnKeyword = "TokenKindFnKeyword"
  show TokenKindWhenKeyword = "TokenKindWhenKeyword"
  show TokenKindElseKeyword = "TokenKindElseKeyword"
  show (TokenKindNameIdentifier name) = "(TokenKindNameIdentifier " <> name <> ")"
  show (TokenKindInt value) = "(TokenKindInt " <> show value <> ")"
  show TokenKindLParen = "TokenKindLParen"
  show TokenKindRParen = "TokenKindRParen"
  show TokenKindLBrace = "TokenKindLBrace"
  show TokenKindRBrace = "TokenKindRBrace"
  show TokenKindEqualsEquals = "TokenKindEqualsEquals"
  show TokenKindPlus = "TokenKindPlus"
  show TokenKindMinus = "TokenKindMinus"
  show TokenKindRArrow = "TokenKindRArrow"
  show TokenKindEOF = "TokenKindEOF"
  show TokenKindWhiteSpace = "TokenKindWhiteSpace"
  show TokenKindNewLine = "TokenKindNewLine"

derive instance equals :: Eq TokenKind
  

-- pub fn fib(n) {
--   when n == 0 -> 0
--     n == 1 -> 1
--     else -> fib(n - 1) + fib(n - 2)
-- }
