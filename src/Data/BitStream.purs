module Data.BitStream where

import Prelude
import Data.ArrayBuffer.Types (Uint8Array)
import Data.Tuple (Tuple(..))
import Effect (Effect)

data BitReader
data BitWriter

type Size = Int
type Value = Int

foreign import bit_reader :: ∀ (@source :: Type). source -> BitReader
foreign import bit_writer :: Int -> BitWriter

foreign import bit_writer_to_bytes :: BitWriter -> Uint8Array

foreign import bit_writer_write :: Size -> Value -> BitWriter -> Effect BitWriter

foreign import bit_reader_read :: Size -> BitReader -> Effect Value

write :: Size -> Value -> BitWriter -> Effect BitWriter
write = bit_writer_write

read :: Size -> BitReader -> Effect (Tuple Value BitReader)
read size reader = do
  value <- bit_reader_read size reader
  pure $ Tuple value reader