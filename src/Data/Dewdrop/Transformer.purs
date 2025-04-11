module Data.Dewdrop.Parser where

import Data.Maybe (Maybe)
import Data.Tuple (Tuple)

type Transformer t u = Array t -> Int -> Maybe (Tuple u Int)

