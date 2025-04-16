module Test.Main where

import Prelude

import Control.Monad.Error.Class (class MonadThrow)
import Data.BitStream (BitReader, get_index, read_from, read_8)
import Data.Dewdrop.Token (Token(..), TokenKind(..))
import Data.FingerTree ((+=), single, empty)
import Data.Foldable (foldl, foldr)
import Data.List (List(..), (:))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Dewdrop.Lexer (lex_token, tokenize)
import Dewdrop.Parser (parse_expr)
import Dewdrop.RPN (RPN, unary, binary, right_unary, finalize, rpn, group, end_group, (++?), (+.?), (+.), (++))
import Effect (Effect)
import Effect.Aff (Error)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner.Node (runSpecAndExitProcess)
import Util (array_to_uint8array, to_uint8array, trace)

solve_and_check :: forall m8 t9. MonadThrow Error m8 => Show t9 => Eq t9 => Maybe (RPN t9) -> t9 -> m8 Unit
solve_and_check rpn' v' = case rpn' of
  Just rpn'' -> case finalize rpn'' of
    Just v -> shouldEqual v v'
    Nothing -> shouldEqual false true
  Nothing -> shouldEqual false true

match_token :: ∀ (m ∷ Type -> Type). MonadThrow Error m => String -> TokenKind -> Int -> m Unit
match_token str kind size = do
  let
    r = lex_token $ read_from $ to_uint8array str
  case r of
    Just (Tuple kind' size') -> do
      _ <- shouldEqual kind kind'
      shouldEqual size $ get_index size'
    Nothing -> shouldEqual false true

