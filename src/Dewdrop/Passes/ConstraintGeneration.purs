module Dewdrop.Passes.ConstraintGeneration where

import Prelude

import Data.FingerTree (from_array)
import Data.List (List(..), (:))
import Data.Map (insert, lookup)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Dewdrop.Types (Compiler, Expr, ExprKind(..), FnParam(..), FnTypeContext, Identifier(..), Module, ModuleDeclaration, ModuleDeclarationKind(..), ModuleFn, ModuleID, ProgramType, TypeConstraint(..), TypeExpr, TypeExprKind, WhenArm, builtin_bool_type, builtin_integer_type, builtin_numeric_type, fn_type_context_new, infer, reference, type_var_new)
import Record (merge)
import Visitor.Pattern (class Pass, class Visitable, VisitResult, continue, ignore, visit)

type ConstraintGenerationProps =
  { expression_type_stack :: List ProgramType
  , fn_type_context :: FnTypeContext
  , generated_type_stack :: List ProgramType
  , module_id :: ModuleID
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
  -- When entering a function declaration, reset the fn_type_context to a new one
  enter (FnDeclarationKind _ _ _) (ConstraintGenerationContext ctx compiler) = do
    let ctx' = merge { fn_type_context: fn_type_context_new } ctx
    continue (ConstraintGenerationContext ctx' compiler)

  -- When exiting a function declaration, store the fn_type_context in the global type environment
  exit (FnDeclarationKind _ name _) (ConstraintGenerationContext ctx@{ fn_type_context, module_id } compiler@{ program }) = do
    let
      { fn_types } = program
      
      -- types are stored by "module reference", which specifies the module itself and the name of the function
      fn_types' = insert (reference module_id name) fn_type_context fn_types

      -- package the program/compiler/ctx back up and continue
      program' = merge { fn_types: fn_types' } compiler.program
      compiler' = merge { program: program' } compiler
      ctx' = merge { fn_type_context, module_id } ctx

    continue (ConstraintGenerationContext ctx' compiler')

instance constraint_generation_fn_pass :: Pass ModuleFn ConstraintGenerationContext where
  enter = ignore
  exit = ignore

