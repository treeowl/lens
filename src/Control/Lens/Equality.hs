{-# LANGUAGE GADTs #-}
{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE TypeFamilies #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Control.Lens.Equality
-- Copyright   :  (C) 2012-13 Edward Kmett
-- License     :  BSD-style (see the file LICENSE)
-- Maintainer  :  Edward Kmett <ekmett@gmail.com>
-- Stability   :  provisional
-- Portability :  Rank2Types
--
----------------------------------------------------------------------------
module Control.Lens.Equality
  (
  -- * Type Equality
    Equality, Equality'
  , AnEquality, AnEquality'
  , runEq
  , substEq
  , mapEq
  , fromEq
  , simply
  -- * Implementation Details
  , Identical(..)
  ) where

import Control.Lens.Internal.Setter
import Control.Lens.Type

{-# ANN module "HLint: ignore Use id" #-}
{-# ANN module "HLint: ignore Eta reduce" #-}

-- $setup
-- >>> import Control.Lens

-----------------------------------------------------------------------------
-- Equality
-----------------------------------------------------------------------------

data Identical a b s t where
  Identical :: Identical a b a b

-- | When you see this as an argument to a function, it expects an 'Equality'.
type AnEquality s t a b = Identical a (Mutator b) a (Mutator b) -> Identical a (Mutator b) s (Mutator t)

-- | A 'Simple' 'AnEquality'.
type AnEquality' s a = AnEquality s s a a

-- | Extract a witness of type 'Equality'.
runEq :: AnEquality s t a b -> Identical s t a b
runEq l = case l Identical of Identical -> Identical
{-# INLINE runEq #-}

-- | Substituting types with 'Equality'.
substEq :: AnEquality s t a b -> ((s ~ a, t ~ b) => r) -> r
substEq l = case runEq l of
  Identical -> \r -> r
{-# INLINE substEq #-}

-- | We can use 'Equality' to do substitution into anything.
mapEq :: AnEquality s t a b -> f s -> f a
mapEq l r = substEq l r
{-# INLINE mapEq #-}

-- | 'Equality' is symmetric.
fromEq :: AnEquality s t a b -> Equality b a t s
fromEq l = substEq l id
{-# INLINE fromEq #-}

simply :: (Overloaded' p f s a -> r) -> Overloaded' p f s a -> r
simply = id
{-# INLINE simply #-}
