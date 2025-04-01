module Dewdrop.Passes.CollectExports where

import Prelude

import Data.Map (insert, lookup)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Dewdrop.Types (Compiler, Expr, ExprKind, FnParam, Module, ModuleContext, ModuleDeclaration, ModuleDeclarationKind(..), ModuleFn, ModuleID, TypeExpr, TypeExprKind, WhenArm, reference)
import Record (merge)
import Visitor.Pattern (class Pass, class Visitable, ignore, skip_all, visit)

type CollectExportsProps = 
  { module_id :: ModuleID }

data CollectExportsContext = CollectExportsContext CollectExportsProps ModuleContext Compiler

run :: Pass Module CollectExportsContext => Visitable Module CollectExportsContext => CollectExportsProps -> Compiler -> Maybe Compiler
run props@{ module_id } compiler@{ modules } = case lookup module_id modules of
  Nothing -> Nothing
  Just module_ctx -> do
    let { ast } = module_ctx
    let ctx = CollectExportsContext props module_ctx compiler
    Tuple (CollectExportsContext _ module_ctx' _) ast' <- visit ast ctx
    let module_ctx'' = merge { ast: ast' } module_ctx'
    let modules' = insert module_id module_ctx'' modules
    let compiler' = merge { modules: modules' } compiler
    Just compiler'

instance constrant_generation_module_pass :: Pass Module CollectExportsContext where
  enter = ignore
  exit = ignore

instance constraint_generation_declaration_pass :: Pass ModuleDeclaration CollectExportsContext where
  enter = ignore
  exit = ignore

instance constraint_generation_declaration_kind_pass :: Pass ModuleDeclarationKind CollectExportsContext where
  enter (FnDeclarationKind true name _) (CollectExportsContext props module_context@{ module_id, exports } compiler) = do
    let exports' = insert name (reference module_id name) exports
    let module_context' = merge { exports: exports' } module_context
    skip_all (CollectExportsContext props module_context' compiler)
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
