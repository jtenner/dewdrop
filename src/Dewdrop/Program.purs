module Dewdrop.Program where

import Data.Dewdrop.AST
import Data.Dewdrop.Compiler
import Data.Dewdrop.Identifier
import Dewdrop.Passes.CollectExports
import Prelude

import Data.Dewdrop.System.System (class System, system_get_raw, to_resource_id)
import Data.Dewdrop.Types (ModuleContext(..), module_context_new)
import Data.FingerTree (FingerTree, from_array, uncons)
import Data.List (List(..))
import Data.Map (insert, lookup)
import Data.Maybe (Maybe(..))
import Data.Set (Set)
import Data.Set as Set
import Data.Tuple (Tuple(..))
import Dewdrop.Parser (parse)
import Dewdrop.Passes.CollectExports as CollectExports
import Record (merge)

data CompilerAction
  = BeginProcess ModuleID
  | CollectExports CollectExportsProps

data UniqueQueue = UniqueQueue
  { actions :: FingerTree CompilerAction
  , seen :: Set ModuleID
  }

exhaust :: ∀ (@system_ctx :: Type). System system_ctx => Compiler system_ctx -> UniqueQueue -> Maybe (Compiler system_ctx)
exhaust compiler@(Compiler { system_ctx }) queue@(UniqueQueue { actions, seen }) = case uncons actions of
  Nothing -> Just compiler
  Just (Tuple action actions') -> case action of
    BeginProcess module_id
      | Set.member module_id seen -> exhaust compiler $ UniqueQueue { actions: actions', seen }
      | otherwise -> do
        let resource_id = to_resource_id system_ctx module_id
        Tuple reader system_ctx' <- system_get_raw system_ctx resource_id
        
        -- Parse the module

        -- TODO: collect_exports = CollectExports { module_id }
        
        exhaust compiler'' (queue' <> queue'')

    CollectExports ctx -> do
      compiler' <- CollectExports.run ctx compiler
      exhaust compiler' queue'

compile :: Compiler -> Maybe Compiler
compile compiler = do
  let queue = from_array [ BeginProcess compiler.main_module ]
  exhaust compiler queue
