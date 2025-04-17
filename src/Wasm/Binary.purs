module Wasm.Binary where

import Prelude

import Data.BitStream (BitReader, BitWriter, read_buffer, read_u8, read_utf8_char, write_string, write_8, write_utf8_char)
import Data.FingerTree (FingerTree, foldl, size, snoc)
import Data.Int.Bits (shl, shr, (.&.), (.|.))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Data.Wasm.Module (HeapType(..), Lanes(..), Locals(..), RefType(..), TypeIndex(..), ValType(..))
import Node.Encoding (Encoding(..), byteLength)
import Util (from_uint8array, to_signed)

type EncoderFn a = BitWriter -> a -> BitWriter
type DecoderFn a = BitReader -> Maybe (Tuple a BitReader)

encode_vec :: ∀ (@u :: Type). EncoderFn u -> FingerTree u -> BitWriter -> BitWriter
encode_vec f n s = foldl f (encode_uleb128 (size n) s) n

decode_vec :: ∀ (@u :: Type). DecoderFn u -> BitReader -> Maybe (Tuple (FingerTree u) BitReader)
decode_vec f s = do
  Tuple n s' <- decode_uleb128 s
  go n mempty s'
  where
  go :: Int -> FingerTree u -> BitReader -> Maybe (Tuple (FingerTree u) BitReader)
  go 0 acc s'' = Just $ Tuple acc s''
  go n acc s'' = do
    Tuple v s''' <- f s''
    go (n - 1) (snoc v acc) s'''

encode_maybe :: ∀ (@u :: Type). EncoderFn u -> Maybe u -> BitWriter -> BitWriter
encode_maybe _ Nothing s = s
encode_maybe f (Just v) s = f s v

-- encode_uleb128 :: WasmInt -> BitStream -> BitStream
leb_bits_mask :: Int
leb_bits_mask = 0x7F -- 0b0111_1111

decode_uleb128 :: BitReader -> Maybe (Tuple Int BitReader)
decode_uleb128 s = go 0 0 s
  where
  go :: Int -> Int -> BitReader -> Maybe (Tuple Int BitReader)
  go acc count s'
    | count >= 10 = Nothing
    | otherwise = do
        Tuple v s'' <- read_u8 s'
        let acc' = (acc `shl` 7) + (v .&. leb_bits_mask)
        if v >= 0x80 then go acc' (count + 1) s''
        else Just $ Tuple acc' s''

