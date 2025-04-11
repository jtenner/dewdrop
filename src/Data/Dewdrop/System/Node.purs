module Data.Dewdrop.System.Node where

import Data.BitStream (BitStream)

import Data.Dewdrop.System.System (class System)
import Data.List (List(..))
import Data.Map (Map)
import Data.Maybe (Maybe(..))

data NodeSystemContext = NodeSystemContext
  { cwd :: String
  , cache :: Map String BitStream
  }

instance node_system :: System NodeSystemContext where
  -- system_get_resource :: ctx -> SystemResourceID -> Maybe SystemResource
  -- system_list_resources :: ctx -> List ResourceStat
  -- system_set_resource :: ctx -> SystemResourceID -> SystemResource -> ctx
  -- system_get_resource (NodeSystemContext ctx@{ cwd, cache }) (RawResourceID { path }) = Nothing
  system_get_resource _ _ = Nothing
  system_list_resources _ = Nil
  system_set_resource n _ _ = n

