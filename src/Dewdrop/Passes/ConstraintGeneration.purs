module Dewdrop.Passes.ConstraintGeneration where

import Prelude

import Data.Array (length)
import Data.Array as Array
import Data.FingerTree (from_array, from_list, size)
import Data.List (List(..), drop, uncons, (:))
import Data.Map (insert, lookup)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Dewdrop.Types (Compiler, Expr(..), ExprKind(..), FnParam(..), FnTypeContext, Identifier(..), Module, ModuleDeclaration, ModuleDeclarationKind(..), ModuleFn(..), ModuleID, ProgramType(..), ProgramTypeKind(..), TypeConstraint(..), TypeExpr, TypeExprKind, WhenArm, builtin_bool_type, builtin_integer_type, builtin_numeric_type, fn_type_context_new, infer, reference, type_var_new)
import Record (merge)
import Util (partition_at)
import Visitor.Pattern (class Pass, class Visitable, VisitResult, continue, exit, ignore, visit)

type ConstraintGenerationProps =
  { expression_type_stack :: List ProgramType
  , fn_type_context_stack :: List FnTypeContext
  , generated_type_stack :: List ProgramType
  , module_id :: ModuleID
  , parameter_index :: Int
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

-- Each FnDeclarationKind generates a new type context.
instance constraint_generation_declaration_kind_pass :: Pass ModuleDeclarationKind ConstraintGenerationContext where
  -- When entering a function declaration, reset the fn_type_context_stack to an empty one
  enter (FnDeclarationKind _ _ _) (ConstraintGenerationContext ctx compiler) = do
    let ctx' = merge { fn_type_context_stack: Nil } ctx
    continue (ConstraintGenerationContext ctx' compiler)

  -- When exiting a function declaration, store the fn_type_context in the global type environment
  exit (FnDeclarationKind _ name _) (ConstraintGenerationContext ctx@{ fn_type_context_stack: (fn_type_context : Nil), module_id } compiler@{ program }) = do
    let
      { fn_types } = program
      
      -- types are stored by "module reference", which specifies the module itself and the name of the function
      fn_types' = insert (reference module_id name) fn_type_context fn_types

      -- package the program/compiler/ctx back up and continue
      program' = merge { fn_types: fn_types' } compiler.program
      compiler' = merge { program: program' } compiler
      ctx' = merge { fn_type_context_stack: Nil } ctx

    continue (ConstraintGenerationContext ctx' compiler')
  exit _ _ = Nothing

