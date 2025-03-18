module Program
  where

import Data.Array (snoc, uncons)

import Data.Foldable (foldl)
import Data.Map (Map, fromFoldable, empty, insert, lookup)
import Data.Maybe (Maybe(..))
import Data.Set (Set)
import Data.Set as Set
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Console (log)
import Effect.Exception (throw)
import Node.Buffer as Buffer
import Node.Encoding (Encoding(..))
import Node.FS.Sync as FS
import Node.Path as Path
import Parser (Expr(..), ExprKind(..), Module(..), ModuleDeclaration(..), ModuleDeclarationKind(..), ModuleFn, NameIdentifier(..), TypeIdentifier(..), WhenArm(..), parse)
import Prelude (class Eq, class Ord, class Show, Ordering(..), Unit, bind, compare, pure, show, ($), (+), (<>), (==))
import Record (merge)

assert_maybe :: ∀ a. Maybe a -> Effect a
assert_maybe (Just a) = pure a
assert_maybe Nothing = throw "Assertion failed"

data ModuleID = ModuleID (Maybe String) (Array String)

instance show_module_id :: Show ModuleID where
  show (ModuleID maybe_name path) = "(ModuleID " <> show maybe_name <> " " <> show path <> ")"

data ModuleElemID = NamedModuleElemID ModuleID NameIdentifier
                  | TypeModuleElemID ModuleID TypeIdentifier

