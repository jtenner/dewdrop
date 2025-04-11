module Dewdrop.IR where

import Data.Dewdrop.AST (ModuleElementReference)
import Prelude

import Data.Dewdrop.Types (IRContext(..), ProgramType(..), ProgramTypeID, ProgramTypeKind(..), TypedIR(..), TypedIRID, TypedIRKind)
import Data.Maybe (Maybe(..))
import Data.Pool (pool_allocate, pool_new, pool_set)
import Data.Tuple (Tuple(..))
import Record (merge)

ir_fn_context_new :: ModuleElementReference -> IRContext
ir_fn_context_new name = do
  let
    irs = pool_new
    Tuple return_type_id types = pool_allocate pool_new
    return_type = ProgramType (TypeVar return_type_id) Nothing

  IRContext
    { name
    , env: mempty
    , parameters: mempty
    , return_type
    , types
    , irs
    , body: mempty
    }

ir_new :: TypedIRKind -> ProgramTypeID -> IRContext -> Tuple TypedIRID IRContext
ir_new ir_kind program_type_id (IRContext ctx@{ irs }) = do
  let
    Tuple ir_id irs' = pool_allocate irs
    irs'' = pool_set ir_id (TypedIR ir_kind program_type_id) irs'

  Tuple ir_id $ IRContext $ merge { irs: irs'' } ctx
