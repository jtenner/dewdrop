module Data.BitStream where

import Prelude

import Data.ArrayBuffer.Types (Uint8Array)
import Data.Char (fromCharCode)
import Data.Char as Char
import Data.FingerTree (FingerTree, foldl, snoc)
import Data.Int (rem)
import Data.Int.Bits (shl, shr, (.&.))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Util (to_uint8array, uint8array_length)

type Index = Int
type Limit = Int
type Length = Int
data BitReaderSource
data BitWriterSource
data BitReader
  = BitReader BitReaderSource Index Limit
  | BitReaderEmpty

data BitWriter = BitWriter (FingerTree BitElement) Index

type Size = Int
type Value = Int

foreign import bit_reader_source :: ∀ (@source :: Type). source -> BitReaderSource
foreign import bit_reader_limit :: BitReaderSource -> Int
foreign import bit_reader_read :: Size -> Index -> BitReaderSource -> Value
foreign import bit_reader_read_buffer :: Length -> Index -> BitReaderSource -> Uint8Array

foreign import bit_writer_source :: Int -> BitWriterSource
foreign import bit_writer_to_bytes :: BitWriterSource -> Uint8Array
foreign import bit_writer_write :: Size -> Value -> BitWriterSource -> BitWriterSource
foreign import bit_writer_write_buffer :: Uint8Array -> BitWriterSource -> BitWriterSource

data BitElement
  = BitElement Size Value
  | BitElementBuffer Uint8Array

bit_reader :: Uint8Array -> BitReader
bit_reader = read_from

get_index :: BitReader -> Index
get_index (BitReader _ index _) = index
get_index BitReaderEmpty = 0

to_bytes :: BitWriter -> Uint8Array
to_bytes (BitWriter source index) = do
  let
    cap = (index `shr` 3) + (if index `rem` 8 == 0 then 0 else 1)
    target = bit_writer_source cap

  bit_writer_to_bytes $ foldl go target source

  where
  go :: BitWriterSource -> BitElement -> BitWriterSource
  go target (BitElementBuffer bytes) = bit_writer_write_buffer bytes target
  go target (BitElement size value) = bit_writer_write size value target

read_from :: Uint8Array -> BitReader
read_from source
  | uint8array_length source == 0 = BitReaderEmpty
  | otherwise = do
      let
        reader = bit_reader_source source
        limit = bit_reader_limit reader
      BitReader reader 0 limit

write :: Size -> Value -> BitWriter -> BitWriter
write size value (BitWriter source index) = do
  let
    index' = index + size
    source' = snoc (BitElement size value) source
  BitWriter source' index'

write_buffer :: Uint8Array -> BitWriter -> BitWriter
write_buffer bytes (BitWriter source index) = do
  let
    index' = index + uint8array_length bytes
    source' = snoc (BitElementBuffer bytes) source
  BitWriter source' index'

read :: Size -> BitReader -> Maybe (Tuple Value BitReader)
read _ BitReaderEmpty = Nothing
read size (BitReader source index limit)
  | index + size > limit = Nothing
  | otherwise = do
      let
        value = bit_reader_read size index source
        next = index + size
        reader = BitReader source next limit
        return_value = Tuple value reader
      pure return_value

read_signed :: Size -> BitReader -> Maybe (Tuple Value BitReader)
read_signed _ BitReaderEmpty = Nothing
read_signed size (BitReader source index limit)
  | index + size > limit = Nothing
  | otherwise = do
      let
        value = bit_reader_read size index source
        next = index + size
        reader = BitReader source next limit
        max_limit = 1 `shl` (size - 1)
      if value >= max_limit then pure $ Tuple (value - max_limit * 2) reader
      else pure $ Tuple value reader

read_u8 :: BitReader -> Maybe (Tuple Int BitReader)
read_u8 = read 8

read_s8 :: BitReader -> Maybe (Tuple Int BitReader)
read_s8 = read_signed 8

write_8 :: Int -> BitWriter -> BitWriter
write_8 = write 8

read_u16 :: BitReader -> Maybe (Tuple Int BitReader)
read_u16 = read 16

read_s16 :: BitReader -> Maybe (Tuple Int BitReader)
read_s16 = read_signed 16

write_16 :: Int -> BitWriter -> BitWriter
write_16 = write 16

read_u32 :: BitReader -> Maybe (Tuple Int BitReader)
read_u32 = read 32

read_s32 :: BitReader -> Maybe (Tuple Int BitReader)
read_s32 = read_signed 32

write_32 :: Int -> BitWriter -> BitWriter
write_32 = write 32

read_u64 :: BitReader -> Maybe (Tuple Int BitReader)
read_u64 = read 64

read_s64 :: BitReader -> Maybe (Tuple Int BitReader)
read_s64 = read_signed 64

write_64 :: Int -> BitWriter -> BitWriter
write_64 = write 64

-- 0x00: 0xxxxxxx
-- 0x06: 110xxxxx 10xxxxxx
-- 0x0E: 1110xxxx 10xxxxxx 10xxxxxx
-- 0x1E: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx

-- This implementation is correct but slow

type Accumulator = Int
type Count = Int

read_utf8_char :: BitReader -> Maybe (Tuple Char BitReader)
read_utf8_char = read_char