decode_sleb128 :: BitReader -> Maybe (Tuple Int BitReader)
decode_sleb128 s = go 0 0 (read_u8 s)
  where
  go :: Int -> Int -> Maybe (Tuple Int BitReader) -> Maybe (Tuple Int BitReader)
  go _ _ Nothing = Nothing
  go acc count (Just (Tuple byte s'))
    | count >= 10 = Nothing
    | byte >= 0x80 = go (acc .|. ((byte .&. leb_bits_mask) `shl` (7 * count))) (count + 1) (read_u8 s')
    | otherwise = do
        let byte' = to_signed 7 $ byte .&. leb_bits_mask
        Just $ Tuple (acc .|. (byte' `shl` (7 * count))) s'

encode_uleb128 :: Int -> BitWriter -> BitWriter
encode_uleb128 v s = go 0 v s
  where
  go :: Int -> Int -> BitWriter -> BitWriter
  go count v' s'
    | count >= 10 = s'
    | v' <= 0x7F = write_8 v' s'
    | otherwise = do
        let
          byte = (v' .&. leb_bits_mask) .|. 0x80
          v'' = v' `shr` 7
        go (count + 1) v'' $ write_8 byte s'

encode_sleb128 :: Int -> BitWriter -> BitWriter
encode_sleb128 v s = go 0 v s
  where
  go :: Int -> Int -> BitWriter -> BitWriter
  go count v' s'
    | count >= 10 = s'
    | v' > 63 || v' < -64 = go (count + 1) (v' `shl` 7) $ write_8 ((v' .&. leb_bits_mask) .|. 0x80) s'
    | otherwise = write_8 (to_signed 7 v') s'

encode_char :: Char -> BitWriter -> BitWriter
encode_char = write_utf8_char

decode_char :: BitReader -> Maybe (Tuple Char BitReader)
decode_char = read_utf8_char

encode_string :: String -> BitWriter -> BitWriter
encode_string v s =
  let
    byte_length = byteLength v UTF8
    s' = encode_uleb128 byte_length s
  in
    write_string v s'

-- n [...items]
-- byte_length string

decode_string :: BitReader -> Maybe (Tuple String BitReader)
decode_string s = do
  Tuple byte_length s' <- decode_uleb128 s
  Tuple bytes s'' <- read_buffer byte_length s'
  str <- from_uint8array bytes Nothing Just
  pure $ Tuple str s''

encode_u8 :: Int -> BitWriter -> BitWriter
encode_u8 = write_8

decode_u8 :: BitReader -> Maybe (Tuple Int BitReader)
decode_u8 = read_u8

encode_lanes :: Lanes -> BitWriter -> BitWriter
encode_lanes (Lanes16 a b c d e f g h i j k l m n o p) bs =
  encode_u8 p $ encode_u8 o $ encode_u8 n $ encode_u8 m $ encode_u8 l $ encode_u8 k $ encode_u8 j $ encode_u8 i $ encode_u8 h $ encode_u8 g $ encode_u8 f $ encode_u8 e $ encode_u8 d $ encode_u8 c $ encode_u8 b $ encode_u8 a bs
encode_lanes (Lanes8 a b c d e f g h) bs =
  encode_u8 h $ encode_u8 g $ encode_u8 f $ encode_u8 e $ encode_u8 d $ encode_u8 c $ encode_u8 b $ encode_u8 a bs
encode_lanes (Lanes4 a b c d) bs =
  encode_u8 d $ encode_u8 c $ encode_u8 b $ encode_u8 a bs
encode_lanes (Lanes2 a b) bs =
  encode_u8 b $ encode_u8 a bs

decode_lanes :: Int -> BitReader -> Maybe (Tuple Lanes BitReader)
decode_lanes 16 s = do
  Tuple a s' <- decode_u8 s
  Tuple b s'' <- decode_u8 s'
  Tuple c s''' <- decode_u8 s''
  Tuple d s'''' <- decode_u8 s'''
  Tuple e s''''' <- decode_u8 s''''
  Tuple f s'''''' <- decode_u8 s'''''
  Tuple g s''''''' <- decode_u8 s''''''
  Tuple h s'''''''' <- decode_u8 s'''''''
  Tuple i s''''''''' <- decode_u8 s''''''''
  Tuple j s'''''''''' <- decode_u8 s'''''''''
  Tuple k s''''''''''' <- decode_u8 s''''''''''
  Tuple l s'''''''''''' <- decode_u8 s'''''''''''
  Tuple m s''''''''''''' <- decode_u8 s''''''''''''
  Tuple n s'''''''''''''' <- decode_u8 s'''''''''''''
  Tuple o s''''''''''''''' <- decode_u8 s''''''''''''''
  Tuple p s'''''''''''''''' <- decode_u8 s'''''''''''''''
  Just (Tuple (Lanes16 a b c d e f g h i j k l m n o p) s'''''''''''''''')
decode_lanes 8 s = do
  Tuple a s' <- decode_u8 s
  Tuple b s'' <- decode_u8 s'
  Tuple c s''' <- decode_u8 s''
  Tuple d s'''' <- decode_u8 s'''
  Tuple e s''''' <- decode_u8 s''''
  Tuple f s'''''' <- decode_u8 s'''''
  Tuple g s''''''' <- decode_u8 s''''''
  Tuple h s'''''''' <- decode_u8 s'''''''
  Just (Tuple (Lanes8 a b c d e f g h) s'''''''')
decode_lanes 4 s = do
  Tuple a s' <- decode_u8 s
  Tuple b s'' <- decode_u8 s'
  Tuple c s''' <- decode_u8 s''
  Tuple d s'''' <- decode_u8 s'''
  Just (Tuple (Lanes4 a b c d) s'''')
decode_lanes 2 s = do
  Tuple a s' <- decode_u8 s
  Tuple b s'' <- decode_u8 s'
  Just (Tuple (Lanes2 a b) s'')
decode_lanes _ _ = Nothing

encode_locals :: Locals -> BitWriter -> Maybe BitWriter
encode_locals (Locals count val_type) s =
  encode_val_type val_type $ encode_uleb128 count s

decode_locals :: BitReader -> Maybe (Tuple Locals BitReader)
decode_locals s = do
  Tuple val_type s' <- decode_val_type s
  Tuple count s'' <- decode_uleb128 s'
  Just (Tuple (Locals count val_type) s'')

encode_heap_type :: HeapType -> BitWriter -> Maybe BitWriter
encode_heap_type HeapTypeNoFunc s = Just $ write_8 0x73 s
encode_heap_type HeapTypeNoExtern s = Just $ write_8 0x72 s
encode_heap_type HeapTypeNone s = Just $ write_8 0x71 s
encode_heap_type HeapTypeFunc s = Just $ write_8 0x70 s
encode_heap_type HeapTypeExtern s = Just $ write_8 0x6F s
encode_heap_type HeapTypeAny s = Just $ write_8 0x6E s
encode_heap_type HeapTypeEq s = Just $ write_8 0x6D s
encode_heap_type HeapTypeI31 s = Just $ write_8 0x6C s
encode_heap_type HeapTypeStruct s = Just $ write_8 0x6B s
encode_heap_type HeapTypeArray s = Just $ write_8 0x6A s
encode_heap_type (HeapTypeIndex (TypeIndex i)) s = Just $ encode_sleb128 i s
encode_heap_type _ _ = Nothing

decode_heap_type :: BitReader -> Maybe (Tuple HeapType BitReader)
decode_heap_type s = case read_u8 s of
  Just (Tuple 0x73 s') -> Just $ Tuple HeapTypeNoFunc s'
  Just (Tuple 0x72 s') -> Just $ Tuple HeapTypeNoExtern s'
  Just (Tuple 0x71 s') -> Just $ Tuple HeapTypeNone s'
  Just (Tuple 0x70 s') -> Just $ Tuple HeapTypeFunc s'
  Just (Tuple 0x6F s') -> Just $ Tuple HeapTypeExtern s'
  Just (Tuple 0x6E s') -> Just $ Tuple HeapTypeAny s'
  Just (Tuple 0x6D s') -> Just $ Tuple HeapTypeEq s'
  Just (Tuple 0x6C s') -> Just $ Tuple HeapTypeI31 s'
  Just (Tuple 0x6B s') -> Just $ Tuple HeapTypeStruct s'
  Just (Tuple 0x6A s') -> Just $ Tuple HeapTypeArray s'
  _ -> case decode_sleb128 s of
    Just (Tuple index s') | index >= 0 -> Just $ Tuple (HeapTypeIndex (TypeIndex index)) s'
    _ -> Nothing

encode_ref_type :: RefType -> BitWriter -> Maybe BitWriter
encode_ref_type RefTypeNoFunc s = Just $ write_8 0x73 s
encode_ref_type (RefType HeapTypeNoFunc true) s = Just $ write_8 0x73 s
encode_ref_type RefTypeNoExtern s = Just $ write_8 0x72 s
encode_ref_type (RefType HeapTypeNoExtern true) s = Just $ write_8 0x72 s
encode_ref_type RefTypeNone s = Just $ write_8 0x71 s
encode_ref_type (RefType HeapTypeNone true) s = Just $ write_8 0x71 s
encode_ref_type RefTypeFunc s = Just $ write_8 0x70 s
encode_ref_type (RefType HeapTypeFunc true) s = Just $ write_8 0x70 s
encode_ref_type RefTypeExtern s = Just $ write_8 0x6F s
encode_ref_type (RefType HeapTypeExtern true) s = Just $ write_8 0x6F s
encode_ref_type RefTypeAny s = Just $ write_8 0x6E s
encode_ref_type (RefType HeapTypeAny true) s = Just $ write_8 0x6E s
encode_ref_type RefTypeEq s = Just $ write_8 0x6D s
encode_ref_type (RefType HeapTypeEq true) s = Just $ write_8 0x6D s
encode_ref_type RefTypeI31 s = Just $ write_8 0x6C s
encode_ref_type (RefType HeapTypeI31 true) s = Just $ write_8 0x6C s
encode_ref_type RefTypeStruct s = Just $ write_8 0x6B s
encode_ref_type (RefType HeapTypeStruct true) s = Just $ write_8 0x6B s
encode_ref_type RefTypeArray s = Just $ write_8 0x6A s
encode_ref_type (RefType HeapTypeArray true) s = Just $ write_8 0x6A s
-- general cases
encode_ref_type (RefType ht true) s = encode_heap_type ht $ write_8 0x63 s
encode_ref_type (RefType ht false) s = encode_heap_type ht $ write_8 0x64 s

decode_ref_type :: BitReader -> Maybe (Tuple RefType BitReader)
decode_ref_type s = case read_u8 s of
  Just (Tuple 0x73 s') -> Just $ Tuple RefTypeNoFunc s'
  Just (Tuple 0x72 s') -> Just $ Tuple RefTypeNoExtern s'
  Just (Tuple 0x71 s') -> Just $ Tuple RefTypeNone s'
  Just (Tuple 0x70 s') -> Just $ Tuple RefTypeFunc s'
  Just (Tuple 0x6F s') -> Just $ Tuple RefTypeExtern s'
  Just (Tuple 0x6E s') -> Just $ Tuple RefTypeAny s'
  Just (Tuple 0x6D s') -> Just $ Tuple RefTypeEq s'
  Just (Tuple 0x6C s') -> Just $ Tuple RefTypeI31 s'
  Just (Tuple 0x6B s') -> Just $ Tuple RefTypeStruct s'
  Just (Tuple 0x6A s') -> Just $ Tuple RefTypeArray s'
  Just (Tuple 0x63 s') -> case read_u8 s' of
    Just (Tuple 0x73 s'') -> Just $ Tuple RefTypeNoFunc s''
    Just (Tuple 0x72 s'') -> Just $ Tuple RefTypeNoExtern s''
    Just (Tuple 0x71 s'') -> Just $ Tuple RefTypeNone s''
    Just (Tuple 0x70 s'') -> Just $ Tuple RefTypeFunc s''
    Just (Tuple 0x6F s'') -> Just $ Tuple RefTypeExtern s''
    Just (Tuple 0x6E s'') -> Just $ Tuple RefTypeAny s''
    Just (Tuple 0x6D s'') -> Just $ Tuple RefTypeEq s''
    Just (Tuple 0x6C s'') -> Just $ Tuple RefTypeI31 s''
    Just (Tuple 0x6B s'') -> Just $ Tuple RefTypeStruct s''
    Just (Tuple 0x6A s'') -> Just $ Tuple RefTypeArray s''
    _ -> do
      Tuple ht s'' <- decode_heap_type s'
      case ht of
        HeapTypeNoFunc -> Just $ Tuple RefTypeNoFunc s''
        HeapTypeNoExtern -> Just $ Tuple RefTypeNoExtern s''
        HeapTypeNone -> Just $ Tuple RefTypeNone s''
        HeapTypeFunc -> Just $ Tuple RefTypeFunc s''
        HeapTypeExtern -> Just $ Tuple RefTypeExtern s''
        HeapTypeAny -> Just $ Tuple RefTypeAny s''
        HeapTypeEq -> Just $ Tuple RefTypeEq s''
        HeapTypeI31 -> Just $ Tuple RefTypeI31 s''
        HeapTypeStruct -> Just $ Tuple RefTypeStruct s''
        HeapTypeArray -> Just $ Tuple RefTypeArray s''
        _ -> Just $ Tuple (RefType ht true) s''
  Just (Tuple 0x64 s') -> do
    Tuple ht s'' <- decode_heap_type s'
    Just $ Tuple (RefType ht false) s''
  _ -> Nothing

decode_val_type :: BitReader -> Maybe (Tuple ValType BitReader)
decode_val_type s = case read_u8 s of
  Just (Tuple 0x7F s') -> Just $ Tuple ValTypeI32 s'
  Just (Tuple 0x7E s') -> Just $ Tuple ValTypeI64 s'
  Just (Tuple 0x7D s') -> Just $ Tuple ValTypeF32 s'
  Just (Tuple 0x7C s') -> Just $ Tuple ValTypeF64 s'
  Just (Tuple 0x7B s') -> Just $ Tuple ValTypeV128 s'
  _ -> do
    Tuple rt s' <- decode_ref_type s
    Just $ Tuple (ValTypeRefType rt) s'

encode_val_type :: ValType -> BitWriter -> Maybe BitWriter
encode_val_type ValTypeI32 s = Just $ write_8 0x7F s
encode_val_type ValTypeI64 s = Just $ write_8 0x7E s
encode_val_type ValTypeF32 s = Just $ write_8 0x7D s
encode_val_type ValTypeF64 s = Just $ write_8 0x7C s
encode_val_type ValTypeV128 s = Just $ write_8 0x7B s
encode_val_type (ValTypeRefType rt) s = encode_ref_type rt s
encode_val_type _ _ = Nothing
