module RPN
  ( (++)
  , (++?)
  , (+.)
  , (+.?)
  , Operator
  , RPN(..)
  , binary
  , end_group
  , finalize
  , group
  , is_nested
  , pop_value_maybe
  , push_operator
  , push_operator_maybe
  , push_value
  , push_value_maybe
  , right_unary
  , rpn
  , unary
  )
  where

import Prelude

import Data.List (List(..), (:))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Debug (spy)

data Operator a = LeftUnary String (a -> a)
                | RightUnary String (a -> a)
                | Binary String Int Boolean (a -> a -> a)
                | Group
                | EndGroup

instance Show (Operator a) where
  show (LeftUnary name _) = "LeftUnary " <> name
  show (RightUnary name _) = "RightUnary " <> name
  show (Binary name _ _ _) = "Binary " <> name
  show Group = "Group"
  show EndGroup = "EndGroup"

data RPN expr = RPN Int (List expr) (List (Operator expr))

rpn :: ∀ a. RPN a
rpn = RPN 0 Nil Nil

unary :: ∀ a. String -> (a -> a) -> Operator a
unary name f = LeftUnary name f

right_unary :: ∀ a. String -> (a -> a) -> Operator a
right_unary name f = RightUnary name f

binary :: ∀ a. String -> Int -> Boolean -> (a -> a -> a) -> Operator a
binary name p f = Binary name p f

group :: ∀ a. Operator a
group = Group

end_group :: ∀ a. Operator a
end_group = EndGroup

infixl 4 push_value as ++
push_value :: ∀ a. Show a => RPN a -> a -> RPN a
push_value (RPN nested stack ops) v = spy ("pushing value " <> show v) $ RPN nested (v : stack) ops

pop_value_maybe :: ∀ a. Show a => RPN a -> Maybe (Tuple a (RPN a))
pop_value_maybe (RPN nested (v : stack) ops) = spy ("popping value " <> show v) $ Just $ Tuple v $ RPN nested stack ops
pop_value_maybe _ = Nothing

infixl 4 push_value_maybe as ++?
push_value_maybe :: ∀ a. Show a => Maybe (RPN a) -> a -> Maybe (RPN a)
push_value_maybe (Just rpn') v = Just $ push_value rpn' v
push_value_maybe _ _ = Nothing

infixl 4 push_operator_maybe as +.?
push_operator_maybe :: ∀ a. Show a => Maybe (RPN a) -> Operator a -> Maybe (RPN a)
push_operator_maybe Nothing _ = Nothing
push_operator_maybe (Just rpn') op = push_operator rpn' op

infixl 4 push_operator as +.
push_operator :: ∀ a. Show a => RPN a -> Operator a -> Maybe (RPN a)
-- If the operator is an end group but the op stack is empty, pushing an end group is not ok
push_operator (RPN _ _ Nil) EndGroup = spy "pushing operator (EndGroup) failed, op stack is empty" Nothing
push_operator (RPN _ Nil _) EndGroup = spy "pushing operator (EndGroup) failed, stack is empty" Nothing
push_operator rpn'@(RPN 0 _ _) EndGroup = spy "pushing operator (EndGroup) failed, not in a group" Nothing

-- pushing a group operator is always ok
push_operator (RPN nested stack ops) Group = spy "Pushing group operator" $ Just $ RPN (nested + 1) stack (Group : ops)

-- If the operator stack is empty, pushing an operator is always ok
push_operator (RPN nested stack Nil) op = spy ("pushing operator, stack is empty (" <> show op <> ")") $ Just $ RPN nested stack (op : Nil)

push_operator (RPN _ _ (EndGroup : _)) _ = spy "Impossible state, stack contains end group" Nothing
-- pushing an end group requires stack evaluation until the group operator is popped
push_operator rpn'@(RPN _ _ (Group : _)) EndGroup = spy "EndGroup processing finished, returning rpn state instead of processing end group" $ Just rpn'

-- If the top operator is a group operator, pushing an operator is always ok
push_operator (RPN nested stack ops@(Group : _)) op = spy "Top operator is group, pushing operator" $ Just $ RPN nested stack (op : ops)

-- EndGroup requires stack evaluation until the Group operator is popped
push_operator rpn' EndGroup = do
  rpn'' <- spy "Processing EndGroup, popping operator" $ pop_operator rpn'
  push_operator rpn'' EndGroup

-- pushing a binary operator to the stack is ok if ...
push_operator rpn'@(RPN nested stack ops@(Binary _ p' _ _ : _)) op@(Binary _ p f _) 
  -- the precidence is higher
  | p > p' = spy "Pushing binary operator with higher precidence" $ Just $ RPN nested stack $ op : ops
  -- the precidence is the same and the operator is right associative
  | p == p' && not f = spy "Right associative, pushing binary operator" $ Just $ RPN nested stack $ op : ops
  -- otherwise, pop the stack once and continue
  | otherwise = do
    rpn'' <- spy "Pushing binary operator with lower precidence, popping operator" $ pop_operator rpn'
    push_operator rpn'' op

-- pushing a right unary operator is always ok
push_operator (RPN nested stack ops) op@(RightUnary _ _) = spy "Pushing right unary operator" Just $ RPN nested stack $ op : ops

-- pushing a left unary operator requires stack evaluation if the stack has a right unary operator
push_operator rpn'@(RPN _ _ (RightUnary _ _ : _)) op@(LeftUnary _ _) = do
  rpn'' <- spy "Pushing left unary operator into right unary operator on stack, popping operator" $ pop_operator rpn'
  push_operator rpn'' op

-- pushing a left unary operator is otherwise ok
push_operator (RPN nested stack ops) op@(LeftUnary _ _) = spy "Pushing left unary operator" $ Just $ RPN nested stack $ op : ops

-- pushing a binary operator requires stack evaluation if the stack has a right unary operator
push_operator rpn' op@(Binary _ _ _ _) = do
  rpn'' <- spy "Pushing binary operator into unary operator on stack, popping operator becuase it has higher precidence" $ pop_operator rpn'
  push_operator rpn'' op

pop_operator :: ∀ a. Show a => RPN a -> Maybe (RPN a)
pop_operator (RPN nested (x : stack) (LeftUnary name f : ops)) = spy ("Popping " <> name <> " with " <> show x ) $ Just $ RPN nested (f x : stack) ops
pop_operator (RPN nested (x : stack) (RightUnary name f : ops)) = spy ("Popping " <> name <> " with " <> show x ) $ Just $ RPN nested (f x : stack) ops
pop_operator (RPN nested (y : x : stack) (Binary name _ _ f : ops)) = spy ("Popping " <> name <> " with " <> show x <> " and " <> show y) $ Just $ RPN nested (f x y : stack) ops
pop_operator weird = do
  let _ = spy "popping operator failed" weird
  Nothing

finalize :: ∀ a. Show a => RPN a -> Maybe a
-- finalizing an RPN stack with an empty operator stack and a single value is success
finalize (RPN _ (x : Nil) Nil) = spy "finalize success" $ Just x

-- pass groups through
finalize (RPN nested stack (Group : ops)) = spy "popping group" $ finalize $ RPN (nested - 1) stack ops

-- anything else requires stack evaluation
finalize rpn' = do
  rpn'' <- spy "finalize popping operator" $ pop_operator rpn'
  finalize rpn''

is_nested :: ∀ a. RPN a -> Boolean
is_nested (RPN nested _ _) = nested > 0
