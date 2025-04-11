module Data.Dewdrop.Types where

import Prelude

import Data.Dewdrop.AST (Module(..), ModuleElementReference(..), ModuleID(..))
import Data.Dewdrop.Identifier (Identifier)
import Data.Dewdrop.Visitor (class Pass, class Visitable, visit, visit_all)
import Data.FingerTree (FingerTree)
import Data.List (List)
import Data.Map (Map)
import Data.Maybe (Maybe(..))
import Data.Pool (Pool, PoolKey, pool_allocate, pool_set)
import Data.Tuple (Tuple(..))
import Record (merge)


-- | Upper and Lower bounds in *that* order
data Bounds = Bounds { upper :: FingerTree ProgramType, lower :: FingerTree ProgramType }

type TypedIRFnContext =
  { name :: ModuleElementReference

  , env :: FingerTree (Tuple Identifier ProgramTypeID)

  -- To keep track of type variables
  , parameters :: FingerTree (Tuple Identifier TypedIRID)
  , return_type :: ProgramType

  -- To keep track of type variables
  , types :: Pool ProgramType

  -- to index ir nodes
  , irs :: Pool TypedIR

  , body :: FingerTree TypedIR
  }

bounds_new :: Bounds
bounds_new = Bounds { upper: mempty, lower: mempty }

type_var_new :: TypedIRFnContext -> Tuple ProgramTypeID TypedIRFnContext
type_var_new ctx@{ types } = do
  let
    Tuple type_id types' = pool_allocate types
    types'' = pool_set type_id (ProgramType (TypeVar type_id) Nothing) types'
  Tuple type_id $ merge { types: types'' } ctx

type ProgramTypeID = PoolKey ProgramType
type TypedIRID = PoolKey TypedIR
type IntValue = Int

data TypedIR = TypedIR TypedIRKind ProgramTypeID

data IRConstKind = IRConstInt Int
                 | IRConstString String

data TypedIRKind
  = TypedIRBuiltin String (FingerTree TypedIRID)
  | TypedIRCall ModuleElementReference (FingerTree TypedIRID)
  | TypedIRConst IRConstKind
  | TypedIRCallIndirect TypedIRID (FingerTree TypedIRID)
  | TypedIRCast TypedIRID



data ProgramType = ProgramType ProgramTypeKind (Maybe ModuleElementReference)
data ProgramTypeKind
  -- Functions
  = FnType (FingerTree ProgramType) ProgramType

  -- Records
  | RecordType (FingerTree (Tuple Identifier ProgramType))

  -- Nominals
  | EnumType (ModuleElementReference) (FingerTree (Tuple Identifier ProgramType)) (FingerTree VariantKind)

  -- Numbers
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
  | Numeric

  -- Other Primitives
  | String
  | Bool

  -- Type helpers
  | Top
  | Bottom

  -- Type variables
  | TypeVar ProgramTypeID

  -- TODO: Constraints for unions and intersections
  | Union ProgramType ProgramType
  | Intersection ProgramType ProgramType

  -- Recursive types
  | Recursive ProgramType

  -- Bounded types
  | Bounded Bounds

data VariantKind = VariantKind Identifier (FingerTree ProgramType)

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

data FnIRIdentifier = FnIRIdentifier ModuleElementReference (List (Tuple Identifier ProgramTypeID))

data ModuleContext = ModuleContext
  { ast :: Module
  , module_id :: ModuleID
  , fns :: Map FnIRIdentifier TypedIRFnContext
  }


instance eq_program_type :: Eq ProgramType where
  eq (ProgramType kind _) (ProgramType kind' _) = kind == kind'

instance eq_program_type_kind :: Eq ProgramTypeKind where
  eq (FnType params ret) (FnType params' ret') = params == params' && ret == ret'
  eq n n' | n == n' = true
  eq _ _ = false

instance visitable_program_type ::
  ( Pass (Tuple Identifier ProgramType) ctx
  , Visitable (Tuple Identifier ProgramType) ctx
  , Pass ProgramTypeKind ctx
  , Visitable ProgramTypeKind ctx
  ) =>
  Visitable ProgramType ctx where
  visit_children (ProgramType kind _) ctx = do
    Tuple ctx' kind' <- visit kind ctx
    Just $ Tuple ctx' (ProgramType kind' Nothing)

instance visitable_program_type_kind ::
  ( Pass ProgramType ctx
  , Visitable ProgramType ctx
  , Pass ProgramTypeKind ctx
  , Pass (Tuple Identifier ProgramType) ctx
  , Visitable (Tuple Identifier ProgramType) ctx
  , Pass Identifier ctx
  , Visitable Identifier ctx
  , Pass VariantKind ctx
  , Visitable VariantKind ctx
  ) =>
  Visitable ProgramTypeKind ctx where
  visit_children (EnumType name env kinds) ctx = do
    Tuple ctx' env' <- visit_all env ctx
    Tuple ctx'' kinds' <- visit_all kinds ctx'
    Just $ Tuple ctx'' $ EnumType name env' kinds'

  visit_children (FnType parameters return_type) ctx = do
    Tuple ctx' parameters' <- visit_all parameters ctx
    Tuple ctx'' return_type' <- visit return_type ctx'
    Just $ Tuple ctx'' (FnType parameters' return_type')

  visit_children (RecordType fields) ctx = do
    Tuple ctx' fields' <- visit_all fields ctx
    Just $ Tuple ctx' $ RecordType fields'

  visit_children (Union left right) ctx = do
    Tuple ctx' left' <- visit left ctx
    Tuple ctx'' right' <- visit right ctx'
    Just $ Tuple ctx'' $ Union left' right'

  visit_children (Intersection left right) ctx = do
    Tuple ctx' left' <- visit left ctx
    Tuple ctx'' right' <- visit right ctx'
    Just $ Tuple ctx'' $ Intersection left' right'

  visit_children (Recursive t) ctx = do
    Tuple ctx' t' <- visit t ctx
    Just $ Tuple ctx' $ Recursive t'

  visit_children n ctx = Just $ Tuple ctx n


instance visitable_variant_type ::
  ( Pass Identifier ctx
  , Visitable Identifier ctx
  , Pass Identifier ctx
  , Visitable VariantKind ctx
  , Pass VariantKind ctx
  , Visitable (Tuple Identifier ProgramType) ctx
  , Pass (Tuple Identifier ProgramType) ctx
  , Visitable ProgramType ctx
  , Pass ProgramType ctx
  , Visitable ProgramTypeKind ctx
  , Pass ProgramTypeKind ctx
  ) =>
  Visitable VariantKind ctx where
  visit_children (VariantKind name fields) ctx = do
    Tuple ctx' name' <- visit name ctx
    Tuple ctx'' fields' <- visit_all fields ctx'
    Just $ Tuple ctx'' $ VariantKind name' fields'

constrain :: Bounds -> Bounds -> Bounds
constrain (Bounds { upper: with_upper, lower: with_lower }) (Bounds { upper, lower }) =
  Bounds { upper: upper <> with_upper, lower: lower <> with_lower }

instance bounds_semigroup :: Semigroup Bounds where
  append = constrain
  