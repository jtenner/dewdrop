module Data.Bits where

import Data.ArrayBuffer.Types (ByteLength, Uint8Array)
import Data.BigInt (BigInt)
import Prelude


data Bits

type Size = Int
type Index = Int

foreign import zeros :: Size -> Bits
foreign import empty :: Bits
foreign import read_impl :: Size -> Index -> Bits -> Int
foreign import read_signed_impl :: Size -> Index -> Bits -> Int
foreign import length :: Bits -> Int
foreign import read_u8_impl :: Index -> BitReader -> Int
foreign import read_u16_impl :: Index -> BitReader -> Int
foreign import read_u32_impl :: Index -> BitReader -> Int
foreign import read_u64_impl :: Index -> BitReader -> BigInt
foreign import read_i8_impl :: Index -> BitReader -> Int
foreign import read_i16_impl :: Index -> BitReader -> Int
foreign import read_i32_impl :: Index -> BitReader -> Int
foreign import read_i64_impl :: Index -> BitReader -> BigInt
foreign import read_f32_impl :: Index -> BitReader -> Number
foreign import read_f64_impl :: Index -> BitReader -> Number
foreign import read_utf8_char_impl :: Index -> BitReader -> Int
foreign import read_buffer_impl :: Index -> ByteLength -> BitReader -> Uint8Array
foreign import from_string :: String -> BitReader
foreign import from_buffer :: Uint8Array -> Bits
foreign import from_words :: Array Int -> BitReader
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

read_from :: Uint8Array -> BitReader
read_from buffer = BitReader $ from_buffer buffer

newtype BitsMut = BitsMut Bits

type Capacity = Int

bits_mut_new :: Capacity -> BitsMut
bits_mut_new capacity = BitsMut $ zeros capacity

write_bits :: BitsMut -> BitReader -> BitsMut
write_bits (BitsMut l) (BitReader r) = BitsMut $ append_bits l r

