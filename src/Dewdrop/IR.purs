module Dewdrop.IR where

import Data.Maybe
import Prelude

import Data.Dewdrop.IR (IRContext(..), TypedIR(..), TypedIRID, TypedIRKind(..), IRConstKind(..))
import Data.Dewdrop.Types (IRBoundsID, ProgramType(..), ProgramTypeKind(..), builtin_integer_type)
import Data.FingerTree (from_array)
import Data.Pool (pool_allocate, pool_get, pool_new, pool_set)
import Data.Tuple (Tuple(..))
import Record (merge)

resolve_bounds :: IRContext -> Bounds -> Bounds -> Maybe ProgramType
resolve_bounds ctx (Bounds { upper: upper_left, lower: lower_left }) (Bounds { upper: upper_right, lower: lower_right }) = do
  upper_bound <- go_at_most ctx Top $ upper_left <> upper_right
  lower_bound <- go_at_least ctx Bottom $ lower_left <> lower_right


ir_fn_context_new :: IRContext
ir_fn_context_new = do
  let
    irs = pool_new
    Tuple return_type_id types = pool_allocate pool_new
    return_type = ProgramType (TypeVar return_type_id)

  IRContext
    { env: mempty
    , parameters: mempty
    , return_type
    , types
    , irs
    , body: mempty
    }

ir_new :: TypedIRKind -> ProgramType -> IRContext -> Tuple TypedIRID IRContext
ir_new ir_kind ir_type (IRContext ctx@{ irs }) = do
  let
    Tuple ir_id irs' = pool_allocate irs
    irs'' = pool_set ir_id (TypedIR { kind: ir_kind, type: ir_type }) irs'

  Tuple ir_id $ IRContext $ merge { irs: irs'' } ctx

ir_int_const :: Int -> IRContext -> Tuple TypedIRID IRContext
ir_int_const value ctx = do
  let
    kind = TypedIRConst (IRConstInt value)
    ir_type = builtin_integer_type

  ir_new kind ir_type ctx 

ir_add :: TypedIRID -> TypedIRID -> IRContext -> Maybe (Tuple TypedIRID IRContext)
ir_add left_id right_id ctx@{ irs } = do
  TypedIR { type: left_type } <- pool_get left_id irs
  TypedIR { type: right_type } <- pool_get right_id irs
  let
    kind = TypedIRBuiltin "~dewdrop.add" $ from_array [left_id, right_id]
  bounds_type <- resolve_bounds ctx $ (at_least left_type) <> (at_least right_type)

  pure $ ir_new kind bounds_type ctx
-- TypedIRBuiltin String (FingerTree TypedIRID)
-- TypedIRCall ModuleID Identifier (FingerTree TypedIRID)
-- TypedIRConst IRConstKind
-- TypedIRCallIndirect TypedIRID (FingerTree TypedIRID)
-- TypedIRCast TypedIRID