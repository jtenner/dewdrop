module Data.Dewdrop.System.System where

import Data.ArrayBuffer.Types (Uint8Array)
import Data.BitStream (BitReader)
import Data.Maybe (Maybe)
import Data.Tuple (Tuple)
import Effect (Effect)

data RawResourceID = RawResourceID { path :: Array String }

data ResourceStat = ResourceStat { id :: RawResourceID, size :: Int, mtime :: Int, raw_path :: String }

class System ctx where
  system_get_raw :: ∀ (@source :: Type). ctx -> RawResourceID -> Maybe (Tuple BitReader ctx)
  system_dir_stat :: ctx -> Array String -> Maybe (Array ResourceStat)
  system_set_raw :: ctx -> RawResourceID -> Uint8Array -> Effect ctx
