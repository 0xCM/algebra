{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances #-}
-- This package is an unfortunate ball of mud forced on me by mutual dependencies
module Numeric.Semiring.Internal
  ( 
  -- * Multiplicative Semigroups
    Multiplicative(..)
  , pow1pIntegral
  , product1
  -- * Semirings
  , Semiring
  -- * Associative algebras of free semigroups over semirings
  , FreeAlgebra(..)
  ) where

import Data.Foldable hiding (sum, concat)
import Data.Semigroup.Foldable
import Data.Int
import Data.Word
import Prelude hiding ((*), (+), negate, subtract,(-), recip, (/), foldr, sum, product, replicate, concat)
import qualified Prelude
import Numeric.Natural.Internal
import Numeric.Semigroup.Additive
import Numeric.Addition.Abelian

infixr 8 `pow1p`
infixl 7 *

-- | A multiplicative semigroup
class Multiplicative r where
  (*) :: r -> r -> r 

  -- pow1p x n = pow x (1 + n)
  pow1p :: Whole n => r -> n -> r
  pow1p x0 y0 = f x0 (y0 Prelude.+ 1) where
    f x y 
      | even y = f (x * x) (y `quot` 2)
      | y == 1 = x
      | otherwise = g (x * x) ((y Prelude.- 1) `quot` 2) x
    g x y z 
      | even y = g (x * x) (y `quot` 2) z
      | y == 1 = x * z
      | otherwise = g (x * x) ((y Prelude.- 1) `quot` 2) (x * z)

  productWith1 :: Foldable1 f => (a -> r) -> f a -> r
  productWith1 f = maybe (error "Numeric.Multiplicative.Semigroup.productWith1: empty structure") id . foldl' mf Nothing
    where 
      mf Nothing y = Just $! f y
      mf (Just x) y = Just $! x * f y

product1 :: (Foldable1 f, Multiplicative r) => f r -> r
product1 = productWith1 id

pow1pIntegral :: (Integral r, Integral n) => r -> n -> r
pow1pIntegral r n = r ^ (1 Prelude.+ n)

instance Multiplicative Bool where
  (*) = (&&)
  pow1p m _ = m

instance Multiplicative Natural where
  (*) = (Prelude.*)
  pow1p = pow1pIntegral

instance Multiplicative Integer where
  (*) = (Prelude.*)
  pow1p = pow1pIntegral

instance Multiplicative Int where
  (*) = (Prelude.*)
  pow1p = pow1pIntegral

instance Multiplicative Int8 where
  (*) = (Prelude.*)
  pow1p = pow1pIntegral

instance Multiplicative Int16 where
  (*) = (Prelude.*)
  pow1p = pow1pIntegral

instance Multiplicative Int32 where
  (*) = (Prelude.*)
  pow1p = pow1pIntegral

instance Multiplicative Int64 where
  (*) = (Prelude.*)
  pow1p = pow1pIntegral

instance Multiplicative Word where
  (*) = (Prelude.*)
  pow1p = pow1pIntegral

instance Multiplicative Word8 where
  (*) = (Prelude.*)
  pow1p = pow1pIntegral

instance Multiplicative Word16 where
  (*) = (Prelude.*)
  pow1p = pow1pIntegral

instance Multiplicative Word32 where
  (*) = (Prelude.*)
  pow1p = pow1pIntegral

instance Multiplicative Word64 where
  (*) = (Prelude.*)
  pow1p = pow1pIntegral

instance Multiplicative () where
  _ * _ = ()
  pow1p _ _ = ()

instance (Multiplicative a, Multiplicative b) => Multiplicative (a,b) where
  (a,b) * (c,d) = (a * c, b * d)

instance (Multiplicative a, Multiplicative b, Multiplicative c) => Multiplicative (a,b,c) where
  (a,b,c) * (i,j,k) = (a * i, b * j, c * k)

instance (Multiplicative a, Multiplicative b, Multiplicative c, Multiplicative d) => Multiplicative (a,b,c,d) where
  (a,b,c,d) * (i,j,k,l) = (a * i, b * j, c * k, d * l)

instance (Multiplicative a, Multiplicative b, Multiplicative c, Multiplicative d, Multiplicative e) => Multiplicative (a,b,c,d,e) where
  (a,b,c,d,e) * (i,j,k,l,m) = (a * i, b * j, c * k, d * l, e * m)

-- | A pair of an additive abelian semigroup, and a multiplicative semigroup, with the distributive laws:
-- 
-- > a(b + c) = ab + ac
-- > (a + b)c = ac + bc
--
-- Common notation includes the laws for additive and multiplicative identity in semiring.
--
-- If you want that, look at 'Rig' instead.
--
-- Ideally we'd use the cyclic definition:
--
-- > class (LeftModule r r, RightModule r r, Additive r, Abelian r, Multiplicative r) => Semiring r
--
-- to enforce that every semiring r is an r-module over itself, but Haskell doesn't like that.
class (Additive r, Abelian r, Multiplicative r) => Semiring r

instance Semiring Integer
instance Semiring Natural
instance Semiring Bool
instance Semiring Int
instance Semiring Int8
instance Semiring Int16
instance Semiring Int32
instance Semiring Int64
instance Semiring Word
instance Semiring Word8
instance Semiring Word16
instance Semiring Word32
instance Semiring Word64
instance Semiring ()
instance (Semiring a, Semiring b) => Semiring (a, b)
instance (Semiring a, Semiring b, Semiring c) => Semiring (a, b, c)
instance (Semiring a, Semiring b, Semiring c, Semiring d) => Semiring (a, b, c, d)
instance (Semiring a, Semiring b, Semiring c, Semiring d, Semiring e) => Semiring (a, b, c, d, e)

-- | An associative algebra built with a free module over a semiring
class Semiring r => FreeAlgebra r a where
  join :: (a -> a -> r) -> a -> r

instance FreeAlgebra r a => Multiplicative (a -> r) where
  f * g = join $ \a b -> f a * g b

instance FreeAlgebra r a => Semiring (a -> r) 

  
instance FreeAlgebra () a where
  join _ _ = ()

-- TODO: check this
instance (FreeAlgebra r b, FreeAlgebra r a) => FreeAlgebra (b -> r) a where
  join f a b = join (\a1 a2 -> f a1 a2 b) a

instance (FreeAlgebra r a, FreeAlgebra r b) => FreeAlgebra r (a,b) where
  join f (a,b) = join (\a1 a2 -> join (\b1 b2 -> f (a1,b1) (a2,b2)) b) a

instance (FreeAlgebra r a, FreeAlgebra r b, FreeAlgebra r c) => FreeAlgebra r (a,b,c) where
  join f (a,b,c) = join (\a1 a2 -> join (\b1 b2 -> join (\c1 c2 -> f (a1,b1,c1) (a2,b2,c2)) c) b) a

instance (FreeAlgebra r a, FreeAlgebra r b, FreeAlgebra r c, FreeAlgebra r d) => FreeAlgebra r (a,b,c,d) where
  join f (a,b,c,d) = join (\a1 a2 -> join (\b1 b2 -> join (\c1 c2 -> join (\d1 d2 -> f (a1,b1,c1,d1) (a2,b2,c2,d2)) d) c) b) a

instance (FreeAlgebra r a, FreeAlgebra r b, FreeAlgebra r c, FreeAlgebra r d, FreeAlgebra r e) => FreeAlgebra r (a,b,c,d,e) where
  join f (a,b,c,d,e) = join (\a1 a2 -> join (\b1 b2 -> join (\c1 c2 -> join (\d1 d2 -> join (\e1 e2 -> f (a1,b1,c1,d1,e1) (a2,b2,c2,d2,e2)) e) d) c) b) a
