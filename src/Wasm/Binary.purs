module Wasm.Binary where

import Prelude

import BitStream
import FingerTree

type EncoderFn a = BitStream -> a -> BitStream

data WasmInt = I32 Int
             | I64 Int

encode_vec :: ∀ (@u :: Type). EncoderFn u -> FingerTree u -> BitStream -> BitStream
encode_vec f n s = foldl f (encode_leb128 (size n)) n

encode_uleb128 :: WasmInt -> BitStream -> BitStream

