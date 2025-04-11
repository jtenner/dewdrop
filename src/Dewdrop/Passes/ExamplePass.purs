module Dewdrop.Passes.ExamplePass where

import Prelude

import Data.List (List(..))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))

import Data.Dewdrop.AST (Expr, ExprKind, FnParam, Module, ModuleDeclaration, ModuleDeclarationKind, ModuleFn, TypeExpr, TypeExprKind, WhenArm)
import Data.Dewdrop.Compiler (Compiler)
import Data.Dewdrop.Visitor (class Pass, class Visitable, ignore, visit)

type Props = {}
data ExamplePassContext = ExamplePassContext (List Props) Compiler

props_new :: Props
props_new = {}

run ∷ Pass Module ExamplePassContext ⇒ Visitable Module ExamplePassContext ⇒ Module → Compiler → Maybe Compiler
run mod compiler = do
  let ctx = ExamplePassContext Nil compiler
  Tuple (ExamplePassContext _ compiler') _ <- visit mod ctx
  Just compiler'

instance constrant_generation_module_pass :: Pass Module ExamplePassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_declaration_pass :: Pass ModuleDeclaration ExamplePassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_declaration_kind_pass :: Pass ModuleDeclarationKind ExamplePassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_fn_pass :: Pass ModuleFn ExamplePassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_fn_param_pass :: Pass FnParam ExamplePassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_type_expr_pass :: Pass TypeExpr ExamplePassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_type_expr_kind_pass :: Pass TypeExprKind ExamplePassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_expr_pass :: Pass Expr ExamplePassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_expr_kind_pass :: Pass ExprKind ExamplePassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_when_arm_pass :: Pass WhenArm ExamplePassContext where
  enter = ignore
  exit = ignore
