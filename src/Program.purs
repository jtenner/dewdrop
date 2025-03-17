module Program
  ( Constraint(..)
  , Constraints
  , FSModule
  , FilePath(..)
  , IdentifierKind(..)
  , ModuleDeclarations
  , ModuleElemID(..)
  , ModuleExports
  , ModuleID(..)
  , ModulePositionID
  , PackageConfig
  , Program(..)
  , ProgramModules
  , ProgramType(..)
  , ProgramTypeKind(..)
  , ProgramTypes
  , add_module
  , new_program
  , read_file
  , type_check
  )
  where

import Data.Array
import Data.Maybe
import Data.Tuple
import Effect
import Parser
import Prelude

import Control.Monad.Trampoline (done)
import Data.Map as Map
import Data.Set (Set)
import Node.Buffer as Buffer
import Node.Encoding (Encoding(..))
import Node.FS.Sync as FS
import Node.Path as Path

data ModuleID = ModuleID (Maybe String) (Array String)

data ModuleElemID = NamedModuleElemID ModuleID NameIdentifier
                  | TypeModuleElemID ModuleID TypeIdentifier

data IdentifierKind = NameIdentifierKind NameIdentifier
                   | TypeIdentifierKind TypeIdentifier

instance compare_identifier_kind :: Ord IdentifierKind where
  compare (NameIdentifierKind (NameIdentifier name)) (NameIdentifierKind (NameIdentifier name')) = compare name name'
  compare (TypeIdentifierKind (TypeIdentifier name)) (TypeIdentifierKind (TypeIdentifier name')) = compare name name'
  compare (NameIdentifierKind _) _ = GT
  compare _ (NameIdentifierKind _) = LT

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
                
data ProgramType = ProgramType ProgramTypeKind ModulePositionID 

type ModuleDeclarations = Map.Map ModuleElemID (Tuple ModuleDeclaration ProgramType)
type ProgramModules = Map.Map ModuleID Module
type ModuleExports = Set ModuleElemID
type ProgramTypes = Set ProgramType

type TypeMap = Map.Map IdentifierKind ProgramType
type ExpressionMap = Map.Map NameIdentifier ProgramType

data Program = Program String ProgramModules ModuleDeclarations ProgramTypes

data FilePath = RelativePath String
              | AbsolutePath String

type PackageConfig =
  { name :: String
  -- , version :: SemVer
  -- , dependencies :: Dependencies
  }

builtin_type_pos = Tuple (ModuleID (Just "dewdrop_std") ["builtins"])

builtin_types :: Map.Map TypeIdentifier ProgramType
builtin_types = Map.fromFoldable
  [ Tuple (TypeIdentifier "I8") (ProgramType I8 builtin_type_pos)
  , Tuple (TypeIdentifier "U8") (ProgramType U8 builtin_type_pos)
  , Tuple (TypeIdentifier "I16") (ProgramType I16 builtin_type_pos)
  , Tuple (TypeIdentifier "U16") (ProgramType U16 builtin_type_pos)
  , Tuple (TypeIdentifier "I32") (ProgramType I32 builtin_type_pos)
  , Tuple (TypeIdentifier "U32") (ProgramType U32 builtin_type_pos)
  , Tuple (TypeIdentifier "I64") (ProgramType I64 builtin_type_pos)
  , Tuple (TypeIdentifier "U64") (ProgramType U64 builtin_type_pos)
  , Tuple (TypeIdentifier "F32") (ProgramType F32 builtin_type_pos)
  , Tuple (TypeIdentifier "F64") (ProgramType F64 builtin_type_pos)
  , Tuple (TypeIdentifier "Int") (ProgramType Integer builtin_type_pos)
  , Tuple (TypeIdentifier "Float") (ProgramType Float builtin_type_pos)
  , Tuple (TypeIdentifier "String") (ProgramType String builtin_type_pos)
  , Tuple (TypeIdentifier "Bool") (ProgramType Bool builtin_type_pos)
  ]
  
new_program :: PackageConfig -> Program
new_program config = Program config.name Map.empty Map.empty builtin_types

type FSModule = 
  { read_file :: FilePath -> Maybe String
  , exists :: FilePath -> Boolean
  , write_file :: FilePath -> Boolean
  }

read_file :: String -> FilePath -> Effect String
read_file base_dir path = do
  case path of
    RelativePath path -> do
      let file_path = Path.concat [base_dir, path]
      contents_buffer <- FS.readFile file_path
      contents <- Buffer.toString UTF8 contents_buffer
      pure contents
    AbsolutePath path -> do
      contents_buffer <- FS.readFile path
      contents <- Buffer.toString UTF8 contents_buffer
      pure contents

exists :: String -> FilePath -> Effect Boolean
exists base_dir path = do
  case path of
    RelativePath path -> do
      let file_path = Path.concat [base_dir, path]
      FS.exists file_path
    AbsolutePath path -> do
      FS.exists path

write_file :: String -> FilePath -> String -> Effect Unit
write_file base_dir path contents = do
    buffer <- Buffer.fromString contents UTF8
    case path of
      RelativePath path -> do
        let file_path = Path.concat [base_dir, path]
        FS.writeFile file_path buffer
      AbsolutePath path -> FS.writeFile path buffer

fs :: String -> Maybe FSModule
fs dir = do
  exists <- FS.exists dir
  case exists of
    true -> Just { read_file: read_file dir, exists: exists dir, write_file: write_file dir }
    false -> Nothing

get_module_path :: ModuleID -> FilePath
get_module_path module_id = do
  case module_id of
    ModuleID Nothing [] -> RelativePath (Path.concat [".", "src", "main.dew"])
    ModuleID Nothing path -> RelativePath (Path.concat [".", "src", (Path.concat path) <> ".dew"])
    ModuleID (Just package_name) [] -> RelativePath (Path.concat [".", "build", "packages", package_name, "src", "main.dew"])
    ModuleID (Just package_name) path -> RelativePath (Path.concat [".", "build", "packages", package_name, "src", (Path.concat path) <> ".dew"])

get_main_module_id :: PackageConfig -> ModuleID
get_main_module_id config = ModuleID Nothing []

add_module :: Program -> ModuleID -> Maybe Program
add_module program module_id = do
  module_path <- get_module_path module_id
  module_contents <- read_file module_path
  new_module <- parse module_contents
  process_declarations program module_id new_module

process_declarations :: Program -> ModuleID -> Module -> Maybe Program
process_declarations program module_id (Module declarations) = do_process_declarations program module_id declarations

do_process_declarations :: Program -> ModuleID -> Array ModuleDeclaration -> Maybe Program
do_process_declarations _ _ _ = Nothing
-- do_process_declarations program module_id [] = Just program
-- do_process_declarations (Program name program_modules program_declarations program_types) module_id (declaration : declarations) = do
  

type TypeIndex = Map.Map Int ProgramType
type NextID = Int

type Constraints = Array Constraint
type Substitution = Map.Map Int ProgramType

data Constraint = Matches ProgramType ProgramType
                | Equals ProgramType ProgramType
                -- | IsVariantOf ProgramType ProgramType

data TypeContext = TypeContext ModuleID NextID TypeIndex Constraints


-- next_id :: TypeContext -> ProgramType -> Int
-- add_constraint :: TypeContext -> Constraint -> TypeContext
-- type_check :: TypeContext -> Expr -> TypeContext




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
