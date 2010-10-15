#!/bin/sh
cd $JPATH/code/haskell
# hugswrap Base 'concat [ "s/%" ++ baseconvpadded 2 decimal hex x ++ "/\\" ++ baseconvpadded 3 decimal octal x ++ "/;" | x <- map show [1..255] ]'
# hugswrap Base 'concat [ "s/%" ++ baseconvpadded 2 decimal hex x ++ "/\\" ++ baseconvpadded 3 decimal octal x ++ "/\n" | x <- map show [1..255] ]'
hugswrap Base 'concat [ "s/%" ++ baseconvpadded 2 decimal hex (show x) ++ "/" ++ [chr x] ++ "/g\n" | x <- [1..255] ]'
