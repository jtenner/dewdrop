module Dewdrop.Types where

import Prelude
import Data.Graph (Graph)
import Data.Graph as Graph
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple)
import Data.FingerTree (FingerTree, empty)

data Token = Token TokenKind Int

data TokenKind
  = TokenKindPubKeyword
  | TokenKindFnKeyword
  | TokenKindWhenKeyword
  | TokenKindElseKeyword
  | TokenKindNameIdentifier String
  | TokenKindTypeIdentifier String
  | TokenKindInt Int
  | TokenKindLParen
  | TokenKindRParen
  | TokenKindLBrace
  | TokenKindRBrace
  | TokenKindEqualsEquals
  | TokenKindAsterisk
  | TokenKindFSlash
  | TokenKindPlus
  | TokenKindMinus
  | TokenKindComma
  | TokenKindColon
  | TokenKindRArrow
  | TokenKindGreaterThan
  | TokenKindGreaterThanOrEqual
  | TokenKindLessThan
  | TokenKindLessThanOrEqual
  | TokenKindWhiteSpace
  | TokenKindNewLine
  | TokenKindEOF

instance show_token_kind :: Show TokenKind where
  show TokenKindPubKeyword = "TokenKindPubKeyword"
  show TokenKindFnKeyword = "TokenKindFnKeyword"
  show TokenKindWhenKeyword = "TokenKindWhenKeyword"
  show TokenKindElseKeyword = "TokenKindElseKeyword"
  show (TokenKindNameIdentifier name) = "(TokenKindNameIdentifier " <> name <> ")"
  show (TokenKindTypeIdentifier name) = "(TokenKindTypeIdentifier " <> name <> ")"
  show (TokenKindInt value) = "(TokenKindInt " <> show value <> ")"
  show TokenKindLParen = "TokenKindLParen"
  show TokenKindRParen = "TokenKindRParen"
  show TokenKindLBrace = "TokenKindLBrace"
  show TokenKindRBrace = "TokenKindRBrace"
  show TokenKindEqualsEquals = "TokenKindEqualsEquals"
  show TokenKindPlus = "TokenKindPlus"
  show TokenKindMinus = "TokenKindMinus"
  show TokenKindAsterisk = "TokenKindAsterisk"
  show TokenKindFSlash = "TokenKindFSlash"
  show TokenKindComma = "TokenKindComma"
  show TokenKindColon = "TokenKindColon"
  show TokenKindRArrow = "TokenKindRArrow"
  show TokenKindGreaterThan = "TokenKindGreaterThan"
  show TokenKindGreaterThanOrEqual = "TokenKindGreaterThanOrEqual"
  show TokenKindLessThan = "TokenKindLessThan"
  show TokenKindLessThanOrEqual = "TokenKindLessThanOrEqual"
  show TokenKindEOF = "TokenKindEOF"
  show TokenKindWhiteSpace = "TokenKindWhiteSpace"
  show TokenKindNewLine = "TokenKindNewLine"

derive instance equals :: Eq TokenKind

instance show :: Show Token where
  show (Token kind pos) = "(Token " <> show kind <> ": " <> show pos <> ")"

derive instance eq :: Eq Token

data Identifier
  = NameIdentifier String
  | TypeIdentifier String

