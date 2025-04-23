module Data.Bits where

import Data.Array
import Data.ArrayBuffer.Types
import Data.BigInt
import Prelude

data Bits

type Size = Int
type Index = Int

foreign import zeros :: Size -> Bits
foreign import empty :: Bits
foreign import read :: Size -> Index -> Bits -> Int
foreign import read_signed :: Size -> Index -> Bits -> Int
foreign import length :: Bits -> Int
foreign import read_u8 :: Index -> Bits -> Int
foreign import read_u16 :: Index -> Bits -> Int
foreign import read_u32 :: Index -> Bits -> Int
foreign import read_u64 :: Index -> Bits -> BigInt
foreign import read_i8 :: Index -> Bits -> Int
foreign import read_i16 :: Index -> Bits -> Int
foreign import read_i32 :: Index -> Bits -> Int
foreign import read_i64 :: Index -> Bits -> BigInt
foreign import read_f32 :: Index -> Bits -> Number
foreign import read_f64 :: Index -> Bits -> Number
foreign import read_utf8_char :: Index -> Bits -> Int
foreign import from_string :: String -> Bits
foreign import from_buffer :: Uint8Array -> Bits
foreign import from_words :: Array Int -> Bits
foreign import to_words :: Bits -> Array Int
foreign import bits_to_hex :: Bits -> String
foreign import eq_bits :: Bits -> Bits -> Boolean
foreign import ord_bits :: Bits -> Bits -> Int
foreign import append_bits :: Bits -> Bits -> Bits
foreign import concat_bits :: Bits -> Bits -> Bits

newtype BitReader = BitReader Bits

instance show_bits :: Show Bits where
  show = bits_to_hex

instance show_bit_reader :: Show BitReader where
  show (BitReader n) = "(BitReader" <> show n <>")"

instance eq_bit_reader :: Eq BitReader where
  eq (BitReader l) (BitReader r) = eq_bits l r

instance ord_bit_reader :: Ord BitReader where
  compare (BitReader l) (BitReader r) =
    case ord_bits l r of
      0 -> EQ
      n | n > 0 -> GT
      _ -> LT

instance semigroup_bits :: Semigroup Bits where
  append = concat_bits

instance semigroup_bit_reader :: Semigroup BitReader where
  append (BitReader l) (BitReader r) = BitReader $ l <> r

instance monoid_bits :: Monoid Bits where
  mempty = empty

instance monoid_bit_reader :: Monoid BitReader where
  mempty = BitReader mempty

instance monoid_bits_mut :: Monoid BitsMut where
  mempty = BitsMut new

read_from :: Uint8Array -> BitReader
read_from buffer = BitReader $ from_buffer buffer
