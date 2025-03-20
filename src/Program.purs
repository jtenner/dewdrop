module Program
  ( ExpressionMap
  , FSModule
  , FilePath(..)
  , ModuleContext
  , ModuleDeclarations
  , ModuleElemID(..)
  , ModuleExports
  , ModuleID(..)
  , ModulePositionID
  , NextID
  , PackageConfig
  , Program
  , ProgramModules
  , ProgramType(..)
  , ProgramTypeConstraint
  , ProgramTypeKind(..)
  , ProgramTypes
  , Substitution
  , TypeConstraint(..)
  , TypeConstraints
  , TypeContext
  , TypeEnv
  , TypeIndex
  , assert_maybe
  , binary_numeric_compare_infer_expr_type
  , binary_numeric_infer_expr_type
  , bool_type
  , build_module_context
  , builtin_bool_type
  , builtin_f32_type
  , builtin_f64_type
  , builtin_float_type
  , builtin_i16_type
  , builtin_i32_type
  , builtin_i64_type
  , builtin_i8_type
  , builtin_integer_type
  , builtin_numeric_type
  , builtin_string_type
  , builtin_types
  , builtin_u16_type
  , builtin_u32_type
  , builtin_u64_type
  , builtin_u8_type
  , compile
  , constraint_type
  , do_infer_expr_arms_types
  , do_infer_expr_types
  , enqueue_module
  , exists
  , f32_type
  , f64_type
  , float_type
  , fn_type
  , fs
  , get_declaration_id
  , get_exports
  , get_main_module_id
  , get_module_path
  , i16_type
  , i32_type
  , i64_type
  , i8_type
  , index_declarations
  , infer_expr_type
  , infer_expr_when_arm
  , infer_integer_type
  , integer_type
  , must_equal
  , must_match
  , must_max_of
  , new_program
  , new_type_context
  , numeric_type
  , pkg
  , pos_in
  , process_module
  , process_module_declarations
  , process_module_fn
  , process_modules
  , read_file
  , string_type
  , type_var
  , u16_type
  , u32_type
  , u64_type
  , u8_type
  , unify
  , write_file
  )
  where

import Data.Array (any, last, snoc, uncons, partition)
import Data.Foldable (foldl, foldM)
import Data.Map (Map, empty, fromFoldable, insert, lookup)
import Data.Maybe (Maybe(..), fromMaybe, maybe)
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
import Parser (Expr(..), ExprKind(..), FnParam(..), Identifier(..), Module(..), ModuleDeclaration(..), ModuleDeclarationKind(..), ModuleFn(..), TypeExpr(..), TypeExprKind(..), WhenArm(..), parse)
import Prelude (map, not, discard, unit, class Eq, class Ord, class Show, Ordering(..), Unit, bind, compare, pure, show, (||), ($), (+), (<>), (==), (&&))
import Record (merge)
import Util (is_equals)

assert_maybe :: ∀ a. Maybe a -> String -> Effect a
assert_maybe (Just a) _ = pure a
assert_maybe Nothing msg = throw ("Assertion failed: " <> msg)

data ModuleID = ModuleID (Maybe String) (Array String)

instance show_module_id :: Show ModuleID where
  show (ModuleID maybe_name path) = "(ModuleID " <> show maybe_name <> " " <> show path <> ")"

instance ord_module_id :: Ord ModuleID where
  compare (ModuleID maybe_name path) (ModuleID maybe_name' path') = compare maybe_name maybe_name' <> compare path path'

instance eq_module_id :: Eq ModuleID where
  eq (ModuleID maybe_name path) (ModuleID maybe_name' path') = maybe_name == maybe_name' && path == path'

data ModuleElemID = ModuleElemID ModuleID Identifier

instance compare_module_elem_id :: Ord ModuleElemID where
  compare (ModuleElemID module_id identifier) (ModuleElemID module_id' identifier') = case compare module_id module_id' of
    EQ -> compare identifier identifier'
    ordering -> ordering

instance eq_module_elem_id :: Eq ModuleElemID where
  eq (ModuleElemID module_id identifier) (ModuleElemID module_id' identifier') = module_id == module_id' && identifier == identifier'

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

