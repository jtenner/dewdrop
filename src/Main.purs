module Main where

import Prelude
import RPN

import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Debug (spy)
import Effect (Effect)
import Effect.Class.Console (logShow)
import Effect.Console (log)
import Program
import Parser


main :: Effect Unit
main = do
  let config = pkg "my-project" "example"
  compile config