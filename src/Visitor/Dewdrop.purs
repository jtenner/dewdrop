module Visitor.Dewdrop where

import Prelude

import Data.Maybe (Maybe(..))
import Parser
  ( Expr(..)
  , FnParam(..)
  , Identifier(..)
  , Module(..)
  , ModuleDeclaration(..)
  , ModuleFn(..)
  , TypeExpr(..)
  , TypeExprKind(..)
  , VisitResult
  , WhenArm(..)
  )

