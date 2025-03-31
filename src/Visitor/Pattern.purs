module Visitor.Pattern
  ( VisitAction(..)
  , VisitResult
  , continue
  , exit
  , from_action
  , replace
  , remove
  , skip_children
  )
  where

import Prelude

import Data.Foldable (class Foldable, foldM)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))

data VisitAction u = Replace u | SkipChildren | Exit | Continue | Remove
type VisitResult ctx node = Maybe (Tuple ctx (VisitAction node))

replace :: ∀ (@node :: Type) (@ctx :: Type). ctx -> node -> VisitResult ctx node
replace ctx node = Just $ Tuple ctx (Replace node)

skip_children :: ∀ (@node :: Type) (@ctx :: Type). ctx -> VisitResult ctx node
skip_children ctx = Just $ Tuple ctx SkipChildren

exit :: ∀ (@node :: Type) (@ctx :: Type). ctx -> VisitResult ctx node
exit ctx = Just $ Tuple ctx Exit

continue :: ∀ (@node :: Type) (@ctx :: Type). ctx -> VisitResult ctx node
continue ctx = Just $ Tuple ctx Continue

from_action :: ∀ (@u :: Type). u -> VisitAction u -> u
from_action _ (Replace u) = u
from_action u _ = u

remove :: ∀ (@node :: Type) (@ctx :: Type). ctx -> VisitResult ctx node
remove ctx = Just $ Tuple ctx Remove



