module Visitor.ConstraintGeneration where

import Prelude

import Parser (Module(..))
import Visitor.Pattern (class Visitable, visit, visit_all)

data ConstraintGeneration = ConstraintGeneration

instance Visitable Module ConstraintGeneration where
  on_enter (Module declarations) ctx = do
    Tuple declarations' ctx' <- visit_all declarations ctx
    Just (Tuple (Just ctx') (Replace (Module declarations')))
