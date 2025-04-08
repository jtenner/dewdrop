module Dewdrop.Passes.TypeIRLower where

import Prelude

import Data.FingerTree (snoc)
import Data.List (List(..), (:))
import Data.Map (insert, lookup)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Dewdrop.Types (Bounds(..), Compiler, Expr, ExprKind, FnParam(..), Identifier(..), Module, ModuleContext, ModuleDeclaration, ModuleDeclarationKind, ModuleElementReference(..), ModuleFn(..), ProgramType(..), ProgramTypeKind(..), TypeExpr(..), TypeExprKind(..), TypedIRFnContext, WhenArm, type_var_new, typed_ir_fn_context_new)
import Data.Foldable (find)
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
    -- Each parameter gets a type varaiable
    let
      { env, parameters } = fn_state
      Tuple id fn_state' = type_var_new fn_state

      -- Since state cannot be shared between enter/exit, we push the type variable onto the stack
      type_stack' = (id : type_stack)

      -- Add the type variable to the environment, and push the parameter
      def = Tuple (NameIdentifier name) id
      env' = snoc def env
      parameters' = snoc def parameters

      -- merge the state
      fn_state'' = merge { env: env', parameters: parameters' } fn_state'
      fn_stack' = (fn_state'' : fn_stack)

    continue (TypeIRLowerContext props (merge { fn_stack: fn_stack', type_stack: type_stack' } state) compiler)
  enter _ _ = Nothing

  -- on exit, if there is a type guard, constrain the lower bounds of the parameter to the type guard
  exit (FnParam _ (Just _) _) (TypeIRLowerContext props state@{ fn_stack: (fn_state : fn_stack), type_stack: (type_guard_id : param_id : type_stack) } compiler) = do
    param_bounds <- get_bounds_by_id param_id fn_state

    let
      param_bounds' = constrain (Bounds { upper: mempty, lower: pure (ProgramType (TypeVar type_guard_id) Nothing) }) param_bounds
      fn_state' = set_bounds_by_id param_id param_bounds' fn_state
      fn_stack' = fn_state' : fn_stack
      -- the type stack was popped, so we need to update it too
      state' = merge { fn_stack: fn_stack', type_stack } state

    continue $ TypeIRLowerContext props state' compiler

  -- on exit, pop the type variable from the stack
  exit _ (TypeIRLowerContext props state@{ type_stack: (_ : type_stack) } compiler) = do
    let state' = merge { type_stack: type_stack } state
    continue $ TypeIRLowerContext props state' compiler

  exit _ _ = Nothing

instance type_ir_lower_type_expr_pass :: Pass TypeExpr TypeIRLowerContext where
  -- When visiting a type expression, it needs to be "resolved" and pushed onto the stack
  -- so that it can be used to constrain IRExpressions.
  --
  -- The type expression itself is pushed onto the stack as a type variable, then subsequently
  -- bounded by the "TypeExprKind" visitor. 
  enter (TypeExpr _ _) (TypeIRLowerContext props state@{ fn_stack: (fn_state : fn_stack), type_stack } compiler) = do
    let
      Tuple type_id fn_state' = type_var_new fn_state
      fn_stack' = fn_state' : fn_stack
      type_stack' = type_id : type_stack

    let state' = merge { fn_stack: fn_stack', type_stack: type_stack' } state
    continue $ TypeIRLowerContext props state' compiler
  enter _ _ = Nothing

  exit = ignore

instance type_ir_lower_type_expr_kind_pass :: Pass TypeExprKind TypeIRLowerContext where
  enter = ignore
  exit (NamedTypeExpr name) (TypeIRLowerContext props state@{ fn_stack: (fn_state : fn_stack), type_stack: (type_id : type_stack) } compiler) = do
    
    bounds <- get_bounds_by_name name fn_state
    let
      bounds' = constrain (Bounds { upper: pure (ProgramType (TypeVar type_id) Nothing), lower: mempty }) bounds
    
    fn_state' <- set_bounds_by_name name bounds' fn_state

    let
      fn_stack' = fn_state' : fn_stack
      state' = merge { fn_stack: fn_stack', type_stack } state

    continue $ TypeIRLowerContext props state' compiler
  exit _ _ = Nothing

instance type_ir_lower_expr_pass :: Pass Expr TypeIRLowerContext where
  enter = ignore
  exit = ignore

instance type_ir_lower_expr_kind_pass :: Pass ExprKind TypeIRLowerContext where
  enter = ignore
  exit = ignore

instance type_ir_lower_when_arm_pass :: Pass WhenArm TypeIRLowerContext where
  enter = ignore
  exit = ignore
