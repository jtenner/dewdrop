module Visitor.Pattern
  ( VisitAction(..)
  , VisitResult
  , class Pass
  , class Visitable
  , continue
  , continue_with
  , enter
  , exit
  , ignore
  , remove
  , replace
  , skip_all
  , skip_children
  , visit
  , visit_all
  , visit_children
  ) where

import Prelude

import Data.Foldable (class Foldable, foldM)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))

data VisitAction u
  = Replace u
  | ContinueWith u
  | Continue
  | SkipChildren
  | Exit
  | Remove

type VisitResult ctx node = Maybe (Tuple ctx (VisitAction node))

replace :: ∀ (@node :: Type) (@ctx :: Type). ctx -> node -> VisitResult ctx node
replace ctx node = Just $ Tuple ctx (Replace node)

skip_children :: ∀ (@node :: Type) (@ctx :: Type). ctx -> VisitResult ctx node
skip_children ctx = Just $ Tuple ctx SkipChildren

skip_all :: ∀ (@node :: Type) (@ctx :: Type). ctx -> VisitResult ctx node
skip_all ctx = Just $ Tuple ctx Exit

continue :: ∀ (@node :: Type) (@ctx :: Type). ctx -> VisitResult ctx node
continue ctx = Just $ Tuple ctx Continue

from_action :: ∀ (@u :: Type). u -> VisitAction u -> u
from_action _ (Replace u) = u
from_action u _ = u

remove :: ∀ (@node :: Type) (@ctx :: Type). ctx -> VisitResult ctx node
remove ctx = Just $ Tuple ctx Remove

continue_with :: ∀ (@node :: Type) (@ctx :: Type). node -> ctx -> VisitResult ctx node
continue_with node ctx = Just $ Tuple ctx (ContinueWith node)

class Pass over ctx where
  enter :: Visitable over ctx => over -> ctx -> VisitResult ctx over
  exit :: Visitable over ctx => over -> ctx -> VisitResult ctx over

class Visitable over ctx where
  visit_children :: Pass over ctx => over -> ctx -> Maybe (Tuple ctx over)

visit :: ∀ (@over :: Type) (@ctx :: Type). Pass over ctx => Visitable over ctx => over -> ctx -> Maybe (Tuple ctx over)
visit over ctx = go_enter over ctx

  where
  go_enter :: over -> ctx -> Maybe (Tuple ctx over)
  go_enter over' ctx' = case enter over' ctx' of
    Nothing -> Nothing
    Just (Tuple ctx'' (Replace over'')) -> go_enter over'' ctx''
    Just (Tuple ctx'' (ContinueWith over'')) -> go_visit_children over'' ctx''
    Just (Tuple ctx'' SkipChildren) -> go_exit over ctx''
    Just (Tuple ctx'' Exit) -> Just $ Tuple ctx'' over'
    Just (Tuple ctx'' _) -> go_visit_children over ctx''

  go_visit_children :: over -> ctx -> Maybe (Tuple ctx over)
  go_visit_children over' ctx' = case visit_children over' ctx' of
    Nothing -> Nothing
    Just (Tuple ctx'' over'') -> go_exit over'' ctx''

  go_exit :: over -> ctx -> Maybe (Tuple ctx over)
  go_exit over' ctx' = case exit over' ctx' of
    Nothing -> Nothing
    Just (Tuple ctx'' (Replace over'')) -> go_exit over'' ctx''
    Just (Tuple ctx'' (ContinueWith over'')) -> Just $ Tuple ctx'' over''
    Just (Tuple ctx'' _) -> Just $ Tuple ctx'' over'

visit_all
  :: ∀ (@iter :: Type -> Type) (@over :: Type) (@ctx :: Type)
   . Pass over ctx
  => Foldable iter
  => Visitable over ctx
  => Applicative iter
  => Monoid (iter over)
  => iter over
  -> ctx
  -> Maybe (Tuple ctx (iter over))
