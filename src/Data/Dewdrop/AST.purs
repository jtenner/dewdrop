module Data.Dewdrop.AST where

import Prelude

import Data.Dewdrop.Identifier (Identifier)
import Data.Dewdrop.Parser (Transformer)
import Data.Dewdrop.Token (Token)
import Data.Dewdrop.Visitor (class Pass, class Visitable, visit, visit_all)
import Data.List (List)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))


type Parser t = Transformer Token t

type ParserResult t = Maybe (Tuple t Int)

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


data ModuleID = ModuleID String (List String)
data ModuleElementReference = ModuleElementReference ModuleID Identifier

instance module_element_reference_ord :: Ord ModuleElementReference where
  compare (ModuleElementReference module_id identifier) (ModuleElementReference module_id' identifier') =
    compare module_id module_id' <> compare identifier identifier'

instance module_element_reference_eq :: Eq ModuleElementReference where
  eq (ModuleElementReference module_id identifier) (ModuleElementReference module_id' identifier') =
    module_id == module_id' && identifier == identifier'

instance module_id_ord :: Ord ModuleID where
  compare (ModuleID package_name path) (ModuleID package_name' path') =
    compare package_name package_name' <> compare path path'

instance module_id_eq :: Eq ModuleID where
  eq (ModuleID package_name path) (ModuleID package_name' path') =
    package_name == package_name' && path == path'

reference :: ModuleID -> Identifier -> ModuleElementReference
reference module_id identifier = ModuleElementReference module_id identifier


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

instance show_fn :: Show ModuleFn where
  show (ModuleFn name args return_type expr) = "(ModuleFn " <> show name <> " " <> show args <> " " <> show return_type <> " " <> show expr <> ")"

instance show_fn_param :: Show FnParam where
  show (FnParam name type_expr _) = "(FnParam " <> name <> " " <> show type_expr <> ")"

instance show_type_expr :: Show TypeExpr where
  show (TypeExpr kind _) = "(TypeExpr " <> show kind <> ")"

instance show_type_expr_kind :: Show TypeExprKind where
  show (NamedTypeExpr name) = "(NamedTypeExpr " <> name <> ")"


-- data Module = Module (Array ModuleDeclaration)
instance visitable_module ::
  ( Pass ModuleDeclaration ctx
  , Pass ModuleDeclarationKind ctx
  , Pass ModuleFn ctx
  , Pass Expr ctx
  , Pass ExprKind ctx
  , Pass FnParam ctx
  , Pass TypeExpr ctx
  , Pass TypeExprKind ctx
  , Pass WhenArm ctx
  ) =>
  Visitable Module ctx where
  visit_children (Module declarations) ctx = do
    Tuple ctx' children <- visit_all declarations ctx
    Just $ Tuple ctx' (Module children)

instance visitable_module_declaration ::
  ( Pass ModuleDeclarationKind ctx
  , Pass ModuleFn ctx
  , Pass Expr ctx
  , Pass ExprKind ctx
  , Pass FnParam ctx
  , Pass TypeExpr ctx
  , Pass TypeExprKind ctx
  , Pass WhenArm ctx
  ) =>
  Visitable ModuleDeclaration ctx where
  visit_children (ModuleDeclaration kind n) ctx = do
    Tuple ctx' kind' <- visit kind ctx
    Just $ Tuple ctx' (ModuleDeclaration kind' n)

instance visitable_module_declaration_kind ::
  ( Pass ModuleFn ctx
  , Pass Expr ctx
  , Pass ExprKind ctx
  , Pass FnParam ctx
  , Pass TypeExpr ctx
  , Pass TypeExprKind ctx
  , Pass WhenArm ctx
  ) =>
  Visitable ModuleDeclarationKind ctx where
  visit_children (FnDeclarationKind exported name fn) ctx = do
    Tuple ctx' fn' <- visit fn ctx
    Just $ Tuple ctx' (FnDeclarationKind exported name fn')

