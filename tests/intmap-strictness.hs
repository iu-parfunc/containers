{-# LANGUAGE FlexibleInstances, GeneralizedNewtypeDeriving #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Main (main) where

import Test.ChasingBottoms.IsBottom
import Test.Framework (Test, defaultMain, testGroup)
import Test.Framework.Providers.QuickCheck2 (testProperty)
import Test.QuickCheck (Arbitrary(arbitrary))

import Data.IntMap.Strict (IntMap)
import qualified Data.IntMap.Strict as M

instance Arbitrary v => Arbitrary (IntMap v) where
    arbitrary = M.fromList `fmap` arbitrary

instance Show (Int -> Int) where
    show _ = "<function>"

instance Show (Int -> Int -> Int) where
    show _ = "<function>"

instance Show (Int -> Int -> Int -> Int) where
    show _ = "<function>"

------------------------------------------------------------------------
-- * Properties

------------------------------------------------------------------------
-- ** Strict module

pSingletonKeyStrict :: Int -> Bool
pSingletonKeyStrict v = isBottom $ M.singleton (bottom :: Int) v

pSingletonValueStrict :: Int -> Bool
pSingletonValueStrict k = isBottom $ (M.singleton k (bottom :: Int))

pFindWithDefaultKeyStrict :: Int -> IntMap Int -> Bool
pFindWithDefaultKeyStrict def m = isBottom $ M.findWithDefault def bottom m

pFindWithDefaultValueStrict :: Int -> IntMap Int -> Bool
pFindWithDefaultValueStrict k m =
    M.member k m || (isBottom $ M.findWithDefault bottom k m)

pAdjustKeyStrict :: (Int -> Int) -> IntMap Int -> Bool
pAdjustKeyStrict f m = isBottom $ M.adjust f bottom m

pAdjustValueStrict :: Int -> IntMap Int -> Bool
pAdjustValueStrict k m
    | k `M.member` m = isBottom $ M.adjust (const bottom) k m
    | otherwise       = case M.keys m of
        []     -> True
        (k':_) -> isBottom $ M.adjust (const bottom) k' m

pInsertKeyStrict :: Int -> IntMap Int -> Bool
pInsertKeyStrict v m = isBottom $ M.insert bottom v m

pInsertValueStrict :: Int -> IntMap Int -> Bool
pInsertValueStrict k m = isBottom $ M.insert k bottom m

pInsertWithKeyStrict :: (Int -> Int -> Int) -> Int -> IntMap Int -> Bool
pInsertWithKeyStrict f v m = isBottom $ M.insertWith f bottom v m

pInsertWithValueStrict :: (Int -> Int -> Int) -> Int -> Int -> IntMap Int
                       -> Bool
pInsertWithValueStrict f k v m
    | M.member k m = (isBottom $ M.insertWith (const2 bottom) k v m) &&
                     not (isBottom $ M.insertWith (const2 1) k bottom m)
    | otherwise    = isBottom $ M.insertWith f k bottom m

pInsertLookupWithKeyKeyStrict :: (Int -> Int -> Int -> Int) -> Int -> IntMap Int
                              -> Bool
pInsertLookupWithKeyKeyStrict f v m = isBottom $ M.insertLookupWithKey f bottom v m

pInsertLookupWithKeyValueStrict :: (Int -> Int -> Int -> Int) -> Int -> Int
                                -> IntMap Int -> Bool
pInsertLookupWithKeyValueStrict f k v m
    | M.member k m = (isBottom $ M.insertLookupWithKey (const3 bottom) k v m) &&
                     not (isBottom $ M.insertLookupWithKey (const3 1) k bottom m)
    | otherwise    = isBottom $ M.insertLookupWithKey f k bottom m

------------------------------------------------------------------------
-- * Test list

tests :: [Test]
tests =
    [
    -- Basic interface
      testGroup "IntMap.Strict"
      [ testProperty "singleton is key-strict" pSingletonKeyStrict
      , testProperty "singleton is value-strict" pSingletonValueStrict
      , testProperty "member is key-strict" $ keyStrict M.member
      , testProperty "lookup is key-strict" $ keyStrict M.lookup
      , testProperty "findWithDefault is key-strict" pFindWithDefaultKeyStrict
      , testProperty "findWithDefault is value-strict" pFindWithDefaultValueStrict
      , testProperty "! is key-strict" $ keyStrict (flip (M.!))
      , testProperty "delete is key-strict" $ keyStrict M.delete
      , testProperty "adjust is key-strict" pAdjustKeyStrict
      , testProperty "adjust is value-strict" pAdjustValueStrict
      , testProperty "insert is key-strict" pInsertKeyStrict
      , testProperty "insert is value-strict" pInsertValueStrict
      , testProperty "insertWith is key-strict" pInsertWithKeyStrict
      , testProperty "insertWith is value-strict" pInsertWithValueStrict
      , testProperty "insertLookupWithKey is key-strict"
        pInsertLookupWithKeyKeyStrict
      , testProperty "insertLookupWithKey is value-strict"
        pInsertLookupWithKeyValueStrict
      ]
    ]

------------------------------------------------------------------------
-- * Test harness

main :: IO ()
main = defaultMain tests

------------------------------------------------------------------------
-- * Utilities

keyStrict :: (Int -> IntMap Int -> a) -> IntMap Int -> Bool
keyStrict f m = isBottom $ f bottom m

const2 :: a -> b -> c -> a
const2 x _ _ = x

const3 :: a -> b -> c -> d -> a
const3 x _ _ _ = x
