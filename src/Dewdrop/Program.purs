module Dewdrop.Program where

import Data.Dewdrop.Compiler (Compiler(..), ModuleID)
import Dewdrop.Passes.CollectExports (CollectExportsProps)
import Prelude

import Data.Dewdrop.System.System (class System)
import Data.FingerTree (FingerTree, uncons)
import Data.Maybe (Maybe(..))
import Data.Set (Set)
import Data.Set as Set
import Data.Tuple (Tuple(..))
import Dewdrop.Passes.CollectExports as CollectExports

data CompilerAction
  = BeginProcess ModuleID
  | CollectExports CollectExportsProps

data UniqueQueue = UniqueQueue
  { actions :: FingerTree CompilerAction
  , seen :: Set ModuleID
  }

unique_queue_new :: UniqueQueue
unique_queue_new = UniqueQueue { actions: mempty, seen: Set.empty }

enqueue :: CompilerAction -> UniqueQueue -> UniqueQueue
enqueue action (UniqueQueue { actions, seen }) = UniqueQueue { actions: actions <> (pure action), seen }

exhaust :: ∀ (@system_ctx :: Type). System system_ctx => Compiler system_ctx -> UniqueQueue -> Maybe (Compiler system_ctx)
exhaust compiler (UniqueQueue { actions, seen }) = case uncons actions of
  Nothing -> Just compiler
  Just (Tuple action actions') -> case action of
    BeginProcess module_id
      | Set.member module_id seen -> exhaust compiler $ UniqueQueue { actions: actions', seen }
      | otherwise -> do
        -- let resource_id = to_resource_id system_ctx module_id
        -- Tuple reader system_ctx' <- system_get_raw system_ctx resource_id
        
        -- Parse the module

        -- TODO: collect_exports = CollectExports { module_id }
        Nothing
        -- exhaust compiler'' (queue' <> queue'')

    CollectExports ctx -> do
      compiler' <- CollectExports.run ctx compiler
      let queue' = UniqueQueue { actions: actions', seen }
      exhaust compiler' queue'
      
compile :: ∀ (@system_ctx :: Type). System system_ctx => Compiler system_ctx -> Maybe (Compiler system_ctx)
compile compiler@(Compiler { main_module }) = do
  let queue = enqueue (BeginProcess main_module) unique_queue_new
  exhaust compiler queue
