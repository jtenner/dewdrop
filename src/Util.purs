module Util
  ( (+&)
  , (++)
  , (++?)
  , (++|)
  , (+|)
  , (..)
  , Consumer
  , char_size
  , char_str
  , drop_maybe
  , expect_char
  , expect_many
  , from_chars
  , guard
  , intersect_char_predicate
  , is_alpha
  , is_alpha_num
  , is_asterisk
  , is_between
  , is_char
  , is_colon
  , is_comma
  , is_digit
  , is_dot
  , is_equals
  , is_fslash
  , is_lbrace
  , is_lcaret
  , is_lower
  , is_lparen
  , is_minus
  , is_name_identifier_continue
  , is_name_identifier_start
  , is_newline
  , is_plus
  , is_positive_digit
  , is_rbrace
  , is_rcaret
  , is_return_char
  , is_rparen
  , is_space
  , is_tab
  , is_type_identifier_continue
  , is_type_identifier_start
  , is_underscore
  , is_upper
  , is_whitespace
  , is_zero
  , partition_at
  , str_char
  , take
  , take_int
  , take_many
  , take_many_joined_by
  , take_many_seperated
  , take_name_identifier
  , take_or
  , take_then
  , take_then_optional
  , take_type_identifier
  , to_chars
  , to_signed
  , to_unsigned
  , trace
  , union_char_predicate
  )
  where

import Prelude

import Data.Array ((!!))
import Data.Char (toCharCode)
import Data.Int.Bits (shl, (.&.))
import Data.List (List(..), (:))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))

foreign import str_char :: String -> Char -> String
foreign import char_str :: Char -> String -> String
foreign import to_chars :: String -> Array Char
foreign import from_chars :: Array Char -> String
foreign import trace :: ∀ a. String -> a -> a

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
  if p c then do_expect_many (str_char s c) (len + 1) p arr (j + 1)
  else Just (Tuple s len)

is_lower :: Char -> Boolean
is_lower = ('a' .. 'z')

is_upper :: Char -> Boolean
is_upper = ('A' .. 'Z')

is_alpha :: Char -> Boolean
is_alpha = is_lower +| is_upper

is_digit :: Char -> Boolean
is_digit = ('0' .. '9')

is_positive_digit :: Char -> Boolean
is_positive_digit = ('1' .. '9')

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

is_lcaret :: Char -> Boolean
is_lcaret = is_char '<'

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

is_comma :: Char -> Boolean
is_comma = is_char ','

is_colon :: Char -> Boolean
is_colon = is_char ':'

is_asterisk :: Char -> Boolean
is_asterisk = is_char '*'

is_fslash :: Char -> Boolean
is_fslash = is_char '/'

is_dot :: Char -> Boolean
is_dot = is_char '.'

is_zero :: Char -> Boolean
is_zero = is_char '0'

is_name_identifier_start :: Char -> Boolean
is_name_identifier_start = is_underscore +| is_lower

is_name_identifier_continue :: Char -> Boolean
is_name_identifier_continue = is_name_identifier_start +| is_digit

is_type_identifier_start :: Char -> Boolean
is_type_identifier_start = is_upper

is_type_identifier_continue :: Char -> Boolean
is_type_identifier_continue = is_alpha_num

type Consumer = Array Char -> Int -> Maybe (Tuple String Int)

take :: (Char -> Boolean) -> Consumer
take p arr index = do
  c <- (arr !! index)
  if (p c) then Just (Tuple (str_char "" c) (index + 1))
  else Nothing

take_many :: (Char -> Boolean) -> Consumer
take_many p arr index = do_take_many "" p arr index

do_take_many :: String -> (Char -> Boolean) -> Consumer
do_take_many acc p arr index = case (arr !! index) of
  Just c | p c -> do_take_many (str_char acc c) p arr (index + 1)
  _ | acc == "" -> Nothing
  _ -> Just (Tuple acc index)

infixl 4 take_then as ++

take_then :: Consumer -> Consumer -> Consumer
take_then a b arr index = do
  Tuple s index2 <- a arr index
  Tuple s2 index3 <- b arr index2
  Just (Tuple (s <> s2) index3)

