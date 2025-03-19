module Test.Main
  ( main
  )
  where

import Data.Array
import Node.Process

import Control.Monad.Error.Class (class MonadThrow)
import Control.Monad.Trampoline (done)
import Data.Eq (class Eq)
import Data.Maybe (Maybe(..))
import Data.Show (class Show)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Error)
import Effect.Class (liftEffect)
import Lexer (Token(..), TokenKind(..), lex_token, tokenize)
import Node.FS.Sync as Fs
import Parser (Expr(..), ExprKind(..), parse_expr)
import Prelude (Unit, bind, discard, (*), (+), (-), (==), ($), pure)
import RPN (RPN, unary, binary, right_unary, finalize, rpn, group, end_group, (++?), (+.?), (+.), (++))
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner.Node (runSpecAndExitProcess)
import Util (to_chars)

solve_and_check :: forall m8 t9. MonadThrow Error m8 => Show t9 => Eq t9 => Maybe (RPN t9) -> t9 -> m8 Unit
solve_and_check rpn' v' = case rpn' of
  Just rpn'' -> case finalize rpn'' of
    Just v -> shouldEqual v v'
    Nothing -> shouldEqual false true
  Nothing -> shouldEqual false true

main :: Effect Unit
main = runSpecAndExitProcess [consoleReporter] do
  describe "Token Kinds" do
    it "should match tokens" do
      -- TokenKindPubKeyword
      shouldEqual (lex_token (to_chars "pub") 0) (Just (Tuple TokenKindPubKeyword 3)) -- to_chars "pub"
      -- TokenKindFnKeyword
      shouldEqual (lex_token (to_chars "fn") 0) (Just (Tuple TokenKindFnKeyword 2)) -- to_chars "fn"
      -- TokenKindWhenKeyword
      shouldEqual (lex_token (to_chars "when") 0) (Just (Tuple TokenKindWhenKeyword 4)) -- to_chars "when"
      -- TokenKindElseKeyword
      shouldEqual (lex_token (to_chars "else") 0) (Just (Tuple TokenKindElseKeyword 4)) -- to_chars "else"
      
      -- TokenKindNameIdentifier String
      shouldEqual (lex_token (to_chars "abc") 0) (Just (Tuple (TokenKindNameIdentifier "abc") 3)) -- to_chars "abc"
      shouldEqual (lex_token (to_chars "_") 0) (Just (Tuple (TokenKindNameIdentifier "_") 1)) -- to_chars "_"
      shouldEqual (lex_token (to_chars "a_b_c_123") 0) (Just (Tuple (TokenKindNameIdentifier "a_b_c_123") 9)) -- to_chars "a_b_c_123"
      -- TokenKindInt Int
      shouldEqual (lex_token (to_chars "1") 0) (Just (Tuple (TokenKindInt 1) 1)) -- to_chars "1"
      shouldEqual (lex_token (to_chars "12") 0) (Just (Tuple (TokenKindInt 12) 2)) -- to_chars "12"
      
      -- TokenKindLParen
      shouldEqual (lex_token (to_chars "(") 0) (Just (Tuple TokenKindLParen 1)) -- to_chars "("
      -- TokenKindRParen
      shouldEqual (lex_token (to_chars ")") 0) (Just (Tuple TokenKindRParen 1)) -- to_chars ")"
      -- TokenKindLBrace
      shouldEqual (lex_token (to_chars "{") 0) (Just (Tuple TokenKindLBrace 1)) -- to_chars "{"
      -- TokenKindRBrace
      shouldEqual (lex_token (to_chars "}") 0) (Just (Tuple TokenKindRBrace 1)) -- to_chars "}"
      -- TokenKindEqualsEquals
      shouldEqual (lex_token (to_chars "==") 0) (Just (Tuple TokenKindEqualsEquals 2)) -- to_chars "=="
      -- TokenKindPlus
      shouldEqual (lex_token (to_chars "+") 0) (Just (Tuple TokenKindPlus 1)) -- to_chars "+"
      -- TokenKindMinus
      shouldEqual (lex_token (to_chars "-") 0) (Just (Tuple TokenKindMinus 1)) -- to_chars "-"
      -- TokenKindRArrow
      shouldEqual (lex_token (to_chars "->") 0) (Just (Tuple TokenKindRArrow 2)) -- to_chars "->"
      -- TokenKindEOF
      shouldEqual (lex_token (to_chars "") 0) (Just (Tuple TokenKindEOF 0)) -- to_chars ""
      shouldEqual (lex_token (to_chars "123") 3) (Just (Tuple TokenKindEOF 3)) -- to_chars "123"
      -- TokenKindWhiteSpace
      shouldEqual (lex_token (to_chars " \t\r") 0) (Just (Tuple TokenKindWhiteSpace 3)) -- to_chars " \t\r"
      -- TokenKindNewLine
      shouldEqual (lex_token (to_chars "\n") 0) (Just (Tuple TokenKindNewLine 1)) -- to_chars "\n"

    it "should generate an array of tokens" do
      let text = """
        pub
        fn
        when
        else
        abc
        _
        a_b_c_123
        1
        12
        (
        )
        {
        }
        ==
        +
        -
        *
        /
        ->

        123
        """
      shouldEqual (tokenize text true) [ Token TokenKindPubKeyword 9
      , Token TokenKindFnKeyword 21
      , Token TokenKindWhenKeyword 32
      , Token TokenKindElseKeyword 45
      , Token (TokenKindNameIdentifier "abc") 58
      , Token (TokenKindNameIdentifier "_") 70
      , Token (TokenKindNameIdentifier "a_b_c_123") 80
      , Token (TokenKindInt 1) 98
      , Token (TokenKindInt 12) 108
      , Token TokenKindLParen 119
      , Token TokenKindRParen 129
      , Token TokenKindLBrace 139
      , Token TokenKindRBrace 149
      , Token TokenKindEqualsEquals 159
      , Token TokenKindPlus 170
      , Token TokenKindMinus 180
      , Token TokenKindAsterisk 190
      , Token TokenKindFSlash 200
      , Token TokenKindRArrow 210
      , Token (TokenKindInt 123) 222
      , Token TokenKindEOF 234
      ]

  let add = binary "+" 5 false \x y -> x + y
  let sub = binary "-" 5 false \x y -> x - y
  let mul = binary "*" 6 false \x y -> x * y
  let mul_2 = unary "*2" \x -> x * 2
  let rmul_2 = right_unary "2*" \x -> x * 2
  let add_2 = unary "+2" \x -> x + 2
  let rmul_3 = right_unary "3*" \x -> x * 3

  describe "RPN" do
    it "should perform unary operations" do
      --                      (*2) 3 = 6
      solve_and_check (rpn ++ 3 +. mul_2) 6

    it "should perform right_unary operations" do
      --                      3 (*2) = 6
      solve_and_check (rpn ++ 3 +. rmul_2) 6

    it "should prioritize right_unary operations over left_unary operations" do
      --                      (+2) (1 (*3)) = 5
      solve_and_check (rpn ++ 1 +. rmul_3 +.? add_2) 5 

    it "should prioritize left_unary operations over binary operations" do
      --                      (+2) 3 * 3 = 15
      solve_and_check (rpn +. add_2 ++? 3 +.? mul ++? 3) 15 

    it "should perform binary operations" do
      --                      1 + 2 = 3
      solve_and_check (rpn ++ 1 +. add ++? 2) 3

    it "should perform order of operations" do
      --                      1 + 2 * 3 - 4 = 3
      solve_and_check (rpn ++ 1 +. add ++? 2 +.? mul ++? 3 +.? sub ++? 4) 3
      
    it "should handle groups" do
      --                      (2 + 3) * 4 = 20
      solve_and_check (rpn +. group ++? 2 +.? add ++? 3 +.? end_group +.? mul ++? 4) 20

  describe "parser" do 
    it "should parse an integer" do
      shouldEqual true true


-- [(Token TokenKindPubKeyword: 9),(Token TokenKindFnKeyword: 21),(Token TokenKindWhenKeyword: 32),(Token TokenKindElseKeyword: 45),(Token (TokenKindNameIdentifier abc): 58),(Token (TokenKindNameIdentifier _): 70),(Token (TokenKindNameIdentifier a_b_c_123): 80),(Token (TokenKindInt 1): 98),(Token (TokenKindInt 12): 108),(Token TokenKindLParen: 119),(Token TokenKindRParen: 129),(Token TokenKindLBrace: 139),(Token TokenKindRBrace: 149),(Token TokenKindEqualsEquals: 159),(Token TokenKindPlus: 170),(Token TokenKindMinus: 180),(Token TokenKindAsterisk: 190),(Token TokenKindFSlash: 200),(Token TokenKindRArrow: 210),(Token (TokenKindInt 123): 222),(Token TokenKindEOF: 234)]