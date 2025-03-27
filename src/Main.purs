module Main where

import Prelude

import Effect (Effect)
import Program (compile, pkg)

main :: Effect Unit
main = do
  let config = pkg "my-project" "example"
  compile config