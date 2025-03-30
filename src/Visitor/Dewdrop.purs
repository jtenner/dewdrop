module Visitor.Dewdrop where

import Prelude

import Data.Maybe (Maybe(..))
import Dewdrop.Parser
  ( Expr(..)
  , FnParam(..)
  , Identifier(..)
  , Module(..)
  , ModuleDeclaration(..)
  , ModuleFn(..)
  , TypeExpr(..)
  , TypeExprKind(..)
  , WhenArm(..)
  )

