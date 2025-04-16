module Data.Dewdrop.System.Node where

import Prelude

import Data.ArrayBuffer.Types (Uint8Array)
import Data.BitStream (BitReader, bit_reader, read_from)
import Data.Dewdrop.System.System (class System, RawResourceID(..), ResourceStat)
import Data.Map (Map, insert, lookup)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Node.Path as Path
import Record (merge)

data NodeSystemContext = NodeSystemContext
  { cwd :: String
  , cache :: Map String Uint8Array
  , package_name :: String
  }

foreign import read_binary :: String -> Uint8Array
foreign import write_binary :: String -> Uint8Array -> Effect Unit

type Extension = String

module_extension :: Extension
module_extension = ".dew"

instance node_system :: System NodeSystemContext where
  system_dir_stat :: NodeSystemContext -> Array String -> Maybe (Array ResourceStat)
  system_dir_stat _ _ = Nothing

  system_set_raw :: NodeSystemContext -> RawResourceID -> Uint8Array -> Effect NodeSystemContext
  system_set_raw (NodeSystemContext ctx@{ cwd, cache }) (RawResourceID { path }) buffer = do
    let
      file_path = Path.concat $ [ cwd ] <> path
    _ <- write_binary file_path buffer
    pure $ NodeSystemContext $ merge { cache: insert file_path buffer cache } ctx

  system_get_raw :: NodeSystemContext -> RawResourceID -> Maybe (Tuple BitReader NodeSystemContext)
  system_get_raw (NodeSystemContext inner_ctx@{ cwd, cache }) (RawResourceID { path }) =
    let
      file_path = Path.concat $ [ cwd ] <> path
    in
      case lookup file_path cache of
        Just cache_lookup -> pure $ Tuple (read_from cache_lookup) $ NodeSystemContext inner_ctx
        Nothing -> do
          let
            binary_data = read_binary file_path
            cache' = insert file_path binary_data cache
          pure $ Tuple (read_from binary_data) $ NodeSystemContext $ merge { cache: cache' } inner_ctx
