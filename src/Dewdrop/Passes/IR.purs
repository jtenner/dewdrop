module Dewdrop.Passes.TypeIRLower where

import Data.Dewdrop.AST (Expr, ExprKind, FnParam, Module, ModuleDeclaration, ModuleDeclarationKind, ModuleFn, TypeExpr, TypeExprKind, WhenArm)
import Data.Dewdrop.Compiler (Compiler)
import Data.Dewdrop.Identifier (Identifier)
import Data.Dewdrop.Types (IRBoundsID, ModuleContext(..), TypedIRID)
import Data.Dewdrop.Visitor (class Pass, class Visitable, ignore, visit)
import Prelude

import Data.List (List(..))
import Data.Map (Map)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))

type IRContextProps = { module_ctx :: ModuleContext }
type IREnv = Map Identifier TypedIRID
data IRContext system_ctx = IRContext
  { compiler :: Compiler system_ctx
  , env_stack :: List IREnv
  , fn_stack :: List (IRContext system_ctx)
  , ir_stack :: List TypedIRID
  , module_ctx :: ModuleContext
  , type_stack :: List IRBoundsID
  }

run :: ∀ (@u :: Type). Pass Module (IRContext u) => Visitable Module (IRContext u) => IRContextProps -> Compiler u -> Maybe (Compiler u)
run { module_ctx } compiler = do
  let
    (ModuleContext { ast }) = module_ctx
    ctx = IRContext { compiler, env_stack: Nil, ir_stack: Nil, module_ctx, fn_stack: Nil, type_stack: Nil }
  Tuple (IRContext { compiler: compiler' }) ast' <- visit ast ctx
  Just compiler'


instance type_ir_lower_module_pass :: Pass Module (IRContext u) where
  enter = ignore
  exit = ignore

instance type_ir_lower_declaration_pass :: Pass ModuleDeclaration (IRContext u) where
  enter = ignore
  exit = ignore

instance type_ir_lower_declaration_kind_pass :: Pass ModuleDeclarationKind (IRContext u) where
  enter = ignore
  exit = ignore

instance type_ir_lower_fn_pass :: Pass ModuleFn (IRContext u) where
  enter = ignore
  exit = ignore

instance type_ir_lower_fn_param_pass :: Pass FnParam (IRContext u) where
  enter = ignore
  exit = ignore

instance type_ir_lower_type_expr_pass :: Pass TypeExpr (IRContext u) where
  enter = ignore
  exit = ignore

instance type_ir_lower_type_expr_kind_pass :: Pass TypeExprKind (IRContext u) where
  enter = ignore
  exit = ignore

instance type_ir_lower_expr_pass :: Pass Expr (IRContext u) where
  enter = ignore
  exit = ignore

instance type_ir_lower_expr_kind_pass :: Pass ExprKind (IRContext u) where
  enter = ignore
  exit = ignore

-- AddExpr
-- SubExpr
-- MulExpr
-- DivExpr
-- WhenExpr
-- BlockExpr
-- EqualsExpr
-- NameExpr
-- CallExpr
-- GreaterThanExpr
-- LessThanExpr
-- GreaterThanEqualsExpr
-- LessThanEqualsExpr

instance type_ir_lower_when_arm_pass :: Pass WhenArm (IRContext u) where
  enter = ignore
  exit = ignore