instance eq_identifier :: Eq Identifier where
  eq (NameIdentifier name) (NameIdentifier name') = name == name'
  eq (TypeIdentifier type_name) (TypeIdentifier type_name') = type_name == type_name'
  eq _ _ = false

instance ord_identifier :: Ord Identifier where
  compare (NameIdentifier name) (NameIdentifier name') = compare name name'
  compare (TypeIdentifier type_name) (TypeIdentifier type_name') = compare type_name type_name'
  compare (NameIdentifier _) _ = GT
  compare _ (NameIdentifier _) = LT

data Module = Module (Array ModuleDeclaration)

data ModuleDeclaration = ModuleDeclaration ModuleDeclarationKind Int

data ModuleDeclarationKind = FnDeclarationKind Boolean Identifier ModuleFn

data ModuleFn = ModuleFn (Maybe String) (Array FnParam) (Maybe TypeExpr) Expr

data FnParam = FnParam String (Maybe TypeExpr) Int

data TypeExpr = TypeExpr TypeExprKind Int

data TypeExprKind = NamedTypeExpr String

data Expr = Expr ExprKind Int

data ExprKind
  = WhenExpr (Array WhenArm) (Maybe Expr)
  | BlockExpr (Array Expr)
  | EqualsExpr Expr Expr
  | IntExpr Int
  | NameExpr String
  | CallExpr Expr (Array Expr)
  | AddExpr Expr Expr
  | SubExpr Expr Expr
  | MulExpr Expr Expr
  | DivExpr Expr Expr
  | GreaterThanExpr Expr Expr
  | LessThanExpr Expr Expr
  | GreaterThanEqualsExpr Expr Expr
  | LessThanEqualsExpr Expr Expr

data WhenArm = WhenArm Expr Expr

type ParserResult t = Maybe (Tuple t Int)

-- helpers
type Parser t = Array Token -> Int -> ParserResult t

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
    parameters = empty
    constraints = empty
    type_env = Map.empty

  TypeContextFn
    { return_type
    , next_id
    , type_index
    , parameters
    , constraints
    , type_env
    }

instance show_expr :: Show Expr where
  show (Expr kind _) = "(Expr " <> show kind <> ")"

instance show_expr_kind :: Show ExprKind where
  show (WhenExpr arms default_expr) = "(WhenExpr " <> show arms <> " " <> show default_expr <> ")"
  show (EqualsExpr left right) = "(EqualsExpr " <> show left <> " " <> show right <> ")"
  show (IntExpr value) = "(IntExpr " <> show value <> ")"
  show (NameExpr name) = "(NameExpr " <> name <> ")"
  show (CallExpr expr args) = "(CallExpr " <> show expr <> " " <> show args <> ")"
  show (AddExpr left right) = "(AddExpr " <> show left <> " " <> show right <> ")"
  show (SubExpr left right) = "(SubExpr " <> show left <> " " <> show right <> ")"
  show (MulExpr left right) = "(MulExpr " <> show left <> " " <> show right <> ")"
  show (DivExpr left right) = "(DivExpr " <> show left <> " " <> show right <> ")"
  show (GreaterThanExpr left right) = "(GreaterThanExpr " <> show left <> " " <> show right <> ")"
  show (LessThanExpr left right) = "(LessThanExpr " <> show left <> " " <> show right <> ")"
  show (GreaterThanEqualsExpr left right) = "(GreaterThanEqualsExpr " <> show left <> " " <> show right <> ")"
  show (LessThanEqualsExpr left right) = "(LessThanEqualsExpr " <> show left <> " " <> show right <> ")"
  show (BlockExpr exprs) = "(BlockExpr " <> show exprs <> ")"

instance show_when_arm :: Show WhenArm where
  show (WhenArm condition expr) = "(WhenArm " <> show condition <> " " <> show expr <> ")"

instance show_module :: Show Module where
  show (Module declarations) = "(Module " <> show declarations <> ")"

instance show_module_declaration :: Show ModuleDeclaration where
  show (ModuleDeclaration kind _) = "(ModuleDeclaration " <> show kind <> ")"

instance show_module_declaration_kind :: Show ModuleDeclarationKind where
  show (FnDeclarationKind exported name fn) = "(FnDeclarationKind " <> show exported <> " " <> show name <> " " <> show fn <> ")"

instance show_identifier :: Show Identifier where
  show (NameIdentifier name) = "(Name " <> name <> ")"
  show (TypeIdentifier name) = "(Type " <> name <> ")"

instance show_fn :: Show ModuleFn where
  show (ModuleFn name args return_type expr) = "(ModuleFn " <> show name <> " " <> show args <> " " <> show return_type <> " " <> show expr <> ")"

instance show_fn_param :: Show FnParam where
  show (FnParam name type_expr _) = "(FnParam " <> name <> " " <> show type_expr <> ")"

instance show_type_expr :: Show TypeExpr where
  show (TypeExpr kind _) = "(TypeExpr " <> show kind <> ")"

instance show_type_expr_kind :: Show TypeExprKind where
  show (NamedTypeExpr name) = "(NamedTypeExpr " <> name <> ")"
