module Dewdrop.Passes.CollectExportsPass where

import Prelude

import Data.Map (insert)
import Data.Maybe (Maybe)
import Data.Tuple (Tuple)
import Dewdrop.Types (Expr, ExprKind, FnParam, Module, ModuleContext, ModuleDeclaration, ModuleDeclarationKind(..), ModuleFn, ModuleReference(..), TypeExpr, TypeExprKind, WhenArm)
import Record (merge)
import Visitor.Pattern (class Pass, ignore, skip_all, visit)

data CollectExportsContext = CollectExportsContext ModuleContext

collect_exports_context_new :: ModuleContext -> CollectExportsContext
collect_exports_context_new module_ctx = CollectExportsContext module_ctx

run :: Module -> ModuleContext -> Maybe (Tuple CollectExportsContext Module)
run mod module_ctx = visit mod $ collect_exports_context_new module_ctx

instance constrant_generation_module_pass :: Pass Module CollectExportsContext where
  enter = ignore
  exit = ignore

instance constraint_generation_declaration_pass :: Pass ModuleDeclaration CollectExportsContext where
  enter = ignore
  exit = ignore

instance constraint_generation_declaration_kind_pass :: Pass ModuleDeclarationKind CollectExportsContext where
  enter (FnDeclarationKind true name fn) (CollectExportsContext module_context@{ resource_id, exports }) = do
    let exports' = insert name (ModuleReference resource_id name) exports
    let module_context' = merge { exports: exports' } module_context
    skip_all (CollectExportsContext module_context')
  enter a b = ignore a b
  exit = ignore

instance constraint_generation_fn_pass :: Pass ModuleFn CollectExportsContext where
  enter = ignore
  exit = ignore

instance constraint_generation_fn_param_pass :: Pass FnParam CollectExportsContext where
  enter = ignore
  exit = ignore

instance constraint_generation_type_expr_pass :: Pass TypeExpr CollectExportsContext where
  enter = ignore
  exit = ignore

instance constraint_generation_expr_pass :: Pass Expr CollectExportsContext where
  enter = ignore
  exit = ignore

instance constraint_generation_expr_kind_pass :: Pass ExprKind CollectExportsContext where
  enter = ignore
  exit = ignore

instance constraint_generation_when_arm_pass :: Pass WhenArm CollectExportsContext where
  enter = ignore
  exit = ignore

instance constraint_generation_type_expr_kind_pass :: Pass TypeExprKind CollectExportsContext where
  enter = ignore
  exit = ignore
