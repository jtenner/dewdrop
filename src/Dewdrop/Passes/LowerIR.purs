module Dewdrop.Passes.TypeIRLower where

import Prelude

import Data.Dewdrop.AST (Expr, ExprKind, FnParam, Module, ModuleDeclaration, ModuleDeclarationKind, ModuleFn, TypeExpr, TypeExprKind, WhenArm)
import Data.Dewdrop.Compiler (Compiler(..), ModuleContext(..))
import Data.Dewdrop.IR (TypedIRID)
import Data.Dewdrop.Identifier (Identifier)
import Data.Dewdrop.Types (IRBoundsID)
import Data.Dewdrop.Visitor (class Pass, class Visitable, ignore, visit)
import Data.List (List(..))
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe)
import Data.Tuple (Tuple(..))
import Record (merge)

data LowerIRContextProps = LowerIRContextProps { module_ctx :: ModuleContext }
type IREnv = Map Identifier TypedIRID
data LowerIRContext system_ctx = LowerIRContext
  { compiler :: Compiler system_ctx
  , env_stack :: List IREnv
  , fn_stack :: List (LowerIRContext system_ctx)
  , ir_stack :: List TypedIRID
  , module_ctx :: ModuleContext
  , type_stack :: List IRBoundsID
  }

run :: ∀ (@u :: Type). Pass Module (LowerIRContext u) => Visitable Module (LowerIRContext u) => LowerIRContextProps -> Compiler u -> Maybe (Compiler u)
run (LowerIRContextProps { module_ctx }) compiler = do
  let
    (ModuleContext { ast, id }) = module_ctx
    ctx = LowerIRContext { compiler, env_stack: Nil, ir_stack: Nil, module_ctx, fn_stack: Nil, type_stack: Nil }
  Tuple (LowerIRContext { compiler: (Compiler inner_compiler'), module_ctx: (ModuleContext inner_module_ctx') }) ast' <- visit ast ctx
  let
    module_ctx' = ModuleContext $ merge { ast: ast' } inner_module_ctx'
    compiler' = Compiler $ merge { modules: Map.insert id module_ctx' inner_compiler'.modules } inner_compiler'
  pure compiler'

instance type_ir_lower_module_pass :: Pass Module (LowerIRContext u) where
  enter = ignore
  exit = ignore

instance type_ir_lower_declaration_pass :: Pass ModuleDeclaration (LowerIRContext u) where
  enter = ignore
  exit = ignore

-- Visitable over ctx => over -> ctx -> VisitResult ctx over
instance type_ir_lower_declaration_kind_pass :: Pass ModuleDeclarationKind (LowerIRContext u) where
  enter = ignore
  exit = ignore

instance type_ir_lower_fn_pass :: Pass ModuleFn (LowerIRContext u) where
  enter = ignore
  exit = ignore

instance type_ir_lower_fn_param_pass :: Pass FnParam (LowerIRContext u) where
  enter = ignore
  exit = ignore

instance type_ir_lower_type_expr_pass :: Pass TypeExpr (LowerIRContext u) where
  enter = ignore
  exit = ignore

instance type_ir_lower_type_expr_kind_pass :: Pass TypeExprKind (LowerIRContext u) where
  enter = ignore
  exit = ignore

instance type_ir_lower_expr_pass :: Pass Expr (LowerIRContext u) where
  enter = ignore
  exit = ignore

instance type_ir_lower_expr_kind_pass :: Pass ExprKind (LowerIRContext u) where
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

instance type_ir_lower_when_arm_pass :: Pass WhenArm (LowerIRContext u) where
  enter = ignore
  exit = ignore
