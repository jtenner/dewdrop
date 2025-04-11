module Data.Dewdrop.Identifier where

import Prelude

import Data.Dewdrop.Visitor (class Pass, class Visitable, ignore)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))

data Identifier
  = NameIdentifier String
  | TypeIdentifier String

instance eq_identifier :: Eq Identifier where
  eq (NameIdentifier name) (NameIdentifier name') = name == name'
  eq (TypeIdentifier type_name) (TypeIdentifier type_name') = type_name == type_name'
  eq _ _ = false

instance ord_identifier :: Ord Identifier where
  compare (NameIdentifier name) (NameIdentifier name') = compare name name'
  compare (TypeIdentifier type_name) (TypeIdentifier type_name') = compare type_name type_name'
  compare (NameIdentifier _) _ = GT
  compare _ (NameIdentifier _) = LT

instance show_identifier :: Show Identifier where
  show (NameIdentifier name) = "(Name " <> name <> ")"
  show (TypeIdentifier name) = "(Type " <> name <> ")"

instance visitable_identifier :: (Pass Identifier ctx) => Visitable Identifier ctx where
  visit_children n ctx = Just $ Tuple ctx n

instance pass_identifier :: Pass Identifier ctx where
  enter = ignore
  exit = ignore
