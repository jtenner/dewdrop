module Dewdrop.Passes.ConstraintGeneration where

import Prelude

import Data.List (List(..), (:))
import Data.Map (insert, lookup)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Dewdrop.Types (Compiler, Expr, ExprKind, FnParam(..), FnTypeContext, Identifier(..), Module, ModuleDeclaration, ModuleDeclarationKind(..), ModuleFn, ModuleID, ProgramType, TypeConstraint(..), TypeExpr, TypeExprKind, WhenArm, fn_type_context_new, infer, reference, type_var_new)
import Record (merge)
import Visitor.Pattern (class Pass, class Visitable, VisitResult, continue, ignore, visit)

type ConstraintGenerationProps =
  { fn_type_context :: FnTypeContext
  , module_id :: ModuleID
  , expression_type_stack :: List ProgramType
  }

-- Define the context as a data type with one constructor holding a record
data ConstraintGenerationContext = ConstraintGenerationContext ConstraintGenerationProps Compiler
  

-- | Runs the constraint generation pass on a single module.
run :: Pass Module ConstraintGenerationContext =>
  Visitable Module ConstraintGenerationContext =>
  ConstraintGenerationProps ->
  Compiler ->
  Maybe Compiler
run ctx@{ module_id } compiler@{ modules } = do
  -- Look up the module using module_id from the context record
  module_ctx@{ ast } <- lookup module_id modules
  -- Module found, run the visitor with the initial context
  -- The initial context contains the compiler state passed into it when created
  Tuple (ConstraintGenerationContext _ compiler') ast' <- visit ast (ConstraintGenerationContext ctx compiler)
  -- Update the module in the compiler with the new AST
  let
    module_ctx' = merge { ast: ast' } module_ctx
    modules' = insert module_id module_ctx' modules
    compiler'' = merge { modules: modules' } compiler'
  Just compiler''

instance constrant_generation_module_pass :: Pass Module ConstraintGenerationContext where
  enter = ignore
  exit = ignore

instance constraint_generation_declaration_pass :: Pass ModuleDeclaration ConstraintGenerationContext where
  enter = ignore
  exit = ignore

-- Implement the pass for ModuleDeclarationKind
instance constraint_generation_declaration_kind_pass :: Pass ModuleDeclarationKind ConstraintGenerationContext where
  -- When entering a function declaration, reset the fn_type_context
  enter (FnDeclarationKind _ _ _) (ConstraintGenerationContext ctx compiler) = do
    let ctx' = merge { fn_type_context: fn_type_context_new } ctx
    continue (ConstraintGenerationContext ctx' compiler)

  -- When exiting a function declaration, store the fn_type_context in the global type environment
  exit (FnDeclarationKind _ name _) (ConstraintGenerationContext ctx@{ fn_type_context, module_id } compiler) = do
    let { program: { fn_types } } = compiler
    let fn_types' = insert (reference module_id name) fn_type_context fn_types
    let program' = merge { fn_types: fn_types' } compiler.program
    let compiler' = merge { program: program' } compiler
    let ctx' = merge { fn_type_context, module_id } ctx
    continue (ConstraintGenerationContext ctx' compiler')

instance constraint_generation_fn_pass :: Pass ModuleFn ConstraintGenerationContext where
  enter = ignore
  exit = ignore

instance constraint_generation_fn_param_pass :: Pass FnParam ConstraintGenerationContext where
  enter (FnParam name maybe_type_expr _) (ConstraintGenerationContext ctx@{ fn_type_context, module_id } compiler) = do
    let { parameters, type_env, constraints } = fn_type_context

    -- create a type variable and add it to the environment
    let Tuple type_var fn_type_context' = type_var_new fn_type_context Nothing
    let type_env' = insert (NameIdentifier name) type_var type_env
    
    -- Add the parameter to the parameters list
    let parameters' = parameters <> (pure type_var)

    -- maybe add a constraint that the type parameter matches the type expression
    constraints' <- case maybe_type_expr of
      Just type_expr -> do
        type_expr_type <- infer type_expr fn_type_context'
        pure $ constraints <> (pure $ Matches type_var type_expr_type)
      Nothing -> pure constraints

    -- Update the context with the new fn_type_context
    let fn_type_context'' = merge { parameters: parameters', type_env: type_env', constraints: constraints' } fn_type_context'
    let ctx' = merge { fn_type_context: fn_type_context'', module_id } ctx

    continue $ ConstraintGenerationContext ctx' compiler

  exit = ignore

instance constraint_generation_type_expr_pass :: Pass TypeExpr ConstraintGenerationContext where
  enter = ignore
  exit = ignore

instance constraint_generation_type_expr_kind_pass :: Pass TypeExprKind ConstraintGenerationContext where
  enter = ignore
  exit = ignore

instance constraint_generation_expr_pass :: Pass Expr ConstraintGenerationContext where
  enter _ (ConstraintGenerationContext ctx compiler) = do
    let { fn_type_context, expression_type_stack } = ctx
    let Tuple var fn_type_context' = type_var_new fn_type_context Nothing
    let expression_type_stack' = var : expression_type_stack
    let ctx' = {
      fn_type_context: fn_type_context',
      expression_type_stack: expression_type_stack'
    }
    let ctx'' = merge ctx' ctx
    continue $ ConstraintGenerationContext ctx'' compiler

  exit :: Expr -> ConstraintGenerationContext -> VisitResult ConstraintGenerationContext Expr
  exit _ (ConstraintGenerationContext (ctx@{ expression_type_stack: (_ : expression_type_stack') }) compiler) = do
    let ctx' = merge { expression_type_stack: expression_type_stack' } ctx
    continue $ ConstraintGenerationContext ctx' compiler
  exit _ (ConstraintGenerationContext ({ expression_type_stack: Nil }) _) = Nothing

instance constraint_generation_expr_kind_pass :: Pass ExprKind ConstraintGenerationContext where
  enter = ignore
  exit = ignore

instance constraint_generation_when_arm_pass :: Pass WhenArm ConstraintGenerationContext where
  enter = ignore
  exit = ignore