instance compare_module_elem_id :: Ord ModuleElemID where
  compare (NamedModuleElemID _ (NameIdentifier name)) (NamedModuleElemID _ (NameIdentifier name')) = compare name name'
  compare (TypeModuleElemID _ (TypeIdentifier name)) (TypeModuleElemID _ (TypeIdentifier name')) = compare name name'
  compare (NamedModuleElemID _ _) _ = GT
  compare _ (NamedModuleElemID _ _) = LT

instance eq_module_elem_id :: Eq ModuleElemID where
  eq (NamedModuleElemID _ (NameIdentifier name)) (NamedModuleElemID _ (NameIdentifier name')) = name == name'
  eq (TypeModuleElemID _ (TypeIdentifier name)) (TypeModuleElemID _ (TypeIdentifier name')) = name == name'
  eq _ _ = false

data IdentifierKind = NameIdentifierKind NameIdentifier
                   | TypeIdentifierKind TypeIdentifier

instance compare_identifier_kind :: Ord IdentifierKind where
  compare (NameIdentifierKind (NameIdentifier name)) (NameIdentifierKind (NameIdentifier name')) = compare name name'
  compare (TypeIdentifierKind (TypeIdentifier name)) (TypeIdentifierKind (TypeIdentifier name')) = compare name name'
  compare (NameIdentifierKind _) _ = GT
  compare _ (NameIdentifierKind _) = LT

instance eq_identifier_kind :: Eq IdentifierKind where
  eq (NameIdentifierKind (NameIdentifier name)) (NameIdentifierKind (NameIdentifier name')) = name == name'
  eq (TypeIdentifierKind (TypeIdentifier name)) (TypeIdentifierKind (TypeIdentifier name')) = name == name'
  eq _ _ = false

type ModulePositionID = Tuple ModuleID Int

data ProgramTypeKind = FnType (Array ProgramType) (Maybe ProgramType)
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
                     | Integer -- Will be inferred later, otherwise defaults to I32
                     | Float -- Will be inferred later, otherwise defaults to F64
                     | String
                     | Bool
                     | TypeVar Int
                     | Numeric -- can be either an Int or a Float

infer_integer_type :: ProgramType -> TypeContext -> Maybe (Tuple Int Boolean)
infer_integer_type (ProgramType I8 _) _ = Just $ Tuple 8 true
infer_integer_type (ProgramType U8 _) _ = Just $ Tuple 8 false
infer_integer_type (ProgramType I16 _) _ = Just $ Tuple 16 true
infer_integer_type (ProgramType U16 _) _ = Just $ Tuple 16 false
infer_integer_type (ProgramType I32 _) _ = Just $ Tuple 32 true
infer_integer_type (ProgramType U32 _) _ = Just $ Tuple 32 false
infer_integer_type (ProgramType I64 _) _ = Just $ Tuple 64 true
infer_integer_type (ProgramType U64 _) _ = Just $ Tuple 64 false
infer_integer_type (ProgramType (TypeVar id) _) context = do
  some_type <- lookup id context.type_index
  infer_integer_type some_type context
infer_integer_type _ _ = Nothing

instance show_program_type_kind :: Show ProgramTypeKind where
  show (FnType args ret) = "(FnType " <> show args <> " " <> show ret <> ")"
  show I8 = "I8"
  show U8 = "U8"
  show I16 = "I16"
  show U16 = "U16"
  show I32 = "I32"
  show U32 = "U32"
  show I64 = "I64"
  show U64 = "U64"
  show F32 = "F32"
  show F64 = "F64"
  show Integer = "Integer"
  show Float = "Float"
  show String = "String"
  show Bool = "Bool"
  show (TypeVar id) = "(TypeVar " <> show id <> ")"
  show Numeric = "Numeric"

data ProgramType = ProgramType ProgramTypeKind (Maybe ModulePositionID)

instance show_program_type :: Show ProgramType where
  show (ProgramType kind _) = "(ProgramType " <> show kind <> ")"

type ModuleDeclarations = Map ModuleElemID (Tuple ModuleDeclaration TypeContext)
type ProgramModules = Map ModuleID (Tuple Module ModuleContext)
type ModuleExports = Set ModuleElemID
type ProgramTypes = Set ProgramType


data IndexableItem = ModuleFnElement ModuleFn TypeContext
                   | TypeElement ProgramType
                   | LocalElement NameIdentifier
type SymbolMap = Map IdentifierKind IndexableItem
type ExpressionMap = Map NameIdentifier ProgramType

type Program =
  { package_name :: String
  , modules :: ProgramModules
  , module_declarations :: ModuleDeclarations
  }


data FilePath = RelativePath String
              | AbsolutePath String

type PackageConfig =
  { name :: String
  -- , version :: SemVer
  -- , dependencies :: Dependencies
  }


type TypeIndex = Map Int ProgramType
type NextID = Int

type TypeConstraints = Array TypeConstraint
type Substitution = Map Int ProgramType

data TypeConstraint = Matches ProgramType ProgramType
                | Equals ProgramType ProgramType
                | AtLeast ProgramType ProgramType
                -- | IsVariantOf ProgramType ProgramType

instance show_type_constraint :: Show TypeConstraint where
  show (Matches left right) = "(Matches " <> show left <> " " <> show right <> ")"
  show (Equals left right) = "(Equals " <> show left <> " " <> show right <> ")"
  show (AtLeast left right) = "(AtLeast " <> show left <> " " <> show right <> ")"


type ModuleContext =
  { symbol_table :: Map ModuleElemID ModuleDeclaration
  , exported :: Set ModuleElemID
  }

build_module_context :: ModuleID -> Module -> ModuleContext
build_module_context id mod =
  { symbol_table: index_declarations id mod, exported: get_exports id mod }


-- Type Environment: Maps variable/function names to their inferred types
type TypeEnv = Map NameIdentifier ProgramType

-- TypeContext ModuleID NextID TypeIndex Constraints TypeEnv
type TypeContext =
  { module_id :: ModuleID
  , next_id :: NextID
  , type_index :: TypeIndex
  , constraints :: TypeConstraints
  , env :: TypeEnv
  }


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

i8_type :: Maybe ModulePositionID -> ProgramType
i8_type pos = (ProgramType I8 pos)
u8_type :: Maybe ModulePositionID -> ProgramType
u8_type pos = (ProgramType U8 pos)
i16_type :: Maybe ModulePositionID -> ProgramType
i16_type pos = (ProgramType I16 pos)
u16_type :: Maybe ModulePositionID -> ProgramType
u16_type pos = (ProgramType U16 pos)
i32_type :: Maybe ModulePositionID -> ProgramType
i32_type pos = (ProgramType I32 pos)
u32_type :: Maybe ModulePositionID -> ProgramType
u32_type pos = (ProgramType U32 pos)
i64_type :: Maybe ModulePositionID -> ProgramType
i64_type pos = (ProgramType I64 pos)
u64_type :: Maybe ModulePositionID -> ProgramType
u64_type pos = (ProgramType U64 pos)
f32_type :: Maybe ModulePositionID -> ProgramType
f32_type pos = (ProgramType F32 pos)
f64_type :: Maybe ModulePositionID -> ProgramType
f64_type pos = (ProgramType F64 pos)
integer_type :: Maybe ModulePositionID -> ProgramType
integer_type pos = (ProgramType Integer pos)
float_type :: Maybe ModulePositionID -> ProgramType
float_type pos = (ProgramType Float pos)
string_type :: Maybe ModulePositionID -> ProgramType
string_type pos = (ProgramType String pos)
bool_type :: Maybe ModulePositionID -> ProgramType
bool_type pos = (ProgramType Bool pos)
numeric_type :: Maybe ModulePositionID -> ProgramType
numeric_type pos = (ProgramType Numeric pos)

fn_type :: Array ProgramType -> ProgramType -> Maybe ModulePositionID -> ProgramType
fn_type args ret pos = (ProgramType (FnType args (Just ret)) pos)

builtin_types :: Map TypeIdentifier ProgramType
builtin_types = fromFoldable
  [ Tuple (TypeIdentifier "I8") builtin_i8_type
  , Tuple (TypeIdentifier "U8") builtin_u8_type
  , Tuple (TypeIdentifier "I16") builtin_i16_type
  , Tuple (TypeIdentifier "U16") builtin_u16_type
  , Tuple (TypeIdentifier "I32") builtin_i32_type
  , Tuple (TypeIdentifier "U32") builtin_u32_type
  , Tuple (TypeIdentifier "I64") builtin_i64_type
  , Tuple (TypeIdentifier "U64") builtin_u64_type
  , Tuple (TypeIdentifier "F32") builtin_f32_type
  , Tuple (TypeIdentifier "F64") builtin_f64_type
  , Tuple (TypeIdentifier "Int") builtin_integer_type
  , Tuple (TypeIdentifier "Float") builtin_float_type
  , Tuple (TypeIdentifier "String") builtin_string_type
  , Tuple (TypeIdentifier "Bool") builtin_bool_type
  ]
  
new_program :: PackageConfig -> Program
new_program config =
  { package_name: config.name
  , modules: empty
  , module_declarations: empty
  }

type FSModule = 
  { read_file :: FilePath -> Effect String
  , exists :: FilePath -> Effect Boolean
  , write_file :: FilePath -> String -> Effect Unit
  }

read_file :: String -> FilePath -> Effect String
read_file base_dir path = do
  case path of
    RelativePath rel_path -> do
      let file_path = Path.concat [base_dir, rel_path]
      contents_buffer <- FS.readFile file_path
      contents <- Buffer.toString UTF8 contents_buffer
      pure contents
    AbsolutePath abs_path -> do
      contents_buffer <- FS.readFile abs_path
      contents <- Buffer.toString UTF8 contents_buffer
      pure contents

exists :: String -> FilePath -> Effect Boolean
exists base_dir path = do
  case path of
    RelativePath rel_path -> do
      let file_path = Path.concat [base_dir, rel_path]
      FS.exists file_path
    AbsolutePath abs_path -> do
      FS.exists abs_path

write_file :: String -> FilePath -> String -> Effect Unit
write_file base_dir path contents = do
    buffer <- Buffer.fromString contents UTF8
    case path of
      RelativePath rel_path -> do
        let file_path = Path.concat [base_dir, rel_path]
        FS.writeFile file_path buffer
      AbsolutePath abs_path -> FS.writeFile abs_path buffer

fs :: String -> FSModule
fs basedir = { read_file: read_file basedir, exists: exists basedir, write_file: write_file basedir }

get_module_path :: ModuleID ->  FilePath
get_module_path module_id = do
  case module_id of
    ModuleID Nothing [] -> RelativePath (Path.concat [".", "src", "main.dew"])
    ModuleID Nothing path -> RelativePath (Path.concat [".", "src", (Path.concat path) <> ".dew"])
    ModuleID (Just package_name) [] -> RelativePath (Path.concat [".", "build", "packages", package_name, "src", "main.dew"])
    ModuleID (Just package_name) path -> RelativePath (Path.concat [".", "build", "packages", package_name, "src", (Path.concat path) <> ".dew"])

get_main_module_id :: PackageConfig -> ModuleID
get_main_module_id _ = ModuleID Nothing []

get_declaration_id :: ModuleID -> ModuleDeclaration -> ModuleElemID
get_declaration_id module_id (ModuleDeclaration (FnDeclarationKind _ name _) _) = NamedModuleElemID module_id name

-- create a new type variable, and return it as well as the new type context
type_var :: TypeContext -> Tuple ProgramType TypeContext
type_var context = do
  let next_id = context.next_id + 1
  let new_type_var = ProgramType (TypeVar next_id) Nothing
  let type_index = insert context.next_id new_type_var context.type_index
  let context' = merge context { next_id, type_index }
  Tuple new_type_var context'

-- create a new "matches" constraint and add it to the context
must_match :: TypeContext -> ProgramType -> ProgramType -> TypeContext
must_match context left right = do
  let constraint = Matches left right
  let constraints = snoc context.constraints constraint
  merge context { constraints }

must_equal :: TypeContext -> ProgramType -> ProgramType -> TypeContext
must_equal context left right = do
  let constraint = Equals left right
  let constraints = snoc context.constraints constraint
  merge context { constraints }

must_max_of :: TypeContext -> ProgramType -> ProgramType -> TypeContext
must_max_of context left right = do
  let constraint = AtLeast left right
  let constraints = snoc context.constraints constraint
  merge context { constraints }
  

-- expression types:

-- IntExpr Int
-- WhenExpr Expr (Array WhenArm) (Maybe Expr)
-- EqualsExpr Expr Expr
-- NameExpr NameIdentifier
-- CallExpr Expr (Array Expr)
-- AddExpr Expr Expr
-- SubExpr Expr Expr
-- MulExpr Expr Expr
-- DivExpr Expr Expr
-- GreaterThanExpr Expr Expr
-- LessThanExpr Expr Expr
-- GreaterThanEqualsExpr Expr Expr
-- LessThanEqualsExpr Expr Expr

index_declarations :: ModuleID -> Module -> Map ModuleElemID ModuleDeclaration
index_declarations module_id (Module declarations) =
  foldl (\acc decl ->
    let key = get_declaration_id module_id decl
    in insert key decl acc
  ) empty declarations

get_exports :: ModuleID -> Module -> Set ModuleElemID
get_exports module_id (Module declarations) =
  foldl (\acc decl ->
    let key = get_declaration_id module_id decl
    in Set.insert key acc
  ) Set.empty declarations


binary_numeric_infer_expr_type :: TypeContext -> Expr -> Expr -> Int -> Maybe (Tuple ProgramType TypeContext)
binary_numeric_infer_expr_type context left right pos = do
  let type_pos = Tuple context.module_id pos
  let Tuple num_type context' = type_var context

  Tuple left_type context'' <- infer_expr_type context' left
  Tuple right_type context''' <- infer_expr_type context'' right

  let context'''' = must_match context''' left_type (numeric_type $ Just type_pos)
  let context''''' = must_match context'''' right_type (numeric_type $ Just type_pos)

  let context'''''' = must_max_of context''''' num_type left_type
  let context''''''' = must_max_of context'''''' num_type right_type

  Just $ Tuple num_type context'''''''

binary_numeric_compare_infer_expr_type :: TypeContext -> Expr -> Expr -> Int -> Maybe (Tuple ProgramType TypeContext)
binary_numeric_compare_infer_expr_type context left right pos = do
  let type_pos = Tuple context.module_id pos
  -- let Tuple num_type context' = type_var context

  Tuple left_type context' <- infer_expr_type context left
  Tuple right_type context'' <- infer_expr_type context' right

  let context''' = must_match context'' left_type (numeric_type $ Just type_pos)
  let context'''' = must_match context''' right_type (numeric_type $ Just type_pos)

  Just $ Tuple (bool_type $ Just type_pos) context''''

-- Type Inference Function
infer_expr_type :: TypeContext -> Expr -> Maybe (Tuple ProgramType TypeContext)
infer_expr_type context (Expr (IntExpr _) pos) = do
  let type_pos = Tuple context.module_id pos
  Just $ Tuple (integer_type $ Just type_pos) context

infer_expr_type context@{ env } (Expr (NameExpr name) _) = do
  name_type <- lookup name env
  Just $ Tuple name_type context

infer_expr_type context (Expr (AddExpr left right) pos) = binary_numeric_infer_expr_type context left right pos
infer_expr_type context (Expr (SubExpr left right) pos) = binary_numeric_infer_expr_type context left right pos
infer_expr_type context (Expr (MulExpr left right) pos) = binary_numeric_infer_expr_type context left right pos
infer_expr_type context (Expr (DivExpr left right) pos) = binary_numeric_infer_expr_type context left right pos
infer_expr_type context (Expr (GreaterThanExpr left right) pos) = binary_numeric_compare_infer_expr_type context left right pos
infer_expr_type context (Expr (LessThanExpr left right) pos) = binary_numeric_compare_infer_expr_type context left right pos
infer_expr_type context (Expr (GreaterThanEqualsExpr left right) pos) = binary_numeric_compare_infer_expr_type context left right pos
infer_expr_type context (Expr (LessThanEqualsExpr left right) pos) = binary_numeric_compare_infer_expr_type context left right pos

infer_expr_type context (Expr (EqualsExpr left right) pos) = do
  let type_pos = Tuple context.module_id pos
  Tuple left_type context' <- infer_expr_type context left
  Tuple right_type context'' <- infer_expr_type context' right
  let context''' = must_match context'' left_type right_type
  Just $ Tuple (bool_type $ Just type_pos) context'''

infer_expr_type context (Expr (CallExpr callee args) pos) = do
  let type_pos = Tuple context.module_id pos
  Tuple callee_type context' <- infer_expr_type context callee
  Tuple arg_types context'' <- do_infer_expr_types context' args []

  let Tuple return_type context''' = type_var context''

  let context'''' = must_match context''' callee_type (fn_type arg_types return_type $ Just type_pos)

  Just $ Tuple return_type context''''

infer_expr_type context (Expr (WhenExpr arms else_arm) _) = do
  let Tuple return_type context' = type_var context

  context'' <- do_infer_expr_arms_types context' arms return_type

  case else_arm of
    Nothing -> Just $ Tuple return_type context''
    Just else_expr -> do
      Tuple else_arm_type context''' <- infer_expr_type context'' else_expr
      let context'''' = must_match context''' return_type else_arm_type
      Just $ Tuple return_type context''''

-- Somehow a default
-- infer_expr_type _ _ = Nothing

infer_expr_when_arm :: TypeContext -> WhenArm -> Maybe (Tuple ProgramType TypeContext)
infer_expr_when_arm context (WhenArm condition result) = do
  Tuple condition_type context' <- infer_expr_type context condition
  Tuple result_type context'' <- infer_expr_type context' result
  let context''' = must_equal context'' condition_type builtin_bool_type
  Just $ Tuple result_type context'''

do_infer_expr_arms_types :: TypeContext -> Array WhenArm -> ProgramType -> Maybe TypeContext
do_infer_expr_arms_types context@{ module_id } arms return_type = case uncons arms of
  Nothing -> Just context
  Just { head: (WhenArm cond body@(Expr _ pos)), tail: rest } -> do
    -- Infer condition type and ensure it’s Bool
    Tuple cond_type context' <- infer_expr_type context cond
    let context'' = must_match context' cond_type (bool_type $ Just $Tuple module_id pos)

    -- Infer body type
    Tuple body_type context''' <- infer_expr_type context'' body
    let context'''' = must_match context''' return_type body_type
    do_infer_expr_arms_types context'''' rest return_type


do_infer_expr_types :: TypeContext -> Array Expr -> Array ProgramType -> Maybe (Tuple (Array ProgramType) TypeContext)
do_infer_expr_types context args acc = case uncons args of
  Nothing -> Just $ Tuple acc context
  Just { head, tail } -> do
    Tuple arg_type context' <- infer_expr_type context head
    do_infer_expr_types context' tail (snoc acc arg_type)

compile :: PackageConfig -> Effect Unit
compile config = do
  let main_module_id = get_main_module_id config
  let main_module_path = get_module_path main_module_id
  let fs' = fs "."
  contents <- fs'.read_file main_module_path
  mod <- assert_maybe $ parse contents
  let module_context = build_module_context main_module_id mod
  
  -- Initialize TypeContext
  let initial_type_context = { module_id: main_module_id
                             , next_id: 0
                             , type_index: empty
                             , constraints: []
                             }
  log "Ok"
