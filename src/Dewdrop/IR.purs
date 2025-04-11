module Dewdrop.IR where

import Dewdrop.Types
import Prelude

import Data.FingerTree (FingerTree)
import Data.Maybe (Maybe(..))
import Data.Pool (pool_allocate, pool_new, pool_set)
import Data.Tuple (Tuple(..))
import Record (merge)

ir_fn_context_new :: ModuleElementReference -> TypedIRFnContext
ir_fn_context_new name = do
  let 
    irs = pool_new
    Tuple return_type_id types = pool_allocate pool_new
    return_type = ProgramType (TypeVar return_type_id) Nothing

  { name
  , env: mempty
  , parameters: mempty
  , return_type
  , types
  , irs
  , body: mempty
  }

ir_new :: TypedIRKind -> ProgramTypeID -> TypedIRFnContext -> Tuple TypedIRID TypedIRFnContext
ir_new ir_kind program_type_id ctx@{ irs } = do
  let
    Tuple ir_id irs' = pool_allocate irs
    irs'' = pool_set ir_id (TypedIR ir_kind program_type_id) irs'

  Tuple ir_id $ merge { irs: irs'' } ctx
