module Dewdrop.Lexer
  ( (+&)
  , (+>)
  , Lexer
  , Token(..)
  , TokenKind(..)
  , combine_accumulator
  , is_token_kind_asterisk
  , is_token_kind_colon
  , is_token_kind_comma
  , is_token_kind_else_keyword
  , is_token_kind_eof
  , is_token_kind_equals_equals
  , is_token_kind_fn_keyword
  , is_token_kind_fslash
  , is_token_kind_int
  , is_token_kind_l_brace
  , is_token_kind_l_paren
  , is_token_kind_minus
  , is_token_kind_name_identifier
  , is_token_kind_new_line
  , is_token_kind_plus
  , is_token_kind_pub_keyword
  , is_token_kind_r_arrow
  , is_token_kind_r_brace
  , is_token_kind_r_paren
  , is_token_kind_type_identifier
  , is_token_kind_when_keyword
  , is_token_kind_white_space
  , lex_asterisk
  , lex_colon
  , lex_comma
  , lex_eof
  , lex_equals_equals
  , lex_fslash
  , lex_greater_than_equals
  , lex_int
  , lex_l_brace
  , lex_l_paren
  , lex_minus
  , lex_name_identifier
  , lex_newline
  , lex_of
  , lex_or
  , lex_plus
  , lex_r_arrow
  , lex_r_brace
  , lex_r_paren
  , lex_token
  , lex_type_identifier
  , lex_whitespace
  , tokenize
  ) where

import Prelude

import Data.Array ((!!), snoc)
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Dewdrop.Types (Token(..), TokenKind(..))
import Util (Consumer, is_fslash, is_asterisk, is_colon, is_comma, is_digit, is_equals, is_lbrace, is_lparen, is_minus, is_newline, is_plus, is_rbrace, is_lcaret, is_rcaret, is_rparen, is_whitespace, take, take_many, take_name_identifier, take_type_identifier, to_chars, (++))

is_token_kind_pub_keyword :: TokenKind -> Boolean
is_token_kind_pub_keyword kind = case kind of
  TokenKindPubKeyword -> true
  _ -> false

is_token_kind_fn_keyword :: TokenKind -> Boolean
is_token_kind_fn_keyword kind = case kind of
  TokenKindFnKeyword -> true
  _ -> false

is_token_kind_when_keyword :: TokenKind -> Boolean
is_token_kind_when_keyword kind = case kind of
  TokenKindWhenKeyword -> true
  _ -> false

is_token_kind_else_keyword :: TokenKind -> Boolean
is_token_kind_else_keyword kind = case kind of
  TokenKindElseKeyword -> true
  _ -> false

is_token_kind_name_identifier :: TokenKind -> Boolean
is_token_kind_name_identifier kind = case kind of
  TokenKindNameIdentifier _ -> true
  _ -> false

is_token_kind_type_identifier :: TokenKind -> Boolean
is_token_kind_type_identifier kind = case kind of
  TokenKindTypeIdentifier _ -> true
  _ -> false

is_token_kind_int :: TokenKind -> Boolean
is_token_kind_int kind = case kind of
  TokenKindInt _ -> true
  _ -> false

is_token_kind_l_paren :: TokenKind -> Boolean
is_token_kind_l_paren kind = case kind of
  TokenKindLParen -> true
  _ -> false

is_token_kind_r_paren :: TokenKind -> Boolean
is_token_kind_r_paren kind = case kind of
  TokenKindRParen -> true
  _ -> false

is_token_kind_l_brace :: TokenKind -> Boolean
is_token_kind_l_brace kind = case kind of
  TokenKindLBrace -> true
  _ -> false

is_token_kind_r_brace :: TokenKind -> Boolean
is_token_kind_r_brace kind = case kind of
  TokenKindRBrace -> true
  _ -> false

is_token_kind_equals_equals :: TokenKind -> Boolean
is_token_kind_equals_equals kind = case kind of
  TokenKindEqualsEquals -> true
  _ -> false

is_token_kind_plus :: TokenKind -> Boolean
is_token_kind_plus kind = case kind of
  TokenKindPlus -> true
  _ -> false

is_token_kind_minus :: TokenKind -> Boolean
is_token_kind_minus kind = case kind of
  TokenKindMinus -> true
  _ -> false

is_token_kind_asterisk :: TokenKind -> Boolean
is_token_kind_asterisk kind = case kind of
  TokenKindAsterisk -> true
  _ -> false

is_token_kind_fslash :: TokenKind -> Boolean
is_token_kind_fslash kind = case kind of
  TokenKindFSlash -> true
  _ -> false

is_token_kind_r_arrow :: TokenKind -> Boolean
is_token_kind_r_arrow kind = case kind of
  TokenKindRArrow -> true
  _ -> false

is_token_kind_comma :: TokenKind -> Boolean
is_token_kind_comma kind = case kind of
  TokenKindComma -> true
  _ -> false

