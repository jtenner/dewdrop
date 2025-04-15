module Dewdrop.Passes.TypeIRLower where

import Data.Dewdrop.AST
import Data.Dewdrop.Compiler
import Data.Dewdrop.Identifier
import Data.Dewdrop.Types
import Data.Dewdrop.Visitor
import Prelude

import Data.FingerTree (from_array, snoc)
import Data.List (List(..), find, (:))
import Data.Map (Map, lookup)
import Data.Maybe (Maybe(..))
import Data.Pool (pool_set)
import Data.Tuple (Tuple(..))
import Dewdrop.IR (ir_fn_context_new)
import Record (merge)

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

run ::  ∀ (@u :: Type). Pass Module (IRContext u) => Visitable Module (IRContext u) => IRContextProps -> Compiler u -> Maybe (Compiler u)
run props@{ module_ctx: ModuleContext { module_id } } compiler@(Compiler { modules }) = case lookup module_id modules of
  Nothing -> Nothing
  Just resource_id -> do
    module_ctx <- lookup module_id modules
    let ctx = IRContext { compiler, env_stack: Nil, ir_stack: Nil, module_ctx, fn_stack: Nil, type_stack: Nil }
    Tuple (IRContext { compiler: compiler' }) ast' <- visit ast ctx
    -- do something with state'
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

-- The type var is on the top of the stack
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
