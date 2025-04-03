module Dewdrop.Program where

import Prelude

import Data.FingerTree (FingerTree, from_array, uncons)
import Data.List (List(..))
import Data.Map (insert, lookup)
import Data.Maybe (Maybe(..))
import Data.Set as Set
import Data.Tuple (Tuple(..))
import Dewdrop.Parser (parse)
import Dewdrop.Passes.CollectExports (CollectExportsProps)
import Dewdrop.Passes.CollectExports as CollectExports
import Dewdrop.Passes.ConstraintGeneration (ConstraintGenerationProps)
import Dewdrop.Passes.ConstraintGeneration as ConstraintGeneration
import Dewdrop.Types (CompileTarget, Compiler, ModuleContext, ModuleID, System, compiler_new, fn_type_context_new, module_context_new)
import Record (merge)

data CompilerAction = BeginProcess ModuleID
                    | CollectExports CollectExportsProps
                    | ConstraintGeneration ConstraintGenerationProps


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
        constraint_generation = ConstraintGeneration { fn_type_context: fn_type_context_new
                                                     , generated_type_stack: Nil
                                                     , module_id
                                                     , expression_type_stack: Nil
                                                     }
        queue'' = from_array [ collect_exports, constraint_generation ]
      exhaust compiler'' (queue' <> queue'')
    
    CollectExports ctx -> do
      compiler' <- CollectExports.run ctx compiler
      exhaust compiler' queue'

    ConstraintGeneration ctx -> do
      compiler' <- ConstraintGeneration.run ctx compiler
      exhaust compiler' queue'
    

compile :: String -> System -> CompileTarget -> Maybe Compiler
compile package_name system target = do
  let compiler = compiler_new package_name system target
  let queue = from_array [ BeginProcess compiler.main_module ]
  exhaust compiler queue

get_module :: Compiler -> ModuleID -> Maybe (Tuple ModuleContext Compiler)
get_module compiler@{ modules, system } module_id = case lookup module_id modules of

  Nothing -> do
    resource_id <- system.to_resource_id module_id
    resource <- system.get_resource resource_id
    ast <- parse resource
    let module_ctx = module_context_new module_id resource_id ast
    let modules' = insert module_id module_ctx modules
    let compiler' = merge { modules: modules' } compiler
    Just $ Tuple module_ctx compiler'

  Just module_ctx -> Just $ Tuple module_ctx compiler
  