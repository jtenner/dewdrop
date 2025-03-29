module Visitor.Pattern
  ( VisitAction(..)
  , VisitExitResult
  , VisitResult
  , class Visitable
  , continue
  , exit
  , on_children
  , on_enter
  , on_exit
  , replace
  , skip
  , visit
  , visit_all
  )
  where

import Prelude

import Data.Foldable (class Foldable, foldM)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Semigroup (class Semigroup)
import Data.Tuple (Tuple(..))

data VisitAction u = Replace u | Skip | Exit | Continue
type VisitResult ctx node = Maybe (Tuple (Maybe ctx) (VisitAction node))
type VisitExitResult ctx node = Maybe (Tuple (Maybe ctx) (Maybe node))

replace :: ∀ (@node :: Type) (@ctx :: Type). Maybe ctx -> node -> VisitResult ctx node
replace ctx node = Just $ Tuple ctx (Replace node)

skip :: ∀ (@node :: Type) (@ctx :: Type). Maybe ctx -> VisitResult ctx node
skip ctx = Just $ Tuple ctx Skip

exit :: ∀ (@node :: Type) (@ctx :: Type). Maybe ctx -> VisitResult ctx node
exit ctx = Just $ Tuple ctx Exit

continue :: ∀ (@node :: Type) (@ctx :: Type). Maybe ctx -> VisitResult ctx node
continue ctx = Just $ Tuple ctx Continue

class Visitable node ctx where
  on_enter :: node -> ctx -> VisitResult ctx node
  on_children :: node -> ctx -> VisitExitResult ctx node
  on_exit :: node -> ctx -> VisitExitResult ctx node

from_action :: ∀ (@node :: Type). node -> VisitAction node -> node
from_action _ (Replace node') = node'
from_action node _ = node

visit :: ∀ (@node :: Type) (@ctx :: Type). Visitable node ctx => node -> ctx -> VisitExitResult ctx node
visit node ctx = do
  Tuple maybe_ctx action <- on_enter node ctx
  let 
    ctx' = fromMaybe ctx maybe_ctx
    node' = from_action node action
  case action of
    Skip -> on_exit node' ctx'
    Exit -> Just $ Tuple (Just ctx') $ Just node'
    _ -> do
      Tuple maybe_ctx' maybe_node <- on_children node' ctx'
      let
        ctx'' = fromMaybe ctx' maybe_ctx'
        node'' = fromMaybe node' maybe_node
      on_exit node'' ctx''


visit_all :: ∀ (@node :: Type) (@iter :: Type -> Type) (@ctx :: Type). Monoid (iter node) => Applicative iter => Semigroup (iter node) => Foldable iter => (Visitable node ctx) => iter node -> ctx -> VisitExitResult ctx (iter node)
visit_all nodes ctx = do
  Tuple maybe_ctx nodes' <- foldM go (Tuple (Just ctx) mempty) nodes
  ctx' <- maybe_ctx
  Just $ Tuple (Just ctx') $ Just nodes'

  where
    go :: Tuple (Maybe ctx) (iter node) -> node -> Maybe (Tuple (Maybe ctx) (iter node))
    go (Tuple Nothing _) _ = Nothing
    go (Tuple (Just ctx') acc) node = case visit node ctx' of
      Just (Tuple maybe_ctx' maybe_node) -> do
        let ctx'' = fromMaybe ctx' maybe_ctx'
        let node' = fromMaybe node maybe_node
        Just $ Tuple (Just ctx'') $ acc <> (pure node')
      Nothing -> Nothing