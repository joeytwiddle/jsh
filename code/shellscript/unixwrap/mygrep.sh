# This work of genius attempts to prevent error messages
# if user greps eg. * and has not specified how to deal with directories.

# Hey dufus, this should be a shell alias!
# Hey dufus, it can't be 'cos it adds to the end of the line!

REALGREP=`jwhich grep`

# $REALGREP "$@" 1>&3 2>&1 | $REALGREP -v "^grep: .*: Is a directory$"
$REALGREP "$@" 2> /dev/null
