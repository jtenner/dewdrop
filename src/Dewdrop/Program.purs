module Dewdrop.Program where

import Dewdrop.Passes.ConstraintGeneration
import Prelude

import Data.List (List(..))
import Data.Maybe (Maybe(..))
import Dewdrop.Types (ModuleID(..), FnTypeContext)


data ProgramPass = ConstraintGenerationPass ConstraintGenerationContext


main_module_id :: ModuleID
main_module_id = ModuleID Nothing Nil

-- compile_program

-- compile_main
-- build_import_tree
-- compile_files
-- link

