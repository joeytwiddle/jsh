#!/bin/sh
## Removes all special terminal characters from stream
## See also: strings, mimencode
## (Problem with 'strings', is that it also strips adjacent newlines.)
# jsh-ext-depends: sed

## Stricter version:
# sed 's/\x1b\[[0-9;]*m//g'

## Remove curses colour codes:
sed -u 's+[^m]*m++g' |

## Remove other non-printing characters:
sed -u 's+[^[:print:][:space:]]++g'

