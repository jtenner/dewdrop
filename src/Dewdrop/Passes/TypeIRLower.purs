module Dewdrop.Passes.CollectExports where

import Prelude

import Data.FingerTree (snoc)
import Data.List (List(..), (:))
import Data.Map (insert, lookup)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Dewdrop.Types (Bounds(..), Compiler, Expr, ExprKind, FnParam(..), Identifier(..), Module, ModuleContext, ModuleDeclaration, ModuleDeclarationKind, ModuleElementReference(..), ModuleFn(..), ProgramType(..), ProgramTypeKind(..), TypeExpr, TypeExprKind, TypedIRFnContext, WhenArm, type_var_new, typed_ir_fn_context_new)
import Record (merge)
import Visitor.Pattern (class Pass, class Visitable, continue, ignore, visit)

type TypeIRLowerContextProps = { module_ctx :: ModuleContext }
type TypeIRLowerContextState =
  { fn_stack :: List TypedIRFnContext
  , type_stack :: List Int
  }

data TypeIRLowerContext = TypeIRLowerContext TypeIRLowerContextProps TypeIRLowerContextState Compiler

run :: Pass Module TypeIRLowerContext => Visitable Module TypeIRLowerContext => TypeIRLowerContextProps -> Compiler -> Maybe Compiler
run props@{ module_ctx: { module_id } } compiler@{ modules } = case lookup module_id modules of
  Nothing -> Nothing
  Just module_ctx -> do
    let { ast } = module_ctx
    let ctx = TypeIRLowerContext props { fn_stack: Nil, type_stack: Nil } compiler
    Tuple (TypeIRLowerContext _ state' _) ast' <- visit ast ctx

    let compiler' = compiler
    -- do something with state'
    Just compiler'

instance type_ir_lower_module_pass :: Pass Module TypeIRLowerContext where
  enter = ignore
  exit = ignore

instance type_ir_lower_declaration_pass :: Pass ModuleDeclaration TypeIRLowerContext where
  enter = ignore
  exit = ignore

instance type_ir_lower_declaration_kind_pass :: Pass ModuleDeclarationKind TypeIRLowerContext where
  enter = ignore
  exit = ignore

-- Stack<ProgramType>

instance type_ir_lower_fn_pass :: Pass ModuleFn TypeIRLowerContext where

  enter (ModuleFn (Just name) _ _ _) (TypeIRLowerContext props@{ module_ctx } state@{ fn_stack } compiler) = do
    let
      { module_id } = module_ctx
      ref = ModuleElementReference module_id $ NameIdentifier name
      fn_ctx = typed_ir_fn_context_new ref
      fns' = (fn_ctx : fn_stack)
      state' = merge { fn_stack: fns' } state
    continue (TypeIRLowerContext props state' compiler)
  enter _ _ = Nothing

  exit = ignore

instance type_ir_lower_fn_param_pass :: Pass FnParam TypeIRLowerContext where
  enter (FnParam name _ _) (TypeIRLowerContext props state@{ fn_stack: (fn_state : fn_stack), type_stack } compiler) = do
    let
      { env, parameters } = fn_state
      Tuple id fn_state' = type_var_new fn_state
      type_stack' = (id : type_stack)
      def = Tuple (NameIdentifier name) id
      env' = snoc def env
      parameters' = snoc def parameters
      fn_state'' = merge { env: env', parameters: parameters' } fn_state'
      fn_stack' = (fn_state'' : fn_stack)
    continue (TypeIRLowerContext props (merge { fn_stack: fn_stack', type_stack: type_stack' } state) compiler)
  enter _ _ = Nothing

  -- generate a fresh type variable
  exit (FnParam _ (Just _) _) (TypeIRLowerContext props state@{ fn_stack: (fn_state : fn_stack), type_stack: (type_guard_id : param_id : type_stack) } compiler) = do
    let { types } = fn_state
    Bounds param_upper param_lower <- lookup param_id types

    let
      param_lower' = snoc (ProgramType (TypeVar type_guard_id) Nothing) param_lower
      bounds' = Bounds param_upper param_lower'
      types' = insert param_id bounds' types
      fn_state' = merge { types: types' } fn_state
      fn_stack' = fn_state' : fn_stack
      state' = merge { fn_stack: fn_stack' } state
    continue $ TypeIRLowerContext props state' compiler
  exit _ (TypeIRLowerContext props state@{ type_stack: (_ : type_stack) } compiler) = do
    let state' = merge { type_stack: type_stack } state
    continue $ TypeIRLowerContext props state' compiler
  exit _ _ = Nothing

instance type_ir_lower_type_expr_pass :: Pass TypeExpr TypeIRLowerContext where
  enter = ignore
  exit = ignore

instance type_ir_lower_expr_pass :: Pass Expr TypeIRLowerContext where
  enter = ignore
  exit = ignore

instance type_ir_lower_expr_kind_pass :: Pass ExprKind TypeIRLowerContext where
  enter = ignore
  exit = ignore

instance type_ir_lower_when_arm_pass :: Pass WhenArm TypeIRLowerContext where
  enter = ignore
  exit = ignore

instance type_ir_lower_type_expr_kind_pass :: Pass TypeExprKind TypeIRLowerContext where
  enter = ignore
  exit = ignore
