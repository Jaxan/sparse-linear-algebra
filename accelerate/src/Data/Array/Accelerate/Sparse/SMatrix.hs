module Data.Array.Accelerate.Sparse.SMatrix where

import qualified Data.Array.Accelerate as A
import Data.Array.Accelerate
          (Acc, Array, Vector, Segments, DIM1, DIM2, Exp, Any(Any), All(All), Z(Z), (:.)((:.)))

import Data.Array.Accelerate.Sparse.SVector



data SMatrix i e = SMatrix {
    smNrows :: Int
  , smNcols :: Int
  , smSegments :: Segments i
  , smEntries :: SVector e } deriving (Eq, Show)



data SSMatrix i m n e = SSMatrix {
    ssmNrows :: m
  , ssmNcols :: n
  , ssmSegments :: Segments i
  , ssmEntries :: SVector e
                                 }


-- | sparse matrix, coordinate representation
data SMatrixCOO i e = SMCOO {
    smcoNrows :: Int
  , smcoNcols :: Int
  , smcoRows, smcoCols :: Array DIM1 i
  , smcoEntries        :: Array DIM1 e
                            } deriving (Eq, Show)

-- | array-of-struct representation of "
data SMatCOO2 i e = SMCOO2 {
    smcooNrows :: Int
  , smcooNcols :: Int   
  , smcooEntries        :: Array DIM1 (COOElem i e)
                           }

newtype COOElem i e = CooE (i, i, e) deriving (Eq, Show)
getRow (CooE (i, _, _)) = i
getCol (CooE (_, j, _)) = j
getElem (CooE (_, _, e)) = e
setElem e' (CooE (i, j, _)) = CooE (i, j, e')

-- | Lexicographic ordering, rows-first
instance (Eq e, Ord i) => Ord (COOElem i e ) where
  (CooE (i, j, _)) <= (CooE (i', j', _))
    | i < i' = True
    | i == i' && j <= j' = True
    | otherwise = False


-- -- identity ::
-- --    (A.IsNum a, A.Elt a) =>
-- --    Exp DIM2 -> Acc (Array DIM2 a)
-- identity sh =
--    A.generate sh
--       (withMatrixIndex $
--        \(_ :. r :. c) -> A.fromIntegral $ A.boolToInt (r A.== c))

-- -- withMatrixIndex :: (A.Lift c a, A.Unlift d b) =>
-- --      (a -> b) -> c (A.Plain a) -> d (A.Plain b)
-- withMatrixIndex f = A.lift . f . A.unlift      
