module Data.Dewdrop.IR where

import Prelude

import Data.Dewdrop.Identifier (Identifier)
import Data.Dewdrop.Types (ModuleID, Bounds, IRBoundsID, ProgramType, unbounded)
import Data.FingerTree (FingerTree)
import Data.Pool (Pool, PoolKey, pool_allocate, pool_set)
import Data.Tuple (Tuple(..))
import Record (merge)

type TypedIRID = PoolKey TypedIR

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

type IntValue = Int

data TypedIR = TypedIR TypedIRKind IRBoundsID

data IRConstKind
  = IRConstInt Int
  | IRConstString String

data TypedIRKind
  = TypedIRBuiltin String (FingerTree TypedIRID)
  | TypedIRCall ModuleID Identifier (FingerTree TypedIRID)
  | TypedIRConst IRConstKind
  | TypedIRCallIndirect TypedIRID (FingerTree TypedIRID)
  | TypedIRCast TypedIRID