instance program_type_eq :: Eq ProgramType where
  eq (ProgramType kind _) (ProgramType kind' _) = kind == kind'

derive instance program_type_kind_eq :: Eq ProgramTypeKind

instance show_program_type :: Show ProgramType where
  show (ProgramType kind _) = "(ProgramType " <> show kind <> ")"

type ModuleDeclarations = Map ModuleElemID (Tuple ModuleDeclaration TypeContext)
type ProgramModules = Map ModuleID (Tuple Module ModuleContext)
type ModuleExports = Set ModuleElemID
type ProgramTypes = Set ProgramType

type ExpressionMap = Map Identifier ProgramType

type Program =
  { package_name :: String
  , modules :: ProgramModules
  , module_queue :: Array ModuleID
  , seen :: Set ModuleID
  , fs :: FSModule
  }

data FilePath = RelativePath String
              | AbsolutePath String

type PackageConfig =
  { name :: String
  , basedir :: String
  -- , version :: SemVer
  -- , dependencies :: Dependencies
  }

pkg :: String -> String -> PackageConfig
pkg name basedir = { name, basedir }

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
  , type_contexts :: Map ModuleElemID TypeContext
  }

-- Type Environment: Maps variable/function names to their inferred types
type TypeEnv = Map Identifier ProgramType

-- TypeContext ModuleID NextID TypeIndex Constraints TypeEnv
type TypeContext =
  { module_id :: ModuleID
  , next_id :: NextID
  , params :: Array ProgramType
  , type_index :: TypeIndex
  , return_type :: ProgramType
  , constraints :: TypeConstraints
  , type_env :: TypeEnv
  }

instance show_module_elem_id :: Show ModuleElemID where
  show (ModuleElemID module_id identifier) = "(ModuleElemID " <> show module_id <> " " <> show identifier <> ")"

new_type_context :: ModuleID -> TypeContext
new_type_context module_id = do
  let return_type = ProgramType (TypeVar 0) Nothing

  { module_id, next_id: 1, params: [], return_type, type_index: fromFoldable [Tuple 0 return_type], constraints: [], type_env: builtin_types }

pos_in :: TypeContext -> Int -> ModulePositionID
pos_in context index = Tuple context.module_id index

build_module_context :: ModuleID -> Module -> ModuleContext
build_module_context id mod =
  { symbol_table: index_declarations id mod, exported: get_exports id mod, type_contexts: empty }

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

builtin_types :: Map Identifier ProgramType
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
  , module_queue: [get_main_module_id config]
  , seen: Set.empty
  , fs: fs config.basedir
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
get_declaration_id module_id (ModuleDeclaration (FnDeclarationKind _ name _) _) = ModuleElemID module_id name

-- create a new type variable, and return it as well as the new type context
type_var :: TypeContext -> (Maybe ModulePositionID) -> Tuple ProgramType TypeContext
type_var context pos = do
  let next_id = context.next_id + 1
  let new_type_var = ProgramType (TypeVar next_id) pos
  let type_index = insert context.next_id new_type_var context.type_index
  let context' = merge { next_id, type_index } context 
  Tuple new_type_var context'

type ProgramTypeConstraint = (ProgramType -> ProgramType -> TypeConstraint)

constraint_type :: ProgramTypeConstraint -> TypeContext -> ProgramType -> ProgramType -> TypeContext
constraint_type constructor context left right =
  let constraint = constructor left right
      constraints = snoc context.constraints constraint
  in merge { constraints } context 


must_match ∷ TypeContext -> ProgramType -> ProgramType -> TypeContext
must_match = constraint_type Matches

must_equal ∷ TypeContext -> ProgramType -> ProgramType -> TypeContext
must_equal = constraint_type Equals

