{-# language DeriveFunctor, DeriveFoldable, TypeFamilies #-}
module Data.Sparse.Internal.IntM where

import Data.Sparse.Utils
import Numeric.Eps
import Numeric.LinearAlgebra.Class

import GHC.Exts
import Data.Complex
import Data.Monoid (All(..))

import qualified Data.IntMap.Strict as IM





-- | A synonym for IntMap 
newtype IntM a = IntM {unIM :: IM.IntMap a} deriving (Eq, Show, Functor, Foldable)

empty :: IntM a
empty = IntM IM.empty

size :: IntM a -> Int
size (IntM x) = IM.size x

singleton :: IM.Key -> a -> IntM a
singleton i x = IntM $ IM.singleton i x

filterWithKey f im = IntM $ IM.filterWithKey f (unIM im)

insert :: IM.Key -> a -> IntM a -> IntM a
insert k x (IntM im) = IntM $ IM.insert k x im

filterI :: (a -> Bool) -> IntM a -> IntM a
filterI f (IntM im) = IntM $ IM.filter f im

lookup :: IM.Key -> IntM a -> Maybe a
lookup i (IntM im) = IM.lookup i im

lookupLT x (IntM im) = IM.lookupLT x im

foldlWithKey :: (a -> IM.Key -> b -> a) -> a -> IntM b -> a
foldlWithKey f z (IntM im) = IM.foldlWithKey f z im

foldlWithKey' :: (a -> IM.Key -> b -> a) -> a -> IntM b -> a
foldlWithKey' f z (IntM im) = IM.foldlWithKey' f z im

mapWithKey f (IntM im) = IntM $ IM.mapWithKey f im

keys :: IntM a -> [IM.Key]
keys (IntM im) = IM.keys im

mapKeys f (IntM im) = IntM $ IM.mapKeys f im

union :: IntM a -> IntM a -> IntM a
union (IntM a) (IntM b) = IntM $ IM.union a b

findMin (IntM im) = IM.findMin im
findMax (IntM im) = IM.findMax im

(!) :: IntM a -> IM.Key -> a
(IntM im) ! i = im IM.! i


instance IsList (IntM a) where
  type Item (IntM a) = (Int, a)
  fromList = IntM . IM.fromList
  toList = IM.toList . unIM



instance Set IntM where
  liftU2 f (IntM a) (IntM b) = IntM $ IM.unionWith f a b
  liftI2 f (IntM a) (IntM b) = IntM $ IM.intersectionWith f a b


instance AdditiveGroup a => AdditiveGroup (IntM a) where
  zeroV = IntM IM.empty
  {-# INLINE zeroV #-}
  (^+^) = liftU2 (^+^)
  {-# INLINE (^+^) #-}
  negateV = fmap negateV
  {-# INLINE negateV #-}

instance VectorSpace a => VectorSpace (IntM a) where
  type Scalar (IntM a) = Scalar a
  n .* v = fmap (n .*) v

instance InnerSpace a => InnerSpace (IntM a) where
  v <.> w = sum $ liftI2 (<.>) v w

instance (Normed a, Magnitude a ~ RealScalar a, RealScalar a ~ Scalar a) => Normed (IntM a) where
  type Magnitude  (IntM a) = Magnitude a
  type RealScalar (IntM a) = RealScalar a
  norm1   = sum . fmap norm1
  norm2Sq = sum . fmap norm2Sq
  normP p v = (sum (fmap (\x -> normP p x ** p) v)) ** (1 / p)
  normalize p v = v ./ normP p v
  normalize2  v = v ./ norm2 v
  normalize2' v = v ./ norm2' v
  norm2  c = sqrt (norm2Sq c)
  norm2' c = sqrt (norm2Sq c)

instance Epsilon a => Epsilon (IntM a) where
  nearZero = getAll . foldMap (All . nearZero)
  -- TODO: rewrite with generic merge combinator?
  near (IntM x) (IntM y) = nearZero (IntM (IM.difference x y))
                        && nearZero (IntM (IM.difference y x))
                        && getAll (foldMap All (IM.intersectionWith (\a b -> a `near` b) x y))


-- -- | list to IntMap
-- mkIm :: [Double] -> IM.IntMap Double
mkIm xs = fromList $ indexed xs :: IntM Double

-- mkImC :: [Complex Double] -> IM.IntMap (Complex Double)
mkImC xs = fromList $ indexed xs :: IntM (Complex Double)
