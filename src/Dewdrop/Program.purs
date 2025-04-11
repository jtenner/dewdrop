module Dewdrop.Program where

import Data.Dewdrop.AST
import Data.Dewdrop.Identifier
import Prelude

import Data.Dewdrop.Compiler
import Data.Dewdrop.Types (ModuleContext(..), module_context_new)
import Data.FingerTree (FingerTree, from_array, uncons)
import Data.List (List(..))
import Data.Map (insert, lookup)
import Data.Maybe (Maybe(..))
import Data.Set as Set
import Data.Tuple (Tuple(..))
import Dewdrop.Parser (parse)
import Dewdrop.Passes.CollectExports
import Record (merge)

data CompilerAction
  = BeginProcess ModuleID
  | CollectExports CollectExportsProps

type Queue = FingerTree CompilerAction

exhaust :: Compiler -> Queue -> Maybe Compiler
exhaust compiler@{ seen } queue = case uncons queue of
  Nothing -> Just compiler
  Just (Tuple action queue') -> case action of

    BeginProcess module_id
      | Set.member module_id seen -> exhaust compiler queue'
      | otherwise -> do
          Tuple _module_ctx compiler' <- get_module compiler module_id

          let
            seen' = Set.insert module_id seen
            compiler'' = merge { seen: seen' } compiler'
            collect_exports = CollectExports { module_id }
            queue'' = from_array [ collect_exports ]
          exhaust compiler'' (queue' <> queue'')

    CollectExports ctx -> do
      compiler' <- CollectExports.run ctx compiler
      exhaust compiler' queue'

compile :: Compiler -> Maybe Compiler
compile compiler = do
  let queue = from_array [ BeginProcess compiler.main_module ]
  exhaust compiler queue
