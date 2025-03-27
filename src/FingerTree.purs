module FingerTree
  ( (+=)
  , FingerTree
  , concat
  , cons
  , empty
  , fold_map_finger_tree
  , foldl
  , foldl_finger_tree
  , foldr
  , foldr_finger_tree
  , from_array
  , from_list
  , map
  , map_finger_tree
  , push
  , single
  , snoc
  , to_array
  , to_list
  , uncons
  , unsnoc
  ) where

import Prelude

import Data.Array as Array
import Data.Foldable (class Foldable)
import Data.List (List(..), (:))
import Data.List.Lazy as List
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))


data FingerTree u
  = Empty
  | Single u
  | Deep Int (Node u) (FingerTree (Node u)) (Node u)

data Node u
  = One u
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
snoc u (Deep n l root (Four v w x y)) = Deep (n + 1) l (snoc (Three v w x) root) $ Two y u

cons :: ∀ (@u :: Type). u -> FingerTree u -> FingerTree u
cons u Empty = single u
cons u (Single v) = Deep 2 (One u) Empty $ One v
cons u (Deep n (One v) root r) = Deep (n + 1) (Two u v) root r
cons u (Deep n (Two v w) root r) = Deep (n + 1) (Three u v w) root r
cons u (Deep n (Three v w x) root r) = Deep (n + 1) (Four u v w x) root r
cons u (Deep n (Four v w x y) root r) = Deep (n + 1) (Two u v) (cons (Three w x y) root) r

uncons :: ∀ (@u :: Type). FingerTree u -> Maybe (Tuple u (FingerTree u))
uncons Empty = Nothing
uncons (Single u) = Just $ Tuple u Empty
uncons (Deep n (Four u v w x) root r) = Just $ Tuple u $ Deep (n - 1) (Three v w x) root r
uncons (Deep n (Three u v w) root r) = Just $ Tuple u $ Deep (n - 1) (Two v w) root r
uncons (Deep n (Two u v) root r) = Just $ Tuple u $ Deep (n - 1) (One v) root r
uncons (Deep n (One u) Empty (Four v w x y)) = Just $ Tuple u $ Deep (n - 1) (Two v w) Empty $ Two x y
uncons (Deep n (One u) Empty (Three v w x)) = Just $ Tuple u $ Deep (n - 1) (Two v w) Empty $ One x
uncons (Deep n (One u) Empty (Two v w)) = Just $ Tuple u $ Deep (n - 1) (One v) Empty $ One w
uncons (Deep _ (One u) Empty (One v)) = Just $ Tuple u $ Single v
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
unsnoc (Deep _ (One v) Empty (One u)) = Just $ Tuple u $ Single v
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
foldr_finger_tree _ acc Empty = acc
foldr_finger_tree f acc (Single a) = f a acc
foldr_finger_tree f acc (Deep _ l root r) = foldr_node_f (foldr_finger_tree flip_foldr_node_f (foldr_node_f acc r) root) l
  where
  foldr_node_f = foldr_node f
  flip_foldr_node_f = flip foldr_node_f

foldl_finger_tree :: ∀ (@u :: Type) b. (b -> u -> b) -> b -> FingerTree u -> b
foldl_finger_tree _ acc Empty = acc
foldl_finger_tree f acc (Single a) = f acc a
foldl_finger_tree f acc (Deep _ l root r) = foldl_node_f (foldl_finger_tree foldl_node_f (foldl_node_f acc l) root) r
  where
  foldl_node_f = foldl_node f

fold_map_finger_tree :: ∀ m u. Monoid m => (u -> m) -> FingerTree u -> m
fold_map_finger_tree _ Empty = mempty
fold_map_finger_tree f (Single a) = f a
fold_map_finger_tree f (Deep _ l root r) = fold_map_node f l <> fold_map_finger_tree (fold_map_node f) root <> fold_map_node f r

instance functor_finger_tree :: Functor FingerTree where
  map = map_finger_tree

map_finger_tree :: ∀ (@u :: Type) (@v :: Type). (u -> v) -> FingerTree u -> FingerTree v
map_finger_tree _ Empty = Empty
map_finger_tree f (Single a) = Single $ f a
map_finger_tree f (Deep n l root r) = Deep n (map_node_f l) (map_finger_tree map_node_f root) $ map_node_f r
  where
  map_node_f = map_node f

instance functor_node :: Functor Node where
  map = map_node

map_node :: ∀ (@u :: Type) (@v :: Type). (u -> v) -> Node u -> Node v
map_node f (One a) = One $ f a
map_node f (Two a b) = Two (f a) (f b)
map_node f (Three a b c) = Three (f a) (f b) (f c)
map_node f (Four a b c d) = Four (f a) (f b) (f c) (f d)

