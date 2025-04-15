module Dewdrop.Passes.CollectExports where

import Prelude

import Data.Dewdrop.AST (Expr, ExprKind, FnParam, Module, ModuleDeclaration, ModuleDeclarationKind(..), ModuleFn, TypeExpr, TypeExprKind, WhenArm)
import Data.Dewdrop.Compiler (Compiler(..), ModuleID, ModuleContext(..), reference)
import Data.Dewdrop.Visitor (class Pass, class Visitable, ignore, skip_all, visit)
import Data.Map (insert, lookup)
import Data.Maybe (Maybe(..))
import Data.Set as Set
import Data.Tuple (Tuple(..))
import Record (merge)

type CollectExportsProps =
  { module_id :: ModuleID }

data CollectExportsContext system_ctx = CollectExportsContext CollectExportsProps ModuleContext (Compiler system_ctx)

run :: ∀ (@system_ctx :: Type). Pass Module (CollectExportsContext system_ctx) => Visitable Module (CollectExportsContext system_ctx) => CollectExportsProps -> Compiler system_ctx -> Maybe (Compiler system_ctx)
run props@{ module_id } (Compiler compiler@{ modules }) = case lookup module_id modules of
  Nothing -> Nothing
  Just module_ctx -> do
    let ModuleContext { ast } = module_ctx
    let ctx = CollectExportsContext props module_ctx (Compiler compiler)
    Tuple (CollectExportsContext _ (ModuleContext module_ctx') _) ast' <- visit ast ctx
    let module_ctx'' = ModuleContext $ merge { ast: ast' } module_ctx'
    let modules' = insert module_id module_ctx'' modules
    Just $ Compiler $ merge { modules: modules' } compiler

instance collect_exports_module_pass :: Pass Module (CollectExportsContext system_ctx) where
  enter = ignore
  exit = ignore

instance collect_exports_declaration_pass :: Pass ModuleDeclaration (CollectExportsContext system_ctx) where
  enter = ignore
  exit = ignore

instance collect_exports_declaration_kind_pass :: Pass ModuleDeclarationKind (CollectExportsContext system_ctx) where
  enter (FnDeclarationKind true name _) (CollectExportsContext props@{ module_id } (ModuleContext module_context@{ exports }) compiler) = do
    let exports' = Set.insert (reference module_id name) exports
    let module_context' = ModuleContext $ merge { exports: exports' } module_context
    skip_all (CollectExportsContext props module_context' compiler)
  enter a b = ignore a b
  exit = ignore

instance collect_exports_fn_pass :: Pass ModuleFn (CollectExportsContext system_ctx) where
  enter = ignore
  exit = ignore

instance collect_exports_fn_param_pass :: Pass FnParam (CollectExportsContext system_ctx) where
  enter = ignore
  exit = ignore

instance collect_exports_type_expr_pass :: Pass TypeExpr (CollectExportsContext system_ctx) where
  enter = ignore
  exit = ignore

instance collect_exports_expr_pass :: Pass Expr (CollectExportsContext system_ctx) where
  enter = ignore
  exit = ignore

instance collect_exports_expr_kind_pass :: Pass ExprKind (CollectExportsContext system_ctx) where
  enter = ignore
  exit = ignore

instance collect_exports_when_arm_pass :: Pass WhenArm (CollectExportsContext system_ctx) where
  enter = ignore
  exit = ignore

instance collect_exports_type_expr_kind_pass :: Pass TypeExprKind (CollectExportsContext system_ctx) where
  enter = ignore
  exit = ignore