read_char :: BitReader -> Maybe (Tuple Char BitReader)
read_char reader = go_four reader
  where
  go_four :: BitReader -> Maybe (Tuple Char BitReader)
  go_four reader' = do
    Tuple value reader'' <- read 5 reader'
    if value == 0x1E then finish_four reader''
    else go_three reader'

  go_three :: BitReader -> Maybe (Tuple Char BitReader)
  go_three reader' = do
    Tuple value reader'' <- read 4 reader'
    if value == 0x0E then finish_three reader''
    else go_two reader'

  go_two :: BitReader -> Maybe (Tuple Char BitReader)
  go_two reader' = do
    Tuple value reader'' <- read 3 reader'
    if value == 0x06 then finish_two reader''
    else go_one reader'

  go_one :: BitReader -> Maybe (Tuple Char BitReader)
  go_one reader' = do
    Tuple value reader'' <- read 1 reader'
    if value == 0x00 then finish_one reader''
    else Nothing

  finish_one :: BitReader -> Maybe (Tuple Char BitReader)
  finish_one reader' = do
    Tuple value reader'' <- read 7 reader'
    char <- fromCharCode value
    pure $ Tuple char reader''

  finish_two :: BitReader -> Maybe (Tuple Char BitReader)
  finish_two reader' = do
    Tuple acc reader'' <- read 5 reader'
    go_finish acc reader'' 1

  finish_three :: BitReader -> Maybe (Tuple Char BitReader)
  finish_three reader' = do
    Tuple acc reader'' <- read 4 reader'
    go_finish acc reader'' 2

  finish_four :: BitReader -> Maybe (Tuple Char BitReader)
  finish_four reader' = do
    Tuple acc reader'' <- read 3 reader'
    go_finish acc reader'' 3

  go_finish :: Accumulator -> BitReader -> Count -> Maybe (Tuple Char BitReader)
  go_finish acc reader' 0 = do
    char <- fromCharCode acc
    pure $ Tuple char reader'

  go_finish acc reader' count | count > 0 = do
    Tuple flag reader'' <- read 1 reader'
    if flag == 2 then do
      Tuple value reader''' <- read 6 reader''
      go_finish ((acc `shl` 6) + value) reader''' (count - 1)
    else Nothing

  go_finish _ _ _ = Nothing

write_utf8_char :: Char -> BitWriter -> BitWriter
write_utf8_char char writer = go (Char.toCharCode char) writer

  where
  -- 0x3F = 0b0011_1111
  six_bit_mask = 0x3F
  -- 0x1F = 0b0001_1111
  five_bit_mask = 0x1F
  -- 0x0F = 0b0000_1111
  four_bit_mask = 0x0F
  -- 0x07 = 0b0000_0111
  three_bit_mask = 0x07

  go :: Int -> BitWriter -> BitWriter
  go value writer'
    -- < 0x80
    | value <= 0x7F = do
        let b0 = (value .&. 0x7F)
        write_8 b0 writer'

    -- < 0x800
    | value <= 0x7FF = do
        let
          b1 = (value .&. six_bit_mask)
          acc = (value `shr` 6)
          b0 = acc .&. five_bit_mask

        -- write: 0b110: 3
        --      : b0: 5
        --      : 0b10: 2
        --      : b1: 6
        write 6 b1 $ write 2 2 $ write 5 b0 $ write 3 6 writer'

    | value <= 0xFFFF = do
        let
          b2 = (value .&. six_bit_mask)
          acc = (value `shr` 6)
          b1 = acc .&. six_bit_mask
          acc' = (acc `shr` 6)
          b0 = acc' .&. four_bit_mask

        -- write: 0b1110: 4
        --      : b0: 4
        --      : 0b10: 2
        --      : b1: 6
        --      : 0b10: 2
        --      : b2: 6
        write 6 b2 $ write 2 2 $ write 6 b1 $ write 2 2 $ write 4 b0 $ write 4 14 writer'

    | otherwise = do
        let
          b3 = (value .&. six_bit_mask)
          acc = (value `shr` 6)
          b2 = acc .&. six_bit_mask
          acc' = (acc `shr` 6)
          b1 = acc' .&. six_bit_mask
          acc'' = (acc' `shr` 6)
          b0 = acc'' .&. three_bit_mask

        -- write: 0b11110: 5
        --      : b0: 3
        --      : 0b10: 2
        --      : b1: 6
        --      : 0b10: 2
        --      : b2: 6
        --      : 0b10: 2
        --      : b3: 6

        write 6 b3 $ write 2 2 $ write 6 b2 $ write 2 2 $ write 6 b1 $ write 2 2 $ write 3 b0 $ write 5 30 writer'

-- U+000000 U+00007F -> 0yyyzzzz	
-- U+000080 U+0007FF -> 110xxxyy 10yyzzzz 	
-- U+000800 U+00FFFF -> 1110wwww 10xxxxyy 10yyzzzz 	
-- U+010000 U+10FFFF -> 11110uvv 10vvwwww 10xxxxyy 10yyzzzz

write_string :: String -> BitWriter -> BitWriter
write_string str writer = write_buffer (to_uint8array str) writer

read_buffer :: Length -> BitReader -> Maybe (Tuple Uint8Array BitReader)
read_buffer _ BitReaderEmpty = Nothing
read_buffer length (BitReader source index limit)
  | index + (length `shl` 3) > limit = Nothing
  | otherwise = do
      let
        buf = bit_reader_read_buffer length index source
        reader = BitReader source (index + (length `shl` 3)) limit
      pure $ Tuple buf reader
