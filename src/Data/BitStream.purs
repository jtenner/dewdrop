module Data.BitStream where

import Prelude

import Data.BigInt
import Data.Array

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
