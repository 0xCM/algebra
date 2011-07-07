module Numeric.Functional.Linear 
  ( Linear(..)
  ) where

import Numeric.Additive
import Control.Applicative
import Control.Monad
import Data.Functor.Plus hiding (zero)
import qualified Data.Functor.Plus as Plus
import Data.Functor.Bind
import qualified Prelude
import Prelude hiding ((+),(-),negate,subtract,replicate)

-- | Linear functionals from elements of a free module to a scalar

-- appLinear f (x + y) = appLinear f x + appLinear f y
-- appLinear f (a .* x) = a * appLinear f x

newtype Linear s a = Linear { appLinear :: (a -> s) -> s }

instance Functor (Linear s) where
  fmap f (Linear m) = Linear (\k -> m (k . f))

instance Apply (Linear s) where
  Linear mf <.> Linear ma = Linear (\k -> mf (\f -> ma (k . f)))

instance Applicative (Linear s) where
  pure a = Linear (\k -> k a)
  Linear mf <*> Linear ma = Linear (\k -> mf (\f -> ma (k . f)))

instance Bind (Linear s) where
  Linear m >>- f = Linear (\k -> m (\a -> appLinear (f a) k))
  
instance Monad (Linear s) where
  return a = Linear (\k -> k a)
  Linear m >>= f = Linear (\k -> m (\a -> appLinear (f a) k))

instance AdditiveSemigroup s => Alt (Linear s) where
  Linear m <!> Linear n = Linear (m + n)

instance AdditiveMonoid s => Plus (Linear s) where
  zero = Linear zero 

instance AdditiveMonoid s => Alternative (Linear s) where
  Linear m <|> Linear n = Linear (m + n)
  empty = Linear zero

instance AdditiveMonoid s => MonadPlus (Linear s) where
  Linear m `mplus` Linear n = Linear (m + n)
  mzero = Linear zero

instance AdditiveSemigroup s => AdditiveSemigroup (Linear s a) where
  Linear m + Linear n = Linear (m + n)
  replicate n (Linear m) = Linear (replicate n m)

instance AdditiveMonoid s => AdditiveMonoid (Linear s a) where
  zero = Linear zero

instance AdditiveGroup s => AdditiveGroup (Linear s a) where
  Linear m - Linear n = Linear (m - n)
  negate (Linear m) = Linear (negate m)
  subtract (Linear m) (Linear n) = Linear (subtract m n)

instance AdditiveAbelianGroup s => AdditiveAbelianGroup (Linear s a)

-- instance MultiplicativeSemigroup s => LeftModule s (Linear s a) where
--  s .* Linear m = Linear (s .* m)

-- instance MultiplicativeSemigroup s => RightModule s (Linear s a) where
--  Linear m *. s = Linear (m *. s)

