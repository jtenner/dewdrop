module Parser
  ( (++->)
  , (+=)
  , (+|)
  , (<-++)
  , Expr(..)
  , ExprKind(..)
  , FnParam(..)
  , Identifier(..)
  , Module(..)
  , ModuleDeclaration(..)
  , ModuleDeclarationKind(..)
  , ModuleFn(..)
  , Parser
  , ParserResult
  , TypeExpr(..)
  , TypeExprKind(..)
  , WhenArm(..)
  , parse_take_left
  , parse_take_right
  , parse_map
  , parse_otherwise
  , parse_expr
  , parse
  )
  where

import Prelude

import Data.Array (length, snoc, (!!))
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Data.Tuple (Tuple(..))
import Lexer (Token(..), TokenKind(..), is_token_kind_colon, is_token_kind_comma, is_token_kind_fn_keyword, is_token_kind_l_paren, is_token_kind_name_identifier, is_token_kind_r_arrow, is_token_kind_r_brace, is_token_kind_r_paren, is_token_kind_type_identifier, tokenize)
import RPN (Operator, RPN, is_nested, binary, end_group, finalize, group, right_unary, rpn, (++), (+.))

-- pub fn fib(n) {
--   when n == 0 -> 0
--     n == 1 -> 1
--     else -> fib(n - 1) + fib(n - 2)
-- }

-- grouping_precedence :: Int
-- grouping_precedence = 18

-- Ops: "." "()"
-- access_and_call_precedence :: Int
-- access_and_call_precedence = 17

-- new_precedence = 16

-- postfix_precedence = 15

-- Ops: "~" "!" "-"
-- prefix_precedence = 14

-- Ops: "**"
-- exponentiation_precedence = 13

-- Ops: "*" "/" "%"
multiplicative_precedence :: Int
multiplicative_precedence = 12

-- Ops: "+" "-"
additive_precedence :: Int
additive_precedence = 11

-- Ops: "<<" ">>"
-- shift_precedence = 10

-- Ops: "<" "<=" ">" ">="
relational_precedence :: Int
relational_precedence = 9

-- Ops: "==" "!="
equality_precedence :: Int
equality_precedence = 8

-- Ops: "&"
-- and_precedence = 7

-- Ops: "^"
-- xor_precedence = 6

-- Ops: "|"
-- or_precedence = 5

-- Ops: "&&"
-- logical_and_precedence = 4

-- Ops: "||" "??"
-- logical_or_precedence = 3

-- Ops: "is"
-- is_precedence = 2

data Identifier = NameIdentifier String
                | TypeIdentifier String