infixl 4 take_then_optional as ++?

take_then_optional :: Consumer -> Consumer -> Consumer
take_then_optional a b arr index = do
  Tuple s index2 <- a arr index
  case b arr index2 of
    Nothing -> Just (Tuple s index2)
    Just (Tuple s2 index3) -> Just (Tuple (s <> s2) index3)

infixl 4 take_or as ++|

take_or :: Consumer -> Consumer -> Consumer
take_or a b arr index = case a arr index of
  Nothing -> b arr index
  result -> result

take_name_identifier :: Consumer
take_name_identifier = take is_name_identifier_start ++? take_many is_name_identifier_continue

take_type_identifier :: Consumer
take_type_identifier = take is_type_identifier_start ++? take_many is_type_identifier_continue

take_int :: Consumer
take_int = take is_zero ++| (take is_positive_digit ++ take_many is_digit)

take_many_seperated :: Consumer -> Consumer -> Consumer
take_many_seperated consumer seperator = \arr index -> do_take_many_seperated "" consumer seperator arr index

do_take_many_seperated :: String -> Consumer -> Consumer -> Consumer
do_take_many_seperated acc consumer seperator arr index = case consumer arr index of
  Nothing
    | acc == "" -> Nothing
    | otherwise -> Just (Tuple acc index)
  Just (Tuple s index2) -> case seperator arr index2 of
    Nothing -> Just (Tuple (acc <> s) index2)
    Just (Tuple _ index3) -> do_take_many_seperated (acc <> s) consumer seperator arr index3

take_many_joined_by :: Consumer -> Consumer -> Consumer
take_many_joined_by consumer seperator = \arr index -> case consumer arr index of
  Nothing -> Nothing
  Just (Tuple s index2) -> do_take_many_joined_by s consumer seperator arr index2

do_take_many_joined_by :: String -> Consumer -> Consumer -> Array Char -> Int -> Maybe (Tuple String Int)
do_take_many_joined_by acc consumer seperator arr index = case seperator arr index of
  Nothing -> Just (Tuple acc index)
  Just (Tuple sep index') -> case consumer arr index' of
    Nothing -> Just (Tuple acc index')
    Just (Tuple s index'') -> do_take_many_joined_by (acc <> sep <> s) consumer seperator arr index''

guard :: forall a. Boolean -> Maybe a -> Maybe a
guard true x = x
guard false _ = Nothing

negative_mask :: Int -> Int
negative_mask n = 1 `shl` (n - 1)

to_signed :: Int -> Int -> Int
to_signed n i =
  let
    sign_bit = negative_mask n
    max_val = 1 `shl` n
  in
    if (i .&. sign_bit) /= 0 then i - max_val
    else i

to_unsigned :: Int -> Int -> Int
to_unsigned n i =
  let
    mask = (1 `shl` n) - 1
  in
    i .&. mask

--   0x00000000 - 0x0000007F:
--       0xxxxxxx
--
--   0x00000080 - 0x000007FF:
--       110xxxxx 10xxxxxx
--
--   0x00000800 - 0x0000FFFF:
--       1110xxxx 10xxxxxx 10xxxxxx
--
--   0x00010000 - 0x001FFFFF:
--       11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
char_size :: Char -> Int
char_size char = case toCharCode char of
  n | n < 0x80 -> 1
  n | n < 0x800 -> 2
  n | n < 0x10000 -> 3
  _ -> 4

drop_maybe :: ∀ (@n :: Type). Int -> List n -> Maybe (List n)
drop_maybe 0 list = pure list
drop_maybe n (_ : list') = drop_maybe (n - 1) list'
drop_maybe _ Nil = Nothing

partition_at :: ∀ (@a :: Type). Int -> List a -> Maybe (Tuple (List a) (List a))
partition_at n list = go n Nil list
  where
  go :: Int -> List a -> List a -> Maybe (Tuple (List a) (List a))
  go 0 acc list' = pure $ Tuple acc list'
  go _ _ Nil = Nothing
  go n' acc (Cons x list') = go (n' - 1) (x : acc) list'
