module Dewdrop.Program where

import Prelude

import Data.Dewdrop.Compiler (Compiler(..), ModuleID, module_context_new, to_resource_id)
import Data.Dewdrop.System.System (class System, system_get_raw)
import Data.FingerTree (FingerTree, uncons)
import Data.Map (insert)
import Data.Maybe (Maybe(..))
import Data.Set (Set)
import Data.Set as Set
import Data.Tuple (Tuple(..))
import Dewdrop.Parser (parse)
import Dewdrop.Passes.CollectExports (CollectExportsProps(..))
import Dewdrop.Passes.CollectExports as CollectExports
import Record (merge)

data CompilerAction
  = BeginProcess ModuleID
  | CollectExportsAction CollectExportsProps

data UniqueQueue = UniqueQueue
  { actions :: FingerTree CompilerAction
  , seen :: Set ModuleID
  }

unique_queue_new :: UniqueQueue
unique_queue_new = UniqueQueue { actions: mempty, seen: Set.empty }

enqueue :: CompilerAction -> UniqueQueue -> UniqueQueue
enqueue action (UniqueQueue { actions, seen }) = UniqueQueue { actions: actions <> (pure action), seen }

dequeue :: UniqueQueue -> Maybe (Tuple CompilerAction UniqueQueue)
dequeue (UniqueQueue { actions, seen }) = case uncons actions of
  Nothing -> Nothing
  Just (Tuple action actions') -> Just (Tuple action $ UniqueQueue { actions: actions', seen })

seen :: ModuleID -> UniqueQueue -> Boolean
seen module_id (UniqueQueue { seen }) = Set.member module_id seen

exhaust :: ∀ (@system_ctx :: Type). System system_ctx => Compiler system_ctx -> UniqueQueue -> Maybe (Compiler system_ctx)
exhaust compiler@(Compiler { system_ctx, package_name }) queue = case dequeue queue of
  Nothing -> Just compiler
  Just (Tuple action queue') -> case action of
    BeginProcess module_id
      | seen module_id queue' -> exhaust compiler queue'
      | otherwise -> do
          -- Get the resource
          Tuple resource system_ctx' <- system_get_raw system_ctx $ to_resource_id module_id package_name

          -- Parse the module
          ast <- parse resource

          let
            -- Create the module context for this module
            module_ctx = module_context_new module_id ast

            -- update the compiler state
            Compiler inner_compiler@{ modules } = compiler
            compiler'' = Compiler $ merge { modules: insert module_id module_ctx modules, system_ctx: system_ctx' } inner_compiler
            -- Enqueue collect exports
            queue'' = enqueue (CollectExportsAction $ CollectExportsProps { module_id }) queue'

          -- exhaust compiler'' (queue' <> queue'')
          exhaust compiler'' queue''

    CollectExportsAction ctx -> do
      compiler' <- CollectExports.run ctx compiler
      exhaust compiler' queue'

compile :: ∀ (@system_ctx :: Type). System system_ctx => Compiler system_ctx -> Maybe (Compiler system_ctx)
compile compiler@(Compiler { main_module }) = do
  let queue = enqueue (BeginProcess main_module) unique_queue_new
  exhaust compiler queue