instance eq_identifier :: Eq Identifier where
  eq (NameIdentifier name) (NameIdentifier name') = name == name'
  eq (TypeIdentifier type_name) (TypeIdentifier type_name') = type_name == type_name'
  eq _ _ = false

instance ord_identifier :: Ord Identifier where
  compare (NameIdentifier name) (NameIdentifier name') = compare name name'
  compare (TypeIdentifier type_name) (TypeIdentifier type_name') = compare type_name type_name'
  compare (NameIdentifier _) _ = GT
  compare _ (NameIdentifier _) = LT

data Module = Module (Array ModuleDeclaration)

data ModuleDeclaration = ModuleDeclaration ModuleDeclarationKind Int

data ModuleDeclarationKind = FnDeclarationKind Boolean Identifier ModuleFn

data ModuleFn = ModuleFn (Maybe String) (Array FnParam) (Maybe TypeExpr) Expr

data FnParam = FnParam String (Maybe TypeExpr) Int

data TypeExpr = TypeExpr TypeExprKind Int

data TypeExprKind = NamedTypeExpr String

data Expr = Expr ExprKind Int

data ExprKind = WhenExpr (Array WhenArm) (Maybe Expr)
              | BlockExpr (Array Expr)
              | EqualsExpr Expr Expr
              | IntExpr Int
              | NameExpr String
              | CallExpr Expr (Array Expr)
              | AddExpr Expr Expr
              | SubExpr Expr Expr
              | MulExpr Expr Expr
              | DivExpr Expr Expr
              | GreaterThanExpr Expr Expr
              | LessThanExpr Expr Expr
              | GreaterThanEqualsExpr Expr Expr
              | LessThanEqualsExpr Expr Expr

data WhenArm = WhenArm Expr Expr

type ParserResult t = Maybe (Tuple t Int)

-- helpers
type Parser t = Array Token -> Int -> ParserResult t

parse_many_seperated :: ∀ t u. Parser t -> Parser u -> Parser (Array t)
parse_many_seperated parser seperator = \tokens index -> do_parse_many_seperated parser seperator tokens index []

do_parse_many_seperated :: ∀ t u. Parser t -> Parser u -> (Array Token) -> Int -> (Array t) -> ParserResult (Array t)
do_parse_many_seperated parser seperator tokens index acc = case parser tokens index of
  Nothing | length acc == 0 -> Nothing
          | otherwise -> Just (Tuple acc index)
  Just (Tuple t next_index) -> case seperator tokens next_index of
    Nothing -> Just (Tuple (snoc acc t) next_index)
    Just (Tuple _ next_index_2) -> do_parse_many_seperated parser seperator tokens next_index_2 (snoc acc t)
    

parse_many :: ∀ t. Parser t -> Parser (Array t)
parse_many parser = \chars index -> do_parse_many parser chars index []

do_parse_many :: ∀ t. Parser t -> (Array Token) -> Int -> (Array t) -> ParserResult (Array t)
do_parse_many parser tokens index acc = case parser tokens index of
  Nothing | length acc == 0 -> Nothing
          | otherwise -> Just (Tuple acc index)
  Just (Tuple t next_index) -> do_parse_many parser tokens next_index (snoc acc t)

parse_optional :: ∀ t. Parser t -> Parser (Maybe t)
parse_optional parser = \chars index -> case parser chars index of
  Nothing -> Just (Tuple Nothing index)
  Just (Tuple t next_index) -> Just (Tuple (Just t) next_index)

infixl 4 parse_otherwise as +|
parse_otherwise :: ∀ t. Parser t -> Parser t -> Parser t
parse_otherwise p1 p2 tokens index = case p1 tokens index of
  Nothing -> p2 tokens index
  result -> result

infixr 3 parse_map as +=
parse_map :: ∀ t u. Parser t -> (t -> u) -> Parser u
parse_map parser mapper = \tokens index -> case parser tokens index of
  Just (Tuple t next_index) -> Just (Tuple (mapper t) next_index)
  Nothing -> Nothing

infixl 4 parse_take_left as <-++
parse_take_left :: ∀ t u. Parser t -> Parser u -> Parser t
parse_take_left p1 p2 tokens index = do
  Tuple t next_index <- p1 tokens index
  Tuple _ next_index_2 <- p2 tokens next_index
  Just (Tuple t next_index_2)

infixl 4 parse_take_right as ++->
parse_take_right :: ∀ t u. Parser t -> Parser u -> Parser u
parse_take_right p1 p2 tokens index = do
  Tuple _ next_index <- p1 tokens index
  p2 tokens next_index

expect :: (TokenKind -> Boolean) -> Parser Token
expect p = \tokens index -> case (tokens !! index) of
  Just (Token kind pos) | p kind -> Just (Tuple (Token kind pos) (index + 1))
  _ -> Nothing

-- parsers
parse :: String -> Maybe Module
parse module_text = do
  Tuple mod _ <- parse_module (tokenize module_text true) 0
  Just mod

parse_module :: (Array Token) -> Int -> ParserResult Module
parse_module tokens index = do
  Tuple declarations next_index <- parse_many parse_declaration tokens index
  let _ = tokens !! next_index
  case tokens !! next_index of
    Just (Token TokenKindEOF _) -> Just (Tuple (Module declarations) next_index)
    _ -> Nothing

parse_declaration :: (Array Token) -> Int -> ParserResult ModuleDeclaration
parse_declaration tokens index = case (tokens !! index) of
  Just (Token TokenKindPubKeyword pos) -> do_parse_pub_declaration pos tokens (index + 1)
  Just (Token _ pos) -> do_parse_declaration pos tokens index
  Nothing -> Nothing

do_parse_declaration :: Int -> (Array Token) -> Int -> ParserResult ModuleDeclaration
-- Imports
-- Consts
-- Fns
-- Types
do_parse_declaration _ _ _ = Nothing

do_parse_pub_declaration :: Int -> (Array Token) -> Int -> ParserResult ModuleDeclaration
-- Consts
-- Fns
-- (do_parse_const_declaration +| do_parse_type_declaration +| do_parse_fn_declaration)

do_parse_pub_declaration pos tokens index = do
  -- TODO: Implement the following: -- Tuple fn next_index <- (do_parse_fn +| do_parse_type_declaration +| do_parse_fn_declaration) tokens index
  Tuple fn next_index <- do_parse_fn tokens index
  case fn of
    ModuleFn (Just name) args return_type body -> Just (Tuple (ModuleDeclaration (FnDeclarationKind true (NameIdentifier name) (ModuleFn (Just name) args return_type body)) pos) next_index)
    _ -> Nothing

do_parse_fn :: (Array Token) -> Int -> ParserResult ModuleFn
do_parse_fn tokens index = do
  Tuple _ next_index <- (expect is_token_kind_fn_keyword) tokens index
  Tuple maybe_name next_index_2 <- parse_optional expect_name_identifier tokens next_index
  Tuple _ next_index_3 <- expect is_token_kind_l_paren tokens next_index_2
  Tuple args next_index_4 <- parse_optional (parse_many_seperated parse_fn_param (expect is_token_kind_comma)) tokens next_index_3
  Tuple _ next_index_5 <- expect is_token_kind_r_paren tokens next_index_4
  Tuple return_type next_index_6 <- parse_optional ((expect is_token_kind_r_arrow) ++-> parse_type_expr) tokens next_index_5
  Tuple expr next_index_7 <- parse_expr tokens next_index_6
  let _ = expr
  let args' = fromMaybe [] args
  let name = maybe Nothing (\(Tuple fn_name _) -> Just fn_name) maybe_name

  Just (Tuple (ModuleFn name args' return_type expr) next_index_7)

expect_name_identifier :: Parser (Tuple String Int)
expect_name_identifier tokens index = case expect is_token_kind_name_identifier tokens index of
  Just (Tuple (Token (TokenKindNameIdentifier name) pos) next_index) -> Just (Tuple (Tuple name pos) next_index)
  _ -> Nothing

expect_type_identifier :: Parser (Tuple String Int)
expect_type_identifier tokens index = case expect is_token_kind_type_identifier tokens index of
  Just (Tuple (Token (TokenKindTypeIdentifier name) pos) next_index) -> Just (Tuple (Tuple name pos) next_index)
  _ -> Nothing

expect_colon :: Parser Token
expect_colon tokens index = expect is_token_kind_colon tokens index

parse_fn_param :: Parser FnParam
parse_fn_param tokens index = do
  Tuple (Tuple name name_pos) next_index <- expect_name_identifier tokens index
  Tuple type_expr next_index_2 <- parse_optional (expect_colon ++-> parse_type_expr) tokens next_index
  Just (Tuple (FnParam name type_expr name_pos) next_index_2)

parse_type_expr :: Parser TypeExpr
parse_type_expr tokens index = do
  Tuple (Tuple name pos) next_index <- expect_type_identifier tokens index
  Just (Tuple (TypeExpr (NamedTypeExpr name) pos) next_index) 
  
parse_expr :: Parser Expr
parse_expr tokens index = do
  Tuple rpn' next_index <- do_parse_expression_unary rpn tokens index
  expr <- finalize rpn'
  Just (Tuple expr next_index)

-- All the different operators in the example for now
do_parse_expression_unary :: RPN Expr -> Parser (RPN Expr)
do_parse_expression_unary rpn' tokens index = case tokens !! index of
  Just (Token (TokenKindInt val) pos) -> do_parse_expression_binary (rpn' ++ Expr (IntExpr val) pos) tokens (index + 1)
  Just (Token (TokenKindNameIdentifier name) pos) -> 
    do_parse_expression_binary (rpn' ++ Expr (NameExpr name) pos) tokens (index + 1)

  -- LParen in unary position is a group
  Just (Token TokenKindLParen _) -> do
    rpn'' <- rpn' +. group
    do_parse_expression_unary rpn'' tokens (index + 1)

  Just (Token TokenKindWhenKeyword pos) -> do
    Tuple arms index' <- (parse_many parse_arm) tokens (index + 1)

    _ <- tokens !! index'
    -- TODO: Investigate why the else arm is failing

    case (tokens !! index') of
      Just (Token TokenKindElseKeyword _) -> do
        let index'' = index' + 1
        Tuple else_expr index''' <- parse_expr tokens index''
        Just $ Tuple (rpn' ++ Expr (WhenExpr arms (Just else_expr)) pos) index'''
      _ -> Just $ Tuple (rpn' ++ (Expr (WhenExpr arms Nothing) pos)) index'

  Just (Token TokenKindLBrace pos) -> do
    Tuple exprs index' <- (parse_many parse_expr) tokens (index + 1)
    _ <- tokens !! index'
    Tuple _ index'' <- expect is_token_kind_r_brace tokens index'
    let rpn'' = rpn' ++ Expr (BlockExpr exprs) pos
    do_parse_expression_binary rpn'' tokens index''
  _ -> Nothing

parse_arm :: Parser WhenArm
parse_arm tokens index = do
  Tuple cond_expr index' <- parse_expr tokens index
  Tuple _ index'' <- expect is_token_kind_r_arrow tokens index'
  Tuple expr index''' <- parse_expr tokens index''
  Just $ Tuple (WhenArm cond_expr expr) index'''

add_op :: Int -> Operator Expr
add_op pos = binary "+" additive_precedence false \x y -> Expr (AddExpr x y) pos

sub_op :: Int -> Operator Expr
sub_op pos = binary "-" additive_precedence false \x y -> Expr (SubExpr x y) pos

mul_op :: Int -> Operator Expr
mul_op pos = binary "*" multiplicative_precedence false \x y -> Expr (MulExpr x y) pos

div_op :: Int -> Operator Expr
div_op pos = binary "/" multiplicative_precedence false \x y -> Expr (DivExpr x y) pos

equals_op :: Int -> Operator Expr
equals_op pos = binary "==" equality_precedence false \x y -> Expr (EqualsExpr x y) pos

call_op :: Int -> Array Expr -> Operator Expr
call_op pos args = right_unary "call" \x -> Expr (CallExpr x args) pos

greater_than_op :: Int -> Operator Expr
greater_than_op pos = binary ">" relational_precedence false \x y -> Expr (GreaterThanExpr x y) pos

greater_than_equals_op :: Int -> Operator Expr
greater_than_equals_op pos = binary ">=" relational_precedence false \x y -> Expr (GreaterThanEqualsExpr x y) pos

less_than_op :: Int -> Operator Expr
less_than_op pos = binary "<" relational_precedence false \x y -> Expr (LessThanExpr x y) pos

less_than_equals_op :: Int -> Operator Expr
less_than_equals_op pos = binary "<=" relational_precedence false \x y -> Expr (LessThanEqualsExpr x y) pos

-- find the next binary operator
do_parse_expression_binary :: RPN Expr -> Parser (RPN Expr)
do_parse_expression_binary rpn' tokens index = case tokens !! index of
  Just (Token TokenKindPlus pos) -> do
    rpn'' <- rpn' +. (add_op pos)
    do_parse_expression_unary rpn'' tokens (index + 1)
  Just (Token TokenKindMinus pos) -> do
    rpn'' <- rpn' +. (sub_op pos)
    do_parse_expression_unary rpn'' tokens (index + 1)
  Just (Token TokenKindAsterisk pos) -> do
    rpn'' <- rpn' +. (mul_op pos)
    do_parse_expression_unary rpn'' tokens (index + 1)
  Just (Token TokenKindFSlash pos) -> do
    rpn'' <- rpn' +. (div_op pos)
    do_parse_expression_unary rpn'' tokens (index + 1)
  Just (Token TokenKindEqualsEquals pos) -> do
    rpn'' <- rpn' +. (equals_op pos)
    do_parse_expression_unary rpn'' tokens (index + 1)
  Just (Token TokenKindGreaterThan pos) -> do
    rpn'' <- rpn' +. (greater_than_op pos)
    do_parse_expression_unary rpn'' tokens (index + 1)
  Just (Token TokenKindGreaterThanOrEqual pos) -> do
    rpn'' <- rpn' +. (greater_than_equals_op pos)
    do_parse_expression_unary rpn'' tokens (index + 1)
  Just (Token TokenKindLessThan pos) -> do
    rpn'' <- rpn' +. (less_than_op pos)
    do_parse_expression_unary rpn'' tokens (index + 1)
  Just (Token TokenKindLessThanOrEqual pos) -> do
    rpn'' <- rpn' +. (less_than_equals_op pos)
    do_parse_expression_unary rpn'' tokens (index + 1)

  -- LParen in binary position is actually a function call
  Just (Token TokenKindLParen pos) -> do
    let _ = tokens !! (index + 1)
    Tuple exprs next_index <- parse_many parse_expr tokens (index + 1)
    Tuple _ next_index_1 <- expect is_token_kind_r_paren tokens next_index
    rpn'' <- rpn' +. call_op pos exprs
    do_parse_expression_binary rpn'' tokens next_index_1

  Just (Token TokenKindRParen _) | is_nested rpn' -> do
      rpn'' <- rpn' +. end_group
      do_parse_expression_binary rpn'' tokens $ index + 1
  
  _ -> Just (Tuple rpn' index)

instance show_expr :: Show Expr where
  show (Expr kind _) = "(Expr " <> show kind <> ")"

instance show_expr_kind :: Show ExprKind where
  show (WhenExpr arms default_expr) = "(WhenExpr " <> show arms <> " " <> show default_expr <> ")"
  show (EqualsExpr left right) = show left <> " == " <> show right
  show (IntExpr value) = show value
  show (NameExpr name) = show name
  show (CallExpr expr args) = "(CallExpr " <> show expr <> " " <> show args <> ")"
  show (AddExpr left right) = show left <> " + " <> show right
  show (SubExpr left right) = show left <> " - " <> show right
  show (MulExpr left right) = show left <> " * " <> show right
  show (DivExpr left right) = show left <> " / " <> show right
  show (GreaterThanExpr left right) = show left <> " > " <> show right
  show (LessThanExpr left right) = show left <> " < " <> show right
  show (GreaterThanEqualsExpr left right) = show left <> " >= " <> show right
  show (LessThanEqualsExpr left right) = show left <> " <= " <> show right
  show (BlockExpr exprs) = "(BlockExpr " <> show exprs <> ")"

instance show_when_arm :: Show WhenArm where
  show (WhenArm condition expr) = "(WhenArm " <> show condition <> " " <> show expr <> ")"

instance show_module :: Show Module where
  show (Module declarations) = "(Module " <> show declarations <> ")"

instance show_module_declaration :: Show ModuleDeclaration where
  show (ModuleDeclaration kind _) = "(ModuleDeclaration " <> show kind <> ")"

instance show_module_declaration_kind :: Show ModuleDeclarationKind where
  show (FnDeclarationKind exported name fn) = "(FnDeclarationKind " <> show exported <> " " <> show name <> " " <> show fn <> ")"

instance show_identifier :: Show Identifier where
  show (NameIdentifier name) = "(Name " <> name <> ")"
  show (TypeIdentifier name) = "(Type " <> name <> ")"

instance show_fn :: Show ModuleFn where
  show (ModuleFn name args return_type expr) = "(ModuleFn " <> show name <> " " <> show args <> " " <> show return_type <> " " <> show expr <> ")"

instance show_fn_param :: Show FnParam where
  show (FnParam name type_expr _) = "(FnParam " <> name <> " " <> show type_expr <> ")"

instance show_type_expr :: Show TypeExpr where
  show (TypeExpr kind _) = "(TypeExpr " <> show kind <> ")"

instance show_type_expr_kind :: Show TypeExprKind where
  show (NamedTypeExpr name) = "(NamedTypeExpr " <> name <> ")"