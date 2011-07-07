module Numeric.Additive.Group
  ( 
  -- * Additive Groups
    AdditiveGroup(..)
  , replicateGroup
  -- * Additive Abelian Groups
  , AdditiveAbelianGroup
  ) where

import Data.Int
import Data.Word
import Prelude hiding ((+), (-), negate, subtract)
import qualified Prelude
import Numeric.Additive.Semigroup
import Numeric.Additive.Monoid

class AdditiveMonoid r => AdditiveGroup r where
  (-)      :: r -> r -> r
  negate   :: r -> r
  subtract :: r -> r -> r

  negate a = zero - a
  a - b  = a + negate b 
  subtract a b = negate a + b

class AdditiveGroup r => AdditiveAbelianGroup r

replicateGroup :: (Integral n, AdditiveGroup r) => n -> r -> r
replicateGroup y0 x0 = case compare y0 0 of
  LT -> f (negate x0) (Prelude.negate y0)
  EQ -> zero
  GT -> f x0 y0
  where
    f x y 
      | even y = f (x + x) (y `quot` 2)
      | y == 1 = x
      | otherwise = g (x + x) ((y Prelude.- 1) `quot` 2) x
    g x y z 
      | even y = g (x + x) (y `quot` 2) z
      | y == 1 = x + z
      | otherwise = g (x + x) ((y Prelude.- 1) `quot` 2) (x + z)


instance AdditiveGroup r => AdditiveGroup (e -> r) where
  f - g = \x -> f x - g x
  negate f x = negate (f x)
  subtract f g x = subtract (f x) (g x)

instance AdditiveGroup Integer where
  (-) = (Prelude.-)
  negate = Prelude.negate
  subtract = Prelude.subtract

instance AdditiveGroup Int where
  (-) = (Prelude.-)
  negate = Prelude.negate
  subtract = Prelude.subtract

instance AdditiveGroup Int8 where
  (-) = (Prelude.-)
  negate = Prelude.negate
  subtract = Prelude.subtract

instance AdditiveGroup Int16 where
  (-) = (Prelude.-)
  negate = Prelude.negate
  subtract = Prelude.subtract

instance AdditiveGroup Int32 where
  (-) = (Prelude.-)
  negate = Prelude.negate
  subtract = Prelude.subtract

instance AdditiveGroup Int64 where
  (-) = (Prelude.-)
  negate = Prelude.negate
  subtract = Prelude.subtract

instance AdditiveGroup Word where
  (-) = (Prelude.-)
  negate = Prelude.negate
  subtract = Prelude.subtract

instance AdditiveGroup Word8 where
  (-) = (Prelude.-)
  negate = Prelude.negate
  subtract = Prelude.subtract

instance AdditiveGroup Word16 where
  (-) = (Prelude.-)
  negate = Prelude.negate
  subtract = Prelude.subtract

instance AdditiveGroup Word32 where
  (-) = (Prelude.-)
  negate = Prelude.negate
  subtract = Prelude.subtract

instance AdditiveGroup Word64 where
  (-) = (Prelude.-)
  negate = Prelude.negate
  subtract = Prelude.subtract

-- *** Additive Abelian Group Instances

instance AdditiveAbelianGroup r => AdditiveAbelianGroup (e -> r)
instance AdditiveAbelianGroup Integer
instance AdditiveAbelianGroup Int
instance AdditiveAbelianGroup Int8
instance AdditiveAbelianGroup Int16
instance AdditiveAbelianGroup Int32
instance AdditiveAbelianGroup Int64
instance AdditiveAbelianGroup Word
instance AdditiveAbelianGroup Word8
instance AdditiveAbelianGroup Word16
instance AdditiveAbelianGroup Word32
instance AdditiveAbelianGroup Word64