must_max_of ∷ TypeContext -> ProgramType -> ProgramType -> TypeContext
must_max_of = constraint_type AtLeast

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
  let type_pos = pos_in context pos
  let Tuple num_type context' = type_var context $ Just type_pos

  Tuple left_type context'' <- infer_expr_type context' left
  Tuple right_type context''' <- infer_expr_type context'' right

  let context'''' = must_match context''' left_type (numeric_type $ Just type_pos)
  let context''''' = must_match context'''' right_type (numeric_type $ Just type_pos)

  let context'''''' = must_max_of context''''' num_type left_type
  let context''''''' = must_max_of context'''''' num_type right_type

  Just $ Tuple num_type context'''''''

binary_numeric_compare_infer_expr_type :: TypeContext -> Expr -> Expr -> Int -> Maybe (Tuple ProgramType TypeContext)
binary_numeric_compare_infer_expr_type context left right pos = do
  let type_pos = pos_in context pos
  -- let Tuple num_type context' = type_var context

  Tuple left_type context' <- infer_expr_type context left
  Tuple right_type context'' <- infer_expr_type context' right

  let context''' = must_match context'' left_type (numeric_type $ Just type_pos)
  let context'''' = must_match context''' right_type (numeric_type $ Just type_pos)

  Just $ Tuple (bool_type $ Just type_pos) context''''

infer_type_expr_type :: TypeContext -> TypeExpr -> Maybe ProgramType
infer_type_expr_type { type_env } (TypeExpr (NamedTypeExpr name) _) = lookup (TypeIdentifier name) type_env

-- Type Inference Function
infer_expr_type :: TypeContext -> Expr -> Maybe (Tuple ProgramType TypeContext)
infer_expr_type context (Expr (IntExpr _) pos) = do
  let type_pos = pos_in context pos
  Just $ Tuple (integer_type $ Just type_pos) context

infer_expr_type context@{ type_env } (Expr (NameExpr name) _) = do
  name_type <- lookup (NameIdentifier name) type_env
  Just $ Tuple name_type context

infer_expr_type context@{ type_env } (Expr (BlockExpr exprs) pos) = do
  let type_pos = pos_in context pos
  let Tuple block_type_var context' = type_var context $ Just type_pos
  Tuple types sub_context <- do_infer_expr_types context' exprs

  -- The last is the "result type" of the block, and blocks must not be empty
  block_type <- last types
  -- The block type must match the block type variable
  let sub_context' = must_match sub_context block_type_var block_type
  
  -- finally any named types in the block must be ignored
  Just $ Tuple block_type_var $ merge { type_env } sub_context'

infer_expr_type context (Expr (AddExpr left right) pos) = binary_numeric_infer_expr_type context left right pos
infer_expr_type context (Expr (SubExpr left right) pos) = binary_numeric_infer_expr_type context left right pos
infer_expr_type context (Expr (MulExpr left right) pos) = binary_numeric_infer_expr_type context left right pos
infer_expr_type context (Expr (DivExpr left right) pos) = binary_numeric_infer_expr_type context left right pos
infer_expr_type context (Expr (GreaterThanExpr left right) pos) = binary_numeric_compare_infer_expr_type context left right pos
infer_expr_type context (Expr (LessThanExpr left right) pos) = binary_numeric_compare_infer_expr_type context left right pos
infer_expr_type context (Expr (GreaterThanEqualsExpr left right) pos) = binary_numeric_compare_infer_expr_type context left right pos
infer_expr_type context (Expr (LessThanEqualsExpr left right) pos) = binary_numeric_compare_infer_expr_type context left right pos

infer_expr_type context (Expr (EqualsExpr left right) pos) = do
  let type_pos = pos_in context pos
  Tuple left_type context' <- infer_expr_type context left
  Tuple right_type context'' <- infer_expr_type context' right
  let context''' = must_match context'' left_type right_type
  Just $ Tuple (bool_type $ Just type_pos) context'''

infer_expr_type context (Expr (CallExpr callee args) pos) = do
  let type_pos = pos_in context pos
  Tuple callee_type context' <- infer_expr_type context callee
  Tuple arg_types context'' <- do_infer_expr_types context' args
  let Tuple return_type context''' = type_var context'' $ Just type_pos
  let context'''' = must_match context''' callee_type (fn_type arg_types return_type $ Just type_pos)
  Just $ Tuple return_type context''''

infer_expr_type context (Expr (WhenExpr arms else_arm) pos) = do
  let type_pos = pos_in context pos
  let Tuple return_type context' = type_var context $ Just type_pos

  context'' <- do_infer_expr_arms_types context' arms return_type

  case else_arm of
    Nothing -> Just $ Tuple return_type context''
    Just else_expr -> do
      Tuple else_arm_type context''' <- infer_expr_type context'' else_expr
      let context'''' = must_match context''' return_type else_arm_type
      Just $ Tuple return_type context''''

infer_expr_when_arm :: TypeContext -> WhenArm -> Maybe (Tuple ProgramType TypeContext)
infer_expr_when_arm context (WhenArm condition result) = do
  Tuple condition_type context' <- infer_expr_type context condition
  Tuple result_type context'' <- infer_expr_type context' result
  let context''' = must_equal context'' condition_type builtin_bool_type
  Just $ Tuple result_type context'''

do_infer_expr_arms_types :: TypeContext -> Array WhenArm -> ProgramType -> Maybe TypeContext
do_infer_expr_arms_types context arms return_type =
  foldM (infer_arm return_type) context arms
  where
    infer_arm ret ctx (WhenArm cond body@(Expr _ pos)) = do
      Tuple cond_type ctx' <- infer_expr_type ctx cond
      let ctx'' = must_match ctx' cond_type (bool_type $ Just $ Tuple ctx.module_id pos)
      Tuple body_type ctx''' <- infer_expr_type ctx'' body
      Just $ must_match ctx''' ret body_type

do_infer_expr_types :: TypeContext -> Array Expr -> Maybe (Tuple (Array ProgramType) TypeContext)
do_infer_expr_types context args = do
  Tuple types ctx <- foldM next (Tuple [] context) args
  Just $ Tuple types ctx
  where
    next (Tuple acc ctx) expr = do
      Tuple t ctx' <- infer_expr_type ctx expr
      Just $ Tuple (snoc acc t) ctx'

process_module :: ModuleID -> Module -> Program -> Maybe Program
process_module module_id mod@(Module declarations) program = do
  let mod_context = build_module_context module_id mod
  -- TODO: Fill in generating constraints for each declaration
  mod_context' <- process_module_declarations module_id declarations mod_context
  Just $ merge { modules: insert module_id (Tuple mod mod_context') program.modules } program

process_module_declarations :: ModuleID -> Array ModuleDeclaration -> ModuleContext -> Maybe ModuleContext
process_module_declarations module_id declarations module_context =
  go module_context $ uncons declarations
  where
    go ctx Nothing = Just ctx
    go ctx@{ exported, symbol_table, type_contexts } (Just { head: decl, tail: rest }) = case decl of
      ModuleDeclaration (FnDeclarationKind fn_exported _ fn) pos -> do
        let elem_id = get_declaration_id module_id decl
        type_context <- process_module_fn module_id pos fn
        case fn_exported of
          true -> do
            let ctx' = merge { exported: Set.insert elem_id exported, symbol_table: insert elem_id decl symbol_table, type_contexts: insert elem_id type_context type_contexts } ctx
            go ctx' $ uncons rest 
          false -> do
            let ctx' = merge { symbol_table: insert elem_id decl symbol_table, type_contexts: insert elem_id type_context type_contexts } ctx
            go ctx' $ uncons rest

process_module_fn :: ModuleID -> Int -> ModuleFn -> Maybe TypeContext
process_module_fn module_id pos_index (ModuleFn maybe_name args return_type_guard_expr body) = do
  let type_context = new_type_context module_id
  let pos = pos_in type_context pos_index
  let Tuple fn_type_var type_context = type_var type_context $ Just pos
  type_context' <- maybe_set_name type_context maybe_name fn_type_var
  Tuple arg_types type_context'' <- foldM next_param_type_var (Tuple [] type_context') args
  Tuple body_type type_context''' <- infer_expr_type type_context'' body
  let type_context'''' = fromMaybe type_context''' $ maybe_return_type type_context''' return_type_guard_expr
  let f = fn_type arg_types body_type $ Just pos
  Just $ must_match type_context'''' fn_type_var f

  where
    maybe_set_name ctx Nothing _ = Just ctx
    maybe_set_name ctx@{ type_env } (Just name) f = Just $ merge { type_env: insert (NameIdentifier name) f type_env } ctx

    maybe_return_type ctx maybe_type_guard_expr = do
      type_guard_expr <- maybe_type_guard_expr
      type_guard <- infer_type_expr_type ctx type_guard_expr
      Just $ must_match ctx ctx.return_type type_guard

    next_param_type_var (Tuple acc ctx) (FnParam name Nothing pos) = do
      let pos_type = pos_in ctx pos
      let Tuple param_type ctx' = type_var ctx $ Just pos_type
      let type_env' = insert (NameIdentifier name) param_type ctx'.type_env
      let ctx'' = merge { type_env: type_env' } ctx'
      let acc' = snoc acc param_type
      Just $ Tuple acc' ctx''

    next_param_type_var (Tuple acc ctx) (FnParam name (Just type_guard_expr) pos) = do
      let pos_type = pos_in ctx pos
      let Tuple param_type ctx' = type_var ctx $ Just pos_type
      let type_env' = insert (NameIdentifier name) param_type ctx'.type_env
      let ctx'' = { module_id: ctx'.module_id
        , next_id: ctx'.next_id
        , params: ctx'.params
        , type_index: ctx'.type_index
        , return_type: ctx'.return_type
        , constraints: ctx'.constraints
        , type_env: type_env'
        }
      let acc' = snoc acc param_type
      type_guard <- infer_type_expr_type ctx'' type_guard_expr
      let ctx''' = must_match ctx'' param_type type_guard
      Just $  Tuple acc' ctx'''
          

enqueue_module :: ModuleID -> Program -> Program
enqueue_module module_id program@{ seen, module_queue } = case Set.member module_id seen of
  true -> program
  false -> merge { module_queue: snoc module_queue module_id } program

process_modules :: Program -> Effect Program
process_modules program@{ module_queue } = 
  case uncons module_queue of
    Nothing -> pure program
    Just { head: module_id, tail: rest } -> do
      contents <- program.fs.read_file $ get_module_path module_id
      mod <- assert_maybe (parse contents) "Failed to parse module"
      let program' = merge { module_queue: rest, seen: Set.insert module_id program.seen } program
      program'' <- assert_maybe (process_module module_id mod program') "Failed to process module"
      process_modules program''

compile :: PackageConfig -> Effect Unit
compile config = do
  let program = new_program config
  {
    modules,
    module_queue,
    seen
  } <- process_modules program

  log $ "modules: " <> show modules 
  log $ "module_queue: " <> show module_queue
  log $ "seen: " <> show seen
  pure unit

-- unification functions

unify :: TypeConstraints -> Maybe Substitution
unify constraints = do
  let { no: rest_constraints, yes: equality_constraints } = partition (is_equals_constraint) constraints
  sub' <- unify' equality_constraints empty
  unify' rest_constraints sub'
  
  where
    is_equals_constraint (Equals _ _) = true
    is_equals_constraint _ = false

    apply_sub :: Substitution -> ProgramType -> ProgramType
    apply_sub sub kind@(ProgramType (TypeVar id) _) = fromMaybe kind $ lookup id sub
    apply_sub sub (ProgramType (FnType args (Just ret)) pos) = ProgramType (FnType (map (apply_sub sub) args) (Just $ apply_sub sub ret)) pos
    apply_sub sub (ProgramType (FnType args Nothing) pos) = ProgramType (FnType (map (apply_sub sub) args) Nothing) pos
    apply_sub _ t = t

    apply_sub_constraint :: Substitution -> TypeConstraint -> TypeConstraint
    apply_sub_constraint sub (Equals left right) = Equals (apply_sub sub left) (apply_sub sub right)
    apply_sub_constraint sub (Matches left right) = Matches (apply_sub sub left) (apply_sub sub right)
    apply_sub_constraint sub (AtLeast left right) = AtLeast (apply_sub sub left) (apply_sub sub right)

    occurs :: Int -> ProgramType -> Boolean
    occurs id (ProgramType (TypeVar id') _) = id == id'
    occurs id (ProgramType (FnType args ret) _) = any (occurs id) args || maybe false (occurs id) ret
    occurs _ _ = false

    unify' :: TypeConstraints -> Substitution -> Maybe Substitution
    unify' constraints' sub = case uncons constraints' of
      Nothing -> Just sub
      Just { head: constraint, tail: rest } -> do
        let constraint' = apply_sub_constraint sub constraint
        sub' <- unify_constraint constraint' sub
        let rest' = map (apply_sub_constraint sub') rest
        unify' rest' sub'

    -- equality is equivalent to substitution
    unify_constraint :: TypeConstraint -> Substitution -> Maybe Substitution
    unify_constraint (Equals left right) sub | left == right = Just sub
    unify_constraint (Matches left right) sub | left == right = Just sub
    unify_constraint (AtLeast left right) sub | left == right = Just sub

    -- for type variables
    unify_constraint (Equals (ProgramType (TypeVar id) _) right) sub | not $ occurs id right = Just $ insert id right sub
    unify_constraint (Equals left (ProgramType (TypeVar id) _)) sub | not $ occurs id left = Just $ insert id left sub
    
    -- TODO: Matching and AtLeast

    -- for type matching
    unify_constraint _ _ = Nothing

