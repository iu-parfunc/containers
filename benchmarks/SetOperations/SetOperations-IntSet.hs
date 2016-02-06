module Main where

import Data.IntSet as C
import SetOperations

import VersionCheck.Containers

main = do
  printContainersVersion
  benchmark fromList True [("union", C.union), ("difference", C.difference), ("intersection", C.intersection)]
