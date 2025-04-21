module Data.Dewdrop.Types where

import Prelude

import Data.Dewdrop.Identifier (Identifier)
import Data.Dewdrop.Visitor (class Pass, class Visitable, visit, visit_all)
import Data.FingerTree (FingerTree)
import Data.Maybe (Maybe(..))
import Data.Pool (PoolKey)
import Data.Tuple (Tuple(..))

-- | Upper and Lower bounds in *that* order
data Bounds = Bounds { upper :: FingerTree ProgramType, lower :: FingerTree ProgramType }

type IRBoundsID = PoolKey Bounds

bounds_new :: Bounds
bounds_new = Bounds { upper: mempty, lower: mempty }

unbounded :: Bounds
unbounded = bounds_new

data ProgramType = ProgramType ProgramTypeKind
data ProgramTypeKind
  -- Functions
  = FnType (FingerTree ProgramType) ProgramType

  -- Records
  | RecordType (FingerTree (Tuple Identifier ProgramType))

  -- Nominals
  | EnumType (FingerTree (Tuple Identifier ProgramType)) (FingerTree VariantKind)

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
  | TypeVar IRBoundsID

  -- TODO: Constraints for unions and intersections
  | Union ProgramType ProgramType
  | Intersection ProgramType ProgramType

  -- Recursive types
  | Recursive ProgramType

fn_type_new :: FingerTree ProgramType -> ProgramType -> ProgramType
fn_type_new params ret = ProgramType $ FnType params ret

data VariantKind = VariantKind Identifier (FingerTree ProgramType)

builtin_i8_type :: ProgramType
builtin_i8_type = ProgramType I8

builtin_u8_type :: ProgramType
builtin_u8_type = ProgramType U8

builtin_i16_type :: ProgramType
builtin_i16_type = ProgramType I16

builtin_u16_type :: ProgramType
builtin_u16_type = ProgramType U16

builtin_i32_type :: ProgramType
builtin_i32_type = ProgramType I32

builtin_u32_type :: ProgramType
builtin_u32_type = ProgramType U32

builtin_i64_type :: ProgramType
builtin_i64_type = ProgramType I64

builtin_u64_type :: ProgramType
builtin_u64_type = ProgramType U64

builtin_f32_type :: ProgramType
builtin_f32_type = ProgramType F32

builtin_f64_type :: ProgramType
builtin_f64_type = ProgramType F64

builtin_integer_type :: ProgramType
builtin_integer_type = ProgramType Integer

builtin_float_type :: ProgramType
builtin_float_type = ProgramType Float

builtin_string_type :: ProgramType
builtin_string_type = ProgramType String

builtin_bool_type :: ProgramType
builtin_bool_type = ProgramType Bool

builtin_numeric_type :: ProgramType
builtin_numeric_type = ProgramType Numeric

instance eq_program_type :: Eq ProgramType where
  eq (ProgramType kind) (ProgramType kind') = kind == kind'

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
  visit_children (ProgramType kind) ctx = do
    Tuple ctx' kind' <- visit kind ctx
    Just $ Tuple ctx' (ProgramType kind')

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
  visit_children (EnumType env kinds) ctx = do
    Tuple ctx' env' <- visit_all env ctx
    Tuple ctx'' kinds' <- visit_all kinds ctx'
    Just $ Tuple ctx'' $ EnumType env' kinds'

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

data ModuleID = ModuleID
  { package_name :: String
  , path :: Array String
  }

instance ord_module_id :: Ord ModuleID where
  compare (ModuleID { package_name, path }) (ModuleID { package_name: package_name', path: path' }) =
    compare package_name package_name' <> compare path path'

derive instance eq_module_id :: Eq ModuleID

at_least :: ProgramType -> Bounds
at_least t = Bounds { upper: mempty, lower: pure t }

at_most :: ProgramType -> Bounds
at_most t = Bounds { upper: pure t, lower: mempty }
