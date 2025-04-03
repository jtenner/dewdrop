module Dewdrop.Passes.ConstraintGeneration where

import Prelude

import Data.Array (length)
import Data.Array as Array
import Data.FingerTree (from_array, from_list, index, snoc)
import Data.List (List(..), uncons, (:))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Dewdrop.Types (Compiler, Expr(..), ExprKind(..), FnParam(..), FnTypeContext, Identifier(..), Module, ModuleDeclaration, ModuleDeclarationKind, ModuleFn(..), ProgramType(..), ProgramTypeKind(..), TypeConstraint(..), TypeExpr(..), TypeExprKind(..), WhenArm, builtin_integer_type, builtin_numeric_type, fn_type_context_new, get_ctx_fn_type, get_type_env, set_type_env, type_var_new)
import Record (merge)
import Util (partition_at)
import Visitor.Pattern (class Pass, class Visitable, VisitResult, continue, ignore, skip_all, visit)

data ConstraintGenerationPassContext = Pass (List PassContext) Compiler
type PassContext = { type_context :: FnTypeContext
                   , type_stack :: List ProgramType
                   , parameter_index :: Int
                   }


run ∷ Pass Module ConstraintGenerationPassContext ⇒ Visitable Module ConstraintGenerationPassContext ⇒ Module → Compiler → Maybe Compiler
run mod compiler = do
  let ctx = Pass Nil compiler
  Tuple (Pass _ compiler') _ <- visit mod ctx
  Just compiler'

instance constrant_generation_module_pass :: Pass Module ConstraintGenerationPassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_declaration_pass :: Pass ModuleDeclaration ConstraintGenerationPassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_declaration_kind_pass :: Pass ModuleDeclarationKind ConstraintGenerationPassContext where
  enter = ignore
  exit = ignore

-- When entering a function, create a new type context and push it onto the stack
instance constraint_generation_fn_pass :: Pass ModuleFn ConstraintGenerationPassContext where
  enter (ModuleFn maybe_name params _ _) (Pass stack compiler) = do
    let
      fn_type_ctx = fn_type_context_new (length params)
      -- If the function has a name, add it to the type environment
      fn_type_ctx' = case maybe_name of
        Just name -> set_type_env (NameIdentifier name) (get_ctx_fn_type fn_type_ctx) fn_type_ctx
        Nothing -> fn_type_ctx
      -- The function type can be inferred later by called get_ctx_fn_type, so no need to add it to the stack
      ctx = { type_context: fn_type_ctx'
            , type_stack: Nil
            , parameter_index: 0
            }
      stack' = (ctx : stack)
    continue (Pass stack' compiler)

  -- Notes:
  -- 1. The generated stack of the module's pass context should have exactly one type on it
  -- 2. The return type of the body should match the return type of the function
  -- 3. The module fn cannot pop the context off the stack, because it doesn't know what to do with it's
  --    type information. The parent (FnExpr) or (FnDeclarationKind) must be responsible for popping it
  --    off the stack and adding it to the parent's type environment.
  exit (ModuleFn _ _ Nothing _) (Pass (ctx@{ type_context, type_stack: (body_type  : Nil) } : stack) compiler) = do
    let
      { return_type, constraints } = type_context
      body_type_matches_return_type = Matches body_type return_type
      constraints' = snoc body_type_matches_return_type constraints
      type_context' = merge { constraints: constraints' } type_context
      ctx' = merge { type_stack: Nil, type_context: type_context' } ctx

    continue $ Pass (ctx' : stack) compiler

  -- Same as above, but the return type must also exist
  exit (ModuleFn _ _ (Just _) _) (Pass (ctx@{ type_context, type_stack: (body_type : return_type_guard_type : Nil) } : stack) compiler) = do
    let
      { return_type, constraints } = type_context
      body_type_matches_return_type = Matches return_type return_type_guard_type
      body_type_matches_return_type' = Matches body_type return_type
      constraints' = constraints <> from_array [body_type_matches_return_type, body_type_matches_return_type']
      type_context' = merge { constraints: constraints' } type_context
      ctx' = merge { type_stack: Nil, type_context: type_context' } ctx

    continue $ Pass (ctx' : stack) compiler

  -- If we exit a function and the type stack doesn't match the function signature, it's a compiler error
  exit _ _ = Nothing

-- FnParam instances require special handling because if a parameter has a type guard, we need to resolve the type
-- and add a constraint to the parameter's type.
instance constraint_generation_fn_param_pass :: Pass FnParam ConstraintGenerationPassContext where
  enter = ignore
  
  -- If there is a type guard, we grab it off the generated type stack
  exit (FnParam name (Just _) _)
       (Pass (ctx@{ type_context, parameter_index, type_stack: (type_guard_type : type_stack) } : stack) compiler) = do
    let { parameters, constraints } = type_context

    -- now add a constraint to the parameter's type
    parameter_type_var <- index parameter_index parameters
    let
      parameter_type_var_matches_type_guard = Matches parameter_type_var type_guard_type
      parameter_index' = parameter_index + 1
      constraints' = snoc parameter_type_var_matches_type_guard constraints
      type_context' = set_type_env (NameIdentifier name) type_guard_type $ merge { constraints: constraints' } type_context
      ctx' = merge { parameter_index: parameter_index', type_context: type_context', type_stack } ctx

    continue (Pass (ctx' : stack) compiler)

  -- If there is no type guard, we just add the parameter's type variable to the type environment
  exit (FnParam name _ _) (Pass (ctx@{ parameter_index, type_context } : stack) compiler) = do
    let { parameters } = type_context
    parameter_type_var <- index parameter_index parameters
    let
      parameter_index' = parameter_index + 1
      type_context' = set_type_env (NameIdentifier name) parameter_type_var type_context
    continue (Pass (merge { parameter_index: parameter_index', type_context: type_context' } ctx : stack) compiler)

  exit _ _ = Nothing

-- Currently, entering a TypeExpr is simply resolving the type and pushing it onto the type stack.
-- Because no complicated type expressions exist yet, this is all that is needed.
instance constraint_generation_type_expr_pass :: Pass TypeExpr ConstraintGenerationPassContext where
  enter (TypeExpr (NamedTypeExpr name) _) (Pass (ctx@{ type_context, type_stack } : stack) compiler) = do
    type_expr_type <- get_type_env (TypeIdentifier name) type_context
    let
      type_stack' = type_expr_type : type_stack
      ctx' = merge { type_stack: type_stack' } ctx
    skip_all (Pass (ctx' : stack) compiler)
  enter _ _ = Nothing

  exit = ignore

instance constraint_generation_type_expr_kind_pass :: Pass TypeExprKind ConstraintGenerationPassContext where
  enter = ignore
  exit = ignore

instance constraint_generation_expr_pass :: Pass Expr ConstraintGenerationPassContext where
  -- Similar to TypeExpr, we can simply resolve the type and push it onto the generated type stack
  enter (Expr (NameExpr name) _) (Pass (ctx@{ type_context, type_stack } : stack) compiler) = do
    type_expr_type <- get_type_env (NameIdentifier name) type_context
    let
      type_stack' = type_expr_type : type_stack
      ctx' = merge { type_stack: type_stack' } ctx
    skip_all (Pass (ctx' : stack) compiler)
  
  -- For an IntExpr, we can simply push the Int type onto the generated type stack
  enter (Expr (IntExpr _) _) (Pass (ctx@{ type_stack } : stack) compiler) = do
    let
      type_stack' = builtin_integer_type : type_stack
      ctx' = merge { type_stack: type_stack' } ctx
    skip_all (Pass (ctx' : stack) compiler)

  -- Otherwise, the expression must be traversed and handled. For convenience, each expression has a
  -- generated type var, which is pushed onto the type stack. The accumulation process in the ExprKind
  -- visitor will inspect the type stack and add constraints to the type context.
  enter _ (Pass (ctx@{ type_context, type_stack } : stack) compiler) = do
    let
      -- Create a new type variable for the expression
      Tuple expr_type_var type_context' = type_var_new Nothing type_context
      type_stack' = expr_type_var : type_stack
      ctx' = merge { type_context: type_context', type_stack: type_stack' } ctx
    continue (Pass (ctx' : stack) compiler)
  
  enter _ _ = Nothing

  exit = ignore

instance constraint_generation_expr_kind_pass :: Pass ExprKind ConstraintGenerationPassContext where
  -- Entering an ExprKind is a no-op
  enter = ignore

  -- All of the inner expressions have been visited, so we can pop the generated types off the stack and add constraints.
  -- For all the simple stuff like "NameExpr" and "IntExpr", it's handled above in `Expr` and skipped.

  -- In the case of a binary expression in form (Numeric (op) Numeric) = Numeric, we can defer to
  -- binary_numeric_returns_numeric_expr_kind
  exit (AddExpr _ _) (Pass (ctx : stack) compiler) = binary_numeric_returns_numeric_expr_kind ctx stack compiler
  exit (SubExpr _ _) (Pass (ctx : stack) compiler) = binary_numeric_returns_numeric_expr_kind ctx stack compiler 
  exit (MulExpr _ _) (Pass (ctx : stack) compiler) = binary_numeric_returns_numeric_expr_kind ctx stack compiler 
  exit (DivExpr _ _) (Pass (ctx : stack) compiler) = binary_numeric_returns_numeric_expr_kind ctx stack compiler

  -- EqualsExpr is a binary expression, but the return type is Bool. In this case we defer to
  -- binary_numeric_returns_bool_expr_kind
  exit (EqualsExpr _ _) (Pass (ctx : stack) compiler) = binary_returns_bool_expr_kind ctx stack compiler

  -- GreaterThan, LessThan, GreaterThanEquals, and LessThanEquals are all binary expressions that return a Bool
  -- where the left and right types must be numeric. We defer to binary_numeric_returns_bool_expr_kind  
  exit (GreaterThanExpr _ _) (Pass (ctx : stack) compiler) = binary_numeric_returns_bool_expr_kind ctx stack compiler
  exit (LessThanExpr _ _) (Pass (ctx : stack) compiler) = binary_numeric_returns_bool_expr_kind ctx stack compiler
  exit (GreaterThanEqualsExpr _ _) (Pass (ctx : stack) compiler) = binary_numeric_returns_bool_expr_kind ctx stack compiler
  exit (LessThanEqualsExpr _ _) (Pass (ctx : stack) compiler) = binary_numeric_returns_bool_expr_kind ctx stack compiler

  -- Call expressions have n + 1 types on the stack, where n is the number of parameters. The callee itself is the last type.
  exit (CallExpr _ params) (Pass (ctx@{ type_context, type_stack } : stack) compiler) = do
    -- partition_at gives us all the parameter types in the correct order
    Tuple param_types type_stack' <- partition_at (length params) type_stack
    case type_stack' of
      (callee_type : type_stack''@(expr_type : _)) -> do
        let
          { constraints } = type_context
          -- Rule: The callee type must be a function type, and matches the following fn type
          callee_fn_type = ProgramType (FnType (Array.fromFoldable param_types) expr_type) Nothing
          callee_type_matches_fn_type = Matches callee_type callee_fn_type
          
          -- update the type context
          constraints' = snoc callee_type_matches_fn_type constraints
          type_context' = merge { constraints: constraints' } type_context
          ctx' = merge { type_context: type_context', type_stack: type_stack'' } ctx

        continue $ Pass (ctx' : stack) compiler

      _ -> Nothing

  -- When expressions have n + 1 types on the stack, where n is the number of arms plus 1 for the else expression
  -- if it exists, plus the generated expression type var.
  exit (WhenExpr arms maybe_else) (Pass (ctx@{ type_context, type_stack } : stack) compiler) = do
    let
      arms_length = case maybe_else of
        Just _ -> length arms + 1
        Nothing -> length arms
    Tuple arm_types type_stack' <- partition_at arms_length type_stack
    -- finally, the actual expression type was already generated
    case type_stack' of
      -- We need to keep it on the stack, so checking for the top item suffices
      (expr_type : _) -> do
        let
          { constraints } = type_context
          -- For each arm type, map it to a constraint that matches the expression type
          arm_constraints = map (Matches expr_type) arm_types
          constraints' = constraints <> from_list arm_constraints
          type_context' = merge { constraints: constraints' } type_context
          -- Note that we need to leave the expression type on top of the stack, which is the same as type_stack'
          -- and not type_stack''.
          ctx' = merge { type_context: type_context', type_stack: type_stack' } ctx

        continue $ Pass (ctx' : stack) compiler
      _ -> Nothing
  
  -- Finally, block expressions are wrapped in {}'s, which means a list of expression types exist on the top of the stack.
  exit (BlockExpr body) (Pass (ctx@{ type_context, type_stack } : stack) compiler) = do
    let
      body_length = length body
    -- The last generated type is the return type, and we ignore the rest
    { head: return_type, tail: type_stack' } <- uncons type_stack
    Tuple _ type_stack'' <- partition_at (body_length - 1) type_stack'

    -- finally, the actual expression type was already generated
    case type_stack'' of
      -- We need to keep it on the stack, so checking for the top item suffices
      (expr_type : _) -> do
        let
          { constraints } = type_context
          -- The expression type must match the return type
          body_type_matches_return_type = Matches expr_type return_type
          
          -- update the type context
          constraints' =  snoc body_type_matches_return_type constraints
          type_context' = merge { constraints: constraints' } type_context
          ctx' = merge { type_context: type_context', type_stack: type_stack' } ctx

        continue $ Pass (ctx' : stack) compiler
      _ -> Nothing

  exit _ _ = Nothing

instance constraint_generation_when_arm_pass :: Pass WhenArm ConstraintGenerationPassContext where
  enter = ignore
  exit = ignore

binary_numeric_returns_numeric_expr_kind :: PassContext -> List PassContext -> Compiler -> VisitResult ConstraintGenerationPassContext ExprKind
binary_numeric_returns_numeric_expr_kind ctx@{ type_context, type_stack: (right_type : left_type : expr_type : type_stack) } stack compiler = do
  let
    { constraints } = type_context
    -- Rule: Left type must be numeric
    left_type_matches_numeric = Matches left_type builtin_numeric_type
    -- Rule: Right type must be numeric
    right_type_matches_numeric = Matches right_type builtin_numeric_type
    -- Rule: The left and right type must match
    left_type_matches_right_type = Matches left_type right_type
    -- Rule: The expression type must be "AtLeast" the size of the left and right types
    expr_type_at_least_left_type = AtLeast expr_type left_type
    expr_type_at_least_right_type = AtLeast expr_type right_type

    -- finally, add the constraints to the type context
    constraints' = constraints <> from_array [ left_type_matches_numeric
                                             , right_type_matches_numeric
                                             , left_type_matches_right_type
                                             , expr_type_at_least_left_type
                                             , expr_type_at_least_right_type
                                             ]
    -- and update the type context
    type_context' = merge { constraints: constraints' } type_context
    type_stack' = expr_type : type_stack
    ctx' = merge { type_context: type_context', type_stack: type_stack' } ctx
  continue $ Pass (ctx' : stack) compiler

  -- All other cases are impossible, and a compiler error
binary_numeric_returns_numeric_expr_kind _ _ _ = Nothing

binary_returns_bool_expr_kind :: PassContext -> List PassContext -> Compiler -> VisitResult ConstraintGenerationPassContext ExprKind
binary_returns_bool_expr_kind ctx@{ type_context, type_stack: (right_type : left_type : expr_type : type_stack) } stack compiler = do
  let
    { constraints } = type_context
    -- Rule: Left type must match right type
    left_type_matches_right_type = Matches left_type right_type
    -- Rule: ExprType must equal bool
    expr_type_equals_bool = Equals expr_type builtin_numeric_type

    constraints' = constraints <> from_array [ left_type_matches_right_type, expr_type_equals_bool ]
    type_context' = merge { constraints: constraints' } type_context
    type_stack' = expr_type : type_stack
    ctx' = merge { type_context: type_context', type_stack: type_stack' } ctx
  continue $ Pass (ctx' : stack) compiler

binary_returns_bool_expr_kind _ _ _ = Nothing

binary_numeric_returns_bool_expr_kind :: PassContext -> List PassContext -> Compiler -> VisitResult ConstraintGenerationPassContext ExprKind
binary_numeric_returns_bool_expr_kind ctx@{ type_context, type_stack: (right_type : left_type : expr_type : type_stack) } stack compiler = do
  let
    { constraints } = type_context
    -- Rule: Left type must be numeric
    left_type_matches_numeric = Matches left_type builtin_numeric_type
    -- Rule: Right type must be numeric
    right_type_matches_numeric = Matches right_type builtin_numeric_type
    -- Rule: Left type must match right type
    left_type_matches_right_type = Matches left_type right_type
    -- Rule: ExprType must equal bool
    expr_type_equals_bool = Equals expr_type builtin_numeric_type

    constraints' = constraints <> from_array [ left_type_matches_numeric
                                             , right_type_matches_numeric
                                             , left_type_matches_right_type
                                             , expr_type_equals_bool
                                             ]
    type_context' = merge { constraints: constraints' } type_context
    type_stack' = expr_type : type_stack
    ctx' = merge { type_context: type_context', type_stack: type_stack' } ctx
  continue $ Pass (ctx' : stack) compiler

binary_numeric_returns_bool_expr_kind _ _ _ = Nothing
