module Data.Dewdrop.Types where

import Prelude

import Data.Dewdrop.Identifier (Identifier)
import Data.Dewdrop.Visitor (class Pass, class Visitable, visit, visit_all)
import Data.FingerTree (FingerTree)
import Data.Maybe (Maybe(..))
import Data.Pool (PoolKey)
import Data.Tuple (Tuple(..))

-- | Upper and Lower bounds in *that* order
newtype Bounds = Bounds { upper :: Maybe ProgramType, lower :: Maybe ProgramType }

type IRBoundsID = PoolKey Bounds

bounds_new :: Bounds
bounds_new = Bounds { upper: mempty, lower: mempty }

unbounded :: Bounds
unbounded = bounds_new

data ProgramType
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
fn_type_new params ret = FnType params ret

data VariantKind = VariantKind Identifier (FingerTree ProgramType)

builtin_i8_type :: ProgramType
builtin_i8_type = I8

builtin_u8_type :: ProgramType
builtin_u8_type = U8

builtin_i16_type :: ProgramType
builtin_i16_type = I16

builtin_u16_type :: ProgramType
builtin_u16_type = U16

builtin_i32_type :: ProgramType
builtin_i32_type = I32

builtin_u32_type :: ProgramType
builtin_u32_type = U32

builtin_i64_type :: ProgramType
builtin_i64_type = I64

builtin_u64_type :: ProgramType
builtin_u64_type = U64

builtin_f32_type :: ProgramType
builtin_f32_type = F32

builtin_f64_type :: ProgramType
builtin_f64_type = F64

builtin_integer_type :: ProgramType
builtin_integer_type = Integer

builtin_float_type :: ProgramType
builtin_float_type = Float

builtin_string_type :: ProgramType
builtin_string_type = String

builtin_bool_type :: ProgramType
builtin_bool_type = Bool

builtin_numeric_type :: ProgramType
builtin_numeric_type = Numeric

instance eq_program_type_kind :: Eq ProgramType where
  eq (FnType params ret) (FnType params' ret') = params == params' && ret == ret'
  eq n n' | n == n' = true
  eq _ _ = false

instance visitable_program_type ::
  ( Pass (Tuple Identifier ProgramType) ctx
  , Visitable (Tuple Identifier ProgramType) ctx
  , Pass ProgramType ctx
  , Visitable ProgramType ctx
  ) =>
  Visitable ProgramType ctx where
  visit_children kind ctx = visit kind ctx

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

is_numeric :: ProgramType -> Boolean
is_numeric (ProgramType I8) = true
is_numeric (ProgramType U8) = true
is_numeric (ProgramType I16) = true
is_numeric (ProgramType U16) = true
is_numeric (ProgramType I32) = true
is_numeric (ProgramType U32) = true
is_numeric (ProgramType I64) = true
is_numeric (ProgramType U64) = true
is_numeric (ProgramType F32) = true
is_numeric (ProgramType F64) = true
is_numeric (ProgramType Integer) = true
is_numeric (ProgramType Float) = true
is_numeric (ProgramType Numeric) = true
is_numeric _ = false

is_float :: ProgramType -> Boolean
is_float (ProgramType Float) = true
is_float (ProgramType F32) = true
is_float (ProgramType F64) = true
is_float _ = false

is_integer :: ProgramType -> Boolean
is_integer (ProgramType I8) = true
is_integer (ProgramType U8) = true
is_integer (ProgramType I16) = true
is_integer (ProgramType U16) = true
is_integer (ProgramType I32) = true
is_integer (ProgramType U32) = true
is_integer (ProgramType I64) = true
is_integer (ProgramType U64) = true
is_integer (ProgramType Integer) = true
is_integer _ = false

constrain :: Bounds -> Bounds -> Maybe Bounds
constrain (Bounds { upper: upper_left, lower: lower_left }) (Bounds { upper: upper_right, lower: lower_right }) = do
  upper <- take_lower_of upper_left upper_right
  lower <- take_upper_of lower_left lower_right
  pure $ Bounds { upper, lower }

take_lower_of :: ProgramType -> ProgramType -> Maybe ProgramType
-- everything is lower than the top type
take_lower_of left Top = pure left
take_lower_of Top right = pure right

-- bottom is always the lowest type
take_lower_of Bottom _ = Bottom
take_lower_of _ Bottom = Bottom

-- all number types are "Numeric"
take_lower_of left Numeric | is_numeric left = pure left
take_lower_of Numeric right | is_numeric right = pure right

-- all integer types are "Integer"
take_lower_of left Integer | is_integer left = pure left
take_lower_of Integer right | is_integer right = pure right

-- all float types are "Float"
take_lower_of left Float | is_float left = pure left
take_lower_of Float right | is_float right = pure right

-- TODO: Implement more!
take_lower_of _ _ = Nothing

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