instance constraint_generation_fn_param_pass :: Pass FnParam ConstraintGenerationContext where
  enter (FnParam name maybe_type_expr _) (ConstraintGenerationContext ctx@{ fn_type_context, module_id } compiler) = do
    let
      { parameters, type_env, constraints } = fn_type_context

      -- create a type variable and add it to the environment
      Tuple type_var fn_type_context' = type_var_new fn_type_context Nothing
      type_env' = insert (NameIdentifier name) type_var type_env
    
    -- Add the parameter to the parameters list
      parameters' = parameters <> (pure type_var)

    -- maybe add a constraint that the type parameter matches the type expression
    constraints' <- case maybe_type_expr of
      Just type_expr -> do
        type_expr_type <- infer type_expr fn_type_context'
        pure $ constraints <> (pure $ Matches type_var type_expr_type)
      Nothing -> pure constraints

    -- Update the context with the new fn_type_context
    let
      fn_type_context'' = merge { parameters: parameters', type_env: type_env', constraints: constraints' } fn_type_context'
      ctx' = merge { fn_type_context: fn_type_context'', module_id } ctx

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
    let
      { fn_type_context, expression_type_stack } = ctx
      -- create a type variable and add it to the environment
      Tuple var fn_type_context' = type_var_new fn_type_context Nothing
      -- add the type variable to the expression type stack to be referenced later
      expression_type_stack' = var : expression_type_stack

      -- update the context
      props = { fn_type_context: fn_type_context', expression_type_stack: expression_type_stack' }
      ctx' = merge props ctx
    
    continue $ ConstraintGenerationContext ctx' compiler

  exit _ (ConstraintGenerationContext (ctx@{ generated_type_stack, expression_type_stack: (var : expression_type_stack') }) compiler) = do
    -- once the expression has been constrained, it may be used later, so any outer expressions can use it
    let
      -- push the type variable onto the generated type stack for later use
      generated_type_stack' = generated_type_stack <> (pure var)
      -- update the context
      ctx' = merge { expression_type_stack: expression_type_stack', generated_type_stack: generated_type_stack' } ctx

    continue $ ConstraintGenerationContext ctx' compiler
  exit _ (ConstraintGenerationContext ({ expression_type_stack: Nil }) _) = Nothing

instance constraint_generation_expr_kind_pass :: Pass ExprKind ConstraintGenerationContext where

  -- IntExpr
  -- integers are always typed as Integer
  enter (IntExpr _) (ConstraintGenerationContext ctx@{ fn_type_context, expression_type_stack: (var : _) } compiler) = do
    let
      { constraints } = fn_type_context
      -- add a constraint that the type variable is an integer
      constraints' = constraints <> (pure $ Equals var builtin_integer_type)
      -- update the context
      fn_type_context' = merge { constraints: constraints' } fn_type_context
      ctx' = merge { fn_type_context: fn_type_context' } ctx

    continue $ ConstraintGenerationContext ctx' compiler
  
  -- NameExpr
  enter (NameExpr name) (ConstraintGenerationContext ctx@{ fn_type_context, expression_type_stack: (_ : expression_type_stack) } compiler) = do
    let { type_env } = fn_type_context
    -- look up the type of the name in the type environment
    maybe_type <- lookup (NameIdentifier name) type_env

    -- replace the type variable at the top of the stack with the type of the name instead
    -- because it's already a type variable anyway
    let
      expression_type_stack' = maybe_type : expression_type_stack
      ctx' = merge { expression_type_stack: expression_type_stack' } ctx

    continue $ ConstraintGenerationContext ctx' compiler

  -- Number Binary Number = Number
  -- AddExpr
  -- SubExpr
  -- MulExpr
  -- DivExpr
  enter (AddExpr _ _) ctx = numeric_binary_expression_kind ctx
  enter (SubExpr _ _) ctx = numeric_binary_expression_kind ctx
  enter (MulExpr _ _) ctx = numeric_binary_expression_kind ctx
  enter (DivExpr _ _) ctx = numeric_binary_expression_kind ctx


  -- Number Binary Number = Boolean
  -- GreaterThanEqualsExpr
  -- GreaterThanExpr
  -- LessThanEqualsExpr
  -- LessThanExpr
  enter (GreaterThanEqualsExpr _ _) ctx = numeric_binary_expression_boolean_kind ctx
  enter (GreaterThanExpr _ _) ctx = numeric_binary_expression_boolean_kind ctx
  enter (LessThanEqualsExpr _ _) ctx = numeric_binary_expression_boolean_kind ctx
  enter (LessThanExpr _ _) ctx = numeric_binary_expression_boolean_kind ctx
  
  -- EqualsExpr
  enter (EqualsExpr _ _) ctx = binary_expression_boolean_kind ctx

  -- BlockExpr
  enter (BlockExpr body) (ConstraintGenerationContext ctx compiler) = do Nothing

  -- WhenExpr
  -- CallExpr
  

  enter _ _ = Nothing
  exit = ignore

instance constraint_generation_when_arm_pass :: Pass WhenArm ConstraintGenerationContext where
  enter = ignore
  exit = ignore

numeric_binary_expression_kind :: ConstraintGenerationContext -> VisitResult ConstraintGenerationContext ExprKind
numeric_binary_expression_kind (ConstraintGenerationContext ctx@{ fn_type_context, expression_type_stack: (var : _), generated_type_stack: (right : left : generated_type_stack) } compiler) = do
  let
    { constraints } = fn_type_context
    left_is_numeric = Matches left builtin_numeric_type
    right_is_numeric = Matches right builtin_numeric_type
    left_matches_right = Matches left right
    var_is_at_least_right = AtLeast var right
    var_is_at_least_left = AtLeast var left

    -- add the constraints
    constraints' = constraints <> from_array [ left_is_numeric, right_is_numeric, var_is_at_least_right, var_is_at_least_left, left_matches_right ]

    -- update the context
    fn_type_context' = merge { constraints: constraints' } fn_type_context
    ctx' = merge { fn_type_context: fn_type_context', generated_type_stack: generated_type_stack } ctx

  continue (ConstraintGenerationContext ctx' compiler)
numeric_binary_expression_kind _ = Nothing

numeric_binary_expression_boolean_kind :: ConstraintGenerationContext -> VisitResult ConstraintGenerationContext ExprKind
numeric_binary_expression_boolean_kind (ConstraintGenerationContext ctx@{ fn_type_context, expression_type_stack: (var : _), generated_type_stack: (right : left : generated_type_stack) } compiler) = do
  let
    { constraints } = fn_type_context
    left_is_numeric = Matches left builtin_numeric_type
    right_is_numeric = Matches right builtin_numeric_type
    left_matches_right = Matches left right
    var_is_boolean = Equals var builtin_bool_type

    -- add the constraints
    constraints' = constraints <> from_array [ left_is_numeric, right_is_numeric, left_matches_right, var_is_boolean ]

    -- update the context
    fn_type_context' = merge { constraints: constraints' } fn_type_context
    ctx' = merge { fn_type_context: fn_type_context', generated_type_stack: generated_type_stack } ctx

  continue $ ConstraintGenerationContext ctx' compiler
numeric_binary_expression_boolean_kind _ = Nothing

binary_expression_boolean_kind :: ConstraintGenerationContext -> VisitResult ConstraintGenerationContext ExprKind
binary_expression_boolean_kind (ConstraintGenerationContext ctx@{ fn_type_context, expression_type_stack: (var : _), generated_type_stack: (right : left : generated_type_stack) } compiler) = do
  let
    { constraints } = fn_type_context
    left_matches_right = Matches left right
    var_is_boolean = Equals var builtin_bool_type

    -- add the constraints
    constraints' = constraints <> from_array [ left_matches_right, var_is_boolean ]

    -- update the context
    fn_type_context' = merge { constraints: constraints' } fn_type_context
    ctx' = merge { fn_type_context: fn_type_context', generated_type_stack: generated_type_stack } ctx

  continue $ ConstraintGenerationContext ctx' compiler
binary_expression_boolean_kind _ = Nothing