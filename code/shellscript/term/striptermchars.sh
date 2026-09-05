#!/bin/sh
## Removes all special terminal characters from stream
## See also: strings -w, mimencode
## (Problem with 'strings', is that it also strips adjacent newlines.  Somewhere between binutils-2.22 and binutils-2.36 the -w option was introduced to disable that behaviour.)
# jsh-ext-depends: sed

## Stricter version:
# sed 's/\x1b\[[0-9;]*m//g'

## Remove curses colour codes:
sed -u 's+\[[^m]*m++g ; s+\[K++g' |

## Alternative (didn't try it yet):
# sed 's/\\033\[[0-9;m]*//g'

## Remove non-printing characters:
sed -u 's+[^[:print:][:space:]]++g'
#tr -dc '[:space:][:print:]'

## Alternatively, if you want to strip Unicode characters too, then you can select ASCII characters only
# tr -dc '\0-\177'
## Here we strip all non-ASCII characters and a few problematic ASCII characters
## See: https://unix.stackexchange.com/questions/475548/removing-all-non-ascii-characters-from-a-workflow-file/475549#475568
## (176 is octal for 126)
# tr -dc '\7-\15\40-\176'
## You could also convert the unknown characters to '?'s
# tr -c '\7-\15\40-\176' '?'
## NOTE: The output from tr can sometimes stall when reading from a stream
## So you may prefer to use sed, because it can run line-buffered.
# LC_ALL=C sed -u 's/[^\o007-\o015\o040-\o176]/?/g'

## iconv can do something similar, but
## WARNING: it only works for entire files, not for streams!
# iconv -c -f utf-8 -t ascii -
