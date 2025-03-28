module Types
  where

import Prelude

import Control.Monad.Trampoline (done)
import Data.Graph (Graph)
import Data.Graph as Graph
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import FingerTree (FingerTree)
import FingerTree as FingerTree
import Parser (Identifier)


type TypeConstraints = FingerTree TypeConstraint
type Substitution = Map Int ProgramType
type ModuleReference = Tuple Int Identifier

data TypeConstraint
  = Matches ProgramType ProgramType
  | Equals ProgramType ProgramType
  | AtLeast ProgramType ProgramType
  | References ModuleReference

data ProgramType = ProgramType ProgramTypeKind (Maybe ModuleReference)

data ProgramTypeKind
  = FnType (Array ProgramType) ProgramType
  | I8
  | U8
  | I16
  | U16
  | I32
  | U32
  | I64
  | U64
  | F32
  | F64
  | Integer
  | Float
  | String
  | Bool
  | Numeric
  | TypeVar Int

builtin_i8_type :: ProgramType
builtin_i8_type = (ProgramType I8 Nothing)

builtin_u8_type :: ProgramType
builtin_u8_type = (ProgramType U8 Nothing)

builtin_i16_type :: ProgramType
builtin_i16_type = (ProgramType I16 Nothing)

builtin_u16_type :: ProgramType
builtin_u16_type = (ProgramType U16 Nothing)

builtin_i32_type :: ProgramType
builtin_i32_type = (ProgramType I32 Nothing)

builtin_u32_type :: ProgramType
builtin_u32_type = (ProgramType U32 Nothing)

builtin_i64_type :: ProgramType
builtin_i64_type = (ProgramType I64 Nothing)

builtin_u64_type :: ProgramType
builtin_u64_type = (ProgramType U64 Nothing)

builtin_f32_type :: ProgramType
builtin_f32_type = (ProgramType F32 Nothing)

builtin_f64_type :: ProgramType
builtin_f64_type = (ProgramType F64 Nothing)

builtin_integer_type :: ProgramType
builtin_integer_type = (ProgramType Integer Nothing)

builtin_float_type :: ProgramType
builtin_float_type = (ProgramType Float Nothing)

builtin_string_type :: ProgramType
builtin_string_type = (ProgramType String Nothing)

builtin_bool_type :: ProgramType
builtin_bool_type = (ProgramType Bool Nothing)

builtin_numeric_type :: ProgramType
builtin_numeric_type = (ProgramType Numeric Nothing)

type_var :: Int -> Maybe ModuleReference -> ProgramType
type_var i mr = (ProgramType (TypeVar i) mr)

type TypeIndex = Graph Int Int
type TypeEnv = Map Int ProgramType
type TypeResolver = Map Identifier ProgramType

type FnTypeContext =
  { next_id :: Int
  , type_index :: TypeIndex
  , parameters :: FingerTree ProgramType
  , return_type :: ProgramType
  , constraints :: TypeConstraints
  , type_env :: TypeEnv
  }

data TypeContext = TypeContextFn FnTypeContext

fn_context_new :: Maybe ModuleReference -> TypeContext
fn_context_new module_ref = do
  let
    return_type = type_var 0 module_ref
    next_id = 1
    type_index = Graph.insertVertex 0 Graph.empty
    parameters = FingerTree.empty
    constraints = FingerTree.empty
    type_env = Map.empty

  TypeContextFn
    { return_type
    , next_id
    , type_index
    , parameters
    , constraints
    , type_env
    }

