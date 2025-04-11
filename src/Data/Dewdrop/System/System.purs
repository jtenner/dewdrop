module Data.Dewdrop.System.System where

import Prelude

import Data.BitStream (BitStream)
import Data.Dewdrop.AST (Module(..))
import Data.List (List)
import Data.Maybe (Maybe)

data SystemResourceID
  = ModuleResourceID { path :: List String, package :: String }
  | RawResourceID { path :: String }

data SystemResource = SystemResource { id :: SystemResourceID, raw_path :: String, data :: BitStream, kind :: SystemResourceKind }

data SystemResourceKind
  = SystemModule Module
  | SystemRaw BitStream

data ResourceStat = ResourceStat { id :: SystemResourceID, size :: Int, mtime :: Int, raw_path :: String }

class System ctx where
  system_get_resource :: ctx -> SystemResourceID -> Maybe SystemResource
  system_list_resources :: ctx -> List ResourceStat
  system_set_resource :: ctx -> SystemResourceID -> SystemResource -> ctx
