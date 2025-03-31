module Dewdrop.Passes.ConstraintGeneration where

import Dewdrop.Types
import Prelude

import Data.List (List)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Visitor.Pattern (class Pass, ignore, visit)

type ConstraintGenerationContext =
  { program :: Program
  , fn_context :: FnTypeContext
  , fn_identifiers :: List Identifier  
  }

constraint_generation_context_new :: Program -> ConstraintGenerationContext
constraint_generation_context_new program =
  { program: program
  , fn_context: empty_fn_type_context
  , fn_identifiers: mempty
  }

run :: Module -> Program -> Maybe ConstraintGenerationContext
run mod program = do
  let ctx = constraint_generation_context_new program
  Tuple { program: program' } _ <- visit mod ctx
  Just program'

instance constrant_generation_module_pass :: Pass Module ConstraintGenerationContext where
  enter = ignore
  exit = ignore

instance constraint_generation_declaration_pass :: Pass ModuleDeclaration ConstraintGenerationContext where
  enter = ignore
  exit = ignore
