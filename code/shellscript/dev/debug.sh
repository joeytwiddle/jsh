## Preferred usage for efficiency:
# [ "$DEBUG" ] && debug <output>
## Note that this will return false outside of debug, hence disrupting set -x etc.

# jsh-depends: cursebold cursecyan cursegreen cursenorm

if [ "$DEBUG" ]
then echo "`cursegreen;cursebold`[DEBUG] `cursecyan`$*`cursenorm`" >&2
fi
