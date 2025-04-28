module Data.Bits where

import Data.ArrayBuffer.Types (ByteLength, Uint8Array)
import Data.BigInt (BigInt)
import Data.Maybe (Maybe(..))
import Data.Char (fromCharCode)
import Node.Buffer (Buffer)
import Prelude


data Bits

type Size = Int
type Index = Int
type Value = Int

foreign import zeros :: Size -> Bits
foreign import empty :: Bits
foreign import length :: Bits -> Int

foreign import read_impl :: Size -> Index -> Bits -> Int
foreign import read_signed_impl :: Size -> Index -> Bits -> Int
foreign import read_u64_impl :: Index -> Bits -> BigInt
foreign import read_i64_impl :: Index -> Bits -> BigInt
foreign import read_f32_impl :: Index -> Bits -> Number
foreign import read_f64_impl :: Index -> Bits -> Number

foreign import offset_impl :: Bits -> Int

foreign import read_utf8_char_impl :: Index -> Bits -> Int
foreign import read_buffer_impl :: Index -> ByteLength -> Bits -> Buffer
foreign import read_string_impl :: ByteLength -> Index -> Bits -> Maybe String -> (String -> Maybe String) -> Maybe String

foreign import from_string :: String -> BitReader
foreign import from_buffer_impl :: forall u. u -> Bits
foreign import from_words :: Array Int -> BitReader
foreign import to_words :: Bits -> Array Int
foreign import bits_to_hex :: Bits -> String
foreign import ord_bits_impl :: Bits -> Bits -> Int
foreign import append_bits :: Bits -> Bits -> Bits
foreign import concat_bits :: Bits -> Bits -> Bits
foreign import write_string_impl :: forall str. str -> BitsMut -> BitsMut
foreign import write_impl :: Size -> Value -> BitsMut -> BitsMut

foreign import write_64 :: BigInt -> BitsMut -> BitsMut

newtype BitReader = BitReader
  { bits :: Bits
  , offset :: Int
  }

instance show_bits :: Show Bits where
  show = bits_to_hex

instance show_bit_reader :: Show BitReader where
  show (BitReader n) = "(BitReader" <> show n <>")"

instance eq_bit_reader :: Eq BitReader where
  eq (BitReader { bits: l }) (BitReader { bits: r }) = (compare l r) == EQ

instance ord_bit_reader :: Ord BitReader where
  compare (BitReader { bits: l }) (BitReader { bits: r }) =
    case ord_bits_impl l r of
      0 -> EQ
      n | n > 0 -> GT
      _ -> LT

instance semigroup_bits :: Semigroup Bits where
  append = concat_bits

instance semigroup_bit_reader :: Semigroup BitReader where
  append (BitReader { bits: l }) (BitReader { bits: r }) = BitReader $ { bits: l <> r, offset: 0 }

instance monoid_bits :: Monoid Bits where
  mempty = empty

instance monoid_bit_reader :: Monoid BitReader where
  mempty = BitReader { bits: mempty, offset: 0 }

read_from :: Uint8Array -> BitReader
read_from buffer = BitReader $ { bits: from_buffer_impl buffer, offset: 0 }

read_from_buffer :: Buffer -> BitReader
read_from_buffer buffer = BitReader $ { bits: from_buffer_impl buffer, offset: 0 }

newtype BitsMut = BitsMut Bits

type Capacity = Int

bits_mut_new :: Capacity -> BitsMut
bits_mut_new capacity = BitsMut $ zeros capacity

write_bits :: BitsMut -> BitReader -> BitsMut
write_bits (BitsMut l) (BitReader { bits: r }) = BitsMut $ append_bits l r

type ReadResult kind = Maybe { head :: kind, tail :: BitReader }

