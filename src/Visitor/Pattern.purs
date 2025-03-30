module Visitor.Pattern
  ( VisitAction(..)
  , VisitResult
  , class Visitable
  , class VisitableChildren
  , continue
  , exit
  , on_enter
  , on_exit
  , replace
  , skip_children
  , visit
  , visit_all
  , visit_children
  ) where

import Prelude

import Data.Foldable (class Foldable, foldM)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple (Tuple(..))

data VisitAction u = Replace u | SkipChildren | Exit | Continue
type VisitResult ctx node = Maybe (Tuple (Maybe ctx) (VisitAction node))

replace :: ∀ (@node :: Type) (@ctx :: Type). Maybe ctx -> node -> VisitResult ctx node
replace ctx node = Just $ Tuple ctx (Replace node)

skip_children :: ∀ (@node :: Type) (@ctx :: Type). Maybe ctx -> VisitResult ctx node
skip_children ctx = Just $ Tuple ctx SkipChildren

exit :: ∀ (@node :: Type) (@ctx :: Type). Maybe ctx -> VisitResult ctx node
exit ctx = Just $ Tuple ctx Exit

continue :: ∀ (@node :: Type) (@ctx :: Type). Maybe ctx -> VisitResult ctx node
continue ctx = Just $ Tuple ctx Continue

class Visitable node ctx where
  on_enter :: node -> ctx -> VisitResult ctx node
  on_exit :: node -> ctx -> VisitResult ctx node

class VisitableChildren node where
  visit_children :: ∀ (@ctx :: Type). node -> ctx -> VisitResult ctx node

from_action :: ∀ (@node :: Type). node -> VisitAction node -> node
from_action _ (Replace node') = node'
from_action node _ = node

visit :: ∀ (@node :: Type) (@ctx :: Type). VisitableChildren node => Visitable node ctx => node -> ctx -> VisitResult ctx node
visit node ctx = do
  Tuple maybe_ctx action <- on_enter node ctx
  let
    node' = from_action node action
    ctx' = fromMaybe ctx maybe_ctx
  case action of
    SkipChildren -> on_exit node' ctx'
    Exit -> Just $ Tuple (Just ctx') $ action
    _ -> do
      Tuple maybe_ctx' action' <- visit_children node' ctx'
      let
        node'' = from_action node' action'
        ctx'' = fromMaybe ctx' maybe_ctx'
      on_exit node'' ctx''

visit_all
  :: ∀ (@node :: Type) (@iter :: Type -> Type) (@ctx :: Type)
   . Monoid (iter node)
  => Applicative iter
  => Semigroup (iter node)
  => Foldable iter
  => (Visitable node ctx)
  => VisitableChildren node
  => iter node
  -> ctx
  -> VisitResult ctx (iter node)
visit_all nodes ctx = do
  Tuple maybe_ctx nodes' <- foldM go (Tuple (Just ctx) mempty) nodes
  ctx' <- maybe_ctx
  Just $ Tuple (Just ctx') $ Replace nodes'

  where
  go :: Tuple (Maybe ctx) (iter node) -> node -> Maybe (Tuple (Maybe ctx) (iter node))
  go (Tuple Nothing _) _ = Nothing
  go (Tuple (Just ctx') acc) node = case visit node ctx' of
    Just (Tuple maybe_ctx' maybe_node) -> do
      let ctx'' = fromMaybe ctx' maybe_ctx'
      let node' = from_action node maybe_node
      Just $ Tuple (Just ctx'') $ acc <> (pure node')
    Nothing -> Nothing