is_token_kind_colon :: TokenKind -> Boolean
is_token_kind_colon kind = case kind of
  TokenKindColon -> true
  _ -> false

is_token_kind_white_space :: TokenKind -> Boolean
is_token_kind_white_space kind = case kind of
  TokenKindWhiteSpace -> true
  _ -> false

is_token_kind_new_line :: TokenKind -> Boolean
is_token_kind_new_line kind = case kind of
  TokenKindNewLine -> true
  _ -> false

is_token_kind_eof :: TokenKind -> Boolean
is_token_kind_eof kind = case kind of
  TokenKindEOF -> true
  _ -> false

type Lexer = Array Char -> Int -> Maybe (Tuple TokenKind Int)
type LexerAccumulator = Array Char -> Int -> Maybe (Tuple String Int)

combine_accumulator :: LexerAccumulator -> LexerAccumulator -> LexerAccumulator
combine_accumulator f1 f2 chars index = do
  Tuple s1 index' <- f1 chars index -- Maybe (Tuple String Int) Some(Just) t | None(Nothing)
  Tuple s2 index'' <- f2 chars index'
  Just (Tuple (s1 <> s2) index'')

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
lex_newline = lex_of (take is_newline) \_ -> TokenKindNewLine

lex_name_identifier :: Lexer
lex_name_identifier = lex_of take_name_identifier \name -> case name of
  "pub" -> TokenKindPubKeyword
  "fn" -> TokenKindFnKeyword
  "when" -> TokenKindWhenKeyword
  "else" -> TokenKindElseKeyword
  id -> TokenKindNameIdentifier id

lex_type_identifier :: Lexer
lex_type_identifier = lex_of take_type_identifier \name -> TokenKindTypeIdentifier name

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

lex_asterisk_asterisk :: Lexer
lex_asterisk_asterisk = lex_of (take is_asterisk ++ take is_asterisk) \_ -> TokenKindAsterisk

lex_asterisk :: Lexer
lex_asterisk = lex_of (take is_asterisk) \_ -> TokenKindAsterisk

lex_fslash :: Lexer
lex_fslash = lex_of (take is_fslash) \_ -> TokenKindFSlash

lex_comma :: Lexer
lex_comma = lex_of (take is_comma) \_ -> TokenKindComma

lex_colon :: Lexer
lex_colon = lex_of (take is_colon) \_ -> TokenKindColon

lex_greater_than_equals :: Lexer
lex_greater_than_equals = lex_of (take is_rcaret ++ take is_equals) \_ -> TokenKindGreaterThanOrEqual

lex_greater_than :: Lexer
lex_greater_than = lex_of (take is_rcaret) \_ -> TokenKindGreaterThan

lex_less_than_equals :: Lexer
lex_less_than_equals = lex_of (take is_lcaret ++ take is_equals) \_ -> TokenKindLessThanOrEqual

lex_less_than :: Lexer
lex_less_than = lex_of (take is_lcaret) \_ -> TokenKindLessThan

lex_eof :: Lexer
lex_eof chars index = case chars !! index of
  Nothing -> Just (Tuple TokenKindEOF index)
  _ -> Nothing

lex_token :: Lexer
lex_token = lex_whitespace
  +& lex_name_identifier
  +& lex_type_identifier
  +& lex_newline
  +& lex_int
  +& lex_greater_than_equals
  +& lex_greater_than
  +& lex_less_than_equals
  +& lex_less_than
  +& lex_l_paren
  +& lex_r_paren
  +& lex_l_brace
  +& lex_r_brace
  +& lex_equals_equals
  +& lex_asterisk_asterisk
  +& lex_asterisk
  +& lex_fslash
  +& lex_plus
  +& lex_r_arrow
  +& lex_minus
  +& lex_comma
  +& lex_colon
  +& lex_eof

tokenize :: String -> Boolean -> Array Token
tokenize chars false = do_tokenize (to_chars chars) 0 []
tokenize chars true = do_tokenize_filter_whitespace (to_chars chars) 0 []

do_tokenize :: Array Char -> Int -> Array Token -> Array Token
do_tokenize chars index acc = case lex_token chars index of
  Just (Tuple TokenKindEOF _) -> snoc acc $ Token TokenKindEOF index
  Just (Tuple token next_index) -> do_tokenize chars next_index $ snoc acc $ Token token index
  _ -> acc

do_tokenize_filter_whitespace :: Array Char -> Int -> Array Token -> Array Token
do_tokenize_filter_whitespace chars index acc = case lex_token chars index of
  Just (Tuple TokenKindEOF _) -> snoc acc $ Token TokenKindEOF index
  Just (Tuple TokenKindWhiteSpace next_index) -> do_tokenize_filter_whitespace chars next_index acc
  Just (Tuple TokenKindNewLine next_index) -> do_tokenize_filter_whitespace chars next_index acc
  Just (Tuple token_kind next_index) -> do_tokenize_filter_whitespace chars next_index $ snoc acc $ Token token_kind index
  _ -> acc
