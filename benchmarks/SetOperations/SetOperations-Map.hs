module Main where

import Data.Map as C
import SetOperations

import VersionCheck.Containers

main = do
  printContainersVersion
  benchmark (\xs -> fromList [(x, x) | x <- xs]) True [("union", C.union), ("difference", C.difference), ("intersection", C.intersection)]