instance constraint_generation_fn_pass :: Pass ModuleFn ConstraintGenerationContext where
  enter (ModuleFn maybe_name args _ _) (ConstraintGenerationContext ctx@{ fn_type_context_stack, generated_type_stack } compiler) = do
    let
      -- create a new fn_type_context
      fn_type_context@{ parameters, return_type, type_env } = fn_type_context_new $ length args
      fn_type = ProgramType (FnType (Array.fromFoldable parameters) return_type) Nothing
      generated_type_stack' = (fn_type : generated_type_stack)
      type_env' = case maybe_name of
        Just name -> insert (NameIdentifier name) fn_type type_env
        Nothing -> type_env
      fn_type_context' = merge { type_env: type_env' } fn_type_context
      -- once the function type is generated, push it onto the generated type stack
      ctx' = merge { fn_type_context_stack: (fn_type_context' : fn_type_context_stack), generated_type_stack: generated_type_stack' } ctx

    continue $ ConstraintGenerationContext ctx' compiler

  -- Once the function has been visited, the stack should look like this:
  -- (body_type : maybe_return_type_expr : generated_type_stack)
  exit (ModuleFn _ _ maybe_return_type_expr _) (ConstraintGenerationContext ctx@{ fn_type_context_stack: (fn_type_context : fn_type_context_stack), generated_type_stack: (body_type : generated_type_stack) } compiler) = do
    let
      -- TODO: Check here 
      { return_type, constraints } = fn_type_context

      -- The return type of the function must match the return type of the body expression
      return_type_matches_body = Matches return_type body_type
      constraints' = constraints <> (pure return_type_matches_body)

    -- If the type guard is present, it must match the return type as well
    Tuple constraints''' generated_type_stack'' <- case maybe_return_type_expr of
      Just _ -> do
        { head: return_type_expr_type, tail: generated_type_stack' } <- uncons generated_type_stack
        let
          return_type_matches_return_type_expr = Matches return_type return_type_expr_type
          constraints'' = constraints' <> (pure return_type_matches_return_type_expr)

        pure $ Tuple constraints'' generated_type_stack'

      Nothing -> pure $ Tuple constraints' generated_type_stack

    let
      generated_fn_type = ProgramType (FnType (Array.fromFoldable fn_type_context.parameters) return_type) Nothing
      generated_type_stack''' = (generated_fn_type : generated_type_stack'')

      -- Update the context
      fn_type_context' = merge { constraints: constraints''' } fn_type_context
      ctx' = merge { fn_type_context_stack: (fn_type_context': fn_type_context_stack), generated_type_stack: generated_type_stack''' } ctx

    continue $ ConstraintGenerationContext ctx' compiler

  exit _ _ = Nothing

-- TODO: Type Expressions generate types onto the generated_type_stack, and need to be consumed. When this happens,
--       the generated type should be added as a constraint to the type context, matching the parameter type.
instance constraint_generation_fn_param_pass :: Pass FnParam ConstraintGenerationContext where
  enter = ignore
  exit = ignore

-- TODO: This is where type expressions are generated and resolved.
instance constraint_generation_type_expr_pass :: Pass TypeExpr ConstraintGenerationContext where
  enter = ignore
  exit = ignore

instance constraint_generation_type_expr_kind_pass :: Pass TypeExprKind ConstraintGenerationContext where
  enter = ignore
  exit = ignore

-- Notes:
-- 1. A type variable is generated for every single expression.
-- 2. This type variable is always added to the expression type stack.
-- 3. Exiting an expression automatically pops this type variable from the expression type stack.
-- 4. This expression is pushed to another stack called the generated type stack. This expression
--    must be consumed by it's parent in the `Pass ExprKind ConstraintGenerationContext` pass.
-- 5. If there are no expressions on the type stack, the visit returns Nothing because something is wrong
instance constraint_generation_expr_pass :: Pass Expr ConstraintGenerationContext where

  -- In the case of a name expression, we don't need to generate a type variable because
  -- it's already generated. All we have to do is look it up in the type environment
  -- and push it to the "generated" type stack.
  enter expr@(Expr (NameExpr name) _) (ConstraintGenerationContext ctx@{ fn_type_context_stack: (fn_type_context : _), generated_type_stack } compiler) = do
    let { type_env } = fn_type_context
    var <- lookup (NameIdentifier name) type_env
    exit expr $ ConstraintGenerationContext (merge { generated_type_stack: var : generated_type_stack } ctx) compiler

  -- Every other expression generates a type variable and adds it to the expression type stack
  -- so that the `ExprKind` pass can reference it.
  enter _ (ConstraintGenerationContext ctx@{ fn_type_context_stack: (fn_type_context : fn_type_context_stack), expression_type_stack } compiler) = do
    let
      -- create a type variable and add it to the environment
      Tuple var fn_type_context' = type_var_new Nothing fn_type_context

      -- add the type variable to the expression type stack to be referenced later and
      -- update the context
      ctx' = merge { fn_type_context_stack: (fn_type_context' : fn_type_context_stack), expression_type_stack: var : expression_type_stack } ctx
    
    continue $ ConstraintGenerationContext ctx' compiler

  enter _ _ = Nothing

  -- Once the expression has been constrained, it may be used later so any outer expressions can use it.
  -- The generated expression is then transferred from the type stack to the generated stack.
  exit _ (ConstraintGenerationContext (ctx@{ generated_type_stack, expression_type_stack: (var : expression_type_stack') }) compiler) = do
    let
      -- push the type variable onto the generated type stack for later use
      generated_type_stack' = generated_type_stack <> (pure var)
      -- update the context
      ctx' = merge { expression_type_stack: expression_type_stack', generated_type_stack: generated_type_stack' } ctx

    continue $ ConstraintGenerationContext ctx' compiler
  
  -- In the case where the expression type stack is empty, there's something wrong with the compiler pass.
  exit _ (ConstraintGenerationContext ({ expression_type_stack: Nil }) _) = Nothing

-- Notes:
--
-- 1. After the expression itself has been visited, the type variable at the top of the stack must
--    be constrained based on the rules of the Dewdrop language for the current expression
-- 2. The type variables generated by the sub-expressions were generated onto the "generated" type stack
--    in reverse order, e.g. First in last out
-- 3. The `exit` event for the parent expression is responsible for consuming the type variables
--    generated by the sub-expressions.
instance constraint_generation_expr_kind_pass :: Pass ExprKind ConstraintGenerationContext where
  enter = ignore

  -- IntExpr
  -- integers are always typed as Integer
  exit (IntExpr _) (ConstraintGenerationContext ctx@{ fn_type_context_stack: (fn_type_context : fn_type_context_stack), expression_type_stack: (var : _) } compiler) = do
    let
      { constraints } = fn_type_context
      -- add a constraint that the type variable is an integer
      constraints' = constraints <> (pure $ Equals var builtin_integer_type)
      -- update the context
      fn_type_context' = merge { constraints: constraints' } fn_type_context
      ctx' = merge { fn_type_context_stack: (fn_type_context' : fn_type_context_stack) } ctx

    continue $ ConstraintGenerationContext ctx' compiler
  
  -- NameExpr
  -- The `NameExpr` branch of this pass is handled by the `Expr` pass because it's best to
  -- short circut the visit. This is because a type variable is already generated for the
  -- name expression.
  exit (NameExpr _) _ = Nothing

  -- AddExpr
  -- SubExpr
  -- MulExpr
  -- DivExpr
  -- Number Binary Number = Number
  --
  -- All of these branches are effectively the same thing. It does the following things
  -- which are implemented by the `numeric_binary_expression_kind` function.
  --
  -- 1. The left and right expressions must be numeric
  -- 2. The left and right expressions must match each other
  -- 3. The return type must be at least as large as the left and right expressions
  exit (AddExpr _ _) ctx = numeric_binary_expression_kind ctx
  exit (SubExpr _ _) ctx = numeric_binary_expression_kind ctx
  exit (MulExpr _ _) ctx = numeric_binary_expression_kind ctx
  exit (DivExpr _ _) ctx = numeric_binary_expression_kind ctx


  -- GreaterThanEqualsExpr
  -- GreaterThanExpr
  -- LessThanEqualsExpr
  -- LessThanExpr
  -- Number Binary Number = Boolean
  --
  -- All of these branches are effectively the same thing. It does the following things
  -- which are implemented by the `numeric_binary_expression_boolean_kind` function.
  --
  -- 1. The left and right expressions must be numeric
  -- 2. The left and right expressions must match each other
  -- 3. The return type must be a boolean
  exit (GreaterThanEqualsExpr _ _) ctx = numeric_binary_expression_boolean_kind ctx
  exit (GreaterThanExpr _ _) ctx = numeric_binary_expression_boolean_kind ctx
  exit (LessThanEqualsExpr _ _) ctx = numeric_binary_expression_boolean_kind ctx
  exit (LessThanExpr _ _) ctx = numeric_binary_expression_boolean_kind ctx
  
  -- EqualsExpr
  -- Left Binary Right = Boolean
  --
  -- All of these branches are effectively the same thing. It does the following things
  -- which are implemented by the `binary_expression_boolean_kind` function.
  --
  -- 1. The left and right expressions must match each other
  -- 2. The return type must be a boolean
  exit (EqualsExpr _ _) ctx = binary_expression_boolean_kind ctx

  -- BlockExpr
  --
  -- Expressions in a block are evaluated in order, so the return type of the block is
  -- the return type of the last generated expression. This branch needs to do the following things:
  --
  -- 1. It must pop the return type off of the generated type stack
  -- 2. It must pop the rest of the generated types off of the generated type stack (length body) - 1
  -- 3. It must generate a constraint that the return type of the block matches the return type of the
  --    body
  --
  -- Notes:
  --
  -- The generated type stack, being in reverse order, has the last generated expression on top. The
  -- (return_type : generated_type_stack) match expression is used here to pattern match the return type
  -- off of the generated type stack, and effectively pop it implicitly, and this only works because
  -- the default return type of the `exit` implementation for `ExprKind` is `Nothing`.
  --
  -- The rest of the body expressions should be popped off of the generated type stack, and fail otherwise.
  exit (BlockExpr body) (ConstraintGenerationContext
    ctx@{ generated_type_stack: (return_type : generated_type_stack), expression_type_stack: (var : _), fn_type_context_stack: (fn_type_context : fn_type_context_stack) } compiler
    ) = do
    let
      -- The last generated expression is on the top of the generated type stack followed by the rest of
      -- the generated types 
      expression_count = length body
      -- ignore the rest (return_type was already removed)
      generated_type_stack' = drop (expression_count - 1) generated_type_stack
      -- generate a constraint that the return type of the block is the return type of the last expression
      var_matches_return_type = Matches var return_type
      
      -- update the context
      constraints = fn_type_context.constraints <> (pure var_matches_return_type)
      fn_type_context' = merge { constraints } fn_type_context
      ctx' = merge { fn_type_context_stack: (fn_type_context' : fn_type_context_stack), generated_type_stack: generated_type_stack' } ctx

    continue $ ConstraintGenerationContext ctx' compiler

  -- WhenExpr
  -- WhenExprs generate a type variable for the return type of each arm.
  exit (WhenExpr arms maybe_else) (ConstraintGenerationContext ctx@{ fn_type_context_stack: (fn_type_context : fn_type_context_stack), expression_type_stack: (var : _), generated_type_stack } compiler) = do
    let
      { constraints } = fn_type_context
      -- each expression on top of the generated types stack must match the type variable on
      -- top of the expression type stack
      count = case maybe_else of
        Just _ -> length arms + 1
        Nothing -> length arms

    -- Split the generated type stack into the arm expression types and the rest of the generated type stack.
    -- This split also includes the `else` arm if it exists.
    Tuple arm_expression_types generated_type_stack' <- partition_at count generated_type_stack

    let
      -- Every arm must match the return type.
      matches_var = Matches var
      constraints' = constraints <> (from_list $ map matches_var arm_expression_types)

      -- Update the context.
      fn_type_context' = merge { constraints: constraints' } fn_type_context
      ctx' = merge { fn_type_context_stack: (fn_type_context' : fn_type_context_stack), generated_type_stack: generated_type_stack' } ctx

    continue $ ConstraintGenerationContext ctx' compiler

  -- CallExpr
  --
  -- Call expressions generate a type variable for the return type of the function call.
  -- Each parameter type should exist on the top of the generated type stack in reverse order,
  -- followed by the function type itself.
  exit (CallExpr _ args) (ConstraintGenerationContext ctx@{ fn_type_context_stack: (fn_type_context : fn_type_context_stack), expression_type_stack: (var : _), generated_type_stack } compiler) = do
    let arg_count = length args
    -- Because the generated type stack is in reverse order, the arguments are on top of the stack backwards.
    -- The `partition_at` function splits the generated type stack into the argument types and the rest of the
    -- generated type stack, but returns the items off the top in reverse order, which means that the argument
    -- types are in the correct order already.
    Tuple arg_types generated_type_stack' <- partition_at arg_count generated_type_stack
    
    -- The function type is the last item on the generated type stack
    { head: fn_type, tail: generated_type_stack'' } <- uncons generated_type_stack'

    
    let
      arg_types' = Array.fromFoldable arg_types
      -- The function type must match a generated function type where the return type "var" matches the return
      -- type of the function call, and the parameter types match the argument types.
      expected_fn_type = ProgramType (FnType arg_types' var) Nothing
      matches_expected_fn_type = Matches fn_type expected_fn_type

      -- Update the type context
      { constraints } = fn_type_context
      constraints' = constraints <> (pure matches_expected_fn_type)
      fn_type_context' = merge { constraints: constraints' } fn_type_context
      
      -- Update the context
      ctx' = merge { fn_type_context_stack: (fn_type_context' : fn_type_context_stack), generated_type_stack: generated_type_stack'' } ctx

    continue $ ConstraintGenerationContext ctx' compiler

  exit _ _ = Nothing

-- WhenArm
--
-- When WhenArms are visited, they use the same assumptions of the `ExprKind` pass.
--
-- 1. The two expressions in each arm are a Boolean expression and a Value expression.
-- 2. They are on the generated type stack in reverse order, shaped like this (Value : Boolean : generated_type_stack)
-- 3. The Boolean condition must be a bool type
-- 4. The Value expression cannot be constrained in this position, and is passed back up to the parent expression
--    by being pushed back onto the generated type stack.
instance constraint_generation_when_arm_pass :: Pass WhenArm ConstraintGenerationContext where
  enter = ignore

  -- All the magic has to happen on exit because the expression types need to be generated first
  exit _ (ConstraintGenerationContext ctx@{ fn_type_context_stack: (fn_type_context : fn_type_context_stack), generated_type_stack: (value : condition : generated_type_stack) } compiler) = do
    let
      { constraints } = fn_type_context
      
      -- The condition must be a boolean
      condition_is_bool = Equals condition builtin_bool_type
      
      -- Update the type context
      constraints' = constraints <> (pure condition_is_bool)
      fn_type_context' = merge { constraints: constraints' } fn_type_context
      
      -- Update the context
      ctx' = merge { fn_type_context_stack: (fn_type_context': fn_type_context_stack), generated_type_stack: value : generated_type_stack } ctx

    continue $ ConstraintGenerationContext ctx' compiler

  -- If the generated type stack doesn't have two items on it, something is wrong
  exit _ _ = Nothing
  

numeric_binary_expression_kind :: ConstraintGenerationContext -> VisitResult ConstraintGenerationContext ExprKind
numeric_binary_expression_kind (ConstraintGenerationContext ctx@{ fn_type_context_stack: (fn_type_context : fn_type_context_stack), expression_type_stack: (var : _), generated_type_stack: (right : left : generated_type_stack) } compiler) = do
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
    ctx' = merge { fn_type_context_stack: (fn_type_context': fn_type_context_stack), generated_type_stack: generated_type_stack } ctx

  continue $ ConstraintGenerationContext ctx' compiler

numeric_binary_expression_kind _ = Nothing

numeric_binary_expression_boolean_kind :: ConstraintGenerationContext -> VisitResult ConstraintGenerationContext ExprKind
numeric_binary_expression_boolean_kind (ConstraintGenerationContext ctx@{ fn_type_context_stack: (fn_type_context : fn_type_context_stack), expression_type_stack: (var : _), generated_type_stack: (right : left : generated_type_stack) } compiler) = do
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
    ctx' = merge { fn_type_context_stack: (fn_type_context': fn_type_context_stack), generated_type_stack: generated_type_stack } ctx

  continue $ ConstraintGenerationContext ctx' compiler
numeric_binary_expression_boolean_kind _ = Nothing

binary_expression_boolean_kind :: ConstraintGenerationContext -> VisitResult ConstraintGenerationContext ExprKind
binary_expression_boolean_kind (ConstraintGenerationContext ctx@{ fn_type_context_stack: (fn_type_context : fn_type_context_stack), expression_type_stack: (var : _), generated_type_stack: (right : left : generated_type_stack) } compiler) = do
  let
    { constraints } = fn_type_context
    left_matches_right = Matches left right
    var_is_boolean = Equals var builtin_bool_type

    -- add the constraints
    constraints' = constraints <> from_array [ left_matches_right, var_is_boolean ]

    -- update the context
    fn_type_context' = merge { constraints: constraints' } fn_type_context
    ctx' = merge { fn_type_context_stack: (fn_type_context' : fn_type_context_stack), generated_type_stack: generated_type_stack } ctx

  continue $ ConstraintGenerationContext ctx' compiler

binary_expression_boolean_kind _ = Nothing
