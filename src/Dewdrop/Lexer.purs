module Dewdrop.Lexer where

import Prelude

import Data.BitStream (BitReader, read_char)
import Data.Dewdrop.Token (Token(..), TokenKind(..))
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Data.String (length)
import Data.Tuple (Tuple(..))
import Util (is_asterisk, is_colon, is_comma, is_digit, is_equals, is_fslash, is_lbrace, is_lcaret, is_lparen, is_minus, is_name_identifier_continue, is_name_identifier_start, is_newline, is_plus, is_positive_digit, is_rbrace, is_rcaret, is_rparen, is_type_identifier_continue, is_type_identifier_start, is_whitespace, is_zero, str_char, trace)

type Consumer = BitReader -> Maybe (Tuple String BitReader)
type CharConsumer = BitReader -> Maybe (Tuple Char BitReader)

take :: (Char -> Boolean) -> Consumer
take p r = do
  Tuple c r' <- read_char r
  if (p c) then pure $ Tuple (str_char "" c) r'
  else Nothing

take_many :: (Char -> Boolean) -> Consumer
take_many p r = go "" r
  where
  go :: String -> Consumer
  go acc r' = case read_char r' of
    Just (Tuple c r'') | p c -> go (str_char acc c) r''
    _ | acc == "" -> Nothing
    _ -> Just (Tuple acc r')

infixl 4 take_then as ++

take_then :: Consumer -> Consumer -> Consumer
take_then a b r = do
  Tuple s r' <- a r
  Tuple s2 r'' <- b r'
  Just (Tuple (s <> s2) r'')

infixl 4 take_then_optional as ++?

take_then_optional :: Consumer -> Consumer -> Consumer
take_then_optional a b r = do
  Tuple s r' <- a r
  case b r' of
    Nothing -> Just (Tuple s r')
    Just (Tuple s2 r'') -> Just (Tuple (s <> s2) r'')

infixl 4 take_or as ++|

take_or :: Consumer -> Consumer -> Consumer
take_or a b r = case a r of
  Nothing -> b r
  result -> result

take_name_identifier :: Consumer
take_name_identifier = take is_name_identifier_start ++? take_many is_name_identifier_continue

take_type_identifier :: Consumer
take_type_identifier = take is_type_identifier_start ++? take_many is_type_identifier_continue

take_int :: Consumer
take_int = take is_zero ++| (take is_positive_digit ++ take_many is_digit)

take_many_seperated :: Consumer -> Consumer -> Consumer
take_many_seperated consumer seperator r = go "" (consumer r) r
  where
  go "" Nothing _ = Nothing
  go acc Nothing r' = Just (Tuple acc r')
  go acc (Just (Tuple s r')) _ = go_seperator (acc <> s) (seperator r') r'

  go_seperator acc Nothing r' = Just (Tuple acc r')
  go_seperator acc (Just (Tuple _ r')) _ = go acc (consumer r') r'

take_many_joined_by :: Consumer -> Consumer -> Consumer
take_many_joined_by c s r = go_c "" $ c r
  where
  go_c _ Nothing = Nothing
  go_c acc (Just (Tuple v r')) = go_s (acc <> v) $ s r'

  go_s acc Nothing = Just (Tuple acc r)
  go_s acc (Just (Tuple v r')) = go_c (acc <> v) $ c r'

do_take_many_joined_by :: String -> Consumer -> Consumer -> Consumer
do_take_many_joined_by acc consumer seperator r = case seperator r of
  Nothing -> Just (Tuple acc r)
  Just (Tuple sep r') -> case consumer r' of
    Nothing -> Just (Tuple acc r')
    Just (Tuple s r'') -> do_take_many_joined_by (acc <> sep <> s) consumer seperator r''

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
  TokenKindInt _ _ -> true
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
  TokenKindWhiteSpace _ -> true
  _ -> false

is_token_kind_new_line :: TokenKind -> Boolean
is_token_kind_new_line kind = case kind of
  TokenKindNewLine -> true
  _ -> false

is_token_kind_eof :: TokenKind -> Boolean
is_token_kind_eof kind = case kind of
  TokenKindEOF -> true
  _ -> false

type Lexer = BitReader -> Maybe (Tuple TokenKind BitReader)
type LexerAccumulator = BitReader -> Maybe (Tuple String BitReader)

combine_accumulator :: LexerAccumulator -> LexerAccumulator -> LexerAccumulator
combine_accumulator f1 f2 r = do
  Tuple s1 r' <- f1 r -- Maybe (Tuple String Int) Some(Just) t | None(Nothing)
  Tuple s2 r'' <- f2 r'
  Just (Tuple (s1 <> s2) r'')

infix 4 combine_accumulator as +>

lex_or :: Lexer -> Lexer -> Lexer
lex_or lexer1 lexer2 r = case lexer1 r of
  Nothing -> lexer2 r
  token -> token

infixl 4 lex_or as +&

lex_of :: Consumer -> (String -> Maybe TokenKind) -> Lexer
lex_of consumer callback r = do
  Tuple s r' <- consumer r
  kind <- callback s
  pure $ Tuple kind r'

lex_whitespace :: Lexer
lex_whitespace = lex_of (take_many is_whitespace) \text -> pure $ TokenKindWhiteSpace text

lex_newline :: Lexer
lex_newline = lex_of (take is_newline) \_ -> pure TokenKindNewLine

lex_name_identifier :: Lexer
lex_name_identifier = lex_of take_name_identifier \name -> pure case name of
  "pub" -> TokenKindPubKeyword
  "fn" -> TokenKindFnKeyword
  "when" -> TokenKindWhenKeyword
  "else" -> TokenKindElseKeyword
  id -> TokenKindNameIdentifier id

lex_type_identifier :: Lexer
lex_type_identifier = lex_of take_type_identifier \name -> pure $ TokenKindTypeIdentifier name

lex_int :: Lexer
lex_int = lex_of (take_many is_digit) \value -> case (Int.fromString value) of
  Just i -> pure $ TokenKindInt i value
  _ -> Nothing

lex_l_paren :: Lexer
lex_l_paren = lex_of (take is_lparen) \_ -> pure TokenKindLParen

lex_r_paren :: Lexer
lex_r_paren = lex_of (take is_rparen) \_ -> pure TokenKindRParen

lex_l_brace :: Lexer
lex_l_brace = lex_of (take is_lbrace) \_ -> pure TokenKindLBrace

lex_r_brace :: Lexer
lex_r_brace = lex_of (take is_rbrace) \_ -> pure TokenKindRBrace

lex_equals_equals :: Lexer
lex_equals_equals = lex_of (take is_equals ++ take is_equals) \_ -> pure TokenKindEqualsEquals

lex_plus :: Lexer
lex_plus = lex_of (take is_plus) \_ -> pure TokenKindPlus

lex_r_arrow :: Lexer
lex_r_arrow = lex_of (take is_minus ++ take is_rcaret) \_ -> pure TokenKindRArrow

lex_minus :: Lexer
lex_minus = lex_of (take is_minus) \_ -> pure TokenKindMinus

lex_asterisk_asterisk :: Lexer
lex_asterisk_asterisk = lex_of (take is_asterisk ++ take is_asterisk) \_ -> pure TokenKindAsterisk

lex_asterisk :: Lexer
lex_asterisk = lex_of (take is_asterisk) \_ -> pure TokenKindAsterisk

lex_fslash :: Lexer
lex_fslash = lex_of (take is_fslash) \_ -> pure TokenKindFSlash

lex_comma :: Lexer
lex_comma = lex_of (take is_comma) \_ -> pure TokenKindComma

lex_colon :: Lexer
lex_colon = lex_of (take is_colon) \_ -> pure TokenKindColon

lex_greater_than_equals :: Lexer
lex_greater_than_equals = lex_of (take is_rcaret ++ take is_equals) \_ -> pure TokenKindGreaterThanOrEqual

lex_greater_than :: Lexer
lex_greater_than = lex_of (take is_rcaret) \_ -> pure TokenKindGreaterThan

lex_less_than_equals :: Lexer
lex_less_than_equals = lex_of (take is_lcaret ++ take is_equals) \_ -> pure TokenKindLessThanOrEqual

lex_less_than :: Lexer
lex_less_than = lex_of (take is_lcaret) \_ -> pure TokenKindLessThan

lex_eof :: Lexer
lex_eof r = case read_char r of
  Nothing -> Just (Tuple TokenKindEOF r)
  _ -> Nothing

lex_unknown :: Lexer
lex_unknown = lex_of take_not_whitespace go
  where
  take_not_whitespace = take_many not_is_whitespace

  not_is_whitespace :: Char -> Boolean
  not_is_whitespace c = not (is_whitespace c || is_newline c)

  go s = pure $ TokenKindUnknown s

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
  +& lex_unknown

type Index = Int
type Length = Int

token_len :: TokenKind -> Length
token_len TokenKindPubKeyword = 3
token_len TokenKindFnKeyword = 2
token_len TokenKindWhenKeyword = 4
token_len TokenKindElseKeyword = 4
token_len (TokenKindNameIdentifier name) = length name
token_len (TokenKindTypeIdentifier name) = length name
token_len (TokenKindInt _ str) = length str
token_len TokenKindEqualsEquals = 2
token_len TokenKindRArrow = 2
token_len TokenKindGreaterThanOrEqual = 2
token_len TokenKindLessThanOrEqual = 2
token_len TokenKindEOF = 0
token_len (TokenKindWhiteSpace text) = length text
token_len (TokenKindUnknown value) = length value
token_len _ = 1

tokenize :: ∀ (@t :: Type -> Type). Monoid (t Token) => Applicative t => Boolean -> BitReader -> t Token
tokenize false = go mempty 0
  where
  go :: t Token -> Index -> BitReader -> t Token
  go acc index r =
    case lex_token r of
      Just (Tuple TokenKindEOF _) -> acc <> (pure $ Token TokenKindEOF index 0)
      Just (Tuple token r') -> go (acc <> (pure $ Token token index $ token_len token)) (index + token_len token) r'
      _ -> acc

tokenize true = go mempty 0
  where
  go :: t Token -> Index -> BitReader -> t Token
  go acc index r =
    case lex_token r of
      Just (Tuple TokenKindEOF _) -> acc <> (pure $ Token TokenKindEOF index $ token_len TokenKindEOF)
      Just (Tuple token_kind@(TokenKindWhiteSpace _) r') -> go acc (index + token_len token_kind) r'
      Just (Tuple token_kind@TokenKindNewLine r') -> go acc (index + token_len token_kind) r'
      Just (Tuple token_kind r') -> do
        let
          token_length = token_len token_kind
          index' = index + token_length
          token = Token token_kind index token_length
          acc' = acc <> (pure token)
        go acc' index' r'
      _ -> acc

-- [(Token TokenKindPubKeyword 9 3),(Token TokenKindFnKeyword 21 2),(Token TokenKindWhenKeyword 32 4),(Token TokenKindElseKeyword 45 4),(Token (TokenKindNameIdentifier abc) 58 3),(Token (TokenKindNameIdentifier _) 70 1),(Token (TokenKindNameIdentifier a_b_c_123) 80 9),(Token (TokenKindInt 1) 98 1),(Token (TokenKindInt 12) 108 2),(Token TokenKindLParen 119 1),(Token TokenKindRParen 129 1),(Token TokenKindLBrace 139 1),(Token TokenKindRBrace 149 1),(Token TokenKindEqualsEquals 159 2),(Token TokenKindPlus 170 1),(Token TokenKindMinus 180 1),(Token TokenKindAsterisk 190 1),(Token TokenKindFSlash 200 1),(Token TokenKindRArrow 210 2),(Token (TokenKindInt 123) 222 3),(Token TokenKindEOF 234 0)]
-- [(Token TokenKindPubKeyword 9 3),(Token TokenKindFnKeyword 21 2),(Token TokenKindWhenKeyword 32 4),(Token TokenKindElseKeyword 45 4),(Token (TokenKindNameIdentifier abc) 58 3),(Token (TokenKindNameIdentifier _) 70 2),(Token (TokenKindNameIdentifier a_b_c_123) 80 9),(Token (TokenKindInt 1) 98 1),(Token (TokenKindInt 12) 108 2),(Token TokenKindLParen 119 1),(Token TokenKindRParen 129 1),(Token TokenKindLBrace 139 1),(Token TokenKindRBrace 149 1),(Token TokenKindEqualsEquals 159 2),(Token TokenKindPlus 170 1),(Token TokenKindMinus 180 1),(Token TokenKindAsterisk 190 1),(Token TokenKindFSlash 200 1),(Token TokenKindRArrow 210 2),(Token (TokenKindInt 123) 222 3),(Token TokenKindEOF 234 0)]