#!/usr/bin/runhugs

module Main where
-- import IO
import System

main = do
       args <- getArgs
       (if (head (args!!0) == '/') then (putStr "") else exitFailure)

       -- (if (2==2) then exitFailure else (putStrLn "tmp"))

       -- myshow args)

fart = show getArgs

