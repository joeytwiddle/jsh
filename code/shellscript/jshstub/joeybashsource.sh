## When bash sources a script, that script cannot obtain the name it was sourced with!
## But if we alias "source" and "." in bash to this script, it can intercept
## the call, and set the TOSOURCE variable.

## Of course, we still have problems losing the alias

# TOOLNAMEB4="$TOOLNAME"

TOOLNAME="$1"
shift

# test ! "$JBSLEVEL" && JBSLEVEL=">"
# JBSLEVELB4="$JBSLEVEL"
# export JBSLEVEL="$JBSLEVEL".

# echo "[$JBSLEVELB4 joeybashsource Intercepted . $TOOLNAME $* ]" >&2

export TOSOURCE=$TOOLNAME

## I thought we might need this when bash didn't seem to be rehashing, but I now think the problem was elsewhere.
## Actually, watching the JBSLEVEL this seems very important!
export DONTEXEC=true
'.' $TOOLNAME "$@"
unset DONTEXEC

# echo "[$JBSLEVEL joeybashsource '.' $TOOLNAME $* ]" >&2
# echo >&2

'.' $TOOLNAME "$@"

unset TOSOURCE

# export JBSLEVEL="$JBSLEVELB4"
# echo "[$JBSLEVEL END joeybashsource '.' $TOOLNAME $* ]" >&2
# export TOOLNAME="$TOOLNAMEB4"
