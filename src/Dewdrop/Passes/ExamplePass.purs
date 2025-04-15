module Dewdrop.Passes.ExamplePass where

import Prelude

import Data.List (List(..))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))

import Data.Dewdrop.AST (Expr, ExprKind, FnParam, Module, ModuleDeclaration, ModuleDeclarationKind, ModuleFn, TypeExpr, TypeExprKind, WhenArm)
import Data.Dewdrop.Compiler (Compiler)
import Data.Dewdrop.Visitor (class Pass, class Visitable, ignore, visit)

type Props = {}
data ExamplePassContext system_ctx = ExamplePassContext (List Props) (Compiler system_ctx)

props_new :: Props
props_new = {}

run ∷ ∀ (@system_ctx :: Type). Pass Module (ExamplePassContext system_ctx) ⇒ Visitable Module (ExamplePassContext system_ctx) ⇒ Module → Compiler system_ctx → Maybe (Compiler system_ctx)
run mod compiler = do
  let ctx = ExamplePassContext Nil compiler
  Tuple (ExamplePassContext _ compiler') _ <- visit mod ctx
  Just compiler'

instance constrant_generation_module_pass :: Pass Module (ExamplePassContext system_ctx) where
  enter = ignore
  exit = ignore

instance constraint_generation_declaration_pass :: Pass ModuleDeclaration (ExamplePassContext system_ctx) where
  enter = ignore
  exit = ignore

instance constraint_generation_declaration_kind_pass :: Pass ModuleDeclarationKind (ExamplePassContext system_ctx) where
  enter = ignore
  exit = ignore

instance constraint_generation_fn_pass :: Pass ModuleFn (ExamplePassContext system_ctx) where
  enter = ignore
  exit = ignore

instance constraint_generation_fn_param_pass :: Pass FnParam (ExamplePassContext system_ctx) where
  enter = ignore
  exit = ignore

instance constraint_generation_type_expr_pass :: Pass TypeExpr (ExamplePassContext system_ctx) where
  enter = ignore
  exit = ignore

instance constraint_generation_type_expr_kind_pass :: Pass TypeExprKind (ExamplePassContext system_ctx) where
  enter = ignore
  exit = ignore

instance constraint_generation_expr_pass :: Pass Expr (ExamplePassContext system_ctx) where
  enter = ignore
  exit = ignore

instance constraint_generation_expr_kind_pass :: Pass ExprKind (ExamplePassContext system_ctx) where
  enter = ignore
  exit = ignore

instance constraint_generation_when_arm_pass :: Pass WhenArm (ExamplePassContext system_ctx) where
  enter = ignore
  exit = ignore
