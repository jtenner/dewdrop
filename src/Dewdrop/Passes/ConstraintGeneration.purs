module Dewdrop.Passes.ConstraintGeneration where

import Prelude

import Data.Map (insert)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Dewdrop.Types
import Record (merge)
import Visitor.Pattern (class Pass, class Visitable, continue, ignore, visit)

-- Define the context as a data type with one constructor holding a record
data ConstraintGenerationPassContext = ConstraintGenerationPassContext
  { fn_type_context :: FnTypeContext
  -- Add other necessary fields later, e.g., global type environment
  , compiler :: Compiler -- Keep compiler for now if needed globally
  , module_id :: ModuleID
  }

run :: Pass Module ConstraintGenerationPassContext =>
  Visitable Module ConstraintGenerationPassContext =>
  ModuleID ->
  Module -> 
  Compiler -> 
  Maybe Compiler
run module_id mod compiler = do
  let fn_type_context = fn_type_context_new
  -- Initialize context with a new fn_type_context
  let ctx = ConstraintGenerationPassContext { fn_type_context, compiler: compiler, module_id }
  -- Pattern match on the constructor to get the inner record
  Tuple (ConstraintGenerationPassContext ctxRec') _ <- visit mod ctx
  -- Return the potentially modified compiler from the extracted record
  Just ctxRec'.compiler

instance constrant_generation_module_pass :: Pass Module ConstraintGenerationPassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_declaration_pass :: Pass ModuleDeclaration ConstraintGenerationPassContext where
  enter = ignore
  exit = ignore

-- Implement the pass for ModuleDeclarationKind
instance constraint_generation_declaration_kind_pass :: Pass ModuleDeclarationKind ConstraintGenerationPassContext where
  -- When entering a function declaration, reset the fn_type_context
  enter (FnDeclarationKind _ _ _) (ConstraintGenerationPassContext ctx) = do
    let ctx' = merge { fn_type_context: fn_type_context_new } ctx
    continue (ConstraintGenerationPassContext ctx')

  -- When exiting a function declaration, store the fn_type_context in the global type environment
  exit (FnDeclarationKind _ name _) (ConstraintGenerationPassContext { fn_type_context, compiler, module_id }) = do
    let { program: { fn_types } } = compiler
    let fn_types' = insert (reference module_id name) fn_type_context fn_types
    let program' = merge { fn_types: fn_types' } compiler.program
    let compiler' = merge { program: program' } compiler
    let ctx' = ConstraintGenerationPassContext { fn_type_context, compiler: compiler', module_id }
    continue ctx'

instance constraint_generation_fn_pass :: Pass ModuleFn ConstraintGenerationPassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_fn_param_pass :: Pass FnParam ConstraintGenerationPassContext where
  enter (FnParam name maybe_type_expr _) (ConstraintGenerationPassContext ctx@{ fn_type_context, compiler, module_id }) = do
    let { parameters, type_env, constraints } = fn_type_context

    -- create a type variable and add it to the environment
    let Tuple type_var fn_type_context' = type_var_new fn_type_context Nothing
    let type_env' = insert (NameIdentifier name) type_var type_env
    
    -- Add the parameter to the parameters list
    let parameters' = parameters <> (pure type_var)

    constraints' <- case maybe_type_expr of
      -- add a constraint that the type parameter matches the type expression
      Just type_expr -> do
        type_expr_type <- infer type_expr fn_type_context'
        pure $ constraints <> (pure $ Matches type_var type_expr_type)
      Nothing -> pure constraints

    let fn_type_context'' = merge { parameters: parameters', type_env: type_env', constraints: constraints' } fn_type_context'
    let ctx' = merge { fn_type_context: fn_type_context'', compiler, module_id } ctx 
    continue $ ConstraintGenerationPassContext ctx'



  exit = ignore

instance constraint_generation_type_expr_pass :: Pass TypeExpr ConstraintGenerationPassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_type_expr_kind_pass :: Pass TypeExprKind ConstraintGenerationPassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_expr_pass :: Pass Expr ConstraintGenerationPassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_expr_kind_pass :: Pass ExprKind ConstraintGenerationPassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_when_arm_pass :: Pass WhenArm ConstraintGenerationPassContext where
  enter = ignore
  exit = ignore
