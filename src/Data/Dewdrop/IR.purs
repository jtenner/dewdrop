module Data.Dewdrop.IR
  ( IRConstKind(..)
  , IRContext(..)
  , IntValue
  , TypedIR(..)
  , TypedIRID
  , TypedIRKind(..)
  )
  where


import Data.Dewdrop.Identifier (Identifier)
import Data.Dewdrop.Types (Bounds, IRBoundsID, ModuleID, ProgramType)
import Data.FingerTree (FingerTree)
import Data.Pool (Pool, PoolKey)
import Data.Tuple (Tuple)

type TypedIRID = PoolKey TypedIR

newtype IRContext = IRContext
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

newtype TypedIR = TypedIR { kind :: TypedIRKind, type :: ProgramType }

data IRConstKind
  = IRConstInt Int
  | IRConstString String

data TypedIRKind
  = TypedIRBuiltin String (FingerTree TypedIRID)
  | TypedIRCall ModuleID Identifier (FingerTree TypedIRID)
  | TypedIRConst IRConstKind
  | TypedIRCallIndirect TypedIRID (FingerTree TypedIRID)
  | TypedIRCast TypedIRID