read :: Size -> BitReader -> ReadResult Int
read size (BitReader { bits, offset })
  | offset + size <= length bits && size <= 32 = do
    let
      head = read_impl size offset bits
      offset' = offset + size
    pure $ { head, tail: BitReader { bits, offset: offset' } }
  | otherwise = Nothing

read_signed :: Size -> BitReader -> ReadResult Int
read_signed size (BitReader { bits, offset })
  | offset + size <= length bits && size <= 32 = do
    let
      head = read_signed_impl size offset bits
      offset' = offset + size
    pure $ { head, tail: BitReader { bits, offset: offset' } }
  | otherwise = Nothing

read_u8 :: BitReader -> ReadResult Int
read_u8 = read 8
read_u16 :: BitReader -> ReadResult Int
read_u16 = read 16
read_u32 :: BitReader -> ReadResult Int
read_u32 = read 32
read_u64 :: BitReader -> ReadResult BigInt
read_u64 (BitReader { bits, offset })
  | offset + 64 <= length bits = do
    let
      head = read_u64_impl offset bits
      offset' = offset + 64
    pure $ { head, tail: BitReader { bits, offset: offset' } }
  | otherwise = Nothing

read_i8 :: BitReader -> ReadResult Int
read_i8 = read_signed 8
read_i16 :: BitReader -> ReadResult Int
read_i16 = read_signed 16
read_i32 :: BitReader -> ReadResult Int
read_i32 = read_signed 32
read_i64 :: BitReader -> ReadResult BigInt
read_i64 (BitReader { bits, offset })
  | offset + 64 <= length bits = do
    let
      value = read_i64_impl offset bits
      offset' = offset + 64
    pure $ { head: value, tail: BitReader { bits, offset: offset' } }
  | otherwise = Nothing

read_f32 :: BitReader -> ReadResult Number
read_f32 (BitReader { bits, offset })
  | offset + 32 <= length bits = do
    let
      value = read_f32_impl offset bits
      offset' = offset + 32
    pure $ { head: value, tail: BitReader { bits, offset: offset' } }
  | otherwise = Nothing

read_f64 :: BitReader -> ReadResult Number
read_f64 (BitReader { bits, offset })
  | offset + 64 <= length bits = do
    let
      value = read_f64_impl offset bits
      offset' = offset + 64
    pure $ { head: value, tail: BitReader { bits, offset: offset' } }
  | otherwise = Nothing

read_utf8_char :: BitReader -> ReadResult Char
read_utf8_char (BitReader { bits, offset }) = do
  let
    char_code = read_utf8_char_impl offset bits
  
  head <- fromCharCode char_code
  pure $ { head, tail: BitReader { bits, offset: offset_impl bits } }
  
read_buffer :: Size -> BitReader -> ReadResult Buffer
read_buffer byte_count (BitReader { bits, offset })
  | offset + (byte_count * 8) <= length bits = do
    let
      value = read_buffer_impl offset byte_count bits
      offset' = offset + (byte_count * 8)
    pure $ { head: value, tail: BitReader { bits, offset: offset' } }
  | otherwise = Nothing

write_8 :: Int -> BitsMut -> BitsMut
write_8 = write_impl 8

write_16 :: Int -> BitsMut -> BitsMut
write_16 = write_impl 16

write_32 :: Int -> BitsMut -> BitsMut
write_32 = write_impl 32

write_string :: String -> BitsMut -> BitsMut
write_string str bits = write_string_impl str bits

write_char :: Char -> BitsMut -> BitsMut
write_char char bits = write_string_impl char bits

read_string :: ByteLength -> BitReader -> ReadResult String
read_string byte_length (BitReader { bits, offset }) = do
  -- ByteLength -> Index -> Bits -> Maybe String -> (String -> Maybe String) -> Maybe String
  head <- read_string_impl byte_length offset bits Nothing Just
  pure { head, tail: BitReader { bits, offset: offset_impl bits } }

instance ord_bits :: Ord Bits where
  compare l r = case ord_bits_impl l r of
    -1 -> LT
    1 -> GT
    _ -> EQ

instance eq_bits :: Eq Bits where
  eq l r = EQ == (compare l r)