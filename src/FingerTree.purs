module FingerTree
  ( FingerTree
  , cons
  , empty
  , single
  , snoc
  , uncons
  , unsnoc
  )
  where

import Prelude

import Data.Array (fold)
import Data.Foldable (class Foldable, foldMap, foldl, foldr)
import Data.List (List(..), (:)) as List
import Data.Map.Internal (Map(..))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))

data FingerTree u = Empty
               | Single u
               | Deep Int (Node u) (FingerTree (Node u)) (Node u)


data Node u = One u
            | Two u u
            | Three u u u 
            | Four u u u u

empty :: ∀ (@u :: Type). FingerTree u
empty = Empty

single :: ∀ (@u :: Type). u -> FingerTree u
single u = Single u

snoc :: ∀ (@u :: Type). u -> FingerTree u -> FingerTree u
snoc u Empty = single u
snoc u (Single v) = Deep 2 (One v) Empty $ One u
snoc u (Deep n l root (One v)) = Deep (n + 1) l root $ Two v u
snoc u (Deep n l root (Two v w)) = Deep (n + 1) l root $ Three v w u
snoc u (Deep n l root (Three v w x)) = Deep (n + 1) l root $ Four v w x u
snoc u (Deep n l root r@(Four _ _ _ _)) = Deep (n + 1) l (snoc r root) $ One u

cons :: ∀ (@u :: Type). u -> FingerTree u -> FingerTree u
cons u Empty = single u
cons u (Single v) = Deep 2 (One v) Empty $ One u
cons u (Deep n (One v) root r) = Deep (n + 1) (Two v u) root r
cons u (Deep n (Two v w) root r) = Deep (n + 1) (Three v w u) root r
cons u (Deep n (Three v w x) root r) = Deep (n + 1) (Four v w x u) root r
cons u (Deep n l@(Four _ _ _ _) root r) = Deep (n + 1) (One u) (cons l root) r

uncons :: ∀ (@u :: Type). FingerTree u -> Maybe (Tuple u (FingerTree u))
uncons Empty = Nothing
uncons (Single u) = Just $ Tuple u Empty
uncons (Deep n (Four u v w x) root r) = Just $ Tuple u $ Deep (n - 1) (Three v w x) root r
uncons (Deep n (Three u v w) root r) = Just $ Tuple u $ Deep (n - 1) (Two v w) root r
uncons (Deep n (Two u v) root r) = Just $ Tuple u $ Deep (n - 1) (One v) root r
uncons (Deep n (One u) Empty (Four v w x y)) = Just $ Tuple u $ Deep (n - 1) (Two v w) Empty $ Two x y
uncons (Deep n (One u) Empty (Three v w x)) = Just $ Tuple u $ Deep (n - 1) (Two v w) Empty $ One x
uncons (Deep n (One u) Empty (Two v w)) = Just $ Tuple u $ Deep (n - 1) (One v) Empty $ One w
uncons (Deep n (One u) Empty (One v)) = Just $ Tuple u $ Single v
uncons (Deep n (One u) root r) = do
  Tuple l' root' <- uncons root
  Just $ Tuple u $ Deep (n - 1) l' root' r


unsnoc :: ∀ (@u :: Type). FingerTree u -> Maybe (Tuple u (FingerTree u))
unsnoc Empty = Nothing
unsnoc (Single u) = Just $ Tuple u Empty
unsnoc (Deep n l root (Four v w x u)) = Just $ Tuple u $ Deep (n - 1) l root $ Three v w x
unsnoc (Deep n l root (Three v w u)) = Just $ Tuple u $ Deep (n - 1) l root $ Two v w
unsnoc (Deep n l root (Two v u)) = Just $ Tuple u $ Deep (n - 1) l root $ One v
unsnoc (Deep n (Four v w x y) Empty (One u)) = Just $ Tuple u $ Deep (n - 1) (Two v w) Empty $ Two x y
unsnoc (Deep n (Three v w x) Empty (One u)) = Just $ Tuple u $ Deep (n - 1) (Two v w) Empty $ One x
unsnoc (Deep n (Two v w) Empty (One u)) = Just $ Tuple u $ Deep (n - 1) (One v) Empty $ One w
unsnoc (Deep n (One v) Empty (One u)) = Just $ Tuple u $ Single v
unsnoc (Deep n l root (One u)) = do
  Tuple r' root' <- unsnoc root
  Just $ Tuple u $ Deep (n - 1) l root' r'


instance fold_node :: Foldable Node where
  foldr = foldr_node
  foldl = foldl_node
  foldMap = fold_map_node

foldr_node :: ∀ (@u :: Type) b. (u -> b -> b) -> b -> Node u -> b
foldr_node f acc (One a) = f a acc
foldr_node f acc (Two a b) = f a (f b acc)
foldr_node f acc (Three a b c) = f a (f b (f c acc))
foldr_node f acc (Four a b c d) = f a (f b (f c (f d acc)))

foldl_node :: ∀ (@u :: Type) b. (b -> u -> b) -> b -> Node u -> b
foldl_node f acc (One a) = f acc a
foldl_node f acc (Two a b) = f (f acc a) b
foldl_node f acc (Three a b c) = f (f (f acc a) b) c
foldl_node f acc (Four a b c d) = f (f (f (f acc a) b) c) d

fold_map_node :: ∀ m u. Monoid m => (u -> m) -> Node u -> m
fold_map_node f (One a) = f a
fold_map_node f (Two a b) = f a <> f b
fold_map_node f (Three a b c) = f a <> f b <> f c
fold_map_node f (Four a b c d) = f a <> f b <> f c <> f d

instance fold_finger_tree :: Foldable FingerTree where
  foldr = foldr_finger_tree
  foldl = foldl_finger_tree
  foldMap = fold_map_finger_tree

foldr_finger_tree :: ∀ (@u :: Type) b. (u -> b -> b) -> b -> FingerTree u -> b
foldr_finger_tree f acc Empty = acc
foldr_finger_tree f acc (Single a) = f a acc
-- foldr_finger_tree f acc (Deep _ l root r) = foldr_node f (foldr_finger_tree (foldr_node f) acc root)) l

foldl_finger_tree :: ∀ (@u :: Type) b. (b -> u -> b) -> b -> FingerTree u -> b
foldl_finger_tree f acc Empty = acc
foldl_finger_tree f acc (Single a) = f acc a
-- foldl_finger_tree f acc (Deep _ l root r) = foldl_node f (foldl_finger_tree f acc root) r

fold_map_finger_tree :: ∀ m u. Monoid m => (u -> m) -> FingerTree u -> m
fold_map_finger_tree f Empty = mempty
fold_map_finger_tree f (Single a) = f a
-- fold_map_finger_tree f (Deep _ l root r) = fold_map_node f l <> fold_map_finger_tree f root <> fold_map_finger_tree f r