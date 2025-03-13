module Main where

import Prelude
import RPN

import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Debug (spy)
import Effect (Effect)
import Effect.Class.Console (logShow)
import Effect.Console (log)
import Lexer (tokenize)
import Parser (parse_expr)


add = binary 5 false \x y -> spy ("add " <> show x <> " " <> show y) (x + y)
sub = binary 5 false \x y -> spy ("sub " <> show x <> " " <> show y) (x - y)
mul = binary 6 false \x y -> spy ("mul " <> show x <> " " <> show y) (x * y)
main :: Effect Unit
main = case (rpn ++ 1 +. add ++? 2 +.? mul ++? 3 +.? sub ++? 4) of
  Just expr -> logShow (finalize expr)
  _ -> log "error"