module Parser where

import Data.Array
import Data.Maybe
import Data.Tuple
import Prelude

import Data.Array.ST.Iterator (next)
import Data.Newtype (overF)
import Lexer (Token(..), TokenKind(..), is_token_kind_colon, is_token_kind_comma, is_token_kind_fn_keyword, is_token_kind_l_paren, is_token_kind_name_identifier, is_token_kind_pub_keyword, is_token_kind_r_arrow, is_token_kind_r_paren, is_token_kind_type_identifier, tokenize)
import RPN (rpn)

data NameIdentifier = NameIdentifier String
data TypeIdentifier = TypeIdentifier String

data Module = Module (Array ModuleDeclaration)

data ModuleDeclaration = ModuleDeclaration ModuleDeclarationKind Int

data ModuleDeclarationKind = FnDeclarationKind Boolean (Maybe NameIdentifier) ModuleFn

data ModuleFn = ModuleFn (Array FnParam) (Maybe TypeExpr) Expr

data FnParam = FnParam NameIdentifier (Maybe TypeExpr)

data TypeExpr = TypeExpr TypeExprKind Int

data TypeExprKind = NamedTypeExpr TypeIdentifier

data Expr = Expr ExprKind Int

data ExprKind = WhenExpr Expr (Array WhenArm) (Maybe Expr)
              | EqualsExpr Expr Expr
              | IntExpr Int
              | NameExpr NameIdentifier
              | CallExpr Expr (Array Expr)
              | AddExpr Expr Expr
              | SubExpr Expr Expr

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
parse_otherwise p1 p2 tokens index = do
  Nothing <- p1 tokens index
  p2 tokens index

infixr 3 parse_map as +=
parse_map :: ∀ t u. Parser t -> (t -> u) -> Parser u
parse_map parser mapper = \tokens index -> case parser tokens index of
  Just (Tuple t next_index) -> Just (Tuple (mapper t) next_index)
  Nothing -> Nothing

infixl 4 parse_take_left as <-++
parse_take_left :: ∀ t u. Parser t -> Parser u -> Parser t
parse_take_left p1 p2 tokens index = do
  Just (Tuple t next_index) <- p1 tokens index
  Just (Tuple _ next_index_2) <- p2 tokens next_index
  Just (Tuple t next_index_2)

infixl 4 parse_take_right as ++->
parse_take_right :: ∀ t u. Parser t -> Parser u -> Parser u
parse_take_right p1 p2 tokens index = do
  Just (Tuple _ next_index) <- p1 tokens index
  p2 tokens next_index

expect :: (TokenKind -> Boolean) -> Parser Token
expect p tokens index = case (tokens !! index) of
  Just (Token kind pos) | p kind -> Just (Tuple (Token kind pos) index + 1)
  _ -> Nothing

-- parsers
parse :: String -> Maybe Module
parse module_text = parse_module (tokenize module_text true) 0

parse_module :: (Array Token) -> Int -> Maybe Module
parse_module tokens index = do
  Tuple declarations next_index <- do_parse_many parse_declaration tokens index
  case (tokens !! index) of
    Just (Token TokenKindEOF _) -> Just (Tuple (Module declarations next_index))
    _ -> Nothing

parse_declaration :: Parser ModuleDeclaration
parse_declaration tokens index =
  case expect is_token_kind_pub_keyword tokens index of
    Nothing -> do_parse_declaration tokens index
    Just (Tuple _ next_index) -> do_parse_pub_declaration tokens next_index
-- pub fn fib(n) {
--   when n == 0 -> 0
--     n == 1 -> 1
--     else -> fib(n - 1) + fib(n - 2)
-- }

do_parse_declaration :: (Array Token) -> Int -> Parser ModuleDeclaration
-- Imports
-- Consts
-- Fns
-- Types
do_parse_declaration _ _ = Nothing

do_parse_pub_declaration :: (Array Token) -> Int -> Parser ModuleDeclaration
-- Consts
-- Fns
-- (do_parse_const_declaration +| do_parse_type_declaration +| do_parse_fn_declaration)
do_parse_pub_declaration = do_parse_fn_declaration += \declaration_kind -> case declaration_kind of
  FnDeclarationKind false name fn -> FnDeclarationKind true name fn
  a -> a

do_parse_fn_declaration :: (Array Token) -> Int -> Parser ModuleDeclarationKind
do_parse_fn_declaration tokens index = do
  Tuple _ next_index <- expect is_token_kind_fn_keyword tokens index
  Tuple name next_index_2 <- expect is_token_kind_name_identifier tokens next_index
  Tuple _ next_index_3 <- expect is_token_kind_l_paren tokens next_index_2
  Tuple args next_index_4 <- parse_optional (parse_many_seperated parse_fn_param (expect is_token_kind_colon)) tokens next_index_3
  Tuple _ next_index_5 <- expect is_token_kind_r_paren tokens next_index_4
  Tuple return_type next_index_6 <- parse_optional ((expect is_token_kind_r_arrow) ++-> parse_type_expr) tokens next_index_5
  Tuple expr next_index_7 <- parse_expr tokens next_index_6
  Just (Tuple (FnDeclarationKind false name (ModuleFn args return_type expr)) next_index_7)

parse_fn_param :: Parser FnParam
parse_fn_param tokens index = do
  Tuple name next_index <- expect is_token_kind_name_identifier tokens index
  Tuple type_expr next_index_2 <- parse_optional ((expect is_token_kind_colon) ++-> parse_type_expr) tokens next_index
  Just (Tuple (FnParam name type_expr) next_index_2)

parse_type_expr :: Parser TypeExpr
parse_type_expr tokens index = do
  Tuple type_name next_index <- expect is_token_kind_type_identifier tokens index
  Just (Tuple (TypeExpr (NamedTypeExpr (TypeIdentifier type_name)) next_index))

parse_expr :: Parser Expr
parse_expr tokens index = do
  Tuple rpn' next_index <- do_parse_expression_unary rpn tokens index
  Just expr <- finalize rpn'
  Just (Tuple expr next_index)

do_parse_expression_unary :: RPN -> (Array Token) -> Int -> Parser RPN
do_parse_expression_unary rpn' tokens index = 
