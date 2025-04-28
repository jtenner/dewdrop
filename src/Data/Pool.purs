module Data.Pool where

import Prelude

import Data.Map (Map, empty, insert, lookup)
import Data.Maybe (Maybe)
import Data.Tuple (Tuple(..))
import Record (merge)

newtype Pool a = Pool { next_id :: Int, pool :: Map Int a }

newtype PoolKey :: ∀ k. k -> Type
newtype PoolKey _a = PoolKey Int

pool_new :: ∀ (@a :: Type). Pool a
pool_new = Pool { next_id: 0, pool: empty }

pool_allocate :: ∀ (@a :: Type). Pool a -> Tuple (PoolKey a) (Pool a)
pool_allocate (Pool state@{ next_id }) = Tuple (PoolKey next_id) $ Pool $ merge { next_id: next_id + 1 } state

pool_set :: ∀ (@a :: Type). PoolKey a -> a -> Pool a -> Pool a
pool_set (PoolKey id) value (Pool { next_id, pool }) = Pool { next_id, pool: insert id value pool }

pool_get :: ∀ (@a :: Type). PoolKey a -> Pool a -> Maybe a
pool_get (PoolKey id) (Pool { pool }) = lookup id pool
