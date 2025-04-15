module Util where

import Prelude

import Data.Array ((!!))
import Data.BitStream (BitReader, read_char)
import Data.Char (toCharCode)
import Data.Int.Bits (shl, (.&.))
import Data.List (List(..), (:))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))

type CharPredicate = Char -> Boolean

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

expect_char :: (Char -> Boolean) -> CharConsumer
expect_char p r = case read_char r of
  t@(Just (Tuple c _)) | p c -> t
  _ -> Nothing

expect_many :: (Char -> Boolean) -> BitReader -> Maybe (Tuple String BitReader)
expect_many p r = go "" p r
  where
  go :: String -> CharPredicate -> BitReader -> Maybe (Tuple String BitReader)
  go acc p' r' = case read_char r' of
    Just (Tuple c r'') | p' c -> go (str_char acc c) p' r''
    _ -> Just (Tuple acc r')

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

type Consumer = BitReader -> Maybe (Tuple String BitReader)
type CharConsumer = BitReader -> Maybe (Tuple Char BitReader)

take :: (Char -> Boolean) -> Consumer
take p r = do
  Tuple c r' <- read_char r
  if (p c)
    then pure $ Tuple (str_char "" c) r'
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
take_many_seperated consumer seperator r =  go "" (consumer r) r
  where
  go "" Nothing _ = Nothing
  go acc Nothing r' = Just (Tuple acc r')
  go acc (Just (Tuple s r')) _ = go_seperator (acc <> s) (seperator r') r'

  go_seperator acc Nothing r' = Just (Tuple acc r')
  go_seperator acc (Just (Tuple _ r')) _ = go acc (consumer r') r'

take_many_joined_by :: Consumer -> Consumer -> Consumer
take_many_joined_by consumer seperator = \r -> case consumer r of
  Nothing -> Nothing
  Just (Tuple s r') -> do_take_many_joined_by s consumer seperator r'

do_take_many_joined_by :: String -> Consumer -> Consumer -> Consumer
do_take_many_joined_by acc consumer seperator r = case seperator r of
  Nothing -> Just (Tuple acc r)
  Just (Tuple sep r') -> case consumer r' of
    Nothing -> Just (Tuple acc r')
    Just (Tuple s r'') -> do_take_many_joined_by (acc <> sep <> s) consumer seperator r''

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
