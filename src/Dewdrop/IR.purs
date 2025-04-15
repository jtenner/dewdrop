module Dewdrop.IR where

import Prelude

import Data.Dewdrop.AST (ModuleElementReference)
import Data.Dewdrop.Types (IRBoundsID, IRContext(..), ProgramType(..), ProgramTypeKind(..), TypedIR(..), TypedIRID, TypedIRKind)
import Data.Maybe (Maybe(..))
import Data.Pool (pool_allocate, pool_new, pool_set)
import Data.Tuple (Tuple(..))
import Record (merge)

ir_fn_context_new :: ModuleElementReference -> IRContext
ir_fn_context_new ref = do
  let
    irs = pool_new
    Tuple return_type_id types = pool_allocate pool_new
    return_type = ProgramType (TypeVar return_type_id) Nothing

  IRContext
    { ref
    , env: mempty
    , parameters: mempty
    , return_type
    , types
    , irs
    , body: mempty
    }

ir_new :: TypedIRKind -> IRBoundsID -> IRContext -> Tuple TypedIRID IRContext
ir_new ir_kind ir_bounds_id (IRContext ctx@{ irs }) = do
  let
    Tuple ir_id irs' = pool_allocate irs
    irs'' = pool_set ir_id (TypedIR ir_kind ir_bounds_id) irs'

  Tuple ir_id $ IRContext $ merge { irs: irs'' } ctx

