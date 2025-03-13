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

import Debug(spy)

data Operator a = LeftUnary (a -> a)
                | RightUnary (a -> a)
                | Binary Int Boolean (a -> a -> a)
                | Group
                | EndGroup

data RPN expr = RPN (List expr) (List (Operator expr))

rpn :: ∀ a. RPN a
rpn = RPN Nil Nil

unary :: ∀ a. (a -> a) -> Operator a
unary f = LeftUnary f

right_unary :: ∀ a. (a -> a) -> Operator a
right_unary f = RightUnary f

binary :: ∀ a. Int -> Boolean -> (a -> a -> a) -> Operator a
binary p f = Binary p f

group :: ∀ a. Operator a
group = Group

end_group :: ∀ a. Operator a
end_group = EndGroup

infixl 4 push_value as ++
push_value :: ∀ a. Show a => RPN a -> a -> RPN a
push_value (RPN stack ops) v = spy ("pushing value" <> show v) (RPN (v : stack) ops)

infixl 4 push_value_maybe as ++?
push_value_maybe :: ∀ a. Show a => Maybe (RPN a) -> a -> Maybe (RPN a)
push_value_maybe (Just rpn') v = Just (push_value rpn' v)
push_value_maybe _ _ = spy "Cannot push value" Nothing

infixl 4 push_operator_maybe as +.?
push_operator_maybe :: ∀ a. Maybe (RPN a) -> Operator a -> Maybe (RPN a)
push_operator_maybe Nothing _ = spy "Cannot push operator" Nothing
push_operator_maybe (Just rpn') op = push_operator rpn' op

infixl 4 push_operator as +.
push_operator :: ∀ a. RPN a -> Operator a -> Maybe (RPN a)
-- If the operator stack is empty, pushing an operator is always ok
push_operator (RPN stack Nil) op = spy "Pushing operator, stack empty" (Just (RPN stack (op : Nil)))
push_operator (RPN _ (EndGroup : _)) _ = spy "Impossible state" Nothing

-- pushing an end group requires stack evaluation until the group operator is popped
push_operator (RPN stack (Group : ops)) EndGroup = spy "Popping group" (Just (RPN stack ops))

-- If the top operator is a group operator, pushing an operator is always ok
push_operator (RPN stack (Group : ops)) op = spy "Pushing operator on top of a group" (Just (RPN stack (op : Group : ops)))

-- pushing a group operator is always ok
push_operator (RPN stack ops) Group = spy "Pushing group" (Just (RPN stack (Group : ops)))

-- handling operators requires stack evaluation
push_operator (RPN stack (Binary _ _ g' : ops)) EndGroup = do
  stack' <- spy "Popping binary" (pop_binary stack g')
  push_operator (RPN stack' ops) EndGroup

push_operator (RPN stack (LeftUnary f' : ops)) EndGroup = do
  stack' <- spy "Popping unary" (pop_unary stack f')
  push_operator (RPN stack' ops) EndGroup

push_operator (RPN stack (RightUnary f' : ops)) EndGroup = do
  stack' <- spy "Popping right unary" (pop_unary stack f')
  push_operator (RPN stack' ops) EndGroup

-- if the operator stack is now empty, pushing an end group is not ok
push_operator (RPN _ _) EndGroup = spy "Pushing end group, stack or ops empty" Nothing

-- pushing a binary operator to the stack is ok if ...
push_operator (RPN stack (Binary p' f' g' : ops)) (Binary p f g) 
  -- the precidence is higher
  | p > p' = spy "incoming operator is higher precedence" Just (RPN stack (Binary p f g : Binary p' f' g' : ops))
  -- the precidence is the same and the operator is right associative
  | p == p' && not f = spy "incoming operator has same precedence with left associativity" Just (RPN stack (Binary p f g : Binary p' f' g' : ops))
  -- otherwise, pop the stack once and continue
  | otherwise = do
    stack' <- spy "popping binary" (pop_binary stack g')
    push_operator (RPN stack' ops) (Binary p f g) 

-- pushing a right unary operator is always ok
push_operator (RPN stack ops) (RightUnary f) = spy "pushing right unary" Just (RPN stack (RightUnary f : ops))

-- pushing a left unary operator requires stack evaluation if the stack has a right unary operator
push_operator (RPN stack (RightUnary g : ops)) (LeftUnary f) = do
  stack' <- spy "popping unary" pop_unary stack g
  push_operator (RPN stack' ops) (LeftUnary f)

-- pushing a left unary operator is otherwise ok
push_operator (RPN stack ops) (LeftUnary f) = spy "pushing left unary" Just (RPN stack (LeftUnary f : ops))

-- pushing a binary operator requires stack evaluation if the stack has a right unary operator
push_operator (RPN stack (RightUnary g' : ops)) (Binary p f g) = do
  stack' <- spy "popping unary" pop_unary stack g'
  push_operator (RPN stack' ops) (Binary p f g) 

-- pushing a binary operator requires stack evaluation if the stack has a left unary operator
push_operator (RPN stack (LeftUnary g' : ops)) (Binary p f g) = do
  stack' <- spy "popping unary" pop_unary stack g'
  push_operator (RPN stack' ops) (Binary p f g)

pop_unary :: ∀ a. List a -> (a -> a) -> Maybe (List a)
pop_unary (x : xs) f = Just (f x : xs)
pop_unary Nil _ = Nothing

pop_binary :: ∀ a. List a -> (a -> a -> a) -> Maybe (List a)
pop_binary (right : left : xs) f = Just (f left right : xs)
pop_binary _ _ = Nothing

finalize :: ∀ a. RPN a -> Maybe a
-- finalizing an RPN stack with an empty operator stack and a single value is success
finalize (RPN (x : Nil) Nil) = spy "finalize done" (Just x)

-- unary operators can be evaluated with the top item on the stack
finalize (RPN (v : stack) (LeftUnary f : ops)) = spy "finalize unary" (finalize (RPN (f v : stack) ops))
finalize (RPN (v : stack) (RightUnary f : ops)) = spy "finalize unary" (finalize (RPN (f v : stack) ops))

-- binary operatores require two operands
finalize (RPN (right : left : stack) (Binary _ _ g : ops)) = spy "finalize binary" (finalize (RPN (g left right : stack) ops))

-- pass groups through
finalize (RPN stack (Group : ops)) = spy "finalize group" (finalize (RPN stack ops))

-- anything else is an error
finalize _ = spy "finalize error" Nothing