concat :: ∀ (@u :: Type). FingerTree u -> FingerTree u -> FingerTree u
concat Empty b = b
concat a Empty = a
concat (Single a) right = cons a right
concat left (Single b) = snoc b left
concat (Deep n l root r) (Deep n' l' root' r') = Deep (n + n') l (concat (cons r root) (snoc l' root')) r'

foldl :: ∀ (@u :: Type) (b :: Type). (b → u → b) → b → FingerTree u → b
foldl = foldl_finger_tree

foldr :: ∀ (@u :: Type) (b :: Type). (u → b → b) → b → FingerTree u → b
foldr = foldr_finger_tree

map :: ∀ (@u :: Type) (@v :: Type). (u → v) → FingerTree u → FingerTree v
map = map_finger_tree

infixl 4 push as +=

push :: ∀ (u :: Type). FingerTree u → u → FingerTree u
push = flip snoc

from_array :: ∀ (u :: Type). Array u -> FingerTree u
from_array [] = empty
from_array [ a ] = single a
from_array [ a, b ] = Deep 2 (One a) Empty $ One b
from_array [ a, b, c ] = Deep 3 (Two a b) Empty $ One c
from_array [ a, b, c, d ] = Deep 4 (Two a b) Empty $ Two c d
from_array [ a, b, c, d, e ] = Deep 5 (Three a b c) Empty $ Two d e
from_array [ a, b, c, d, e, f ] = Deep 6 (Three a b c) Empty $ Three d e f
from_array [ a, b, c, d, e, f, g ] = Deep 7 (Four a b c d) Empty $ Three e f g
from_array [ a, b, c, d, e, f, g, h ] = Deep 8 (Four a b c d) Empty $ Four e f g h

from_array values = Array.foldl push empty values

instance show_finger_tree :: Show u => Show (FingerTree u) where
  show Empty = "[]"
  show (Single a) = "[" <> show a <> "]"
  show (Deep _ l root r) = "[" <> show l <> ", " <> show root <> ", " <> show r <> "]"

instance show_node :: Show u => Show (Node u) where
  show (One a) = show a
  show (Two a b) = show a <> ", " <> show b
  show (Three a b c) = show a <> ", " <> show b <> ", " <> show c
  show (Four a b c d) = show a <> ", " <> show b <> ", " <> show c <> ", " <> show d

instance eq_finger_tree :: Eq u => Eq (FingerTree u) where
  eq :: FingerTree u -> FingerTree u -> Boolean
  eq Empty Empty = true
  eq (Single a) (Single b) = a == b
  eq (Deep n pf root sf) (Deep n' pf' root' sf') | n == n' =
    case go (to_list_node pf) (to_list_node pf') (snoc sf root) (snoc sf' root') of
      Nothing -> false
      Just b -> b

    where
    go :: List u -> List u -> FingerTree (Node u) -> FingerTree (Node u) -> Maybe Boolean
    go Nil Nil Empty Empty = Just true
    go Nil r left right = do
      Tuple l' left' <- unsnoc left
      go (to_list_node l') r left' right
    go l Nil left right = do
      Tuple r' right' <- unsnoc right
      go l (to_list_node r') left right'
    
    go (a : b : c : d : l') (a' : b' : c' : d' : r') left right | a == a' && b == b' && c == c' && d == d' = go l' r' left right
    go (a : b : c : l') (a' : b' : c' : r') left right | a == a' && b == b' && c == c' = go l' r' left right
    go (a : b : l') (a' : b' : r') left right | a == a' && b == b' = go l' r' left right
    go (a : l') (a' : r') left right | a == a' = go l' r' left right
    go l' r' left right | l' == r' = do
      Tuple l'' left' <- unsnoc left
      Tuple r'' right' <- unsnoc right
      go (to_list_node l'') (to_list_node r'') left' right'

    go _ _ _ _ = Nothing
  eq _ _ = false

to_list :: ∀ (@u :: Type). FingerTree u -> List u
to_list Empty = Nil
to_list (Single a) = (a : Nil)
to_list (Deep _ l root r) = to_list_node l <> (List.foldMap to_list_node $ to_list root) <> to_list_node r

to_list_node :: ∀ (@u :: Type). Node u -> List u
to_list_node (One a) = (a : Nil)
to_list_node (Two a b) = (a : b : Nil)
to_list_node (Three a b c) = (a : b : c : Nil)
to_list_node (Four a b c d) = (a : b : c : d : Nil)

from_list :: ∀ (@u :: Type). List u -> FingerTree u
from_list Nil = Empty
from_list (a : Nil) = Single a
from_list (a : b : Nil) = Deep 2 (One a) Empty $ One b
from_list (a : b : c : Nil) = Deep 3 (Two a b) Empty $ One c
from_list (a : b : c : d : Nil) = Deep 4 (Two a b) Empty $ Two c d
from_list (a : b : c : d : e : Nil) = Deep 5 (Three a b c) Empty $ Two d e
from_list (a : b : c : d : e : f : Nil) = Deep 6 (Three a b c) Empty $ Three d e f
from_list (a : b : c : d : e : f : g : Nil) = Deep 7 (Four a b c d) Empty $ Three e f g
from_list (a : b : c : d : e : f : g : h : Nil) = Deep 8 (Four a b c d) Empty $ Four e f g h

from_list (a : b : c : d : e : f : g : h : l) =
  let
    sf = Four a b c d
    next = Four e f g h
  in
    go 4 sf next empty l
  where
  go n sf next root (e' : f' : g' : h' : l') = go (n + 4) sf (Four e' f' g' h') (snoc next root) l'
  go n sf next root (e' : f' : g' : Nil) = Deep (n + 3) sf (snoc next root) $ Three e' f' g'
  go n sf next root (e' : f' : Nil) = Deep (n + 2) sf (snoc next root) $ Two e' f'
  go n sf next root (e' : Nil) = Deep (n + 1) sf (snoc next root) $ One e'
  go n sf next root Nil = Deep n sf root next

to_array :: ∀ (@u :: Type). FingerTree u -> Array u
to_array = Array.fromFoldable