instance visitable_module_fn ::
  ( Pass Expr ctx
  , Pass FnParam ctx
  , Pass TypeExpr ctx
  , Pass TypeExprKind ctx
  , Pass Expr ctx
  , Pass ExprKind ctx
  , Pass WhenArm ctx
  ) =>
  Visitable ModuleFn ctx where
  visit_children (ModuleFn name args return_type expr) ctx = do
    Tuple ctx' args' <- visit_all args ctx
    Tuple ctx'' expr' <- visit expr ctx'
    Just $ Tuple ctx'' (ModuleFn name args' return_type expr')

instance visitable_fn_param ::
  ( Pass TypeExpr ctx
  , Pass TypeExprKind ctx
  ) =>
  Visitable FnParam ctx where
  visit_children (FnParam name type_guard n) ctx = do
    Tuple ctx' type_guard' <- visit type_guard ctx
    Just $ Tuple ctx' (FnParam name type_guard' n)




instance visitable_type_expr :: (Pass TypeExprKind ctx) => Visitable TypeExpr ctx where
  visit_children (TypeExpr kind _) ctx = do
    Tuple ctx' kind' <- visit kind ctx
    Just $ Tuple ctx' (TypeExpr kind' 0)

instance visitable_type_expr_kind :: Visitable TypeExprKind ctx where
  visit_children kind ctx = Just $ Tuple ctx kind

instance visitable_expr ::
  ( Pass Expr ctx
  , Pass ExprKind ctx
  , Pass WhenArm ctx
  ) =>
  Visitable Expr ctx where
  visit_children (Expr kind n) ctx = do
    Tuple ctx' kind' <- visit kind ctx
    Just $ Tuple ctx' $ Expr kind' n

instance visitable_expr_kind ::
  ( Pass ExprKind ctx
  , Pass Expr ctx
  , Pass WhenArm ctx
  ) =>
  Visitable ExprKind ctx where
  visit_children (WhenExpr arms maybe_else) ctx = do
    Tuple ctx' arms' <- visit_all arms ctx
    Tuple ctx'' maybe_else' <- visit maybe_else ctx'
    Just $ Tuple ctx'' $ WhenExpr arms' maybe_else'

  visit_children (BlockExpr body) ctx = do
    Tuple ctx' body' <- visit_all body ctx
    Just $ Tuple ctx' (BlockExpr body')

  visit_children (EqualsExpr l r) ctx = visit_binary EqualsExpr l r ctx
  visit_children (AddExpr l r) ctx = visit_binary AddExpr l r ctx
  visit_children (SubExpr l r) ctx = visit_binary SubExpr l r ctx
  visit_children (MulExpr l r) ctx = visit_binary MulExpr l r ctx
  visit_children (DivExpr l r) ctx = visit_binary DivExpr l r ctx
  visit_children (GreaterThanExpr l r) ctx = visit_binary GreaterThanExpr l r ctx
  visit_children (LessThanExpr l r) ctx = visit_binary LessThanExpr l r ctx
  visit_children (GreaterThanEqualsExpr l r) ctx = visit_binary GreaterThanEqualsExpr l r ctx
  visit_children (LessThanEqualsExpr l r) ctx = visit_binary LessThanEqualsExpr l r ctx
  visit_children (CallExpr callee args) ctx = do
    Tuple ctx' callee' <- visit callee ctx
    Tuple ctx'' args' <- visit_all args ctx'
    Just $ Tuple ctx'' $ CallExpr callee' args'
  visit_children n ctx = Just $ Tuple ctx n

visit_binary
  :: ∀ (@ctx :: Type)
   . Pass ExprKind ctx
  => Pass Expr ctx
  => Pass WhenArm ctx
  => (Expr -> Expr -> ExprKind)
  -> Expr
  -> Expr
  -> ctx
  -> Maybe (Tuple ctx ExprKind)
visit_binary kind l r ctx = do
  Tuple inner_ctx l' <- visit l ctx
  Tuple inner_ctx' r' <- visit r inner_ctx
  Just $ Tuple inner_ctx' $ kind l' r'

instance visitable_when_arm ::
  ( Pass Expr ctx
  , Pass ExprKind ctx
  , Pass WhenArm ctx
  ) =>
  Visitable WhenArm ctx where
  visit_children (WhenArm condition body) ctx = do
    Tuple inner_ctx condition' <- visit condition ctx
    Tuple inner_ctx' body' <- visit body inner_ctx
    Just $ Tuple inner_ctx' (WhenArm condition' body')
