module VersionCheck.Containers where

containersVersion :: String
containersVersion = "The right one"

printContainersVersion :: IO ()
printContainersVersion = putStrLn ("Containers version: " ++ containersVersion)
