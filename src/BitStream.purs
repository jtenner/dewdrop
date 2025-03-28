module BitStream
  ( BitStream
  , BitStreamElement
  , Mask
  , Size
  , Value
  , match
  , read_bits
  , read_i16
  , read_i32
  , read_i64
  , read_i8
  , read_u16
  , read_u32
  , read_u64
  , read_u8
  , read_utf8_char
  , write_bits
  , write_string
  , write_u16
  , write_u32
  , write_u64
  , write_u8
  , write_utf8_char
  )
  where

import Prelude

import Data.Array as Array
import Data.Char (fromCharCode, toCharCode)
import Data.Int.Bits (shl, shr, (.&.), (.|.))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import FingerTree (FingerTree, uncons, cons, snoc)
import Util (to_chars, to_unsigned)

type Value = Int
type Size = Int
type BitStreamElement = Tuple Value Size
type BitStream = FingerTree BitStreamElement
type BitIndex = Int
type Mask = Int

read_bits :: Size -> BitStream -> Maybe (Tuple Value BitStream)
read_bits n bs
  | n <= 0 = Nothing  -- Restrict n >=1
  | otherwise = go n 0 $ uncons bs
  where
    go :: Size -> Value -> Maybe (Tuple BitStreamElement BitStream) -> Maybe (Tuple Value BitStream)
    go _ _ Nothing = Nothing

    go left acc (Just (Tuple l@(Tuple v s) bs'))
      | s == left = Just $ Tuple (acc `shl` s + v) bs'
      | left > s = do
        let acc' = acc `shl` s .|. v
        go (left - s) acc' $ uncons bs'
      | otherwise = do
        let Tuple (Tuple v' _) r = split l left
        let acc' = (acc `shl` s) .|. v'
        Just $ Tuple acc' $ cons r bs'

write_bits :: Size -> Value -> BitStream -> BitStream
write_bits n _ s | n <= 0 = s
write_bits n v s = let
  v' = to_unsigned n v
  in snoc (Tuple v' n) s

read_u8 :: BitStream -> Maybe (Tuple Value BitStream)
read_u8 = read_bits 8

read_u16 :: BitStream -> Maybe (Tuple Value BitStream)
read_u16 = read_bits 16

read_u32 :: BitStream -> Maybe (Tuple Value BitStream)
read_u32 = read_bits 32

read_u64 :: BitStream -> Maybe (Tuple Value BitStream)
read_u64 = read_bits 64

read_i8 :: BitStream -> Maybe (Tuple Value BitStream)
read_i8 = read_signed 8

read_i16 :: BitStream -> Maybe (Tuple Value BitStream)
read_i16 = read_signed 16

read_i32 :: BitStream -> Maybe (Tuple Value BitStream)
read_i32 = read_signed 32

read_i64 :: BitStream -> Maybe (Tuple Value BitStream)
read_i64 = read_signed 64

negative_mask :: Size -> Mask
negative_mask n = 1 `shl` (n - 1)

read_signed :: Size -> BitStream -> Maybe (Tuple Value BitStream)
read_signed n s = do
  Tuple v s' <- read_bits n s
  let
    mask = negative_mask n
    is_negative = (v .&. mask) /= 0
    v' = if is_negative then v - mask else v
  Just $ Tuple v' s'

write_u8 :: Value -> BitStream -> BitStream
write_u8 = write_bits 8

write_u16 :: Value -> BitStream -> BitStream
write_u16 = write_bits 16

write_u32 :: Value -> BitStream -> BitStream
write_u32 = write_bits 32

write_u64 :: Value -> BitStream -> BitStream
write_u64 = write_bits 64

match :: Size -> Value -> BitStream -> Maybe (Tuple Value BitStream)
match n _ _ | n <= 0 = Nothing
match n v s = do
  Tuple v' s' <- read_bits n s
  if v == v' then Just $ Tuple v s' else Nothing

read_utf8_char :: BitStream -> Maybe (Tuple Char BitStream)
read_utf8_char s = case read_bits 8 s of
  -- if there are multiple bytes...
  Just (Tuple v s') | (v .&. 0xF8) == 0xF0 -> go 3 (v .&. 0x07) s'
  Just (Tuple v s') | (v .&. 0xF0) == 0xE0 -> go 2 (v .&. 0x0F) s'
  Just (Tuple v s') | (v .&. 0xC0) == 0xC0 -> go 1 (v .&. 0x1F) s'
  Just (Tuple v s') | (v .&. 0x80) == 0x00 -> go 0 (v .&. 0x7F) s'
  _ -> Nothing
  where
    go :: Int -> Value -> BitStream -> Maybe (Tuple Char BitStream)
    go 0 v s' = do
      v' <- fromCharCode v 
      Just $ Tuple v' s'
    
    go n v s' = do
      Tuple v' s'' <- read_bits 8 s'
      go (n - 1) ((v `shl` 6) + (v' .&. 0x3F)) s''

write_utf8_char :: Char -> BitStream -> BitStream
write_utf8_char c s = go (toCharCode c) s
  where
    go :: Value -> BitStream -> BitStream
    go value s'
      | value <= 0x7F = write_u8 value s' -- 0 .. 0x7F
      | value <= 0x7FF = do -- 80 .. 7FF
        let s'' = write_u8 ((value `shr` 6) .|. 0xC0) s'
        write_u8 ((value .&. 0x3F) .|. 0x80) s''
      | value <= 0xFFFF = do -- 800 .. FFFF
        let s'' = write_u8 ((value `shr` 12) .|. 0xE0) s'
        let s''' = write_u8 (((value `shr` 6) .&. 0x3F) .|. 0x80) s''
        write_u8 ((value .&. 0x3F) .|. 0x80) s'''
      | value <= 0x10FFFF = do -- 10000 .. 10FFFF
        let s'' = write_u8 ((value `shr` 18) .|. 0xF0) s'
        let s''' = write_u8 (((value `shr` 12) .&. 0x3F) .|. 0x80) s''
        let s'''' = write_u8 (((value `shr` 6) .&. 0x3F) .|. 0x80) s'''
        write_u8 ((value .&. 0x3F) .|. 0x80) s''''
      | otherwise = s

write_string :: String -> BitStream -> BitStream
write_string str bs = Array.foldl (flip write_utf8_char) bs (to_chars str)

split :: BitStreamElement -> BitIndex -> Tuple BitStreamElement BitStreamElement
split (Tuple v s) at 
  | at >= s = Tuple (Tuple v s) (Tuple 0 0)
  | at <= 0 = Tuple (Tuple 0 0) (Tuple v s)
  | otherwise = do
    let
      mask = (1 `shl` at) - 1
      lv = v `shr` at
      ls = s - at
      rv = v .&. mask
      rs = at
    Tuple (Tuple lv ls) (Tuple rv rs)