visit_all iter ctx = foldM go (Tuple ctx mempty) iter
  where
  go :: (Tuple ctx (iter over)) -> over -> Maybe (Tuple ctx (iter over))
  go (Tuple ctx' acc) over = go_enter over ctx'
    where
    go_enter :: over -> ctx -> Maybe (Tuple ctx (iter over))
    go_enter over' ctx'' = case enter over' ctx'' of
      Nothing -> Nothing
      Just (Tuple ctx''' (Replace over'')) -> go_enter over'' ctx'''
      Just (Tuple ctx''' (ContinueWith over'')) -> go_visit_children over'' ctx'''
      Just (Tuple ctx''' SkipChildren) -> go_exit over' ctx'''
      Just (Tuple ctx''' Exit) -> Just $ Tuple ctx''' acc
      Just (Tuple ctx''' Remove) -> Just $ Tuple ctx''' acc
      Just (Tuple ctx''' _) -> go_visit_children over' ctx'''

    go_visit_children :: over -> ctx -> Maybe (Tuple ctx (iter over))
    go_visit_children over' ctx'' = case visit_children over' ctx'' of
      Nothing -> Nothing
      Just (Tuple ctx''' over'') -> go_exit over'' ctx'''

    go_exit :: over -> ctx -> Maybe (Tuple ctx (iter over))
    go_exit over' ctx'' = case exit over' ctx'' of
      Nothing -> Nothing
      Just (Tuple ctx''' (Replace over'')) -> go_exit over'' ctx'''
      Just (Tuple ctx''' (ContinueWith over'')) -> Just $ Tuple ctx''' (acc <> (pure over''))
      Just (Tuple ctx''' Remove) -> Just $ Tuple ctx''' acc
      Just (Tuple ctx''' _) -> Just $ Tuple ctx''' $ acc <> (pure over')

ignore :: ∀ (@ctx :: Type) (@over :: Type). over -> ctx -> VisitResult ctx over
ignore _ ctx = continue ctx

instance visitable_maybe :: (Visitable over ctx, Pass over ctx) => Visitable (Maybe over) ctx where
  visit_children Nothing ctx = Just $ Tuple ctx Nothing
  visit_children (Just node) ctx = go_enter node ctx

    where
    go_enter :: over -> ctx -> Maybe (Tuple ctx (Maybe over))
    go_enter over' ctx' = case enter over' ctx' of
      Nothing -> Nothing
      Just (Tuple ctx'' (Replace over'')) -> go_enter over'' ctx''
      Just (Tuple ctx'' (ContinueWith over'')) -> go_visit_children over'' ctx''
      Just (Tuple ctx'' SkipChildren) -> go_exit over' ctx''
      Just (Tuple ctx'' Exit) -> Just $ Tuple ctx'' $ Just over'
      Just (Tuple ctx'' Remove) -> Just $ Tuple ctx'' Nothing
      Just (Tuple ctx'' _) -> go_visit_children over' ctx''

    go_visit_children :: over -> ctx -> Maybe (Tuple ctx (Maybe over))
    go_visit_children over' ctx' = case visit_children over' ctx' of
      Nothing -> Nothing
      Just (Tuple ctx'' over'') -> go_exit over'' ctx''

    go_exit :: over -> ctx -> Maybe (Tuple ctx (Maybe over))
    go_exit over' ctx' = case exit over' ctx' of
      Nothing -> Nothing
      Just (Tuple ctx'' (Replace over'')) -> go_exit over'' ctx''
      Just (Tuple ctx'' (ContinueWith over'')) -> Just $ Tuple ctx'' $ Just over''
      Just (Tuple ctx'' Remove) -> Just $ Tuple ctx'' Nothing
      Just (Tuple ctx'' _) -> Just $ Tuple ctx'' $ Just over'

instance pass_maybe :: (Pass node ctx, Visitable node ctx) => Pass (Maybe node) ctx where
  enter Nothing ctx = skip_all ctx
  enter (Just node) ctx = do
    Tuple ctx' visit_action <- enter node ctx
    let node' = from_action node visit_action
    case visit_action of
      Remove -> replace ctx' Nothing
      _ -> replace ctx (Just node')
  exit Nothing ctx = skip_all ctx
  exit (Just node) ctx = do
    Tuple ctx' visit_action <- exit node ctx
    let node' = from_action node visit_action
    case visit_action of
      Remove -> replace ctx' Nothing
      _ -> replace ctx (Just node')

instance visitable_tuple :: (Pass left ctx, Pass right ctx, Visitable left ctx, Visitable right ctx) => Visitable (Tuple left right) ctx where
  visit_children (Tuple left right) ctx = do
    Tuple ctx' left' <- visit left ctx
    Tuple ctx'' right' <- visit right ctx'
    Just $ Tuple ctx'' (Tuple left' right')

instance pass_tuple :: (Pass left ctx, Pass right ctx, Visitable left ctx, Visitable right ctx) => Pass (Tuple left right) ctx where
  enter = ignore
  exit = ignore