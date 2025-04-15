module Data.Dewdrop.IR where

import Prelude

import Data.Dewdrop.Compiler (ModuleElementReference)
import Data.Dewdrop.Identifier (Identifier)
import Data.Dewdrop.Types (Bounds, IRBoundsID, ProgramType, unbounded)
import Data.FingerTree (FingerTree)
import Data.Pool (Pool, PoolKey, pool_allocate, pool_set)
import Data.Tuple (Tuple(..))
import Record (merge)


data IRContext = IRContext
  { env :: FingerTree (Tuple Identifier IRBoundsID)

  -- To keep track of type variables
  , parameters :: FingerTree (Tuple Identifier TypedIRID)
  , return_type :: ProgramType

  -- To keep track of type variables
  , types :: Pool Bounds

  -- to index ir nodes
  , irs :: Pool TypedIR

  , body :: FingerTree TypedIR
  }


type_var_new :: IRContext -> Tuple IRBoundsID IRContext
type_var_new (IRContext ctx@{ types }) = do
  let
    Tuple type_id types' = pool_allocate types
    types'' = pool_set type_id unbounded types'
  Tuple type_id $ IRContext $ merge { types: types'' } ctx

type TypedIRID = PoolKey TypedIR
type IntValue = Int

data TypedIR = TypedIR TypedIRKind IRBoundsID

data IRConstKind
  = IRConstInt Int
  | IRConstString String

data TypedIRKind
  = TypedIRBuiltin String (FingerTree TypedIRID)
  | TypedIRCall ModuleElementReference (FingerTree TypedIRID)
  | TypedIRConst IRConstKind
  | TypedIRCallIndirect TypedIRID (FingerTree TypedIRID)
  | TypedIRCast TypedIRID