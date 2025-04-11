module Dewdrop.Passes.CollectExports where

import Prelude

import Data.Dewdrop.AST (Expr, ExprKind, FnParam, Module, ModuleDeclaration, ModuleDeclarationKind(..), ModuleFn, ModuleID, TypeExpr, TypeExprKind, WhenArm, reference)
import Data.Dewdrop.Compiler
import Data.Dewdrop.Types (ModuleContext(..))
import Data.Dewdrop.Visitor (class Pass, class Visitable, ignore, skip_all, visit)
import Data.Map (insert, lookup)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Record (merge)

type CollectExportsProps =
  { module_id :: ModuleID }

data CollectExportsContext = CollectExportsContext CollectExportsProps ModuleContext Compiler

run :: Pass Module CollectExportsContext => Visitable Module CollectExportsContext => CollectExportsProps -> Compiler -> Maybe Compiler
run props@{ module_id } compiler@{ modules } = case lookup module_id modules of
  Nothing -> Nothing
  Just module_ctx -> do
    let ModuleContext { ast } = module_ctx
    let ctx = CollectExportsContext props module_ctx compiler
    Tuple (CollectExportsContext _ (ModuleContext module_ctx') _) ast' <- visit ast ctx
    let module_ctx'' = ModuleContext $ merge { ast: ast' } module_ctx'
    let modules' = insert module_id module_ctx'' modules
    Just $ merge { modules: modules' } compiler

instance collect_exports_module_pass :: Pass Module CollectExportsContext where
  enter = ignore
  exit = ignore

instance collect_exports_declaration_pass :: Pass ModuleDeclaration CollectExportsContext where
  enter = ignore
  exit = ignore

instance collect_exports_declaration_kind_pass :: Pass ModuleDeclarationKind CollectExportsContext where
  enter (FnDeclarationKind true name _) (CollectExportsContext props (ModuleContext module_context@{ module_id, exports }) compiler) = do
    let exports' = insert name (reference module_id name) exports
    let module_context' = ModuleContext $ merge { exports: exports' } module_context
    skip_all (CollectExportsContext props module_context' compiler)
  enter a b = ignore a b
  exit = ignore

instance collect_exports_fn_pass :: Pass ModuleFn CollectExportsContext where
  enter = ignore
  exit = ignore

instance collect_exports_fn_param_pass :: Pass FnParam CollectExportsContext where
  enter = ignore
  exit = ignore

instance collect_exports_type_expr_pass :: Pass TypeExpr CollectExportsContext where
  enter = ignore
  exit = ignore

instance collect_exports_expr_pass :: Pass Expr CollectExportsContext where
  enter = ignore
  exit = ignore

instance collect_exports_expr_kind_pass :: Pass ExprKind CollectExportsContext where
  enter = ignore
  exit = ignore

instance collect_exports_when_arm_pass :: Pass WhenArm CollectExportsContext where
  enter = ignore
  exit = ignore

instance collect_exports_type_expr_kind_pass :: Pass TypeExprKind CollectExportsContext where
  enter = ignore
  exit = ignore
