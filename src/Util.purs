module Util
  ( (+&)
  , (++)
  , (++?)
  , (+|)
  , (..)
  , Consumer
  , char_str
  , expect_char
  , expect_many
  , intersect_char_predicate
  , is_alpha
  , is_alpha_num
  , is_between
  , is_char
  , is_digit
  , is_equals
  , is_int_start
  , is_lbrace
  , is_lower
  , is_lparen
  , is_minus
  , is_name_identifier_continue
  , is_name_identifier_start
  , is_newline
  , is_plus
  , is_rbrace
  , is_rcaret
  , is_return_char
  , is_rparen
  , is_space
  , is_tab
  , is_underscore
  , is_upper
  , is_whitespace
  , str_char
  , take
  , take_identifier
  , take_int
  , take_many
  , take_then
  , take_then_optional
  , to_chars
  , union_char_predicate
  )
  where

import Prelude

import Data.Array ((!!))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))

foreign import str_char :: String -> Char -> String
foreign import char_str :: Char -> String -> String
foreign import to_chars :: String -> Array Char

is_char :: Char -> Char -> Boolean
is_char c c' = c == c'

is_between :: Char -> Char -> Char -> Boolean
is_between a b c = a <= c && b >= c

infixl 4 is_between as ..

intersect_char_predicate :: (Char -> Boolean) -> (Char -> Boolean) -> Char -> Boolean
intersect_char_predicate p1 p2 c = p1 c && p2 c

infixl 4 intersect_char_predicate as +&

union_char_predicate :: (Char -> Boolean) -> (Char -> Boolean) -> Char -> Boolean
union_char_predicate p1 p2 c = p1 c || p2 c

infixl 4 union_char_predicate as +|

expect_char :: (Char -> Boolean) -> Array Char -> Int -> Maybe Char
expect_char p arr i = do
  c <- arr !! i
  if p c then Just c else Nothing

expect_many :: (Char -> Boolean) -> Array Char -> Int -> Maybe (Tuple String Int)
expect_many p arr i = do_expect_many "" 0 p arr i

do_expect_many :: String -> Int -> (Char -> Boolean) -> Array Char -> Int -> Maybe (Tuple String Int)
do_expect_many s len p arr j = do
  c <- arr !! j
  if p c
    then do_expect_many (str_char s c) (len + 1) p arr (j + 1)
    else Just (Tuple s len)

is_lower :: Char -> Boolean
is_lower = ('a' .. 'z')
is_upper :: Char -> Boolean
is_upper = ('A' .. 'Z')
is_alpha :: Char -> Boolean
is_alpha = is_lower +| is_upper
is_digit :: Char -> Boolean
is_digit = ('0' .. '9')
is_int_start :: Char -> Boolean
is_int_start = ('1' .. '9')
is_alpha_num :: Char -> Boolean
is_alpha_num = is_alpha +| is_digit
is_plus :: Char -> Boolean
is_plus = is_char '+'
is_minus :: Char -> Boolean
is_minus = is_char '-'
is_equals :: Char -> Boolean
is_equals = is_char '='
is_rcaret :: Char -> Boolean
is_rcaret = is_char '>'
is_space :: Char -> Boolean
is_space = is_char ' '
is_newline :: Char -> Boolean
is_newline = is_char '\n'
is_tab :: Char -> Boolean
is_tab = is_char '\t'
is_return_char :: Char -> Boolean
is_return_char = is_char '\r'
is_lparen :: Char -> Boolean
is_lparen = is_char '('
is_rparen :: Char -> Boolean
is_rparen = is_char ')'
is_underscore :: Char -> Boolean
is_underscore = is_char '_'
is_whitespace :: Char -> Boolean
is_whitespace = is_space +| is_return_char +| is_tab
is_lbrace :: Char -> Boolean
is_lbrace = is_char '{'
is_rbrace :: Char -> Boolean
is_rbrace = is_char '}'
is_name_identifier_start :: Char -> Boolean
is_name_identifier_start = is_underscore +| is_lower
is_name_identifier_continue :: Char -> Boolean
is_name_identifier_continue = is_name_identifier_start +| is_digit

type Consumer = Array Char -> Int -> Maybe (Tuple String Int)

take :: (Char -> Boolean) -> Consumer
take p arr index = do
  c <- (arr !! index)
  if (p c)
    then Just (Tuple (str_char "" c) (index + 1))
    else Nothing

take_many :: (Char -> Boolean) -> Consumer
take_many p arr index = do_take_many "" p arr index

do_take_many :: String -> (Char -> Boolean) -> Consumer
do_take_many acc p arr index = case (arr !! index) of
  Just c | p c -> do_take_many (str_char acc c) p arr (index + 1)
  _ | acc == "" -> Nothing
  _ -> Just (Tuple acc index)

take_then :: Consumer -> Consumer -> Consumer
take_then a b arr index = do
  Tuple s index2 <- a arr index
  Tuple s2 index3 <- b arr index2
  Just (Tuple (s <> s2) index3)

infixl 4 take_then as ++

take_then_optional :: Consumer -> Consumer -> Consumer
take_then_optional a b arr index = do
  Tuple s index2 <- a arr index
  case b arr index2 of
    Nothing -> Just (Tuple s index2)
    Just (Tuple s2 index3) -> Just (Tuple (s <> s2) index3)

infixl 4 take_then_optional as ++?

take_identifier :: Consumer
take_identifier = take is_name_identifier_start ++? take_many is_name_identifier_continue

take_int :: Consumer
take_int = take is_int_start ++ take_many is_digit
