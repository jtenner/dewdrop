module Dewdrop.Pass where

import Dewdrop.Types
import Prelude
import Visitor.Pattern

import Data.Tuple (Tuple(..))

class Pass ctx where
  enter_module :: Module -> ctx -> VisitResult ctx Module
  exit_module :: Module -> ctx -> VisitResult ctx Module
  enter_module_declaration :: ModuleDeclaration -> ctx -> VisitResult ctx ModuleDeclaration
  exit_module_declaration :: ModuleDeclaration -> ctx -> VisitResult ctx ModuleDeclaration
  enter_module_declaration_kind :: ModuleDeclarationKind -> ctx -> VisitResult ctx ModuleDeclarationKind
  exit_module_declaration_kind :: ModuleDeclarationKind -> ctx -> VisitResult ctx ModuleDeclarationKind
  enter_module_fn :: ModuleFn -> ctx -> VisitResult ctx ModuleFn
  exit_module_fn :: ModuleFn -> ctx -> VisitResult ctx ModuleFn
  enter_fn_param :: FnParam -> ctx -> VisitResult ctx FnParam
  exit_fn_param :: FnParam -> ctx -> VisitResult ctx FnParam
  enter_type_expr :: TypeExpr -> ctx -> VisitResult ctx TypeExpr
  exit_type_expr :: TypeExpr -> ctx -> VisitResult ctx TypeExpr
  enter_type_expr_kind :: TypeExprKind -> ctx -> VisitResult ctx TypeExprKind
  exit_type_expr_kind :: TypeExprKind -> ctx -> VisitResult ctx TypeExprKind
  enter_expr :: Expr -> ctx -> VisitResult ctx Expr
  exit_expr :: Expr -> ctx -> VisitResult ctx Expr
  enter_expr_kind :: ExprKind -> ctx -> VisitResult ctx ExprKind
  exit_expr_kind :: ExprKind -> ctx -> VisitResult ctx ExprKind
  enter_when_arm :: WhenArm -> ctx -> VisitResult ctx WhenArm
  exit_when_arm :: WhenArm -> ctx -> VisitResult ctx WhenArm

ignore :: ∀ (@ctx :: Type) (@node :: Type). node -> ctx -> VisitResult ctx node
ignore _ ctx = continue ctx 

instance default_purescript_pass :: Pass ctx where
  enter_module = ignore
  exit_module = ignore
  enter_module_declaration = ignore
  exit_module_declaration = ignore
  enter_module_declaration_kind = ignore
  exit_module_declaration_kind = ignore
  enter_module_fn = ignore
  exit_module_fn = ignore
  enter_fn_param = ignore
  exit_fn_param = ignore
  enter_type_expr = ignore
  exit_type_expr = ignore
  enter_type_expr_kind = ignore
  exit_type_expr_kind = ignore
  enter_expr = ignore
  exit_expr = ignore
  enter_expr_kind = ignore
  exit_expr_kind = ignore
  enter_when_arm = ignore
  exit_when_arm = ignore

-- data Module = Module (Array ModuleDeclaration)
visit_module :: forall ctx. Pass ctx => ctx -> Module -> VisitResult ctx Module
visit_module ctx mod = do
  Tuple ctx' enter_action <- enter_module mod ctx
  let Module declarations = from_action enter_action ctx'
  Tuple ctx'' children_action <- visit_all visit_module_declaration ctx'' declarations
  let declarations = from_action children_action declarations
  exit_module (Module declarations) ctx''

-- data ModuleDeclaration = ModuleDeclaration ModuleDeclarationKind Int

-- data ModuleDeclarationKind = FnDeclarationKind Boolean Identifier ModuleFn

-- data ModuleFn = ModuleFn (Maybe String) (Array FnParam) (Maybe TypeExpr) Expr

-- data FnParam = FnParam String (Maybe TypeExpr) Int

-- data TypeExpr = TypeExpr TypeExprKind Int

-- data TypeExprKind = NamedTypeExpr String

-- data Expr = Expr ExprKind Int

-- data ExprKind
--   = WhenExpr (Array WhenArm) (Maybe Expr)
--   | BlockExpr (Array Expr)
--   | EqualsExpr Expr Expr
--   | IntExpr Int
--   | NameExpr String
--   | CallExpr Expr (Array Expr)
--   | AddExpr Expr Expr
--   | SubExpr Expr Expr
--   | MulExpr Expr Expr
--   | DivExpr Expr Expr
--   | GreaterThanExpr Expr Expr
--   | LessThanExpr Expr Expr
--   | GreaterThanEqualsExpr Expr Expr
--   | LessThanEqualsExpr Expr Expr

-- data WhenArm = WhenArm Expr Expr