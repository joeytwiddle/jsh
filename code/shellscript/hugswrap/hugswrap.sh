#!/bin/sh
## Usage: hugswrap <modulename_to_import> <hugs_command_to_run>

TMPFILE=`jgettmp baseconv`

cat > $TMPFILE << !

module Main where
import System
import $1

main = do
  args <- getArgs
  putStrLn ($2)

!

runhugs $TMPFILE

jdeltmp $TMPFILE