expect_words :: ∀ (m ∷ Type -> Type). MonadThrow Error m => List Int -> (BitReader -> Maybe (Tuple Int BitReader)) -> Array Int -> m Unit
expect_words bytes reader v = do
  let init = read_from $ array_to_uint8array v
  go bytes init

  where
  go Nil _ = shouldEqual true true
  go (byte : bytes') r = case reader r of
    Just (Tuple value r') -> do
      shouldEqual value byte
      go bytes' r'
    Nothing -> do
      let _ = trace "Failed to read word from" r 
      shouldEqual false true

main ∷ Effect Unit
main = runSpecAndExitProcess [ consoleReporter ] do
  describe "Reader" do
    --bit_reader
    --get_index
    --to_bytes
    --read_from
    --write
    --write_buffer
    --read
    --read_u8
    --write_u8
    --read_char
    --write_utf8_char
    --write_string
    --read_buffer
    it "should read words from a buffer" do
      expect_words (1 : Nil) read_8 [1]
      expect_words (-1 : Nil) read_8 [255]

  describe "Token Kinds" do

    it "should tokenize pub" do match_token "pub" TokenKindPubKeyword 3
    it "should tokenize fn" do match_token "fn" TokenKindFnKeyword 2
    it "should tokenize when" do match_token "when" TokenKindWhenKeyword 4
    it "should tokenize else" do match_token "else" TokenKindElseKeyword 4
    it "should tokenize abc" do match_token "abc" (TokenKindNameIdentifier "abc") 3
    it "should tokenize _" do match_token "_" (TokenKindNameIdentifier "_") 1
    it "should tokenize a_b_c_123" do match_token "a_b_c_123" (TokenKindNameIdentifier "a_b_c_123") 9
    it "should tokenize 1" do match_token "1" (TokenKindInt 1) 1
    it "should tokenize 12" do match_token "12" (TokenKindInt 12) 2
    it "should tokenize (" do match_token "(" TokenKindLParen 1
    it "should tokenize )" do match_token ")" TokenKindRParen 1
    it "should tokenize {" do match_token "{" TokenKindLBrace 1
    it "should tokenize }" do match_token "}" TokenKindRBrace 1
    it "should tokenize ==" do match_token "==" TokenKindEqualsEquals 2
    it "should tokenize +" do match_token "+" TokenKindPlus 1
    it "should tokenize -" do match_token "-" TokenKindMinus 1
    it "should tokenize ->" do match_token "->" TokenKindRArrow 2
    it "should tokenize \"\"" do match_token "" TokenKindEOF 0
    it "should tokenize 123" do match_token "123" TokenKindEOF 3
    it "should tokenize  \t\r" do match_token " \t\r" TokenKindWhiteSpace 3
    it "should tokenize \n" do match_token "\n" TokenKindNewLine 1

    it "should generate an array of tokens" do
      let
        text =
          """
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
      shouldEqual (tokenize true $ read_from $ to_uint8array text)
        [ Token TokenKindPubKeyword 9
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

  let
    add = binary "+" 5 false \x y -> x + y
    sub = binary "-" 5 false \x y -> x - y
    mul = binary "*" 6 false \x y -> x * y
    mul_2 = unary "*2" \x -> x * 2
    rmul_2 = right_unary "2*" \x -> x * 2
    add_2 = unary "+2" \x -> x + 2
    rmul_3 = right_unary "3*" \x -> x * 3

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
      let
        tokens = tokenize true $ read_from $ to_uint8array "123"
        result = parse_expr tokens 0
      case result of
        Just (Tuple expr _) -> shouldEqual (show expr) "(Expr (IntExpr 123))"
        Nothing -> shouldEqual "Nothing" "Just"

    it "should parse a variable" do
      let
        tokens = tokenize true $ read_from $ to_uint8array "abc"
        result = parse_expr tokens 0
      case result of
        Just (Tuple expr _) -> shouldEqual (show expr) "(Expr (NameExpr abc))"
        Nothing -> shouldEqual "Nothing" "Just"

    it "should parse a binary expression" do
      let
        tokens = tokenize true $ read_from $ to_uint8array "1 + 2"
        result = parse_expr tokens 0
      case result of
        Just (Tuple expr _) -> shouldEqual (show expr) "(Expr (AddExpr (Expr (IntExpr 1)) (Expr (IntExpr 2))))"
        Nothing -> shouldEqual "Nothing" "Just"

    it "should parse a grouped expression" do
      let
        tokens = tokenize true $ read_from $ to_uint8array "(1 + 2)"
        result = parse_expr tokens 0
      case result of
        Just (Tuple expr _) -> shouldEqual (show expr) "(Expr (AddExpr (Expr (IntExpr 1)) (Expr (IntExpr 2))))"
        Nothing -> shouldEqual "Nothing" "Just"

    it "should parse a more complex expression" do
      let
        tokens = tokenize true $ read_from $ to_uint8array "(1 + 2) * 3 - 4"
        result = parse_expr tokens 0
      case result of
        Just (Tuple expr _) -> shouldEqual (show expr) "(Expr (SubExpr (Expr (MulExpr (Expr (AddExpr (Expr (IntExpr 1)) (Expr (IntExpr 2)))) (Expr (IntExpr 3)))) (Expr (IntExpr 4))))"
        Nothing -> shouldEqual "Nothing" "Just"

    it "should parse a call expression" do
      let
        tokens = tokenize true $ read_from $ to_uint8array "f(1, 2)"
        result = parse_expr tokens 0
      case result of
        Just (Tuple expr _) -> shouldEqual (show expr) "(Expr (CallExpr (Expr (NameExpr f)) [(Expr (IntExpr 1)),(Expr (IntExpr 2))]))"
        Nothing -> shouldEqual "Nothing" "Just"

  describe "FingerTree" do
    it "should handle empty trees" do
      let empty_ft = empty

      shouldEqual (map (\x -> x + 1) empty_ft) mempty
      shouldEqual (foldl (\acc x -> acc + x) 0 empty_ft) 0
      shouldEqual (foldr (\x acc -> acc + x) 0 empty_ft) 0

    it "should handle single element trees" do
      let ft = single 5
      shouldEqual (map (\x -> x + 1) ft) $ pure 6
      shouldEqual (foldl (\acc x -> acc + x) 0 ft) 5

    it "should handle multiple element trees" do
      let ft = mempty += 1 += 2 += 3
      shouldEqual (map (\x -> x + 1) ft) $ pure 2 += 3 += 4
      shouldEqual (foldl (\acc x -> acc + x) 0 ft) 6

    it "should handle concatenation" do
      let
        ft1 = pure 1
        ft2 = pure 2
        combined = ft1 <> ft2
      shouldEqual (map (\x -> x + 1) combined) $ pure 2 += 3
      shouldEqual (foldr (\x acc -> acc + x) 0 combined) 3

    it "should handle complex transformations" do
      let ft = (single 1) <> (single 2) <> (single 3)
      shouldEqual (foldr (\x acc -> acc + x) 0 ft) 6

    it "should handle edge cases with foldr" do
      let ft = (single 1) <> (single 2) <> (single 3)
      shouldEqual (foldr (\x acc -> acc + x) 0 ft) 6

    it "should handle empty foldr" do
      let emptyFT = empty
      shouldEqual (foldr (\x acc -> acc + x) 0 emptyFT) 0

    it "should handle single element foldr" do
      let singleFT = single 5
      shouldEqual (foldr (\x acc -> acc + x) 0 singleFT) 5

