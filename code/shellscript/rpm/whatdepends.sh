#!/bin/sh
## For when you do an apt-get install but get dependency problems which need resolving.
## Doesn't deal with or options

grep " Depends: " |
afterfirst " Depends: " |
takecols 1 |

## Formatted for easy insertion
## The current context is for downgrading to stable:
# sed 's+$+/unstable+' |
tr '\n' ' '

echo
