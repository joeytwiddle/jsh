## TODO CONSIDER:
## If debug etc. were aliases, they could probably display what script they were called from with "$0"?
## Otherwise to get the calling script + line number, we could try some other tricks, or give up.  pstree!

## Q: What command to set DEBUG=1 and other debugging env vars, before doing something?
## A: ...

## Preferred usage for efficiency:
# [ "$DEBUG" ] && debug <output>
## Note that this will return false outside of debug, hence disrupting set -x etc.

# jsh-depends: cursebold cursecyan cursegreen cursenorm

if [ "$DEBUG" ]
then echo "`cursegreen;cursebold`[DEBUG] `cursecyan`$*`cursenorm`" >&2
fi
