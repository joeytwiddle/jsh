#!/bin/sh
## Removes all special terminal characters from stream
## See also: strings, mimencode
## (Problem with 'strings', is that it also strips adjacent newlines.)
# jsh-ext-depends: sed

## Alternative (didn't try it yet):
# sed 's/\\033\[[0-9;m]*//g'

## Remove curses colour codes:
sed -u 's+[^m]*m++g' |

## Remove other non-printing characters:
sed -u 's+[^[:print:][:space:]]++g'

