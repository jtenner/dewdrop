module Dewdrop.Passes.CollectExports where

import Prelude

import Data.Dewdrop.AST (Expr, ExprKind, FnParam, Module, ModuleDeclaration, ModuleDeclarationKind(..), ModuleFn, TypeExpr, TypeExprKind, WhenArm)
import Data.Dewdrop.Compiler (Compiler(..), ModuleID, ModuleContext(..), reference)
import Data.Dewdrop.Visitor (class Pass, class Visitable, ignore, skip_all, visit)
import Data.Map (insert, lookup)
import Data.Maybe (Maybe)
import Data.Set as Set
import Data.Tuple (Tuple(..))
import Record (merge)

data CollectExportsProps = CollectExportsProps { module_id :: ModuleID }

data CollectExportsContext system_ctx = CollectExportsContext
  { compiler :: Compiler system_ctx
  , module_ctx :: ModuleContext
  , module_id :: ModuleID
  }

run :: ∀ (@system_ctx :: Type). Pass Module (CollectExportsContext system_ctx) => Visitable Module (CollectExportsContext system_ctx) => CollectExportsProps -> Compiler system_ctx -> Maybe (Compiler system_ctx)
run (CollectExportsProps { module_id }) compiler@(Compiler { modules }) = do
  module_ctx@(ModuleContext { ast }) <- lookup module_id modules
  let
    ctx = CollectExportsContext { compiler, module_ctx, module_id }
  Tuple (CollectExportsContext { compiler: (Compiler compiler'), module_ctx: (ModuleContext module_ctx') }) ast' <- visit ast ctx
  let
    module_context'' = ModuleContext $ merge { ast: ast' } module_ctx'
    modules' = insert module_id module_context'' modules
  pure $ Compiler $ merge { modules: modules' } compiler'

instance collect_exports_module_pass :: Pass Module (CollectExportsContext system_ctx) where
  enter = ignore
  exit = ignore

instance collect_exports_declaration_pass :: Pass ModuleDeclaration (CollectExportsContext system_ctx) where
  enter = ignore
  exit = ignore

instance collect_exports_declaration_kind_pass :: Pass ModuleDeclarationKind (CollectExportsContext system_ctx) where
  enter (FnDeclarationKind true name _) (CollectExportsContext inner_ctx@{ module_id, module_ctx }) = do
    let
      ModuleContext inner_module_ctx@{ exports } = module_ctx
      exports' = Set.insert (reference module_id name) exports
      module_context' = ModuleContext $ merge { exports: exports' } inner_module_ctx

    skip_all (CollectExportsContext $ merge { module_ctx: module_context' } inner_ctx)
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
